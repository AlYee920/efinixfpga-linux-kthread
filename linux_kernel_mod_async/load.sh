make;sudo rmmod efx_pcie_simple_rdwr;sudo insmod efx_pcie_simple_rdwr.ko;dmesg |tail -10; watch -n 0.1 "cat /proc/interrupts|grep pcie"
