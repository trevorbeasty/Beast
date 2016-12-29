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

@interface CircuitDesignRowComponent ()
{
    // core
    BOOL _supportsUserInput;
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

@property (nonatomic, strong) TJBCircuitTemplateGeneratorVC *masterController;

@end

@implementation CircuitDesignRowComponent

#pragma mark - Instantiation

- (void)viewDidLoad
{
    if (_supportsUserInput == NO){
        int chainIndex = [self.chainNumber intValue] - 1;
        int roundIndex = [self.roundNumber intValue] - 1;
        
        NSString *weightString = [[NSNumber numberWithDouble: self.chainTemplate.weightArrays[chainIndex].numbers[roundIndex].value] stringValue];
        NSString *repsString = [[NSNumber numberWithDouble: self.chainTemplate.repsArrays[chainIndex].numbers[roundIndex].value] stringValue];
        double rest = self.chainTemplate.targetRestTimeArrays[chainIndex].numbers[roundIndex].value;
        NSString *restString =[[TJBStopwatch singleton] minutesAndSecondsStringFromNumberOfSeconds: (int)rest];

        [self.weightButton setTitle: weightString
                           forState: UIControlStateNormal];
        [self.repsButton setTitle: repsString
                         forState: UIControlStateNormal];
        [self.restButton setTitle: restString
                         forState: UIControlStateNormal];
    }
    
    if ([self.targetsVaryByRound intValue] == 0)
    {
        self.roundLabel.text = @"All Rounds";
    }
    else
    {
        self.roundLabel.text = [NSString stringWithFormat: @"Round %d", [self.roundNumber intValue]];
    }
    
    if ([self.targetingWeight intValue] == 0)
    {
        self.weightButton.enabled = NO;
        [self.weightButton setTitle: @""
                           forState: UIControlStateDisabled];
    }
    
    if ([self.targetingReps intValue] == 0)
    {
        self.repsButton.enabled = NO;
        [self.repsButton setTitle: @""
                           forState: UIControlStateDisabled];
    }
    
    if ([self.targetingRest intValue] == 0)
    {
        self.restButton.enabled = NO;
        [self.restButton setTitle: @""
                           forState: UIControlStateDisabled];
    }
}

- (instancetype)initWithTargetingWeight:(NSNumber *)targetingWeight targetingReps:(NSNumber *)targetingReps targetingRest:(NSNumber *)targetingRest targetsVaryByRound:(NSNumber *)targetsVaryByRound roundNumber:(NSNumber *)roundNumber masterController:(TJBCircuitTemplateGeneratorVC *)masterController chainNumber:(NSNumber *)chainNumber supportsUserInput:(BOOL)supportsUserInput chainTemplate:(TJBChainTemplate *)chainTemplate{
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
    
    return self;
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



@end












