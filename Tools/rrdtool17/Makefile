#
# Copyright (C) 2007-2012 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=rrdtool
PKG_VERSION:=1.7.0
PKG_RELEASE:=3

#PKG_SOURCE_URL:=http://oss.oetiker.ch/rrdtool/pub/
#PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
#PKG_MD5SUM:=19b24f7184a8dbf7b48c1bbb565ad9fb

#PKG_BUILD_DEPENDS:=python

PKG_CONFIG_DEPENDS:= \
	CONFIG_PACKAGE_rrdcgi \

PKG_FIXUP:=autoreconf

PKG_INSTALL:=1

include $(INCLUDE_DIR)/package.mk
#include $(TOPDIR)/feeds/packages/lang/python/python-package.mk

define Package/rrdtool17/Default
  SECTION:=MYREP
  CATEGORY:=MYREP
  TITLE:=Round Robin Database (RRD)
  SUBMENU:=Tools
  URL:=http://oss.oetiker.ch/rrdtool/
endef

define Package/librrd17
$(call Package/rrdtool17/Default)
  TITLE+= management library (v1.7.0)
  DEPENDS:= +libart +libfreetype +libpng +zlib +libpthread +glib2 +pango +cairo
endef

define Package/rrdcgi17
$(call Package/rrdtool17/Default)
  TITLE+= CGI graphing tool (v1.7.0)
  DEPENDS+= +librrd17
endef

define Package/rrdtool17
$(call Package/rrdtool17/Default)
  TITLE+= management tools (v1.7.0)
  DEPENDS+= +librrd17
endef

CONFIGURE_ARGS += \
	--enable-shared=yes \
	--enable-static=yes \
	--disable-rpath \
	--with-gnu-ld \
	--disable-mmap \
	--disable-perl \
	--disable-tcl \
	--disable-ruby \
	--disable-python \
	--disable-examples \
	--disable-lua \
	--disable-libwrap \
	--disable-librados \
	--disable-libdbi \
	--disable-rrd_restore \
	--enable-rrd_graph \
	--with-rrd-default-font="/usr/share/rrdtool/fonts/DejaVuSansMono-Roman.ttf"

CONFIGURE_VARS += \
	rd_cv_ieee_works=yes \
	rd_cv_null_realloc=nope \
	ac_cv_func_mmap_fixed_mapped=yes \

ifneq ($(SDK)$(CONFIG_PACKAGE_rrdcgi17),)
  CONFIGURE_ARGS += --enable-rrdcgi
else
  CONFIGURE_ARGS += --disable-rrdcgi
endif

define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	env >/tmp/env.txt
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

define Build/Compile
	$(call Build/Compile/Default)
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/lib/include
	$(CP) $(PKG_INSTALL_DIR)/usr/include/rrd.h $(1)/usr/lib/include/
	$(INSTALL_DIR) $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/librrd.{a,so*} $(1)/usr/lib/
endef

define Package/librrd17/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/librrd.so.* $(1)/usr/lib/
	#$(CP) $(PKG_INSTALL_DIR)/usr/lib/librrd_th.so.* $(1)/usr/lib/
	$(INSTALL_DIR) $(1)/usr/share/rrdtool/fonts
	#$(CP) $(PKG_BUILD_DIR)/src/DejaVuSansMono-Roman.ttf \
		$(1)/usr/share/rrdtool/fonts/
endef

define Package/rrdcgi17/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/rrdcgi $(1)/usr/bin/
endef

define Package/rrdtool17/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/rrdtool $(1)/usr/bin/rrdtool
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/rrdupdate $(1)/usr/bin/rrdupdate
endef


$(eval $(call BuildPackage,librrd17))
$(eval $(call BuildPackage,rrdcgi17))
$(eval $(call BuildPackage,rrdtool17))
