/*
     File: RSKImageScrollView.m
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

#import <Foundation/Foundation.h>

#import "RSKImageScrollView.h"
#import "RSKImageScrollViewDelegate.h"

#pragma mark -

@interface RSKImageScrollView () <UIScrollViewDelegate>
{
    CGSize _imageSize;
    UIImageView *_imageView;
    
    CGPoint _pointToCenterAfterResize;
    CGFloat _scaleToRestoreAfterResize;
}

@end

@implementation RSKImageScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self)
    {
        _aspectFill = NO;
        _imageView = [[UIImageView alloc] init];
        self.showsVerticalScrollIndicator = NO;
        self.showsHorizontalScrollIndicator = NO;
        self.scrollsToTop = NO;
        self.decelerationRate = UIScrollViewDecelerationRateFast;
        self.delegate = self;
        
        [self addSubview:_imageView];
    }
    return self;
}

- (void)didAddSubview:(UIView *)subview
{
    [super didAddSubview:subview];
    
    [self centerImageView];
}

- (void)setAspectFill:(BOOL)aspectFill
{
    if (_aspectFill != aspectFill) {
        _aspectFill = aspectFill;
        
        if (_imageView.image) {
            [self setMaxMinZoomScalesForCurrentBounds];
            
            if (self.zoomScale < self.minimumZoomScale) {
                self.zoomScale = self.minimumZoomScale;
            } else if (self.zoomScale > self.maximumZoomScale) {
                self.zoomScale = self.maximumZoomScale;
            }
        }
    }
}

- (UIImage *)image
{
    return _imageView.image;
}

- (void)setImage:(UIImage *)image
{
    _imageView.image = image;
    
    if (CGSizeEqualToSize(_imageSize, CGSizeZero)) {
        self.imageSize = image.size;
    }
}

- (UIColor *)imageViewBackgroundColor
{
    return _imageView.backgroundColor;
}

- (void)setImageViewBackgroundColor:(UIColor *)imageViewBackgroundColor
{
    _imageView.backgroundColor = imageViewBackgroundColor;
}

- (id<UICoordinateSpace>)imageViewCoordinateSpace
{
    return [_imageView coordinateSpace];
}

- (CGRect)imageViewFrame
{
    return _imageView.frame;
}

- (void)setImageSize:(CGSize)imageSize
{
    _imageSize = imageSize;
    
    self.zoomScale = 1.0f;
    _imageView.frame = CGRectMake(0.0f, 0.0f, imageSize.width, imageSize.height);
    self.contentSize = imageSize;
    [self setMaxMinZoomScalesForCurrentBounds];
    [self setInitialZoomScale];
    [self setInitialContentOffset];
    [self centerImageView];
}

- (void)setInitialZoomScaleAndContentOffsetAndCenterImageView
{
    [self setInitialZoomScale];
    [self setInitialContentOffset];
    [self centerImageView];
}

- (void)setInitialZoomScaleAndContentOffsetAnimated:(BOOL)animated
{
    if (animated) {
        UIViewAnimationOptions options = UIViewAnimationOptionBeginFromCurrentState | UIViewAnimationCurveEaseInOut;
        [UIView animateWithDuration:0.4f delay:0.0f options:options animations:^{
            [self setInitialZoomScaleAndContentOffsetAndCenterImageView];
        } completion:nil];
    } else {
        [self setInitialZoomScaleAndContentOffsetAndCenterImageView];
    }
}

- (void)setFrame:(CGRect)frame
{
    if (CGSizeEqualToSize(self.contentSize, CGSizeZero)) {
        [super setFrame:frame];
        return;
    }
    
    BOOL sizeChanging = !CGSizeEqualToSize(frame.size, self.frame.size);
    
    if (sizeChanging) {
        [self prepareToResize];
    }
    
    [super setFrame:frame];
    
    if (sizeChanging) {
        [self recoverFromResizing];
    }
    
    [self centerImageView];
}

- (void)zoomToLocation:(CGPoint)location animated:(BOOL)animated
{
    CGPoint locationInImageView = [_imageView convertPoint:location fromView:self];
    CGSize size = CGSizeMake(self.bounds.size.width / MIN(self.zoomScale * 5.0f, self.maximumZoomScale),
                             self.bounds.size.height / MIN(self.zoomScale * 5.0f, self.maximumZoomScale));
    CGPoint origin = CGPointMake(locationInImageView.x - size.width * 0.5f,
                                 locationInImageView.y - size.height * 0.5f);
    CGRect rect = CGRectMake(origin.x, origin.y, size.width, size.height);
    
    [self zoomToRect:rect animated:animated];
}

#pragma mark - UIScrollViewDelegate

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView
{
    return _imageView;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if ([self.imageScrollViewDelegate respondsToSelector:@selector(imageScrollViewDidScroll)]) {
        [self.imageScrollViewDelegate imageScrollViewDidScroll];
    }
}

- (void)scrollViewDidZoom:(__unused UIScrollView *)scrollView
{
    [self centerImageView];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if ([self.imageScrollViewDelegate respondsToSelector:@selector(imageScrollViewWillBeginDragging)]) {
        [self.imageScrollViewDelegate imageScrollViewWillBeginDragging];
    }
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if ([self.imageScrollViewDelegate respondsToSelector:@selector(imageScrollViewDidEndDragging:)]) {
        [self.imageScrollViewDelegate imageScrollViewDidEndDragging:decelerate];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if ([self.imageScrollViewDelegate respondsToSelector:@selector(imageScrollViewDidEndDecelerating)]) {
        [self.imageScrollViewDelegate imageScrollViewDidEndDecelerating];
    }
}

- (void)scrollViewWillBeginZooming:(UIScrollView *)scrollView withView:(UIView *)view
{
    if ([self.imageScrollViewDelegate respondsToSelector:@selector(imageScrollViewWillBeginZooming)]) {
        [self.imageScrollViewDelegate imageScrollViewWillBeginZooming];
    }
}

- (void)scrollViewDidEndZooming:(UIScrollView *)scrollView withView:(UIView *)view atScale:(CGFloat)scale
{
    if ([self.imageScrollViewDelegate respondsToSelector:@selector(imageScrollViewDidEndZooming)]) {
        [self.imageScrollViewDelegate imageScrollViewDidEndZooming];
    }
}

#pragma mark - Center imageView within scrollView

- (void)centerImageView
{
    // center imageView as it becomes smaller than the size of the screen
    
    CGFloat top = 0.0f;
    CGFloat left = 0.0f;
    
    // center vertically
    if (self.contentSize.height < CGRectGetHeight(self.bounds)) {
        top = (CGRectGetHeight(self.bounds) - self.contentSize.height) * 0.5f;
    }
    
    // center horizontally
    if (self.contentSize.width < CGRectGetWidth(self.bounds)) {
        left = (CGRectGetWidth(self.bounds) - self.contentSize.width) * 0.5f;
    }
    
    UIEdgeInsets contentInset = UIEdgeInsetsMake(top, left, top, left);
    
    if (!UIEdgeInsetsEqualToEdgeInsets(self.contentInset, contentInset)) {
        self.contentInset = contentInset;
    }
}

#pragma mark - Configure scrollView to display new image

- (void)setMaxMinZoomScalesForCurrentBounds
{
    if (CGSizeEqualToSize(self.bounds.size, CGSizeZero)) {
        return;
    }
    
    if (CGSizeEqualToSize(_imageSize, CGSizeZero)) {
        self.maximumZoomScale = 1.0f;
        self.minimumZoomScale = 1.0f;

        return;
    }
    
    CGSize boundsSize = self.bounds.size;
    
    // calculate min/max zoomscale
    CGFloat xScale = boundsSize.width  / _imageSize.width;    // the scale needed to perfectly fit the image width-wise
    CGFloat yScale = boundsSize.height / _imageSize.height;   // the scale needed to perfectly fit the image height-wise
    
    CGFloat minScale;
    if (_aspectFill) {
        minScale = MAX(xScale, yScale); // use maximum of these to allow the image to fill the screen
    } else {
        minScale = MIN(xScale, yScale); // use minimum of these to allow the image to become fully visible
    }
    
    CGFloat maxScale = MAX(xScale, yScale);
    
    // Image must fit/fill the screen, even if its size is smaller.
    CGFloat xImageScale = maxScale * _imageSize.width / boundsSize.width;
    CGFloat yImageScale = maxScale * _imageSize.height / boundsSize.height;
    
    CGFloat maxImageScale = MAX(xImageScale, yImageScale);
    
    maxImageScale = MAX(minScale, maxImageScale);
    maxScale = MAX(maxScale, maxImageScale);
    
    // don't let minScale exceed maxScale. (If the image is smaller than the screen, we don't want to force it to be zoomed.)
    if (minScale > maxScale) {
        minScale = maxScale;
    }
    
    self.maximumZoomScale = maxScale;
    self.minimumZoomScale = minScale;
}

- (void)setInitialZoomScale
{
    if (self.zoomScale != self.minimumZoomScale) {
        self.zoomScale = self.minimumZoomScale;
    }
}

- (void)setInitialContentOffset
{
    CGSize boundsSize = self.bounds.size;
    CGRect frameToCenter = _imageView.frame;
    
    CGPoint contentOffset = self.contentOffset;
    if (CGRectGetWidth(frameToCenter) > boundsSize.width) {
        contentOffset.x = (CGRectGetWidth(frameToCenter) - boundsSize.width) * 0.5f;
    }
    if (CGRectGetHeight(frameToCenter) > boundsSize.height) {
        contentOffset.y = (CGRectGetHeight(frameToCenter) - boundsSize.height) * 0.5f;
    }
    
    if (!CGPointEqualToPoint(self.contentOffset, contentOffset)) {
        self.contentOffset = contentOffset;
    }
}

#pragma mark -
#pragma mark Methods called during rotation to preserve the zoomScale and the visible portion of the image

#pragma mark - Rotation support

- (void)prepareToResize
{
    if (_imageView == nil) {
        return;
    }
    
    CGPoint boundsCenter = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
    _pointToCenterAfterResize = [self convertPoint:boundsCenter toView:_imageView];
    
    _scaleToRestoreAfterResize = self.zoomScale;
    
    // If we're at the minimum zoom scale, preserve that by returning 0, which will be converted to the minimum
    // allowable scale when the scale is restored.
    if (_scaleToRestoreAfterResize <= self.minimumZoomScale + FLT_EPSILON)
        _scaleToRestoreAfterResize = 0;
}

- (void)recoverFromResizing
{
    if (_imageView == nil) {
        return;
    }
    
    [self setMaxMinZoomScalesForCurrentBounds];
    
    // Step 1: restore zoom scale, first making sure it is within the allowable range.
    CGFloat maxZoomScale = MAX(self.minimumZoomScale, _scaleToRestoreAfterResize);
    self.zoomScale = MIN(self.maximumZoomScale, maxZoomScale);
    
    // Step 2: restore center point, first making sure it is within the allowable range.
    
    // 2a: convert our desired center point back to our own coordinate space
    CGPoint boundsCenter = [self convertPoint:_pointToCenterAfterResize fromView:_imageView];
    
    // 2b: calculate the content offset that would yield that center point
    CGPoint offset = CGPointMake(boundsCenter.x - self.bounds.size.width * 0.5f,
                                 boundsCenter.y - self.bounds.size.height * 0.5f);
    
    // 2c: restore offset, adjusted to be within the allowable range
    CGPoint maxOffset = [self maximumContentOffset];
    CGPoint minOffset = [self minimumContentOffset];
    
    CGFloat realMaxOffset = MIN(maxOffset.x, offset.x);
    offset.x = MAX(minOffset.x, realMaxOffset);
    
    realMaxOffset = MIN(maxOffset.y, offset.y);
    offset.y = MAX(minOffset.y, realMaxOffset);
    
    if (self.contentSize.height < self.bounds.size.height) {
        
        offset.y = -(self.bounds.size.height - self.contentSize.height) * 0.5f;
    }
    if (self.contentSize.width < self.bounds.size.width) {
        
        offset.x = -(self.bounds.size.width - self.contentSize.width) * 0.5f;
    }
    
    self.contentOffset = offset;
}

- (CGPoint)maximumContentOffset
{
    CGSize contentSize = self.contentSize;
    CGSize boundsSize = self.bounds.size;
    return CGPointMake(contentSize.width - boundsSize.width, contentSize.height - boundsSize.height);
}

- (CGPoint)minimumContentOffset
{
    return CGPointZero;
}

@end
