#
# Copyright (C) 2008-2016 OpenWrt.org
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=motion
PKG_VERSION:=4.2.1
PKG_RELEASE:=1

PKG_MAINTAINER:=Roger D <rogerdammit@gmail.com>
PKG_LICENSE:=GPLv2
PKG_LICENSE_FILES:=COPYING

PKG_SOURCE:=$(PKG_NAME)-release-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/Motion-Project/motion/tar.gz/release-$(PKG_VERSION)?
PKG_HASH:=d97ec6ae766adfd478b6f7f9cc0da5f2fe21faa9366d98664be255714c1cf81d
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-release-$(PKG_VERSION)

PKG_BUILD_PARALLEL:=0
PKG_FIXUP:=autoreconf

include $(INCLUDE_DIR)/package.mk

define Package/motion-ffmpeg-static
  SECTION:=MYREP
  CATEGORY:=MYREP
  SUBMENU:=Media
  DEPENDS:= +libjpeg +libpthread +libmicrohttpd +libffmpeg-full-H3
  TITLE:=webcam motion sensing and logging
  URL:=https://motion-project.github.io/
endef

define Package/motion-ffmpeg-static/conffiles
/etc/motion.conf
endef

CONFIGURE_ARGS+= \
	--without-optimizecpu \
	--without-jpeg-mmx \
	--without-sdl \
	--without-mysql \
	--without-pgsql \
	--without-sqlite3 \
	--without-bktr \
	--enable-static \
	--with-ffmpeg=$(STAGING_DIR)/usr
	
##	
#TARGET_LDFLAGS+= \
#	-static

MAKE_FLAGS += \
	LDFLAGS=" -static " 
	

	#-lavformat -lswscale -lavcodec -lavutil -lfdk-aac -lswresample -lm -lopus -lz -lva -lvpx -lx264 -lmp3lame -lbz2 -ldl -lvorbisenc -lvorbis -ltheoraenc -ltheoradec" 
##-lavformat -lswscale -lavcodec -lavutil -lfdk-aac -lswresample -lm -lopus -lz -lva -lvpx -lx264 -lmp3lame -lbz2 -ldl -lvorbisenc -lvorbis -ltheoraenc -ltheoradec
	
define Package/motion-ffmpeg-static/install
	$(INSTALL_DIR) $(1)/etc
	$(CP) $(PKG_BUILD_DIR)/motion-dist.conf $(1)/etc/motion.conf
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/motion $(1)/usr/bin/

endef

$(eval $(call BuildPackage,motion-ffmpeg-static))
