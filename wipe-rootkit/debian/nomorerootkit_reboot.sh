#!/bin/bash
apt-get install --reinstall linux-image-$(uname -r)
update-initramfs -u -k $(uname -r)
update-grub
reboot now
