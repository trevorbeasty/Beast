//
//  TJBCircuitDesignVC.m
//  Beast
//
//  Created by Trevor Beasty on 12/12/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TJBCircuitDesignVC.h"

#import "TJBCircuitTemplateGeneratorVC.h"

#import "TJBAestheticsController.h"

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

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;

- (IBAction)didPressLaunchTemplate:(id)sender;

// labels
@property (weak, nonatomic) IBOutlet UIButton *launchTemplateButton;
@property (weak, nonatomic) IBOutlet UILabel *circuitNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfExercisesLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfRoundsLabel;
@property (weak, nonatomic) IBOutlet UILabel *targetingWeightLabel;
@property (weak, nonatomic) IBOutlet UILabel *targetingRepsLabel;
@property (weak, nonatomic) IBOutlet UILabel *targetingRestLabel;
@property (weak, nonatomic) IBOutlet UILabel *targetsVaryByRoundLabel;

// dynamic labels
@property (weak, nonatomic) IBOutlet UILabel *counterNumberOfExercises;
@property (weak, nonatomic) IBOutlet UILabel *counterNumberOfRounds;

// backdrop view
@property (weak, nonatomic) IBOutlet UIView *backdropView;

@end

@implementation TJBCircuitDesignVC

#pragma mark - Instantiation

- (void)viewDidLoad{
    [self configureBackropView];
    [self configureView];
    [self configureNavigationBar];
    [self viewAesthetics];
    [self addBackgroundImage];
}

- (void)configureBackropView{
    [self.view sendSubviewToBack: self.backdropView];
    
    CALayer *layer = self.backdropView.layer;
    layer.masksToBounds = YES;
    layer.cornerRadius = 8;
    layer.opacity = .65;
}

- (void)addBackgroundImage{
    [[TJBAestheticsController singleton] addFullScreenBackgroundViewWithImage: [UIImage imageNamed: @"weightRack"]
                                                                   toRootView: self.view
                                                                 imageOpacity: .35];
}

- (void)configureView{
    _numberOfExercises = 1.0;
    _numberOfRounds = 1.0;
    
    self.counterNumberOfExercises.text = [[NSNumber numberWithDouble: _numberOfExercises] stringValue];
    self.counterNumberOfRounds.text = [[NSNumber numberWithDouble: _numberOfRounds] stringValue];
    
    [self.numberOfExercisesStepper addTarget: self
                                      action: @selector(didChangeExerciseStepperValue)
                            forControlEvents: UIControlEventValueChanged];
    [self.numberOfRoundsStepper addTarget: self
                                   action: @selector(didChangeRoundsStepperValue)
                         forControlEvents: UIControlEventValueChanged];
}

- (void)configureNavigationBar{
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle: @"Circuit Design"];
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCancel
                                                                                   target: self
                                                                                   action: @selector(didPressCancel)];
    [navItem setLeftBarButtonItem: barButtonItem];
    [self.navBar setItems: @[navItem]];
}

- (void)viewAesthetics{
    CALayer *layer = self.nameTextField.layer;
    layer.masksToBounds = YES;
    layer.cornerRadius = 8;
    layer.borderWidth = 1;
    layer.borderColor = [[UIColor darkGrayColor] CGColor];
    
    NSArray *views = @[self.circuitNameLabel,
                       self.numberOfExercisesLabel,
                       self.numberOfRoundsLabel,
                       self.targetingWeightLabel,
                       self.targetingRepsLabel,
                       self.targetingRestLabel,
                       self.targetsVaryByRoundLabel];
    [TJBAestheticsController configureViewsWithType1Format: views
                                               withOpacity: .85];
    
    // button
    [[TJBAestheticsController singleton] configureButtonsInArray: @[self.launchTemplateButton]
                                                     withOpacity: .85];
}

#pragma mark - Stepper Methods

- (void)didChangeExerciseStepperValue{
    double number = self.numberOfExercisesStepper.value;
    
    _numberOfExercises = number;
    self.counterNumberOfExercises.text = [[NSNumber numberWithDouble: number] stringValue];
}

- (void)didChangeRoundsStepperValue{
    double number = self.numberOfRoundsStepper.value;
    
    _numberOfRounds = number;
    self.counterNumberOfRounds.text = [[NSNumber numberWithDouble: number] stringValue];
}

#pragma mark - Button Actions

- (IBAction)didPressLaunchTemplate:(id)sender{
    if ([self.nameTextField.text isEqualToString: @""]){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"Invalid Title"
                                                                       message: @"Please enter a title before proceeding"
                                                                preferredStyle: UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle: @"Continue"
                                                         style: UIAlertActionStyleDefault
                                                       handler: nil];
        [alert addAction: action];
        [self presentViewController: alert
                           animated: YES
                         completion: nil];
        
    } else{
        TJBCircuitTemplateGeneratorVC *vc = [[TJBCircuitTemplateGeneratorVC alloc] initWithTargetingWeight: [NSNumber numberWithLong: self.targetingWeightSC.selectedSegmentIndex]
                                                                                             targetingReps: [NSNumber numberWithLong: self.targetingRepsSC.selectedSegmentIndex]
                                                                                             targetingRest: [NSNumber numberWithLong: self.targetingRestSC.selectedSegmentIndex]
                                                                                        targetsVaryByRound: [NSNumber numberWithLong: self.targetsVaryByRoundSC.selectedSegmentIndex]
                                                                                         numberOfExercises: [NSNumber numberWithDouble: _numberOfExercises]
                                                                                            numberOfRounds: [NSNumber numberWithDouble: _numberOfRounds]
                                                                                                      name: self.nameTextField.text
                                                                                         supportsUserInput: YES];
        
        [self presentViewController: vc
                           animated: YES
                         completion: nil];
    }
    

}

- (void)didPressCancel{
    [self dismissViewControllerAnimated: NO
                             completion: nil];
}

@end



































