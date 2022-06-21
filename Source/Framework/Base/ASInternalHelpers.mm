//
//  ASInternalHelpers.mm
//  Texture
//
//  Copyright (c) Facebook, Inc. and its affiliates.  All rights reserved.
//  Changes after 4/13/2017 are: Copyright (c) Pinterest, Inc.  All rights reserved.
//  Licensed under Apache 2.0: http://www.apache.org/licenses/LICENSE-2.0
//

#import "ASInternalHelpers.h"

CGFloat ASScreenScale()
{
  static CGFloat __scale = 0.0;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(1, 1), YES, 0);
    __scale = CGContextGetCTM(UIGraphicsGetCurrentContext()).a;
    UIGraphicsEndImageContext();
  });
  return __scale;
}

// See ASCeilPixelValue for a more thoroguh explanation of (f + FLT_EPSILON),
// but here is some quick math:
//
// Imagine a layout that comes back with a height of 100.66666666663
// for a 3x deice:
// 100.66666666663 * 3 = 301.99999999988995
// floor(301.99999999988995) = 301
// 301 / 3 = 100.333333333
//
// If we add FLT_EPSILON to normalize the garbage at the end we get:
// po (100.66666666663 + FLT_EPSILON) * 3 = 302.00000035751782
// floor(302.00000035751782) = 302
// 302/3 = 100.66666666
CGFloat ASFloorPixelValue(CGFloat f)
{
  CGFloat scale = ASScreenScale();
  return floor((f + FLT_EPSILON) * scale) / scale;
}

CGPoint ASCeilPointValues(CGPoint p)
{
  return CGPointMake(ASCeilPixelValue(p.x), ASCeilPixelValue(p.y));
}

// With 3x devices layouts will often to compute to pixel bounds but
// include garbage values beyond the precision of a float/double.
// This garbage can result in a pixel value being rounded up when it isn't
// necessary.
//
// For example, imagine a layout that comes back with a height of 100.666666666669
// for a 3x device:
// 100.666666666669 * 3 = 302.00000000000699
// ceil(302.00000000000699) = 303
// 303/3 = 101
//
// If we use FLT_EPSILON to get rid of the garbage at the end of the value,
// things work as expected:
// (100.666666666669 - FLT_EPSILON) * 3 = 301.99999964237912
// ceil(301.99999964237912) = 302
// 302/3 = 100.666666666
//
// For even more conversation around this, see:
// https://github.com/TextureGroup/Texture/issues/838
CGFloat ASCeilPixelValue(CGFloat f)
{
  CGFloat scale = ASScreenScale();
  return ceil((f - FLT_EPSILON) * scale) / scale;
}

CGFloat ASRoundPixelValue(CGFloat f)
{
  CGFloat scale = ASScreenScale();
  return round(f * scale) / scale;
}

