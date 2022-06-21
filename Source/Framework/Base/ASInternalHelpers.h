//
//  ASInternalHelpers.h
//  Texture
//
//  Copyright (c) Facebook, Inc. and its affiliates.  All rights reserved.
//  Changes after 4/13/2017 are: Copyright (c) Pinterest, Inc.  All rights reserved.
//  Licensed under Apache 2.0: http://www.apache.org/licenses/LICENSE-2.0
//

#import <UIKit/UIKit.h>

#import "ASBaseDefines.h"

NS_ASSUME_NONNULL_BEGIN

ASDK_EXTERN CGFloat ASFloorPixelValue(CGFloat f);

ASDK_EXTERN CGPoint ASCeilPointValues(CGPoint p);

ASDK_EXTERN CGFloat ASCeilPixelValue(CGFloat f);

ASDK_EXTERN CGFloat ASRoundPixelValue(CGFloat f);

NS_ASSUME_NONNULL_END
