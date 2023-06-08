# rust2react-native

rust2react-native is a project that bridges Rust with a React Native application targeting the iOS platform. This scaffolding allows developers to write high-performance native modules in Rust for React Native applications, leveraging the performance, safety, and compatibility features of Rust with the flexibility of React Native.

## Project Structure

The project consists of the following two folders:

1. **react_native_rust_lib:** This folder contains the Rust library.
2. **ReactNativeRustBridge:** This folder contains the React Native sample project.

## Getting Started

To integrate Rust with your React Native project targeting iOS, follow the steps below:

### Step 1: Install Rust

Before you begin, ensure that you have Rust installed on your development machine. You can download Rust from the official website: [https://www.rust-lang.org/tools/install](https://www.rust-lang.org/tools/install).

### Step 2: Create a New Rust Project

Next, create a new Rust project using the `cargo new` command. Open your terminal and navigate to the root directory of your React Native project. Then, execute the following command:

```shell
cargo new --lib react_native_rust_lib
```

This command creates a new Rust project named `react_native_rust_lib` inside the root directory of your React Native project.

### Step 3: Write Your Rust Code

Now that you have a new Rust project, you can start writing your Rust code. In the `react_native_rust_lib` directory, open the `src/lib.rs` file and write your Rust code. For example, let's create a simple Rust function that adds two numbers together:

```rust
#[no_mangle]
pub extern "C" fn add_numbers(a: i32, b: i32) -> i32 {
    a + b
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn it_works() {
        let result = add_numbers(2, 2);
        assert_eq!(result, 4);
    }
}
```

The above code defines a Rust function `add_numbers` that takes two `i32` arguments and returns their sum.

### Step 4: Integrate Your Rust Project for iOS

#### Step 4.1: Build Your Rust Project

To link your Rust project with your React Native project, you need to build it as a static library. Start by configuring the `Cargo.toml` file inside your `react_native_rust_lib` directory to support a static library:

```toml
[package]
name = "react_native_rust_lib"
version = "0.1.0"
edition = "2021"

[lib]
name = "react_native_rust_lib"
crate-type = ["staticlib"]
```

The above configuration ensures that the project is built as a static library. Next, compile the Rust project into a library that can be used in your React Native project. Open your terminal, navigate to the `react_native_rust_lib` directory, and execute the following commands:

```shell
cargo build --target aarch64-apple-ios --release
cargo build --target x86_64-apple-ios --release
```

These commands build your Rust project for iOS. Make sure to install the necessary targets by running the command `rustup target add aarch64-apple-ios x86_64-apple-ios` in your terminal before building.

When you compile a Rust module as a static library for iOS, you need to compile it separately for each architecture you want to support (e.g., ARMv7, ARM64). This creates multiple binary files, each containing code for a specific architecture. To use the Rust module in a React Native app, you need to create a universal binary file that contains code for all the architectures you want to support.

You can use `lipo` to create a universal static library. Execute the following command in your terminal:

```shell
lipo -create -output libreact_native_rust_lib.a \
    target/aarch64-apple-ios/release/libreact_native_rust_lib.a \
    target/x86_64-apple-ios/release/libreact_native_rust_lib.a
```

The above command creates a universal static library named `libreact_native_rust_lib.a` by combining the individual architecture-specific binary files.

#### Step 4.2: Generate a Header File

When you compile a Rust module as a static library for iOS, the resulting binary file contains compiled machine code that can be executed by the device's CPU. However, to call functions in the Rust module from other code (such as a React Native app), you need to provide information about the function signatures and data types that the Rust module expects and returns.

To achieve this, you need to generate a header file for your Rust module. You can use the `cbindgen` tool to automatically generate a C-style header file based on your Rust code. Execute the following command in your terminal:

```shell
cbindgen --lang c --crate react_native_rust_lib --output react_native_rust_lib.h
```

The above command generates a header file named `react_native_rust_lib.h` that contains the C-style declarations for all the functions, variables, and data types in your Rust code.

#### Step 4.3: Add Your Rust Library to Your Xcode Project

Next, you need to add your Rust library to your React Native project. Follow the steps below:

1. Create a new directory called `rust_libs` inside the `ios` folder of your React Native project.
2. Copy the `libreact_native_rust_lib.a` (universal static library) and `react_native_rust_lib.h` files from your Rust project's `react_native_rust_lib` directory into the `ios/rust_libs` directory.
3. Your `ios/rust_libs` folder should have the following structure:

   ```
   ios/rust_libs
   ├── RustBridge.m
   ├── libreact_native_rust_lib.a
   └── react_native_rust_lib.h
   ```

#### Step 4.4: Link Your Rust Library in Your Xcode Project

To link your Rust library in your React Native project, you need to perform the following steps:

1. Open your React Native project's `ios/ReactNativePro.xcodeproj` file in Xcode.
2. Click on your project in the Project Navigator.
3. Click on your target in the Targets list.
4. Select the "Build Phases" tab.
5. Click the "+" button under "Link Binary With Libraries".
6. Click the "Add Other" button.
7. Navigate to your React Native project's `ios/rust_libs` directory and select the `libreact_native_rust_lib.a` file.
8. Click the "Add" button.

#### Step 4.5: Create a React Native Bridge Module

To use the Rust static library in an Xcode project, you need to create a bridge module that defines the methods you want to invoke in the Rust code. The bridge module is an Objective-C file that acts as an interface between the Rust code and the React Native code.

Create a new file called `RustBridge.m` inside the `ios/rust_libs` directory with the following content:

```objective-c
#import <Foundation/Foundation.h>
#import "React/RCTBridgeModule.h"
#include "react_native_rust_lib.h"

@interface RustBridge : NSObject <RCTBridgeModule>

@end

@implementation RustBridge

RCT_EXPORT_MODULE();

RCT_EXPORT_METHOD(addNumbers:(int)a b:(int)b
                  resolver:(RCTPromiseResolveBlock)resolve
                  rejecter:(RCTPromiseRejectBlock)reject) {
    int result = add_numbers(a, b);
    resolve(@(result));
}

@end
```

The above code defines a bridge module called `RustBridge` that conforms to the `RCTBridgeModule` protocol. It exposes a method called `addNumbers` which takes two integers (`a` and `b`) and returns their sum. Inside the implementation of the method, it calls the `add_numbers` function from the Rust code and resolves the result using the provided promise resolver.

#### Step 5: Integrate Your Rust project for Android

Note: This tutorial only covers integrating Rust with React Native for iOS. Android integration is more complex and involves compiling `.so` files with the Android NDK. While there are plugins available, such as `rust-android-gradle` by Mozilla, they might not work on certain platforms. Separate tutorials might be necessary for Android integration.

#### Step 6: Create a React Native Module

Now that you've built and linked your Rust project for iOS, you can create a React Native module that will use your Rust code. Follow the steps below:

1. Create a new directory called `react_native_rust_lib` in your React Native project.
2. Inside the `react_native_rust_lib` directory, create a file called `RustBridge.ts` with the following code:

```javascript
import { NativeModules } from 'react-native';

const { RustBridge } = NativeModules;

export default RustBridge;
```

The above code imports the `NativeModules` object from React Native and creates a JavaScript module called `RustBridge`, which allows you to call your Rust code from your React Native project.

#### Step 7: Use Your Rust Module in Your React Native Project

You're now ready to use your Rust module in your React Native project. Open your React Native project's `App.js` file and add the following code:

```javascript
import RustBridge from './react_native_rust_lib/RustBridge';

console.log(RustBridge.addNumbers(1, 2));
```

The above code imports your `RustBridge` module and calls the `addNumbers` function that you defined in your Rust code.

## Conclusion

Integrating Rust in a React Native project can be a powerful way to improve the performance and safety of your mobile application. By following these steps, you can easily create high-performance native modules using Rust and React Native.
