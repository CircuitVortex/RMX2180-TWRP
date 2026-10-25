# TWRP for Realme C15 (RMX2180)

Device tree + GitHub Actions workflow to build TWRP recovery.

## Build on GitHub

1. Fork or upload this repo to your GitHub account.
2. Open **Actions** → **Build TWRP RMX2180** → **Run workflow**.
3. When it finishes, download the **TWRP-RMX2180** artifact (`recovery.img`).
4. Flash from Termux:

```bash
pkg install android-tools
adb reboot bootloader
fastboot flash recovery /sdcard/Download/recovery.img
fastboot reboot recovery
```

## Local build (PC/Linux)

```bash
repo init -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git -b twrp-11 --depth=1
repo sync -c -j$(nproc) --force-sync --no-clone-bundle --no-tags
mkdir -p device/realme
cp -a device/realme/RMX2180 <twrp-root>/device/realme/RMX2180
cd <twrp-root>
source build/envsetup.sh
lunch twrp_RMX2180-eng
mka recoveryimage -j$(nproc)
```

## Device

- Codename: RMX2180 (also RMX2185 / RMX2189 assert)
- SoC: MT6765 (Helio G35)
- Boot header v2
- Recovery partition: 102760448 bytes

## Notes

- Bootloader must be unlocked.
- FBE decrypt may need extra vendor keymaster blobs on some builds.
- If boot fails after flash, restore stock recovery and check vbmeta.
