//
//  UIViewLayoutElement.m
//  LayoutSpecs
//
//  Created by Huy Nguyen on 6/20/22.
//

#import "UIViewLayoutElement.h"

#import <CoreGraphics/CoreGraphics.h>

#import "ASLayout.h"
#import "ASLayoutElementStylePrivate.h"

@implementation UIViewLayoutElement

- (instancetype)initWithView:(UIView *)view
{
    self = [super init];
    if (self) {
        _view = view;
    }
    return self;
}

- (ASLayoutElementType)layoutElementType
{
  return ASLayoutElementTypeContent;
}

@synthesize style;

- (nonnull ASLayout *)calculateLayoutThatFits:(ASSizeRange)constrainedSize {
    CGSize intrinsicSize = [self.view sizeThatFits:constrainedSize.max];
    CGSize finalSize = ASSizeRangeClamp(constrainedSize, intrinsicSize);
    return [ASLayout layoutWithLayoutElement:self size:finalSize];
}

- (nonnull ASLayout *)calculateLayoutThatFits:(ASSizeRange)constrainedSize restrictedToSize:(ASLayoutElementSize)size relativeToParentSize:(CGSize)parentSize {
    const ASSizeRange resolvedRange = ASSizeRangeIntersect(constrainedSize, ASLayoutElementSizeResolve(self.style.size, parentSize));
    return [self calculateLayoutThatFits:resolvedRange];
}

- (BOOL)implementsLayoutMethod {
    return YES;
}

- (nonnull ASLayout *)layoutThatFits:(ASSizeRange)constrainedSize {
    return [self layoutThatFits:constrainedSize parentSize:constrainedSize.max];
}

- (nonnull ASLayout *)layoutThatFits:(ASSizeRange)constrainedSize parentSize:(CGSize)parentSize {
    return [self calculateLayoutThatFits:constrainedSize restrictedToSize:self.style.size relativeToParentSize:parentSize];
}

- (nullable NSArray<id<ASLayoutElement>> *)sublayoutElements {
    return nil;
}

@end
