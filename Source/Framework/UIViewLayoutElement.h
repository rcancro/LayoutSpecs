//
//  UIViewLayoutElement.h
//  LayoutSpecs
//
//  Created by Huy Nguyen on 6/20/22.
//

#import <UIKit/UIKit.h>
#import "ASLayoutElement.h"

@interface UIViewLayoutElement : NSObject <ASLayoutElement>

@property (nonatomic, readonly) UIView *view;

- (instancetype)initWithView:(UIView *)view;
- (instancetype)init NS_UNAVAILABLE;

@end
