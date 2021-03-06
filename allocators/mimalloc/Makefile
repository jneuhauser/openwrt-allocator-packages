#
# Copyright (C) 2019 Johann Neuhauser <johann@it-neuhauser.de>
#
# This is free software, licensed under the GNU General Public License v2.
# See /LICENSE for more information.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=mimalloc
MAJOR_MINOR_VERSION:=1.2
PATCH_VERSION:=2
EXTRA_VERSION:=
PKG_VERSION:=$(MAJOR_MINOR_VERSION).$(PATCH_VERSION)$(EXTRA_VERSION)
PKG_RELEASE:=1

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION).tar.gz
PKG_SOURCE_URL:=https://codeload.github.com/microsoft/mimalloc/tar.gz/v$(PKG_VERSION)?
PKG_HASH:=55a5b9af9bae6f9af787dcd1ff561e6865b51f04e1722c7d3e19cc6bd427655e

PKG_MAINTAINER:=Johann Neuhauser <johann@it-neuhauser.de>
PKG_LICENSE:=MIT
PKG_LICENSE_FILES:=LICENSE

CMAKE_INSTALL:=1
PKG_BUILD_PARALLEL:=1

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

define Package/mimalloc/default
  SECTION:=libs
  CATEGORY:=Libraries
  URL:=https://github.com/microsoft/mimalloc
  DEPENDS:= +librt +libatomic
  TITLE:=mimalloc general purpose allocator
endef

define Package/mimalloc/description/default
  mimalloc (pronounced "me-malloc") is a general purpose allocator with excellent performance characteristics.
  Initially developed by Daan Leijen for the run-time systems of the Koka and Lean languages.
endef

define Package/mimalloc
  $(call Package/mimalloc/default)
  VARIANT:=default
  DEFAULT_VARIANT:=1
endef

define Package/mimalloc/description
  $(call Package/mimalloc/description/default)
endef

define Package/mimalloc-secure
  $(call Package/mimalloc/default)
  TITLE+=(secure)
  VARIANT:=secure
  PROVIDES:=mimalloc
endef

define Package/mimalloc-secure/description
  $(call Package/mimalloc/description/default)

  mimalloc in secure mode, uses guard pages, randomized allocation,
  encrypted free lists, etc. to protect against various heap vulnerabilities.
  The performance penalty is only around 3% on average over our benchmarks.
endef

CMAKE_OPTIONS+=\
  -DMI_BUILD_TESTS=OFF\
  -DMI_CHECK_FULL=OFF\
  -DMI_INTERPOSE=OFF\
  -DMI_LOCAL_DYNAMIC_TLS=OFF\
  -DMI_OVERRIDE=ON\
  -DMI_SEE_ASM=OFF\
  -DMI_USE_CXX=OFF

ifeq ($(BUILD_VARIANT),secure)
  CMAKE_OPTIONS+=-DMI_SECURE=ON
else
  CMAKE_OPTIONS+=-DMI_SECURE=OFF
endif

define Package/mimalloc/install
	$(INSTALL_DIR) $(1)/usr/lib/mimalloc-$(MAJOR_MINOR_VERSION)
	$(CP) $(PKG_INSTALL_DIR)/usr/lib/mimalloc-$(MAJOR_MINOR_VERSION)/*.so* \
		$(1)/usr/lib/mimalloc-$(MAJOR_MINOR_VERSION)/
	$(LN) mimalloc-$(MAJOR_MINOR_VERSION)/libmimalloc$(if $(filter $(BUILD_VARIANT),secure),-$(BUILD_VARIANT)).so.$(MAJOR_MINOR_VERSION) \
		$(1)/usr/lib/libmimalloc$(if $(filter $(BUILD_VARIANT),secure),-$(BUILD_VARIANT)).so
endef

Package/mimalloc-secure/install = $(Package/mimalloc/install)

$(eval $(call BuildPackage,mimalloc))
$(eval $(call BuildPackage,mimalloc-secure))
