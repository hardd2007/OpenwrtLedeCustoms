# Править в samba /etc/config/samba


include $(TOPDIR)/rules.mk

PKG_NAME:=automount-SMB
PKG_VERSION:=0.8
PKG_RELEASE:=25032017

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/automount-SMB
	SECTION:=MYREP
	CATEGORY:=MYREP
	DEPENDS:=+base-files
	TITLE:=automount-SMB
	URL:=http://acs-house.ru/
endef


define Package/automount-SMB/description
	Automount any flash partition on samba
endef



define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Compile/Default
endef

define Package/automount-SMB/install-target

#	rm -f $(1)/lib/upgrade/ubnt.sh

endef


define Package/automount-SMB/install
		$(CP)  ./files/* $(1)/
endef

define Package/automount-SMB/postinst
#!/bin/sh

	rm -f $(TARGET_DIR)/etc/config/samba
	cp -fR $(TARGET_ROOTFS_DIR)/$(PKG_NAME)-$(PKG_VERSION)/ipkg-mipsel_24kec/$(PKG_NAME)/* $(TARGET_DIR)/
endef



$(eval $(call BuildPackage,automount-SMB))
