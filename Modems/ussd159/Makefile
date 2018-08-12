include $(TOPDIR)/rules.mk

PKG_NAME:=ussd159
PKG_VERSION:=1.3
PKG_RELEASE:=30092015

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/ussd159
  SECTION:=MYREP
  CATEGORY:=MYREP
  SUBMENU:=Modem
  TITLE:=Small program for sending USSD requests.
endef

define Package/ussd159/description
 Small program for sending USSD requests.
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

define Build/Configure/Default
endef

define Package/ussd159/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ussd159 $(1)/usr/bin
endef

$(eval $(call BuildPackage,ussd159))
