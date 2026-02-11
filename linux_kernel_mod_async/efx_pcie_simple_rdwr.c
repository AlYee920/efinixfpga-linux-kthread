#include <linux/module.h>
#include <linux/init.h>
#include <linux/ioport.h>
#include <linux/pci.h>
#include <linux/kthread.h>
#include <linux/delay.h>
#include <linux/interrupt.h>

/* Meta Information */
MODULE_LICENSE("GPL");
MODULE_AUTHOR("EFINIX Inc.");
MODULE_DESCRIPTION("A simple LKM for a PCIe read request");

#define VENDOR_ID 0x1f7a
#define DEVICE_ID 0x0100
// #define RUN_ONCE

// PCIe device
static struct pci_dev *ptr;

// ptr to PCI device's Bar0
static void __iomem *selected_bar;
/* Kernel threads */
static struct task_struct *writer_task = NULL;
static struct task_struct *reader_task = NULL;

static int irq_vector_read = -1;
static int irq_vector_write = -1;
static uint intr_cnt = 0;

static u32 g_val=0;

static irqreturn_t msi_one_read(int irq, void *dev_id)
{
	u32 val;
	val = ioread32(selected_bar + ((intr_cnt * 0x20) & 0xfffff));
	intr_cnt++;
	//pr_info("efx_pcie : MSI_one_read handled!");
	// cpu_relax();
	// cond_resched();
	return IRQ_HANDLED;
}

static irqreturn_t msi_burst_write(int irq, void *dev_id)
{
	u32 i;
	for (i = 0; i < 4 && !kthread_should_stop(); i++)
	{
		iowrite32(g_val, selected_bar + ((g_val * 0x20)&0xfffff));
		g_val++;
	}
	// cpu_relax();
	// cond_resched();
	//pr_info("efx_pcie : MSI_burst_write handled!");
	return IRQ_HANDLED;
}

static int writer_thread_fn(void *data)
{
	u32 val = 0xdead0000;
	int i;
#ifdef RUN_ONCE
	for (i = 0; i < 16 && !kthread_should_stop(); i++)
	{
		iowrite32(val, selected_bar + i * 0x20);
		pr_info("efx_pcie: write_mem_and_print: %x\n", val);
		val++;
	}
#else
	set_user_nice(current, -20);
	while (!kthread_should_stop())
	{

		iowrite32(val, selected_bar + ((val * 0x20) & 0xfffff));
		val++;
		// udelay(1);
		cond_resched();
	}

#endif

	return 0;
}

/* ---------- Reader Thread ---------- */
static int reader_thread_fn(void *data)
{
	u32 val;
	int i;

	set_user_nice(current, -20);

#ifdef RUN_ONCE
	val = ioread32(selected_bar + 0x1000);
	pr_info("efx_pcie: read_mem_and_print: %x\n", val);
#else
	while (!kthread_should_stop())
	{
		val = ioread32(selected_bar + 0x1000);
		// udelay(1);
		cpu_relax();
		cond_resched();
	}
#endif
	return 0;
}

void dump_all_bar(void)
{
	int i;
	resource_size_t bar_start, bar_len;
	u16 cmd;

	printk(KERN_INFO "efx_pcie - BAR Discovery for %04x:%04x\n",
		   ptr->vendor, ptr->device);

	pci_read_config_word(ptr, PCI_COMMAND, &cmd);
	printk(KERN_INFO "efx_pcie - PCI_COMMAND: 0x%04x (MMIO:%s IO:%s MASTER:%s)\n",
		   cmd, (cmd & PCI_COMMAND_MEMORY) ? "ON" : "OFF",
		   (cmd & PCI_COMMAND_IO) ? "ON" : "OFF", (cmd & PCI_COMMAND_MASTER) ? "ON" : "OFF");

	for (i = 0; i < 6; i++)
	{ // 0-5 (BAR0-BAR5)
		bar_start = pci_resource_start(ptr, i);
		bar_len = pci_resource_len(ptr, i);

		if (bar_len == 0)
		{
			printk(KERN_INFO "efx_pcie - BAR%d: DISABLED\n", i);
			continue;
		}

		printk(KERN_INFO "efx_pcie - BAR%d: START=0x%llx LEN=0x%llx %s%s%s\n", i,
			   (unsigned long long)bar_start, (unsigned long long)bar_len,
			   pci_resource_flags(ptr, i) & IORESOURCE_MEM ? "MEM" : "IO",
			   pci_resource_flags(ptr, i) & IORESOURCE_MEM_64 ? " 64BIT" : "",
			   pci_resource_flags(ptr, i) & IORESOURCE_PREFETCH ? " PREFETCH" : "");
	}
}

/**
 * @brief This function is called, when the module is loaded into the kernel
 */
static int __init my_init(void)
{
	printk("Efinix PCIe kernel init\n");

	// Requesting the device
	u16 val;
	// int i;
	int ret;

	ptr = pci_get_device(VENDOR_ID, DEVICE_ID, ptr);
	if (ptr == NULL)
	{
		printk("efx_pcie Cannot see PCI device as requested!\n");
		return -1;
	}

	if (pci_enable_device(ptr) < 0)
	{
		printk("efx_pcie Cannot enable pcie device!\n");
		return -1;
	}

	pci_read_config_word(ptr, PCI_VENDOR_ID, &val);
	printk("efx_pcie - VENDOR_ID: 0x%x\n", val);

	pci_read_config_word(ptr, PCI_DEVICE_ID, &val);
	printk("efx_pcie - DEVICE_ID: 0x%x\n", val);

	dump_all_bar();

	// Attempt to request and map all bar address to CPU address

	if (pci_request_region(ptr, 0, "efx_pcie"))
	{
		printk("efx_pcie - Could not request bar%d! maybe already in use?\n", 0);
		return -1;
	}

	selected_bar = pci_iomap(ptr, 0, pci_resource_len(ptr, 0));

	pr_info("efx_pcie: BAR0 mapped at %p\n", selected_bar);

// pci_enable_ats(ptr, PAGE_SHIFT);
// pci_enable_pasid(ptr);



	/* ---------- Enable MSI ---------- */
	ret = pci_alloc_irq_vectors(ptr, 2, 2, PCI_IRQ_MSI);
	pr_info("efx_pcie: allocated %d MSI interrupt\n", ret);
	if (ret < 0)
	{
		pr_err("efx_pcie: MSI allocation failed\n");
		goto err_out;
	}

	irq_vector_read = pci_irq_vector(ptr, 1);
	//ret = request_irq(irq_vector_read, msi_one_read, IRQF_ONESHOT, "efx_pcie_msi_read", ptr);
	ret = request_threaded_irq(irq_vector_read, NULL, msi_one_read, IRQF_ONESHOT, "efx_pcie_msi_read", ptr);
	if (ret)
	{
		pr_err("efx_pcie_msi_read: request_irq failed : %d\n", ret);
		goto err_out;
	}
	pr_info("efx_pcie: msi_one_read enabled on IRQ %d\n", irq_vector_read);

	irq_vector_write = pci_irq_vector(ptr, 0);
	//ret = request_irq(irq_vector_write, msi_burst_write, IRQF_ONESHOT, "efx_pcie_msi_write", ptr);
	ret = request_threaded_irq(irq_vector_write, NULL, msi_burst_write, IRQF_ONESHOT, "efx_pcie_msi_write", ptr);
	if (ret)
	{
		pr_err("efx_pcie_msi_write: request_irq failed : %d\n", ret);
		goto err_out;
	}
	pr_info("efx_pcie: msi_burst_write enabled on IRQ %d\n", irq_vector_write);

	/* Start concurrent threads */
	// writer_task = kthread_create(writer_thread_fn, NULL, "efx_writer");
	// if (IS_ERR(writer_task))
	// {
	// 	pr_err("efx_pcie: writer thread failed\n");
	// 	goto err_out;
	// }
	// kthread_bind(writer_task, 1);

	// reader_task = kthread_create(reader_thread_fn, NULL, "efx_reader");
	// if (IS_ERR(reader_task))
	// {
	// 	pr_err("efx_pcie: reader thread failed\n");
	// 	kthread_stop(writer_task);
	// 	goto err_out;
	// }
	// kthread_bind(reader_task, 2);
	// wake_up_process(writer_task);
	// wake_up_process(reader_task);

	return 0;

err_out:
	pci_iounmap(ptr, selected_bar);
	pci_release_region(ptr, 0);
	pci_disable_device(ptr);
	if (irq_vector_read >= 0)
	{
		free_irq(irq_vector_read, ptr);
	}
	if (irq_vector_write >= 0)
	{
		free_irq(irq_vector_write, ptr);
	}
	pci_free_irq_vectors(ptr);

	return -EINVAL;
}

/**
 * @brief This function is called, when the module is removed from the kernel
 */
static void __exit my_exit(void)
{
	int i;
	printk("efx_pcie - exit\n");

#ifdef RUN_ONCE
	writer_task = NULL;
	reader_task = NULL;
#else
	if (writer_task)
	{
		kthread_stop(writer_task);
		writer_task = NULL;
	}

	if (reader_task)
	{
		kthread_stop(reader_task);
		reader_task = NULL;
	}
#endif

	if (selected_bar)
		pci_iounmap(ptr, selected_bar);

	if (irq_vector_read >= 0)
	{
		free_irq(irq_vector_read, ptr);
	}
	if (irq_vector_write >= 0)
	{
		free_irq(irq_vector_write, ptr);
	}
	pci_free_irq_vectors(ptr);

	for (i = 0; i < 6; i++)
	{
		pci_release_region(ptr, i);
	}
	pci_disable_device(ptr);
}

module_init(my_init);
module_exit(my_exit);
