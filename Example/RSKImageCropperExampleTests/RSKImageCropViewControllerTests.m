//
//  RSKImageCropViewControllerTests.m
//  RSKImageCropperExample
//
//  Created by Ruslan Skorb on 4/18/15.
//  Copyright (c) 2015 Ruslan Skorb. All rights reserved.
//

#import "RSKImageCropViewController.h"

SpecBegin(RSKImageCropViewController)

describe(@"init", ^{
    __block RSKImageCropViewController *imageCropViewController = nil;
    
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
});

describe(@"initWithImage:", ^{
    __block UIImage *image = nil;
    __block RSKImageCropViewController *imageCropViewController = nil;
    
    before(^{
        image = [UIImage imageNamed:@"photo"];
        imageCropViewController = [[RSKImageCropViewController alloc] initWithImage:image];
    });
    
    it(@"should init with the specified image", ^{
        expect(imageCropViewController.originalImage).to.equal(image);
    });
    
    it(@"should init with default crop mode of `RSKImageCropModeCircle`", ^{
        expect(imageCropViewController.cropMode).to.equal(RSKImageCropModeCircle);
    });
});

describe(@"initWithImage:cropMode:", ^{
    it(@"should init with specified crop mode", ^{
        RSKImageCropViewController *imageCropViewController = [[RSKImageCropViewController alloc] initWithImage:nil cropMode:RSKImageCropModeSquare];
        expect(imageCropViewController.cropMode).to.equal(RSKImageCropModeSquare);
    });
});

SpecEnd
