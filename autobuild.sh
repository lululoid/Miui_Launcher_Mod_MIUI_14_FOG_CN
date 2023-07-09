#!/usr/bin/bash
# Check for the package manager to use

apps=(zip figlet)
rapps=()
# pkg should be first to anticipate termux
p_managers=( "pkg" "apt" "yum" "dnf" "pacman" "zypper")

for app in "${apps[@]}"; do
  rapp=$(command -v "$app" >/dev/null || which "$app" >/dev/null )

	if [ -n "$rapp" ]; then
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
			sudo "$pm" install "${rapps[@]}"
			break
		fi
	done
fi

# It's figlet time
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
# Read version and versionCode from module.prop and automatically update module.prop
if [ -z "$version" ]; then
    version=$(sed -n 's/version=\(.*\)/\1/p' module.prop)
fi

if [ -z "$versionCode" ]; then
    versionCode=$(grep versionCode module.prop | cut -d "=" -f2)
    versionCode=$((versionCode + 1))
fi

sed -i "s/version=.*/version=$version/; s/versionCode=[0-9]*/versionCode=$versionCode/g" module.prop

# Create zip file
echo "> Creating zip file"
zip_name="MIUI-Launcher-MOD-$version" 
rm -rf "$zip_name.zip"                # remove previous module
zip -r -q "$zip_name.zip" . -x .git/\* autobuild.sh README.md # Ignore specified files and folders because they are not needed for the module
echo "> Done! You can find the module zip file in the current directory - '$(pwd)/$zip_name.zip'"

