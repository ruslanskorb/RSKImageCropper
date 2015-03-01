## RSKImageCropper

<p align="center">
	<img src="Screenshot.png" alt="Sample">
</p>

An image cropper for iOS like in the Contacts app with support for landscape orientation.

## Installation

[CocoaPods](http://cocoapods.org) is the recommended method of installing RSKImageCropper. Simply add the following line to your `Podfile`:

#### Podfile

```ruby
pod 'RSKImageCropper'
```

## Basic Usage

Import the class header.

``` objective-c
#import "RSKImageCropViewController.h"
```

Just create a view controller for image cropping and set the delegate.

``` objective-c
- (IBAction)onButtonTouch:(UIButton *)sender
{
    UIImage *image = [UIImage imageNamed:@"image"];
    RSKImageCropViewController *imageCropVC = [[RSKImageCropViewController alloc] initWithImage:image];
    imageCropVC.delegate = self;
    [self.navigationController pushViewController:imageCropVC animated:YES];
}
```

## Delegate

`RSKImageCropViewControllerDelegate` provides four delegate methods. To use them, implement the delegate in your view controller.

```objective-c
@interface ViewController () <RSKImageCropViewControllerDelegate>
```

Then implement the delegate functions.

```objective-c
// Crop image has been canceled.
- (void)imageCropViewControllerDidCancelCrop:(RSKImageCropViewController *)controller
{
    [self.navigationController popViewControllerAnimated:YES];
}

// The original image will be cropped.
- (void)imageCropViewController:(RSKImageCropViewController *)controller willCropImage:(UIImage *)originalImage
{
    // Use when `applyMaskToCroppedImage` set to YES
    // or when `rotationEnabled` set to YES.
    [SVProgressHUD show];
}

// The original image has been cropped.
- (void)imageCropViewController:(RSKImageCropViewController *)controller didCropImage:(UIImage *)croppedImage usingCropRect:(CGRect)cropRect
{
    self.imageView.image = croppedImage;
    [self.navigationController popViewControllerAnimated:YES];
}

// The original image has been cropped. Additionally provides a rotation angle used to produce image.
- (void)imageCropViewController:(RSKImageCropViewController *)controller didCropImage:(UIImage *)croppedImage usingCropRect:(CGRect)cropRect rotationAngle:(CGFloat)rotationAngle
{
    self.imageView.image = croppedImage;
    [self.navigationController popViewControllerAnimated:YES];
}
```

## DataSource

`RSKImageCropViewControllerDataSource` provides two data source methods. The method `imageCropViewControllerCustomMaskRect:` asks the data source a custom rect for the mask. The method `imageCropViewControllerCustomMaskPath:` asks the data source a custom path for the mask. To use them, implement the data source in your view controller.

```objective-c
@interface ViewController () <RSKImageCropViewControllerDataSource>
```

Then implement the data source functions.

```objective-c
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
```

## Coming Soon

- If you would like to request a new feature, feel free to raise as an issue.

## Demo

Build and run the `RSKImageCropperExample` project in Xcode to see `RSKImageCropper` in action.
Have fun. Fork and send pull requests. Figure out hooks for customization.

## Contact

Ruslan Skorb

- http://github.com/ruslanskorb
- http://twitter.com/ruslanskorb
- ruslan.skorb@gmail.com

## License

This project is is available under the MIT license. See the LICENSE file for more info. Attribution by linking to the [project page](https://github.com/ruslanskorb/RSKImageCropper) is appreciated.
