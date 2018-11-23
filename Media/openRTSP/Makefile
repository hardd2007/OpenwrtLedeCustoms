include $(TOPDIR)/rules.mk
	PKG_NAME:=openRTSP
	PKG_RELEASE:=1
	PKG_VERSION:=2018.10.17
	PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)
	

	include $(INCLUDE_DIR)/package.mk

define Package/openRTSP
	SECTION:=MYREP
	CATEGORY:=MYREP
	SUBMENU:=Media
	TITLE:=Openrtsp for ipcamera
	DEPENDS:=+libstdcpp
endef

define Package/openRTSP/description
	Openrtsp for ipcamera
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	env >/tmp/env.txt
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

define Package/openRTSP/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/testProgs/openRTSP $(1)/usr/bin/
endef
$(eval $(call BuildPackage,openRTSP))
