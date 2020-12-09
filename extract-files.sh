#!/bin/bash
#
# Copyright (C) 2016 The CyanogenMod Project
# Copyright (C) 2017 The LineageOS Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

# If we're being sourced by the common script that we called,
# stop right here. No need to go down the rabbit hole.
if [ "${BASH_SOURCE[0]}" != "${0}" ]; then
    return
fi

set -e

# Required!
export DEVICE=X00H
export DEVICE_COMMON=msm8937-common
export VENDOR=asus
export DEVICE_BRINGUP_YEAR=2020

"./../../${VENDOR}/${DEVICE_COMMON}/extract-files.sh" "$@"

MY_DIR="${BASH_SOURCE%/*}"
if [[ ! -d "$MY_DIR" ]]; then MY_DIR="$PWD"; fi

LINEAGE_ROOT="$MY_DIR"/../../..
DEVICE_BLOB_ROOT="$LINEAGE_ROOT"/vendor/"$VENDOR"/"$DEVICE"/proprietary

sed -i "s|/system/etc/firmware|/vendor/firmware\x0\x0\x0\x0|g" "$DEVICE_BLOB_ROOT/vendor/lib64/libgf_ca.so"

for blob in libarcsoft_hdr.so libarcsoft_nighthawk.so libarcsoft_night_shot.so libarcsoft_panorama_burstcapture.so libarcsoft_videostab.so libmpbase.so; do
    patchelf --remove-needed "libandroid.so" "$DEVICE_BLOB_ROOT/vendor/lib/$blob"
done

for blob in hw/camera.msm8937.so libcamera_client.so; do
    patchelf --replace-needed "libgui.so" "libgui_vendor.so" "$DEVICE_BLOB_ROOT/vendor/lib/$blob"
done

patchelf --replace-needed "libkeystore_binder.so" "libkeystore_binder_vendor.so" "$DEVICE_BLOB_ROOT/vendor/bin/hw/android.hardware.biometrics.fingerprint@2.1-service"

for blob in hw/fingerprint.default.so libgoodixfingerprintd_binder.so libvendor.goodix.hardware.fingerprint@1.0-service.so; do
    patchelf --replace-needed "libbacktrace.so" "libbacktrace_vendor.so" "$DEVICE_BLOB_ROOT/vendor/lib64/$blob"
    patchelf --replace-needed "libbinder.so" "libbinder-v28.so" "$DEVICE_BLOB_ROOT/vendor/lib64/$blob"
    patchelf --replace-needed "libkeystore_binder.so" "libkeystore_binder_vendor.so" "$DEVICE_BLOB_ROOT/vendor/lib64/$blob"
    patchelf --replace-needed "libunwind.so" "libunwind_vendor.so" "$DEVICE_BLOB_ROOT/vendor/lib64/$blob"
done
