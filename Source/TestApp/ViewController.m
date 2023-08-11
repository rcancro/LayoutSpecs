//
//  ViewController.m
//  TestApp
//
//  Created by Huy Nguyen on 6/20/22.
//

#import "ViewController.h"

#import <LayoutSpecs/ASBackgroundLayoutSpec.h>
#import <LayoutSpecs/ASStackLayoutSpec.h>
#import <LayoutSpecs/ASInsetLayoutSpec.h>
#import <LayoutSpecs/ASLayout.h>
#import <LayoutSpecs/ASLayoutView.h>
#import <LayoutSpecs/UIView+ASLayoutElement.h>

@interface HelloView: ASLayoutView
@property (nonatomic) UIImageView *imageView;
@property (nonatomic) UILabel *label;
@end

@implementation HelloView

- (instancetype)init
{
    self = [super init];
    if (self) {
        _imageView = [[UIImageView alloc] initWithImage:[UIImage systemImageNamed:@"hand.wave"]];
        _label = [[UILabel alloc] init];
        _label.text = @"hello!";
        
        [self addSubview:self.imageView];
        [self addSubview:self.label];
    }
    return self;
}

- (id<ASLayoutElement>)layoutSpecThatFits:(ASSizeRange)constrainedSize
{
    ASStackLayoutSpec *stackSpec = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionHorizontal
                                                                           spacing:12
                                                                    justifyContent:ASStackLayoutJustifyContentCenter
                                                                        alignItems:ASStackLayoutAlignItemsCenter
                                                                          children:@[ self.imageView, self.label ]];
    return [ASInsetLayoutSpec insetLayoutSpecWithInsets:UIEdgeInsetsMake(0, 16, 0, 16) child:stackSpec];
}

@end

@interface ContentView()
@property (nonatomic) HelloView *helloView;
@property (nonatomic) UILabel *label;
@property (nonatomic) UIButton *button;
@property (nonatomic) UIView *backgroundView;
@end

@implementation ContentView

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.label = [[UILabel alloc] init];
        self.label.text = @"Hello world!";
        
        self.button = [[UIButton alloc] init];
        [self.button setTitle:@"Button" forState:UIControlStateNormal];
        
        self.backgroundView = [[UIView alloc] init];
        self.backgroundView.backgroundColor = UIColor.systemGray3Color;
        
        self.helloView = [[HelloView alloc] init];
        
        [self addSubview:self.backgroundView];
        [self addSubview:self.label];
        [self addSubview:self.button];
        [self addSubview:self.helloView];
        self.backgroundColor = UIColor.whiteColor;
    }
    return self;
}

- (id<ASLayoutElement>)layoutSpecThatFits:(ASSizeRange)constrainedSize
{
    ASStackLayoutSpec *stackSpec = [ASStackLayoutSpec stackLayoutSpecWithDirection:ASStackLayoutDirectionVertical
                                                                           spacing:50
                                                                    justifyContent:ASStackLayoutJustifyContentCenter
                                                                        alignItems:ASStackLayoutAlignItemsCenter
                                                                          children:@[ self.helloView, self.label, self.button ]];
    ASBackgroundLayoutSpec *backgroundSpec = [ASBackgroundLayoutSpec backgroundLayoutSpecWithChild:stackSpec
                                                                                        background:self.backgroundView];
    return backgroundSpec;
}

@end

@implementation ViewController

- (instancetype)init
{
    self = [super initWithView:[[ContentView alloc] init]];
    if (self) {
    }
    return self;
}



@end
