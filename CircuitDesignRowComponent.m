//
//  CircuitDesignRowComponent.m
//  Beast
//
//  Created by Trevor Beasty on 12/15/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import "CircuitDesignRowComponent.h"

// will need to delete this import statement and create delegate protocol once the delegate header begins working
// for now, will import master controller and define methods in its header

#import "TJBCircuitTemplateGeneratorVC.h"

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

@property (nonatomic, strong) TJBCircuitTemplateGeneratorVC *masterController;

@end

@implementation CircuitDesignRowComponent

#pragma mark - Instantiation

- (void)viewDidLoad
{
//    if (_supportsUserInput == NO){
//        self.weightButton.enabled = NO;
//        self.repsButton.enabled = NO;
//        self.restButton.enabled = NO;
//    }
    
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

- (instancetype)initWithTargetingWeight:(NSNumber *)targetingWeight targetingReps:(NSNumber *)targetingReps targetingRest:(NSNumber *)targetingRest targetsVaryByRound:(NSNumber *)targetsVaryByRound roundNumber:(NSNumber *)roundNumber masterController:(TJBCircuitTemplateGeneratorVC *)masterController chainNumber:(NSNumber *)chainNumber supportsUserInput:(BOOL)supportsUserInput{
    self = [super init];
    
    self.targetingWeight = targetingWeight;
    self.targetingReps = targetingReps;
    self.targetingRest = targetingRest;
    self.targetsVaryByRound = targetsVaryByRound;
    self.roundNumber = roundNumber;
    self.masterController = masterController;
    self.chainNumber = chainNumber;
    _supportsUserInput = supportsUserInput;
    
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












