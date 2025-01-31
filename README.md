PACKER_LOG=1 packer build -var "version=17.10.01a" cisco-cat-8kv.pkr.hcl

pkill -f '/usr/bin/qemu-system-x86_64.*-name cisco-cat8kv'

vagrant box add --box-version 17.10.01.a /var/lib/libvirt/images/cisco-c8000v.json