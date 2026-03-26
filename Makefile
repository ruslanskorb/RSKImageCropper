PROJECT = Example/RSKImageCropperExample.xcodeproj
SCHEME = RSKImageCropperExample
CONFIGURATION = Release
DEVICE_HOST = platform='iOS Simulator',OS='26.2',name='iPhone 17 Pro'

.PHONY: all build ci clean test

all: ci

build:
	set -o pipefail && xcodebuild -project $(PROJECT) -scheme $(SCHEME) -configuration '$(CONFIGURATION)' -sdk iphonesimulator -destination $(DEVICE_HOST) build

clean:
	xcodebuild -project $(PROJECT) -scheme $(SCHEME) -configuration '$(CONFIGURATION)' -sdk iphonesimulator -destination $(DEVICE_HOST) clean

test:
	set -o pipefail && xcodebuild test -project $(PROJECT) -scheme $(SCHEME) -configuration Debug -sdk iphonesimulator -destination $(DEVICE_HOST)

ci: CONFIGURATION = Debug
ci: build
