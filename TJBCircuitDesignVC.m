//
//  TJBCircuitDesignVC.m
//  Beast
//
//  Created by Trevor Beasty on 12/12/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import "TJBCircuitDesignVC.h"

@interface TJBCircuitDesignVC ()

{
    double _numberOfExercises;
    double _numberOfRounds;
}

@property (weak, nonatomic) IBOutlet UISegmentedControl *targetingWeightSC;
@property (weak, nonatomic) IBOutlet UISegmentedControl *targetingRepsSC;
@property (weak, nonatomic) IBOutlet UISegmentedControl *targetingRestSC;
@property (weak, nonatomic) IBOutlet UISegmentedControl *targetsVaryByRoundSC;

@property (weak, nonatomic) IBOutlet UIStepper *numberOfExercisesStepper;
@property (weak, nonatomic) IBOutlet UIStepper *numberOfRoundsStepper;

@property (weak, nonatomic) IBOutlet UILabel *numberOfExercisesLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfRoundsLabel;

- (IBAction)didPressLaunchTemplate:(id)sender;

@end

@implementation TJBCircuitDesignVC

#pragma mark - Instantiation

- (void)viewDidLoad
{
    // steppers
    
    _numberOfExercises = 1.0;
    _numberOfRounds = 1.0;
    
    self.numberOfExercisesLabel.text = [[NSNumber numberWithDouble: _numberOfExercises] stringValue];
    self.numberOfRoundsLabel.text = [[NSNumber numberWithDouble: _numberOfRounds] stringValue];
    
    [self.numberOfExercisesStepper addTarget: self
                                      action: @selector(didChangeExerciseStepperValue)
                            forControlEvents: UIControlEventValueChanged];
    [self.numberOfRoundsStepper addTarget: self
                                   action: @selector(didChangeRoundsStepperValue)
                         forControlEvents: UIControlEventValueChanged];
}

#pragma mark - Stepper Methods

- (void)didChangeExerciseStepperValue
{
    double number = self.numberOfExercisesStepper.value;
    
    _numberOfExercises = number;
    self.numberOfExercisesLabel.text = [[NSNumber numberWithDouble: number] stringValue];
}

- (void)didChangeRoundsStepperValue
{
    double number = self.numberOfRoundsStepper.value;
    
    _numberOfRounds = number;
    self.numberOfRoundsLabel.text = [[NSNumber numberWithDouble: number] stringValue];
}

#pragma mark - Button Actions

- (IBAction)didPressLaunchTemplate:(id)sender
{
    
}

@end
