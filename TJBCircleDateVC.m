//
//  TJBCircleDateVC.m
//  Beast
//
//  Created by Trevor Beasty on 1/26/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBCircleDateVC.h"

// aesthetics

#import "TJBAestheticsController.h"

@interface TJBCircleDateVC ()

{
    
    CGSize _buttonSize;
}

// IBOutlet

@property (weak, nonatomic) IBOutlet UIButton *mainButton;

// IBAction

- (IBAction)didPressMainButton:(id)sender;

// core

@property (nonatomic, strong) NSString *mainButtonTitle;


@end

@implementation TJBCircleDateVC

#pragma mark - Instantiation

- (instancetype)initWithMainButtonTitle:(NSString *)mainButtonTitle size:(CGSize)size{
    
    self = [super init];
    
    if (self){
        
        self.mainButtonTitle = mainButtonTitle;
        _buttonSize = size;
        
    }
    
    return self;
    
}

#pragma mark - View Life Cycle

- (void)viewDidLoad{
    
    [self.mainButton setTitle: self.mainButtonTitle
                     forState: UIControlStateNormal];
    
    [self configureViewAesthetics];
    
    
}

- (void)configureViewAesthetics{
    
    self.mainButton.backgroundColor = [[TJBAestheticsController singleton] color1];
    
    [self configureButtonMask];
    
    
    
}

- (void)configureButtonMask{
    
    // establish the bezier path
    
    CGPoint center = CGPointMake(_buttonSize.width / 2.0,  _buttonSize.height / 2.0);
    
    CGFloat radius = MIN(_buttonSize.width, _buttonSize.height);
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter: center
                                                        radius: radius
                                                    startAngle: 0
                                                      endAngle: 2 * M_PI
                                                     clockwise: YES];
    
    // shape layer
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    
    shapeLayer.path = path.CGPath;
    shapeLayer.strokeColor = [UIColor grayColor].CGColor;
    
    // button
    
    self.mainButton.layer.mask = shapeLayer;

    
}

#pragma mark - IBAction

- (IBAction)didPressMainButton:(id)sender{
    
    
    
}


@end



















