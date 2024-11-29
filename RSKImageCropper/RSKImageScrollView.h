/*
     File: RSKImageScrollView.h
 Abstract: Centers image within the scroll view and configures image sizing and display.
  Version: 1.5 modified by Ruslan Skorb on 11/26/24.
 
 Disclaimer: IMPORTANT:  This Apple software is supplied to you by Apple
 Inc. ("Apple") in consideration of your agreement to the following
 terms, and your use, installation, modification or redistribution of
 this Apple software constitutes acceptance of these terms.  If you do
 not agree with these terms, please do not use, install, modify or
 redistribute this Apple software.
 
 In consideration of your agreement to abide by the following terms, and
 subject to these terms, Apple grants you a personal, non-exclusive
 license, under Apple's copyrights in this original Apple software (the
 "Apple Software"), to use, reproduce, modify and redistribute the Apple
 Software, with or without modifications, in source and/or binary forms;
 provided that if you redistribute the Apple Software in its entirety and
 without modifications, you must retain this notice and the following
 text and disclaimers in all such redistributions of the Apple Software.
 Neither the name, trademarks, service marks or logos of Apple Inc. may
 be used to endorse or promote products derived from the Apple Software
 without specific prior written permission from Apple.  Except as
 expressly stated in this notice, no other rights or licenses, express or
 implied, are granted by Apple herein, including but not limited to any
 patent rights that may be infringed by your derivative works or by other
 works in which the Apple Software may be incorporated.
 
 The Apple Software is provided by Apple on an "AS IS" basis.  APPLE
 MAKES NO WARRANTIES, EXPRESS OR IMPLIED, INCLUDING WITHOUT LIMITATION
 THE IMPLIED WARRANTIES OF NON-INFRINGEMENT, MERCHANTABILITY AND FITNESS
 FOR A PARTICULAR PURPOSE, REGARDING THE APPLE SOFTWARE OR ITS USE AND
 OPERATION ALONE OR IN COMBINATION WITH YOUR PRODUCTS.
 
 IN NO EVENT SHALL APPLE BE LIABLE FOR ANY SPECIAL, INDIRECT, INCIDENTAL
 OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
 SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
 INTERRUPTION) ARISING IN ANY WAY OUT OF THE USE, REPRODUCTION,
 MODIFICATION AND/OR DISTRIBUTION OF THE APPLE SOFTWARE, HOWEVER CAUSED
 AND WHETHER UNDER THEORY OF CONTRACT, TORT (INCLUDING NEGLIGENCE),
 STRICT LIABILITY OR OTHERWISE, EVEN IF APPLE HAS BEEN ADVISED OF THE
 POSSIBILITY OF SUCH DAMAGE.
 
 Copyright (C) 2012 Apple Inc. All Rights Reserved.
 Copyright (C) 2014-present Ruslan Skorb. All Rights Reserved.
 
 */

#import <UIKit/UIKit.h>

NS_HEADER_AUDIT_BEGIN(nullability, sendability)

@protocol RSKImageScrollViewDelegate;

/**
 A view that allows the scrolling and zooming of its image.
 */
NS_SWIFT_UI_ACTOR
@interface RSKImageScrollView : UIScrollView

/**
 A Boolean value that determines whether the image will always fill the available space. Default value is `NO`.
 */
@property (nonatomic, assign) BOOL aspectFill;

/**
 An image for scrolling and zooming. Default value is `nil`.
 */
@property (nonatomic, nullable, strong) UIImage *image;

/**
 The delegate of the image scroll view.
 
 @discussion The delegate must adopt the `RSKImageScrollViewDelegate` protocol. The `RSKImageScrollView` class, which doesn’t retain the delegate, invokes each protocol method the delegate implements.
 */
@property (nonatomic, nullable, weak) id<RSKImageScrollViewDelegate> imageScrollViewDelegate;

/**
 The logical dimensions, in points, of the image. Default value is `CGSizeZero`.
 
 @discussion Can be set to a value different from `image.size`.
*/
@property (nonatomic, assign) CGSize imageSize;

/**
 The background color of the image view. Default value is `nil`, which results in a transparent color.
 
 @discussion Changes to this property can be animated.
 */
@property (nonatomic, nullable, strong) UIColor *imageViewBackgroundColor;

/**
 The coordinate space of the image view.
 */
@property (nonatomic, readonly) id<UICoordinateSpace> imageViewCoordinateSpace;

/**
 The current frame of the image view in the coordinate space of the image scroll view.
 */
@property (nonatomic, readonly) CGRect imageViewFrame;

/**
 Sets the current scale factor applied to the image and offset from the image’s origin to the initial value.
 
 @param animated `YES` to animate the transition to the new scale and content offset, `NO` to make the transition immediate.
 */
- (void)setInitialZoomScaleAndContentOffsetAnimated:(BOOL)animated;

/**
 Zooms to a specific location in the image so that it’s visible in the image scroll view.
 
 @param location A point defining a location in the image. The point should be in the coordinate space of the image scroll view.
 @param animated `YES` if the scrolling should be animated, `NO` if it should be immediate.
 */
- (void)zoomToLocation:(CGPoint)location animated:(BOOL)animated;

@end

NS_HEADER_AUDIT_END(nullability, sendability)
