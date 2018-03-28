include $(TOPDIR)/rules.mk

PKG_NAME:=mysmstools
PKG_VERSION:=1.7
PKG_RELEASE:=30092015

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/mysmstools
  SECTION:=MYREP
  CATEGORY:=MYREP
  SUBMENU:=Modem
  TITLE:=Small program for SMS.
endef

define Package/mysmstools/description
 Small program for SMS.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

define Build/Configure/Default
endef

define Package/mysmstools/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/sms_tool $(1)/usr/bin
endef

$(eval $(call BuildPackage,mysmstools))
