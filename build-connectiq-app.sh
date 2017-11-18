#!/usr/bin/env bash

set -euxo pipefail

sdk_version=${sdk_version:-2.3.5}
sdk_dir=${sdk_dir:-./build/sdks}

mkdir -p bin
java -Dfile.encoding=UTF-8 \
  -jar ${sdk_dir}/${sdk_version}/bin/monkeybrains.jar \
	--package-app \
	--manifest ./manifest.xml \
	--output ./bin/garmin-nest-camera-control.iq \
	--release \
	--warn \
	--private-key ${sdk_dir}/../keys/developer_key.der \
	$(find ./resources -iname '*.xml' | sed s'/^/--rez /' | xargs echo) \
	$(find ./source -iname '*.mc' | tr '\n' ' ')
