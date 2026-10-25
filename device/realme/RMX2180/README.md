# TWRP device tree — Realme C15 (RMX2180)

Platform: MT6765 (Helio G35) / oppo6765  
Header: Android boot v2  
Recovery size: 102760448 bytes  

## Prebuilt blobs (already extracted)

- `prebuilt/Image.gz` — kernel from stock boot.img  
- `prebuilt/dtbo.img` — from stock recovery.img  
- `prebuilt/dtb/mt6765.dtb` — from stock boot.img  

## Build (on a machine with TWRP source)

```bash
# Sync minimal TWRP (example)
repo init -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git -b twrp-11
repo sync -j$(nproc)

# Place this tree
mkdir -p device/realme
cp -a rmx2180_device_tree device/realme/RMX2180

# Build
. build/envsetup.sh
lunch twrp_RMX2180-eng
mka recoveryimage -j$(nproc)
```

Output: `out/target/product/RMX2180/recovery.img`

## Flash (unlocked bootloader)

```bash
fastboot flash recovery recovery.img
fastboot boot recovery.img   # test without permanent flash
```

## Notes / known issues

- FBE decryption may need device-specific keymaster blobs from stock `vendor`
- If boot loops after flash, restore stock recovery and check vbmeta (`--disable-verity --disable-verification`)
- Unified assert includes RMX2185 / RMX2189 family
