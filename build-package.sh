#!/bin/bash

# Download the installer archive from Mozilla distribution server
if [ ! -e thunderbird-latest.tar.xz ]; then
	if ! wget -O thunderbird-latest.tar.xz 'https://download.mozilla.org/?product=thunderbird-latest&os=linux64&lang=en-US'; then
		echo "Failed to download distribution package from mozilla"
		exit 201
	fi
fi

# Make necessary directories
mkdir thunderbird-vendor
mkdir thunderbird-vendor/DEBIAN
mkdir -p thunderbird-vendor/opt/mozilla
mkdir -p thunderbird-vendor/usr/share/applications

# Extract the installer archive
if ! tar -xJvf thunderbird-latest.tar.xz -C thunderbird-vendor/opt/mozilla; then
	echo "Failed to extract downloaded package"
	exit 201
fi

# Execute the Thunderbird binary to get the version number
version=$(thunderbird-vendor/opt/mozilla/thunderbird/thunderbird --version | sed 's/.* //')
if [ -z "$version" ]; then
	echo "Did not get a valid version from running the downloaded application. Check that the package was downloaded and extracted successfully and try again."
	exit 202
fi

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
Icon=/opt/mozilla/thunderbird/chrome/icons/default/default128.png
StartupNotify=false
Terminal=false
Type=Application
Categories=Internet;
Keywords=thunderbird;email;e-mail;mozilla;" > thunderbird-vendor/usr/share/applications/thunderbird.desktop

# Build the package
chmod g-s thunderbird-vendor/DEBIAN
chmod 755 thunderbird-vendor/DEBIAN
dpkg-deb --build thunderbird-vendor

# Clean up
rm thunderbird-latest.tar.xz
rm -r thunderbird-vendor
