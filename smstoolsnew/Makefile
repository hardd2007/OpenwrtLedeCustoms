include $(TOPDIR)/rules.mk

PKG_NAME:=smstoolsnew
PKG_VERSION:=12f559497
PKG_RELEASE:=28012018

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/smstoolsnew
  SECTION:=MYREP
  CATEGORY:=MYREP
  SUBMENU:=Modem
  TITLE:=New program for SMS.
endef

define Package/smstoolsnew/description
 Small program for SMS.
endef


TARGET_CFLAGS += -ffunction-sections -fdata-sections
TARGET_LDFLAGS += -Wl,--gc-sections

define Package/smstoolsnew/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/sms_tool $(1)/usr/bin
endef

$(eval $(call BuildPackage,smstoolsnew))
