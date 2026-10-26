#
# Copyright (C) 2021-2026 The TWRP Open Source Project
#
# SPDX-License-Identifier: Apache-2.0
#
# Product configuration for realme C15 (RMX2180)
#

# Inherit from the common Open Source product configuration
$(call inherit-product, $(SRC_TARGET_DIR)/product/base.mk)
$(call inherit-product, $(SRC_TARGET_DIR)/product/core_64_bit.mk)

# Inherit from TWRP common
$(call inherit-product, vendor/twrp/config/common.mk)

# Inherit device configuration
$(call inherit-product, device/realme/RMX2180/device.mk)

# Device identifier
PRODUCT_DEVICE := RMX2180
PRODUCT_NAME := twrp_RMX2180
PRODUCT_BRAND := realme
PRODUCT_MODEL := RMX2180
PRODUCT_MANUFACTURER := realme

PRODUCT_GMS_CLIENTID_BASE := android-oppo

# Assert
TARGET_OTA_ASSERT_DEVICE := RMX2180,rmx2180,RMX2185,rmx2185,RMX2189,rmx2189
