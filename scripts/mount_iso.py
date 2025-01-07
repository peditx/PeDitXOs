import os
import subprocess
import sys

def mount_iso(iso_path, mount_point):
    # Check if the mount point exists, if not, create it
    if not os.path.exists(mount_point):
        os.makedirs(mount_point)
    
    # Attempt to mount the ISO
    try:
        subprocess.run(['mount', '-o', 'loop', iso_path, mount_point], check=True)
        print(f"ISO {iso_path} mounted successfully at {mount_point}")
    except subprocess.CalledProcessError as e:
        print(f"Error mounting ISO: {e}")
        sys.exit(1)

def copy_iso_content(mount_point, destination):
    # Copy the content of the ISO to the destination directory
    try:
        subprocess.run(['cp', '-a', f'{mount_point}/.', destination], check=True)
        print(f"ISO content copied to {destination}")
    except subprocess.CalledProcessError as e:
        print(f"Error copying ISO content: {e}")
        sys.exit(1)

def main():
    iso_path = 'debian.iso'  # Path to the ISO file
    mount_point = '/mnt'  # Mount point
    destination = '/tmp/live-iso'  # Destination for the ISO content
    
    # Mount the ISO
    mount_iso(iso_path, mount_point)
    
    # Copy the ISO content
    copy_iso_content(mount_point, destination)

if __name__ == '__main__':
    main()
