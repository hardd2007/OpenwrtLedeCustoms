include $(TOPDIR)/rules.mk

PKG_NAME:=uqmi-lite
PKG_RELEASE:=2016-12-19
PKG_VERSION:=8ceeab

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_RELEASE)-$(PKG_VERSION)

PKG_BUILD_PARALLEL:=0

PKG_FLAGS:=nonshared

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/uqmi-lite
  SECTION:=MYREP
  CATEGORY:=MYREP
  SUBMENU:=Modem
  DEPENDS:=+libubox +libblobmsg-json +kmod-usb-net +kmod-usb-net-qmi-wwan +wwan
  TITLE:=Control utility for mobile broadband modems
endef

define Package/uqmi/description
  uqmi is a command line tool for controlling mobile broadband modems using
  the QMI-protocol.
endef

define Package/luci-proto-qmi-new
$(call Package/uqmi-lite/Default)
  SECTION:=MYREP
  CATEGORY:=MYREP
  SUBMENU:=Luci
  TITLE:=Support for uqmi
  DEPENDS:=+uqmi-lite
endef

define Package/luci-proto-qmi-new/description
 This package contains LuCI support for uqmi
endef




TARGET_CFLAGS += \
	-I$(STAGING_DIR)/usr/include -ffunction-sections -fdata-sections

TARGET_LDFLAGS += -Wl,--gc-sections

CMAKE_OPTIONS += \
	-DDEBUG=1
	
define Package/uqmi-lite/install
	$(INSTALL_DIR) $(1)/sbin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/uqmi $(1)/sbin/
	$(INSTALL_DIR) $(1)/lib/netifd/proto/
	$(INSTALL_BIN) ./files/lib/netifd/proto/qmi.sh $(1)/lib/netifd/proto/
endef

define Package/luci-proto-qmi-new/install
	$(INSTALL_DIR) $(1)/usr
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DIR) $(1)/usr/lib/lua
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/network
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci/model/cbi/admin_network
	$(INSTALL_DATA) ./files/usr/lib/lua/luci/model/network/proto_qmi.lua $(1)/usr/lib/lua/luci/model/network/
	$(INSTALL_DATA) ./files/usr/lib/lua/luci/model/cbi/admin_network/proto_qmi.lua $(1)/usr/lib/lua/luci/model/cbi/admin_network/
endef

$(eval $(call BuildPackage,uqmi-lite))
$(eval $(call BuildPackage,luci-proto-qmi-new))
