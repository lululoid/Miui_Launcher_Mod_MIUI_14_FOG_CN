# shellcheck disable=SC2034,SC2086,SC3010
SKIPUNZIP=1
SKIPMOUNT=false
android=$(getprop ro.build.version.release)

ui_print "             Delivered with ❤ by "
sleep 0.5
ui_print " █▀▀ █▀▀█ █░░░█ ░▀░ █▀▀▄ ▀▀█ █▀▀ █▀▀█ █▀▀█"
ui_print " █▀▀ █▄▄▀ █▄█▄█ ▀█▀ █░░█ ▄▀░ █▀▀ █▄▄▀ █▄▀█"
ui_print " ▀▀▀ ▀░▀▀ ░▀░▀░ ▀▀▀ ▀░░▀ ▀▀▀ ▀▀▀ ▀░▀▀ █▄▄█"
ui_print " ==================:)====================="
sleep 0.5

log_it() {
	log=$(echo "$*" | tr -s " ")
	false && ui_print "  DEBUG: $log"
}

_ui_print() {
	ui_print ""
	ui_print "$*"
}

install_files() {
	ui_print " READ!!! "
	ui_print " Signature verification must be disabled"
	ui_print " mandatory for MIUI 14 users based on"
	ui_print " Android 13; otherwise, the module will"
	ui_print " not work. "

	# finding miui launcher
	set -- \
		/system/priv-app/ \
		/system/product/priv-app/

	for dir in "$@"; do
		launcher=$(find "$dir" -type f -iname "*miuihome*")
		launcher_dir=$(find "$dir" -type d -iname "*miuihome*")

		log_it "launcher: $launcher"
		log_it "launcher_dir: $launcher_dir"
		mkdir -p "$MODPATH$launcher_dir"
	done

	REPLACE="$launcher_dir"

	if [ -z "$launcher_dir" ]; then
		_ui_print "> Installing on non MIUI system?"

		if [ $android -eq 11 ] || [ $android -eq 12 ]; then
			REPLACE=/system/priv-app/aMiuiHome

			ui_print "> Android < 13 detected"
			cp -rf $MODPATH/files/launcher/MiuiHome.apk "$MODPATH$REPLACE"
		elif [ $android -eq 13 ]; then
			REPLACE=/system/product/priv-app/aMiuiHome

			ui_print "> Android 13 detected"
			cp -rf $MODPATH/files/launcher/MiuiHome.apk "$MODPATH$REPLACE"
		else
			_ui_print "> Version not supported. Please upgrade your system."
			abort " Aborting..."
		fi
	fi

	ui_print "> Uninstalling launcher updates.."
	pm uninstall-system-updates com.miui.home 1>/dev/null &&
		ui_print " Launcher updates uninstalled"
	installation=$(pm install "$MODPATH"/files/launcher/MiuiHome.apk)

	log_it "installation=$(pm install "$MODPATH"/files/launcher/MiuiHome.apk)"
	log_it "$(ls "$MODPATH"/files/launcher/)"

	[[ "$installation" != "Success" ]] &&
		abort "> Please Disable signature verification"

	mv "$MODPATH"/files/launcher/MiuiHome.apk "$MODPATH$launcher"
	[ "$installation" = "Success" ] &&
		ui_print "> Miui launcher installation success, you could check it out now."

	is_poco=$(find /system/product/overlay -type f -iname "Framework_resoverlay.apk")
	[ -n "$is_poco" ] && {
		_ui_print "> POCO detected"
		mkdir $MODPATH/system/product/overlay
		cp -rf $MODPATH/files/poco/Framework_resoverlay.apk $MODPATH/system/product/overlay
	}
}

set_monet() {
	[ $android -gt 11 ] && {
		ui_print " Do you want Monet colors?"
		ui_print "  Vol+ = Yes"
		ui_print "  Vol- = No"

		while true; do
			# shellcheck disable=SC2069
			timeout 0.25 /system/bin/getevent -lqc 1 2>&1 >"$TMPDIR"/events &
			sleep 0.1
			if (grep -q 'KEY_VOLUMEUP *DOWN' "$TMPDIR"/events); then
				mkdir -p "$MODPATH/system/product/overlay"
				cp -rf "$MODPATH/files/MonetMiuiHome.apk" "$MODPATH/system/product/overlay"
				ui_print "> Monet installed"
				break
			elif (grep -q 'KEY_VOLUMEDOWN *DOWN' "$TMPDIR"/events); then
				ui_print "> Monet is cool ynow?"
				break
			fi
		done
	}
}

set_permissions() {
	su -c pm grant com.miui.home android.permission.READ_MEDIA_IMAGES
	set_perm_recursive $MODPATH 0 0 0755 0644
}

cleanup() {
	rm -rf $MODPATH/files 2>/dev/null
	ui_print "> Deleting package cache files"
	# check if this is an update or first install
	{
		[ ! -d $NVBASE/modules/miui_launcher_mod ] && {
			rm -rf /data/resource-cache/*
			rm -rf /data/system/package_cache/*
			rm -rf /cache/*
			rm -rf /data/dalvik-cache/*
		}
	} || ui_print "> Cache cleanup skipped, no need to reboot."
	ui_print "> Deleting old module (if it is installed)"
	touch /data/adb/modules/miui_launcher_mod/remove
}

unzip -o $ZIPFILE -x 'META-INF/*' -d $MODPATH >&2
ui_print "> Installing files"
set_permissions
install_files
set_monet
sleep 1
cleanup
sleep 1
ui_print "> Removing any MIUI Launcher folder to avoid issues"
