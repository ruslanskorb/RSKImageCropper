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

@protocol RSKImageCropViewControllerDataSource;
@protocol RSKImageCropViewControllerDelegate;

/**
 Types of supported crop modes.
 */
typedef NS_ENUM(NSUInteger, RSKImageCropMode) {
    RSKImageCropModeCircle,
    RSKImageCropModeSquare,
    RSKImageCropModeCustom
};

@interface RSKImageCropViewController : UIViewController

/**
 Designated initializer. Initializes and returns a newly allocated view controller object with the specified image.
 
 @param originalImage The image for cropping.
 */
- (instancetype)initWithImage:(UIImage *)originalImage;

/**
 Initializes and returns a newly allocated view controller object with the specified image and the specified crop mode.
 
 @param originalImage The image for cropping.
 @param cropMode The mode for cropping.
 */
- (instancetype)initWithImage:(UIImage *)originalImage cropMode:(RSKImageCropMode)cropMode;

///-----------------------------
/// @name Accessing the Delegate
///-----------------------------

/**
 The receiver's delegate.
 
 @discussion A `RSKImageCropViewControllerDelegate` delegate responds to messages sent by completing / canceling crop the image in the image crop view controller.
 */
@property (weak, nonatomic) id<RSKImageCropViewControllerDelegate> delegate;

/**
 The receiver's data source.
 
 @discussion A `RSKImageCropViewControllerDataSource` data source provides a custom rect and a custom path for the mask.
 */
@property (weak, nonatomic) id<RSKImageCropViewControllerDataSource> dataSource;

///--------------------------
/// @name Accessing the Image
///--------------------------

/**
 The image for cropping.
 */
@property (strong, nonatomic) UIImage *originalImage;

/// -----------------------------------
/// @name Accessing the Mask Attributes
/// -----------------------------------

/**
 The color of the layer with the mask. Default value is [UIColor colorWithRed:0.0f green:0.0f blue:0.0f alpha:0.7f].
 */
@property (strong, nonatomic) UIColor *maskLayerColor;

/**
 The rect of the mask.
 
 @discussion Updating each time before the crop view lays out its subviews.
 */
@property (assign, readonly, nonatomic) CGRect maskRect;

/**
 The path of the mask.
 
 @discussion Updating each time before the crop view lays out its subviews.
 */
@property (strong, readonly, nonatomic) UIBezierPath *maskPath;

/// -----------------------------------
/// @name Accessing the Crop Attributes
/// -----------------------------------

/**
 The mode for cropping.
 */
@property (assign, nonatomic) RSKImageCropMode cropMode;

/// -------------------------------
/// @name Accessing the UI Elements
/// -------------------------------

/**
 The Title Label.
 */
@property (strong, nonatomic, readonly) UILabel *moveAndScaleLabel;

/**
 The Cancel Button.
 */
@property (strong, nonatomic, readonly) UIButton *cancelButton;

/**
 The Choose Button.
 */
@property (strong, nonatomic, readonly) UIButton *chooseButton;

/// -------------------------------------------
/// @name Checking of the Interface Orientation
/// -------------------------------------------

/**
 Returns a Boolean value indicating whether the user interface is currently presented in a portrait orientation.
 
 @return YES if the interface orientation is portrait, otherwise returns NO.
 */
- (BOOL)isPortraitInterfaceOrientation;

@end

/**
 The `RSKImageCropViewControllerDataSource` protocol is adopted by an object that provides a custom rect and a custom path for the mask.
 */
@protocol RSKImageCropViewControllerDataSource <NSObject>

/**
 Asks the data source a custom rect for the mask.
 
 @param controller The crop view controller object to whom a rect is provided.
 
 @return A custom rect for the mask.
 
 @discussion Only valid if `cropMode` is `RSKImageCropModeCustom`.
 */
- (CGRect)imageCropViewControllerCustomMaskRect:(RSKImageCropViewController *)controller;

/**
 Asks the data source a custom path for the mask.
 
 @param controller The crop view controller object to whom a path is provided.
 
 @return A custom path for the mask.
 
 @discussion Only valid if `cropMode` is `RSKImageCropModeCustom`.
 */
- (UIBezierPath *)imageCropViewControllerCustomMaskPath:(RSKImageCropViewController *)controller;

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
