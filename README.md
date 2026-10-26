# TWRP for realme C15 (RMX2180) — rebuilt device tree

Unified, corrected TWRP device tree for the realme C15 (RMX2180 / MT6765 / Helio G35),
rebuilt by merging the reverse-engineered **v2 device tree** with the original
**RMX2180-TWRP GitHub tree**. Every correction made during the rebuild is listed in
[FIXES.md](FIXES.md).

## Device

| Item | Value |
|------|-------|
| Codename | RMX2180 (unified assert with RMX2185 / RMX2189) |
| SoC | MediaTek Helio G35 (MT6765) |
| Kernel | Prebuilt from stock boot.img — Linux 4.19.127+, clang 11.0.1 (May 2022) |
| Boot image | Header v2, page size 2048 |
| Recovery partition | 102,760,448 bytes (98 MiB) |
| Data crypto | FBE, fscrypt **v1** (`aes-256-xts:aes-256-cts:v1`), metadata on `md_udc` |
| Base | TWRP **twrp-11** (minimal-manifest-twrp, AOSP 11) |

## Build on GitHub (recommended)

The repo ships with a ready-to-run workflow (`.github/workflows/build-twrp.yml`):

1. Push this repository to your GitHub account.
2. Open **Actions** → **Build TWRP RMX2180** → **Run workflow**.
3. When it finishes, download the **TWRP-RMX2180** artifact (`recovery.img`).
4. Flash from Termux:

```bash
pkg install android-tools
adb reboot bootloader
fastboot flash recovery /sdcard/Download/recovery.img
fastboot reboot recovery
```

> If boot fails after flashing, restore stock recovery and boot a disabled-vbmeta
> image: `fastboot flash vbmeta vbmeta.img --disable-verity --disable-verification`

## Local build (PC/Linux)

```bash
repo init -u https://github.com/minimal-manifest-twrp/platform_manifest_twrp_aosp.git -b twrp-11 --depth=1
repo sync -c -j$(nproc) --force-sync --no-clone-bundle --no-tags
mkdir -p device/realme
cp -a /path/to/RMX2180-TWRP/device/realme/RMX2180 device/realme/RMX2180
source build/envsetup.sh
lunch twrp_RMX2180-eng
mka recoveryimage -j$(nproc)
```

Output: `out/target/product/RMX2180/recovery.img`

## Repository layout

```
RMX2180-TWRP/
├── .github/workflows/build-twrp.yml   ← GitHub Actions build (twrp-11)
├── README.md
├── FIXES.md                           ← full changelog of the rebuild
└── device/realme/RMX2180/
    ├── AndroidProducts.mk             ← lunch choices: twrp_RMX2180-eng/-userdebug
    ├── Android.mk
    ├── BoardConfig.mk                 ← merged + corrected boot.img values
    ├── device.mk                      ← fastbootd + FBE decrypt modules
    ├── twrp_RMX2180.mk                ← product config (inherits device.mk)
    ├── recovery.fstab                 ← stock-derived (md_udc metadata, ext4, fscrypt v1)
    ├── system.prop
    └── prebuilt/
        ├── Image.gz                   ← stock kernel 4.19.127+ (verified)
        ├── dtb/mt6765.dtb             ← valid FDT magic 0xd00dfeed
        └── dtbo.img                   ← 3 overlay variants (Egis/Oplus FP boards)
```

## Notes

- Bootloader must be unlocked.
- FBE decrypt is best-effort: if `/data` stays encrypted, additional vendor
  keymaster blobs may be required on some builds.
- The original `device_realme_RMX2180_v2` tree was a **full-ROM** tree; only its
  verified hardware values were carried over here. Do not try to `mka bacon`
  from this tree — it builds `recovery.img` only.
