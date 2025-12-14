# AnyKernel3 Ramdisk Mod Script
# osm0sis @ xda-developers

# FusionX kernel custom installer by SenX

## AnyKernel setup
# begin properties
properties() { '
do.devicecheck=1
do.modules=0
do.systemless=1
do.cleanup=1
do.cleanuponabort=0
device.name1=munch
device.name2=munchin
device.name3=
device.name4=
device.name5=
supported.versions=
'; } # end properties

# shell variables
block=/dev/block/bootdevice/by-name/boot;
is_slot_device=1;
ramdisk_compression=auto;

## AnyKernel methods (DO NOT CHANGE)
# import patching functions/variables - see for reference
. tools/ak3-core.sh;

## AnyKernel file attributes
# set permissions/ownership for included ramdisk files
set_perm_recursive 0 0 750 750 $ramdisk/*;

if { [ "$(basename "$ZIPFILE")" = "update.zip" ] || [ "$(basename "$ZIPFILE")" = "package.zip" ]; }; then
  SIDELOAD=1;
  ui_print "Sideload installation detected";
  ui_print " ";
else
  SIDELOAD=0;
fi;

# Function to get volume key with timeout
get_key_with_timeout() {
  local timeout=$1
  local start_time=$(date +%s)
  local end_time=$((start_time + timeout))
  local last_display=$start_time
  
  ui_print "◉ Auto-selecting in $timeout seconds..."
  
  while true; do
    local current_time=$(date +%s)
    local remaining=$((end_time - current_time))
    
    if [ $remaining -le 0 ]; then
      echo "TIMEOUT"
      return 1
    fi
    
    if [ $current_time -gt $last_display ]; then
      ui_print "◉ Auto-selecting in $remaining seconds..."
      last_display=$current_time
    fi
    
    local ev=$(timeout 0.5 getevent -lc 1 2>/dev/null | grep "KEY_VOLUME.*DOWN")
    
    case $ev in
      *KEY_VOLUMEUP*DOWN*) echo "UP"; return 0 ;;
      *KEY_VOLUMEDOWN*DOWN*) echo "DOWN"; return 0 ;;
    esac
    sleep 0.1
  done
}

manual_install() {
  ui_print " ";
  ui_print "> CPU Mode: Normal (Vol +) || Efficient (Vol -) ";
  while true; do
    ev=$(getevent -lt 2>/dev/null | grep -m1 "KEY_VOLUME.*DOWN")
    case $ev in
      *KEY_VOLUMEUP*)
        ui_print "┌─────────────────────────────────┐";
        ui_print "│      Normal CPU Mode Selected   │";
        ui_print "└─────────────────────────────────┘";
        ui_print "> CPU Frequency: 3.2GHz (Vol +) || 2.8GHz (Vol -) ";
        while true; do
          ev=$(getevent -lt 2>/dev/null | grep -m1 "KEY_VOLUME.*DOWN")
          case $ev in
            *KEY_VOLUMEUP*)
              ui_print "◉ Maximum CPU selected - 3.2GHz (Stock)";
              mv dtbs/stock/dtb.img $home/dtb;
              rm -rf dtbs/;
              break 
              ;;
            *KEY_VOLUMEDOWN*)
              ui_print "◉ Balance CPU selected - 2.8GHz (Slight)";
              mv dtbs/slight/dtb.img $home/dtb;
              rm -rf dtbs/;
              break 
              ;;
          esac
        done
        break 
        ;;
      *KEY_VOLUMEDOWN*)
        ui_print "┌─────────────────────────────────┐";
        ui_print "│      Efficient Mode Enabled     │";
        ui_print "└─────────────────────────────────┘";
        ui_print "◉ Applying power-efficient CPU configuration (2.5GHz)...";
        mv dtbs/efficiency/dtb.img $home/dtb;
        rm -rf dtbs/;
        break;
        ;;
    esac
  done
}

auto_install() {
  ui_print " ";
  
  case "$ZIPFILE" in
    *eff*|*EFF*)
      ui_print "┌─────────────────────────────────┐";
      ui_print "│      Efficient CPU - 2.5GHz     │";
      ui_print "└─────────────────────────────────┘";
      ui_print "◉ Applying power-efficient CPU frequency...";
      mv dtbs/efficiency/dtb.img $home/dtb;
      rm -rf dtbs/;
      ;;
    *bal*|*BAL*|*swift*|*SWIFT*|*slight*|*SLIGHT*)
      ui_print "┌─────────────────────────────────┐";
      ui_print "│      Balance CPU - 2.8GHz       │";
      ui_print "└─────────────────────────────────┘";
      ui_print "◉ Applying balanced (slight) CPU frequency...";
      mv dtbs/slight/dtb.img $home/dtb;
      rm -rf dtbs/;
      ;;
    *)
      ui_print "┌─────────────────────────────────┐";
      ui_print "│        Max CPU - 3.2GHz         │";
      ui_print "└─────────────────────────────────┘";
      ui_print "◉ Applying maximum (stock) CPU frequency...";
      mv dtbs/stock/dtb.img $home/dtb;
      rm -rf dtbs/;
      ;;
  esac
}

process_fusionx_file() {
  FUSIONX_FILE=$(find . -type f -name "*.fusionX" | head -n 1)

  if [ -n "$FUSIONX_FILE" ]; then
    ui_print "Detected .fusionX file: $FUSIONX_FILE"
    
    FILE_NAME=$(basename "$FUSIONX_FILE")
    FILE_NAME_NO_EXT=$(echo "$FILE_NAME" | sed 's/\.fusionX$//')

    case "$FILE_NAME_NO_EXT" in
      *eff*|*EFF*)
        ui_print "◉ Config: Efficient CPU...";
        mv dtbs/efficiency/dtb.img $home/dtb;
        rm -rf dtbs/;
        ;;
      *bal*|*BAL*|*swift*|*slight*)
        ui_print "◉ Config: Balanced CPU...";
        mv dtbs/slight/dtb.img $home/dtb;
        rm -rf dtbs/;
        ;;
      *)
        ui_print "◉ Config: Defaulting to Max CPU...";
        mv dtbs/stock/dtb.img $home/dtb;
        rm -rf dtbs/;
        ;;
    esac

    rm -f "$FUSIONX_FILE"
    return 0
  else
    return 1
  fi
}

ui_print "> Installation Mode: Manual (Vol +) || Auto (Vol -) ";

KEY_RESULT=$(get_key_with_timeout 5)

case "$KEY_RESULT" in
  "UP")
    ui_print "◉ Manual installation selected";
    INSTALL_METHOD="manual"
    ;;
  "DOWN")
    ui_print "◉ Automatic installation selected";
    INSTALL_METHOD="auto"
    ;;
  "TIMEOUT")
    ui_print "┌─────────────────────────────────┐";
    ui_print "│  No Input - Defaulting to Auto  │";
    ui_print "└─────────────────────────────────┘";
    INSTALL_METHOD="auto"
    ;;
esac
ui_print " ";

if [ "$INSTALL_METHOD" = "manual" ]; then
  manual_install
elif [ "$INSTALL_METHOD" = "auto" ]; then
  if [ "$SIDELOAD" = "1" ] && process_fusionx_file; then
    ui_print "Using configuration from fusionX file";
  else
    auto_install
  fi
fi

if [ ! -f /vendor/etc/task_profiles.json ] && [ ! -f /system/vendor/etc/task_profiles.json ]; then
  ui_print " ";
  ui_print "Notice: Task profiles not found on your ROM";
  ui_print "Consider installing Uclamp task profiles module for optimal performance";
  ui_print "You can ignore this message if already installed";
  ui_print " ";
fi;

## AnyKernel install
dump_boot;

if [ -d $ramdisk/overlay ]; then
  rm -rf $ramdisk/overlay;
fi;

write_boot;
## end install
