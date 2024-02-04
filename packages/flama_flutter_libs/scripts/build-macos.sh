cd llama.cpp
./scripts/build-macos.sh
cd ..
mv llama.cpp/build/libllama.dylib macos/
mv llama.cpp/ggml-metal.metal macos/
