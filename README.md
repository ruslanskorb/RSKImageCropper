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

`RSKImageCropViewControllerDelegate` provides two delegate methods. To use them, implement the delegate in your view controller.

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

// The original image has been cropped.
- (void)imageCropViewController:(RSKImageCropViewController *)controller didCropImage:(UIImage *)croppedImage
{
    self.imageView.image = croppedImage;
    [self.navigationController popViewControllerAnimated:YES];
}
```

## Coming Soon

- Add more cropping guides.
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
