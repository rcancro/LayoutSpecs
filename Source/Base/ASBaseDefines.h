//
//  ASBaseDefines.h
//  Texture
//
//  Copyright (c) Facebook, Inc. and its affiliates.  All rights reserved.
//  Changes after 4/13/2017 are: Copyright (c) Pinterest, Inc.  All rights reserved.
//  Licensed under Apache 2.0: http://www.apache.org/licenses/LICENSE-2.0
//

#import <Foundation/Foundation.h>

#define ASDK_EXTERN FOUNDATION_EXTERN
#define unowned __unsafe_unretained

#ifndef ASDISPLAYNODE_INLINE
# if defined (__STDC_VERSION__) && __STDC_VERSION__ >= 199901L
#  define ASDISPLAYNODE_INLINE static inline
# elif defined (__MWERKS__) || defined (__cplusplus)
#  define ASDISPLAYNODE_INLINE static inline
# elif ASDISPLAYNODE_GNUC (3, 0)
#  define ASDISPLAYNODE_INLINE static __inline__ __attribute__ ((always_inline))
# else
#  define ASDISPLAYNODE_INLINE static
# endif
#endif

#ifndef ASDISPLAYNODE_DEPRECATED
# if ASDISPLAYNODE_GNUC (3, 0) && ASDISPLAYNODE_WARN_DEPRECATED
#  define ASDISPLAYNODE_DEPRECATED __attribute__ ((deprecated))
# else
#  define ASDISPLAYNODE_DEPRECATED
# endif
#endif

#ifndef AS_WARN_UNUSED_RESULT
#if __has_attribute(warn_unused_result)
#define AS_WARN_UNUSED_RESULT __attribute__((warn_unused_result))
#else
#define AS_WARN_UNUSED_RESULT
#endif
#endif

#define ASOVERLOADABLE __attribute__((overloadable))

#if __has_attribute(noescape)
#define AS_NOESCAPE __attribute__((noescape))
#else
#define AS_NOESCAPE
#endif

#if __has_attribute(objc_subclassing_restricted)
#define AS_SUBCLASSING_RESTRICTED __attribute__((objc_subclassing_restricted))
#else
#define AS_SUBCLASSING_RESTRICTED
#endif

/// Ensure that class is of certain kind
#define ASDynamicCast(x, c) ({ \
  id __val = x;\
  ((c *) ([__val isKindOfClass:[c class]] ? __val : nil));\
})

/**
 * Create a new array by mapping `collection` over `work`, ignoring nil.
 */
#define ASArrayByFlatMapping(collectionArg, decl, work) ({ \
  id __collection = collectionArg; \
  NSArray *__result; \
  if (__collection) { \
    id __buf[[__collection count]]; \
    NSUInteger __i = 0; \
    for (decl in __collection) {\
      if ((__buf[__i] = work)) { \
        __i++; \
      } \
    } \
    __result = [NSArray arrayByTransferring:__buf count:__i]; \
  } \
  __result; \
})
