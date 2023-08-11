//
//  UIView+ASLayoutElement.m
//  LayoutSpecs
//
//  Created by Ricky Cancro on 8/11/23.
//

#import "UIView+ASLayoutElement.h"

#import <objc/runtime.h>

#import "ASLayout.h"
#import "ASLayoutElementStylePrivate.h"

@implementation UIView (ASLayoutElement)
@dynamic style;

- (ASLayoutElementType)layoutElementType
{
  return ASLayoutElementTypeContent;
}

#pragma mark - Style

- (void)setStyle:(ASLayoutElementStyle *)style
{
     objc_setAssociatedObject(self, @selector(style), style, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (ASLayoutElementStyle *)style
{
    ASLayoutElementStyle *style = objc_getAssociatedObject(self, @selector(style));
    if (style == nil) {
        style = [[ASLayoutElementStyle alloc] init];
        [self setStyle:style];
    }
    return style;
}

- (instancetype)styledWithBlock:(AS_NOESCAPE void (^)(__kindof ASLayoutElementStyle *style))styleBlock
{
  styleBlock(self.style);
  return self;
}

#pragma mark Children

- (nullable NSArray<id<ASLayoutElement>> *)sublayoutElements
{
    return [self subviews];
}

#pragma mark - Layout

- (nonnull ASLayout *)calculateLayoutThatFits:(ASSizeRange)constrainedSize {
    CGSize intrinsicSize = [self sizeThatFits:constrainedSize.max];
    CGSize finalSize = ASSizeRangeClamp(constrainedSize, intrinsicSize);
    return [ASLayout layoutWithLayoutElement:self size:finalSize];
}

- (nonnull ASLayout *)calculateLayoutThatFits:(ASSizeRange)constrainedSize restrictedToSize:(ASLayoutElementSize)size relativeToParentSize:(CGSize)parentSize {
    const ASSizeRange resolvedRange = ASSizeRangeIntersect(constrainedSize, ASLayoutElementSizeResolve(self.style.size, parentSize));
    return [self calculateLayoutThatFits:resolvedRange];
}

- (nonnull ASLayout *)layoutThatFits:(ASSizeRange)constrainedSize {
    return [self layoutThatFits:constrainedSize parentSize:constrainedSize.max];
}

- (nonnull ASLayout *)layoutThatFits:(ASSizeRange)constrainedSize parentSize:(CGSize)parentSize {
    return [self calculateLayoutThatFits:constrainedSize restrictedToSize:self.style.size relativeToParentSize:parentSize];
}

@end
