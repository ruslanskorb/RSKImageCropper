//
// RSKExampleViewController.m
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

#import "RSKExampleViewController.h"
#import "RSKImageCropper.h"

static const CGFloat kPhotoDiameter = 130.0f;

@interface RSKExampleViewController () <RSKImageCropViewControllerDelegate>

@property (strong, nonatomic) UIView *photoFrameView;
@property (strong, nonatomic) UIButton *addPhotoButton;
@property (strong, nonatomic) UISegmentedControl *maskShapeControl;
@property (readwrite, nonatomic) RSKImageCropMaskShape maskShape;
@property (assign, nonatomic) BOOL didSetupConstraints;

@end

@implementation RSKExampleViewController

#pragma mark - Lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)]) {
        self.edgesForExtendedLayout = UIRectEdgeNone;
    }
    
    self.navigationItem.title = @"RSKImageCropper";
    
    // ---------------------------
    // Add the frame of the photo.
    // ---------------------------
    
    self.photoFrameView = [[UIView alloc] init];
    self.photoFrameView.backgroundColor = [UIColor colorWithRed:182/255.0f green:182/255.0f blue:187/255.0f alpha:1.0f];
    self.photoFrameView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.photoFrameView];
    
    // ---------------------------
    // Add the button "add photo".
    // ---------------------------
    
    self.addPhotoButton = [[UIButton alloc] init];
    self.addPhotoButton.backgroundColor = [UIColor whiteColor];
    self.addPhotoButton.translatesAutoresizingMaskIntoConstraints = NO;
    self.addPhotoButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
    self.addPhotoButton.titleLabel.lineBreakMode = NSLineBreakByWordWrapping;
    self.addPhotoButton.titleLabel.textAlignment = NSTextAlignmentCenter;
    [self.addPhotoButton setTitle:@"add\nphoto" forState:UIControlStateNormal];
    [self.addPhotoButton setTitleColor:[UIColor colorWithRed:0/255.0f green:122/255.0f blue:255/255.0f alpha:1.0f] forState:UIControlStateNormal];
    [self.addPhotoButton addTarget:self action:@selector(onAddPhotoButtonTouch:) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.addPhotoButton];
    
    self.maskShapeControl = [[UISegmentedControl alloc] initWithItems:@[@"Oval", @"Square"]];
    self.maskShapeControl.selectedSegmentIndex = 0;
    self.maskShapeControl.translatesAutoresizingMaskIntoConstraints = NO;
    [self.maskShapeControl addTarget:self
                             action:@selector(updateMaskShape)
                   forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.maskShapeControl];
    
    self.maskShape = RSKImageCropMaskOval;
    
    // ----------------
    // Add constraints.
    // ----------------
    
    [self.view setNeedsUpdateConstraints];
}

- (void)updateViewConstraints
{
    [super updateViewConstraints];
    
    if (self.didSetupConstraints) {
        return;
    }
    
    // ---------------------------
    // The frame of the photo.
    // ---------------------------
    
    NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:self.photoFrameView attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual
                                                                     toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f
                                                                   constant:(self.photoFrameView.layer.cornerRadius * 2)];
    [self.photoFrameView addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.photoFrameView attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual
                                                 toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f
                                               constant:(self.photoFrameView.layer.cornerRadius * 2)];
    [self.photoFrameView addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.photoFrameView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual
                                                 toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0f
                                               constant:0.0f];
    [self.view addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.photoFrameView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual
                                                 toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0f
                                               constant:0.0f];
    [self.view addConstraint:constraint];
    
    // ---------------------------
    // The button "add photo".
    // ---------------------------
    
    constraint = [NSLayoutConstraint constraintWithItem:self.addPhotoButton attribute:NSLayoutAttributeWidth relatedBy:NSLayoutRelationEqual
                                                 toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f
                                               constant:kPhotoDiameter];
    [self.addPhotoButton addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.addPhotoButton attribute:NSLayoutAttributeHeight relatedBy:NSLayoutRelationEqual
                                                 toItem:nil attribute:NSLayoutAttributeNotAnAttribute multiplier:1.0f
                                               constant:kPhotoDiameter];
    [self.addPhotoButton addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.addPhotoButton attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual
                                                 toItem:self.photoFrameView attribute:NSLayoutAttributeCenterX multiplier:1.0f
                                               constant:0.0f];
    [self.view addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.addPhotoButton attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual
                                                 toItem:self.photoFrameView attribute:NSLayoutAttributeCenterY multiplier:1.0f
                                               constant:0.0f];
    [self.view addConstraint:constraint];
    
    // ---------------------------
    // Mask shape control
    // ---------------------------
    
    constraint = [NSLayoutConstraint constraintWithItem:self.maskShapeControl
                                              attribute:NSLayoutAttributeTop
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.view
                                              attribute:NSLayoutAttributeTop
                                             multiplier:1
                                               constant:20];
    [self.view addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.maskShapeControl
                                              attribute:NSLayoutAttributeCenterX
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self.view
                                              attribute:NSLayoutAttributeCenterX
                                             multiplier:1
                                               constant:0];
    [self.view addConstraint:constraint];
    
    self.didSetupConstraints = YES;
}

#pragma mark - Accessors

-(void)setMaskShape:(RSKImageCropMaskShape)maskShape
{
    _maskShape = maskShape;
//    [self resetPhoto];
    [self updateAddPhotoButtonShape];
}

-(void) resetPhoto
{
    [self.addPhotoButton setImage:nil forState:UIControlStateNormal];
}

-(void) updateAddPhotoButtonShape
{
    switch (self.maskShape) {
        case RSKImageCropMaskOval:
            [self makeAddPhotoButtonOval];
            break;
            
        case RSKImageCropMaskSquare:
            [self makeAddPhotoButtonSquare];
            break;
            
        default:
            [self makeAddPhotoButtonOval];
            break;
    }
}

-(void) makeAddPhotoButtonOval
{
    self.addPhotoButton.layer.masksToBounds = YES;
    self.addPhotoButton.layer.cornerRadius = kPhotoDiameter / 2;
    self.photoFrameView.layer.masksToBounds = YES;
    self.photoFrameView.layer.cornerRadius = (kPhotoDiameter + 2) / 2;
}

-(void) makeAddPhotoButtonSquare
{
    self.addPhotoButton.layer.masksToBounds = NO;
    self.addPhotoButton.layer.cornerRadius = 0;
    self.photoFrameView.layer.masksToBounds = NO;
    self.photoFrameView.layer.cornerRadius = 0;
}

#pragma mark - Action handling

-(void) updateMaskShape
{
    if (self.maskShapeControl.selectedSegmentIndex == 0)
    {
        self.maskShape = RSKImageCropMaskOval;
    }
    else
    {
        self.maskShape = RSKImageCropMaskSquare;
    }
}

- (void)onAddPhotoButtonTouch:(UIButton *)sender
{
    UIImage *photo = [UIImage imageNamed:@"photo"];
    RSKImageCropViewController *imageCropVC = [[RSKImageCropViewController alloc] initWithImage:photo];
    imageCropVC.delegate = self;
    imageCropVC.maskShape = self.maskShape;
    [self.navigationController pushViewController:imageCropVC animated:YES];
}

#pragma mark - RSKImageCropViewControllerDelegate

- (void)imageCropViewControllerDidCancelCrop:(RSKImageCropViewController *)controller
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)imageCropViewController:(RSKImageCropViewController *)controller didCropImage:(UIImage *)croppedImage
{
    [self.addPhotoButton setImage:croppedImage forState:UIControlStateNormal];
    [self.navigationController popViewControllerAnimated:YES];
}

@end
