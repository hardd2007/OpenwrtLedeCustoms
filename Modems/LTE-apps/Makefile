include $(TOPDIR)/rules.mk

PKG_NAME:=LTE-apps
PKG_VERSION:=0.4
PKG_RELEASE:=29032018

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/LTE-apps
  SECTION:=MYREP
  CATEGORY:=MYREP
  SUBMENU:=Modem
#  DEPENDS:=+base-files
  TITLE:=New tools for modems
  URL:=http://acs-house.ru/
endef


define Package/LTE-apps/description
 New generation software for config 3g/4g moodems
endef



define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Compile/Default
endef

define Package/LTE-apps/install
	$(INSTALL_DIR) $(1)/etc/config
	$(INSTALL_DIR) $(1)/etc/hotplug.d/usb
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/controller
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi
	$(INSTALL_DIR) $(1)/www/res
	$(INSTALL_DIR) $(1)/www/cgi-bin
	$(INSTALL_DATA) ./files/etc/config/modem $(1)/etc/config/modem
	$(INSTALL_BIN) ./files/etc/hotplug.d/usb/99-4gmodem $(1)/etc/hotplug.d/usb/99-4gmodem
	$(INSTALL_DATA) ./files/usr/lib/lua/luci/controller/modem.lua $(1)/usr/lib/lua/luci/controller/modem.lua
	$(INSTALL_DATA) ./files/usr/lib/lua/luci/model/cbi/modem.lua $(1)/usr/lib/lua/luci/model/cbi/modem.lua
	$(CP) ./files/www/* $(1)/www/
	$(CP) ./files/www/cgi-bin/* $(1)/www/cgi-bin/
	chmod 0755 $(1)/www/cgi-bin/*
	
endef

$(eval $(call BuildPackage,LTE-apps))
