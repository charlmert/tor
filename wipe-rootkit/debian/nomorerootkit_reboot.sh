#!/bin/bash
rm -frv /var/cache/apt/archives/linux-image-$(uname -r)*.deb
apt-get install --reinstall linux-image-$(uname -r)
update-initramfs -u -k $(uname -r)
update-grub
reboot now
