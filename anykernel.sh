# AnyKernel3 Ramdisk Mod Script
# osm0sis @ xda-developers

# FusionX kernel custom installer by SenX

# Big thanks to these guys from whom i've taken ideas.
# @KaminariKo (FakeDreamer Kernel) and @sk113r (E404 kernel)

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

manual_install() {
  ui_print " ";
  ui_print "> UI Variant: MIUI/HyperOS (Vol +) || AOSP (Vol -) ";
  while true; do
    ev=$(getevent -lt 2>/dev/null | grep -m1 "KEY_VOLUME.*DOWN")
    case $ev in
      *KEY_VOLUMEUP*)
        ui_print "┌─────────────────────────────────┐";
        ui_print "│      MIUI/HyperOS Selected      │";
        ui_print "└─────────────────────────────────┘";
        ui_print "◉ Applying kernel for MIUI/HyperOS...";
        mv *-miui-dtbo.img $home/dtbo.img;
        rm -f *-aosp-dtbo.img;
        break 
        ;;
      *KEY_VOLUMEDOWN*)
        ui_print "┌─────────────────────────────────┐";
        ui_print "│        AOSP Selected            │";
        ui_print "└─────────────────────────────────┘";
        ui_print "◉ Applying kernel for AOSP-based ROMs...";
        mv *-aosp-dtbo.img $home/dtbo.img;
        rm -f *-miui-dtbo.img;
        break 
        ;;
    esac
  done
  ui_print " ";

  ui_print "> GPU Profile: Modified (Vol +) || Stock (Vol -) ";
  while true; do
    ev=$(getevent -lt 2>/dev/null | grep -m1 "KEY_VOLUME.*DOWN")
    case $ev in
      *KEY_VOLUMEUP*)
        ui_print "┌─────────────────────────────────┐";
        ui_print "│     Modified GPU Selected       │";
        ui_print "└─────────────────────────────────┘";
        ui_print " ";
        ui_print "> GPU Profile: OC+UV (Vol +) || UV Only (Vol -) ";
        while true; do
          ev=$(getevent -lt 2>/dev/null | grep -m1 "KEY_VOLUME.*DOWN")
          case $ev in
            *KEY_VOLUMEUP*)
              ui_print "◉ OC+UV GPU profile Setected (683-150MHz)...";
              GPU_PROFILE="ocuv"
              break;
              ;;
            *KEY_VOLUMEDOWN*)
              ui_print "◉ UV GPU profile Selectected...";
              GPU_PROFILE="uv"
              break;
              ;;
          esac
        done
        break;
        ;;
      *KEY_VOLUMEDOWN*)
        ui_print "┌─────────────────────────────────┐";
        ui_print "│      Stock GPU Selected         │";
        ui_print "└─────────────────────────────────┘";
        GPU_PROFILE="stock"
        break;
        ;;
    esac
  done
  ui_print " ";

  ui_print "> CPU Mode: Normal (Vol +) || Efficient (Vol -) ";
  while true; do
    ev=$(getevent -lt 2>/dev/null | grep -m1 "KEY_VOLUME.*DOWN")
    case $ev in
      *KEY_VOLUMEUP*)
        ui_print "┌─────────────────────────────────┐";
        ui_print "│     Normal CPU Mode Selected    │";
        ui_print "└─────────────────────────────────┘";
        ui_print " ";
        ui_print "> CPU Frequency: 3.2GHz (Vol +) || 2.8GHz (Vol -) ";
        while true; do
          ev=$(getevent -lt 2>/dev/null | grep -m1 "KEY_VOLUME.*DOWN")
          case $ev in
            *KEY_VOLUMEUP*)
              ui_print "◉ Maximum CPU selected - 3.2GHz";
              if [ "$GPU_PROFILE" = "ocuv" ]; then
                mv *-normal-dtb $home/dtb;
                rm -f *-slightuc-dtb *-effcpu-dtb *-normal-gpustk-dtb *-slightuc-gpustk-dtb *-effcpu-gpustk-dtb *-normal-uv-dtb *-slightuc-uv-dtb *-effcpu-uv-dtb;
              elif [ "$GPU_PROFILE" = "uv" ]; then
                mv *-normal-uv-dtb $home/dtb;
                rm -f *-normal-dtb *-slightuc-dtb *-effcpu-dtb *-normal-gpustk-dtb *-slightuc-gpustk-dtb *-effcpu-gpustk-dtb *-slightuc-uv-dtb *-effcpu-uv-dtb;
              else
                mv *-normal-gpustk-dtb $home/dtb;
                rm -f *-normal-dtb *-slightuc-dtb *-effcpu-dtb *-slightuc-gpustk-dtb *-effcpu-gpustk-dtb *-normal-uv-dtb *-slightuc-uv-dtb *-effcpu-uv-dtb;
              fi
              break 
              ;;
            *KEY_VOLUMEDOWN*)
              ui_print "◉ Balance CPU selected - 2.8GHz";
              if [ "$GPU_PROFILE" = "ocuv" ]; then
                mv *-slightuc-dtb $home/dtb;
                rm -f *-normal-dtb *-effcpu-dtb *-normal-gpustk-dtb *-slightuc-gpustk-dtb *-effcpu-gpustk-dtb *-normal-uv-dtb *-slightuc-uv-dtb *-effcpu-uv-dtb;
              elif [ "$GPU_PROFILE" = "uv" ]; then
                mv *-slightuc-uv-dtb $home/dtb;
                rm -f *-normal-dtb *-slightuc-dtb *-effcpu-dtb *-normal-gpustk-dtb *-slightuc-gpustk-dtb *-effcpu-gpustk-dtb *-normal-uv-dtb *-effcpu-uv-dtb;
              else
                mv *-slightuc-gpustk-dtb $home/dtb;
                rm -f *-normal-dtb *-slightuc-dtb *-effcpu-dtb *-normal-gpustk-dtb *-effcpu-gpustk-dtb *-normal-uv-dtb *-slightuc-uv-dtb *-effcpu-uv-dtb;
              fi
              break 
              ;;
          esac
        done
        break 
        ;;
      *KEY_VOLUMEDOWN*)
        ui_print "┌─────────────────────────────────┐";
        ui_print "│     Efficient Mode Enabled      │";
        ui_print "└─────────────────────────────────┘";
        ui_print "◉ Applying power-efficient CPU configuration (2.5GHz)...";
        if [ "$GPU_PROFILE" = "ocuv" ]; then
          mv *-effcpu-dtb $home/dtb;
          rm -f *-normal-dtb *-slightuc-dtb *-normal-gpustk-dtb *-slightuc-gpustk-dtb *-effcpu-gpustk-dtb *-normal-uv-dtb *-slightuc-uv-dtb *-effcpu-uv-dtb;
        elif [ "$GPU_PROFILE" = "uv" ]; then
          mv *-effcpu-uv-dtb $home/dtb;
          rm -f *-normal-dtb *-slightuc-dtb *-effcpu-dtb *-normal-gpustk-dtb *-slightuc-gpustk-dtb *-effcpu-gpustk-dtb *-normal-uv-dtb *-slightuc-uv-dtb;
        else
          mv *-effcpu-gpustk-dtb $home/dtb;
          rm -f *-normal-dtb *-slightuc-dtb *-effcpu-dtb *-normal-gpustk-dtb *-slightuc-gpustk-dtb *-normal-uv-dtb *-slightuc-uv-dtb *-effcpu-uv-dtb;
        fi
        break;
        ;;
    esac
  done
}

auto_install() {
  ui_print " ";
  case "$ZIPFILE" in
    *miui*|*MIUI*)
      ui_print "┌─────────────────────────────────┐";
      ui_print "│    MIUI/HyperOS ROM Detected    │";
      ui_print "└─────────────────────────────────┘";
      ui_print "◉ Applying kernel for MIUI/HyperOS...";
      mv *-miui-dtbo.img $home/dtbo.img;
      rm -f *-aosp-dtbo.img;
      ;;
    *aosp*|*AOSP*)
      ui_print "┌─────────────────────────────────┐";
      ui_print "│       AOSP ROM Detected         │";
      ui_print "└─────────────────────────────────┘";
      ui_print "◉ Applying kernel for AOSP...";
      mv *-aosp-dtbo.img $home/dtbo.img;
      rm -f *-miui-dtbo.img;
      ;;
    *)
      ui_print "┌─────────────────────────────────┐";
      ui_print "│  No Specific Variant Detected!! │";
      ui_print "└─────────────────────────────────┘";
      ui_print "◉ Applying default AOSP configuration...";
      mv *-aosp-dtbo.img $home/dtbo.img;
      rm -f *-miui-dtbo.img;
      ;;
  esac
  ui_print " ";

  GPU_PROFILE="stock"
  case "$ZIPFILE" in
    *ocuv*|*OCUV*)
      GPU_PROFILE="ocuv"
      ui_print "◉ OC+UV GPU profile detected (683-150MHz)...";
      ;;
    *uv*|*UV*)
      GPU_PROFILE="uv"
      ui_print "◉ UV GPU profile detected...";
      ;;
    *)
      ui_print "◉ Using default stock GPU profile...";
      ;;
  esac
  ui_print " ";

  case "$ZIPFILE" in
    *eff*|*EFF*)
      ui_print "┌─────────────────────────────────┐";
      ui_print "│     Efficient CPU - 2.5GHz      │";
      ui_print "└─────────────────────────────────┘";
      ui_print "◉ Applying power-efficient CPU frequency...";
      if [ "$GPU_PROFILE" = "ocuv" ]; then
        mv *-effcpu-dtb $home/dtb;
        rm -f *-normal-dtb *-slightuc-dtb *-normal-gpustk-dtb *-slightuc-gpustk-dtb *-effcpu-gpustk-dtb *-normal-uv-dtb *-slightuc-uv-dtb *-effcpu-uv-dtb;
      elif [ "$GPU_PROFILE" = "uv" ]; then
        mv *-effcpu-uv-dtb $home/dtb;
        rm -f *-normal-dtb *-slightuc-dtb *-effcpu-dtb *-normal-gpustk-dtb *-slightuc-gpustk-dtb *-effcpu-gpustk-dtb *-normal-uv-dtb *-slightuc-uv-dtb;
      else
        mv *-effcpu-gpustk-dtb $home/dtb;
        rm -f *-normal-dtb *-slightuc-dtb *-effcpu-dtb *-normal-gpustk-dtb *-slightuc-gpustk-dtb *-normal-uv-dtb *-slightuc-uv-dtb *-effcpu-uv-dtb;
      fi
      ;;
    *bal*|*BAL*)
      ui_print "┌─────────────────────────────────┐";
      ui_print "│     Balance CPU - 2.8GHz        │";
      ui_print "└─────────────────────────────────┘";
      ui_print "◉ Applying balanced CPU frequency...";
      if [ "$GPU_PROFILE" = "ocuv" ]; then
        mv *-slightuc-dtb $home/dtb;
        rm -f *-normal-dtb *-effcpu-dtb *-normal-gpustk-dtb *-slightuc-gpustk-dtb *-effcpu-gpustk-dtb *-normal-uv-dtb *-slightuc-uv-dtb *-effcpu-uv-dtb;
      elif [ "$GPU_PROFILE" = "uv" ]; then
        mv *-slightuc-uv-dtb $home/dtb;
        rm -f *-normal-dtb *-slightuc-dtb *-effcpu-dtb *-normal-gpustk-dtb *-slightuc-gpustk-dtb *-effcpu-gpustk-dtb *-normal-uv-dtb *-effcpu-uv-dtb;
      else
        mv *-slightuc-gpustk-dtb $home/dtb;
        rm -f *-normal-dtb *-slightuc-dtb *-effcpu-dtb *-normal-gpustk-dtb *-effcpu-gpustk-dtb *-normal-uv-dtb *-slightuc-uv-dtb *-effcpu-uv-dtb;
      fi
      ;;
    *)
      ui_print "┌─────────────────────────────────┐";
      ui_print "│        Max CPU - 3.2GHz         │";
      ui_print "└─────────────────────────────────┘";
      ui_print "◉ Applying maximum CPU frequency...";
      if [ "$GPU_PROFILE" = "ocuv" ]; then
        mv *-normal-dtb $home/dtb;
        rm -f *-slightuc-dtb *-effcpu-dtb *-normal-gpustk-dtb *-slightuc-gpustk-dtb *-effcpu-gpustk-dtb *-normal-uv-dtb *-slightuc-uv-dtb *-effcpu-uv-dtb;
      elif [ "$GPU_PROFILE" = "uv" ]; then
        mv *-normal-uv-dtb $home/dtb;
        rm -f *-normal-dtb *-slightuc-dtb *-effcpu-dtb *-normal-gpustk-dtb *-slightuc-gpustk-dtb *-effcpu-gpustk-dtb *-slightuc-uv-dtb *-effcpu-uv-dtb;
      else
        mv *-normal-gpustk-dtb $home/dtb;
        rm -f *-normal-dtb *-slightuc-dtb *-effcpu-dtb *-slightuc-gpustk-dtb *-effcpu-gpustk-dtb *-normal-uv-dtb *-slightuc-uv-dtb *-effcpu-uv-dtb;
      fi
      ;;
  esac
}

process_fusionx_file() {
  FUSIONX_FILE=$(find . -type f -name "*.fusionX" | head -n 1)

  if [ -n "$FUSIONX_FILE" ]; then
    ui_print "Detected .fusionX file: $FUSIONX_FILE"
    ui_print " ";
    
    FILE_NAME=$(basename "$FUSIONX_FILE")
    FILE_NAME_NO_EXT=$(echo "$FILE_NAME" | sed 's/\.fusionX$//')
    
    UI_VARIANT=$(echo "$FILE_NAME_NO_EXT" | cut -d'-' -f1)  
    CPU_VARIANT=$(echo "$FILE_NAME_NO_EXT" | cut -d'-' -f2)  
    GPU_VARIANT=$(echo "$FILE_NAME_NO_EXT" | cut -d'-' -f3)
    
    if [ -z "$UI_VARIANT" ] || [ -z "$CPU_VARIANT" ] || [ -z "$GPU_VARIANT" ]; then
      ui_print "┌─────────────────────────────────┐";
      ui_print "│         FORMAT ERROR!           │";
      ui_print "└─────────────────────────────────┘";
      ui_print "Invalid .fusionX filename format!";
      ui_print "Required format: [ui]-[cpu]-[gpu].fusionX";
      abort "ERROR: Invalid .fusionX format! Use: [ui]-[cpu]-[gpu].fusionX";
    fi
    
    case "$UI_VARIANT" in
      miui|aosp) ;;
      *)
        ui_print "┌─────────────────────────────────┐";
        ui_print "│       INVALID UI VARIANT!       │";
        ui_print "└─────────────────────────────────┘";
        ui_print "UI variant '$UI_VARIANT' is not supported!";
        ui_print "Supported UI variants: miui, aosp";
        abort "ERROR: Invalid UI variant '$UI_VARIANT'! Use 'miui' or 'aosp'";
        ;;
    esac
    
    case "$CPU_VARIANT" in
      max|bal|eff) ;;
      *)
        ui_print "┌─────────────────────────────────┐";
        ui_print "│      INVALID CPU VARIANT!       │";
        ui_print "└─────────────────────────────────┘";
        ui_print "CPU variant '$CPU_VARIANT' is not supported!";
        ui_print "Supported CPU variants: max, bal, eff";
        abort "ERROR: Invalid CPU variant '$CPU_VARIANT'! Use 'max', 'bal', or 'eff'";
        ;;
    esac
    
    case "$GPU_VARIANT" in
      stock|ocuv|uv) ;;
      *)
        ui_print "┌─────────────────────────────────┐";
        ui_print "│      INVALID GPU VARIANT!       │";
        ui_print "└─────────────────────────────────┘";
        ui_print "GPU variant '$GPU_VARIANT' is not supported!";
        ui_print "Supported GPU variants: stock, ocuv, uv";
        abort "ERROR: Invalid GPU variant '$GPU_VARIANT'! Use 'stock', 'ocuv', or 'uv'";
        ;;
    esac
    
    ui_print "ROM Variant: $UI_VARIANT"
    ui_print "CPU Variant: $CPU_VARIANT"
    ui_print "GPU Variant: $GPU_VARIANT"
    ui_print " ";

    case "$UI_VARIANT" in
      miui)
        ui_print "┌─────────────────────────────────┐";
        ui_print "│    MIUI/HyperOS ROM Detected    │";
        ui_print "└─────────────────────────────────┘";
        ui_print "◉ Applying kernel for MIUI/HyperOS...";
        mv *-miui-dtbo.img $home/dtbo.img;
        rm -f *-aosp-dtbo.img;
        ;;
      aosp)
        ui_print "┌─────────────────────────────────┐";
        ui_print "│       AOSP ROM Detected         │";
        ui_print "└─────────────────────────────────┘";
        ui_print "◉ Applying kernel for AOSP...";
        mv *-aosp-dtbo.img $home/dtbo.img;
        rm -f *-miui-dtbo.img;
        ;;
    esac
    ui_print " ";

    if [ "$CPU_VARIANT" = "eff" ]; then
      if [ "$GPU_VARIANT" = "ocuv" ]; then
        ui_print "┌─────────────────────────────────┐";
        ui_print "│  Efficient CPU + OCUV - 2.5GHz  │";
        ui_print "└─────────────────────────────────┘";
        ui_print "◉ Applying efficient CPU + OC+UV GPU...";
        mv *-effcpu-dtb $home/dtb;
        rm -f *-normal-dtb *-slightuc-dtb *-normal-gpustk-dtb *-slightuc-gpustk-dtb *-effcpu-gpustk-dtb *-normal-uv-dtb *-slightuc-uv-dtb *-effcpu-uv-dtb;
      elif [ "$GPU_VARIANT" = "uv" ]; then
        ui_print "┌─────────────────────────────────┐";
        ui_print "│    Efficient CPU + UV - 2.5GHz  │";
        ui_print "└─────────────────────────────────┘";
        ui_print "◉ Applying efficient CPU + UV GPU...";
        mv *-effcpu-uv-dtb $home/dtb;
        rm -f *-normal-dtb *-slightuc-dtb *-effcpu-dtb *-normal-gpustk-dtb *-slightuc-gpustk-dtb *-effcpu-gpustk-dtb *-normal-uv-dtb *-slightuc-uv-dtb;
      else
        ui_print "┌─────────────────────────────────┐";
        ui_print "│   Efficient CPU Mode - 2.5GHz   │";
        ui_print "└─────────────────────────────────┘";
        ui_print "◉ Applying efficient CPU + stock GPU...";
        mv *-effcpu-gpustk-dtb $home/dtb;
        rm -f *-normal-dtb *-slightuc-dtb *-effcpu-dtb *-normal-gpustk-dtb *-slightuc-gpustk-dtb *-normal-uv-dtb *-slightuc-uv-dtb *-effcpu-uv-dtb;
      fi
    elif [ "$CPU_VARIANT" = "bal" ]; then
      if [ "$GPU_VARIANT" = "ocuv" ]; then
        ui_print "┌─────────────────────────────────┐";
        ui_print "│   Balance CPU + OCUV - 2.8GHz   │";
        ui_print "└─────────────────────────────────┘";
        ui_print "◉ Applying balanced CPU + OC+UV GPU...";
        mv *-slightuc-dtb $home/dtb;
        rm -f *-normal-dtb *-effcpu-dtb *-normal-gpustk-dtb *-slightuc-gpustk-dtb *-effcpu-gpustk-dtb *-normal-uv-dtb *-slightuc-uv-dtb *-effcpu-uv-dtb;
      elif [ "$GPU_VARIANT" = "uv" ]; then
        ui_print "┌─────────────────────────────────┐";
        ui_print "│     Balance CPU + UV - 2.8GHz   │";
        ui_print "└─────────────────────────────────┘";
        ui_print "◉ Applying balanced CPU + UV GPU...";
        mv *-slightuc-uv-dtb $home/dtb;
        rm -f *-normal-dtb *-slightuc-dtb *-effcpu-dtb *-normal-gpustk-dtb *-slightuc-gpustk-dtb *-effcpu-gpustk-dtb *-normal-uv-dtb *-effcpu-uv-dtb;
      else
        ui_print "┌─────────────────────────────────┐";
        ui_print "│    Balance CPU Mode - 2.8GHz    │";
        ui_print "└─────────────────────────────────┘";
        ui_print "◉ Applying balanced CPU + stock GPU...";
        mv *-slightuc-gpustk-dtb $home/dtb;
        rm -f *-normal-dtb *-slightuc-dtb *-effcpu-dtb *-normal-gpustk-dtb *-effcpu-gpustk-dtb *-normal-uv-dtb *-slightuc-uv-dtb *-effcpu-uv-dtb;
      fi
    elif [ "$CPU_VARIANT" = "max" ]; then
      if [ "$GPU_VARIANT" = "ocuv" ]; then
        ui_print "┌─────────────────────────────────┐";
        ui_print "│      Max CPU + OCUV - 3.2GHz    │";
        ui_print "└─────────────────────────────────┘";
        ui_print "◉ Applying maximum CPU + OC+UV GPU...";
        mv *-normal-dtb $home/dtb;
        rm -f *-slightuc-dtb *-effcpu-dtb *-normal-gpustk-dtb *-slightuc-gpustk-dtb *-effcpu-gpustk-dtb *-normal-uv-dtb *-slightuc-uv-dtb *-effcpu-uv-dtb;
      elif [ "$GPU_VARIANT" = "uv" ]; then
        ui_print "┌─────────────────────────────────┐";
        ui_print "│       Max CPU + UV - 3.2GHz     │";
        ui_print "└─────────────────────────────────┘";
        ui_print "◉ Applying maximum CPU + UV GPU...";
        mv *-normal-uv-dtb $home/dtb;
        rm -f *-normal-dtb *-slightuc-dtb *-effcpu-dtb *-normal-gpustk-dtb *-slightuc-gpustk-dtb *-effcpu-gpustk-dtb *-slightuc-uv-dtb *-effcpu-uv-dtb;
      else
        ui_print "┌─────────────────────────────────┐";
        ui_print "│        Max CPU - 3.2GHz         │";
        ui_print "└─────────────────────────────────┘";
        ui_print "◉ Applying maximum CPU + stock GPU...";
        mv *-normal-gpustk-dtb $home/dtb;
        rm -f *-normal-dtb *-slightuc-dtb *-effcpu-dtb *-slightuc-gpustk-dtb *-effcpu-gpustk-dtb *-normal-uv-dtb *-slightuc-uv-dtb *-effcpu-uv-dtb;
      fi
    fi

    rm -f "$FUSIONX_FILE"
    return 0
  else
    ui_print "No configuration file found!!";
    return 1
  fi
}

ui_print "> Installation Mode: Manual (Vol +) || Auto (Vol -) ";

while true; do
  ev=$(getevent -lt 2>/dev/null | grep -m1 "KEY_VOLUME.*DOWN")
  case $ev in
    *KEY_VOLUMEUP*)
      ui_print "◉ Manual installation selected";
      INSTALL_METHOD="manual"
      break
      ;;
    *KEY_VOLUMEDOWN*)
      ui_print "◉ Automatic installation selected";
      INSTALL_METHOD="auto"
      break
      ;;
  esac
done

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

## vendor_boot shell variables
block=/dev/block/bootdevice/by-name/vendor_boot;
is_slot_device=1;
ramdisk_compression=auto;
patch_vbmeta_flag=auto;

reset_ak;

dump_boot;

write_boot;
## end vendor_boot install
