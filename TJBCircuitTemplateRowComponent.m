//
//  TJBCircuitTemplateRowComponent.m
//  Beast
//
//  Created by Trevor Beasty on 1/10/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBCircuitTemplateRowComponent.h"

// master VC

#import "TJBCircuitTemplateVC.h"

// aesthetics

#import "TJBAestheticsController.h"

// stopwatch

#import "TJBStopwatch.h"

// core data

#import "CoreDataController.h"

@interface TJBCircuitTemplateRowComponent ()

// core

@property (nonatomic, strong) NSNumber *targetingWeight;
@property (nonatomic, strong) NSNumber *targetingReps;
@property (nonatomic, strong) NSNumber *targetingRest;
@property (nonatomic, strong) NSNumber *targetsVaryByRound;
@property (nonatomic, strong) NSNumber *roundNumber;
@property (nonatomic, strong) NSNumber *chainNumber;

// IBAction

- (IBAction)didPressWeightButton:(id)sender;
- (IBAction)didPressRepsButton:(id)sender;
- (IBAction)didPressRestButton:(id)sender;

// IBOutlet

@property (weak, nonatomic) IBOutlet UIButton *weightButton;
@property (weak, nonatomic) IBOutlet UIButton *repsButton;
@property (weak, nonatomic) IBOutlet UIButton *restButton;
@property (weak, nonatomic) IBOutlet UILabel *roundLabel;

// delegate

@property (nonatomic, weak) TJBCircuitTemplateVC <TJBCircuitTemplateVCProtocol> *masterController;

@end

@implementation TJBCircuitTemplateRowComponent

#pragma mark - Instantiation

- (instancetype)initWithTargetingWeight:(NSNumber *)targetingWeight targetingReps:(NSNumber *)targetingReps targetingRest:(NSNumber *)targetingRest targetsVaryByRound:(NSNumber *)targetsVaryByRound roundNumber:(NSNumber *)roundNumber masterController:(TJBCircuitTemplateVC<TJBCircuitTemplateVCProtocol> *)masterController chainNumber:(NSNumber *)chainNumber{
    
    self = [super init];
    
    self.targetingWeight = targetingWeight;
    self.targetingReps = targetingReps;
    self.targetingRest = targetingRest;
    self.targetsVaryByRound = targetsVaryByRound;
    self.roundNumber = roundNumber;
    self.masterController = masterController;
    self.chainNumber = chainNumber;
    
    return self;
}

#pragma mark - View Life Cycle

- (void)viewDidLoad{
    
    [self viewAesthetics];
}

- (void)viewAesthetics{
    TJBAestheticsController *aesthetics = [TJBAestheticsController singleton];
    
    // round label
    
    if ([self.targetsVaryByRound intValue] == 0)
    {
        self.roundLabel.text = @"All Rounds";
    }
    else
    {
        self.roundLabel.text = [NSString stringWithFormat: @"Round %d", [self.roundNumber intValue]];
    }
    
    // button appearance
    
    void (^eraseButton)(UIButton *) = ^(UIButton *button){
        button.backgroundColor = [UIColor whiteColor];
        [button setTitle: @""
                forState: UIControlStateNormal];
        button.enabled = NO;
    };
    
        
        void (^activeButtonConfiguration)(UIButton *) = ^(UIButton *button){
            button.backgroundColor = [aesthetics buttonBackgroundColor];
            [button setTitleColor: [aesthetics buttonTextColor]
                         forState: UIControlStateNormal];
            CALayer *layer = button.layer;
            layer.masksToBounds = YES;
            layer.cornerRadius = 8.0;
            layer.opacity = .85;
        };
        
        if ([self.targetingWeight boolValue] == YES){
            
            activeButtonConfiguration(self.weightButton);
        } else{
            
            eraseButton(self.weightButton);
        }
        
        if ([self.targetingReps boolValue] == YES){
            
            activeButtonConfiguration(self.repsButton);
        } else{
            
            eraseButton(self.repsButton);
        }
        
        if ([self.targetingRest boolValue] == YES){
            
            activeButtonConfiguration(self.restButton);
        } else{
            
            eraseButton(self.restButton);
        }
        
    
}


#pragma mark - Button Actions

- (IBAction)didPressWeightButton:(id)sender
{
    
        [self.masterController didPressUserInputButtonWithType: WeightType
                                                   chainNumber: self.chainNumber
                                                   roundNumber: self.roundNumber
                                                        button: self.weightButton];
}

- (IBAction)didPressRepsButton:(id)sender{
    
    
        [self.masterController didPressUserInputButtonWithType: RepsType
                                                   chainNumber: self.chainNumber
                                                   roundNumber: self.roundNumber
                                                        button: self.repsButton];
}

- (IBAction)didPressRestButton:(id)sender{
    
    
        [self.masterController didPressUserInputButtonWithType: RestType
                                                   chainNumber: self.chainNumber
                                                   roundNumber: self.roundNumber
                                                        button: self.restButton];
}

#pragma mark - <TJBCircuitTemplateRowComponentProtocol>

//- (void)updateLabelWithNumberType:(NumberType)numberType value:(double)value{
//    
//    NSString *string = [[NSNumber numberWithDouble: value] stringValue];
//    NSString *restString = [[TJBStopwatch singleton] minutesAndSecondsStringFromNumberOfSeconds: value];
//    
//    switch (numberType) {
//        case WeightType:
//            [self.weightButton setTitle: string
//                               forState: UIControlStateNormal];
//            break;
//        case RepsType:
//            [self.repsButton setTitle: string
//                             forState: UIControlStateNormal];
//            break;
//        case RestType:
//            [self.restButton setTitle: restString
//                             forState: UIControlStateNormal];
//            break;
//            
//        default:
//            break;
//    }
//}

- (void)updateViewsWithUserSelectedWeight:(TJBNumberTypeArrayComp *)weight reps:(TJBNumberTypeArrayComp *)reps rest:(TJBNumberTypeArrayComp *)rest{
    
    //// if respective object is not a default, update the corresponding view appropriately
    
    CoreDataController *cdc = [CoreDataController singleton];
    
    // weight
    
    BOOL weightIsDefaultObject = [cdc numberTypeArrayCompIsDefaultObject: weight];
    
    if (!weightIsDefaultObject){
        
        NSString *weightTitle = [[NSNumber numberWithFloat: weight.value] stringValue];
        
        [self.weightButton setTitle: weightTitle
                           forState: UIControlStateNormal];
        [self configureButtonWithSelectedAppearance: self.weightButton];
        
    }
    
    // reps
    
    BOOL repsIsDefaultObject = [cdc numberTypeArrayCompIsDefaultObject: reps];
    
    if (!repsIsDefaultObject){
        
        NSString *repsTitle = [[NSNumber numberWithFloat: reps.value] stringValue];
        
        [self.repsButton setTitle: repsTitle
                           forState: UIControlStateNormal];
        [self configureButtonWithSelectedAppearance: self.repsButton];
        
    }
    
    // rest
    
    BOOL restIsDefaultObject = [cdc numberTypeArrayCompIsDefaultObject: rest];
    
    if (!restIsDefaultObject){
        
        NSString *restTitle = [[TJBStopwatch singleton] minutesAndSecondsStringFromNumberOfSeconds: rest.value];
        
        [self.restButton setTitle: restTitle
                         forState: UIControlStateNormal];
        [self configureButtonWithSelectedAppearance: self.restButton];
        
    }
    
}

- (void)configureButtonWithSelectedAppearance:(UIButton *)button{
    
    //// configure the passed in button with the 'selected' appearance
    
    button.backgroundColor = [UIColor whiteColor];
    [button setTitleColor: [UIColor blackColor]
                 forState: UIControlStateNormal];
    
}



@end












































