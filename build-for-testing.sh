#!/usr/bin/env bash

pod install 

xcodebuild build-for-testing  \
    -workspace 'AICameraDetection.xcworkspace' \
    -scheme 'AICameraDetectionTests' \
    - run: xcrun simctl list &>/dev/null \
    -destination 'platform=iOS Simulator,name=iPhone 8' 

echo 'Succeeded  Test Build '