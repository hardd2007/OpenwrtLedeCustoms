include $(TOPDIR)/rules.mk

PKG_NAME:=BMP180
PKG_VERSION:=3


PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/BMP180
  SECTION:=MYREP
  CATEGORY:=MYREP
  SUBMENU:=Tools
  TITLE:=BMP180 reader
endef

define Package/BMP180/description
 Programm for read BMP180 device.
endef


TARGET_CFLAGS += -ffunction-sections -fdata-sections
TARGET_LDFLAGS += -Wl,--gc-sections

define Package/BMP180/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/bmp180 $(1)/usr/bin
endef

$(eval $(call BuildPackage,BMP180))
