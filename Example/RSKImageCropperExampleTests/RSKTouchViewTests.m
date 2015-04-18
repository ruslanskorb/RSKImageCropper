//
// RSKTouchViewTests.m
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

#import "RSKTouchView.h"

SpecBegin(RSKTouchView)

__block UIView *receiver = nil;
__block RSKTouchView *touchView = nil;

before(^{
    receiver = [[UIView alloc] init];
    
    touchView = [[RSKTouchView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
    touchView.receiver = receiver;
});

describe(@"hit test", ^{
    it(@"returns the receiver if the view contains the specified point", ^{
        CGPoint touchPoint = CGPointMake(50, 100);
        UIView *farthestDescendant = [touchView hitTest:touchPoint withEvent:nil];
        
        expect(farthestDescendant).to.equal(receiver);
    });
    
    it(@"returns `nil` if the view does not contain the specified point", ^{
        CGPoint touchPoint = CGPointMake(50, 520);
        UIView *farthestDescendant = [touchView hitTest:touchPoint withEvent:nil];
        
        expect(farthestDescendant).to.beNil();
    });
});

after(^{
    receiver = nil;
    touchView = nil;
});

SpecEnd
