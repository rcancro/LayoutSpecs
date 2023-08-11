//
//  UIView+ASLayoutElement.h
//  TestApp
//
//  Created by Ricky Cancro on 8/10/23.
//

#import <UIKit/UIKit.h>
#import <LayoutSpecs/ASLayoutElement.h>

NS_ASSUME_NONNULL_BEGIN

@interface ASLayoutView: UIView <ASLayoutElement>
- (id<ASLayoutElement>)layoutSpecThatFits:(ASSizeRange)constrainedSize;
@end

NS_ASSUME_NONNULL_END
