#
# Copyright (C) 2007-2013 OpenWrt.org
# Copyright (C) 2010 Vertical Communications
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=myqmi
PKG_VERSION:=1.7
PKG_RELEASE:=16112015
PKG_MAINTAINER:=Oskari Rauta <oskari.rauta@gmail.com>
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)-$(PKG_RELEASE)

include $(INCLUDE_DIR)/package.mk

define Package/myqmi/Default
  VERSION:=$(PKG_VERSION)-$(PKG_RELEASE)
  URL:=http://openwrt.org/
  MAINTAINER:=Oskari Rauta <oskari.rauta@gmail.com>
endef

define Package/myqmi
$(call Package/myqmi/Default)
  SECTION:=MYREP
  CATEGORY:=MYREP
  SUBMENU:=Modem
  TITLE:=Protocol support for qmi
  DEPENDS:=+netifd +uqmi
endef

define Package/myqmi/description
 This package contains protocol support for QMI.
endef

define Package/luci-proto-myqmi
$(call Package/myqmi/Default)
  SECTION:=MYREP
  CATEGORY:=MYREP
  SUBMENU:=Modem
#  SUBMENU:=6. Protocols
  TITLE:=Support for uqmi
  DEPENDS:=+uqmi +myqmi
endef

define Package/luci-proto-myqmi/description
 This package contains LuCI support for uqmi
endef


define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Configure
endef

define Build/Compile/Default
endef

Build/Compile = $(Build/Compile/Default)

define Package/myqmi/install
	$(INSTALL_DIR) $(1)/lib
	$(INSTALL_DIR) $(1)/lib/netifd
	$(INSTALL_DIR) $(1)/lib/netifd/proto
#	$(INSTALL_DIR) $(1)/etc
#	$(INSTALL_DIR) $(1)/etc/gcom
#	$(INSTALL_DIR) $(1)/etc/gcom/ncm
#	$(INSTALL_DIR) $(1)/etc/gcom/ncm/signal
#	$(INSTALL_DIR) $(1)/etc/gcom/ncm/carrier
#	$(INSTALL_DIR) $(1)/etc/gcom/ncm/setmode
#	$(INSTALL_DIR) $(1)/etc/gcom/ncm/connect
#	$(INSTALL_DIR) $(1)/etc/gcom/ncm/initscripts
	$(INSTALL_BIN) ./files/lib/netifd/proto/qmi.sh $(1)/lib/netifd/proto/
#	$(INSTALL_DATA) ./files/etc/gcom/ncm/getcardinfo.gcom $(1)/etc/gcom/ncm/
endef

define Package/luci-proto-myqmi/install
	$(INSTALL_DIR) $(1)/usr
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DIR) $(1)/usr/lib/lua
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/network
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/admin_network
	$(INSTALL_DATA) ./files/usr/lib/lua/luci/model/network/proto_qmi.lua $(1)/usr/lib/lua/luci/model/network/
	$(INSTALL_DATA) ./files/usr/lib/lua/luci/model/cbi/admin_network/proto_qmi.lua $(1)/usr/lib/lua/luci/model/cbi/admin_network/
endef

$(eval $(call BuildPackage,myqmi))
$(eval $(call BuildPackage,luci-proto-myqmi))
