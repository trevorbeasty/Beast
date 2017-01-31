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
    CGSize _size;
    BOOL _hasSelectedAppearance;
    BOOL _isCircled;
    BOOL _isEnabled;
    CGPoint _center;
}

// IBOutlet

@property (weak, nonatomic) IBOutlet UIButton *mainButton;
@property (weak, nonatomic) IBOutlet UILabel *dayLabel;

// IBAction

- (IBAction)didPressMainButton:(id)sender;

// core

@property (nonatomic, strong) NSString *mainButtonTitle;
@property (nonatomic, strong) NSString *dayTitle;
@property (nonatomic, strong) CAShapeLayer *activeShapeLayer;

@end

@implementation TJBCircleDateVC

#pragma mark - Instantiation

- (instancetype)initWithMainButtonTitle:(NSString *)mainButtonTitle dayTitle:(NSString *)dayTitle size:(CGSize)size hasSelectedAppearance:(BOOL)hasSelectedAppearance isEnabled:(BOOL)isEnabled isCircled:(BOOL)isCircled{
    
    self = [super init];
    
    if (self){
        
        self.mainButtonTitle = mainButtonTitle;
        self.dayTitle = dayTitle;
        _size = size;
        _hasSelectedAppearance = hasSelectedAppearance;
        _isCircled = isCircled;
        _isEnabled = isEnabled;
        
    }
    
    return self;
    
}

#pragma mark - View Life Cycle

- (void)viewDidLoad{
    
    // configure the center property which will be used to create circle effects
    
    const CGFloat dayLabelHeight = 20.0;
    const CGFloat spacing = 4.0;
    
    _center = CGPointMake(_size.width / 2.0, (_size.height - dayLabelHeight - spacing) / 2.0);
    _radius = _size.width / 2.0 - 3.0;
    
    [self configureViews];
    
}

- (void)drawCircle{
    
    if (self.activeShapeLayer){
        
        [self.activeShapeLayer removeFromSuperlayer];
        
    }
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter: _center
                                                        radius: _radius - 1.0
                                                    startAngle: 0
                                                      endAngle: 2 * M_PI
                                                     clockwise: YES];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    self.activeShapeLayer = shapeLayer;
    
    shapeLayer.path = path.CGPath;
    shapeLayer.fillColor = nil;
    shapeLayer.borderWidth = 2.0;
    
    if (_hasSelectedAppearance){
        
        shapeLayer.strokeColor = [UIColor blackColor].CGColor;
        
    } else{
        
        shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
        
    }
    
    [self.mainButton.layer addSublayer: shapeLayer];
    
}

- (void)configureViews{
    
    // appearances
    
    self.view.backgroundColor = [UIColor blackColor];
    
    self.mainButton.backgroundColor = [UIColor clearColor];
    [self.mainButton setTitleColor: [UIColor whiteColor]
                          forState: UIControlStateNormal];
    [self.mainButton setTitle: self.mainButtonTitle
                     forState: UIControlStateNormal];
    self.mainButton.titleLabel.font = [UIFont boldSystemFontOfSize: 20.0];
        
    self.dayLabel.text = self.dayTitle;
    self.dayLabel.textColor = [UIColor whiteColor];
    self.dayLabel.backgroundColor = [UIColor clearColor];
    self.dayLabel.font = [UIFont systemFontOfSize: 15.0];
    
    if (!_isEnabled){
        
        self.mainButton.enabled = NO;
        
        self.mainButton.backgroundColor = [UIColor grayColor];
        self.dayLabel.backgroundColor = [UIColor grayColor];
        self.view.backgroundColor = [UIColor grayColor];
        
    }
    
    if (_hasSelectedAppearance){
        
        [self configureButtonAsSelected];
        
    }
    
    if (_isCircled){
        
        [self drawCircle];
        
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
    
    _hasSelectedAppearance = YES;
    
    UIColor *color = [[TJBAestheticsController singleton] yellowNotebookColor];
    
    self.view.backgroundColor = color;
    
    self.dayLabel.backgroundColor = color;
    self.dayLabel.textColor = [UIColor blackColor];
    
    self.mainButton.titleLabel.backgroundColor = color;
    [self.mainButton setTitleColor: [UIColor blackColor]
                          forState: UIControlStateNormal];
    
    if (_isCircled){
        
        [self drawCircle];
        
    }
    
}

- (void)configureButtonAsNotSelected{
    
    _hasSelectedAppearance = NO;
    
    UIColor *color = [UIColor blackColor];
    
    self.view.backgroundColor = color;
    
    self.dayLabel.backgroundColor = color;
    self.dayLabel.textColor = [UIColor whiteColor];
    
    self.mainButton.titleLabel.backgroundColor = color;
    [self.mainButton setTitleColor: [UIColor whiteColor]
                          forState: UIControlStateNormal];
    
    if (_isCircled){
        
        [self drawCircle];
        
    }
    
}

- (void)configureWithDayTitle:(NSString *)dayTitle buttonTitle:(NSString *)buttonTitle{
    
    self.dayLabel.text = dayTitle;
    [self.mainButton setTitle: buttonTitle
                     forState: UIControlStateNormal];
    
}

#pragma mark - IBAction

- (IBAction)didPressMainButton:(id)sender{
    
    NSLog(@"main button pressed");
    
}


@end



















