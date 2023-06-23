#!/usr/bin/bash

# Check for the Distro Type

apps=(zip figlet)
rapps=()
p_managers=( "pkg" "apt" "yum" "dnf" "pacman" "zypper")

for app in "${apps[@]}"; do
	rapp=$(which "$app")

	if [ -z "$rapp" ]; then
		rapps+=("$app")
	fi
done

if [ "$rapps" ]; then
	# Check if package manager is available
	for pm in "${p_managers[@]}"; do
		is_installed=$(command -v "$pm")
		if $is_installed | grep -qo pacman; then
			sudo "$pm" -S "${rapps[@]}"
			break
		# This is for termux
		elif $is_installed | grep -qo pkg; then
			$pm install "${rapps[@]}"
			break
		elif $is_installed; then
			# Install zip and figlet package using pkg
			sudo "$pm" install "${rapps[@]}"
			break
		fi
	done
fi

# Display "Lawnchair Magisk" in bigger fonts
figlet "MIUI Launcher MOD"

# Delete already exists module zip
rm -rf MIUI\ Launcher\ MOD*

# Check if the current directory has system folder and setup.sh to verify that current directory is valid
if [ ! -d "files" ] || [ ! -f "customize.sh" ]; then
	echo "Error: Current directory is not valid. Make sure that you are in the right directory and try again."
	exit 1
fi

version=$1
versionCode=$2

# Read version and versionCode from module.prop
if [ -z "$version" ]; then
    version=$(sed -n 's/version=\(.*\)/\1/p' module.prop)
fi

if [ -z "$versionCode" ]; then
    versionCode=$(grep versionCode module.prop | cut -d "=" -f2)
    versionCode=$((versionCode + 1))
fi

# Automatically update module.prop
sed -i "s/version=.*/version=$version/; s/versionCode=[0-9]*/versionCode=$versionCode/g" module.prop

# Create zip file
echo "> Creating zip file"
echo ""
zip_name="MIUI-Launcher-MOD-$version"                         # make the output look easier to read
rm -rf "$zip_name.zip"
zip -r -q "$zip_name.zip" . -x .git/\* autobuild.sh README.md # Ignore specified files and folders because they are not needed for the module
echo ""                                                       # make the output look easier to read
echo "> Done! You can find the module zip file in the current directory - '$(pwd)/$zip_name.zip'"

