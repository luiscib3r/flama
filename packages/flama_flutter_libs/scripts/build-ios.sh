rm -r llama.xcframework 
rm -r ios/llama.xcframework
mkdir ios-device
mkdir ios-simulator
cd llama.cpp
./scripts/build-ios.sh
mv build/Release-iphoneos/libllama.a ../ios-device/
./scripts/build-ios-sim.sh
mv build/Release-iphonesimulator/libllama.a ../ios-simulator/
cd ..
xcodebuild \
    -create-xcframework \
    -library ios-device/libllama.a \
    -library ios-simulator/libllama.a \
    -output llama.xcframework
mv llama.xcframework ios/
rm -r ios-device
rm -r ios-simulator
