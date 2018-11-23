#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=myncm
PKG_VERSION:=0.95
PKG_RELEASE:=28012017

PKG_MAINTAINER:=HardD

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME).$(PKG_VERSION)


include $(INCLUDE_DIR)/package.mk

define Package/myncm/Default
  VERSION:=$(PKG_VERSION)-$(PKG_RELEASE)
  URL:=http://openwrt.org/
  MAINTAINER:=Oskari Rauta <oskari.rauta@gmail.com>
endef

define Package/myncm
$(call Package/myncm/Default)
  SECTION:=MYREP
  CATEGORY:=MYREP
  SUBMENU:=Modem
  TITLE+=NCM 3G/4G Support
  DEPENDS:=+comgt +wwan +netifd
endef

define Package/luci-proto-myncm
$(call Package/myncm/Default)
  SECTION:=MYREP
  CATEGORY:=MYREP
  SUBMENU:=Modem
  TITLE:=Support for NCM Luci
  DEPENDS:=+myncm
endef

define Package/myncm/description
 This package contains protocol support for NCM.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Compile
endef

define Build/Compile/Default
endef


define Package/myncm/install
	$(INSTALL_DIR) $(1)/etc/gcom
	$(INSTALL_DATA) ./files/ncm.json $(1)/etc/gcom/ncm.json
	$(INSTALL_DATA) ./files/runcommand.gcom $(1)/etc/gcom/runcommand.gcom
	$(INSTALL_DATA) ./files/modem_dev.gcom $(1)/etc/gcom/modem_dev.gcom
	$(INSTALL_DIR) $(1)/lib/netifd/proto
	$(INSTALL_BIN) ./files/ncm.sh $(1)/lib/netifd/proto/ncm.sh
endef

define Package/luci-proto-myncm/install
	$(INSTALL_DIR) $(1)/usr
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DIR) $(1)/usr/lib/lua
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/network
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/admin_network
	$(INSTALL_DATA) ./files/usr/lib/lua/luci/model/network/proto_ncm.lua $(1)/usr/lib/lua/luci/model/network/
	$(INSTALL_DATA) ./files/usr/lib/lua/luci/model/cbi/admin_network/proto_ncm.lua $(1)/usr/lib/lua/luci/model/cbi/admin_network/
endef



$(eval $(call BuildPackage,myncm))
$(eval $(call BuildPackage,luci-proto-myncm))