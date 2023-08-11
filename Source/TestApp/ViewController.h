//
//  ViewController.h
//  TestApp
//
//  Created by Huy Nguyen on 6/20/22.
//

#import <UIKit/UIKit.h>
#import <LayoutSpecs/ASLayoutView.h>
#import <LayoutSpecs/ASLayoutViewController.h>

@interface ContentView: ASLayoutView
@end

@interface ViewController : ASLayoutViewController<ContentView *>


@end

