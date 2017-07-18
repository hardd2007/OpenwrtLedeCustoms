include $(TOPDIR)/rules.mk

PKG_NAME:=LTE-modem-2017
PKG_VERSION:=0.2
PKG_RELEASE:=18072017

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/LTE-modem-2017
  SECTION:=MYREP
  CATEGORY:=MYREP
  DEPENDS:=+base-files
  TITLE:=LTE modem 2017
  URL:=http://acs-house.ru/
endef


define Package/LTE-modem-2017/description
 New generation software for config 3g/4g moodems
endef



define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Compile/Default
endef

define Package/LTE-modem-2017/install
	mkdir -p $(1)/etc/crontabs
	mkdir -p $(1)/usr/lib
	mkdir -p $(1)/usr/bin
	mkdir -p $(1)/www
	mkdir -p $(1)/etc
	$(CP) ./files/* $(1)/
	
endef

$(eval $(call BuildPackage,LTE-modem-2017))
