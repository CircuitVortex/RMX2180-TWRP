#
# Copyright (C) 2021-2026 The TWRP Open Source Project
#
# SPDX-License-Identifier: Apache-2.0
#
# device.mk for realme C15 (RMX2180)
# Shared configuration inherited by twrp_RMX2180.mk
#

DEVICE_PATH := device/realme/RMX2180

# Dynamic partitions
PRODUCT_USE_DYNAMIC_PARTITIONS := true

# Shipping API / VNDK (Android 11 stock)
PRODUCT_SHIPPING_API_LEVEL := 29
PRODUCT_TARGET_VNDK_VERSION := 30

# fastbootd (required for TW_INCLUDE_FASTBOOTD)
PRODUCT_PACKAGES += \
    android.hardware.fastboot@1.0-impl-mock \
    android.hardware.fastboot@1.0-impl-mock.recovery \
    fastbootd

# Additional binaries & libraries needed for FBE decryption
TARGET_RECOVERY_DEVICE_MODULES += \
    libkeymaster4 \
    libkeymaster41 \
    libpuresoftkeymasterdevice

# Install the recovery fstab into the TWRP ramdisk
PRODUCT_COPY_FILES += \
    $(DEVICE_PATH)/recovery.fstab:$(TARGET_COPY_OUT_RECOVERY)/root/system/etc/recovery.fstab
