include $(TOPDIR)/rules.mk

PKG_NAME:=MR3020Meteo
PKG_VERSION:=201908


PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/MR3020Meteo
	SECTION:=MYREP
	CATEGORY:=MYREP
	SUBMENU:=Tools
	TITLE:=MR3020 custom gpio modules
	URL:=http://acs-house.ru/
endef


define Package/MR3020Meteo/description
	MR3020 custom gpio 1-wire i2c modules
endef



define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Compile/Default
endef


define Package/MR3020Meteo/install
	mkdir -p $(1)/etc/modules.d
	$(CP)  ./files/* $(1)/


endef

$(eval $(call BuildPackage,MR3020Meteo))
