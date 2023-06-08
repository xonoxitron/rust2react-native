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
