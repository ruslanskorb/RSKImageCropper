//
//  UIApplication+RSKImageCropper.h
//  RSKImageCropperExample
//
//  Created by Ruslan Skorb on 3/28/15.
//  Copyright (c) 2015 Ruslan Skorb. All rights reserved.
//

#import <UIKit/UIKit.h>

/**
 The category `RSKImageCropper` of the class `UIApplication` provides the method `rsk_sharedApplication` which returns `nil` in an application extension, otherwise it returns the singleton app instance.
 */
@interface UIApplication (RSKImageCropper)

/**
 Returns `nil` in an application extension, otherwise returns the singleton app instance.
 
 @return `nil` in an application extension, otherwise the app instance is created in the `UIApplicationMain` function.
 */
+ (UIApplication *)rsk_sharedApplication;

@end
