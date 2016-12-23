//
//  TJBCircuitDesignVC.m
//  Beast
//
//  Created by Trevor Beasty on 12/12/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import "TJBCircuitDesignVC.h"

#import "TJBCircuitTemplateGeneratorVC.h"

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

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (nonatomic, strong) UINavigationItem *navItem;

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
    
    // navigation bar
    
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle: @"Circuit Template Configuration"];
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle: @"Home"
                                                                      style: UIBarButtonItemStyleDone
                                                                     target: self
                                                                     action: @selector(didPressHome)];
    
    [navItem setLeftBarButtonItem: barButtonItem];
    
    [self.navBar setItems: @[navItem]];
    
    // background view
    
    [self addBackgroundView];
}

- (void)addBackgroundView
{
    UIImage *image = [UIImage imageNamed: @"coolRandom"];
    UIView *imageView = [[UIImageView alloc] initWithImage: image];
    [self.view addSubview: imageView];
    [self.view sendSubviewToBack: imageView];
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
    TJBCircuitTemplateGeneratorVC *vc = [[TJBCircuitTemplateGeneratorVC alloc] initWithTargetingWeight: [NSNumber numberWithLong: self.targetingWeightSC.selectedSegmentIndex]
                                                                                         targetingReps: [NSNumber numberWithLong: self.targetingRepsSC.selectedSegmentIndex]
                                                                                         targetingRest: [NSNumber numberWithLong: self.targetingRestSC.selectedSegmentIndex]
                                                                                    targetsVaryByRound: [NSNumber numberWithLong: self.targetsVaryByRoundSC.selectedSegmentIndex]
                                                                                     numberOfExercises: [NSNumber numberWithDouble: _numberOfExercises]
                                                                                        numberOfRounds: [NSNumber numberWithDouble: _numberOfRounds]
                                                                                                  name: self.nameTextField.text];
    
    [self presentViewController: vc
                       animated: YES
                     completion: nil];
}

- (void)didPressHome
{
    [self dismissViewControllerAnimated: NO
                             completion: nil];
}

@end



































