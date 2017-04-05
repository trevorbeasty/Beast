//
//  TJBNumberJumpVC.m
//  Beast
//
//  Created by Trevor Beasty on 3/22/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBNumberJumpVC.h"

// aesthetics

#import "TJBAestheticsController.h"

// stopwatch

#import "TJBStopwatch.h"

@interface TJBNumberJumpVC ()

{
    
    BOOL _isTimeType;
    
}

// core

@property (strong) NSNumber *lowerLimit;
@property (strong) NSNumber *intervalSize;
@property (strong) NSNumber *numberOfLabels;
@property (copy) void (^delegateCallback)(NSNumber *);

@property (strong) NSNumber *impliedUpperLimit;

@end

@implementation TJBNumberJumpVC

#pragma mark - Instantiation

- (instancetype)initWithLowerLimit:(NSNumber *)lowerLimit numberOfLabels:(NSNumber *)numberOfLabels intervalSize:(NSNumber *)intervalSize delegateCallback:(void (^)(NSNumber *))delegateCallback{
    
    self = [super init];
    
    self.lowerLimit = lowerLimit;
    self.intervalSize = intervalSize;
    self.numberOfLabels = numberOfLabels;
    self.delegateCallback = delegateCallback;
    
    _isTimeType = NO;
    
    [self calculateAndStoreImpliedUpperLimit];
    
    return self;
    
}

- (instancetype)initWithLowerLimit:(NSNumber *)lowerLimit numberOfLabels:(NSNumber *)numberOfLabels intervalSize:(NSNumber *)intervalSize delegateCallback:(void (^)(NSNumber *))delegateCallback isTimeType:(BOOL)isTimeType{
    
    self = [super init];
    
    self.lowerLimit = lowerLimit;
    self.intervalSize = intervalSize;
    self.numberOfLabels = numberOfLabels;
    self.delegateCallback = delegateCallback;
    
    _isTimeType = isTimeType;
    
    [self calculateAndStoreImpliedUpperLimit];
    
    return self;
    
}

- (void)calculateAndStoreImpliedUpperLimit{
    
    int lowerLimit = [self.lowerLimit intValue];
    int intervalSize = [self.intervalSize intValue];
    int numberOfLabels = [self.numberOfLabels intValue];
    
    int iterativeValue = lowerLimit;
    
    for (int i = 0; i < numberOfLabels - 1; i++){
        
        iterativeValue += intervalSize;
        
    }
    
    self.impliedUpperLimit = @(iterativeValue);
    
}

#pragma mark - View Life Cycle

- (void)loadView{
    
    // labels - will use stack view
    // will also serve as the meta view
    // configure stack view
    
    UIStackView *stackView = [[UIStackView alloc] init];
    self.view = stackView;
    
    stackView.distribution = UIStackViewDistributionFillEqually;
    stackView.axis = UILayoutConstraintAxisVertical;
    stackView.alignment = UIStackViewAlignmentFill;
    
    // add labels
    // labels are added at equal intervals
    
    int lowerLimit = [self.lowerLimit intValue];
    int interval = [self.intervalSize intValue];
    
    int iterativeValue = lowerLimit;
    
    for (int i = 0; i < [self.numberOfLabels intValue]; i++){
        
        UILabel *label = [[UILabel alloc] init];
        [self configureLabelAesthetics: label];
        
        NSString *text;
        
        if (_isTimeType == NO){
            
            text = [NSString stringWithFormat: @"%d", iterativeValue];
            
        } else{
            
            text = [[TJBStopwatch singleton] minutesAndSecondsStringFromNumberOfSeconds: iterativeValue];
            
        }

        label.text = text;
        
        [stackView addArrangedSubview: label];
        
        iterativeValue += interval;
        
    }

    // GR's
    
    [self configureGestureRecognizers];
    

    
}

- (void)configureLabelAesthetics:(UILabel *)label{
    
    label.font = [UIFont boldSystemFontOfSize: 15];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [[TJBAestheticsController singleton] paleLightBlueColor];
    label.textAlignment = NSTextAlignmentCenter;
    
}

- (void)configureGestureRecognizers{
    
    // two GR's are used to provide the main functionality of this class
    // a tap GR sends the tap location
    // a swipe GR continually sends the drag location
    
    // tap GR
    
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget: self
                                                                            action: @selector(didTap:)];
    tapGR.numberOfTapsRequired = 1;
    tapGR.numberOfTouchesRequired = 1;
    
    [self.view addGestureRecognizer: tapGR];
    
}

#pragma mark - GR Actions

- (void)didTap:(UIGestureRecognizer *)gr{
    
    float vertPercent = [self equivalentPercentileForGR: gr];
    
    self.delegateCallback(@(vertPercent * [self.impliedUpperLimit floatValue]));
    
}

- (void)didPan:(UIGestureRecognizer *)gr{
    
    float vertPercent = [self equivalentPercentileForGR: gr];
    
    self.delegateCallback(@(vertPercent * [self.impliedUpperLimit floatValue]));
    
}

#pragma mark - Touch Calculation

- (float)equivalentPercentileForGR:(UIGestureRecognizer *)gr{
    
    // return the location of the touch in the view as a percentage with respect to the view's height
    // must apply some corrections to account for the fact that label text is centered
    
    CGFloat absVertLocationInView = [gr locationInView: self.view].y;
    CGFloat totalHeight = self.view.frame.size.height;
    
    // calculate the space between the text of labels
    // this will be used to create a logical structure that applies appropriate adjustments
    
    CGFloat textToTextInterval = totalHeight / ([self.numberOfLabels floatValue] + 1.0);
    
    float equivPercentile;
    
    if (absVertLocationInView < textToTextInterval / 2.0){
        
        equivPercentile = 0.0;
        
    } else if (absVertLocationInView < totalHeight - textToTextInterval / 2.0){
        
        equivPercentile = (absVertLocationInView - textToTextInterval / 2.0) / (totalHeight - textToTextInterval);
        
    } else{
        
        equivPercentile = 1.0;
        
    }
    
    return equivPercentile;
    
}



@end




































