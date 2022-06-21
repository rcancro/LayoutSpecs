//
//  ASLayoutSpec.mm
//  Texture
//
//  Copyright (c) Facebook, Inc. and its affiliates.  All rights reserved.
//  Changes after 4/13/2017 are: Copyright (c) Pinterest, Inc.  All rights reserved.
//  Licensed under Apache 2.0: http://www.apache.org/licenses/LICENSE-2.0
//

#import "ASLayoutSpec.h"
#import "ASLayoutSpecPrivate.h"

#import "ASLayoutSpec+Subclasses.h"

#import "ASCollections.h"
#import "ASLayoutElementStylePrivate.h"
#import "ASEqualityHelpers.h"

@implementation ASLayoutSpec

// Dynamic properties for ASLayoutElements
@dynamic layoutElementType;

#pragma mark - Lifecycle

- (instancetype)init
{
  if (!(self = [super init])) {
    return nil;
  }
  
  _isMutable = YES;
  _childrenArray = [[NSMutableArray alloc] init];
  
  return self;
}

- (ASLayoutElementType)layoutElementType
{
  return ASLayoutElementTypeLayoutSpec;
}

- (BOOL)canLayoutAsynchronous
{
  return YES;
}

- (BOOL)implementsLayoutMethod
{
  return YES;
}

#pragma mark - Style

- (ASLayoutElementStyle *)style
{
  if (_style == nil) {
    _style = [[ASLayoutElementStyle alloc] init];
  }
  return _style;
}

- (instancetype)styledWithBlock:(AS_NOESCAPE void (^)(__kindof ASLayoutElementStyle *style))styleBlock
{
  styleBlock(self.style);
  return self;
}

#pragma mark - Layout

- (ASLayout *)layoutThatFits:(ASSizeRange)constrainedSize\
{
  return [self layoutThatFits:constrainedSize parentSize:constrainedSize.max];
}

- (ASLayout *)layoutThatFits:(ASSizeRange)constrainedSize parentSize:(CGSize)parentSize
{
  return [self calculateLayoutThatFits:constrainedSize restrictedToSize:self.style.size relativeToParentSize:parentSize];
}

- (ASLayout *)calculateLayoutThatFits:(ASSizeRange)constrainedSize
                     restrictedToSize:(ASLayoutElementSize)size
                 relativeToParentSize:(CGSize)parentSize
{
  const ASSizeRange resolvedRange = ASSizeRangeIntersect(constrainedSize, ASLayoutElementSizeResolve(self.style.size, parentSize));
  return [self calculateLayoutThatFits:resolvedRange];
}

- (ASLayout *)calculateLayoutThatFits:(ASSizeRange)constrainedSize
{
  return [ASLayout layoutWithLayoutElement:self size:constrainedSize.min];
}

#pragma mark - Child

- (void)setChild:(id<ASLayoutElement>)child
{
  ASDisplayNodeAssert(self.isMutable, @"Cannot set properties when layout spec is not mutable");
  ASDisplayNodeAssert(_childrenArray.count < 2, @"This layout spec does not support more than one child. Use the setChildren: or the setChild:AtIndex: API");
 
  if (child) {
    _childrenArray[0] = child;
  } else {
    if (_childrenArray.count) {
      [_childrenArray removeObjectAtIndex:0];
    }
  }
}

- (id<ASLayoutElement>)child
{
  ASDisplayNodeAssert(_childrenArray.count < 2, @"This layout spec does not support more than one child. Use the setChildren: or the setChild:AtIndex: API");
  
  return _childrenArray.firstObject;
}

#pragma mark - Children

- (void)setChildren:(NSArray<id<ASLayoutElement>> *)children
{
  ASDisplayNodeAssert(self.isMutable, @"Cannot set properties when layout spec is not mutable");

#if ASDISPLAYNODE_ASSERTIONS_ENABLED
  for (id<ASLayoutElement> child in children) {
    ASDisplayNodeAssert([child conformsToProtocol:NSProtocolFromString(@"ASLayoutElement")], @"Child %@ of spec %@ is not an ASLayoutElement!", child, self);
  }
#endif
  [_childrenArray setArray:children];
}

- (nullable NSArray<id<ASLayoutElement>> *)children
{
  return [_childrenArray copy];
}

- (NSArray<id<ASLayoutElement>> *)sublayoutElements
{
  return [_childrenArray copy];
}

#pragma mark - NSFastEnumeration

- (NSUInteger)countByEnumeratingWithState:(NSFastEnumerationState *)state objects:(id unowned _Nullable [_Nonnull])buffer count:(NSUInteger)len
{
  return [_childrenArray countByEnumeratingWithState:state objects:buffer count:len];
}

#pragma mark - Framework Private

#if AS_DEDUPE_LAYOUT_SPEC_TREE
- (nullable NSHashTable<id<ASLayoutElement>> *)findDuplicatedElementsInSubtree
{
  NSHashTable *result = nil;
  NSUInteger count = 0;
  [self _findDuplicatedElementsInSubtreeWithWorkingSet:[NSHashTable hashTableWithOptions:NSHashTableObjectPointerPersonality] workingCount:&count result:&result];
  return result;
}

/**
 * This method is extremely performance-sensitive, so we do some strange things.
 *
 * @param workingSet A working set of elements for use in the recursion.
 * @param workingCount The current count of the set for use in the recursion.
 * @param result The set into which to put the result. This initially points to @c nil to save time if no duplicates exist.
 */
- (void)_findDuplicatedElementsInSubtreeWithWorkingSet:(NSHashTable<id<ASLayoutElement>> *)workingSet workingCount:(NSUInteger *)workingCount result:(NSHashTable<id<ASLayoutElement>>  * _Nullable *)result
{
  Class layoutSpecClass = [ASLayoutSpec class];

  for (id<ASLayoutElement> child in self) {
    // Add the object into the set.
    [workingSet addObject:child];

    // Check that addObject: caused the count to increase.
    // This is faster than using containsObject.
    NSUInteger oldCount = *workingCount;
    NSUInteger newCount = workingSet.count;
    BOOL objectAlreadyExisted = (newCount != oldCount + 1);
    if (objectAlreadyExisted) {
      if (*result == nil) {
        *result = [NSHashTable hashTableWithOptions:NSHashTableObjectPointerPersonality];
      }
      [*result addObject:child];
    } else {
      *workingCount = newCount;
      // If child is a layout spec we haven't visited, recurse its children.
      if ([child isKindOfClass:layoutSpecClass]) {
        [(ASLayoutSpec *)child _findDuplicatedElementsInSubtreeWithWorkingSet:workingSet workingCount:workingCount result:result];
      }
    }
  }
}
#endif

@end

#pragma mark - ASWrapperLayoutSpec

@implementation ASWrapperLayoutSpec

+ (instancetype)wrapperWithLayoutElement:(id<ASLayoutElement>)layoutElement NS_RETURNS_RETAINED
{
  return [[self alloc] initWithLayoutElement:layoutElement];
}

- (instancetype)initWithLayoutElement:(id<ASLayoutElement>)layoutElement
{
  self = [super init];
  if (self) {
    self.child = layoutElement;
  }
  return self;
}

+ (instancetype)wrapperWithLayoutElements:(NSArray<id<ASLayoutElement>> *)layoutElements NS_RETURNS_RETAINED
{
  return [[self alloc] initWithLayoutElements:layoutElements];
}

- (instancetype)initWithLayoutElements:(NSArray<id<ASLayoutElement>> *)layoutElements
{
  self = [super init];
  if (self) {
    self.children = layoutElements;
  }
  return self;
}

- (ASLayout *)calculateLayoutThatFits:(ASSizeRange)constrainedSize
{
  NSArray *children = self.children;
  const auto count = children.count;
  ASLayout *rawSublayouts[count];
  int i = 0;
  
  CGSize size = constrainedSize.min;
  for (id<ASLayoutElement> child in children) {
    ASLayout *sublayout = [child layoutThatFits:constrainedSize parentSize:constrainedSize.max];
    sublayout.position = CGPointZero;
    
    size.width = MAX(size.width,  sublayout.size.width);
    size.height = MAX(size.height, sublayout.size.height);
    
    rawSublayouts[i++] = sublayout;
  }
  const auto sublayouts = [NSArray<ASLayout *> arrayByTransferring:rawSublayouts count:i];
  return [ASLayout layoutWithLayoutElement:self size:size sublayouts:sublayouts];
}

@end
