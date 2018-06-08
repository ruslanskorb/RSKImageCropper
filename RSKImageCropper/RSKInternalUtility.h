//
// RSKInternalUtility.h
//
// Copyright (c) 2015-present Ruslan Skorb, http://ruslanskorb.com/
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

/**
 Returns a localized version of the string designated by the specified key and residing in the RSKImageCropper table.
 
 @param key The key for a string in the RSKImageCropper table.
 @param comment The comment to place above the key-value pair in the strings file.
 
 @return A localized version of the string designated by key in the RSKImageCropper table.
 */
FOUNDATION_EXPORT NSString * RSKLocalizedString(NSString *key, NSString *comment);

@interface RSKInternalUtility : NSObject

/**
 Returns the NSBundle object for returning localized strings.
 
 @return The NSBundle object for returning localized strings.
 
 @discussion We assume a convention of a bundle named RSKImageCropperStrings.bundle, otherwise we
 return the bundle associated with the RSKInternalUtility class.
 */
+ (NSBundle *)bundleForStrings;

@end
