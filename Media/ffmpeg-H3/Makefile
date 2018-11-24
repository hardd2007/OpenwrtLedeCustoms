#
# Copyright (C) 2017-2018 Ian Leonard <antonlacon@gmail.com>
# Copyright (C) 2018 Ted Hess <thess@kitschensync.net>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ffmpeg-H3
PKG_VERSION:=4.1
PKG_RELEASE:=4
PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)-$(PKG_VERSION)

include $(INCLUDE_DIR)/package.mk

define Package/ffmpeg-H3
 SECTION:=MYREP
 CATEGORY:=MYREP
 SUBMENU:=Media
 TITLE:= Main binary
 DEPENDS:= +libffmpeg-full-H3
endef

define Package/ffmpeg-H3/description
 FFmpeg with hw decoding for H3 SoC
endef


define Package/ffprobe-H3
 SECTION:=MYREP
 CATEGORY:=MYREP
 SUBMENU:=Media
 TITLE:= CLI media identifier
 DEPENDS:= +libffmpeg-full-H3
endef

define Package/ffprobe-H3/description
 This package contains the FFprobe command line tool.
endef

define Package/libffmpeg-full-H3
 SECTION:=MYREP
 CATEGORY:=MYREP
 SUBMENU:=Media
 TITLE:= libffmpeg-full-H3
 DEPENDS:= +libpthread +zlib +libbz2 +PACKAGE_lame-lib:lame-lib \
 +PACKAGE_libx264:libx264 +libmpeg2 +libvorbis +libogg +PACKAGE_fdk-aac:fdk-aac \
 +alsa-lib +libvpx +PACKAGE_libopus:libopus
 PROVIDES:= libffmpeg
endef

# Strip off FPU notation
REAL_CPU_TYPE:=$(firstword $(subst +, ,$(CONFIG_CPU_TYPE)))
# Fixup cpu types recogized by ffmpeg configure
REAL_CPU_TYPE:=$(subst octeonplus,octeon+,$(REAL_CPU_TYPE))

FFMPEG_CONFIGURE:= \
	CFLAGS="$(TARGET_CFLAGS) $(TARGET_CPPFLAGS) $(FPIC)" \
	LDFLAGS="$(TARGET_LDFLAGS)" \
	./configure \
	--enable-cross-compile \
	--cross-prefix="$(TARGET_CROSS)" \
	--arch="$(ARCH)" \
	$(if $(REAL_CPU_TYPE),--cpu=$(call qstrip,$(REAL_CPU_TYPE)),) \
	--target-os=linux \
	--prefix="/usr" \
	--pkg-config="pkg-config" \
	--enable-shared \
	--enable-static \
	--enable-pthreads \
	--enable-zlib \
	--disable-doc \
	--disable-debug \
	--disable-lzma \
	--disable-vaapi \
	--disable-vdpau \
	--disable-outdevs \
	--disable-runtime-cpudetect \
	--enable-lto \
	--enable-vfp \
	--enable-neon \
	--enable-hardcoded-tables \
	--enable-libx264 \
	--enable-gpl \
	--enable-version3 \
	--enable-nonfree \
	--enable-decoder=adpcm_ima_wav \
	--enable-decoder=adpcm_ima_qt \
	--enable-decoder=adpcm_ms \
	--enable-libmp3lame --enable-encoder=libmp3lame \
	--enable-libx264 --enable-encoder=libx264 --enable-decoder=h264 --enable-parser=h264 --enable-muxer=h264 \
	--enable-libfdk_aac \
	--enable-libopus \
	--enable-libvorbis \
	--enable-libvpx \
	--enable-avresample
	
define Build/Prepare
	mkdir -p $(PKG_BUILD_DIR)
	env >/tmp/env.txt
	$(CP) ./src/* $(PKG_BUILD_DIR)/
endef

define Build/Configure
	( cd $(PKG_BUILD_DIR); $(FFMPEG_CONFIGURE) )
endef

define Build/Compile
	$(MAKE) -C $(PKG_BUILD_DIR) \
		DESTDIR="$(PKG_INSTALL_DIR)" \
		all install
endef

define Build/InstallDev/full
	$(INSTALL_DIR) $(1)/usr/include
	$(INSTALL_DIR) $(1)/usr/lib
	$(INSTALL_DIR) $(1)/usr/lib/pkgconfig
	$(CP) $(PKG_INSTALL_DIR)/usr/include/lib{avcodec,avdevice,avfilter,avformat,avresample,avutil,swresample,swscale} $(1)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lib{avcodec,avdevice,avfilter,avformat,avresample,avutil,swresample,swscale}.{a,so*} $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/lib{avcodec,avdevice,avfilter,avformat,avresample,avutil,swresample,swscale}.pc $(1)/usr/lib/pkgconfig/
	$(CP) $(PKG_INSTALL_DIR)/usr/include/libpostproc $(1)/usr/include/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libpostproc.{a,so*} $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/pkgconfig/libpostproc.pc $(1)/usr/lib/pkgconfig/
endef

Build/InstallDev = $(Build/InstallDev/full)

define Package/ffmpeg-H3/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/ffmpeg $(1)/usr/bin/
endef

define Package/ffprobe-H3/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(CP) $(PKG_INSTALL_DIR)/usr/bin/ffprobe $(1)/usr/bin/
endef



# Only ffmpeg with libx264 is GPL (yes libpostproc); all other builds are lgpl (no libpostproc)
define Package/libffmpeg-full-H3/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/lib{avcodec,avdevice,avfilter,avformat,avresample,avutil,swresample,swscale}.so.* $(1)/usr/lib/
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/libpostproc.so.* $(1)/usr/lib/
endef

$(eval $(call BuildPackage,ffmpeg-H3))
$(eval $(call BuildPackage,ffprobe-H3))
$(eval $(call BuildPackage,libffmpeg-full-H3))
