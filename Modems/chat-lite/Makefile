include $(TOPDIR)/rules.mk

PKG_NAME:=chat-lite
PKG_VERSION:=2.4.7
PKG_RELEASE:=12

include $(INCLUDE_DIR)/package.mk

PKG_FLAGS:=nonshared

define Package/chat-lite
  SECTION:=MYREP
  CATEGORY:=MYREP
  SUBMENU:=Modem
#  DEPENDS:=+libubox
  TITLE:=Establish conversation with a modem
endef

define Package/chat/description
This package contains an utility to establish conversation with other PPP servers
(via a modem).
endef

TARGET_CFLAGS += -ffunction-sections -fdata-sections
TARGET_LDFLAGS += -Wl,--gc-sections

MAKE_FLAGS += COPTS="$(TARGET_CFLAGS)" \
		PRECOMPILED_FILTER=1 \
		STAGING_DIR="$(STAGING_DIR)"


define Package/chat-lite/install
	$(INSTALL_DIR) $(1)/usr/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/chat $(1)/usr/sbin/
endef

$(eval $(call BuildPackage,chat-lite))
