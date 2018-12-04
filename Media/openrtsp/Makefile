include $(TOPDIR)/rules.mk

	PKG_NAME:=openrtsp
	PKG_RELEASE:=1
	PKG_VERSION:=2018.11.26
	PKG_BUILD_DIR := $(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)
	

include $(INCLUDE_DIR)/package.mk

define Package/openrtsp
	SECTION:=MYREP
	CATEGORY:=MYREP
	SUBMENU:=Media
	TITLE:=Openrtsp for ipcamera (26.11.2018)
	DEPENDS:=+libstdcpp
endef

define Package/openrtsp/description
	Openrtsp for ipcamera
endef

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	env >/tmp/env.txt
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

define Build/Configure
	( cd $(PKG_BUILD_DIR); \
		./genMakefiles linux; \
	)
endef

define Package/openrtsp/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/testProgs/openRTSP $(1)/usr/bin/
endef
$(eval $(call BuildPackage,openrtsp))
