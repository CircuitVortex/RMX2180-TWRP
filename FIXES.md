# FIXES.md — changelog of the RMX2180 device tree rebuild

This tree was rebuilt from two sources:

- **`RMX2180-TWRP-github`** — the original TWRP tree (complete, but with a stale fstab and a missing workflow)
- **`device_realme_RMX2180_v2`** — a full-ROM tree with correct, reverse-engineered values, but many broken references

The result is a single **TWRP-only** tree pinned to **twrp-11**. Below is every correction made.

---

## 1. Build-breaking fixes

| # | Problem | Fix |
|---|---------|-----|
| 1 | v2 `BoardConfig.mk` pointed to `prebuilt/kernel` and `prebuilt/dtb.img` — **files that do not exist** in either archive | Unified to `prebuilt/Image.gz` + `BOARD_PREBUILT_DTBIMAGE_DIR := prebuilt/dtb` (both exist and verified) |
| 2 | v2 set `BOARD_INCLUDE_DTB_IN_BOOTIMG :=` (empty) and appended `--dtb $(TARGET_PREBUILT_DTB)` to `BOARD_MKBOOTIMG_ARGS` — a mkbootimg argument that does not exist in AOSP 11 | Removed both; dtb is now included via `BOARD_INCLUDE_DTB_IN_BOOTIMG := true` + `BOARD_PREBUILT_DTBIMAGE_DIR` (standard AOSP 11 path) |
| 3 | v2 referenced `TARGET_FS_CONFIG_GEN := config.fs` — **missing file** | Dropped (recovery-only tree does not need fs_config) |
| 4 | v2 referenced `BOARD_SEPOLICY_DIRS += sepolicy/vendor` — **missing directory** | Dropped; TWRP builds with its own permissive-friendly policy |
| 5 | v2 `device.mk` copied `configs/wifi/p2p_supplicant_overlay.conf` and `wpa_supplicant_overlay.conf` — **missing files** | Dropped along with all full-ROM HAL packages |
| 6 | v2 `device.mk` inherited `vendor/realme/RMX2180/RMX2180-vendor.mk` — **no vendor tree exists** | Dropped |
| 7 | v2 had **no `AndroidProducts.mk`**, so `realme_RMX2180.mk` was unreachable (and it was a full-ROM product anyway) | Rebuilt tree uses the TWRP-only `AndroidProducts.mk` with `twrp_RMX2180-eng` / `-userdebug` |
| 8 | Original `twrp_RMX2180.mk` **never inherited `device.mk`** — the file existed but its fastbootd/keymaster/fstab config was duplicated inline, making `device.mk` orphaned | `twrp_RMX2180.mk` now inherits `device.mk`; shared config lives in one place |
| 9 | Original `Android.mk` used `all-subdir-makefiles` (deprecated pattern) | Switched to `all-makefiles-under` |
| 10 | Original repo README documented a GitHub Actions build, but **no workflow file existed** | Added `.github/workflows/build-twrp.yml` (repo sync → `lunch twrp_RMX2180-eng` → `mka recoveryimage` → artifact upload) |

## 2. Boot image / kernel corrections

| # | Problem | Fix |
|---|---------|-----|
| 11 | v2 offsets were arithmetically inconsistent with the real boot.img header: `BOARD_RAMDISK_OFFSET := 0x11b00000` and `BOARD_KERNEL_TAGS_OFFSET := 0x47808000` (with no `--base` passed) do **not** reproduce the documented load addresses (ramdisk `0x51B00000`, tags `0x47880000`) | Restored the consistent set: base `0x40078000`, ramdisk offset `0x11a88000`, tags offset `0x07808000`, second offset `0xbff88000` — all sum to the real header addresses |
| 12 | v2 defined `TARGET_KERNEL_SOURCE`/`TARGET_KERNEL_CONFIG` (no kernel source exists anywhere) | Removed; prebuilt-only configuration |
| 13 | Manual `BOARD_MKBOOTIMG_ARGS` duplicated what AOSP 11's build system auto-generates from `BOARD_KERNEL_*` vars | Only `--header_version` kept explicitly |
| 14 | Prebuilt binaries verified before adoption: `Image.gz` decompresses to kernel `4.19.127+` (clang 11.0.1, May 9 2022 — matches RE notes); `mt6765.dtb` and `dtbo.img` carry valid FDT magic `0xd00dfeed` | Kept as-is |

## 3. Partition / fstab corrections

| # | Problem | Fix |
|---|---------|-----|
| 15 | Recovery partition size conflict: v2 said 33,554,432 (32 MiB), original said 102,760,448 (98 MiB) | **102,760,448** (user-confirmed real partition size; 98 MiB = 784 × 128 KiB flash blocks) |
| 16 | Metadata partition naming: original fstab used `/dev/block/by-name/metadata`; stock ramdisk fstab (v2) uses **`md_udc`** (OPPO/realme naming) | `recovery.fstab` rebuilt from the stock-derived fstab: `/dev/block/platform/bootdevice/by-name/md_udc` |
| 17 | Original recovery.fstab claimed userdata was **f2fs with fscrypt v2** — contradicts the actual stock ramdisk fstab (v2), which says **ext4 with fscrypt v1** | Userdata is now `ext4` + `fileencryption=aes-256-xts:aes-256-cts:v1`, matching `TW_USE_FSCRYPT_POLICY := 1` |
| 18 | Stock fstab flags unsuitable for TWRP: `inlinecrypt`, `checkpoint=block`, AVB key references, GSI `avb_keys` | Removed from the recovery fstab |
| 19 | Added missing mount points from the stock fstab: `cache` (452,984,832 B), `protect1/2`, `nvdata`, `nvcfg`, `persist`, and all raw partitions (`tee`, `scp`, `sspm`, `md1*`, `gz`, `spmfw`, `odmdtbo`, `logo`, …) for backup/inspection | Included |
| 20 | Original `BoardConfig` set `BOARD_USERDATAIMAGE_FILE_SYSTEM_TYPE := f2fs` | Corrected to `ext4` (f2fs support stays enabled via `TARGET_USERIMAGES_USE_F2FS` for formatting) |
| 21 | Original super group listed `system_ext` but had no `BOARD_SYSTEM_EXTIMAGE_FILE_SYSTEM_TYPE` | Added ext4 type (and odm) |

## 4. BoardConfig / TWRP option corrections

| # | Problem | Fix |
|---|---------|-----|
| 22 | `TARGET_USES_UEFI := true` (original tree) — meaningless on MediaTek | Removed |
| 23 | Contradictory flags: `TW_SCREEN_BLANK_ON_BOOT := true` **and** `TW_NO_SCREEN_BLANK := true` set together | Kept `TW_NO_SCREEN_BLANK := true` only |
| 24 | `TARGET_BOOTLOADER_BOARD_NAME` disagreed across trees (`oppo6765` vs `mt6765`) | Unified to `mt6765` |
| 25 | No explicit A/B declaration | Added `AB_OTA_UPDATER := false` (dedicated recovery partition device) |
| 26 | v2 `TARGET_CPU_VARIANT := generic` + `RUNTIME cortex-a53` vs original plain `cortex-a53` | Kept `cortex-a53` (supported directly by twrp-11's clang) |
| 27 | Full-ROM-only blocks (AVB vbmeta_system/vendor chains, `ENABLE_VENDOR_RIL_SERVICE`, Wi-Fi HAL board flags, NFC, fingerprint, `TARGET_RELEASETOOLS_EXTENSIONS`, `SELINUX_IGNORE_NEVERALLOWS`) | Removed — not applicable to a recovery-only build; simple recovery AVB block retained |
| 28 | `system.prop` contained `ro.crypto.volume.filenames_mode=aes-256-cts` **twice** | Deduplicated; kept device/board + crypto props relevant to TWRP |
| 29 | `TW_DEVICE_VERSION` bump | Set to `v2-rebuilt` so TWRP's About screen identifies the rebuild |

## 6. Post-rebuild external validation (cross-checked against
##    HemanthJabalpuri/twrp_realme_RMX2185, android-11 branch — working tree
##    for the same C11/C12/C15 family)

| Item | Rebuilt tree | Reference tree | Verdict |
|------|--------------|----------------|---------|
| Kernel base / ramdisk / tags / second / dtb offsets | 0x40078000 / 0x11a88000 / 0x07808000 / 0xbff88000 / 0x07808000 | identical | ✅ confirmed |
| Boot / recovery partition sizes | 33554432 / 102760448 | identical | ✅ confirmed |
| Boot header v2, page size 2048, cmdline `bootopt=64S3,32N2,64N2` | yes | identical | ✅ confirmed |
| Userdata ext4 + `fileencryption=aes-256-xts:aes-256-cts:v1` | yes | identical | ✅ confirmed (original TWRP-github fstab's f2fs/v2 claim was wrong) |
| Block path scheme `platform/bootdevice/by-name` | yes | identical | ✅ confirmed |
| `TW_THEME portrait_hdpi`, brightness `lcd-backlight`, max 2047, `RGBX_8888` | yes | identical | ✅ confirmed |
| Super partition size | 9126805504 (64 GB C15, from v2 RE data) | 7327449088 (32 GB C11/C12) | ⚠️ different variant — v2 value is device-specific and expected |
| `TARGET_BOOTLOADER_BOARD_NAME` | mt6765 | oppo6765 | ℹ️ cosmetic, no build/boot impact |
| `TW_OZIP_DECRYPT_KEY` | — | 0000 | ✅ added in rebuild (enables flashing stock `.ozip` firmware zips) |

## 5. Kept unchanged (verified correct)

- Boot header v2, page size 2048, kernel cmdline `bootopt=64S3,32N2,64N2` + permissive SELinux
- `TW_THEME portrait_hdpi`, brightness path `/sys/class/leds/lcd-backlight/brightness` (max 2047)
- `PLATFORM_VERSION 99.87.36` / security patch 2099 spoof
- `BOARD_SUPER_PARTITION_SIZE 9126805504` / `BOARD_MAIN_SIZE 9122611200`
- FBE decrypt stack: `TW_INCLUDE_CRYPTO_FBE`, `TW_INCLUDE_FBE_METADATA_DECRYPT`, `libkeymaster4/41`, `libpuresoftkeymasterdevice`
- fastbootd modules (`android.hardware.fastboot@1.0-impl-mock(.recovery)`, `TW_INCLUDE_FASTBOOTD`)
