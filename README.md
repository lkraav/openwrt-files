# OpenWRT solutions

## tplink_tl-wa860re-v1

### Why?

As you might have experienced, [OpenWRT 21+ tiny official builds don't fit on 4/32MB devices](https://openwrt.org/supported_devices/openwrt_on_432_devices). Last easily fitting builds are 19.07 series.

But with help of simple **ramdisk [extroot](https://openwrt.org/docs/guide-user/additional-software/extroot_configuration)** setup, it's possible to keep at least thousands of older devices alive and well with at least 22.03.3, and probably for many releases to come :tada:

This solution is a simpler version of [extroot z-ram soluton](https://forum.openwrt.org/t/extroot-using-z-ram-drive-with-the-backup-restore-option-over-nfs-share/32725/), much thanks to @faruktezcan and other hard-working forum members, for figuring out the heavy lifting part of ramdisk extroot initialization.

### How it works

My use case is to continue running simple wireless APs on these TL-WA860RE v1 devices, but you can install a quite a lot of other types of functionality before you run out of RAM. `luci-ssl` (using WolfSSL, at least) unfortunately gets oom-killed during install.

* **Uses official imagebuilder**: no need to maintain our own buildsystem (for now), and package feeds
  - :point_up: ... All official packages are immediately installable :muscle:

* **Builds a minimal "wired-network"-only image to boot, and connect**: this still fits fine on probably most  4/32MB devices [see configuration](https://github.com/lkraav/openwrt-files/blob/trunk/make.sh#L38-L51)
  - :point_up: ... To fit into tiny 4MB flash, we exclude firewall, wireless, and some other usual suspects (but big bad WolfSSL fits!).
  - :point_up: ... We include simple ramdisk extroot scripts: [ram-root.sh](https://github.com/lkraav/openwrt-files/tree/trunk/tplink_tl-wa860re-v1/root), [rc.local](https://github.com/lkraav/openwrt-files/blob/trunk/tplink_tl-wa860re-v1/etc/rc.local)

* **On boot: TL-WA860RE v1 has about 13MB free RAM available**, plenty of room to work with
  - :point_up: ... `rc.local` detects connection via `ping`, downloads and installs whatever you need.
  - :point_up: ... In my case `kmod-ath9k`, `wpad-basic-wolfssl`. You can re-install your firewall, etc.

* **If your device is rarely powered off**, download-install-on-boot overhead is near-zero.

* **PROFIT** :moneybag:

Let's keep electronic waste down. Let us know here if you saved a few devices with this!

Feel free to post bug reports, enhancement ideas here, or on [GitHub Issues](https://github.com/lkraav/openwrt-files/issues).

## See also

* https://github.com/faruktezcan/openwrt-ram-root
