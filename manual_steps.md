# Manual steps for installing the test infra

**Note that every instructions are avalaible for manual usage only, please see the automated way (with ansible) at [Usage](readme.md#usage).**

See all the steps below : 

- Step 1 : build the image with packer
    - from : raspbian default file ".img"
    - give : custom  ".img"

</br>

- Step 2 : create a virtual machine with vbox and in it virtualize previous custom ".img" with qemu 
    - from : custom .img
    - give : virtual raspberry

</br>

- Step 3 : Apply test on virtual raspberry

</br>

## Packer (Step 1)

On this first step we will, configure an custom image (based on "raspios-bullseye-arm64-lite") for my pi with:
- user config
- ssh config + ssh pub keys in it
- ip configuration + dns config

<!-- 
Reminder if using server on side :
```
scp -r  <location of myinfra/packer/> <user>@<serveronside>:~/.config/packer/plugin/samples/
``` 
-->

To build the image (it's important to stay at the plugin directory, this is where packer-arm plugin is):
```
cd ~/.config/packer/plugin
packer build samples/my-packer-raspberry-pi-os.json
```

**Qemu bonus :**

<blockquote></br>

- Now to make things simplier, we gonna convert our ".img" file to "qcow2" format to use it with qemu :

```
qemu-img convert -f raw -O qcow2 myrasp.img myrasp.qcow
```

- to check image info :
```
qemu-img info myrasp.qcow
```
</br></blockquote>




## Vagrant (Step 2)
</br>
<blockquote></br>

### Trying 1 :

First I try to directly using my "myrasp.qcow" image with qemu, but can't get it working, because launching qemu through ssh (headless) is a pain in the ass !!!

Here is my qemu command :

```
sudo qemu-system-arm \
-kernel ./qemu-rpi-kernel//kernel-qemu-4.4.34-jessie \
-append "root=/dev/sda2 panic=1 rootfstype=ext4 rw" \
-hda myrasp.qcow \
-cpu arm1176 -m 256 \
-M versatilepb \
-no-reboot \
-net nic -net user \
-net tap,ifname=vnet0,script=no,downscript=no
```

I gave up using directly qemu (even with graphical interface), I can't get any logs and the virtual machine won't start (Note that I using "-nographic " option in qemu change nothing : still not working). 

### Trying 2 :

From Here I tried to use vagrant to automatically run a virtual machine running with qemu and based on my custom rapsberry image, but failed to get any result.

Note that I used [vagrant-qemu](https://github.com/ppggff/vagrant-qemu) vagrant plugin, but the plugin is full of default values that make the work very hard by trying to override all of them. You can still found my vagrant file at [My Vagrant file](vagrant/Vagrantfile_qemu_provider) which ended by an error "Failed to get "write" lock" (using the default file, my rasp.img or my rasp.qcow) :

```
qemu-system-arm: -drive format=qcow2,file=/home/ottomatic/Document/vagrant/.vagrant/machines/default/qemu/luQSCVk_Zcw/linked-box.img: Failed to get "write" lock
Is another process using the image [/home/ottomatic/Document/vagrant/.vagrant/machines/default/qemu/luQSCVk_Zcw/linked-box.img]?
``` 
</br>
</blockquote></br>

**So I tried another solution : mount the virtual raspberry with qemu inside a virtual machine.**
Following the solution from [the repo h3r3/rpi-emu ](https://github.com/h3r3/rpi-emu).

</br>

I reuse the vagrantfile from the repo to build an virtualbox machine from which we will virtualize our raspberry. [See here why quemu must be used instead of classic virtualbox as provider for raspberry virtualization](https://stackoverflow.com/questions/34051322/is-there-a-vagrant-box-that-simulates-a-raspberry-pi)

- Go to the project path's folder and start the vagrant box : 
```
cd ~/ && \
vagrant up
```

- Connect to the vagrant box, to (manually) check that everything is ok :
```
vagrant ssh
```

- Finally destroy the box, when all the (manual) check are done :
```
vagrant destroy
```

## Testinfra (Step 3)

After the configuration steps, let's test that everything that we wanted is done on our raspberries with Testinfra.

py.test -v test_myinfra.py