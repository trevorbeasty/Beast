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
    float _radius;
    CGPoint _center;
    BOOL _selectedAppearance;
}

// IBOutlet

@property (weak, nonatomic) IBOutlet UIButton *mainButton;
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;

// IBAction

- (IBAction)didPressMainButton:(id)sender;

// core

@property (nonatomic, strong) NSString *mainButtonTitle;
@property (nonatomic, strong) NSString *dayTitle;




@end

@implementation TJBCircleDateVC

#pragma mark - Instantiation

- (instancetype)initWithMainButtonTitle:(NSString *)mainButtonTitle dayTitle:(NSString *)dayTitle radius:(float)radius center:(CGPoint)center selectedAppearance:(BOOL)selectedAppearance{
    
    self = [super init];
    
    if (self){
        
        self.mainButtonTitle = mainButtonTitle;
        self.dayTitle = dayTitle;
        _radius = radius;
        _center = center;
        _selectedAppearance = selectedAppearance;
        
    }
    
    return self;
    
}

#pragma mark - View Life Cycle

- (void)viewDidLoad{
    
    [self configureViewAesthetics];
    
}

- (void)addCircularBorder{
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter: _center
                                                        radius: _radius - 1.0
                                                    startAngle: 0
                                                      endAngle: 2 * M_PI
                                                     clockwise: YES];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    
    shapeLayer.path = path.CGPath;
    shapeLayer.fillColor = nil;
    shapeLayer.borderWidth = 2.0;
    shapeLayer.strokeColor = [[TJBAestheticsController singleton] color1].CGColor;
    
    [self.mainButton.layer addSublayer: shapeLayer];
    
}

- (void)configureViewAesthetics{
    
    // main button
        
    self.mainButton.backgroundColor = [UIColor whiteColor];
        
    [self.mainButton setTitle: self.mainButtonTitle
                     forState: UIControlStateNormal];
        
    [self.mainButton setTitleColor: [[TJBAestheticsController singleton] color1]
                          forState: UIControlStateNormal];
        
    // day label
        
    self.dayLabel.text = self.dayTitle;
    self.dayLabel.textColor = [[TJBAestheticsController singleton] color1];
        
    //
        
    [self addCircularBorder];
    
    if (_selectedAppearance){
        
        [self configureButtonAsSelected];
        
    } else{
        
        [self configureButtonAsNotSelected];
        
    }

    
    
}

- (void)configureButtonMask{
    
    // establish the bezier path

    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter: _center
                                                        radius: _radius
                                                    startAngle: 0
                                                      endAngle: 2 * M_PI
                                                     clockwise: YES];
    
    // shape layer
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    
    shapeLayer.path = path.CGPath;
    
    
    // button
    
    self.mainButton.layer.mask = shapeLayer;

}

#pragma mark - General API

- (void)configureButtonAsSelected{
    
    self.dayLabel.font = [UIFont boldSystemFontOfSize: 17.0];
    self.mainButton.titleLabel.font = [UIFont boldSystemFontOfSize: 17.0];
    
}

- (void)configureButtonAsNotSelected{
    
    self.dayLabel.font = [UIFont systemFontOfSize: 17.0];
    self.mainButton.titleLabel.font = [UIFont systemFontOfSize: 17.0];
    
}

#pragma mark - IBAction

- (IBAction)didPressMainButton:(id)sender{
    
    
    
}


@end



















