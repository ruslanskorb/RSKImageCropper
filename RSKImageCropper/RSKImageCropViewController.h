//
// RSKImageCropViewController.h
//
// Copyright (c) 2014 Ruslan Skorb, http://lnkd.in/gsBbvb
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import <UIKit/UIKit.h>

@protocol RSKImageCropViewControllerDelegate;

@interface RSKImageCropViewController : UIViewController

/**
 Designated initializer. Initializes and returns a newly allocated view controller object with the specified image.
 
 @param originalImage The image for cropping.
 */
- (instancetype)initWithImage:(UIImage *)originalImage;

///-----------------------------
/// @name Accessing the Delegate
///-----------------------------

/**
 The receiver's delegate.
 
 @discussion A `RSKImageCropViewControllerDelegate` delegate responds to messages sent by completing / canceling crop the image in the image crop view controller.
 */
@property (weak, nonatomic) id<RSKImageCropViewControllerDelegate> delegate;

///--------------------------
/// @name Accessing the Image
///--------------------------

/**
 The image for cropping.
 */
@property (strong, nonatomic) UIImage *originalImage;

@end

/**
 The `RSKImageCropViewControllerDelegate` protocol defines messages sent to a image crop view controller delegate when crop image was canceled or the original image was cropped.
 */
@protocol RSKImageCropViewControllerDelegate <NSObject>

/**
 Tells the delegate that crop image has been canceled.
 */
- (void)imageCropViewControllerDidCancelCrop:(RSKImageCropViewController *)controller;

/**
 Tells the delegate that the original image has been cropped.
 */
- (void)imageCropViewController:(RSKImageCropViewController *)controller didCropImage:(UIImage *)croppedImage;

@end