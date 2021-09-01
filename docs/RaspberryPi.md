# Raspberry Pi Deployment

This directory contains scripts and tools intended to ease deployment onto a Raspberry Pi. Follow these directions to get this working on any Raspberry Pi with onboard WiFi.

# Requirements

* [BalenaEtcher](https://www.balena.io/etcher/)
* `whiptail`
* Some videos, images, and/or audio files you wish to deploy
* A MicroSD card
* A Raspberry Pi with onboard WiFi
* A local WiFi network
* An SSH key

# Deployment

* Download a recent image of Raspberry Pi OS Lite [here](https://www.raspberrypi.org/software/operating-systems/#raspberry-pi-os-32-bit);
* Open Etcher and flash the MicroSD card with Raspbian;
* Unplug, then replug in the card to ensure a fresh mount;
* Locate the mount point in the filesystem:
  * `/boot` and `/rootfs` are both needed;
  * ensure they are under the same mountpoint (i.e. */media/microsd*);
  * note down this location for the installer;
* Ensure that all files you wish to deploy to the system are copied into `./data`;
* Run the deployment script and follow the prompts, input the required information:
  * For Linux: `deploy_rpi.sh`
  * For Windows: `deploy_rpi.ps1`
* Unplug, insert in the Raspberry Pi, power on;
* When booted, execute `ssh -i ~/.ssh/[Private Key] pi@[Hostname]`;
* Become `root` (`sudo su -` will suffice);
* From there you will likely wish to update the password for the `pi` user as well as update the keymap/locale if UK is not appropriate for you;
* Run the installer as usual (`cd /home/pi/haz/scripts/ && ./install.sh`);