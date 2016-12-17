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

@property (weak, nonatomic) IBOutlet UIButton *weightButton;
@property (weak, nonatomic) IBOutlet UIButton *repsButton;
@property (weak, nonatomic) IBOutlet UIButton *restButton;

- (IBAction)didPressWeightButton:(id)sender;
- (IBAction)didPressRepsButton:(id)sender;
- (IBAction)didPressRestButton:(id)sender;



@end

@implementation CircuitDesignRowComponent

#pragma mark - Instantiation

- (void)viewDidLoad
{
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

- (instancetype)initWithTargetingWeight:(NSNumber *)targetingWeight targetingReps:(NSNumber *)targetingReps targetingRest:(NSNumber *)targetingRest targetsVaryByRound:(NSNumber *)targetsVaryByRound roundNumber:(NSNumber *)roundNumber masterController:(TJBCircuitTemplateGeneratorVC<TJBNumberSelectionDelegate> *)masterController chainNumber:(NSNumber *)chainNumber
{
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

#pragma mark - Button Actions

- (IBAction)didPressWeightButton:(id)sender
{
    [self.masterController didPressUserInputButtonWithType: nil
                                               chainNumber: nil
                                               roundNumber: nil
                                                    button: nil];
}

- (IBAction)didPressRepsButton:(id)sender
{
    
}

- (IBAction)didPressRestButton:(id)sender
{
    
}



@end












