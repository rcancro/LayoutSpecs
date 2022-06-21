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

    [view addSubview:self.label];
    [view addSubview:self.button];
    [view addSubview:self.backgroundView];
    
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
    ASLayout *sublayout1 = layout.sublayouts[0];
    ASLayout *sublayout2 = layout.sublayouts[1];
    ASLayout *sublayout3 = layout.sublayouts[1].sublayouts[0];
    ASLayout *sublayout4 = layout.sublayouts[1].sublayouts[1];
    NSLog(@"Layout: %@", NSStringFromCGSize(layout.size));
}

@end
