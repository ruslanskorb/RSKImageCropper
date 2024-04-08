//
// RSKImageScrollViewDelegate.h
//
// Copyright (c) 2022-present Ruslan Skorb, https://ruslanskorb.com
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

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

/**
 The interface for the delegate of an image scroll view.
 */
NS_SWIFT_UI_ACTOR
@protocol RSKImageScrollViewDelegate <NSObject>

@optional

/**
 Tells the delegate when the user scrolls the image within the image scroll view.
 */
- (void)imageScrollViewDidScroll;

/**
 Tells the delegate when the image scroll view is about to start scrolling the image.
 */
- (void)imageScrollViewWillBeginDragging;

/**
 Tells the delegate when dragging ended in the image scroll view.
 
 @param willDecelerate `YES` if the scrolling movement will continue, but decelerate, after a touch-up gesture during a dragging operation. If the value is `NO`, scrolling stops immediately upon touch-up.
 */
- (void)imageScrollViewDidEndDragging:(BOOL)willDecelerate;

/**
 Tells the delegate that the image scroll view ended decelerating the scrolling movement.
 */
- (void)imageScrollViewDidEndDecelerating;

/**
 Tells the delegate that zooming of the image in the image scroll view is about to commence.
 */
- (void)imageScrollViewWillBeginZooming;

/**
 Tells the delegate when zooming of the image in the image scroll view completed.
 */
- (void)imageScrollViewDidEndZooming;

@end

NS_ASSUME_NONNULL_END
