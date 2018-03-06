#!/bin/bash

# Download the installer archive from Mozilla distribution server
if [ ! -e thunderbird-latest.tar.bz2 ]; then
	wget -O thunderbird-latest.tar.bz2 'https://download.mozilla.org/?product=thunderbird-latest&os=linux64&lang=en-US'
fi

# Make necessary directories
mkdir thunderbird-vendor
mkdir thunderbird-vendor/DEBIAN
mkdir -p thunderbird-vendor/opt/mozilla
mkdir -p thunderbird-vendor/usr/share/applications

# Extract the installer archive
tar -xjvf thunderbird-latest.tar.bz2 -C thunderbird-vendor/opt/mozilla

# Execute the Thunderbird binary to get the version number
version=$(thunderbird-vendor/opt/mozilla/thunderbird/thunderbird --version | sed 's/.* //')

# Create control file for package
echo "Package: thunderbird-vendor
Version: $version
Maintainer: $USER
Architecture: amd64
Description: Package of the Thunderbird email client as released by Mozilla" > thunderbird-vendor/DEBIAN/control

# Create desktop entry inside package with appropriate version number
echo "[Desktop Entry]
Version=$version
Name=Mozilla Thunderbird
Comment=E-Mail Client
GenericName=E-Mail Client
Exec=/opt/mozilla/thunderbird/thunderbird
Icon=/opt/mozilla/thunderbird/chrome/icons/default/default256.png
StartupNotify=true
Terminal=false
Type=Application
Categories=Internet;
Keywords=thunderbird;email;e-mail;mozilla;" > thunderbird-vendor/usr/share/applications/thunderbird.desktop

# Build the package
chmod g-s thunderbird-vendor/DEBIAN
chmod 755 thunderbird-vendor/DEBIAN
dpkg-deb --build thunderbird-vendor

# Clean up
rm thunderbird-latest.tar.bz2
rm -r thunderbird-vendor
