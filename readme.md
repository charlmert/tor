## How to secure Apple Mac Mojave (10.14.6) via Torgaurd vpn

Get you a torguard account from R140 p/m @ https://torguard.net/

## Install torguard for mac

https://torguard.net/blog/how-to-setup-the-new-torguard-vpn-app-on-mac-os/

Download and install http://updates.torguard.biz/Software/MacOSX/TorGuard-latest.dmg

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
