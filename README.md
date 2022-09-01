# Run NixOS VM on macOS machine

This repo provides an example of running a NixOS VM on your macOS machine using
new features in nixpkgs. It contains results of the work done for issue
[NixOS/nixpkgs#108984](https://github.com/NixOS/nixpkgs/issues/108984).

## TL;DR

Run this and you will get a working VM on your macOS machine, built with NixOS
configuration from this flake:

```bash
nix run github:YorikSar/nixos-vm-on-macos
```

To exit, run `sudo poweroff` or press Ctrl-a-x

## Setting up

Here I will list errors that you might encounter and how to address them.

### Experimental features

```
error: experimental Nix feature 'nix-command' is disabled; use '--extra-experimental-features nix-command' to override
```

Flakes are still experimental in Nix, so if you didn't enable them in your
config yet, you can do one of:

* run `export NIX_CONFIG="extra-experimental-features = nix-command flakes"` to
  temporary enable them in your current shell
* add line `extra-experimental-features = nix-command flakes` to your
  `~/.config/nix/nix.conf` file to enable them for your current user
* add line `extra-experimental-features = nix-command flakes` to your
  `/etc/nix/nix.conf` file to enable them globally on your machine

### Flake configuration settings

```
do you want to allow configuration setting 'extra-substituters' to be set to 'https://yoriksar-gh.cachix.org' (y/N)? y
do you want to permanently mark this value as trusted (y/N)? y
do you want to allow configuration setting 'extra-trusted-public-keys' to be set to 'yoriksar-gh.cachix.org-1:YrztCV1unI7qDV6IXmiXFig5PgptqTlUa4MiobULGT8=' (y/N)? y
do you want to permanently mark this value as trusted (y/N)? y
```

This flake provides configuration settings for using my cache hosted on
[Cachix](https://cachix.org). On the first run, Nix will ask you if you want to
enable each of these settings (I recommend answer "yes") and whether you want
to trust these settings in the future so that you don't have to reply to these
questions every time.

### Trust my substituter

```
warning: ignoring untrusted substituter 'https://yoriksar-gh.cachix.org'
```

If you see this line, it means that while your Nix trusts the configuration
values, it doesn't trust substituter. Add these lines to your
`/etc/nix/nix.conf`:

```
trusted-substituters = https://yoriksar-gh.cachix.org
trusted-public-keys = yoriksar-gh.cachix.org-1:YrztCV1unI7qDV6IXmiXFig5PgptqTlUa4MiobULGT8=
```

and then restart your Nix daemon with:

```
sudo launchctl kickstart -k system/org.nixos.nix-daemon
```

### Linux builder is required

```
error: a 'aarch64-linux' with features {} is required to build '...', but I am a 'x86_64-darwin' with features {benchmark, big-parallel, nixos-test}
```

If you don't configure my substituter (see previous 2 sections) or change
the configuration in any way, you will have to rebuild NixOS system
configuration. Unfortunately, it requires you to have a remote builder
configured for your machine with the appropriate Linux support. I will refer
you to [docs](https://nixos.org/manual/nix/stable/advanced-topics/distributed-builds.html)
that describe how to set it up. You would still have to provide your own Linux
machine though.

### Host and guest architecture must match

```
qemu-system-x86_64: Unknown Error
```

If you're seeing this on your Apple Silicon machine, you're probably running
Intel version of Nix that uses `x86_64-darwin` system by default. You can't run
`x86_64-linux` machine on Apple Silicon at this point (will be fixed in nixpkgs
eventually), and it would be very slow (Rosetta is of no help here), so you
should stick to running `aarch64-linux` VM on your machine. To do so, add
`--system aarch64-darwin` to your `nix run` and it will pick up the right
package.

### There's a different issue

Feel free to ask about it in 
[the original issue](https://github.com/NixOS/nixpkgs/issues/108984) or in this
repo's [issues](https://github.com/YorikSar/nixos-vm-on-macos/issues).
