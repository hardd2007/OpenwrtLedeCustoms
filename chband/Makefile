include $(TOPDIR)/rules.mk

PKG_NAME:=chband
PKG_VERSION=2015-02-28
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/chband
	SECTION:=MYREP
	CATEGORY:=MYREP
	TITLE:=Change bands for 4G Modem
	PKGARCH:=all
	DEPENDS:=+comgt +luci-proto-3g
endef

define Package/chband/description
	Changing bands for 4G/3G Modem
endef

define Build/Prepare
endef

define Build/Configure
endef

define Build/Compile
endef

define Package/chband/install
	$(CP) ./files/* $(1)/
	$(INSTALL_DIR) $(1)/lib/netifd/proto
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/admin_network
	$(INSTALL_BIN) ./files/lib/netifd/proto/3g.sh $(1)/lib/netifd/proto/3g.sh
	$(INSTALL_DATA) ./files/usr/lib/lua/luci/model/cbi/admin_network/proto_3g.lua $(1)/usr/lib/lua/luci/model/cbi/admin_network/proto_3g.lua
endef

$(eval $(call BuildPackage,chband))

