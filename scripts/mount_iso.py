import os
import subprocess
import sys

def mount_iso(iso_path, mount_point):
    try:
        if not os.path.isfile(iso_path):
            print(f"Error: The file {iso_path} does not exist.")
            sys.exit(1)

        if not os.path.exists(mount_point):
            os.makedirs(mount_point)

        subprocess.run(['sudo', 'mount', '-o', 'loop', iso_path, mount_point], check=True)
        print(f"ISO {iso_path} successfully mounted to {mount_point}")

    except subprocess.CalledProcessError as e:
        print(f"Error: Failed to mount {iso_path}. {e}")
        sys.exit(1)

def main():
    iso_path = 'debian.iso'  # مسیر فایل ISO
    mount_point = '/mnt'      # مسیر ماؤن

    mount_iso(iso_path, mount_point)

if __name__ == "__main__":
    main()
