#!/usr/bin/env bash

set -uxeo pipefail

sdk_version=${sdk_version:-2.3.5}
sdk_sha256=${sdk_sha256:-f80090e77da859857036e0afc2d6410f42c8b3450655bb60aeb324ed66297ee2}
sdk_url=${sdk_url:-https://developer.garmin.com/downloads/connect-iq/sdks/connectiq-sdk-lin-${sdk_version}.zip}
sdk_dir=${sdk_dir:-./build/sdks}

# download and verify sdk
mkdir -p $sdk_dir
cd $sdk_dir
if [[ ! -e ./$sdk_version ]]; then
  curl -o connectiq-sdk.zip --user-agent travis-ci/gncc "$sdk_url"
  sha256sum connectiq-sdk.zip | grep $sdk_sha256
  unzip -qq -d ./$sdk_version connectiq-sdk.zip
fi

# temp developer keys for build
cd ..
if [[ ! -e ./keys ]]; then
  mkdir -p ./keys
  openssl genrsa \
    -out ./keys/developer_key.pem \
    4096
  openssl pkcs8 \
    -topk8 \
    -inform PEM \
    -outform DER \
    -in ./keys/developer_key.pem \
    -out ./keys/developer_key.der \
    -nocrypt
fi
cd ..
