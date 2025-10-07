#!/bin/sh

# PeDitXOS Service Runner v3
# This script contains the installation and uninstallation logic for Store applications.

ACTION="$1"

# --- Dynamic URLs Start ---
URL_INSTALL_INSTALLDNSJUMPER="https://peditx.ir/projects/DNSJumper/code/install.sh"
URL_INSTALL_PXNOTIFIER="https://peditx.ir/projects/PXnotifier/code/install.sh"
URL_INSTALL_TORPLUS="https://raw.githubusercontent.com/peditx/openwrt-torplus/main/.Files/install.sh"
URL_INSTALL_SSHPLUS="https://raw.githubusercontent.com/peditx/SshPlus/main/Files/install_sshplus.sh"
URL_INSTALL_AIRCAST="https://raw.githubusercontent.com/peditx/aircast-openwrt/main/aircast_install.sh"
URL_INSTALL_WARP="https://raw.githubusercontent.com/peditx/openwrt-warpplus/refs/heads/main/files/install.sh"
URL_INSTALL_WARPPLUSPLUS="https://raw.githubusercontent.com/peditx/openwrt-warpplusplus/refs/heads/main/install.sh"
URL_INSTALL_AMNEZIAWG="https://raw.githubusercontent.com/Slava-Shchipunov/awg-openwrt/refs/heads/master/amneziawg-install.sh"
URL_INSTALL_IRANIPS="https://raw.githubusercontent.com/peditx/iranIPS/refs/heads/main/.files/iranips.sh"
URL_INSTALL_CARBONPX="https://raw.githubusercontent.com/peditx/luci-theme-carbonpx/refs/heads/main/install.sh"
URL_INSTALL_PEDITX="https://raw.githubusercontent.com/peditx/luci-theme-peditx/refs/heads/main/install.sh"
URL_INSTALL_INSTALLAURORATHEME="https://peditx.ir/foreignscs/luci-theme-aurora/install.sh"
URL_INSTALL_INSTALLARGONTHEME="https://peditx.ir/foreignscs/luci-theme-argon/install.sh"
# --- Dynamic URLs End ---

# --- Dynamic Uninstall URLs Start ---
URL_UNINSTALL_INSTALL_INSTALLDNSJUMPER="https://www.google.com/search?q=https://peditx.ir/projects/DNSJumper/code/uninstall.sh"
# --- Dynamic Uninstall URLs End ---


# --- Dynamic Functions Start ---
install_installdnsjumper() {
	echo "Downloading Install DNSJumper components..."
	cd /tmp && rm -f install.sh && wget -q "$URL_INSTALL_INSTALLDNSJUMPER" -O install.sh && chmod +x install.sh && sh install.sh
}

install_pxnotifier() {
	echo "Downloading PXNotifier components..."
	cd /tmp && rm -f install.sh && wget -q "$URL_INSTALL_PXNOTIFIER" -O install.sh && chmod +x install.sh && sh install.sh
}

install_torplus() {
	echo "Downloading Install TORPlus components..."
	cd /tmp && rm -f install.sh && wget -q "$URL_INSTALL_TORPLUS" -O install.sh && chmod +x install.sh && sh install.sh
}

install_sshplus() {
	echo "Downloading Install SSHPlus components..."
	cd /tmp && rm -f install_sshplus.sh && wget -q "$URL_INSTALL_SSHPLUS" -O install_sshplus.sh && chmod +x install_sshplus.sh && sh install_sshplus.sh
}

install_aircast() {
	echo "Downloading Install Air-Cast components..."
	cd /tmp && rm -f aircast_install.sh && wget -q "$URL_INSTALL_AIRCAST" -O aircast_install.sh && chmod +x aircast_install.sh && sh aircast_install.sh
}

install_warp() {
	echo "Downloading Install Warp+ components..."
	cd /tmp && rm -f install.sh && wget -q "$URL_INSTALL_WARP" -O install.sh && chmod +x install.sh && sh install.sh
}

install_warpplusplus() {
	echo "Downloading Install Warp++ components..."
	cd /tmp && rm -f install.sh && wget -q "$URL_INSTALL_WARPPLUSPLUS" -O install.sh && chmod +x install.sh && sh install.sh
}

install_amneziawg() {
	echo "Downloading Install AmneziaWG components..."
	cd /tmp && rm -f amneziawg-install.sh && wget -q "$URL_INSTALL_AMNEZIAWG" -O amneziawg-install.sh && chmod +x amneziawg-install.sh && sh amneziawg-install.sh
}

install_iranips() {
	echo "Downloading Install Iran Rule IPS for Passwall2 components..."
	cd /tmp && rm -f iranips.sh && wget -q "$URL_INSTALL_IRANIPS" -O iranips.sh && chmod +x iranips.sh && sh iranips.sh
}

install_carbonpx() {
	echo "Downloading Install CarbonPX Theme components..."
	cd /tmp && rm -f install.sh && wget -q "$URL_INSTALL_CARBONPX" -O install.sh && chmod +x install.sh && sh install.sh
}

install_peditx() {
	echo "Downloading Install PeDitX Theme components..."
	cd /tmp && rm -f install.sh && wget -q "$URL_INSTALL_PEDITX" -O install.sh && chmod +x install.sh && sh install.sh
}

install_installauroratheme() {
	echo "Downloading Install Aurora Theme components..."
	cd /tmp && rm -f install.sh && wget -q "$URL_INSTALL_INSTALLAURORATHEME" -O install.sh && chmod +x install.sh && sh install.sh
}

install_installargontheme() {
	echo "Downloading Install Argon Theme components..."
	cd /tmp && rm -f install.sh && wget -q "$URL_INSTALL_INSTALLARGONTHEME" -O install.sh && chmod +x install.sh && sh install.sh
}
# --- Dynamic Functions End ---

# --- Dynamic Uninstall Functions Start ---
uninstall_installdnsjumper() {
	echo "Downloading Uninstall Install DNSJumper components..."
	cd /tmp && rm -f uninstall.sh && wget -q "$URL_UNINSTALL_INSTALL_INSTALLDNSJUMPER" -O uninstall.sh && chmod +x uninstall.sh && sh uninstall.sh
}
# --- Dynamic Uninstall Functions End ---


# --- Static Functions (Do not edit these) ---

change_repo() {
	echo "Changing to PeDitX Repo..."
	# Add actual commands here in the future
	echo "Repository change function is a placeholder."
}

install_wol() {
	echo "Installing Wake On Lan..."
	opkg update
	opkg install luci-app-wol
	echo "Wake On Lan installed successfully."
}

cleanup_memory() {
	echo "Cleaning up memory..."
	sync && echo 3 > /proc/sys/vm/drop_caches
	echo "Memory cleanup complete."
}

self_update_view() {
	echo "--- Starting Store UI Self-Update ---"
	VIEW_FILE_PATH="/usr/lib/lua/luci/view/serviceinstaller/main.htm"
	VIEW_FILE_URL="https://raw.githubusercontent.com/peditx/PeDitXOs/refs/heads/main/services/main.htm"
	TEMP_FILE="/tmp/main.htm.new"

	echo "Downloading latest UI from GitHub..."
	wget -q "$VIEW_FILE_URL" -O "$TEMP_FILE"

	if [ $? -eq 0 ] && [ -s "$TEMP_FILE" ]; then
		echo "Download successful."
		echo "Replacing old file at ${VIEW_FILE_PATH}"
		mv "$TEMP_FILE" "$VIEW_FILE_PATH"
		if [ $? -eq 0 ]; then
			echo "Store UI updated successfully!"
			echo "Please clear your browser cache and refresh the LuCI page."
		else
			echo "[ERROR] Failed to move the new file. Check permissions."
			rm -f "$TEMP_FILE"
		fi
	else
		echo "[ERROR] Failed to download the new UI file. Please check your internet connection."
		rm -f "$TEMP_FILE"
	fi
	echo "--- UI Update Finished ---"
}


# --- Main Execution Block ---
case "$ACTION" in
# --- Dynamic Cases Start ---
	install_installdnsjumper) install_installdnsjumper ;;
	uninstall_installdnsjumper) uninstall_installdnsjumper ;;
	install_pxnotifier) install_pxnotifier ;;
	install_torplus) install_torplus ;;
	install_sshplus) install_sshplus ;;
	install_aircast) install_aircast ;;
	install_warp) install_warp ;;
	install_warpplusplus) install_warpplusplus ;;
	install_amneziawg) install_amneziawg ;;
	install_iranips) install_iranips ;;
	install_carbonpx) install_carbonpx ;;
	install_peditx) install_peditx ;;
	install_installauroratheme) install_installauroratheme ;;
	install_installargontheme) install_installargontheme ;;
# --- Dynamic Cases End ---

# --- Static Cases (Do not edit these) ---
	change_repo) change_repo ;;
	install_wol) install_wol ;;
	cleanup_memory) cleanup_memory ;;
	self_update_view) self_update_view ;; 
	*) exit 1 ;; # Exit if action is not found
esac

exit 0
