#include <linux/module.h>
#include <linux/init.h>
#include <linux/ioport.h>
#include <linux/pci.h>
#include <linux/kthread.h>
#include <linux/delay.h>

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

static int writer_thread_fn(void *data)
{
	u32 val = 0xdead0000;
	int i;
// while (!kthread_should_stop() && atomic_read(&run_flag)) {
// 	iowrite32(val, selected_bar);

// 	/* Ensure write ordering on PCIe */
// 	wmb();

// 	val++;
// 	udelay(10);
// }
#ifdef RUN_ONCE
	for (i = 0; i < 16 && !kthread_should_stop(); i++)
	{
		iowrite32(val, selected_bar + i * 0x20);
		pr_info("efx_pcie: write_mem_and_print: %x\n", val);
		val++;
	}
#else

	while (!kthread_should_stop())
	{
		iowrite32(val, selected_bar + i * 0x20);
		val++;
		//udelay(1);
	}

#endif

	return 0;
}

/* ---------- Reader Thread ---------- */
static int reader_thread_fn(void *data)
{
	u32 val;

	// while (!kthread_should_stop() && atomic_read(&run_flag)) {
	// 	/* Ensure read observes latest writes */
	// 	mb();
	// 	val = ioread32(selected_bar);

	// 	pr_info("efx_pcie: read value = 0x%08x\n", val);
	// 	udelay(20);
	// }
#ifdef RUN_ONCE
	val = ioread32(selected_bar + 0x1000);
	pr_info("efx_pcie: read_mem_and_print: %x\n", val);
	// usleep_range(10, 50);
#else
	while (!kthread_should_stop())
	{
		val = ioread32(selected_bar + 0x1000);
		//udelay(1);
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
	printk(KERN_INFO "efx_pcie - PCI_COMMAND: 0x%04x (MMIO:%s IO:%s Mem:%s)\n",
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

	/* Start concurrent threads */

	writer_task = kthread_create(writer_thread_fn, NULL, "efx_writer");
	if (IS_ERR(writer_task))
	{
		pr_err("efx_pcie: writer thread failed\n");
		goto err_out;
	}
	kthread_bind(writer_task, 1);

	reader_task = kthread_create(reader_thread_fn, NULL, "efx_reader");
	if (IS_ERR(reader_task))
	{
		pr_err("efx_pcie: reader thread failed\n");
		kthread_stop(writer_task);
		goto err_out;
	}
	kthread_bind(reader_task, 2);

	wake_up_process(writer_task);
	wake_up_process(reader_task);

	return 0;

err_out:
	pci_iounmap(ptr, selected_bar);
	pci_release_region(ptr, 0);
	pci_disable_device(ptr);
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

	for (i = 0; i < 6; i++)
	{
		pci_release_region(ptr, i);
	}
	pci_disable_device(ptr);
}

module_init(my_init);
module_exit(my_exit);
