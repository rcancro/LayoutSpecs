//
//  ASLayoutViewController.m
//  LayoutSpecs
//
//  Created by Ricky Cancro on 8/11/23.
//

#import "ASLayoutViewController.h"

#import <LayoutSpecs/UIView+ASLayoutElement.h>
#import <LayoutSpecs/ASLayout.h>

@interface ASLayoutViewController ()
@property (nonatomic) UIView *temporaryView;
@end

@implementation ASLayoutViewController

- (instancetype)init
{
    return [self initWithView:[[UIView alloc] init]];
}

- (instancetype)initWithView:(UIView *)view
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _temporaryView = view;
    }
    return self;
}

- (void)loadView
{
    // do not call super so we can use our custom root view
    
    self.view = self.temporaryView;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
}


- (void)viewWillLayoutSubviews
{
    ASSizeRange sizeRange = ASSizeRangeMake(self.view.bounds.size);
    ASLayout *layout = [self.view layoutThatFits:sizeRange];
    layout = [layout filteredContentLayoutTree];
    
    self.view.frame = CGRectMake(0, 0, layout.size.width, layout.size.height);
    
    for (UIView *element in [self.view sublayoutElements]) {
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
@end
