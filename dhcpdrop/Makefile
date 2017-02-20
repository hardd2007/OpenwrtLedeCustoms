include $(TOPDIR)/rules.mk

PKG_NAME:=dhcpdrop
PKG_VERSION:=0.5
PKG_RELEASE:=1

#PKG_SOURCE:=dhcdrop-0.5.tar.bz2
#PKG_SOURCE_URL:=http://www.netpatch.ru/projects/dhcdrop

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk

define Package/dhcpdrop
	SECTION:=MYREP
	CATEGORY:=MYREP
	TITLE:=Drop DHCP servers
	#DEPENDS:=+libiconv-full +iconv
	URL:=http://www.netpatch.ru/projects/dhcdrop
endef

define Package/dhcpdrop/description
	Podavlenie DHCP serverov
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

define Build/Configure/Default
endef


define Package/dhcpdrop/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/src/dhcdrop $(1)/usr/bin/
	#$(INSTALL_BIN) $(PKG_BUILD_DIR)/scripts/sendsms $(1)/usr/bin/
	#$(INSTALL_DIR) $(1)/etc/init.d
	#$(INSTALL_DIR) $(1)/etc
	#$(INSTALL_DATA) ./files/smsd.conf $(1)/etc/
endef

$(eval $(call BuildPackage,dhcpdrop))
