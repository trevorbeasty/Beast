//
//  TJBCircuitActiveUpdatingRowComp.m
//  Beast
//
//  Created by Trevor Beasty on 1/11/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBCircuitActiveUpdatingRowComp.h"

// stopwatch

#import "TJBStopwatch.h"

// master controller

#import "TJBCircuitActiveUpdatingVC.h"

@interface TJBCircuitActiveUpdatingRowComp ()

// core

@property (nonatomic, strong) NSNumber *chainNumber;
@property (nonatomic, strong) NSNumber *roundNumber;
@property (nonatomic, strong) NSNumber *weightData;
@property (nonatomic, strong) NSNumber *repsData;
@property (nonatomic, strong) NSNumber *restData;
@property (nonatomic, strong) NSNumber *setLengthData;
@property (nonatomic, strong) NSNumber *setHasBeenRealized;
@property (nonatomic, strong) NSNumber *isFirstExerciseInFirstRound;
@property (nonatomic, weak) TJBCircuitActiveUpdatingVC <TJBCircuitActiveUpdatingVCProtocol> *masterController;

// IBOutlet

@property (weak, nonatomic) IBOutlet UIButton *weightButton;
@property (weak, nonatomic) IBOutlet UIButton *repsButton;
@property (weak, nonatomic) IBOutlet UIButton *restButton;
@property (weak, nonatomic) IBOutlet UILabel *roundLabel;
@property (weak, nonatomic) IBOutlet UIButton *setLengthButton;

@end

@implementation TJBCircuitActiveUpdatingRowComp

#pragma mark - Instantiation

- (instancetype)initWithRoundNumber:(NSNumber *)roundNumber chainNumber:(NSNumber *)chainNumber weightData:(NSNumber *)weightData repsData:(NSNumber *)repsData restData:(NSNumber *)restData setLengthData:(NSNumber *)setLengthData setHasBeenRealized:(NSNumber *)setHasBeenRealized isFirstExerciseInFirstRound:(NSNumber *)isFirstExerciseInFirstRound masterController:(TJBCircuitActiveUpdatingVC<TJBCircuitActiveUpdatingVCProtocol> *)masterController{
    
    self = [super init];
    
    self.chainNumber = chainNumber;
    self.roundNumber = roundNumber;
    self.weightData = weightData;
    self.repsData = repsData;
    self.restData = restData;
    self.setLengthData = setLengthData;
    self.setHasBeenRealized = setHasBeenRealized;
    self.isFirstExerciseInFirstRound = isFirstExerciseInFirstRound;
    self.masterController = masterController;
    
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
    
    //// if the set has been realized, update the views with the appropriate information
    
    BOOL setHasBeenRealized = [self.setHasBeenRealized boolValue];
    
    if (setHasBeenRealized) {
        
        TJBStopwatch *stopwatch = [TJBStopwatch singleton];
        
        // weight
        
        [self.weightButton setTitle: [self.weightData stringValue]
                           forState: UIControlStateNormal];
        
        // reps
        
        [self.repsButton setTitle: [self.repsData stringValue]
                         forState: UIControlStateNormal];
        
        // rest
        
        BOOL isFirstExerciseInFirstRound = [self.isFirstExerciseInFirstRound boolValue];
        
        if (isFirstExerciseInFirstRound){
            
            deleteTitle(self.restButton);
            
        } else if(self.restData){
    
            NSString *restTitle = [stopwatch minutesAndSecondsStringFromNumberOfSeconds: [self.restData intValue]];
                
            [self.restButton setTitle: restTitle
                                 forState: UIControlStateNormal];
                
        }
        
        // set length
        
        NSString *setLengthTitle = [stopwatch minutesAndSecondsStringFromNumberOfSeconds: [self.setLengthData intValue]];
        
        [self.setLengthButton setTitle: setLengthTitle
                              forState: UIControlStateNormal];
        
        
    } else{

        // delete all button titles
        
        NSArray *buttons  = @[self.weightButton,
                              self.repsButton,
                              self.restButton,
                              self.setLengthButton];
        
        for (UIButton *button in buttons){
            
            deleteTitle(button);
            
        }
        
    }
}

- (void)configureViewAestheticsAndFunctionality{
    
    //// configure the views according to the passed in data.  If rest data is nil, then show an empty string as the button's title
    
    // round label

    self.roundLabel.text = [NSString stringWithFormat: @"Round %d", [self.roundNumber intValue]];
    
    // button appearance
    
    NSArray *buttons = @[self.weightButton,
                         self.repsButton,
                         self.restButton,
                         self.setLengthButton];
    
    for (UIButton *button in buttons){
        
        button.backgroundColor = [UIColor whiteColor];
        
        [button setTitleColor: [UIColor blackColor]
                     forState: UIControlStateNormal];
        
        button.enabled = NO;
        
    }
}

#pragma mark - <TJBCircuitActiveUpdatingRowCompProtocol>

- (void)updateViewsWithWeight:(NSNumber *)weight reps:(NSNumber *)reps{
    
    //// update views with the passed-in parameters
    
    [self.weightButton setTitle: [weight stringValue]
                       forState: UIControlStateNormal];
    
    [self.repsButton setTitle: [reps stringValue]
                     forState: UIControlStateNormal];
    
    return;
    
}


@end















