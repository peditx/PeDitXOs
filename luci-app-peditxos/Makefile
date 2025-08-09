#
# Copyright (C) 2024 PeDitX
#
include $(TOPDIR)/rules.mk
include $(TOPDIR)/feeds/luci/luci.mk

# --- Package Information ---
PKG_NAME:=luci-app-peditxos
PKG_VERSION:=65
PKG_RELEASE:=3
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

# --- *** FIX: Correctly install files with proper permissions *** ---
# This section tells the build system how to install your files into the package.
define Package/luci-app-peditxos/install
	# Install LuCI controller and view files
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci
	$(CP) ./luasrc/* $(1)/usr/lib/lua/luci/

	# Install the main runner script as an executable file
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./root/usr/bin/peditx_runner.sh $(1)/usr/bin/
endef

# This tells the build system to include the post-install and pre-removal scripts
define Package/luci-app-peditxos/postinst
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./control/postinst $(1)/etc/uci-defaults/99-luci-app-peditxos
endef

define Package/luci-app-peditxos/prerm
	$(CP) ./control/prerm $(1)/prerm
endef

# --- Finalize Package ---
$(eval $(call BuildPackage,$(PKG_NAME)))

