//
//  UIView+ASLayoutElement.m
//  TestApp
//
//  Created by Ricky Cancro on 8/10/23.
//

#import "ASLayoutView.h"
#import "ASLayout.h"
#import "ASLayoutSpec.h"
#import "ASLayoutElementStylePrivate.h"
#import "ASLayoutSpec+Subclasses.h"

@implementation ASLayoutView

@synthesize style = _style;

- (ASLayoutElementType)layoutElementType
{
    return ASLayoutElementTypeContent;
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

#pragma mark Children

- (nullable NSArray<id<ASLayoutElement>> *)sublayoutElements
{
    return self.subviews;
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    ASSizeRange sizeRange = ASSizeRangeMake(self.bounds.size);
    ASLayout *layout = [self calculateLayoutThatFits:sizeRange];
    layout = [layout filteredContentLayoutTree];
    
    for (ASLayoutView *element in [self subviews]) {
        CGRect frame = [layout frameForElement:element];
        if (CGRectIsNull(frame)) {
            // There is no frame for this element in our layout.
            // This currently can happen if we get a CA layout pass
            // while waiting for the client to run animateLayoutTransition:
        } else {
            element.frame = frame;
        }
    }
}

- (id<ASLayoutElement>)layoutSpecThatFits:(ASSizeRange)constrainedSize
{
    return nil;
}

- (nonnull ASLayout *)calculateLayoutThatFits:(ASSizeRange)constrainedSize
{
    id<ASLayoutElement> layoutElement = [self layoutSpecThatFits:constrainedSize];
    if (!layoutElement) {
        CGSize intrinsicSize = [self sizeThatFits:constrainedSize.max];
        CGSize finalSize = ASSizeRangeClamp(constrainedSize, intrinsicSize);
        return [ASLayout layoutWithLayoutElement:self size:finalSize];
    }
    
    // Certain properties are necessary to set on an element of type ASLayoutSpec
    if (layoutElement.layoutElementType == ASLayoutElementTypeLayoutSpec) {
        ASLayoutSpec *layoutSpec = (ASLayoutSpec *)layoutElement;
#if AS_DEDUPE_LAYOUT_SPEC_TREE
        NSHashTable *duplicateElements = [layoutSpec findDuplicatedElementsInSubtree];
        if (duplicateElements.count > 0) {
            ASDisplayNodeFailAssert(@"Node %@ returned a layout spec that contains the same elements in multiple positions. Elements: %@", self, duplicateElements);
            // Use an empty layout spec to avoid crashes
            layoutSpec = [[ASLayoutSpec alloc] init];
        }
#endif
        
        ASDisplayNodeAssert(layoutSpec.isMutable, @"Node %@ returned layout spec %@ that has already been used. Layout specs should always be regenerated.", self, layoutSpec);
        
        layoutSpec.isMutable = NO;
    }
    
    ASLayout *layout = [layoutElement layoutThatFits:constrainedSize];
    
    // Make sure layoutElementObject of the root layout is `self`, so that the flattened layout will be structurally correct.
    BOOL isFinalLayoutElement = (layout.layoutElement != self);
    if (isFinalLayoutElement) {
        layout.position = CGPointZero;
        layout = [ASLayout layoutWithLayoutElement:self size:layout.size sublayouts:@[layout]];
    }
    
    layout = [layout filteredContentLayoutTree];
    
    // Flip layout if layout should be rendered right-to-left
    BOOL shouldRenderRTLLayout = [UIView userInterfaceLayoutDirectionForSemanticContentAttribute:self.semanticContentAttribute] == UIUserInterfaceLayoutDirectionRightToLeft;
    if (shouldRenderRTLLayout) {
        for (ASLayout *sublayout in layout.sublayouts) {
            switch (self.semanticContentAttribute) {
                case UISemanticContentAttributeUnspecified:
                case UISemanticContentAttributeForceRightToLeft: {
                    // Flip
                    CGPoint flippedPosition = CGPointMake(layout.size.width - CGRectGetWidth(sublayout.frame) - sublayout.position.x, sublayout.position.y);
                    sublayout.position = flippedPosition;
                }
                case UISemanticContentAttributePlayback:
                case UISemanticContentAttributeForceLeftToRight:
                case UISemanticContentAttributeSpatial:
                    // Don't flip
                    break;
            }
        }
    }
    
    
    return layout;
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
