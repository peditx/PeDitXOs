#
# PeDitXOS Tools Makefile
# Copyright (C) 2024 PeDitX
#
include $(TOPDIR)/rules.mk
include $(TOPDIR)/feeds/luci/luci.mk

# --- Package Information ---
PKG_NAME:=luci-app-peditxos
PKG_VERSION:=65
PKG_RELEASE:=1
PKG_MAINTAINER:=PeDitX <telegram: @PeDitX>

# --- LuCI Configuration ---
LUCI_TITLE:=PeDitXOS Tools Suite for OpenWrt
LUCI_PKGARCH:=all
# Dependencies: Add all required packages here. opkg will install them automatically.
LUCI_DEPENDS:= \
	+luci-compat \
	+luci-app-ttyd \
	+curl \
	+sshpass \
	+procps-ng-pkill \
	+coreutils \
	+coreutils-base64 \
	+coreutils-nohup \
	+wget \
	+luci-theme-peditx \
	+luci-theme-carbonpx \
	+luci-app-themeswitch

# --- Package Definition ---
define Package/luci-app-peditxos
	$(call Package/luci-app/Default)
	TITLE:=$(LUCI_TITLE)
	DEPENDS:=$(LUCI_DEPENDS)
	MAINTAINER:=$(PKG_MAINTAINER)
endef

# --- Package Description ---
define Package/luci-app-peditxos/description
	A collection of tools and utilities for OpenWrt managed via LuCI.
	Includes Passwall installers, DNS changers, service managers, and system optimizations.
endef

# --- Build/Installation Rules ---
# This section tells the build system where to place your files inside the package.

define Package/luci-app-peditxos/install
	# Install the LuCI controller and view files
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci
	$(CP) ./luasrc/* $(1)/usr/lib/lua/luci/

	# Install the main runner script
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./root/usr/bin/peditx_runner.sh $(1)/usr/bin/
endef

# --- Post-Installation and Pre-Removal Scripts ---
# These will use the files you create in the 'control' directory.

define Package/luci-app-peditxos/postinst
	#!/bin/sh
	# The contents of the 'control/postinst' file will be automatically included here.
endef

define Package/luci-app-peditxos/prerm
	#!/bin/sh
	# The contents of the 'control/prerm' file will be automatically included here.
endef


# --- Finalize Package ---
$(eval $(call BuildPackage,$(PKG_NAME)))
