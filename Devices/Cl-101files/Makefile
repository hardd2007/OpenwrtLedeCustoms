# Править в samba /etc/config/samba
#Carelink CL-101
# 12 - 3G
# 14 - wps







include $(TOPDIR)/rules.mk

PKG_NAME:=Cl-101files
PKG_VERSION:=2.4.4

PKG_RELEASE:=24032019

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/Cl-101files
	SECTION:=MYREP
	CATEGORY:=MYREP
	DEPENDS:=+base-files
	SUBMENU:=Devices
	TITLE:=Cl-101files
	URL:=http://acs-house.ru/
endef


define Package/Cl-101files/description
	Files for Carelink CL-101
endef



define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
endef

define Build/Compile/Default
endef

define Package/Cl-101files/install-target

#	rm -f $(1)/lib/upgrade/ubnt.sh

endef


define Package/Cl-101files/install
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

define Package/Cl-101files/postinst
#!/bin/sh
	printenv >/tmp/env.txt
	rm -f $(TARGET_DIR)/bin/board_detect
	rm -f $(TARGET_DIR)/bin/config_generate
#	rm -f $(TARGET_DIR)/etc/config/samba
	rm -fR  $(TARGET_DIR)/etc/board.d
	rm -f $(TARGET_DIR)/etc/hotplug.d/ieee80211/10_fix_wifi_mac
	rm -f $(TARGET_DIR)/etc/hotplug.d/net/10-ar922x-led-fix
	rm -f $(TARGET_DIR)/etc/hotplug.d/block/10-mount
	
	rm -f $(TARGET_DIR)/etc/uci-defaults/03_network-switchX-migration
	rm -f $(TARGET_DIR)/etc/uci-defaults/03_network-vlan-migration
	rm -f $(TARGET_DIR)/etc/uci-defaults/04_led_migration
	rm -f $(TARGET_DIR)/etc/uci-defaults/09_fix-checksum
	rm -f $(TARGET_DIR)/etc/uci-defaults/09_fix-seama-header
	rm -f $(TARGET_DIR)/etc/uci-defaults/10_migrate-shadow
	rm -f $(TARGET_DIR)/etc/uci-defaults/12_network-generate-ula
	rm -f $(TARGET_DIR)/etc/uci-defaults/20_migrate-feeds
	rm -f $(TARGET_DIR)/etc/uci-defaults/11_migrate-sysctl
	rm -f $(TARGET_DIR)/etc/uci-defaults/30_luci-theme-openwrt
	rm -f $(TARGET_DIR)/etc/uci-defaults/50_luci-mod-admin-full
	rm -f $(TARGET_DIR)/etc/uci-defaults/luci-i18n-base-en
	rm -f $(TARGET_DIR)/etc/uci-defaults/luci-i18n-base-ru
	rm -f $(TARGET_DIR)/etc/uci-defaults/luci-i18n-firewall-en
	rm -f $(TARGET_DIR)/etc/uci-defaults/luci-i18n-firewall-ru
	rm -f $(TARGET_DIR)/etc/uci-defaults/00_uhttpd_ubus
	
	rm -f $(TARGET_DIR)/lib/functions/uci-defaults.sh
	rm -f $(TARGET_DIR)/etc/init.d/bootcount
	rm -f $(TARGET_DIR)/etc/init.d/enablemodem
	rm -f $(TARGET_DIR)/etc/init.d/gpio_switch
	rm -f $(TARGET_DIR)/lib/preinit/04_handle_checksumming
	
	rm -f $(TARGET_DIR)/lib/upgrade/allnet.sh
	rm -f $(TARGET_DIR)/lib/upgrade/dir825.sh
	rm -f $(TARGET_DIR)/lib/upgrade/merakinand.sh
	rm -f $(TARGET_DIR)/lib/upgrade/openmesh.sh
	rm -f $(TARGET_DIR)/lib/upgrade/ubnt.sh
	rm -f $(TARGET_DIR)/etc/config/uhttpd-opkg
	rm -f $(TARGET_DIR)/lib/preinit/04_handle_checksumming
	rm -f $(TARGET_DIR)/lib/preinit/07_set_preinit_iface_ramips
	
	
	
	echo "" >$(TARGET_DIR)/etc/dnsmasq.conf
	echo "" >$(TARGET_DIR)/etc/firewall.user
	echo "" >$(TARGET_DIR)/etc/sysupgrade.conf
#	rm -f $(TARGET_DIR)/www/index.html
	
	cp -fR $(TARGET_ROOTFS_DIR)/$(PKG_NAME)-$(PKG_VERSION)/ipkg-$(PKGARCH)/$(PKG_NAME)/* $(TARGET_DIR)/
	rm -fR $(TARGET_DIR)/CONTROL
#	mips-openwrt-linux-musl-strip --strip-debug $(TARGET_DIR)/lib/modules/4.9.86/*
	echo "----LUA----"
	/home/hardd/MNT/MYREP/Lua/lua.sh $(TARGET_DIR)
	echo "----LUA----"




endef



$(eval $(call BuildPackage,Cl-101files))
