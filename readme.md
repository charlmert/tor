# Debian Tor (VPN Protection)
How to secure debian stretch 9.x via Torgaurd vpn
Get you a torguard account from R140 p/m @ https://torguard.net/

## To remove any rootkits, re-install kernel with optional upgrade

```bash
apt-get install --reinstall linux-image-$(uname -r)
update-initramfs -u -k $(uname -r)
update-grub
reboot now
```

or just run this and reboot manually, don't forget to reboot

```bash
curl https://raw.githubusercontent.com/charlmert/tor/master/wipe-rootkit/debian/nomorerootkit.sh | bash
```

or if you want the script to trigger a reboot instead of rebooting manually

```bash
curl https://raw.githubusercontent.com/charlmert/tor/master/wipe-rootkit/debian/nomorerootkit_reboot.sh | bash
```

This will make sure you have no rootkits running on your machine as any system calls that may have been swapped out
when the rootkit was installed will be reclaimed by the original kernel and wipe out the rootkit system call overrides.

This will make any rootkit activity visible and any investigations into hidden processes and or hidden connections, files etc. should
still be looked into.

This was tested using the Reptile (https://github.com/f0rb1dd3n/Reptile) rootkit and after kernel re-install the reptile 
hidden directories were visible which means that the vfs file hiding routine installed by the rootkit was no longer installed.

Once we're certain that there's no potential backdoor activity we can secure our connection with a vpn and harden our system with a firewall
that allows only connections in and outbound for the vpn traffic.

This will basically make absolutely sure that even if your on a trusted network your machine will be safe (that is my goal).

## Install torguard for debian

```bash
wget https://torguard.net/downloads/torguard-latest-amd64.deb
dpkg -i torguard-latest-amd64.deb
```

Click on "Activities" and type torguard into the search and run it
You can also type torguard in a console logged in as yourself

## Connect torguard to get the interface name

Connect torguard and check which interface it uses

In debian terminal as root, sudo su

```bash
ifconfig
#...
tun0: flags=4305<UP,POINTOPOINT,RUNNING,NOARP,MULTICAST>  mtu 48000
        inet xx.xx.x.x  netmask 255.255.255.255  destination 10.37.0.5
        inet6 xxxx::xxxx:xxxx:xxxx:xxxx  prefixlen 64  scopeid 0x20<link>
        unspec 00-00-00-00-00-00-00-00-00-00-00-00-00-00-00-00  txqueuelen 100  (UNSPEC)
        RX packets 188  bytes 55039 (53.7 KiB)
        RX errors 0  dropped 0  overruns 0  frame 0
        TX packets 333  bytes 30855 (30.1 KiB)
        TX errors 0  dropped 0 overruns 0  carrier 0  collisions 0
```

It's tun0 on my mac so set this in the config for the following step

## Setup firewall using ufw

Install ufw

```bash
apt-get install ufw
```

Run these ufw commands in a terminal as root

```bash
sudo ufw default deny incoming
sudo ufw default deny outgoing

sudo ufw allow in on lo from any to any
sudo ufw allow out on lo from any to any

sudo ufw allow out to any port 443 proto tcp
sudo ufw allow out to any port 80 proto tcp
sudo ufw allow out to any port 443 proto udp
sudo ufw allow out to any port 80 proto udp

sudo ufw allow out to any proto udp

sudo ufw allow out to 1.1.1.1 port 53
sudo ufw allow out to 8.8.8.8 port 53
sudo ufw allow out to 9.9.9.9 port 53
sudo ufw allow out on tun0 from any to any
sudo ufw enable
```

# Mac Tor (VPN Protection)
How to secure Apple Mac Mojave (10.14.6) via Torgaurd vpn
Get you a torguard account from R140 p/m @ https://torguard.net/


## Install torguard for mac

https://torguard.net/blog/how-to-setup-the-new-torguard-vpn-app-on-mac-os/

Download and install http://updates.torguard.biz/Software/MacOSX/TorGuard-latest.dmg

## Connect torguard to get the interface name

Connect torguard and check which interface it uses

In mac terminal as root, sudo su

```bash
ifconfig
#...
utun0: flags=8051<UP,POINTOPOINT,RUNNING,MULTICAST> mtu 2000
	inet6 fe80::d966:89:2760:1fec%utun0 prefixlen 64 scopeid 0xe 
	nd6 options=201<PERFORMNUD,DAD>
pktap0: flags=1<UP> mtu 0
utun1: flags=8051<UP,POINTOPOINT,RUNNING,MULTICAST> mtu 48000
	inet xx.xxx.x.x --> xx.xxx.x.x netmask 0xffffffff 
```

It's utun1 on my mac so set this in the config for the following step

## Setup firewall using pfctl

Paste these rules into /etc/pf.conf

```bash
#
# com.apple anchor point
#
scrub-anchor "com.apple/*"
nat-anchor "com.apple/*"
rdr-anchor "com.apple/*"as
dummynet-anchor "com.apple/*"
anchor "com.apple/*"
load anchor "com.apple" from "/etc/pf.anchors/com.apple"

#
# Allow connection via Torguard only
#
wifi=en1 #change this to en0 on MacBook Airs and other Macs without ethernet ports


# Set the device HERE, utun1
vpn=utun1

#vpn2=tap0

block all 
#block in drop from any to any 
#block out drop from any to any 

set skip on lo          # allow local traffic

# Torgaurd vpn auth needs this

pass out proto tcp to any port 80
pass out proto tcp to any port 443 

pass out proto udp to any port 80
pass out proto udp to any port 443 

pass out proto udp to any 

pass on p2p0            #allow AirDrop
pass on p2p1            #allow AirDrop
pass on p2p2            #allow AirDrop
pass quick proto tcp to any port 631    #allow AirPrint

# Allow Google DNS Servers
pass out proto tcp to 1.1.1.1 port 53
pass out proto udp to 1.1.1.1 port 53
pass in proto tcp from 1.1.1.1
pass in proto udp from 1.1.1.1

pass out proto tcp to 8.8.8.8 port 53
pass out proto udp to 8.8.8.8 port 53
pass in proto tcp from 8.8.8.8
pass in proto udp from 8.8.8.8

#pass on $wifi proto udp # allow only UDP packets over unprotected Wi-Fi
#pass on $vpn2           # allow everything else through the VPN (tap interface)
pass on $vpn            # allow everything else through the VPN (tun interface)

```

Then load the rules with (sudo su as admin in a terminal)

```bash
pfctl -f /etc/pf.conf
pfctl -v
```

To enable / disable pf firewall
```bash
# enable firewall
pfctl -e

# disable firewall
pfctl -d
```


# Setting up pass

1. Generate gpg key
2. Initialize password store
3. Initialize password store git
4. Generate password

```bash
gpg --gen-key

gpg --list-keys
# pub   rsa2048 2020-03-03 [SC] [expires: 2022-03-03]
#       43A1B6EB152823DEA92740B081222ACFA99262D0
# uid           [ultimate] Charl <charl@comxnetworks.com>
# sub   rsa2048 2020-03-03 [E] [expires: 2022-03-03]

pass init 43A1B6EB152823DEA92740B081222ACFA99262D0
pass git init
pass generate -c appleid.apple.com/charlmertfb@gmail.com
```
