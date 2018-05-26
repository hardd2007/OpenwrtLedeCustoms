include $(TOPDIR)/rules.mk

PKG_NAME:=NetMon
PKG_VERSION:=0.1
PKG_RELEASE:=29032018

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/NetMon
  SECTION:=MYREP
  CATEGORY:=MYREP
#  SUBMENU:=Modem
#  DEPENDS:=+base-files
  TITLE:=New tools for modems
  URL:=http://acs-house.ru/
endef


define Package/NetMon/description
 Монитор наличия интернет соедиения
endef

define Build/Compile/Default
endef

define Package/NetMon/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi
	$(INSTALL_DATA) ./files/etc/config/netmon $(1)/etc/config/netmon
	$(INSTALL_DATA) ./files/usr/lib/lua/luci/controller/netmon.lua $(1)/usr/lib/lua/luci/controller/netmon.lua
	$(INSTALL_DATA) ./files/usr/lib/lua/luci/model/cbi/netmon.lua $(1)/usr/lib/lua/luci/model/cbi/netmon.lua
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./files/usr/bin/netmon.sh $(1)/usr/bin/netmon.sh
	$(INSTALL_DIR) $(1)/etc/init.d/
	$(INSTALL_BIN) ./files/etc/init.d/netmon $(1)/etc/init.d/netmon

	
endef

$(eval $(call BuildPackage,NetMon))
