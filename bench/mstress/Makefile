#
# Copyright (C) 2019 Johann Neuhauser <johann@it-neuhauser.de>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

# notes: mstress.c:48:26: warning: conversion from 'long long unsigned int' to 'uintptr_t' 
#   {aka 'const unsigned int'} changes value from '13787848793156543929' to '484763065' [-Woverflow]

include $(TOPDIR)/rules.mk

PKG_NAME:=mstress
PKG_VERSION:=0.1
PKG_RELEASE:=1

PKG_MAINTAINER:=Johann Neuhauser <johann@it-neuhauser.de>
PKG_LICENSE:=
PKG_LICENSE_FILES:=

CMAKE_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/mstress
  SECTION:=utils
  CATEGORY:=Utilities
  DEPENDS:=+libpthread
  TITLE:=mstress
endef

define Package/mstress/description
  No one knows something about it, but it´s used for benchmarking malloc implementations.
endef

CMAKE_OPTIONS+=\
	-DCMAKE_VERBOSE_MAKEFILE:BOOL=ON

define Package/mstress/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_INSTALL_DIR)/usr/bin/mstress $(1)/usr/bin/
endef

$(eval $(call BuildPackage,mstress))
