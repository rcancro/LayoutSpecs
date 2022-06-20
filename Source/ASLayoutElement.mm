//
//  ASLayoutElement.mm
//  Texture
//
//  Copyright (c) Facebook, Inc. and its affiliates.  All rights reserved.
//  Changes after 4/13/2017 are: Copyright (c) Pinterest, Inc.  All rights reserved.
//  Licensed under Apache 2.0: http://www.apache.org/licenses/LICENSE-2.0
//

#import <AsyncDisplayKit/ASDisplayNode+FrameworkPrivate.h>
#import <AsyncDisplayKit/ASInternalHelpers.h>



CGFloat const ASLayoutElementParentDimensionUndefined = NAN;
CGSize const ASLayoutElementParentSizeUndefined = {ASLayoutElementParentDimensionUndefined, ASLayoutElementParentDimensionUndefined};

#pragma mark - ASLayoutElementStyle

NSString * const ASLayoutElementStyleWidthProperty = @"ASLayoutElementStyleWidthProperty";
NSString * const ASLayoutElementStyleMinWidthProperty = @"ASLayoutElementStyleMinWidthProperty";
NSString * const ASLayoutElementStyleMaxWidthProperty = @"ASLayoutElementStyleMaxWidthProperty";

NSString * const ASLayoutElementStyleHeightProperty = @"ASLayoutElementStyleHeightProperty";
NSString * const ASLayoutElementStyleMinHeightProperty = @"ASLayoutElementStyleMinHeightProperty";
NSString * const ASLayoutElementStyleMaxHeightProperty = @"ASLayoutElementStyleMaxHeightProperty";

NSString * const ASLayoutElementStyleSpacingBeforeProperty = @"ASLayoutElementStyleSpacingBeforeProperty";
NSString * const ASLayoutElementStyleSpacingAfterProperty = @"ASLayoutElementStyleSpacingAfterProperty";
NSString * const ASLayoutElementStyleFlexGrowProperty = @"ASLayoutElementStyleFlexGrowProperty";
NSString * const ASLayoutElementStyleFlexShrinkProperty = @"ASLayoutElementStyleFlexShrinkProperty";
NSString * const ASLayoutElementStyleFlexBasisProperty = @"ASLayoutElementStyleFlexBasisProperty";
NSString * const ASLayoutElementStyleAlignSelfProperty = @"ASLayoutElementStyleAlignSelfProperty";
NSString * const ASLayoutElementStyleAscenderProperty = @"ASLayoutElementStyleAscenderProperty";
NSString * const ASLayoutElementStyleDescenderProperty = @"ASLayoutElementStyleDescenderProperty";

NSString * const ASLayoutElementStyleLayoutPositionProperty = @"ASLayoutElementStyleLayoutPositionProperty";

#define ASLayoutElementStyleSetSizeWithScope(x)                                    \
  ({                                                                               \
    __instanceLock__.lock();                                                       \
    const ASLayoutElementSize oldSize = _size.load();                              \
    ASLayoutElementSize newSize = oldSize;                                         \
    {x};                                                                           \
    BOOL changed = !ASLayoutElementSizeEqualToLayoutElementSize(oldSize, newSize); \
    if (changed) {                                                                 \
      _size.store(newSize);                                                        \
    }                                                                              \
    __instanceLock__.unlock();                                                     \
    changed;                                                                       \
  })

#define ASLayoutElementStyleCallDelegate(propertyName)\
do {\
  [self propertyDidChange:propertyName];\
  [_delegate style:self propertyDidChange:propertyName];\
} while(0)

@implementation ASLayoutElementStyle {
  AS::RecursiveMutex __instanceLock__;
  std::atomic<ASLayoutElementSize> _size;
  std::atomic<CGFloat> _spacingBefore;
  std::atomic<CGFloat> _spacingAfter;
  std::atomic<CGFloat> _flexGrow;
  std::atomic<CGFloat> _flexShrink;
  std::atomic<ASDimension> _flexBasis;
  std::atomic<ASStackLayoutAlignSelf> _alignSelf;
  std::atomic<CGFloat> _ascender;
  std::atomic<CGFloat> _descender;
  std::atomic<CGPoint> _layoutPosition;
}

@dynamic width, height, minWidth, maxWidth, minHeight, maxHeight;
@dynamic preferredSize, minSize, maxSize, preferredLayoutSize, minLayoutSize, maxLayoutSize;

#pragma mark - Lifecycle

- (instancetype)initWithDelegate:(id<ASLayoutElementStyleDelegate>)delegate
{
  self = [self init];
  if (self) {
    _delegate = delegate;
  }
  return self;
}

- (instancetype)init
{
  self = [super init];
  if (self) {
    std::atomic_init(&_size, ASLayoutElementSizeMake());
    std::atomic_init(&_flexBasis, ASDimensionAuto);
  }
  return self;
}

ASSynthesizeLockingMethodsWithMutex(__instanceLock__)

#pragma mark - ASLayoutElementStyleSize

- (ASLayoutElementSize)size
{
  return _size.load();
}

- (void)setSize:(ASLayoutElementSize)size
{
  ASLayoutElementStyleSetSizeWithScope({
    newSize = size;
  });
  // No CallDelegate method as ASLayoutElementSize is currently internal.
}

#pragma mark - ASLayoutElementStyleSizeForwarding

- (ASDimension)width
{
  return _size.load().width;
}

- (void)setWidth:(ASDimension)width
{
  BOOL changed = ASLayoutElementStyleSetSizeWithScope({ newSize.width = width; });
  if (changed) {
    ASLayoutElementStyleCallDelegate(ASLayoutElementStyleWidthProperty);
  }
}

- (ASDimension)height
{
  return _size.load().height;
}

- (void)setHeight:(ASDimension)height
{
  BOOL changed = ASLayoutElementStyleSetSizeWithScope({ newSize.height = height; });
  if (changed) {
    ASLayoutElementStyleCallDelegate(ASLayoutElementStyleHeightProperty);
  }
}

- (ASDimension)minWidth
{
  return _size.load().minWidth;
}

- (void)setMinWidth:(ASDimension)minWidth
{
  BOOL changed = ASLayoutElementStyleSetSizeWithScope({ newSize.minWidth = minWidth; });
  if (changed) {
    ASLayoutElementStyleCallDelegate(ASLayoutElementStyleMinWidthProperty);
  }
}

- (ASDimension)maxWidth
{
  return _size.load().maxWidth;
}

- (void)setMaxWidth:(ASDimension)maxWidth
{
  BOOL changed = ASLayoutElementStyleSetSizeWithScope({ newSize.maxWidth = maxWidth; });
  if (changed) {
    ASLayoutElementStyleCallDelegate(ASLayoutElementStyleMaxWidthProperty);
  }
}

- (ASDimension)minHeight
{
  return _size.load().minHeight;
}

- (void)setMinHeight:(ASDimension)minHeight
{
  BOOL changed = ASLayoutElementStyleSetSizeWithScope({ newSize.minHeight = minHeight; });
  if (changed) {
    ASLayoutElementStyleCallDelegate(ASLayoutElementStyleMinHeightProperty);
  }
}

- (ASDimension)maxHeight
{
  return _size.load().maxHeight;
}

- (void)setMaxHeight:(ASDimension)maxHeight
{
  BOOL changed = ASLayoutElementStyleSetSizeWithScope({ newSize.maxHeight = maxHeight; });
  if (changed) {
    ASLayoutElementStyleCallDelegate(ASLayoutElementStyleMaxHeightProperty);
  }
}


#pragma mark - ASLayoutElementStyleSizeHelpers

- (void)setPreferredSize:(CGSize)preferredSize
{
  BOOL changed = ASLayoutElementStyleSetSizeWithScope({
    newSize.width = ASDimensionMakeWithPoints(preferredSize.width);
    newSize.height = ASDimensionMakeWithPoints(preferredSize.height);
  });
  if (changed) {
    ASLayoutElementStyleCallDelegate(ASLayoutElementStyleWidthProperty);
    ASLayoutElementStyleCallDelegate(ASLayoutElementStyleHeightProperty);
  }
}

- (CGSize)preferredSize
{
  ASLayoutElementSize size = _size.load();
  if (size.width.unit == ASDimensionUnitFraction) {
    NSCAssert(NO, @"Cannot get preferredSize of element with fractional width. Width: %@.", NSStringFromASDimension(size.width));
    return CGSizeZero;
  }
  
  if (size.height.unit == ASDimensionUnitFraction) {
    NSCAssert(NO, @"Cannot get preferredSize of element with fractional height. Height: %@.", NSStringFromASDimension(size.height));
    return CGSizeZero;
  }
  
  return CGSizeMake(size.width.value, size.height.value);
}

- (void)setMinSize:(CGSize)minSize
{
  BOOL changed = ASLayoutElementStyleSetSizeWithScope({
    newSize.minWidth = ASDimensionMakeWithPoints(minSize.width);
    newSize.minHeight = ASDimensionMakeWithPoints(minSize.height);
  });
  if (changed) {
    ASLayoutElementStyleCallDelegate(ASLayoutElementStyleMinWidthProperty);
    ASLayoutElementStyleCallDelegate(ASLayoutElementStyleMinHeightProperty);
  }
}

- (void)setMaxSize:(CGSize)maxSize
{
  BOOL changed = ASLayoutElementStyleSetSizeWithScope({
    newSize.maxWidth = ASDimensionMakeWithPoints(maxSize.width);
    newSize.maxHeight = ASDimensionMakeWithPoints(maxSize.height);
  });
  if (changed) {
    ASLayoutElementStyleCallDelegate(ASLayoutElementStyleMaxWidthProperty);
    ASLayoutElementStyleCallDelegate(ASLayoutElementStyleMaxHeightProperty);
  }
}

- (ASLayoutSize)preferredLayoutSize
{
  ASLayoutElementSize size = _size.load();
  return ASLayoutSizeMake(size.width, size.height);
}

- (void)setPreferredLayoutSize:(ASLayoutSize)preferredLayoutSize
{
  BOOL changed = ASLayoutElementStyleSetSizeWithScope({
    newSize.width = preferredLayoutSize.width;
    newSize.height = preferredLayoutSize.height;
  });
  if (changed) {
    ASLayoutElementStyleCallDelegate(ASLayoutElementStyleWidthProperty);
    ASLayoutElementStyleCallDelegate(ASLayoutElementStyleHeightProperty);
  }
}

- (ASLayoutSize)minLayoutSize
{
  ASLayoutElementSize size = _size.load();
  return ASLayoutSizeMake(size.minWidth, size.minHeight);
}

- (void)setMinLayoutSize:(ASLayoutSize)minLayoutSize
{
  BOOL changed = ASLayoutElementStyleSetSizeWithScope({
    newSize.minWidth = minLayoutSize.width;
    newSize.minHeight = minLayoutSize.height;
  });
  if (changed) {
    ASLayoutElementStyleCallDelegate(ASLayoutElementStyleMinWidthProperty);
    ASLayoutElementStyleCallDelegate(ASLayoutElementStyleMinHeightProperty);
  }
}

- (ASLayoutSize)maxLayoutSize
{
  ASLayoutElementSize size = _size.load();
  return ASLayoutSizeMake(size.maxWidth, size.maxHeight);
}

- (void)setMaxLayoutSize:(ASLayoutSize)maxLayoutSize
{
  BOOL changed = ASLayoutElementStyleSetSizeWithScope({
    newSize.maxWidth = maxLayoutSize.width;
    newSize.maxHeight = maxLayoutSize.height;
  });
  if (changed) {
    ASLayoutElementStyleCallDelegate(ASLayoutElementStyleMaxWidthProperty);
    ASLayoutElementStyleCallDelegate(ASLayoutElementStyleMaxHeightProperty);
  }
}

#pragma mark - ASStackLayoutElement

- (void)setSpacingBefore:(CGFloat)spacingBefore
{
  if (_spacingBefore.exchange(spacingBefore) != spacingBefore) {
    ASLayoutElementStyleCallDelegate(ASLayoutElementStyleSpacingBeforeProperty);
  }
}

- (CGFloat)spacingBefore
{
  return _spacingBefore.load();
}

- (void)setSpacingAfter:(CGFloat)spacingAfter
{
  if (_spacingAfter.exchange(spacingAfter) != spacingAfter) {
    ASLayoutElementStyleCallDelegate(ASLayoutElementStyleSpacingAfterProperty);
  }
}

- (CGFloat)spacingAfter
{
  return _spacingAfter.load();
}

- (void)setFlexGrow:(CGFloat)flexGrow
{
  if (_flexGrow.exchange(flexGrow) != flexGrow) {
    ASLayoutElementStyleCallDelegate(ASLayoutElementStyleFlexGrowProperty);
  }
}

- (CGFloat)flexGrow
{
  return _flexGrow.load();
}

- (void)setFlexShrink:(CGFloat)flexShrink
{
  if (_flexShrink.exchange(flexShrink) != flexShrink) {
    ASLayoutElementStyleCallDelegate(ASLayoutElementStyleFlexShrinkProperty);
  }
}

- (CGFloat)flexShrink
{
  return _flexShrink.load();
}

- (void)setFlexBasis:(ASDimension)flexBasis
{
  if (!ASDimensionEqualToDimension(_flexBasis.exchange(flexBasis), flexBasis)) {
    ASLayoutElementStyleCallDelegate(ASLayoutElementStyleFlexBasisProperty);
  }
}

- (ASDimension)flexBasis
{
  return _flexBasis.load();
}

- (void)setAlignSelf:(ASStackLayoutAlignSelf)alignSelf
{
  if (_alignSelf.exchange(alignSelf) != alignSelf) {
    ASLayoutElementStyleCallDelegate(ASLayoutElementStyleAlignSelfProperty);
  }
}

- (ASStackLayoutAlignSelf)alignSelf
{
  return _alignSelf.load();
}

- (void)setAscender:(CGFloat)ascender
{
  if (_ascender.exchange(ascender) != ascender) {
    ASLayoutElementStyleCallDelegate(ASLayoutElementStyleAscenderProperty);
  }
}

- (CGFloat)ascender
{
  return _ascender.load();
}

- (void)setDescender:(CGFloat)descender
{
  if (_descender.exchange(descender) != descender) {
    ASLayoutElementStyleCallDelegate(ASLayoutElementStyleDescenderProperty);
  }
}

- (CGFloat)descender
{
  return _descender.load();
}

#pragma mark - ASAbsoluteLayoutElement

- (void)setLayoutPosition:(CGPoint)layoutPosition
{
  if (!CGPointEqualToPoint(_layoutPosition.exchange(layoutPosition), layoutPosition)) {
    ASLayoutElementStyleCallDelegate(ASLayoutElementStyleLayoutPositionProperty);
  }
}

- (CGPoint)layoutPosition
{
  return _layoutPosition.load();
}

- (void)propertyDidChange:(NSString *)propertyName
{
}

@end
