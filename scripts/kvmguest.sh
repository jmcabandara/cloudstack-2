virt-install \
        --connect qemu:///system \
        --virt-type kvm \
        --name test \
        --vcpu 1 \
        --ram 512 \
        --disk path=/var/lib/libvirt/images/test.qcow2,format=qcow2,size=8 \
        --network bridge=br0 \
        --os-variant rhel6 \
        --location http://172.16.1.1/dist/centos62/ \
        --extra-args 'ks=http://172.16.1.1/ks/guestvm.cfg ksdevice=eth0 console=ttyS0,115200n8'
