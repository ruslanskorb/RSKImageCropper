//
// RSKImageCropViewController.m
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

#import "RSKImageCropViewController.h"
#import "RSKTouchView.h"
#import "RSKImageScrollView.h"
#import "UIImage+FixOrientation.h"

static const CGFloat kPortraitMaskRectInnerEdgeInset = 15.0f;
static const CGFloat kPortraitMoveAndScaleLabelVerticalMargin = 64.0f;
static const CGFloat kPortraitCancelAndChooseButtonsHorizontalMargin = 13.0f;
static const CGFloat kPortraitCancelAndChooseButtonsVerticalMargin = 21.0f;

static const CGFloat kLandscapeMaskRectInnerEdgeInset = 45.0f;
static const CGFloat kLandscapeMoveAndScaleLabelVerticalMargin = 12.0f;
static const CGFloat kLandscapeCancelAndChooseButtonsVerticalMargin = 12.0f;

@interface RSKImageCropViewController ()

@property (strong, nonatomic) UIColor *originalNavigationControllerViewBackgroundColor;
@property (assign, nonatomic) BOOL originalNavigationControllerNavigationBarHidden;
@property (assign, nonatomic) BOOL originalStatusBarHidden;

@property (strong, nonatomic) RSKImageScrollView *imageScrollView;
@property (strong, nonatomic) RSKTouchView *overlayView;
@property (strong, nonatomic) CAShapeLayer *maskLayer;
@property (strong, nonatomic) UILabel *moveAndScaleLabel;
@property (strong, nonatomic) UIButton *cancelButton;
@property (strong, nonatomic) UIButton *chooseButton;

@property (strong, nonatomic) UITapGestureRecognizer *doubleTapGestureRecognizer;

@property (assign, nonatomic) BOOL didSetupConstraints;
@property (strong, nonatomic) NSLayoutConstraint *moveAndScaleLabelTopConstraint;
@property (strong, nonatomic) NSLayoutConstraint *cancelButtonBottomConstraint;
@property (strong, nonatomic) NSLayoutConstraint *chooseButtonBottomConstraint;

@end

@implementation RSKImageCropViewController

#pragma mark - Lifecycle

- (instancetype)initWithImage:(UIImage *)originalImage
{
    self = [super init];
    if (self) {
        _originalImage = originalImage;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
        self.automaticallyAdjustsScrollViewInsets = NO;
    }
    
    self.view.backgroundColor = [UIColor blackColor];
    self.view.clipsToBounds = YES;
    
    self.originalStatusBarHidden = [UIApplication sharedApplication].statusBarHidden;
    [[UIApplication sharedApplication] setStatusBarHidden:YES];
    
    self.originalNavigationControllerNavigationBarHidden = self.navigationController.navigationBarHidden;
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    
    [self.view addSubview:self.imageScrollView];
    [self.view addSubview:self.overlayView];
    [self.view addSubview:self.moveAndScaleLabel];
    [self.view addSubview:self.cancelButton];
    [self.view addSubview:self.chooseButton];
    
    [self.view addGestureRecognizer:self.doubleTapGestureRecognizer];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.originalNavigationControllerViewBackgroundColor = self.navigationController.view.backgroundColor;
    self.navigationController.view.backgroundColor = [UIColor blackColor];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    [[UIApplication sharedApplication] setStatusBarHidden:self.originalStatusBarHidden];
    [self.navigationController setNavigationBarHidden:self.originalNavigationControllerNavigationBarHidden animated:animated];
    self.navigationController.view.backgroundColor = self.originalNavigationControllerViewBackgroundColor;
}

- (void)viewWillLayoutSubviews
{
    [super viewWillLayoutSubviews];
    
    [self layoutImageScrollView];
    [self layoutOverlayView];
    [self updateMaskPath];
    [self.view setNeedsUpdateConstraints];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (!self.imageScrollView.zoomView) {
        [self displayImage];
    }
}

- (void)updateViewConstraints
{
    [super updateViewConstraints];
    
    if (!self.didSetupConstraints) {
        // ---------------------------
        // The label "Move and Scale".
        // ---------------------------
        
        NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.moveAndScaleLabel attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual
                                                                         toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0f
                                                                       constant:0.0f];
        [self.view addConstraint:constraint];
        
        CGFloat constant = kPortraitMoveAndScaleLabelVerticalMargin;
        self.moveAndScaleLabelTopConstraint = [NSLayoutConstraint constraintWithItem:self.moveAndScaleLabel attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual
                                                                              toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0f
                                                                            constant:constant];
        [self.view addConstraint:self.moveAndScaleLabelTopConstraint];
        
        // --------------------
        // The button "Cancel".
        // --------------------
        
        constant = kPortraitCancelAndChooseButtonsHorizontalMargin;
        constraint = [NSLayoutConstraint constraintWithItem:self.cancelButton attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual
                                                     toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0f
                                                   constant:constant];
        [self.view addConstraint:constraint];
        
        constant = -kPortraitCancelAndChooseButtonsVerticalMargin;
        self.cancelButtonBottomConstraint = [NSLayoutConstraint constraintWithItem:self.cancelButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0f
                                                                          constant:constant];
        [self.view addConstraint:self.cancelButtonBottomConstraint];
        
        // --------------------
        // The button "Choose".
        // --------------------
        
        constant = -kPortraitCancelAndChooseButtonsHorizontalMargin;
        constraint = [NSLayoutConstraint constraintWithItem:self.chooseButton attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual
                                                     toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0f
                                                   constant:constant];
        [self.view addConstraint:constraint];
        
        constant = -kPortraitCancelAndChooseButtonsVerticalMargin;
        self.chooseButtonBottomConstraint = [NSLayoutConstraint constraintWithItem:self.chooseButton attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual
                                                                            toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0f
                                                                          constant:constant];
        [self.view addConstraint:self.chooseButtonBottomConstraint];
        
        self.didSetupConstraints = YES;
    } else {
        if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
            self.moveAndScaleLabelTopConstraint.constant = kPortraitMoveAndScaleLabelVerticalMargin;
            self.cancelButtonBottomConstraint.constant = -kPortraitCancelAndChooseButtonsVerticalMargin;
            self.chooseButtonBottomConstraint.constant = -kPortraitCancelAndChooseButtonsVerticalMargin;
        } else {
            self.moveAndScaleLabelTopConstraint.constant = kLandscapeMoveAndScaleLabelVerticalMargin;
            self.cancelButtonBottomConstraint.constant = -kLandscapeCancelAndChooseButtonsVerticalMargin;
            self.chooseButtonBottomConstraint.constant = -kLandscapeCancelAndChooseButtonsVerticalMargin;
        }
    }
}

#pragma mark - Custom Accessors

- (RSKImageScrollView *)imageScrollView
{
    if (!_imageScrollView) {
        _imageScrollView = [[RSKImageScrollView alloc] init];
        _imageScrollView.clipsToBounds = NO;
    }
    return _imageScrollView;
}

- (RSKTouchView *)overlayView
{
    if (!_overlayView) {
        _overlayView = [[RSKTouchView alloc] init];
        _overlayView.receiver = self.imageScrollView;
        [_overlayView.layer addSublayer:self.maskLayer];
    }
    return _overlayView;
}

- (CAShapeLayer *)maskLayer
{
    if (!_maskLayer) {
        _maskLayer = [CAShapeLayer layer];
        _maskLayer.fillRule = kCAFillRuleEvenOdd;
        _maskLayer.fillColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7].CGColor;
    }
    return _maskLayer;
}

- (UILabel *)moveAndScaleLabel
{
    if (!_moveAndScaleLabel) {
        _moveAndScaleLabel = [[UILabel alloc] init];
        _moveAndScaleLabel.translatesAutoresizingMaskIntoConstraints = NO;
        _moveAndScaleLabel.backgroundColor = [UIColor clearColor];
        _moveAndScaleLabel.text = @"Move and Scale";
        _moveAndScaleLabel.textColor = [UIColor whiteColor];
        _moveAndScaleLabel.opaque = NO;
    }
    return _moveAndScaleLabel;
}

- (UIButton *)cancelButton
{
    if (!_cancelButton) {
        _cancelButton = [[UIButton alloc] init];
        _cancelButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_cancelButton setTitle:@"Cancel" forState:UIControlStateNormal];
        [_cancelButton addTarget:self action:@selector(onCancelButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
        _cancelButton.opaque = NO;
    }
    return _cancelButton;
}

- (UIButton *)chooseButton
{
    if (!_chooseButton) {
        _chooseButton = [[UIButton alloc] init];
        _chooseButton.translatesAutoresizingMaskIntoConstraints = NO;
        [_chooseButton setTitle:@"Choose" forState:UIControlStateNormal];
        [_chooseButton addTarget:self action:@selector(onChooseButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
        _chooseButton.opaque = NO;
    }
    return _chooseButton;
}

- (UITapGestureRecognizer *)doubleTapGestureRecognizer
{
    if (!_doubleTapGestureRecognizer) {
        _doubleTapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleDoubleTap:)];
        _doubleTapGestureRecognizer.delaysTouchesEnded = NO;
        _doubleTapGestureRecognizer.numberOfTapsRequired = 2;
    }
    return _doubleTapGestureRecognizer;
}

#pragma mark - Action handling

- (void)onCancelButtonTouch:(UIBarButtonItem *)sender
{
    [self cancelCrop];
}

- (void)onChooseButtonTouch:(UIBarButtonItem *)sender
{
    [self cropImage];
}

- (void)handleDoubleTap:(UITapGestureRecognizer *)gestureRecognizer
{
    [self resetZoomScale:YES];
    [self resetContentOffset:YES];
}

#pragma mark - Private

- (void)resetZoomScale:(BOOL)animated
{
    CGFloat zoomScale;
    if (CGRectGetWidth(self.view.bounds) > CGRectGetHeight(self.view.bounds)) {
        zoomScale = CGRectGetHeight(self.view.bounds) / self.originalImage.size.height;
    } else {
        zoomScale = CGRectGetWidth(self.view.bounds) / self.originalImage.size.width;
    }
    [self.imageScrollView setZoomScale:zoomScale animated:animated];
}

- (void)resetContentOffset:(BOOL)animated
{
    CGSize boundsSize = self.imageScrollView.bounds.size;
    CGRect frameToCenter = self.imageScrollView.zoomView.frame;
    CGPoint contentOffset = self.imageScrollView.contentOffset;
    contentOffset.x = (frameToCenter.size.width - boundsSize.width) / 2.0;
    contentOffset.y = (frameToCenter.size.height - boundsSize.height) / 2.0;
    [self.imageScrollView setContentOffset:contentOffset animated:animated];
}

- (void)displayImage
{
    if (self.originalImage) {
        [self.imageScrollView displayImage:self.originalImage];
        [self resetZoomScale:NO];
    }
}

- (void)layoutImageScrollView
{
    self.imageScrollView.frame = [self maskRect];
}

- (void)layoutOverlayView
{
    CGRect frame = CGRectMake(0, 0, CGRectGetWidth(self.view.bounds) * 2, CGRectGetHeight(self.view.bounds) * 2);
    self.overlayView.frame = frame;
}

- (void)updateMaskPath
{
    UIBezierPath *clipPath = [UIBezierPath bezierPathWithRect:self.overlayView.frame];
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithOvalInRect:[self maskRect]];
    
    [clipPath appendPath:maskPath];
    clipPath.usesEvenOddFillRule = YES;
    
    CABasicAnimation *pathAnimation = [CABasicAnimation animationWithKeyPath:@"path"];
    pathAnimation.duration = [CATransaction animationDuration];
    pathAnimation.timingFunction = [CATransaction animationTimingFunction];
    [self.maskLayer addAnimation:pathAnimation forKey:@"path"];
    
    self.maskLayer.path = [clipPath CGPath];
}

- (CGRect)maskRect
{
    CGRect bounds = self.view.bounds;
    
    CGFloat width = CGRectGetWidth(bounds);
    CGFloat height = CGRectGetHeight(bounds);
    
    CGFloat diameter;
    if (UIInterfaceOrientationIsPortrait(self.interfaceOrientation)) {
        diameter = MIN(width, height) - kPortraitMaskRectInnerEdgeInset * 2;
    } else {
        diameter = MIN(width, height) - kLandscapeMaskRectInnerEdgeInset * 2;
    }
    
    CGFloat radius = diameter / 2;
    CGPoint center = CGPointMake(width / 2, height / 2);
    
    CGRect maskRect = CGRectMake(center.x - radius, center.y - radius, diameter, diameter);
    
    return maskRect;
}

- (CGRect)cropRect
{
    CGRect cropRect = CGRectZero;
    float zoomScale = 1.0 / self.imageScrollView.zoomScale;
    
    cropRect.origin.x = self.imageScrollView.contentOffset.x * zoomScale;
    cropRect.origin.y = self.imageScrollView.contentOffset.y * zoomScale;
    cropRect.size.width = CGRectGetWidth(self.imageScrollView.bounds) * zoomScale;
    cropRect.size.height = CGRectGetHeight(self.imageScrollView.bounds) * zoomScale;
    
    CGSize imageSize = self.originalImage.size;
    CGFloat x = CGRectGetMinX(cropRect);
    CGFloat y = CGRectGetMinY(cropRect);
    CGFloat width = CGRectGetWidth(cropRect);
    CGFloat height = CGRectGetHeight(cropRect);
    
    UIImageOrientation imageOrientation = self.originalImage.imageOrientation;
    if (imageOrientation == UIImageOrientationRight || imageOrientation == UIImageOrientationRightMirrored) {
        cropRect.origin.x = y;
        cropRect.origin.y = imageSize.width - CGRectGetWidth(cropRect) - x;
        cropRect.size.width = height;
        cropRect.size.height = width;
    } else if (imageOrientation == UIImageOrientationLeft || imageOrientation == UIImageOrientationLeftMirrored) {
        cropRect.origin.x = imageSize.height - CGRectGetHeight(cropRect) - y;
        cropRect.origin.y = x;
        cropRect.size.width = height;
        cropRect.size.height = width;
    } else if (imageOrientation == UIImageOrientationDown || imageOrientation == UIImageOrientationDownMirrored) {
        cropRect.origin.x = imageSize.width - CGRectGetWidth(cropRect) - x;;
        cropRect.origin.y = imageSize.height - CGRectGetHeight(cropRect) - y;
    }
    
    return cropRect;
}

- (UIImage *)croppedImage:(UIImage *)image cropRect:(CGRect)cropRect
{
    CGImageRef croppedCGImage = CGImageCreateWithImageInRect(image.CGImage, cropRect);
    UIImage *croppedImage = [UIImage imageWithCGImage:croppedCGImage scale:1.0f orientation:image.imageOrientation];
    CGImageRelease(croppedCGImage);
    return [croppedImage fixOrientation];
}

- (void)cropImage
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        UIImage *croppedImage = [self croppedImage:self.originalImage cropRect:[self cropRect]];
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([self.delegate respondsToSelector:@selector(imageCropViewController:didCropImage:)]) {
                [self.delegate imageCropViewController:self didCropImage:croppedImage];
            }
        });
    });
}

- (void)cancelCrop
{
    if ([self.delegate respondsToSelector:@selector(imageCropViewControllerDidCancelCrop:)]) {
        [self.delegate imageCropViewControllerDidCancelCrop:self];
    }
}

@end
