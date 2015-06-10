//
//  RSKImageCropViewController+RSKImageCropViewControllerProtected.h
//
//  Created by Dustin Bergman on 6/10/15.
//  Copyright (c) 2015 Ruslan Skorb. All rights reserved.
//

#import "RSKImageCropViewController.h"

@interface RSKImageCropViewController (RSKImageCropViewControllerProtected)

/**
 *  Asynchronously crops the original image in accordance with the current settings
 */
- (void)cropImage;

/**
 *  Method that invokes the protocol method imageCropViewControllerDidCancelCrop:
 */
- (void)cancelCrop;

/**
 *  Method that resets the original image in to original position in the scroll view.
 *
 *  @param animated BOOL
 */
- (void)reset:(BOOL)animated;

@end
