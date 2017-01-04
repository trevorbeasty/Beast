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

@interface TJBCircuitDesignVC () <UIViewControllerRestoration>

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

// container views
@property (weak, nonatomic) IBOutlet UIView *backdropView;
@property (weak, nonatomic) IBOutlet UIView *metaContainerView;

@end

@implementation TJBCircuitDesignVC

#pragma mark - Instantiation

- (instancetype)init{
    self = [super init];
    
    self.restorationIdentifier = @"TJBCircuitDesignVC";
    self.restorationClass = [TJBCircuitDesignVC class];
    
    return self;
}

#pragma mark - View Life Cycle

- (void)viewDidLoad{
    [self configureViewDataAndFunctionality];
    [self configureNavigationBar];
    [self viewAesthetics];
    [self addBackgroundImage];
}

- (void)addBackgroundImage{
    [[TJBAestheticsController singleton] addFullScreenBackgroundViewWithImage: [UIImage imageNamed: @"weightRack"]
                                                                   toRootView: self.view
                                                                 imageOpacity: .35];
}

- (void)configureViewDataAndFunctionality{
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
    // meta container view
    self.metaContainerView.backgroundColor = [UIColor whiteColor];
    CALayer *layer;
    layer = self.metaContainerView.layer;
    layer.masksToBounds = YES;
    layer.cornerRadius = 8.0;
    layer.opacity = .85;
    
    // text field
    [self.circuitNameLabel setTextColor: [UIColor whiteColor]];
    self.circuitNameLabel.backgroundColor = [UIColor darkGrayColor];
    
    layer = self.nameTextField.layer;
    layer.masksToBounds = YES;
    layer.cornerRadius = 8;
    layer.borderWidth = 1;
    layer.borderColor = [[UIColor darkGrayColor] CGColor];
    
    // labels
    NSArray *labels = @[self.numberOfExercisesLabel,
                       self.numberOfRoundsLabel,
                       self.targetingWeightLabel,
                       self.targetingRepsLabel,
                       self.targetingRestLabel,
                       self.targetsVaryByRoundLabel];
    for (UILabel *label in labels){
        label.backgroundColor = [[TJBAestheticsController singleton] labelType1Color];
        label.layer.opacity = .85;
    }
    
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

#pragma mark - <UIViewControllerRestoration>

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder{
    return [[TJBCircuitDesignVC alloc] init];
}

@end



































