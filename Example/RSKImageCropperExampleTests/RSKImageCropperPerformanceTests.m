//
// RSKImageCropperPerformanceTests.m
//
// Copyright (c) 2015 Ruslan Skorb, http://ruslanskorb.com/
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

#import <XCTest/XCTest.h>
#import "RSKImageCropViewController.h"

@interface RSKImageCropViewController (Testing)

- (void)cropImage;
- (void)setRotationAngle:(CGFloat)rotationAngle;

@end

@interface RSKImageCropperPerformanceTests : XCTestCase

@property (strong, nonatomic) RSKImageCropViewController *imageCropViewController;

@end

@implementation RSKImageCropperPerformanceTests

- (void)setUp
{
    [super setUp];
    
    self.imageCropViewController = [[RSKImageCropViewController alloc] initWithImage:[UIImage imageNamed:@"photo"]];
    [self.imageCropViewController view];
    [self.imageCropViewController.view setNeedsUpdateConstraints];
    [self.imageCropViewController.view updateConstraintsIfNeeded];
    [self.imageCropViewController.view setNeedsLayout];
    [self.imageCropViewController.view layoutIfNeeded];
    [self.imageCropViewController viewWillAppear:NO];
    [self.imageCropViewController viewDidAppear:NO];
}

- (void)tearDown
{
    self.imageCropViewController = nil;
    
    [super tearDown];
}

- (void)testCropImagePerformanceWithDefaultSettings
{
    [self measureBlock:^{
        [self.imageCropViewController cropImage];
    }];
}

- (void)testCropImagePerformanceWithCustomRotationAngle
{
    [self.imageCropViewController setRotationAngle:M_PI_4];
    [self measureBlock:^{
        [self.imageCropViewController cropImage];
    }];
}

- (void)testCropImagePerformanceWhenApplyMaskToCroppedImage
{
    self.imageCropViewController.applyMaskToCroppedImage = YES;
    [self measureBlock:^{
        [self.imageCropViewController cropImage];
    }];
}

- (void)testCropImagePerformanceWithCustomRotationAngleAndWhenApplyMaskToCroppedImage
{
    [self.imageCropViewController setRotationAngle:M_PI_4];
    self.imageCropViewController.applyMaskToCroppedImage = YES;
    [self measureBlock:^{
        [self.imageCropViewController cropImage];
    }];
}

@end
