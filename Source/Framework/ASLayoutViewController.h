//
//  ASLayoutViewController.h
//  LayoutSpecs
//
//  Created by Ricky Cancro on 8/11/23.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface ASLayoutViewController<__covariant ViewType : UIView *> : UIViewController

- (instancetype)init;
- (instancetype)initWithView:(nullable ViewType)view NS_DESIGNATED_INITIALIZER;


- (instancetype)initWithNibName:(nullable NSString *)nibNameOrNil bundle:(nullable NSBundle *)nibBundleOrNil NS_UNAVAILABLE;
- (instancetype)initWithCoder:(NSCoder *)coder NS_UNAVAILABLE;

@end

NS_ASSUME_NONNULL_END
