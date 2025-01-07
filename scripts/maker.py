import subprocess
import os
import urllib.request

# URLs for the necessary files
iso_url = "https://dl-cdn.alpinelinux.org/alpine/v3.16/releases/x86_64/alpine-standard-3.16.0-x86_64.iso"
script_url = "https://raw.githubusercontent.com/peditx/PeDitXOs/refs/heads/main/scripts/PeDitXrt_installer.sh"
banner_url = "https://raw.githubusercontent.com/peditx/luci-theme-peditx/refs/heads/main/luasrc/style/brand.png"

# Paths
iso_path = "/tmp/debian.iso"
work_dir = "/tmp/debian_work"
output_dir = "/tmp"
iso_output_path = "/tmp/PeDitXOs.iso"

# Function to download a file from a URL
def download_file(url, path):
    print(f"Downloading {url} to {path}...")
    urllib.request.urlretrieve(url, path)

# Function to extract the ISO using 7z
def extract_iso():
    print("Extracting the ISO contents...")
    subprocess.run(["7z", "x", iso_path, "-o" + work_dir], check=True)

# Function to copy the script to the live system
def copy_script():
    print("Copying the script to the live system...")
    script_path = os.path.join(work_dir, "root", "PeDitXrt_installer.sh")
    urllib.request.urlretrieve(script_url, script_path)
    subprocess.run(["chmod", "+x", script_path], check=True)

# Function to install required packages
def install_packages():
    print("Installing necessary packages...")
    packages = ["unzip", "parted", "gzip", "nano", "fdisk"]
    for package in packages:
        subprocess.run(["apk", "add", package], check=True)

# Function to set up the banner
def setup_banner():
    print("Setting up the custom banner...")
    banner_path = os.path.join(work_dir, "usr", "share", "plymouth", "themes", "mytheme", "banner.png")
    os.makedirs(os.path.dirname(banner_path), exist_ok=True)
    urllib.request.urlretrieve(banner_url, banner_path)

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
