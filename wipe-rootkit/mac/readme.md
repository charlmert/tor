# Removing any mac based rootkits

XNU kernel is part of the Darwin operating system for use in macOS and iOS operating systems. XNU is an acronym for X is Not Unix. XNU is a hybrid kernel combining the Mach kernel developed at Carnegie Mellon University with components from FreeBSD and a C++ API for writing drivers called IOKit.

# Building the latest available kernel

The quick way

```bash
sudo curl https://raw.githubusercontent.com/PureDarwin/xnubuild/master/xnubuild.sh | bash
```

Or you can clone the repo (I'll fork this and check out the script)

```bash
git clone https://github.com/PureDarwin/xnubuild.git
cd xnubuild
sudo bash xnubuild.sh
```

Backup existing kernel (mount /backup as an external or change /backup to /Volumes/External for e.g.)

```bash
cp -frv /System /backup
cp -frv /usr /backup
```

Activate the kernel (look for the xnu build number as seen at the first step when installing e.g. xnu-4903.242.1)

```bash
sudo cp -frv build/xnu-4903.242.1.dst/* /
```

# Manual install (Not complete, I prefer the xnubuild)
## You need xcode command line tools

```bash
xcode-select --install
```

## You need dtrace-tools

I've modified the source to work on macos (tested for catalina 10.15.3)
Follow the readme on how to install here
https://github.com/charlmert/dtrace

## get XNU Darwin source and build for the current systems release

```bash
git clone git@github.com:apple/darwin-xnu.git
```

To build a kernel for the same architecture as running OS, just type

```bash
cd darwin-xnu
make
make SDKROOT=macosx.internal
```
