include $(TOPDIR)/rules.mk

PKG_NAME:=4Gmodem
PKG_VERSION:=2.3
PKG_RELEASE:=16112015

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/4Gmodem
  SECTION:=MYREP
  CATEGORY:=MYREP
  SUBMENU:=Modem
  DEPENDS:=+libc +base-files
  TITLE:=4G-modem
  URL:=http://acs-house.ru/
endef


define Package/4Gmodem/description
 Files for 4g/3g modems
endef



define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Compile/Default
endef

define Package/4Gmodem/install
	
	mkdir -p $(1)/etc/crontabs
	mkdir -p $(1)/etc/rc.d
	mkdir -p $(1)/overlay
	mkdir -p $(1)/lib/firmware
	mkdir -p $(1)/tmp
	mkdir -p $(1)/usr/lib
	mkdir -p $(1)/usr/bin
	mkdir -p $(1)/www
	mkdir -p $(1)/root
	mkdir -p $(1)/etc
	$(CP) ./files/* $(1)/
	
endef

$(eval $(call BuildPackage,4Gmodem))
