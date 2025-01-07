import os
import urllib.request
import subprocess
import shutil

# URLs for required files
iso_url = "https://dl-cdn.alpinelinux.org/alpine/v3.16/releases/x86_64/alpine-standard-3.16.0-x86_64.iso"
script_url = "https://raw.githubusercontent.com/peditx/PeDitXOs/refs/heads/main/scripts/PeDitXrt_installer.sh"
banner_url = "https://raw.githubusercontent.com/peditx/luci-theme-peditx/refs/heads/main/luasrc/style/brand.png"

# Paths for the working directories and files
work_dir = "/tmp/live-iso"
mount_dir = "/mnt"
iso_path = "/tmp/debian.iso"
script_path = os.path.join(work_dir, "root", "PeDitXrt_installer.sh")
banner_path = os.path.join(work_dir, "usr", "share", "plymouth", "themes", "mytheme", "banner.png")
iso_output_path = "/tmp/PeDitXOs.iso"

# Download ISO, script, and banner
def download_file(url, dest_path):
    print(f"Downloading {url} to {dest_path}")
    urllib.request.urlretrieve(url, dest_path)

# Setup environment
def setup_environment():
    print("Setting up environment...")
    os.makedirs(work_dir, exist_ok=True)
    os.makedirs(os.path.dirname(script_path), exist_ok=True)
    os.makedirs(os.path.dirname(banner_path), exist_ok=True)

# Mount the ISO
def mount_iso():
    print("Mounting the ISO...")
    subprocess.run(["mount", "-o", "loop", iso_path, mount_dir], check=True)

# Copy the content from the mounted ISO to the working directory
def copy_iso_contents():
    print("Copying contents from ISO to working directory...")
    for item in os.listdir(mount_dir):
        s = os.path.join(mount_dir, item)
        d = os.path.join(work_dir, item)
        if os.path.isdir(s):
            shutil.copytree(s, d, dirs_exist_ok=True)
        else:
            shutil.copy2(s, d)

# Copy the script to the live system
def copy_script():
    print("Copying the installer script...")
    download_file(script_url, script_path)
    os.chmod(script_path, 0o755)

# Install required packages
def install_packages():
    print("Installing required packages...")
    packages = ["unzip", "parted", "gzip", "nano", "fdisk"]
    for package in packages:
        subprocess.run(["apk", "add", package], check=True)

# Set up the banner
def setup_banner():
    print("Setting up banner...")
    os.makedirs(os.path.dirname(banner_path), exist_ok=True)
    download_file(banner_url, banner_path)

# Create the new ISO
def create_iso():
    print("Creating new ISO...")
    subprocess.run(["xorriso", "-as", "mkisofs", "-o", iso_output_path, "-r", "-J", "-V", "PeDitXOs", work_dir], check=True)

# Main function to execute all steps
def main():
    # Setup environment and download necessary files
    setup_environment()
    download_file(iso_url, iso_path)
    
    # Mount the ISO, copy contents, and setup the environment
    mount_iso()
    copy_iso_contents()
    
    # Copy the script, install packages, and set up the banner
    copy_script()
    install_packages()
    setup_banner()
    
    # Create the new ISO
    create_iso()
    
    print(f"ISO created successfully at {iso_output_path}")

if __name__ == "__main__":
    main()
