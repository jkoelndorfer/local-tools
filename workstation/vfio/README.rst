This document describes some lessons learned and gotchas when attempting to get
a KVM VFIO setup working in order to pass a graphics card through to a Windows
guest to achieve near-native performance when gaming.

0. See the Arch Wiki (https://wiki.archlinux.org/index.php/PCI_passthrough_via_OVMF) for a
   comprehensive guide.

1. It is possible to use the passthrough GPU inside the Windows virtual machine as well
   as natively in Linux. In my experience, this is not very difficult to do if you have a
   secondary GPU that is dedicated to your Linux desktop session.

   If you want to use the GPU in Linux, start an X server on that GPU and use Synergy
   to provide input to that server. That X server will need some configuration to
   accommodate. See xorg.nvidia.conf. Additionally, Arch includes some X11 configuration
   that needs to be removed (I wasn't able to figure out how to override it).

   Using the GPU in Windows is accomplished via the usual method with VFIO.

   **NOTE: Swapping the GPU between Linux and Windows will only work if you bind the GPU
   to the vfio-pci driver on boot.** I'm not sure why this is, but if you allow the NVIDIA
   driver to claim the GPU at boot time, later passing the GPU into a VM will cause a
   garbled display in anything but basic 640x480 VESA mode.

1. Command line for kernel boot:
   intel_iommu=on hugepagesz=1G default_hugepagesz=1G nohz_full=2-11 rcu_nocbs=2-11

   Set those in `/etc/default/grub`.

   The `intel_iommu` setting is, of course, mandatory. Hugepages provide a performance boost.
   `nohz_full` and `rcu_nocbs` exempt the CPUs from doing some kernel work, so they should
   provide more time to the guest VM.

2. Enable message-signaled interrupts (MSI) for the graphics card device. This has to be done
   in the registry inside the Windows virtual machine. This is apparently a
   more performant way to do hardware interrupts in a virtual environment.

3. If passing virtual machine audio to a PulseAudio server, run qemu as the user who owns
   the PulseAudio server.

4. The `qemu-win10` script configures the host system to route traffic destined
   for a specific subnet to the virtual machine. Since there is no NAT on the
   local system (which would be slower and hamper some port forwarding) the
   home router *also* needs to be configured with the correct route. NAT for the
   virtual machine's subnet must also be configured.
