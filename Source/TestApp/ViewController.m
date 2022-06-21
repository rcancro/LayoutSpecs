//
//  ViewController.m
//  TestApp
//
//  Created by Huy Nguyen on 6/20/22.
//

#import "ViewController.h"

#import <LayoutSpecs/ASBackgroundLayoutSpec.h>
#import <LayoutSpecs/ASStackLayoutSpec.h>
#import <LayoutSpecs/UIViewLayoutElement.h>
#import <LayoutSpecs/ASLayout.h>

@interface ViewController ()

@property (nonatomic) UILabel *label;
@property (nonatomic) UIButton *button;
@property (nonatomic) UIView *backgroundView;

@end

@implementation ViewController

@synthesize label;
@synthesize button;
@synthesize backgroundView;

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.label = [[UILabel alloc] init];
        self.label.text = @"Hello world!";
        
        self.button = [[UIButton alloc] init];
        [self.button setTitle:@"Button" forState:UIControlStateNormal];
        
        self.backgroundView = [[UIView alloc] init];
        self.backgroundView.backgroundColor = UIColor.redColor;
    }
    return self;
}

- (void)loadView
{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = UIColor.whiteColor;

    [view addSubview:self.backgroundView];
    [view addSubview:self.label];
    [view addSubview:self.button];
    
    self.view = view;
}

- (void)viewWillLayoutSubviews
{
    UIViewLayoutElement *labelElement = [[UIViewLayoutElement alloc] initWithView:self.label];
    UIViewLayoutElement *buttonElement = [[UIViewLayoutElement alloc] initWithView:self.button];
    UIViewLayoutElement *backgroundElement = [[UIViewLayoutElement alloc] initWithView:self.backgroundView];
    
    ASStackLayoutSpec *stackSpec = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionVertical
                                                                           spacing:0
                                                                    justifyContent:ASStackLayoutJustifyContentCenter
                                                                        alignItems:ASStackLayoutAlignItemsCenter
                                                                          children:@[ labelElement, buttonElement ]];
    ASBackgroundLayoutSpec *backgroundSpec = [ASBackgroundLayoutSpec backgroundLayoutSpecWithChild:stackSpec
                                                                                        background:backgroundElement];
    
    ASSizeRange sizeRange = ASSizeRangeMake(self.view.bounds.size);
    ASLayout *layout = [backgroundSpec layoutThatFits:sizeRange];
    layout = [layout filteredContentLayoutTree];
    
    self.view.frame = CGRectMake(0, 0, layout.size.width, layout.size.height);
    
    for (UIViewLayoutElement *element in @[labelElement, buttonElement, backgroundElement]) {
      CGRect frame = [layout frameForElement:element];
      if (CGRectIsNull(frame)) {
        // There is no frame for this element in our layout.
        // This currently can happen if we get a CA layout pass
        // while waiting for the client to run animateLayoutTransition:
      } else {
        element.view.frame = frame;
      }
    }
}

@end
