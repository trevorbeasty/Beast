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

// aesthetics

#import "TJBAestheticsController.h"

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

// IBAction

- (IBAction)didPressWeightButton:(id)sender;
- (IBAction)didPressRepsButton:(id)sender;


// IBOutlet

@property (weak, nonatomic) IBOutlet UIButton *weightButton;
@property (weak, nonatomic) IBOutlet UIButton *repsButton;
@property (weak, nonatomic) IBOutlet UIButton *restButton;
@property (weak, nonatomic) IBOutlet UILabel *roundLabel;

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
        
//        // set length
//        
//        NSString *setLengthTitle = [stopwatch minutesAndSecondsStringFromNumberOfSeconds: [self.setLengthData intValue]];
//        
//        [self.setLengthButton setTitle: setLengthTitle
//                              forState: UIControlStateNormal];
        
        
    } else{

        // delete all button titles
        
        NSArray *buttons  = @[self.weightButton,
                              self.repsButton,
                              self.restButton];
        
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
                         self.restButton];
    
    for (UIButton *button in buttons){
        
        button.backgroundColor = [UIColor whiteColor];
        
        [button setTitleColor: [UIColor blackColor]
                     forState: UIControlStateNormal];
        
        button.enabled = NO;
        
    }
}

#pragma mark - <TJBCircuitActiveUpdatingRowCompProtocol>

- (void)updateViewsWithWeight:(NSNumber *)weight reps:(NSNumber *)reps rest:(NSNumber *)rest setLength:(NSNumber *)setLength{
    
    //// update views with the passed-in parameters.  If the rest parameter is nil, give the rest button a blank title
    
    // weight
    
    [self.weightButton setTitle: [weight stringValue]
                       forState: UIControlStateNormal];
    
    // reps
    
    [self.repsButton setTitle: [reps stringValue]
                     forState: UIControlStateNormal];
    
    // rest
    
    if (rest){
        
        NSString *restTitle = [[TJBStopwatch singleton] minutesAndSecondsStringFromNumberOfSeconds: [rest intValue]];
        
        [self.restButton setTitle: restTitle
                         forState: UIControlStateNormal];
        
    } else{
        
        [self.restButton setTitle: @""
                         forState: UIControlStateNormal];
        
    }
    
//    // set length
//    
//    NSString *setLengthTitle = [[TJBStopwatch singleton] minutesAndSecondsStringFromNumberOfSeconds: [setLength intValue]];
//    
//    [self.setLengthButton setTitle: setLengthTitle
//                          forState: UIControlStateNormal];
    
    return;
    
}

//// for making corrections

- (void)enableWeightAndRepsButtonsAndGiveEnabledAppearance{
    
    //// give the weight and reps buttons the appropriate enabled appearance and enable them
    
    void (^activeButtonConfiguration)(UIButton *) = ^(UIButton *button){
        
        button.enabled = YES;
        
        button.backgroundColor = [[TJBAestheticsController singleton] buttonBackgroundColor];
        
        [button setTitleColor: [[TJBAestheticsController singleton] buttonTextColor]
                     forState: UIControlStateNormal];
        
        CALayer *layer = button.layer;
        
        layer.masksToBounds = YES;
        layer.cornerRadius = 8.0;
        layer.opacity = .85;
        
    };
    
    activeButtonConfiguration(self.weightButton);
    activeButtonConfiguration(self.repsButton);
    
    return;
    
}

- (void)disableWeightAndRepsButtonsAndGiveDisabledAppearance{
    
    [self disableWeightButtonAndGiveDisabledAppearance];
    
    [self disableRepsButtonAndGiveDisabledAppearance];

}

- (void)disableWeightButtonAndGiveDisabledAppearance{
    
    void (^disabledButtonConfiguration)(UIButton *) = ^(UIButton *button){
        
        [button setTitleColor: [UIColor blackColor]
                     forState: UIControlStateNormal];
        
        button.backgroundColor = [UIColor whiteColor];
        
        button.enabled = NO;
        
    };
    
    disabledButtonConfiguration(self.weightButton);
    
}

- (void)disableRepsButtonAndGiveDisabledAppearance{
    
    void (^disabledButtonConfiguration)(UIButton *) = ^(UIButton *button){
        
        [button setTitleColor: [UIColor blackColor]
                     forState: UIControlStateNormal];
        
        button.backgroundColor = [UIColor whiteColor];
        
        button.enabled = NO;
        
    };
    
    disabledButtonConfiguration(self.repsButton);
    
}

#pragma mark - IBAction

- (IBAction)didPressWeightButton:(id)sender{
    
    //// call the master controller's protocol method
    
    [self.masterController didPressUserInputButtonWithType: WeightType
                                               chainNumber: self.chainNumber
                                               roundNumber: self.roundNumber
                                                    button: self.weightButton];
    
}

- (IBAction)didPressRepsButton:(id)sender{
    
    //// call the master controller's protocol method
    
    [self.masterController didPressUserInputButtonWithType: RepsType
                                               chainNumber: self.chainNumber
                                               roundNumber: self.roundNumber
                                                    button: self.repsButton];
    
}



@end


































