//
//  TJBCircuitReferenceRowComp.m
//  Beast
//
//  Created by Trevor Beasty on 1/11/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBCircuitReferenceRowComp.h"

// aesthetics

//#import "TJBAestheticsController.h"

// stopwatch

#import "TJBStopwatch.h"

@interface TJBCircuitReferenceRowComp ()

// core

@property (nonatomic, strong) NSNumber *targetingWeight;
@property (nonatomic, strong) NSNumber *targetingReps;
@property (nonatomic, strong) NSNumber *targetingRest;
@property (nonatomic, strong) NSNumber *targetsVaryByRound;
@property (nonatomic, strong) NSNumber *roundNumber;
@property (nonatomic, strong) NSNumber *weightData;
@property (nonatomic, strong) NSNumber *repsData;
@property (nonatomic, strong) NSNumber *restData;

// IBOutlet

@property (weak, nonatomic) IBOutlet UIButton *weightButton;
@property (weak, nonatomic) IBOutlet UIButton *repsButton;
@property (weak, nonatomic) IBOutlet UIButton *restButton;
@property (weak, nonatomic) IBOutlet UILabel *roundLabel;





@end

@implementation TJBCircuitReferenceRowComp

#pragma mark - Instantiation

- (instancetype)initWithTargetingWeight:(NSNumber *)targetingWeight targetingReps:(NSNumber *)targetingReps targetingRest:(NSNumber *)targetingRest targetsVaryByRound:(NSNumber *)targetsVaryByRound roundNumber:(NSNumber *)roundNumber weightData:(NSNumber *)weightData repsData:(NSNumber *)repsData restData:(NSNumber *)restData{
    
    self = [super init];
    
    self.targetingWeight = targetingWeight;
    self.targetingReps = targetingReps;
    self.targetingRest = targetingRest;
    self.targetsVaryByRound = targetsVaryByRound;
    self.roundNumber = roundNumber;
    self.weightData = weightData;
    self.repsData = repsData;
    self.restData = restData;
    
    return self;
}

#pragma mark - View Life Cycle

- (void)viewDidLoad{
    
    [self configureViewAestheticsAndFunctionality];
    
    [self configureViewData];
}

- (void)configureViewData{

    void (^deleteTitle)(UIButton *) = ^(UIButton *button){
        [button setTitle: @""
                forState: UIControlStateNormal];
    };
    
    // if the value is being targeted, populate it.  If not, give it a blank title
    
    if ([self.targetingWeight boolValue] == YES){
        [self.weightButton setTitle: [self.weightData stringValue]
                           forState: UIControlStateNormal];
    } else{
        deleteTitle(self.weightButton);
    }
    
    if ([self.targetingReps boolValue] == YES){
        [self.repsButton setTitle: [self.repsData stringValue]
                         forState: UIControlStateNormal];
    } else{
        deleteTitle(self.repsButton);
    }
    
    if ([self.targetingRest boolValue] == YES){
        
        NSString *restString = [[TJBStopwatch singleton] minutesAndSecondsStringFromNumberOfSeconds: [self.restData intValue]];
        [self.restButton setTitle: restString
                         forState: UIControlStateNormal];
        
    } else{
        deleteTitle(self.restButton);
    }
    
    
    
}

- (void)configureViewAestheticsAndFunctionality{

    self.roundLabel.text = [NSString stringWithFormat: @"Round %d", [self.roundNumber intValue]];
    
    // button appearance
    
    NSArray *buttons = @[self.weightButton,
                         self.repsButton,
                         self.restButton];
    
    for (UIButton *button in buttons){
        
        button.backgroundColor = [UIColor whiteColor];
        [button setTitleColor: [UIColor blackColor]
                     forState: UIControlStateNormal];
        button.enabled = NO;
        
    }
}



@end
























































