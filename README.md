# PCIe MSI Interrupt Test on Ti375 Development Kit 
This project demonstrates PCIe MSI (Message Signaled Interrupts) functionality using an Efinix Ti375N1156 FPGA development kit connected to a Linux-based test PC.

## Requirement
- Efinix Ti375N1156 Development Kit
- General-purposed Linux machine


## Hardware Setup

1. Program Ti375N1156 Development Kit (Ti375 Devkit) using `SPI Active using JTAG Bridge` with `hardware/bitstream/ti375n1156_oob.hex`.
2. Plug the Ti375 Devkit into the the Linux Machine
3. Power on the Linux Machine.
4. Connect to the `debug_profile.json` using Efinity Debugger.

## Software Setup

1. Navigate to linux_kernel_mod_async/ directory
2. Use make to compile the linux kernel module
Run sudo insmod efx_pcie_simple_rdwr.ko to install the kernel module
3. Run sudo dmesg, you should expect these messages:
```
   [ 1796.629410] Efinix PCIe kernel init
   [ 1796.629518] efx_pcie - VENDOR_ID: 0x1f7a
   [ 1796.629521] efx_pcie - DEVICE_ID: 0x100
   [ 1796.629522] efx_pcie - BAR Discovery for 1f7a:0100
   [ 1796.629525] efx_pcie - PCI_COMMAND: 0x0002 (MMIO:ON IO:OFF MASTER:OFF)
   [ 1796.629526] efx_pcie - BAR0: START=0x74000000 LEN=0x4000000 MEM
   [ 1796.629527] efx_pcie - BAR1: DISABLED
   [ 1796.629527] efx_pcie - BAR2: DISABLED
   [ 1796.629527] efx_pcie - BAR3: DISABLED
   [ 1796.629528] efx_pcie - BAR4: DISABLED
   [ 1796.629528] efx_pcie - BAR5: DISABLED
   [ 1796.629539] efx_pcie: BAR0 mapped at 00000000939b468a
   [ 1796.629609] efx_pcie: allocated 2 MSI interrupt
   [ 1796.629621] efx_pcie: msi_one_read enabled on IRQ 149
   [ 1796.629640] efx_pcie: msi_burst_write enabled on IRQ 148
```
4. Obtain the MSI address and MSI data via either:
   1. Running `sudo lspci -d 1f7a:0100 -vv | grep MSI: -A 2`
   ```
   Capabilities: [90] MSI: Enable+ Count=2/32 Maskable+ 64bit+
               Address: 00000000fee00618  Data: 0000
               Masking: fffffffc  Pending: 00000000
   ```

   2. Using the apbvio in the Efinity Debugger:
      1. Set `apb_write` to `0`
      2. Set `apb_paddr` to `0x94`
      3. Toggle `apb_start`
      4. Note down the **MSI address**
      5. Repeat Step 2 with address `0x9c` for **MSI data**
   3. Insert the **MSI address** and **MSI data** in `vio1` `AXI_ADDR` and `AXI_DATA` port in Debugger
   4. Toggle the `AXI_START` to trigger `msi_burst_write` interrupt followed by `msi_one_read` interrupt.
   5. Set `MSI_TEST_INIT` to `1` to start the automated test.

## Error Checking
The RTL expect incremental `TARGET_AXI_WDATA` from the Linux Machine. Any mismatch will cause the error counter to increment by 2. 