//
// RSKImageCropViewControllerTests.m
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

#import "RSKImageCropViewController.h"
#import "RSKImageScrollView.h"

@interface RSKImageCropViewControllerDataSourceObject1 : NSObject <RSKImageCropViewControllerDataSource>

@end

@implementation RSKImageCropViewControllerDataSourceObject1

// Returns a custom rect for the mask.
- (CGRect)imageCropViewControllerCustomMaskRect:(RSKImageCropViewController *)controller
{
    CGSize maskSize;
    if ([controller isPortraitInterfaceOrientation]) {
        maskSize = CGSizeMake(250, 250);
    } else {
        maskSize = CGSizeMake(220, 220);
    }
    
    CGFloat viewWidth = CGRectGetWidth(controller.view.frame);
    CGFloat viewHeight = CGRectGetHeight(controller.view.frame);
    
    CGRect maskRect = CGRectMake((viewWidth - maskSize.width) * 0.5f,
                                 (viewHeight - maskSize.height) * 0.5f,
                                 maskSize.width,
                                 maskSize.height);
    
    return maskRect;
}

// Returns a custom path for the mask.
- (UIBezierPath *)imageCropViewControllerCustomMaskPath:(RSKImageCropViewController *)controller
{
    CGRect rect = controller.maskRect;
    CGPoint point1 = CGPointMake(CGRectGetMinX(rect), CGRectGetMaxY(rect));
    CGPoint point2 = CGPointMake(CGRectGetMaxX(rect), CGRectGetMaxY(rect));
    CGPoint point3 = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    
    UIBezierPath *triangle = [UIBezierPath bezierPath];
    [triangle moveToPoint:point1];
    [triangle addLineToPoint:point2];
    [triangle addLineToPoint:point3];
    [triangle closePath];
    
    return triangle;
}

// Returns a custom rect in which the image can be moved.
- (CGRect)imageCropViewControllerCustomMovementRect:(RSKImageCropViewController *)controller
{
    // If the image is not rotated, then the movement rect coincides with the mask rect.
    return controller.maskRect;
}

@end

@interface RSKImageCropViewControllerDelegateObject1 : NSObject <RSKImageCropViewControllerDelegate>

@end

@implementation RSKImageCropViewControllerDelegateObject1

- (void)imageCropViewController:(RSKImageCropViewController *)controller willCropImage:(UIImage *)originalImage {}
- (void)imageCropViewController:(RSKImageCropViewController *)controller didCropImage:(UIImage *)croppedImage usingCropRect:(CGRect)cropRect rotationAngle:(CGFloat)rotationAngle {};
- (void)imageCropViewControllerDidCancelCrop:(RSKImageCropViewController *)controller {};
- (void)imageCropViewControllerDidDisplayImage:(RSKImageCropViewController *)controller {};

@end

static const CGFloat kLayoutImageScrollViewAnimationDuration = 0.25;

@interface RSKImageCropViewController (Testing)

@property (readonly, nonatomic) CGRect imageRect;
@property (strong, nonatomic) RSKImageScrollView *imageScrollView;
@property (assign, nonatomic) BOOL originalNavigationControllerNavigationBarHidden;
@property (assign, nonatomic) BOOL originalStatusBarHidden;
@property (assign, nonatomic) CGFloat rotationAngle;
@property (strong, nonatomic) UIRotationGestureRecognizer *rotationGestureRecognizer;

- (void)cancelCrop;
- (void)cropImage;
- (UIImage *)croppedImage:(UIImage *)originalImage cropMode:(RSKImageCropMode)cropMode cropRect:(CGRect)cropRect imageRect:(CGRect)imageRect rotationAngle:(CGFloat)rotationAngle zoomScale:(CGFloat)zoomScale maskPath:(UIBezierPath *)maskPath applyMaskToCroppedImage:(BOOL)applyMaskToCroppedImage;
- (void)displayImage;
- (void)handleDoubleTap:(UITapGestureRecognizer *)gestureRecognizer;
- (void)handleRotation:(UIRotationGestureRecognizer *)gestureRecognizer;
- (void)onCancelButtonTouch:(UIBarButtonItem *)sender;
- (void)onChooseButtonTouch:(UIBarButtonItem *)sender;
- (void)layoutImageScrollView;
- (void)reset:(BOOL)animated;
- (void)resetContentOffset;
- (void)resetFrame;
- (void)resetRotation;
- (void)resetZoomScale;

@end

SpecBegin(RSKImageCropViewController)

__block RSKImageCropViewController *imageCropViewController = nil;
__block UIImage *originalImage = nil;

dispatch_block_t sharedLoadView = ^{
    [imageCropViewController.view setNeedsUpdateConstraints];
    [imageCropViewController.view updateConstraintsIfNeeded];
    
    [imageCropViewController.view setNeedsLayout];
    [imageCropViewController.view layoutIfNeeded];
    
    [imageCropViewController viewWillAppear:YES];
    [imageCropViewController viewDidAppear:YES];
};

beforeAll(^{
    originalImage = [UIImage imageNamed:@"photo"];
});

describe(@"init", ^{
    before(^{
        imageCropViewController = [[RSKImageCropViewController alloc] init];
    });
    
    it(@"should init with disabled rotation", ^{
        expect(imageCropViewController.rotationEnabled).to.beFalsy();
    });
    
    it(@"should init with disabled masking image", ^{
        expect(imageCropViewController.applyMaskToCroppedImage).to.beFalsy();
    });
    
    it(@"should init with disabled avoiding empty space around image", ^{
        expect(imageCropViewController.avoidEmptySpaceAroundImage).to.beFalsy();
    });
    
    after(^{
        imageCropViewController = nil;
    });
});

describe(@"initWithImage:", ^{
    before(^{
        imageCropViewController = [[RSKImageCropViewController alloc] initWithImage:originalImage];
    });
    
    it(@"should init with the specified image", ^{
        expect(imageCropViewController.originalImage).to.equal(originalImage);
    });
    
    it(@"should init with default crop mode of `RSKImageCropModeCircle`", ^{
        expect(imageCropViewController.cropMode).to.equal(RSKImageCropModeCircle);
    });
    
    after(^{
        imageCropViewController = nil;
    });
});

describe(@"initWithImage:cropMode:", ^{
    it(@"should init with specified crop mode", ^{
        imageCropViewController = [[RSKImageCropViewController alloc] initWithImage:originalImage cropMode:RSKImageCropModeSquare];
        expect(imageCropViewController.cropMode).to.equal(RSKImageCropModeSquare);
    });
});

describe(@"empty space around the image", ^{
    it(@"sets `aspectFill` of `imageScrollView` identical to `avoidEmptySpaceAroundImage`", ^{
        BOOL testAvoidEmptySpaceAroundImage = YES;
        
        imageCropViewController = [[RSKImageCropViewController alloc] init];
        
        expect(imageCropViewController.imageScrollView.aspectFill).notTo.equal(testAvoidEmptySpaceAroundImage);
        
        imageCropViewController.avoidEmptySpaceAroundImage = testAvoidEmptySpaceAroundImage;
        
        expect(imageCropViewController.imageScrollView.aspectFill).to.equal(testAvoidEmptySpaceAroundImage);
    });
});

describe(@"crop image", ^{
    dispatch_block_t sharedIt = ^{
        UIImage *croppedImage = [imageCropViewController croppedImage:imageCropViewController.originalImage cropMode:imageCropViewController.cropMode cropRect:imageCropViewController.cropRect imageRect:imageCropViewController.imageRect rotationAngle:imageCropViewController.rotationAngle zoomScale:imageCropViewController.zoomScale maskPath:imageCropViewController.maskPath applyMaskToCroppedImage:imageCropViewController.applyMaskToCroppedImage];
        
        expect(croppedImage).notTo.beNil();
        expect(croppedImage.imageOrientation).to.equal(UIImageOrientationUp);
        expect(croppedImage.scale).to.equal(imageCropViewController.originalImage.scale);
    };
    
    describe(@"crop mode is `RSKImageCropModeCircle`", ^{
        before(^{
            imageCropViewController = [[RSKImageCropViewController alloc] initWithImage:originalImage cropMode:RSKImageCropModeCircle];
            
            sharedLoadView();
        });
        
        it(@"correctly crop the image when all properties are default", ^{
            sharedIt();
        });
        
        it(@"correctly crop the image when rotation angle is not equal to 0", ^{
            imageCropViewController.rotationAngle = M_PI_4;
            
            sharedIt();
        });
        
        it(@"correctly crop the image when `applyMaskToCroppedImage` is `YES`", ^{
            imageCropViewController.applyMaskToCroppedImage = YES;
            
            sharedIt();
        });
        
        after(^{
            imageCropViewController = nil;
        });
    });
    
    describe(@"crop mode is `RSKImageCropModeSquare`", ^{
        before(^{
            imageCropViewController = [[RSKImageCropViewController alloc] initWithImage:originalImage cropMode:RSKImageCropModeSquare];
            
            sharedLoadView();
        });
        
        it(@"correctly crop the image when all properties are default", ^{
            sharedIt();
        });
        
        it(@"correctly crop the image when rotation angle is not equal to 0", ^{
            imageCropViewController.rotationAngle = M_PI_4;
            
            sharedIt();
        });
        
        it(@"correctly crop the image when `applyMaskToCroppedImage` is `YES`", ^{
            imageCropViewController.applyMaskToCroppedImage = YES;
            
            sharedIt();
        });
        
        after(^{
            imageCropViewController = nil;
        });
    });
    
    describe(@"crop mode is `RSKImageCropModeCustom`", ^{
        before(^{
            RSKImageCropViewControllerDataSourceObject1 *dataSourceObject = [[RSKImageCropViewControllerDataSourceObject1 alloc] init];
            
            imageCropViewController = [[RSKImageCropViewController alloc] initWithImage:originalImage cropMode:RSKImageCropModeCustom];
            imageCropViewController.dataSource = dataSourceObject;
            
            sharedLoadView();
        });
        
        it(@"correctly crop the image when all properties are default", ^{
            sharedIt();
        });
        
        it(@"correctly crop the image when rotation angle is not equal to 0", ^{
            imageCropViewController.rotationAngle = M_PI_4;
            
            sharedIt();
        });
        
        it(@"correctly crop the image when `applyMaskToCroppedImage` is `YES`", ^{
            imageCropViewController.applyMaskToCroppedImage = YES;
            
            sharedIt();
        });
        
        after(^{
            imageCropViewController = nil;
        });
    });
    
    describe(@"crop image with any image orientation", ^{
        it(@"UIImageOrientationDown", ^{
            UIImage *downImage = [UIImage imageWithCGImage:originalImage.CGImage scale:originalImage.scale orientation:UIImageOrientationDown];
            
            imageCropViewController = [[RSKImageCropViewController alloc] initWithImage:downImage];
            
            sharedLoadView();
            sharedIt();
        });
        
        it(@"UIImageOrientationLeft", ^{
            UIImage *leftImage = [UIImage imageWithCGImage:originalImage.CGImage scale:originalImage.scale orientation:UIImageOrientationLeft];
            
            imageCropViewController = [[RSKImageCropViewController alloc] initWithImage:leftImage];
            
            sharedLoadView();
            sharedIt();
        });
        
        it(@"UIImageOrientationRight", ^{
            UIImage *rightImage = [UIImage imageWithCGImage:originalImage.CGImage scale:originalImage.scale orientation:UIImageOrientationRight];
            
            imageCropViewController = [[RSKImageCropViewController alloc] initWithImage:rightImage];
            
            sharedLoadView();
            sharedIt();
        });
        
        it(@"UIImageOrientationUpMirrored", ^{
            UIImage *upMirroredImage = [UIImage imageWithCGImage:originalImage.CGImage scale:originalImage.scale orientation:UIImageOrientationUpMirrored];
            
            imageCropViewController = [[RSKImageCropViewController alloc] initWithImage:upMirroredImage];
            
            sharedLoadView();
            sharedIt();
        });
        
        it(@"UIImageOrientationDownMirrored", ^{
            UIImage *downMirroredImage = [UIImage imageWithCGImage:originalImage.CGImage scale:originalImage.scale orientation:UIImageOrientationDownMirrored];
            
            imageCropViewController = [[RSKImageCropViewController alloc] initWithImage:downMirroredImage];
            
            sharedLoadView();
            sharedIt();
        });
        
        it(@"UIImageOrientationLeftMirrored", ^{
            UIImage *leftMirroredImage = [UIImage imageWithCGImage:originalImage.CGImage scale:originalImage.scale orientation:UIImageOrientationLeftMirrored];
            
            imageCropViewController = [[RSKImageCropViewController alloc] initWithImage:leftMirroredImage];
            
            sharedLoadView();
            sharedIt();
        });
        
        it(@"UIImageOrientationRightMirrored", ^{
            UIImage *rightMirroredImage = [UIImage imageWithCGImage:originalImage.CGImage scale:originalImage.scale orientation:UIImageOrientationRightMirrored];
            
            imageCropViewController = [[RSKImageCropViewController alloc] initWithImage:rightMirroredImage];
            
            sharedLoadView();
            sharedIt();
        });
    });
});

describe(@"crop size", ^{
    __block UIImage *originalImage1 = nil;
    __block UIImage *originalImage2 = nil;
    
    __block id mockImageCropViewController = nil;
    __block id mockImageCropViewControllerView = nil;
    
    __block RSKImageCropMode cropMode;
    __block UIImage *photo = nil;
    
    before(^{
        originalImage1 = [UIImage imageNamed:@"photo"];
        originalImage2 = [UIImage imageNamed:@"photo_2"];
        
        imageCropViewController = [[RSKImageCropViewController alloc] init];
        sharedLoadView();
        
        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        
        mockImageCropViewControllerView = [OCMockObject partialMockForObject:imageCropViewController.view];
        [[[mockImageCropViewControllerView stub] andReturn:window] window];
        
        mockImageCropViewController = [OCMockObject partialMockForObject:imageCropViewController];
        [[[mockImageCropViewController stub] andReturn:mockImageCropViewControllerView] view];
    });
    
    describe(@"when `avoidEmptySpaceAroundImage` is disabled", ^{
        
        dispatch_block_t sharedIt = ^{
            imageCropViewController.originalImage = photo;
            imageCropViewController.cropMode = cropMode;
            imageCropViewController.imageScrollView.zoomScale = imageCropViewController.imageScrollView.minimumZoomScale;
            
            CGFloat maxSize = (photo.size.width > photo.size.height) ? photo.size.width : photo.size.height;
            expect(imageCropViewController.cropRect.size).to.equal(CGSizeMake(maxSize, maxSize));
        };
        
        describe(@"when crop mode is `RSKImageCropModeCircle`", ^{
            before(^{
                cropMode = RSKImageCropModeCircle;
            });
            
            it(@"for photo", ^{
                photo = originalImage1;
                sharedIt();
            });
            
            it(@"for photo_2", ^{
                photo = originalImage2;
                sharedIt();
            });
            
            after(^{
                photo = nil;
            });
        });
        
        describe(@"when crop mode is `RSKImageCropModeSquare`", ^{
            before(^{
                cropMode = RSKImageCropModeSquare;
            });
            
            it(@"for photo", ^{
                photo = originalImage1;
                sharedIt();
            });
            
            it(@"for photo_2", ^{
                photo = originalImage2;
                sharedIt();
            });
            
            after(^{
                photo = nil;
            });
        });
    });
    
    describe(@"when `avoidEmptySpaceAroundImage` is enabled", ^{
        
        dispatch_block_t sharedIt = ^{
            imageCropViewController.originalImage = photo;
            imageCropViewController.cropMode = cropMode;
            imageCropViewController.imageScrollView.zoomScale = imageCropViewController.imageScrollView.minimumZoomScale;
            imageCropViewController.avoidEmptySpaceAroundImage = YES;
            
            CGFloat minSize = (photo.size.width < photo.size.height) ? photo.size.width : photo.size.height;
            expect(imageCropViewController.cropRect.size).to.equal(CGSizeMake(minSize, minSize));
        };
        
        describe(@"when crop mode is `RSKImageCropModeCircle`", ^{
            before(^{
                cropMode = RSKImageCropModeCircle;
            });
            
            it(@"for photo", ^{
                photo = originalImage1;
                sharedIt();
            });
            
            it(@"for photo_2", ^{
                photo = originalImage2;
                sharedIt();
            });
            
            after(^{
                photo = nil;
            });
        });
        
        describe(@"when crop mode is `RSKImageCropModeSquare`", ^{
            before(^{
                cropMode = RSKImageCropModeSquare;
            });
            
            it(@"for photo", ^{
                photo = originalImage1;
                sharedIt();
            });
            
            it(@"for photo_2", ^{
                photo = originalImage2;
                sharedIt();
            });
            
            after(^{
                photo = nil;
            });
        });
    });
    
    after(^{
        imageCropViewController = nil;
        
        [mockImageCropViewController stopMocking];
        mockImageCropViewController = nil;
        
        [mockImageCropViewControllerView stopMocking];
        mockImageCropViewControllerView = nil;
    });
});

describe(@"crop view", ^{
    dispatch_block_t sharedIt = ^{
        sharedLoadView();
        
        expect(imageCropViewController.view).to.haveValidSnapshot();
    };
    
    describe(@"portrait", ^{
        dispatch_block_t sharedPortraitIt = ^{
            imageCropViewController.view.frame = CGRectMake(0, 0, 320, 568);
            
            sharedIt();
        };
        
        describe(@"crop mode", ^{
            it(@"looks right when crop mode is `RSKImageCropModeCircle`", ^{
                imageCropViewController = [[RSKImageCropViewController alloc] initWithImage:originalImage cropMode:RSKImageCropModeCircle];
                
                sharedPortraitIt();
            });
            
            it(@"looks right when crop mode is `RSKImageCropModeSquare`", ^{
                imageCropViewController = [[RSKImageCropViewController alloc] initWithImage:originalImage cropMode:RSKImageCropModeSquare];
                
                sharedPortraitIt();
            });
            
            it(@"looks right when crop mode is `RSKImageCropModeCustom`", ^{
                RSKImageCropViewControllerDataSourceObject1 *dataSourceObject = [[RSKImageCropViewControllerDataSourceObject1 alloc] init];
                
                imageCropViewController = [[RSKImageCropViewController alloc] initWithImage:originalImage cropMode:RSKImageCropModeCustom];
                imageCropViewController.dataSource = dataSourceObject;
                
                sharedPortraitIt();
            });
        });
        
        describe(@"stroke of the mask", ^{
            it(@"looks right when stroked outline is visible", ^{
                imageCropViewController = [[RSKImageCropViewController alloc] initWithImage:originalImage cropMode:RSKImageCropModeSquare];
                imageCropViewController.maskLayerStrokeColor = [UIColor whiteColor];
                
                sharedPortraitIt();
            });
        });
    });
    
    describe(@"landscape", ^{
        dispatch_block_t sharedLandscapeIt = ^{
            imageCropViewController.view.frame = CGRectMake(0, 0, 568, 320);
            
            sharedIt();
        };
        
        describe(@"crop mode", ^{
            it(@"looks right when crop mode is `RSKImageCropModeCircle`", ^{
                imageCropViewController = [[RSKImageCropViewController alloc] initWithImage:originalImage cropMode:RSKImageCropModeCircle];
                
                sharedLandscapeIt();
            });
            
            it(@"looks right when crop mode is `RSKImageCropModeSquare`", ^{
                imageCropViewController = [[RSKImageCropViewController alloc] initWithImage:originalImage cropMode:RSKImageCropModeSquare];
                
                sharedLandscapeIt();
            });
            
            it(@"looks right when crop mode is `RSKImageCropModeCustom`", ^{
                RSKImageCropViewControllerDataSourceObject1 *dataSourceObject = [[RSKImageCropViewControllerDataSourceObject1 alloc] init];
                
                imageCropViewController = [[RSKImageCropViewController alloc] initWithImage:originalImage cropMode:RSKImageCropModeCustom];
                imageCropViewController.dataSource = dataSourceObject;
                
                sharedLandscapeIt();
            });
        });
        
        describe(@"stroke of the mask", ^{
            it(@"looks right when storked outline is visible", ^{
                imageCropViewController = [[RSKImageCropViewController alloc] initWithImage:originalImage cropMode:RSKImageCropModeSquare];
                imageCropViewController.maskLayerStrokeColor = [UIColor whiteColor];
                
                sharedLandscapeIt();
            });
        });
    });
});

describe(@"dataSource", ^{
    before(^{
        imageCropViewController = [[RSKImageCropViewController alloc] initWithImage:originalImage cropMode:RSKImageCropModeCustom];
    });
    
    describe(@"with all methods", ^{
        __block id <RSKImageCropViewControllerDataSource> dataSourceObject = nil;
        
        before(^{
            dataSourceObject = [[RSKImageCropViewControllerDataSourceObject1 alloc] init];
            imageCropViewController.dataSource = dataSourceObject;
        });
        
        it(@"gives the right custom mask rect", ^{
            CGRect customMaskRect = CGRectMake(20, 40, 250, 250);
            
            id dataSourceMock = [OCMockObject partialMockForObject:dataSourceObject];
            [[[dataSourceMock stub] andReturnValue:[NSValue valueWithCGRect:customMaskRect]] imageCropViewControllerCustomMaskRect:imageCropViewController];
            [[dataSourceMock expect] imageCropViewControllerCustomMaskRect:imageCropViewController];
            
            [imageCropViewController view];
            
            [imageCropViewController.view setNeedsUpdateConstraints];
            [imageCropViewController.view updateConstraintsIfNeeded];
            
            [imageCropViewController.view setNeedsLayout];
            [imageCropViewController.view layoutIfNeeded];
            
            expect(imageCropViewController.maskRect).to.equal(customMaskRect);
            
            [dataSourceMock stopMocking];
        });
        
        it(@"gives the right custom movement rect", ^{
            CGRect customMovementRect = CGRectMake(20, 40, 250, 250);
            
            id dataSourceMock = [OCMockObject partialMockForObject:dataSourceObject];
            [[[dataSourceMock stub] andReturnValue:[NSValue valueWithCGRect:customMovementRect]] imageCropViewControllerCustomMovementRect:imageCropViewController];
            [[dataSourceMock expect] imageCropViewControllerCustomMovementRect:imageCropViewController];
            
            [imageCropViewController view];
            
            [imageCropViewController.view setNeedsUpdateConstraints];
            [imageCropViewController.view updateConstraintsIfNeeded];
            
            [imageCropViewController.view setNeedsLayout];
            [imageCropViewController.view layoutIfNeeded];
            
            expect(imageCropViewController.imageScrollView.frame).to.equal(customMovementRect);
            
            [dataSourceMock stopMocking];
        });
        
        it(@"gives the right custom mask path", ^{
            CGRect customMaskRect = CGRectMake(20, 40, 250, 250);
            UIBezierPath *customMaskPath = [UIBezierPath bezierPathWithRect:customMaskRect];
            
            id dataSourceMock = [OCMockObject partialMockForObject:dataSourceObject];
            [[[dataSourceMock stub] andReturn:customMaskPath] imageCropViewControllerCustomMaskPath:imageCropViewController];
            [[dataSourceMock expect] imageCropViewControllerCustomMaskPath:imageCropViewController];
            
            [imageCropViewController view];
            
            [imageCropViewController.view setNeedsUpdateConstraints];
            [imageCropViewController.view updateConstraintsIfNeeded];
            
            [imageCropViewController.view setNeedsLayout];
            [imageCropViewController.view layoutIfNeeded];
            
            expect(imageCropViewController.maskPath).to.equal(customMaskPath);
            
            [dataSourceMock stopMocking];
        });
        
        after(^{
            dataSourceObject = nil;
        });
    });
    
    after(^{
        imageCropViewController = nil;
    });
});

describe(@"delegate", ^{
    before(^{
        imageCropViewController = [[RSKImageCropViewController alloc] init];
    });
    
    it(@"calls appropriate delegate methods before and after cropping image", ^{
        RSKImageCropViewControllerDelegateObject1 *delegateObject = [[RSKImageCropViewControllerDelegateObject1 alloc] init];
        imageCropViewController.delegate = delegateObject;
        
        id delegateMock = [OCMockObject partialMockForObject:delegateObject];
        
        [[delegateMock expect] imageCropViewController:imageCropViewController willCropImage:OCMOCK_ANY];
        [[delegateMock expect] imageCropViewController:imageCropViewController didCropImage:OCMOCK_ANY usingCropRect:imageCropViewController.cropRect rotationAngle:imageCropViewController.rotationAngle];
        
        [imageCropViewController cropImage];
        
        [delegateMock verifyWithDelay:1.0];
        [delegateMock stopMocking];
    });
    
    it(@"calls the appropriate delegate method if the user cancel cropping image", ^{
        RSKImageCropViewControllerDelegateObject1 *delegateObject = [[RSKImageCropViewControllerDelegateObject1 alloc] init];
        imageCropViewController.delegate = delegateObject;
        
        id delegateMock = [OCMockObject partialMockForObject:delegateObject];
        
        [[delegateMock expect] imageCropViewControllerDidCancelCrop:imageCropViewController];
        
        [imageCropViewController cancelCrop];
        
        [delegateMock verify];
        [delegateMock stopMocking];
    });
    
    it(@"calls the appropriate delegate method when the image is displayed", ^{
        RSKImageCropViewControllerDelegateObject1 *delegateObject = [[RSKImageCropViewControllerDelegateObject1 alloc] init];
        imageCropViewController.delegate = delegateObject;
        imageCropViewController.originalImage = originalImage;
        
        id delegateMock = [OCMockObject partialMockForObject:delegateObject];
        
        [[delegateMock expect] imageCropViewControllerDidDisplayImage:imageCropViewController];
        
        [imageCropViewController displayImage];
        
        [delegateMock verify];
        [delegateMock stopMocking];
    });
    
    after(^{
        imageCropViewController = nil;
    });
});

describe(@"navigation controller navigation bar", ^{
    it(@"hides navigation bar in viewWillAppear:", ^{
        imageCropViewController = [[RSKImageCropViewController alloc] init];
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:imageCropViewController];
        id mock = [OCMockObject partialMockForObject:navigationController];
        
        [[mock expect] setNavigationBarHidden:YES animated:NO];
        
        [imageCropViewController view];
        [imageCropViewController viewWillAppear:NO];
        
        [mock verify];
    });
    
    it(@"restores visibility of the navigation bar in viewWillDisappear:", ^{
        imageCropViewController = [[RSKImageCropViewController alloc] init];
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:imageCropViewController];
        id mock = [OCMockObject partialMockForObject:navigationController];
        
        [imageCropViewController view];
        [imageCropViewController viewWillAppear:NO];
        
        [[mock expect] setNavigationBarHidden:imageCropViewController.originalNavigationControllerNavigationBarHidden animated:NO];
        
        [imageCropViewController viewWillDisappear:NO];
        
        [mock verify];
    });
    
    after(^{
        imageCropViewController = nil;
    });
});

describe(@"original image", ^{
    before(^{
        imageCropViewController = [[RSKImageCropViewController alloc] init];
        sharedLoadView();
    });
    
    it(@"displays new original image", ^{
        id mockImageCropViewControllerView = [OCMockObject partialMockForObject:imageCropViewController.view];
        [[[mockImageCropViewControllerView stub] andReturn:[[UIWindow alloc] init]] window];
        
        id mockImageCropViewController = [OCMockObject partialMockForObject:imageCropViewController];
        [[[mockImageCropViewController stub] andReturn:mockImageCropViewControllerView] view];
        [[mockImageCropViewController expect] displayImage];
        
        imageCropViewController.originalImage = originalImage;
        
        [mockImageCropViewController verify];
        [mockImageCropViewController stopMocking];
        [mockImageCropViewControllerView stopMocking];
    });
    
    after(^{
        imageCropViewController = nil;
    });
});

describe(@"reset", ^{
    before(^{
        imageCropViewController = [[RSKImageCropViewController alloc] initWithImage:originalImage];
        sharedLoadView();
    });
    
    it(@"should reset rotation", ^{
        CGFloat initialRotationAngle = imageCropViewController.rotationAngle;
        CGFloat testRotationAngle = M_PI_2;
        imageCropViewController.rotationAngle = testRotationAngle;
        [imageCropViewController resetRotation];
        expect(imageCropViewController.rotationAngle).to.equal(initialRotationAngle);
    });
    
    it(@"should reset frame", ^{
        CGRect initialFrame = imageCropViewController.imageScrollView.frame;
        CGRect testFrame = CGRectOffset(imageCropViewController.maskRect, 100, 100);
        imageCropViewController.imageScrollView.frame = testFrame;
        [imageCropViewController resetFrame];
        expect(imageCropViewController.imageScrollView.frame).to.equal(initialFrame);
    });
    
    it(@"should reset zoom scale", ^{
        CGFloat initialZoomScale = imageCropViewController.zoomScale;
        CGFloat testZoomScale = initialZoomScale + 0.1;
        imageCropViewController.imageScrollView.zoomScale = testZoomScale;
        [imageCropViewController resetZoomScale];
        expect(imageCropViewController.zoomScale).to.equal(initialZoomScale);
    });
    
    it(@"should reset content offset", ^{
        CGPoint initialContentOffset = imageCropViewController.imageScrollView.contentOffset;
        CGPoint testContentOffset = CGPointMake(initialContentOffset.x + 50, initialContentOffset.y + 50);
        imageCropViewController.imageScrollView.contentOffset = testContentOffset;
        [imageCropViewController resetContentOffset];
        expect(imageCropViewController.imageScrollView.contentOffset).to.equal(initialContentOffset);
    });
    
    it(@"should reset rotation, frame, zoom scale, content offset", ^{
        CGFloat initialRotationAngle = imageCropViewController.rotationAngle;
        CGRect initialFrame = imageCropViewController.imageScrollView.frame;
        CGFloat initialZoomScale = imageCropViewController.zoomScale;
        CGPoint initialContentOffset = imageCropViewController.imageScrollView.contentOffset;
        
        CGFloat testRotationAngle = M_PI_2;
        CGRect testFrame = CGRectOffset(imageCropViewController.maskRect, 100, 100);
        CGFloat testZoomScale = initialZoomScale + 0.1;
        CGPoint testContentOffset = CGPointMake(initialContentOffset.x + 50, initialContentOffset.y + 50);
        
        imageCropViewController.rotationAngle = testRotationAngle;
        
        CGAffineTransform transform = imageCropViewController.imageScrollView.transform;
        imageCropViewController.imageScrollView.transform = CGAffineTransformIdentity;
        imageCropViewController.imageScrollView.frame = testFrame;
        imageCropViewController.imageScrollView.transform = transform;
        
        imageCropViewController.imageScrollView.zoomScale = testZoomScale;
        imageCropViewController.imageScrollView.contentOffset = testContentOffset;
        
        [imageCropViewController reset:NO];
        
        expect(imageCropViewController.rotationAngle).to.equal(initialRotationAngle);
        expect(imageCropViewController.imageScrollView.frame).to.equal(initialFrame);
        expect(imageCropViewController.zoomScale).to.equal(initialZoomScale);
        expect(imageCropViewController.imageScrollView.contentOffset).to.equal(initialContentOffset);
    });
    
    after(^{
        imageCropViewController = nil;
    });
});

describe(@"rotation", ^{
    __block id mockRotationGestureRecognizer = nil;
    __block CGFloat testRotationAngle;
    
    before(^{
        testRotationAngle = M_PI_2;
        
        UIRotationGestureRecognizer *rotationGestureRecognizer = [[UIRotationGestureRecognizer alloc] init];
        mockRotationGestureRecognizer = [OCMockObject partialMockForObject:rotationGestureRecognizer];
        [[[mockRotationGestureRecognizer stub] andReturnValue:@(testRotationAngle)] rotation];
        [[[mockRotationGestureRecognizer stub] andReturnValue:@(UIGestureRecognizerStateEnded)] state];
    });
    
    it(@"enables the rotation", ^{
        imageCropViewController = [[RSKImageCropViewController alloc] init];
        BOOL testRotationEnabled = YES;
        
        id mockRotationGestureRecognizer = [OCMockObject partialMockForObject:imageCropViewController.rotationGestureRecognizer];
        [[mockRotationGestureRecognizer expect] setEnabled:testRotationEnabled];
        
        imageCropViewController.rotationEnabled = testRotationEnabled;
        
        [mockRotationGestureRecognizer verify];
        [mockRotationGestureRecognizer stopMocking];
    });
    
    it(@"handles the rotation", ^{
        imageCropViewController = [[RSKImageCropViewController alloc] init];
        id mockImageCropViewController = [OCMockObject partialMockForObject:imageCropViewController];
        
        [[mockImageCropViewController expect] setRotationAngle:testRotationAngle];
        [[mockImageCropViewController expect] layoutImageScrollView];
        
        [mockImageCropViewController handleRotation:mockRotationGestureRecognizer];
        
        [mockImageCropViewController verifyWithDelay:kLayoutImageScrollViewAnimationDuration];
        [mockImageCropViewController stopMocking];
    });
    
    it(@"correctly sets the rotation angle", ^{
        imageCropViewController = [[RSKImageCropViewController alloc] init];
        imageCropViewController.rotationAngle = testRotationAngle;
        
        expect(imageCropViewController.rotationAngle).to.equal(testRotationAngle);
    });
    
    describe(@"movement rect", ^{
        dispatch_block_t sharedIt = ^{
            sharedLoadView();
            
            [imageCropViewController handleRotation:mockRotationGestureRecognizer];
        };
        
        it(@"correctly sets the movement rect after rotation when crop mode is `RSKImageCropModeCircle`", ^{
            imageCropViewController = [[RSKImageCropViewController alloc] initWithImage:originalImage cropMode:RSKImageCropModeCircle];
            
            sharedIt();
            
            expect(imageCropViewController.imageScrollView.frame).after(kLayoutImageScrollViewAnimationDuration).to.equal(imageCropViewController.maskRect);
        });
        
        it(@"correctly sets the movement rect after rotation when crop mode is `RSKImageCropModeSquare`", ^{
            imageCropViewController = [[RSKImageCropViewController alloc] initWithImage:originalImage cropMode:RSKImageCropModeSquare];
            
            sharedIt();
            
            expect(imageCropViewController.imageScrollView.frame).after(kLayoutImageScrollViewAnimationDuration).to.equal(imageCropViewController.maskRect);
        });
        
        it(@"correctly sets the movement rect after rotation when crop mode is `RSKImageCropModeCustom`", ^{
            RSKImageCropViewControllerDataSourceObject1 *dataSourceObject = [[RSKImageCropViewControllerDataSourceObject1 alloc] init];
            imageCropViewController = [[RSKImageCropViewController alloc] initWithImage:originalImage cropMode:RSKImageCropModeCustom];
            imageCropViewController.dataSource = dataSourceObject;
            
            sharedIt();
            
            expect(imageCropViewController.imageScrollView.frame).after(kLayoutImageScrollViewAnimationDuration).to.equal([dataSourceObject imageCropViewControllerCustomMovementRect:imageCropViewController]);
        });
        
        after(^{
            imageCropViewController = nil;
        });
    });
    
    after(^{
        [mockRotationGestureRecognizer stopMocking];
        mockRotationGestureRecognizer = nil;
        
        imageCropViewController = nil;
    });
});

describe(@"status bar", ^{
    if (@available(iOS 7.0, *)) {
        
        it(@"hides status bar", ^{
            
            imageCropViewController = [[RSKImageCropViewController alloc] init];
            expect(imageCropViewController.prefersStatusBarHidden).to.beTruthy();
        });
    }
    else {
        
        it(@"hides status bar in viewWillAppear:", ^{
            UIApplication *application = [UIApplication sharedApplication];
            id mock = [OCMockObject partialMockForObject:application];
            
            [[mock expect] setStatusBarHidden:YES];
            
            imageCropViewController = [[RSKImageCropViewController alloc] init];
            [imageCropViewController view];
            [imageCropViewController viewWillAppear:NO];
            
            [mock verify];
        });
        
        it(@"restores visibility of the status bar in viewWillDisappear:", ^{
            imageCropViewController = [[RSKImageCropViewController alloc] init];
            
            UIApplication *application = [UIApplication sharedApplication];
            id mock = [OCMockObject partialMockForObject:application];
            
            [imageCropViewController view];
            [imageCropViewController viewWillAppear:NO];
            
            [[mock expect] setStatusBarHidden:imageCropViewController.originalStatusBarHidden];
            
            [imageCropViewController viewWillDisappear:NO];
            
            [mock verify];
        });
    }
});

describe(@"taps", ^{
    before(^{
        imageCropViewController = [[RSKImageCropViewController alloc] init];
    });
    
    it(@"handles double tap on the image", ^{
        id mock = [OCMockObject partialMockForObject:imageCropViewController];
        [[mock expect] reset:YES];
        
        [imageCropViewController handleDoubleTap:nil];
        
        [mock verify];
    });
    
    it(@"handles tap on the cancel button", ^{
        id mock = [OCMockObject partialMockForObject:imageCropViewController];
        [[mock expect] cancelCrop];
        
        [imageCropViewController onCancelButtonTouch:nil];
        
        [mock verify];
    });
    
    it(@"handles tap on the choose button", ^{
        id mock = [OCMockObject partialMockForObject:imageCropViewController];
        [[mock expect] cropImage];
        
        [imageCropViewController onChooseButtonTouch:nil];
        
        [mock verify];
    });
    
    after(^{
        imageCropViewController = nil;
    });
});

describe(@"zoomToRect", ^{
    before(^{
        imageCropViewController = [[RSKImageCropViewController alloc] initWithImage:originalImage];
        sharedLoadView();
    });
    
    it(@"zooms to a specific area of the image", ^{
        CGRect rect = CGRectMake(100.0, 100.0, 400.0, 400.0);
        [imageCropViewController zoomToRect:rect animated:NO];
        
        UIScrollView *imageScrollView = imageCropViewController.imageScrollView;
        CGRect visibleRect = CGRectMake(round(imageScrollView.contentOffset.x / imageScrollView.zoomScale),
                                        round(imageScrollView.contentOffset.y / imageScrollView.zoomScale),
                                        imageScrollView.bounds.size.width / imageScrollView.zoomScale,
                                        imageScrollView.bounds.size.height / imageScrollView.zoomScale);
        
        BOOL contains = CGRectContainsRect(visibleRect, rect);
        expect(contains).to.beTruthy();
    });
    
    after(^{
        imageCropViewController = nil;
    });
});

afterAll(^{
    originalImage = nil;
    imageCropViewController = nil;
});

SpecEnd
