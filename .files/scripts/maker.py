import os
import subprocess
import urllib.request
import shutil

# Paths and URLs
iso_url = "https://dl-cdn.alpinelinux.org/alpine/v3.16/releases/x86_64/alpine-standard-3.16.0-x86_64.iso"
iso_path = "/tmp/debian.iso"
work_dir = "/tmp/debian_work"
script_url = "https://raw.githubusercontent.com/peditx/PeDitXOs/refs/heads/main/scripts/PeDitXrt_installer.sh"
script_path = os.path.join(work_dir, "root", "PeDitXrt_installer.sh")
banner_url = "https://raw.githubusercontent.com/peditx/luci-theme-peditx/refs/heads/main/luasrc/style/brand.png"
banner_path = os.path.join(work_dir, "usr", "share", "plymouth", "themes", "mytheme", "banner.png")
iso_output_path = "/tmp/PeDitXOs.iso"

# Function to download a file
def download_file(url, path):
    print(f"Downloading {url} to {path}...")
    urllib.request.urlretrieve(url, path)

# Function to mount the ISO
def mount_iso():
    print(f"Mounting the ISO at {iso_path}...")
    subprocess.run(["mount", "-o", "loop", iso_path, "/mnt"], check=True)

# Function to extract the contents of the ISO
def extract_iso():
    print(f"Extracting the ISO contents to {work_dir}...")
    subprocess.run(["cp", "-a", "/mnt/.", work_dir], check=True)

# Function to copy the installation script to the live system
def copy_script():
    print(f"Copying the script from {script_url} to {script_path}...")
    os.makedirs(os.path.dirname(script_path), exist_ok=True)
    download_file(script_url, script_path)
    subprocess.run(["chmod", "+x", script_path], check=True)

# Function to install necessary packages
def install_packages():
    print("Installing necessary packages...")
    subprocess.run(["chroot", work_dir, "apk", "add", "unzip", "parted", "gzip", "nano", "fdisk"], check=True)

# Function to set up the Plymouth theme and banner
def setup_banner():
    print(f"Setting up the banner at {banner_path}...")
    os.makedirs(os.path.dirname(banner_path), exist_ok=True)
    download_file(banner_url, banner_path)
    subprocess.run(["chroot", work_dir, "sh", "-c", "echo 'theme=\"mytheme\"' >> /etc/plymouth/plymouthd.conf"], check=True)

# Function to create the new ISO
def create_iso():
    print("Creating the new ISO...")
    subprocess.run(["xorriso", "-as", "mkisofs", "-o", iso_output_path, "-r", "-J", "-V", "PeDitXOs", work_dir], check=True)

# Main function to execute all steps
def main():
    # Setup environment and download necessary files
    os.makedirs(work_dir, exist_ok=True)
    download_file(iso_url, iso_path)
    
    # Extract contents from the ISO
    extract_iso()
    
    # Copy the script, install packages, and set up the banner
    copy_script()
    install_packages()
    setup_banner()
    
    # Create the new ISO
    create_iso()
    
    print(f"ISO created successfully at {iso_output_path}")

if __name__ == "__main__":
    main()
