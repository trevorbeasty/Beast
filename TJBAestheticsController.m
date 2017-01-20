//
//  TJBAestheticsController.m
//  Beast
//
//  Created by Trevor Beasty on 12/25/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TJBAestheticsController.h"

@implementation TJBAestheticsController

#pragma mark - Singleton

+ (instancetype)singleton{
    static TJBAestheticsController *singleton;
    
    if (!singleton)
    {
        singleton = [[self alloc] initPrivate];
    }
    return singleton;
}

- (instancetype)initPrivate{
    self = [super init];
    
    return self;
}

- (instancetype)init{
    @throw [NSException exceptionWithName: @"Singleton"
                                   reason: @"Use +[TJBAestheticsController singleton]"
                                 userInfo: nil];
}

#pragma mark - Images

- (void)addFullScreenBackgroundViewWithImage:(UIImage *)image toRootView:(UIView *)rootView imageOpacity:(double)opacity{
    
    CGSize screenSize = [[UIScreen mainScreen] bounds].size;
    UIImage *resizedImage = [self imageWithImage: image
                                    scaledToSize: screenSize];
    
    UIView *imageView = [[UIImageView alloc] initWithImage: resizedImage];
    imageView.layer.opacity = opacity;
    
    [rootView addSubview: imageView];
    [rootView sendSubviewToBack: imageView];

}

- (void)addFullScreenBackgroundViewWithImage:(UIImage *)image toRootView:(UIView *)rootView{
    [self addFullScreenBackgroundViewWithImage: image
                                    toRootView: rootView
                                  imageOpacity: 1.0];
}

- (UIImage *)imageWithImage:(UIImage *)image scaledToSize:(CGSize)newSize{
    UIGraphicsBeginImageContext(newSize);
    
    [image drawInRect: CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return newImage;
}

#pragma mark - Action Buttons

- (void)configureButtonsInArray:(NSArray<UIButton *> *)buttons withOpacity:(double)opacity{
    
    for (UIButton *button in buttons){
        
        CALayer *layer = button.layer;
        layer.masksToBounds = YES;
        layer.cornerRadius = [[self buttonCornerRadius] intValue];
        layer.opacity = opacity;
        
        button.backgroundColor = [self buttonBackgroundColor];
        [button setTitleColor: [self buttonTextColor]
                     forState: UIControlStateNormal];
        
        UILabel *title = button.titleLabel;
        [title setFont: [self buttonFont]];
        
    }
    
}

- (UIColor *)buttonBackgroundColor{
    return [UIColor colorWithRed: 16.0 / 255.0
                           green: 168.0 / 255.0
                            blue: 1.0
                           alpha: 1.0];
}

- (UIColor *)buttonTextColor{
    return [UIColor whiteColor];
}

- (NSNumber *)buttonCornerRadius{
    return  [NSNumber numberWithInt: 16];
}

- (UIFont *)buttonFont{
    return [UIFont systemFontOfSize: 28.0];
}

#pragma mark - Labels

- (UIColor *)labelType1Color{
    return [UIColor colorWithRed: 1.0
                           green: 229.0 / 255.0
                            blue: 188.0 / 255.0
                           alpha: 1.0];
}


+ (void)configureViewsWithType1Format:(NSArray<UIView *> *)views withOpacity:(double)opacity{
    for(UIView *view in views){
        view.backgroundColor = [[self singleton] labelType1Color];
        
        CALayer *layer = view.layer;
        layer.masksToBounds = YES;
        layer.cornerRadius = 8;
        layer.opacity = opacity;
    }
}

+ (void)configureLabelsWithType2Format:(NSArray<UILabel *> *)labels withOpacity:(double)opacity{
    
    for(UILabel *label in labels){
        
        label.backgroundColor = [UIColor darkGrayColor];
        
        [label setTextColor: [UIColor whiteColor]];
        
        label.layer.opacity = opacity;
 
    }
}


#pragma mark - Navigation Bar

+ (void)configureNavigationBar:(UINavigationBar *)navBar{
    navBar.backgroundColor = [UIColor darkGrayColor];
    [navBar.titleTextAttributes setValue: [UIColor whiteColor]
                                  forKey: NSForegroundColorAttributeName];
}

@end


















