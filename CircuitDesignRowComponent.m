//
//  CircuitDesignRowComponent.m
//  Beast
//
//  Created by Trevor Beasty on 12/15/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import "CircuitDesignRowComponent.h"

#import "TJBCircuitTemplateGeneratorVC.h"
#import "TJBChainTemplate+CoreDataProperties.h"
#import "TJBWeightArray+CoreDataProperties.h"
#import "TJBRepsArray+CoreDataProperties.h"
#import "TJBTargetRestTimeArray+CoreDataProperties.h"
#import "TJBNumberTypeArrayComp+CoreDataProperties.h"
#import "TJBStopwatch.h"

#import "TJBAestheticsController.h"

#import "TJBStopwatch.h"

@interface CircuitDesignRowComponent ()
{
    // core
    BOOL _supportsUserInput;
    BOOL _valuesPopulatedDuringWorkout;
}

@property (weak, nonatomic) IBOutlet UIButton *weightButton;
@property (weak, nonatomic) IBOutlet UIButton *repsButton;
@property (weak, nonatomic) IBOutlet UIButton *restButton;

- (IBAction)didPressWeightButton:(id)sender;
- (IBAction)didPressRepsButton:(id)sender;
- (IBAction)didPressRestButton:(id)sender;

// core
@property (nonatomic, strong) NSNumber *targetingWeight;
@property (nonatomic, strong) NSNumber *targetingReps;
@property (nonatomic, strong) NSNumber *targetingRest;
@property (nonatomic, strong) NSNumber *targetsVaryByRound;
@property (nonatomic, strong) NSNumber *roundNumber;
@property (nonatomic, strong) NSNumber *chainNumber;

@property (nonatomic, strong) TJBChainTemplate *chainTemplate;

@property (nonatomic, strong) TJBCircuitTemplateGeneratorVC <TJBCircuitTemplateUserInputDelegate> *masterController;

@end

@implementation CircuitDesignRowComponent

#pragma mark - Instantiation

- (instancetype)initWithTargetingWeight:(NSNumber *)targetingWeight targetingReps:(NSNumber *)targetingReps targetingRest:(NSNumber *)targetingRest targetsVaryByRound:(NSNumber *)targetsVaryByRound roundNumber:(NSNumber *)roundNumber masterController:(TJBCircuitTemplateGeneratorVC *)masterController chainNumber:(NSNumber *)chainNumber supportsUserInput:(BOOL)supportsUserInput chainTemplate:(TJBChainTemplate *)chainTemplate valuesPopulatedDuringWorkout:(BOOL)valuesPopulatedDuringWorkout{
    self = [super init];
    
    self.targetingWeight = targetingWeight;
    self.targetingReps = targetingReps;
    self.targetingRest = targetingRest;
    self.targetsVaryByRound = targetsVaryByRound;
    self.roundNumber = roundNumber;
    self.masterController = masterController;
    self.chainNumber = chainNumber;
    _supportsUserInput = supportsUserInput;
    self.chainTemplate = chainTemplate;
    
    _valuesPopulatedDuringWorkout = valuesPopulatedDuringWorkout;
    
    return self;
}

#pragma mark - View Life Cycle

- (void)viewDidLoad{
    [self viewAesthetics];
    [self populateButtonsWithDataIfNotCollectingUserInput];
}

- (void)viewAesthetics{
    TJBAestheticsController *aesthetics = [TJBAestheticsController singleton];

    // round label
    if ([self.targetsVaryByRound intValue] == 0 && _supportsUserInput == YES)
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
    
    if (_supportsUserInput == YES){
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
    } else if (_supportsUserInput == NO){
        NSArray *buttons = @[self.weightButton,
                             self.repsButton,
                             self.restButton];
        for (UIButton *button in buttons){
            [button setTitleColor: [UIColor blackColor]
                         forState: UIControlStateNormal];
        }
        
        if ([self.targetingWeight intValue] == NO){
            eraseButton(self.weightButton);
        }
        if ([self.targetingReps intValue] == NO){
            eraseButton(self.repsButton);
        }
        if ([self.targetingRest intValue] == NO){
            eraseButton(self.restButton);
        }
    }
}

- (void)populateButtonsWithDataIfNotCollectingUserInput{
    if (_supportsUserInput == NO){
        if (_valuesPopulatedDuringWorkout == YES){
            NSArray *buttons = @[self.weightButton,
                                 self.repsButton,
                                 self.restButton];
            NSString *blank = @"";
            for (UIButton *button in buttons){
                [button setTitle: blank
                        forState: UIControlStateNormal];
            }
        } else{
            int chainIndex = [self.chainNumber intValue] - 1;
            int roundIndex = [self.roundNumber intValue] - 1;
            
            TJBChainTemplate *chainTemplate = self.chainTemplate;
            
            if (chainTemplate.targetingWeight == YES){
                NSString *weightString = [[NSNumber numberWithDouble: chainTemplate.weightArrays[chainIndex].numbers[roundIndex].value] stringValue];
                [self.weightButton setTitle: weightString
                                   forState: UIControlStateNormal];
            };
            
            if (chainTemplate.targetingReps == YES){
                NSString *repsString = [[NSNumber numberWithDouble: chainTemplate.repsArrays[chainIndex].numbers[roundIndex].value] stringValue];
                [self.repsButton setTitle: repsString
                                 forState: UIControlStateNormal];
            };
            
            if (chainTemplate.targetingRestTime == YES){
                double rest = chainTemplate.targetRestTimeArrays[chainIndex].numbers[roundIndex].value;
                NSString *restString =[[TJBStopwatch singleton] minutesAndSecondsStringFromNumberOfSeconds: (int)rest];
                [self.restButton setTitle: restString
                                 forState: UIControlStateNormal];
            };
        }
  
    }
}

#pragma mark - Button Actions

- (IBAction)didPressWeightButton:(id)sender
{
    if (_supportsUserInput == YES)
        [self.masterController didPressUserInputButtonWithType: WeightType
                                               chainNumber: self.chainNumber
                                               roundNumber: self.roundNumber
                                                    button: self.weightButton];
}

- (IBAction)didPressRepsButton:(id)sender
{
    if (_supportsUserInput == YES)
        [self.masterController didPressUserInputButtonWithType: RepsType
                                               chainNumber: self.chainNumber
                                               roundNumber: self.roundNumber
                                                    button: self.repsButton];
}

- (IBAction)didPressRestButton:(id)sender
{
    if (_supportsUserInput == YES)
        [self.masterController didPressUserInputButtonWithType: RestType
                                               chainNumber: self.chainNumber
                                               roundNumber: self.roundNumber
                                                    button: self.restButton];
}

#pragma mark - <RowComponentActiveUpdatingProtocol>
- (void)updateLabelWithNumberType:(NumberType)numberType value:(double)value{
    NSString *string = [[NSNumber numberWithDouble: value] stringValue];
    NSString *restString = [[TJBStopwatch singleton] minutesAndSecondsStringFromNumberOfSeconds: value];
    
    switch (numberType) {
        case WeightType:
            [self.weightButton setTitle: string
                               forState: UIControlStateNormal];
            break;
        case RepsType:
            [self.repsButton setTitle: string
                             forState: UIControlStateNormal];
            break;
        case RestType:
            [self.restButton setTitle: restString
                             forState: UIControlStateNormal];
            break;
            
        default:
            break;
    }
}

@end












