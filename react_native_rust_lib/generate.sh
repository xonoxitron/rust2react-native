lipo -create -output libreact_native_rust_lib.a target/aarch64-apple-ios/release/libreact_native_rust_lib.a target/x86_64-apple-ios/release/libreact_native_rust_lib.a
cbindgen --lang c --crate react_native_rust_lib --output react_native_rust_lib.h
