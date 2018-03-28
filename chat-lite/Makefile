#
# Copyright (C) 2006-2012 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=chat-lite
PKG_RELEASE:=2.4.7

PKG_BUILD_DIR := $(KERNEL_BUILD_DIR)/$(PKG_NAME)
STAMP_PREPARED := $(STAMP_PREPARED)_$(call confvar,CONFIG_chat-lite_REDBOOT_PARTS)

PKG_LICENSE:=GPL-2.0+
PKG_LICENSE_FILES:=

include $(INCLUDE_DIR)/package.mk

define Package/chat-lite
  SECTION:=MYREP
  CATEGORY:=MYREP
#  DEPENDS:=+libubox
  TITLE:=Update utility for trx firmware images
endef

define Package/chat-lite/description
 This package contains an utility useful to upgrade from other firmware or 
 older OpenWrt releases.
endef

target=$(firstword $(subst -, ,$(BOARD)))

MAKE_FLAGS += TARGET="$(target)"
TARGET_CFLAGS := $(TARGET_CFLAGS) -Dtarget_$(target)=1 -Wall

ifdef CONFIG_chat-lite_REDBOOT_PARTS
  MAKE_FLAGS += FIS_SUPPORT=1
  TARGET_CFLAGS += -DFIS_SUPPORT=1
endif

define Package/chat-lite/install
	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/chat-lite $(1)/sbin/
endef

$(eval $(call BuildPackage,chat-lite))
