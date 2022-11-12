<h1 align="center">:dizzy:<br />
    <a href="https://github.com/Draed"></a>My lab infrastructure by <a href="https://github.com/Draed">@Draed</a>
</h1>

## Description

In order to do my rush, Proof of concept and test, I need a versatile lab infrastructure.
For most of my work I used virtualization through container (most of the time docker or podman), but sometime I need a simple linux server (for ie : VRRP, dhcp, ssh, jenkins ...), and this "classic" (bare metal) server also need to be versatile, to do so I use dd over ssh session to push new rapsberries images and ansible to get the desired inital state.

**Within the "ansible" folder in this repo is the playbook which create that "lab" infrastructure.**

My test lab is build on raspberry pi units, using these tools : 
- Packer to build my base image for my Pi 
- Vagrant to test the packer image, before sending it to the pi (via SSH)
- Ansible to configure the core element on it (log, snmp, ntp)
- Testinfra to check that ansible playbook result in the desired state
- Docker and podman as main virtualization element
- Terraform to start a bunch of labs

<!-- img here -->


##  Prerequisites

- Any server out of the lab infrastructure which act like a "Master" and will build images and configure "Workers" (members of the lab infrastructure).

## Usage

- First, configure the inventory files within the ansible playbooks folder : 'lab_infra_playbook' (playbook for the "workers" - element of the lab) and 'server_side_playbook' (playbook for the "master").

- Then from a server on side ("Master like"), launch the 'server_side_playbook' (within the Ansible folder) :  
```
cd ansible/server_side_playbook && \
ansible-playbook -i inventory.yml  server_side_playbook.yml --ask-become-pass 
```
(Reminder : Use --check to only test)

This will configure the master to create the image for the rasps ("workers").

- Then run the "lab_infra_playbook" :
```
cd ansible/lab_infra_playbook && \
ansible-playbook -i inventory.yml  lab_infra_playbook.yml --ask-become-pass 
```

This will push the customs rasps images and configure them (ssh, logs, snmp, etc ...)

---- 

</br>

==Now We can launch any labs with a terraform tf file on docker/podman running on our raspberries==


## Sources : 

### Ansible 
- Use lsb_release in ansible : https://www.shellhacks.com/ansible-lsb_release-variable/
- Ansible get apt key and add repo : https://docs.ansible.com/ansible/latest/collections/ansible/builtin/apt_key_module.html
- check if package is installed : https://docs.ansible.com/ansible/latest/collections/ansible/builtin/package_facts_module.html


### Pi
- pi change image over network : https://weberblog.net/reinstall-your-raspberry-over-the-network
- How to build image for raspberry pi with packer tutorial : https://medium.com/@source4learn/how-to-build-a-custom-raspberry-pi-os-image-using-packer-da83be261687
- run raspberry os on virtualbox : https://raspberrytips.com/run-raspberry-in-virtual-machine/
- how to build custom ova for raspberry : https://williamlam.com/2020/11/how-to-build-a-customizable-raspberry-pi-os-virtual-appliance-ova.html
- using QUEMU to virtualize raspberry : https://blog.agchapman.com/using-qemu-to-emulate-a-raspberry-pi/
- How to emulate raspberry pi , stackexchange question : https://raspberrypi.stackexchange.com/questions/117234/how-to-emulate-raspberry-pi-in-qemu

### Packer 
- how to install packer : https://developer.hashicorp.com/packer/downloads?host=www.packer.io
- tutorial from iso to vagrant box : http://blog.ruilopes.com/from-iso-to-vagrant-box.html
- packer plugin for raspberry img : https://github.com/solo-io/packer-plugin-arm-image

### Vagrant : 
- quemu vagrant pugin : https://github.com/billyan2018/vagrant-qemu
- an other quemu vagrant plugin : https://github.com/ppggff/vagrant-qemu#example
- vagrant file and script to emulate rapsberry pi : https://github.com/h3r3/rpi-emu
- vagrant config for virtualbox provider : https://developer.hashicorp.com/vagrant/docs/providers/virtualbox/configuration

### Qemu : 
- solution to error running qemu through ssh (headless mode) : https://github.com/sickcodes/Docker-OSX/issues/2
- and a reminder of what xhost do : https://unix.stackexchange.com/questions/177557/what-does-this-xhost-command-do

### Testinfra : 
- testinfra basic tutorial : https://testinfra.readthedocs.io/en/latest/index.html
- testinfra with ansible tutorial : https://www.devopsroles.com/ansible-uses-testinfra-test-infrastructure/

### Other 
- apt-key depreciation : https://itsfoss.com/apt-key-deprecated/
- raspberries official images : https://www.raspberrypi.com/software/operating-systems/
- debian configure language : https://www.shellhacks.com/linux-define-locale-language-settings/
- locate binary file : https://www.systranbox.com/how-to-find-binary-files-in-linux/
- What is EDK2 : https://wiki.osdev.org/EDK2
- What is OVMF : https://github.com/tianocore/tianocore.github.io/wiki/OVMF