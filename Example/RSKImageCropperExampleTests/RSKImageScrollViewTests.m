//
// RSKImageScrollViewTests.m
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

#import "RSKImageScrollView.h"

SpecBegin(RSKImageScrollView)

__block RSKImageScrollView *imageScrollView = nil;
__block UIImage *image = nil;

dispatch_block_t sharedIt = ^{
    [imageScrollView displayImage:image];
    
    [imageScrollView setNeedsLayout];
    [imageScrollView layoutIfNeeded];
};

before(^{
    imageScrollView = [[RSKImageScrollView alloc] initWithFrame:CGRectMake(0, 0, 320, 320)];
    imageScrollView.clipsToBounds = NO;
    image = [UIImage imageNamed:@"photo"];
});

describe(@"visuals", ^{
    it(@"looks right by default", ^{
        sharedIt();
        
        expect(imageScrollView).haveValidSnapshot();
    });
    
    it(@"looks right with minimum zoom scale", ^{
        sharedIt();
        imageScrollView.zoomScale = imageScrollView.minimumZoomScale;
        
        expect(imageScrollView).haveValidSnapshot();
    });
    
    it(@"looks right with minimum zoom scale and when `aspectFill` is `YES`", ^{
        imageScrollView.aspectFill = YES;
        sharedIt();
        imageScrollView.zoomScale = imageScrollView.minimumZoomScale;
        
        expect(imageScrollView).haveValidSnapshot();
    });
});

after(^{
    imageScrollView = nil;
    image = nil;
});

SpecEnd
