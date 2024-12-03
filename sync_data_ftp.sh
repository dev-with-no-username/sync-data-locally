#!/bin/bash

# FTP server details
FTP_SERVER="192.168.1.48"  # Replace with your Android phone's IP
FTP_PORT="2221"            # Replace with your FTP port
FTP_DIRECTORY="/DCIM/Documenti"  # Path to the photos folder on the Android phone

# Local directories
TEMP_DIR="/tmp/android_photos"
USB_DEVICE="/dev/sdc1"  # Replace with your USB device (e.g., /dev/sdb1)
USB_DEFAULT_MOUNT="/media/usb"  # Path to mount the USB drive
USB_MOUNT="/media/usb"  # Path to mount the USB drive

# Read username and password from command-line
echo "Enter your username:"
read FTP_USER
echo "Enter your password:"
read -s FTP_PASSWORD

# Parse command-line options
while getopts ":d:u" opt; do
    case $opt in
        d) 
            if [ ! -z "$OPTARG" ]; then
                FTP_DIRECTORY="$OPTARG"  # Override FTP_DIRECTORY
            fi
            ;;
        u) 
            if [ ! -z "$OPTARG" ]; then
                USB_DEVICE="$OPTARG"     # Override USB_DEVICE
            fi
            ;;
    esac
done

echo "FTP_DIRECTORY: $FTP_DIRECTORY, USB_DEVICE: $USB_DEVICE"

# Ensure necessary directories exist
mkdir -p "$TEMP_DIR"
mkdir -p "$USB_MOUNT"

# Auto-detect the USB mount point
USB_MOUNT=$(lsblk -o NAME,MOUNTPOINT | grep "$(basename "$USB_DEVICE")" | awk '{print $2}')

# Mount the USB drive if not mounted
if [ -z "$USB_MOUNT" ]; then
    USB_MOUNT="$USB_DEFAULT_MOUNT"
    sudo mount "$USB_DEVICE" "$USB_MOUNT"
    if [ $? -ne 0 ]; then
        echo "Failed to mount USB drive. Exiting."
        exit 1
    fi
else
    echo "Detected USB drive mounted at $USB_MOUNT"
fi

# Sync photos from Android to temp directory using FTP
echo "Syncing photos from Android..."
lftp -u "$FTP_USER","$FTP_PASSWORD" "ftp://$FTP_SERVER:$FTP_PORT" <<EOF
mirror --verbose --continue --delete --only-newer "$FTP_DIRECTORY" "$TEMP_DIR"
bye
EOF

# Extract the folder name from the FTP_DIRECTORY
DIRECTORY_NAME=$(basename "$FTP_DIRECTORY")

# Copy photos to the USB drive under the directory with the same name
DEST_DIR="$USB_MOUNT/$DIRECTORY_NAME"
mkdir -p "$DEST_DIR"

echo "Copying photos to USB drive at $DEST_DIR..."
if [ -d "$USB_MOUNT" ]; then
    cp -r "$TEMP_DIR"/* "$DEST_DIR"
    if [ $? -eq 0 ]; then
        echo "Photos successfully copied to $DEST_DIR."
    else
        echo "Error copying photos to $DEST_DIR."
    fi
else
    echo "USB drive mount point not found. Skipping copy."
fi

# Cleanup temporary directory
echo "Cleaning up temporary files..."
rm -rf "$TEMP_DIR"

# Unmount the USB drive
echo "Unmounting USB drive..."
sudo umount "$USB_DEFAULT_MOUNT"
if [ $? -eq 0 ]; then
    echo "USB drive successfully unmounted."
else
    echo "USB drive not unmounted because was mounted on $USB_MOUNT instead of default $USB_DEFAULT_MOUNT."
fi

echo "Script completed."