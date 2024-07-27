{pkgs, config, lib, ...}: {
  
  virtualisation = {
    libvirtd = {
      enable = true;
      qemu = {
        swtpm.enable = true;
        ovmf.enable = true;
        ovmf.packages = [ pkgs.OVMFFull.fd ];
      };
    };
  };

  users.users.link-lab-vm.extraGroups = [ "libvirtd" ];


  systemd.services."link-lab-vm" = {
    name = "link-lab-vm";
    after = [
      "network.target"
      "multi-user.target"
    ];

    script = ''
      mkdir -p /var/lib/link-lab-vm

      FILE=/var/lib/link-lab-vm.qcow
      if [ -f "$FILE" ]; then
          echo "$FILE exists."
      else 
          echo "$FILE does not exist ... creating it now"
          qemu-img create -f qcow2 /var/lib/link-lab-vm/disk.qcow 25G
      fi

      qemu-system-x86_64 \
        -name link-lab-vm \
        -enable-kvm \
        -cpu host,+kvm_pv_eoi,+kvm_pv_unhalt \
        -machine ‘type=pc’ \
        -daemonize \
        -nographic \
        -no-shutdown \
        -vga none \
        -accel kvm \
        -m 4096 \
        -smp 4 \
        -boot d \
        -device virtio-vga-gl -display sdl,gl=on \
        -device intel-hda -device hda-duplex \
        -device virtio-serial -chardev spicevmc,id=vdagent,debug=0,name=vdagent \
        -device virtserialport,chardev=vdagent,name=com.redhat.spice.0 \
        -hda $FILE \
        -cdrom /var/lib/link-lab-vm/ubuntu.iso \
        -netdev bridge,id=eth0,br=iqceth0 \
        -device e1000,netdev=eth0,mac=52:54:00:05:06:10,bus=pci.0,addr=0x2,id=net0 \
        -netdev bridge,id=esa0,br=iqcbr0 \
        -device virtio-net-pci,netdev=esa0,mq=on,vectors=6,bus=pci.0,addr=0x3,id=net1

    '';
  };
}
