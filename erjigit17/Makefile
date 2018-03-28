include $(TOPDIR)/rules.mk

PKG_NAME:=erjigit17
PKG_VERSION:=2.4.1
PKG_RELEASE:=31082016

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/erjigit17
	SECTION:=MYREP
	CATEGORY:=MYREP
	SUBMENU:=Devices
	DEPENDS:=+base-files
	TITLE:=erjigit17
	URL:=http://acs-house.ru/
endef


define Package/erjigit17/description
	Files for WT3020 router
endef



define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Compile/Default
endef

define Package/erjigit17/install-target

endef


define Package/erjigit17/install
	echo "Vatriables" >>/tmp/vars.txt
	echo $(BUILD_DIR) >>/tmp/vars.txt
	echo $(PLATFORM_DIR) >>/tmp/vars.txt
	echo $(PROFILE) >>/tmp/vars.txt
	echo $(GENERIC_PLATFORM_DIR) >>/tmp/vars.txt
	echo $(PLATFORM_SUBDIR) >>/tmp/vars.txt
	echo $(1) >>/tmp/vars.txt
	mkdir -p $(1)/etc/crontabs
	mkdir -p $(1)/etc/rc.d
	mkdir -p $(1)/overlay
	mkdir -p $(1)/lib/firmware
	mkdir -p $(1)/tmp
	mkdir -p $(1)/usr/lib
	mkdir -p $(1)/usr/bin
	mkdir -p $(1)/www
	mkdir -p $(1)/root
	mkdir -p $(1)/etc
	$(CP)  ./files/* $(1)/
	MY_DIR=$(1)


endef

define Package/erjigit17/postinst
#!/bin/sh
	echo $(TARGET_DIR) >>/tmp/vars.txt
	rm -f $(TARGET_DIR)/bin/board_detect
	rm -f $(TARGET_DIR)/bin/config_generate
#	rm -f $(TARGET_DIR)/etc/config/samba
	rm -fR $(TARGET_DIR)/etc/board.d
	rm -f $(TARGET_DIR)/etc/uci-defaults/10_migrate-shadow
	rm -f $(TARGET_DIR)/etc/hotplug.d/block/10-mount
	rm -f $(TARGET_DIR)/etc/uci-defaults/11_migrate-sysctl
	rm -f $(TARGET_DIR)/etc/uci-defaults/09_fix-seama-header
	rm -f $(TARGET_DIR)/lib/functions/uci-defaults.sh
	rm -f $(TARGET_DIR)/etc/init.d/bootcount
	rm -f $(TARGET_DIR)/lib/preinit/04_handle_checksumming
	rm -f $(TARGET_DIR)/lib/upgrade/ubnt.sh
#	rm -f $(BUILD_DIR)/root-ramips/www/index.html

#cp -fR $(1)/* $(BUILD_DIR)/root-ramips/
	echo "Vatriables2" >>/tmp/vars.txt
	echo $(BUILD_DIR) >>/tmp/vars.txt
	echo $(PLATFORM_DIR) >>/tmp/vars.txt
	echo $(PROFILE) >>/tmp/vars.txt
	echo $(GENERIC_PLATFORM_DIR) >>/tmp/vars.txt
	echo $(PLATFORM_SUBDIR) >>/tmp/vars.txt
	echo $(1) >>/tmp/vars.txt
	echo $(BUILD_DIR_BASE) >>/tmp/vars.txt
	echo $(TARGET_DIR_NAME) >>/tmp/vars.txt
	echo $(TARGET_ROOTFS_DIR) >>/tmp/vars.txt
	echo $(MY_DIR) >>/tmp/vars.txt
	echo $(PKG_DIR_NAME) >>/tmp/vars.txt
	echo $(USE_SOURCE_DIR) >>/tmp/vars.txt
	echo "End2" >>/tmp/vars.txt
	cp -fR $(TARGET_ROOTFS_DIR)/$(PKG_NAME)-$(PKG_VERSION)/ipkg-mipsel_24kec/$(PKG_NAME)/* $(TARGET_DIR)/
	rm -fR $(TARGET_DIR)/CONTROL


endef



$(eval $(call BuildPackage,erjigit17))
