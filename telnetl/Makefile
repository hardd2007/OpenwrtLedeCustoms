include $(TOPDIR)/rules.mk

PKG_NAME:=telnetl
PKG_VERSION:=1.0
PKG_RELEASE:=04052017

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/telnetl
  SECTION:=MYREP
  CATEGORY:=MYREP
  SUBMENU:=Tools
  DEPENDS:=+libc +base-files
  TITLE:=Telnet login
  URL:=http://acs-house.ru/
endef


define Package/telnetl/description
 Legacy telnet login support
endef



define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Compile/Default
endef

define Package/telnetl/install
	mkdir -p $(1)/etc
	$(CP) ./files/* $(1)/
	
endef

$(eval $(call BuildPackage,telnetl))
