# Cisco Catalyst 8kv Vagrant box

A Packer template for creating a Cisco Catalyst 8kv Vagrant box for the [libvirt](https://libvirt.org) provider.

### How to Create the Box

1. Install KVM. Information on how to set up KVM can be found online. This setup has been tested on Debian. Additionally, you need to install the following:
   - **git**
   - **packer** (tested on v1.11.2)
   - **vagrant** (tested on v2.2.14)

2. Verify the version of the `vagrant-libvirt` plugin. It must be **0.9.0**. To check the version, run:

   ```bash
   vagrant plugin list
   ```

   If `vagrant-libvirt` is not installed or has an older version, you can install or update it with:

   ```bash
   vagrant plugin install vagrant-libvirt --plugin-version 0.9.0
   ```

3. Install Packer plugins:

   ```bash
   packer plugins install github.com/hashicorp/qemu
   packer plugins install github.com/hashicorp/vagrant
   ```

4. Download and move the image to the appropriate directory and adjust its ownership and permissions:

   ```bash
   sudo chown libvirt-qemu:kvm /var/lib/libvirt/images/cisco-catalyst-8kv.qcow2
   sudo chmod 640 /var/lib/libvirt/images/cisco-catalyst-8kv.qcow2
   ```

5. Clone this repository and navigate to its directory:

   ```bash
   git clone https://github.com/celeroon/cisco-catalyst-8kv-vagrant-libvirt
   cd cisco-catalyst-8kv-vagrant-libvirt
   ```

6. Use Packer to build the Vagrant Box for the specified version of FortiSIEM:

   ```bash
   packer build -var "version=17.10.01a" -var "image_name=cisco-catalyst-8kv.qcow2" cisco-cat-8kv.pkr.hcl
   ```

   If you encounter issues, run with debug logging enabled:

   ```bash
   PACKER_LOG=1 packer build -var "version=17.10.01a" -var "image_name=cisco-catalyst-8kv.qcow2" cisco-cat-8kv.pkr.hcl
   ```

7. Move the created Vagrant Box to the `/var/lib/libvirt/images` directory:

   ```bash
   sudo mv ./builds/cisco-catalyst-8kv*.box /var/lib/libvirt/images
   ```

8. Copy the metadata file to the `/var/lib/libvirt/images` directory:

   ```bash
   sudo cp ./src/cisco-catalyst-8kv.json /var/lib/libvirt/images
   ```

9. Update the Vagrant Box metadata file with the correct path and version:

    ```bash
    vm_version="17.10.01a"
    sudo sed -i "s/\"version\": \"VER\"/\"version\": \"$vm_version\"/; s#\"url\": \"file:///var/lib/libvirt/images/cisco-catalyst-8kv-VER.box\"#\"url\": \"file:///var/lib/libvirt/images/cisco-catalyst-8kv-$vm_version.box\"#" /var/lib/libvirt/images/cisco-catalyst-8kv.json
    ```

10. Add the Cisco Catalyst 8kv Vagrant Box to the inventory:

    ```bash
    vagrant box add --box-version 17.10.01a /var/lib/libvirt/images/cisco-catalyst-8kv.json
    ```

### Acknowledgments

Special thanks to the following users for providing repositories with Packer examples for creating Vagrant Boxes:

- [https://github.com/mweisel](https://github.com/mweisel)
- [https://github.com/krjakbrjak](https://github.com/krjakbrjak)
