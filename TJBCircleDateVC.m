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

// master controller

#import "TJBWorkoutNavigationHub.h"

@interface TJBCircleDateVC ()

{
    float _radius;
    CGSize _size;
    BOOL _hasSelectedAppearance;
    BOOL _isCircled;
    BOOL _isEnabled;
    BOOL _representsHistoricDay;
    CGPoint _center;
}

// IBOutlet

@property (weak, nonatomic) IBOutlet UILabel *dayLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;

// core

@property (nonatomic, strong) NSNumber *dayIndex;
@property (nonatomic, strong) NSString *dayTitle;
@property (nonatomic, strong) CAShapeLayer *activeShapeLayer;
@property (nonatomic, weak) TJBWorkoutNavigationHub<TJBDateSelectionMaster> *masterController;
@property (nonatomic, strong) NSDate *representedDate;

@end

@implementation TJBCircleDateVC

#pragma mark - Instantiation

- (instancetype)initWithDayIndex:(NSNumber *)dayIndex dayTitle:(NSString *)dayTitle size:(CGSize)size hasSelectedAppearance:(BOOL)hasSelectedAppearance isEnabled:(BOOL)isEnabled isCircled:(BOOL)isCircled masterController:(TJBWorkoutNavigationHub<TJBDateSelectionMaster> *)masterController representedDate:(NSDate *)representedDate representsHistoricDay:(BOOL)representsHistoricDay{
    
    self = [super init];
    
    if (self){
        
        self.dayIndex = dayIndex;
        self.dayTitle = dayTitle;
        _size = size;
        _hasSelectedAppearance = hasSelectedAppearance;
        _isCircled = isCircled;
        _isEnabled = isEnabled;
        self.masterController = masterController;
        self.representedDate = representedDate;
        _representsHistoricDay = representsHistoricDay;
        
    }
    
    return self;
    
}

#pragma mark - View Life Cycle

- (void)viewDidLoad{
    
    // configure the center property which will be used to create circle effects
    
    _center = CGPointMake(_size.width / 2.0, _size.height - 6.0);
    _radius = 3.0;
    
    // GR
    
    // the tap GR will always be there. It only reacts (in the didSelectView method) if the vc isEnableld == YES
    
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget: self
                                                                            action: @selector(didSelectView)];
    tapGR.numberOfTouchesRequired = 1;
    tapGR.numberOfTapsRequired = 1;
    
    [self.view addGestureRecognizer: tapGR];
    
    [self configureViews];
    
}

- (void)drawCircleWithOpacity:(float)opacity{
    
    if (self.activeShapeLayer){
        
        [self.activeShapeLayer removeFromSuperlayer];
        
    }
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter: _center
                                                        radius: _radius
                                                    startAngle: 0
                                                      endAngle: 2 * M_PI
                                                     clockwise: YES];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    self.activeShapeLayer = shapeLayer;
    shapeLayer.path = path.CGPath;
    shapeLayer.opacity = opacity;
    
    if (_hasSelectedAppearance){
        
        shapeLayer.strokeColor = [UIColor blackColor].CGColor;
        shapeLayer.fillColor = [UIColor blackColor].CGColor;
        
    } else{
        
        shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
        shapeLayer.fillColor = [UIColor whiteColor].CGColor;
        
    }
    
    [self.view.layer addSublayer: shapeLayer];
    
}

- (void)configureViews{
    
    // appearances
    
    self.view.backgroundColor = [UIColor blackColor];
    
    self.numberLabel.backgroundColor = [UIColor clearColor];
    self.numberLabel.textColor = [UIColor whiteColor];
    NSString *numberTitle = [NSString stringWithFormat: @"%d", [self.dayIndex intValue] + 1];
    self.numberLabel.text = numberTitle;
    self.numberLabel.font = [UIFont boldSystemFontOfSize: 20.0];
        
    self.dayLabel.text = self.dayTitle;
    self.dayLabel.textColor = [UIColor whiteColor];
    self.dayLabel.backgroundColor = [UIColor clearColor];
    self.dayLabel.font = [UIFont systemFontOfSize: 15.0];
    
    if (_representsHistoricDay){
        
        self.view.backgroundColor = [UIColor darkGrayColor];
        
    } else{
        
        self.view.backgroundColor = [UIColor lightGrayColor];
        
    }
    
    if (_hasSelectedAppearance){
        
        [self configureButtonAsSelected];
        
    }
    
    if (_isCircled){
        
        [self drawCircleWithOpacity: 1.0];
        
    }
    
}


#pragma mark - General API

- (void)configureButtonAsSelected{
    
    _hasSelectedAppearance = YES;
    
    UIColor *color = [[TJBAestheticsController singleton] yellowNotebookColor];
    
    self.view.backgroundColor = color;
    self.dayLabel.textColor = [UIColor blackColor];
    self.numberLabel.textColor = [UIColor blackColor];
    
    if (_isCircled){
        
        [self drawCircleWithOpacity: .4];
        
    }
    
}

- (void)configureButtonAsNotSelected{
    
    _hasSelectedAppearance = NO;
    
    UIColor *color;
    
    if (_representsHistoricDay){
        color = [UIColor darkGrayColor];
    } else{
        color = [UIColor lightGrayColor];
    }
    
    self.view.backgroundColor = color;
    self.dayLabel.textColor = [UIColor whiteColor];
    self.numberLabel.textColor = [UIColor whiteColor];
    
    if (_isCircled){
        
        [self drawCircleWithOpacity: .4];
        
    }
    
}

- (void)configureWithDayTitle:(NSString *)dayTitle buttonTitle:(NSString *)buttonTitle{
    
    self.dayLabel.text = dayTitle;
    self.numberLabel.text = buttonTitle;
    
}

#pragma mark - Gesture Recognizer

- (void)didSelectView{
    
    if (_isEnabled == YES && _representsHistoricDay == YES){
        
        [self.masterController didSelectObjectWithIndex: self.dayIndex
                                        representedDate: self.representedDate];
        
    }
    
}

#pragma mark - Runtime Manipulation

- (void)configureEnabledAppearance{
    
    NSArray *views = @[self.numberLabel, self.dayLabel];
    for (UIView *v in views){
        
        v.layer.opacity = 1.0;
        
    }
    
    if (_isCircled){
        
        [self drawCircleWithOpacity: 1.0];
        
    }
    
    _isEnabled = YES;
    
}

- (void)configureDisabledAppearance{
    
    NSArray *views = @[self.numberLabel, self.dayLabel];
    for (UIView *v in views){
        
        v.layer.opacity = .4;
        
    }
    
    if (_isCircled){
        
        [self drawCircleWithOpacity: .4];
        
    }
    
    _isEnabled = NO;
    
}

- (void)getRidOfContentDot{
    
    _isCircled = NO;
    
    if (self.activeShapeLayer){
        
        [self.activeShapeLayer removeFromSuperlayer];
        self.activeShapeLayer = nil;
        
    }
    
}


@end



















