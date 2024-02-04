rm -r jniLibs
rm -r android/src/main/jniLibs
mkdir -p jniLibs/arm64-v8a
cd llama.cpp
./scripts/build-android.sh arm64-v8a
mv build/libllama.so ../jniLibs/arm64-v8a/
cd ..
mv jniLibs android/src/main/