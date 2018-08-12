#
# Copyright (C) 2010-2015 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=openvpn2318

PKG_VERSION:=2.3.18
PKG_RELEASE:=1

PKG_SOURCE_URL:=http://swupdate.openvpn.net/community/releases
PKG_SOURCE:=openvpn-$(PKG_VERSION).tar.xz
PKG_MD5SUM:=844ec9c64aae62051478784b8562f881

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/openvpn-$(PKG_VERSION)

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(BUILD_VARIANT)/openvpn-$(PKG_VERSION)
PKG_MAINTAINER:=Felix Fietkau <nbd@nbd.name>

PKG_INSTALL:=1
PKG_FIXUP:=autoreconf
PKG_BUILD_PARALLEL:=1
PKG_LICENSE:=GPL-2.0

include $(INCLUDE_DIR)/package.mk

define Package/openvpn2318/Default
  TITLE:=Open source VPN solution using $(2)
  SECTION:=MYREP
  CATEGORY:=MYREP
  SUBMENU:=VPN
  URL:=http://openvpn.net
  MENU:=1
  DEPENDS:=+kmod-tun +OPENVPN2318_$(1)_ENABLE_LZO:liblzo +OPENVPN2318_$(1)_ENABLE_IPROUTE2:ip $(3)
  VARIANT:=$(1)
  MAINTAINER:=Mirko Vogt <mirko@openwrt.org>
endef

Package/openvpn2318-polarssl=$(call Package/openvpn2318/Default,polarssl,PolarSSL,+libpolarssl)

define Package/openvpn2318/config/Default
	source "$(SOURCE)/Config-$(1).in"
endef

Package/openvpn2318-polarssl/config=$(call Package/openvpn2318/config/Default,polarssl)

ifeq ($(BUILD_VARIANT),polarssl)
CONFIG_OPENVPN2318_POLARSSL:=y
endif

CONFIGURE_VARS += \
	IFCONFIG=/sbin/ifconfig \
	ROUTE=/sbin/route \
	IPROUTE=/usr/sbin/ip \
	NETSTAT=/sbin/netstat

define Build/Configure
	$(call Build/Configure/Default, \
		$(if $(CONFIG_OPENVPN2318_$(BUILD_VARIANT)_ENABLE_SMALL),--enable-small) \
		--disable-selinux \
		--disable-systemd \
		--disable-plugins \
		--disable-debug \
		--disable-pkcs11 \
		$(if $(CONFIG_OPENVPN2318_$(BUILD_VARIANT)_ENABLE_LZO),--enable,--disable)-lzo \
		$(if $(CONFIG_OPENVPN2318_$(BUILD_VARIANT)_ENABLE_X509_ALT_USERNAME),enable,disable-x509-alt-username)-ssl \
		$(if $(CONFIG_OPENVPN2318_$(BUILD_VARIANT)_ENABLE_SERVER),--enable,--disable)-server \
		$(if $(CONFIG_OPENVPN2318_$(BUILD_VARIANT)_ENABLE_MANAGEMENT),--enable,--disable)-management \
		$(if $(CONFIG_OPENVPN2318_$(BUILD_VARIANT)_ENABLE_SOCKS),--enable,--disable)-socks \
		$(if $(CONFIG_OPENVPN2318_$(BUILD_VARIANT)_ENABLE_HTTP),--enable,--disable)-http-proxy \
		$(if $(CONFIG_OPENVPN2318_$(BUILD_VARIANT)_ENABLE_FRAGMENT),--enable,--disable)-fragment \
		$(if $(CONFIG_OPENVPN2318_$(BUILD_VARIANT)_ENABLE_MULTIHOME),--enable,--disable)-multihome \
		$(if $(CONFIG_OPENVPN2318_$(BUILD_VARIANT)_ENABLE_IPROUTE2),--enable,--disable)-iproute2 \
		$(if $(CONFIG_OPENVPN2318_$(BUILD_VARIANT)_ENABLE_DEF_AUTH),--enable,--disable)-def-auth \
		$(if $(CONFIG_OPENVPN2318_$(BUILD_VARIANT)_ENABLE_PF),--enable,--disable)-pf \
		$(if $(CONFIG_OPENVPN2318_NOSSL),--disable-ssl --disable-crypto,--enable-ssl --enable-crypto) \
		$(if $(CONFIG_OPENVPN2318_OPENSSL),--with-crypto-library=openssl) \
		$(if $(CONFIG_OPENVPN2318_POLARSSL),--with-crypto-library=polarssl) \
	)
endef

define Package/openvpn2318-$(BUILD_VARIANT)/conffiles
/etc/config/openvpn
endef

TARGET_CFLAGS += -ffunction-sections -fdata-sections
TARGET_LDFLAGS += -Wl,--gc-sections

define Package/openvpn2318-$(BUILD_VARIANT)/install
	$(INSTALL_DIR) \
		$(1)/usr/sbin \
		$(1)/etc/init.d \
		$(1)/etc/config \
		$(1)/etc/openvpn \
		$(1)/lib/upgrade/keep.d

	$(INSTALL_BIN) \
		$(PKG_INSTALL_DIR)/usr/sbin/openvpn \
		$(1)/usr/sbin/

	$(INSTALL_BIN) \
		files/openvpn.init \
		$(1)/etc/init.d/openvpn

	$(INSTALL_CONF) files/openvpn.config \
		$(1)/etc/config/openvpn

	$(INSTALL_DATA) \
		files/openvpn.upgrade \
		$(1)/lib/upgrade/keep.d/openvpn
endef

$(eval $(call BuildPackage,openvpn2318-polarssl))
