# Править в samba /etc/config/samba
#Править в opkg /etc/opkg/distfeed.conf
# Добавить в /include/target.mk CPU_CFLAGS_24kec = -mips32r2 -mtune=24kec
# Править /etc/hotplug.d/usb/20-usb_mode в usbmode
# echo 6000 > /sys/class/net/wwan0/cdc_ncm/tx_max
# echo 0 > /sys/class/net/wwan0/cdc_ncm/min_tx_pkt

include $(TOPDIR)/rules.mk

PKG_NAME:=WR1043NDv1files
PKG_VERSION:=2.4

PKG_RELEASE:=14042017

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/WR1043NDv1files
	SECTION:=MYREP
	CATEGORY:=MYREP
	SUBMENU:=Devices
	DEPENDS:=+base-files
	TITLE:=WR1043NDv1files
	URL:=http://acs-house.ru/
endef


define Package/WR1043NDv1files/description
	Files for WT3020 router
endef



define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Compile/Default
endef

define Package/WR1043NDv1files/install-target

#	rm -f $(1)/lib/upgrade/ubnt.sh

endef


define Package/WR1043NDv1files/install
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

define Package/WR1043NDv1files/postinst
#!/bin/sh

	rm -f $(TARGET_DIR)/bin/board_detect
	rm -f $(TARGET_DIR)/bin/config_generate
#	rm -f $(TARGET_DIR)/etc/config/samba
	rm -fR  $(TARGET_DIR)/etc/board.d
	rm -f $(TARGET_DIR)/etc/uci-defaults/03_network-switchX-migration
	rm -f $(TARGET_DIR)/etc/uci-defaults/03_network-vlan-migration
	rm -f $(TARGET_DIR)/etc/uci-defaults/04_led_migration
	rm -f $(TARGET_DIR)/etc/uci-defaults/09_fix-checksum
	rm -f $(TARGET_DIR)/etc/uci-defaults/09_fix-seama-header
	rm -f $(TARGET_DIR)/etc/hotplug.d/net/10-ar922x-led-fix
	
	rm -f $(TARGET_DIR)/etc/hotplug.d/block/10-mount
	rm -f $(TARGET_DIR)/etc/uci-defaults/11_migrate-sysctl
	rm -f $(TARGET_DIR)/lib/functions/uci-defaults.sh
	rm -f $(TARGET_DIR)/etc/init.d/bootcount
	rm -f $(TARGET_DIR)/etc/init.d/enablemodem
	rm -f $(TARGET_DIR)/etc/init.d/gpio_switch
	rm -f $(TARGET_DIR)/lib/preinit/04_handle_checksumming
	rm -f $(TARGET_DIR)/lib/upgrade/allnet.sh
	rm -f $(TARGET_DIR)/lib/upgrade/dir825.sh
	rm -f $(TARGET_DIR)/lib/upgrade/merakinand.sh
	rm -f $(TARGET_DIR)/lib/upgrade/openmesh.sh
	
#	rm -f $(TARGET_DIR)/www/index.html
	rm -f $(TARGET_DIR)/etc/uci-defaults/20_migrate_feeds
	cp -fR $(TARGET_ROOTFS_DIR)/$(PKG_NAME)-$(PKG_VERSION)/ipkg-$(PKGARCH)/$(PKG_NAME)/* $(TARGET_DIR)/
	rm -fR $(TARGET_DIR)/CONTROL

	



endef



$(eval $(call BuildPackage,WR1043NDv1files))
