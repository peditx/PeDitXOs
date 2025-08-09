#
# Copyright (C) 2024 PeDitX
#
include $(TOPDIR)/rules.mk
include $(TOPDIR)/feeds/luci/luci.mk

# --- Package Information ---
PKG_NAME:=luci-app-peditxos
PKG_VERSION:=66
PKG_RELEASE:=4
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
	+wget

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

# --- Installation Rules ---
# This section tells the build system how to install your files into the package.
define Package/luci-app-peditxos/install
	# Install LuCI controller and view files
	$(INSTALL_DIR) $(1)/usr/lib/lua/luci
	$(CP) ./luasrc/* $(1)/usr/lib/lua/luci/

	# Install the main runner script as an executable file
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) ./root/usr/bin/peditx_runner.sh $(1)/usr/bin/
endef

# --- *** FIX: Correctly package post-install and pre-removal scripts *** ---
# This tells the build system to include the scripts in the correct way.
# The postinst script will be run once by uci-defaults and then removed.
define Package/luci-app-peditxos/postinst
	$(INSTALL_DIR) $(1)/etc/uci-defaults
	$(INSTALL_BIN) ./control/postinst $(1)/etc/uci-defaults/99-luci-app-peditxos
endef

# The prerm script is placed in the control archive to be run before removal.
define Package/luci-app-peditxos/prerm
	$(INSTALL_BIN) ./control/prerm $(1)/prerm
endef


# --- Finalize Package ---
$(eval $(call BuildPackage,$(PKG_NAME)))
