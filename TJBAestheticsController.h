//
//  TJBAestheticsController.h
//  Beast
//
//  Created by Trevor Beasty on 12/25/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TJBAestheticsController : NSObject

// action buttons
// buttons will have a height of 40; must be set in interface builder
@property (nonatomic, strong, readonly) UIColor *buttonBackgroundColor;
@property (nonatomic, strong, readonly) UIColor *buttonTextColor;

@property (nonatomic, strong, readonly) NSNumber *buttonCornerRadius;

@property (nonatomic, strong, readonly) UIFont *buttonFont;

// label type 1
@property (nonatomic, strong, readonly) UIColor *labelType1Color;

// assorted colors

@property (nonatomic, strong, readonly) UIColor *color1;
@property (nonatomic, strong, readonly) UIColor *paleLightBlueColor;
@property (nonatomic, strong, readonly) UIColor *color2;
@property (nonatomic, strong, readonly) UIColor *yellowNotebookColor;
@property (nonatomic, strong, readonly) UIColor *blueButtonColor;
@property (nonatomic, strong, readonly) UIColor *offWhiteColor;
@property (nonatomic, strong, readonly) UIColor *titleBarButtonColor;

+ (instancetype)singleton;

// background images
- (void)addFullScreenBackgroundViewWithImage:(UIImage *)image toRootView:(UIView *)rootView;
- (void)addFullScreenBackgroundViewWithImage:(UIImage *)image toRootView:(UIView *)rootView imageOpacity:(double)opacity;

// action button configuration
- (void)configureButtonsInArray:(NSArray<UIButton *> *)buttons withOpacity:(double)opacity;

// navigation bars
+ (void)configureNavigationBar:(UINavigationBar *)navBar;

// labels
+ (void)configureViewsWithType1Format:(NSArray<UIView *> *)views withOpacity:(double)opacity;

+ (void)configureLabelsWithType2Format:(NSArray<UILabel *> *)labels withOpacity:(double)opacity;

@end
















