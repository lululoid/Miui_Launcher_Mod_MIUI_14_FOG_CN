for dir in /system/priv-app/ /system/product/priv-app/; do
    launcher=$(find "$dir" -type f -iname "*miuihome*")
    launcher_dir=$(find "$dir" -type d -iname "*miuihome*")
    
    mkdir -p "$MODPATH$launcher_dir"
done
if [ -z "$launcher_dir" ]; then 
    abort "MIUI Launcher not found in your system"
fi

REPLACE="$launcher_dir"
SKIPUNZIP=1
SKIPMOUNT=false

for dir in /system/priv-app/ /system/product/priv-app/; do
    launcher=$(find "$dir" -type f -iname "miuihome*")
    launcher_dir=$(find "$dir" -type d -iname "miuihome*")
    
    mkdir -p "$MODPATH$launcher_dir"
done
~
if [ -z "$launcher_dir" ]; then 
    abort "MIUI Launcher not found in your system"
fi

_ui_print() {
    ui_print ""
    ui_print "$*"
}

install_files() {
    . "$MODPATH"/addon/install.sh
    ui_print "> Choose your MIUI Version:"
    ui_print "  Vol+ = MIUI 13 or 14 Android 12"
    ui_print "  Vol- = MIUI 14 Android 13 Xiaomi.eu based"

    if chooseport; then
        pm uninstall-system-updates com.miui.home

		install_error=$(pm install "$MODPATH/files/launcher/MiuiHome.apk" 2>&1 >/dev/null)

		if [ -n "$install_error" ]; then
			abort "> Installation aborted. Please Disable signature verification"
		fi
        ui_print "> MIUI launcher mod installed"
        mv "$MODPATH/files/launcher/MiuiHome.apk" "$MODPATH$launcher"
    else
        {
            ui_print "> MIUI 14 EU selected"
			mv "$MODPATH/files/launcher/MiuiHome.apk" "$MODPATH$launcher"
            mv "$MODPATH/files/launcher/MiuiHome.apk" "$MODPATH$launcher"
        }

    fi
    ui_print "> Is your device POCO?"
    ui_print "  Vol+ = Yes"
    ui_print "  Vol- = No"

    if chooseport; then
        _ui_print "> Deleting POCO Launcher and adding MIUIHome support."
        mkdir "$MODPATH"/system/product/overlay
        cp -rf "$MODPATH"/files/poco/Framework_resoverlay.apk "$MODPATH"/system/product/overlay
    else
        {
            ui_print "> Skipping..."
        }

    fi

}

cleanup() {
    rm -rf "$MODPATH"/addon 2>/dev/null
    rm -rf "$MODPATH"/files 2>/dev/null
    rm -f "$MODPATH"/install.sh 2>/dev/null
    ui_print "> Deleting package cache files"
    rm -rf /data/resource-cache/*
    rm -rf /data/system/package_cache/*
    rm -rf /cache/*
    rm -rf /data/dalvik-cache/*
    ui_print "> Launcher updates will be uninstalled..."
    ui_print "> Deleting old module (if it is installed)"
    touch /data/adb/modules/miui_launcher_mod/remove
}

run_install() {
    unzip -o "$ZIPFILE" -x 'META-INF/*' -d "$MODPATH" >&2
    ui_print "> Installing files"
    install_files
    sleep 1
    ui_print "> Cleaning up"
    cleanup
    sleep 1
    ui_print "> Removing any MIUI Launcher folder to avoid issues"
}

set_perm_recursive  "$MODPATH"  0  0  0755  0644

run_install
