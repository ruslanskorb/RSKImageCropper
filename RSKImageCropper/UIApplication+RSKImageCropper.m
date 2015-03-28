//
//  UIApplication+RSKImageCropper.m
//  RSKImageCropperExample
//
//  Created by Ruslan Skorb on 3/28/15.
//  Copyright (c) 2015 Ruslan Skorb. All rights reserved.
//

#import "UIApplication+RSKImageCropper.h"
#import <objc/runtime.h>

@implementation UIApplication (RSKImageCropper)

+ (void)load
{
    // When you build an extension based on an Xcode template, you get an extension bundle that ends in .appex.
    // https://developer.apple.com/library/ios/documentation/General/Conceptual/ExtensibilityPG/ExtensionCreation.html
    if (![[[NSBundle mainBundle] bundlePath] hasSuffix:@".appex"]) {
        Method sharedApplicationMethod = class_getClassMethod([UIApplication class], @selector(sharedApplication));
        if (sharedApplicationMethod != NULL) {
            IMP sharedApplicationMethodImplementation = method_getImplementation(sharedApplicationMethod);
            Method rsk_sharedApplicationMethod = class_getClassMethod([UIApplication class], @selector(rsk_sharedApplication));
            method_setImplementation(rsk_sharedApplicationMethod, sharedApplicationMethodImplementation);
        }
    }
}

+ (UIApplication *)rsk_sharedApplication
{
    return nil;
}

@end
