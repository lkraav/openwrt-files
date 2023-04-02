#!/bin/sh

# Sanity checks.
[ -n "$1" ] || {
    echo "Error: OpenWRT profile parameter missing. Example: tplink_tl-wa860re-v1"
    exit 1
}

[ -n "$2" ] || {
    echo "Error: imagebuilder path parameter missing."
    exit 1
}

[ -d "$2" ] || {
    echo "Error: imagebuilder path doesn't exist."
    exit 1
}

# tplink_tl-wa860re-v1: 22.03.3
#
# We can't fit stock kernel +
# * wpad-mini + libustream-mbedtls + opkg
#   [mktplinkfw] *** error: images are too big by 257047 bytes
# * wpad-mini
#   [mktplinkfw] *** error: images are too big by 28459 bytes
#
# Work-around
# * drop kmod-ath9k, boot with wired network
# * ram-root
# * install more packages: kmod-ath9k, wpad-basic-wolfssl
# * start missing services
#
# LuCI SSL doesn't fit even in ram-root, install gets oom-killed.
#
# @see https://github.com/lkraav/openwrt-files/tree/trunk/tl-wa860re-v1
# @since 2023.03.12
# @todo fit kmod-ath9k, disable wpad service.
[ tplink_tl-wa860re-v1 = "$1" ] && {
    make -C "$2" image PROFILE="$1" PACKAGES=" \
        -dnsmasq \
        -firewall4 \
        -kmod-ath9k -kmod-nft-offload \
        -nftables \
        -odhcp6c \
        -odhcpd-ipv6only \
        -ppp \
        -ppp-mod-pppoe \
        -wpad-basic-wolfssl \
    " \
    FILES="${PWD}/$1" \
    #DISABLED_SERVICES="wpad"

    exit 0
}

# x86_64 generic: 22.03.3
#
# Protectli Vault FW6A
#
# @see https://forum.openwrt.org/t/tips-for-getting-cheap-used-x86-based-firewall-with-full-gbit-nat-a-pc-engines-apu-if-you-are-in-the-us/104490/392?u=lkraav
[ generic = "$1" ] && {
    make -C "$2" image PACKAGES=" \
        luci-app-fwknopd \
        luci-app-wireguard \
        luci-proto-wireguard \
        luci-ssl \
        -kmod-ppp \
        -odhcp6c \
        -odhcpd-ipv6only \
        -ppp \
        -ppp-mod-pppoe \
        wireguard-tools \
    " FILES="${PWD}/$1"

    exit 0
}

echo "Error: profile $1 not implemented."
exit 1
