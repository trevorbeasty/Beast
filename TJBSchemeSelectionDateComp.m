//
//  TJBSchemeSelectionDateComp.m
//  Beast
//
//  Created by Trevor Beasty on 2/2/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBSchemeSelectionDateComp.h"

// master controller

#import "NewOrExistinigCircuitVC.h"

// aesthetics

#import "TJBAestheticsController.h"

@interface TJBSchemeSelectionDateComp ()

{
    
    // core
    
    BOOL _isEnabled;
    BOOL _hasSelectedAppearance;
    BOOL _isCircled;
    BOOL _representsPastDate;
    CGSize _size;
    
}

// IBOutlet

@property (weak, nonatomic) IBOutlet UILabel *monthLabel;

// core

@property (nonatomic, strong) NSString *monthString;
@property (nonatomic, strong) NSNumber *index;
@property (nonatomic, strong) NSDate *representedDate;
@property (nonatomic, weak) NewOrExistinigCircuitVC<TJBSchemeSelectionDateCompDelegate> *masterController;

// state

@property (nonatomic, weak) CAShapeLayer *activeShapeLayer;



@end

@implementation TJBSchemeSelectionDateComp

#pragma mark - Instantiation

- (instancetype)initWithMonthString:(NSString *)monthString representedDate:(NSDate *)representedDate index:(NSNumber *)index isEnabled:(BOOL)isEnabled isCircled:(BOOL)isCircled hasSelectedAppearance:(BOOL)hasSelectedAppearance size:(CGSize)size masterController:(NewOrExistinigCircuitVC<TJBSchemeSelectionDateCompDelegate> *)masterController representsPastDate:(BOOL)representsPastDate{
    
    self = [super init];
    
    _isEnabled = isEnabled;
    _hasSelectedAppearance = hasSelectedAppearance;
    _isCircled = isCircled;
    _representsPastDate = representsPastDate;
    _size = size;
    self.representedDate = representedDate;
    self.masterController = masterController;
    self.monthString = monthString;
    self.index = index;
    
    return self;
    
}

#pragma mark - View Life Cycle

- (void)viewDidLoad{
    
    [self configureGestureRecognizer];

    if (_isCircled){
        
        [self drawCircle];
        
    }
    
    [self configureViews];
    
}

- (void)configureGestureRecognizer{
    
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget: self
                                                                            action: @selector(didSelectView)];
    tapGR.numberOfTouchesRequired = 1;
    tapGR.numberOfTapsRequired = 1;
    
    [self.view addGestureRecognizer: tapGR];
    
}

- (void)drawCircle{
    
    _isCircled = YES;
    
    // if a previous circle exists, remove it
    
    if (self.activeShapeLayer){
        
        [self.activeShapeLayer removeFromSuperlayer];
        
    }
    
    //
    
    CGPoint center = CGPointMake(_size.width / 2.0, _size.height - 8.0);
    CGFloat radius = 3.0;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter: center
                                                        radius: radius
                                                    startAngle: 0
                                                      endAngle: 2 * M_PI
                                                     clockwise: YES];
    
    CAShapeLayer *shapeLayer = [CAShapeLayer layer];
    self.activeShapeLayer = shapeLayer;
    shapeLayer.path = path.CGPath;
    
    if (_hasSelectedAppearance){
        
        shapeLayer.strokeColor = [UIColor darkGrayColor].CGColor;
        shapeLayer.fillColor = [UIColor darkGrayColor].CGColor;
        
    } else{
        
        shapeLayer.strokeColor = [UIColor whiteColor].CGColor;
        shapeLayer.fillColor = [UIColor whiteColor].CGColor;
        
    }
    
    [self.view.layer addSublayer: shapeLayer];
    
}

- (void)deleteCircle{
    
    _isCircled = NO;
    
    if (self.activeShapeLayer){
        
        [self.activeShapeLayer removeFromSuperlayer];
        
    }
    
}

- (void)configureViews{
    
    // label
    
    self.monthLabel.text = self.monthString;
    self.monthLabel.font = [UIFont boldSystemFontOfSize: 20.0];
    
    if (_hasSelectedAppearance){
        
        [self configureAsSelected];
        
    } else{
        
        [self configureAsNotSelected];
        
    }
    
}

#pragma mark - Actions

- (void)didSelectView{
    
    if (_isEnabled && _representsPastDate){
        
        [self.masterController didSelectObjectWithIndex: self.index];
        
    }
        
}

#pragma mark - API

- (void)configureAsSelected{
    
    _hasSelectedAppearance = YES;
    
    self.monthLabel.textColor = [UIColor darkGrayColor];
    self.view.backgroundColor = [[TJBAestheticsController singleton] paleLightBlueColor];
    
    if (_isCircled){
        
        [self drawCircle];
        
    }
    
}

- (void)configureAsNotSelected{
    
    _hasSelectedAppearance = NO;
    
    if (!_representsPastDate){
        
        self.monthLabel.textColor = [UIColor whiteColor];
        self.view.backgroundColor = [UIColor lightGrayColor];
        
    } else{
        
        self.monthLabel.textColor = [UIColor whiteColor];
        self.view.backgroundColor = [UIColor darkGrayColor];
        
    }
    
    if (_isCircled){
        
        [self drawCircle];
        
    }
    
}

- (void)configureAsEnabled{
    
    self.monthLabel.layer.opacity = 1.0;
    
    _isEnabled = YES;
    
}

- (void)configureAsDisabled{
    
    self.monthLabel.layer.opacity = .4;
    
    _isEnabled = NO;
    
}



@end

























