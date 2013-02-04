cloud-setup-agent -a -m 172.16.1.2 -z default -p default -c default -g $(uuidgen) --pubNic=cloud-public --prvNic=cloud-mgmt --guestNic=cloud-guest
virsh net-destroy default
virsh net-undefine default
