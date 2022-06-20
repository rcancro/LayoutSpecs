//
//  ASAssert.h
//  Texture
//
//  Copyright (c) Facebook, Inc. and its affiliates.  All rights reserved.
//  Changes after 4/13/2017 are: Copyright (c) Pinterest, Inc.  All rights reserved.
//  Licensed under Apache 2.0: http://www.apache.org/licenses/LICENSE-2.0
//

#pragma once

#import <Foundation/NSException.h>
#import <pthread.h>
#import "ASBaseDefines.h"

#if !defined(NS_BLOCK_ASSERTIONS)
  #define ASDISPLAYNODE_ASSERTIONS_ENABLED 1
#else
  #define ASDISPLAYNODE_ASSERTIONS_ENABLED 0
#endif

/**
 * Note: In some cases it would be sufficient to do e.g.:
 *  ASDisplayNodeAssert(...) NSAssert(__VA_ARGS__)
 * but we prefer not to, because we want to match the autocomplete behavior of NSAssert.
 * The construction listed above does not show the user what arguments are required and what are optional.
 */

#define ASDisplayNodeAssert(condition, desc, ...) NSAssert(condition, desc, ##__VA_ARGS__)
#define ASDisplayNodeCAssert(condition, desc, ...) NSCAssert(condition, desc, ##__VA_ARGS__)

#define ASDisplayNodeAssertNil(condition, desc, ...) ASDisplayNodeAssert((condition) == nil, desc, ##__VA_ARGS__)
#define ASDisplayNodeCAssertNil(condition, desc, ...) ASDisplayNodeCAssert((condition) == nil, desc, ##__VA_ARGS__)

#define ASDisplayNodeAssertNotNil(condition, desc, ...) ASDisplayNodeAssert((condition) != nil, desc, ##__VA_ARGS__)
#define ASDisplayNodeCAssertNotNil(condition, desc, ...) ASDisplayNodeCAssert((condition) != nil, desc, ##__VA_ARGS__)

#define ASDisplayNodeFailAssert(desc, ...) ASDisplayNodeAssert(NO, desc, ##__VA_ARGS__)
#define ASDisplayNodeCFailAssert(desc, ...) ASDisplayNodeCAssert(NO, desc, ##__VA_ARGS__)

#define ASDisplayNodeCAssertPositiveReal(description, num) ASDisplayNodeCAssert(num >= 0 && num <= CGFLOAT_MAX, @"%@ must be a real positive integer: %f.", description, (CGFloat)num)
#define ASDisplayNodeCAssertInfOrPositiveReal(description, num) ASDisplayNodeCAssert(isinf(num) || (num >= 0 && num <= CGFLOAT_MAX), @"%@ must be infinite or a real positive integer: %f.", description, (CGFloat)num)
