# Править в samba /etc/config/samba
#Править в opkg /etc/opkg/distfeed.conf
# Добавить в /include/target.mk CPU_CFLAGS_24kec = -mips32r2 -mtune=24kec
# Править /etc/hotplug.d/usb/20-usb_mode в usbmode
# echo 6000 > /sys/class/net/wwan0/cdc_ncm/tx_max
# echo 0 > /sys/class/net/wwan0/cdc_ncm/min_tx_pkt
# Убрать лишнее в uhttpd.config uhttpd.init
# Убрать лишнее в firewall.config user, 



include $(TOPDIR)/rules.mk

PKG_NAME:=A5-V11files
PKG_VERSION:=2.4.4
PKG_RELEASE:=19072019

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/A5-V11files
	SECTION:=MYREP
	CATEGORY:=MYREP
	DEPENDS:=+base-files
	SUBMENU:=Devices
	TITLE:=A5-V11files
	URL:=http://acs-house.ru/
endef


define Package/A5-V11files/description
	Files for A5 V11 router
endef



define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Compile/Default
endef

define Package/A5-V11files/install-target

	rm -f $(1)/lib/upgrade/ubnt.sh

endef


define Package/A5-V11files/install
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


endef

define Package/A5-V11files/postinst
#!/bin/sh

	rm -fR $(TARGET_DIR)/bin/board_detect
	rm -fR $(TARGET_DIR)/bin/config_generate
#	rm -fR $(TARGET_DIR)/etc/config/samba
	rm -fR  $(TARGET_DIR)/etc/board.d
	rm -f $(TARGET_DIR)/etc/uci-defaults/10_migrate-shadow
	rm -f $(TARGET_DIR)/etc/hotplug.d/block/10-mount
	rm -f $(TARGET_DIR)/etc/uci-defaults/11_migrate-sysctl
	rm -f $(TARGET_DIR)/etc/uci-defaults/09_fix-seama-header
	rm -f $(TARGET_DIR)/lib/functions/uci-defaults.sh
	rm -f $(TARGET_DIR)/etc/init.d/bootcount
	rm -f $(TARGET_DIR)/lib/preinit/04_handle_checksumming
	rm -f $(TARGET_DIR)/lib/upgrade/ubnt.sh
#	rm -f $(TARGET_DIR)/www/index.html
	rm -f $(TARGET_DIR)/etc/init.d/enablemodem
	rm -f $(TARGET_DIR)/etc/init.d/gpio_switch
	cp -fR $(TARGET_ROOTFS_DIR)/$(PKG_NAME)-$(PKG_VERSION)/ipkg-$(PKGARCH)/$(PKG_NAME)/* $(TARGET_DIR)/
	rm -fR $(TARGET_DIR)/CONTROL
#	mips-openwrt-linux-musl-strip --strip-debug $(TARGET_DIR)/lib/modules/4.9.86/*
	echo "----LUA----"
	/home/hardd/MNT/MYREP/Lua/lua.sh $(TARGET_DIR)
	echo "----LUA----"



endef



$(eval $(call BuildPackage,A5-V11files))
