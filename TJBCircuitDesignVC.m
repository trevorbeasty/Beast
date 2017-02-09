//
//  TJBCircuitDesignVC.m
//  Beast
//
//  Created by Trevor Beasty on 12/12/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TJBCircuitDesignVC.h"

// circuit template

#import "TJBCircuitTemplateContainerVC.h"

// aesthetics

#import "TJBAestheticsController.h"

@interface TJBCircuitDesignVC () <UIViewControllerRestoration, UITextFieldDelegate>

{
    int _numberOfExercises;
    int _numberOfRounds;
}

//// IBOutlet

@property (weak, nonatomic) IBOutlet UISegmentedControl *targetingWeightSC;
@property (weak, nonatomic) IBOutlet UISegmentedControl *targetingRepsSC;
@property (weak, nonatomic) IBOutlet UISegmentedControl *targetingRestSC;
@property (weak, nonatomic) IBOutlet UISegmentedControl *targetsVaryByRoundSC;

@property (weak, nonatomic) IBOutlet UIStepper *numberOfExercisesStepper;
@property (weak, nonatomic) IBOutlet UIStepper *numberOfRoundsStepper;

@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;

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

// IBAction

- (IBAction)didPressLaunchTemplate:(id)sender;

// for restoration

@property (nonatomic, strong) NSNumber *wasRestored;

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
    
    [self addTapRecognizerForKeyboardManagement];
    
}

- (void)addTapRecognizerForKeyboardManagement{
    
    //// self explanatory
    
    // tap GR
    
    UITapGestureRecognizer *singleTapGR = [[UITapGestureRecognizer alloc] initWithTarget: self
                                                                                  action: @selector(didSingleTap)];
    
    singleTapGR.numberOfTapsRequired = 1;
    singleTapGR.cancelsTouchesInView = NO;
    singleTapGR.delaysTouchesBegan = NO;
    singleTapGR.delaysTouchesEnded = NO;
    
    [self.view addGestureRecognizer: singleTapGR];
    
}


- (void)configureViewDataAndFunctionality{
    
    BOOL selfWasRestored = [self.wasRestored boolValue] == YES;
    
    if (!selfWasRestored){
        _numberOfExercises = 1.0;
        _numberOfRounds = 1.0;
        
        self.counterNumberOfExercises.text = [[NSNumber numberWithDouble: _numberOfExercises] stringValue];
        self.counterNumberOfRounds.text = [[NSNumber numberWithDouble: _numberOfRounds] stringValue];
    }

    [self.numberOfExercisesStepper addTarget: self
                                      action: @selector(didChangeExerciseStepperValue)
                            forControlEvents: UIControlEventValueChanged];
    
    [self.numberOfRoundsStepper addTarget: self
                                   action: @selector(didChangeRoundsStepperValue)
                         forControlEvents: UIControlEventValueChanged];
}

- (void)configureNavigationBar{
    
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle: @"Scheme Design"];
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCancel
                                                                                   target: self
                                                                                   action: @selector(didPressCancel)];
    
    [navItem setLeftBarButtonItem: barButtonItem];
    
    [self.navBar setItems: @[navItem]];
    
    [self.navBar setTitleTextAttributes: @{NSFontAttributeName: [UIFont boldSystemFontOfSize: 20.0]}];
    
}

- (void)configureShadowView{
    
    [self.view layoutIfNeeded];
    
    UIView *shadowView = [[UIView alloc] initWithFrame: self.metaContainerView.frame];
    [self.view insertSubview: shadowView
                belowSubview: self.metaContainerView];
    
    shadowView.backgroundColor = [UIColor whiteColor];
    shadowView.clipsToBounds = NO;
    
    CALayer *shadowLayer = shadowView.layer;
    shadowLayer.masksToBounds = NO;
    shadowLayer.shadowColor = [UIColor whiteColor].CGColor;
    shadowLayer.shadowOffset = CGSizeMake(0.0, 3.0);
    shadowLayer.shadowOpacity = 1.0;
    shadowLayer.shadowRadius = 3.0;
    
}

- (void)viewAesthetics{
    
    [self configureShadowView];
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    // control container view
    
    self.metaContainerView.backgroundColor = [UIColor whiteColor];
    
//    CALayer *containerLayer;
//    containerLayer = self.metaContainerView.layer;
//    containerLayer.masksToBounds = YES;
//    containerLayer.cornerRadius = 4.0;
    
    // text field
    
    [self.circuitNameLabel setTextColor: [UIColor darkGrayColor]];
    self.circuitNameLabel.backgroundColor = [UIColor whiteColor];
    
    CALayer *tfLayer = self.circuitNameLabel.layer;
    tfLayer = self.nameTextField.layer;
    tfLayer.masksToBounds = YES;
    tfLayer.cornerRadius = 8;
    tfLayer.borderWidth = 1;
    tfLayer.borderColor = [[UIColor darkGrayColor] CGColor];
    
    self.nameTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    
    // SC's and steppers
    
    NSArray *steppers = @[self.numberOfExercisesStepper,
                          self.numberOfRoundsStepper];
    for (UIStepper *s in steppers){
        
        s.tintColor = [[TJBAestheticsController singleton] blueButtonColor];
        
    }
    
    NSArray *segmentedControls = @[self.targetingWeightSC,
                                   self.targetingRepsSC,
                                   self.targetingRestSC,
                                   self.targetsVaryByRoundSC];
    for (UISegmentedControl *sc in segmentedControls){
        
        sc.tintColor = [[TJBAestheticsController singleton] blueButtonColor];
        
    }
    
    // labels
    
    NSArray *labels = @[self.numberOfExercisesLabel,
                       self.numberOfRoundsLabel,
                       self.targetingWeightLabel,
                       self.targetingRepsLabel,
                       self.targetingRestLabel,
                       self.targetsVaryByRoundLabel];
    
    for (UILabel *label in labels){
        
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize: 20.0];
        label.textColor = [UIColor whiteColor];
        
    }
    
    // button
    
    self.launchTemplateButton.backgroundColor = [[TJBAestheticsController singleton] blueButtonColor];
    
    [self.launchTemplateButton setTitleColor: [UIColor whiteColor]
                                    forState: UIControlStateNormal];
    
    self.launchTemplateButton.titleLabel.font = [UIFont boldSystemFontOfSize: 20.0];
    
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
        
        NSNumber *targetingWeight = [NSNumber numberWithLong: self.targetingWeightSC.selectedSegmentIndex];
        NSNumber *targetingReps = [NSNumber numberWithLong: self.targetingRepsSC.selectedSegmentIndex];
        NSNumber *targetingRest = [NSNumber numberWithLong: self.targetingRestSC.selectedSegmentIndex];
        NSNumber *targetsVaryByRound = [NSNumber numberWithLong: self.targetsVaryByRoundSC.selectedSegmentIndex];
        NSNumber *numberOfExercises = [NSNumber numberWithInt: _numberOfExercises];
        NSNumber *numberOfRounds = [NSNumber numberWithInt: _numberOfRounds];
        
        NSLog(@"exercises: %@\nrounds: %@",
              numberOfExercises,
              numberOfRounds);
        
        TJBCircuitTemplateContainerVC *vc = [[TJBCircuitTemplateContainerVC alloc] initWithTargetingWeight: targetingWeight
                                                                                             targetingReps: targetingReps
                                                                                             targetingRest: targetingRest
                                                                                        targetsVaryByRound: targetsVaryByRound
                                                                                         numberOfExercises: numberOfExercises
                                                                                            numberOfRounds: numberOfRounds
                                                                                                      name: self.nameTextField.text];
        
        
        
        [self presentViewController: vc
                           animated: YES
                         completion: nil];
    }
    

}

- (void)didPressCancel{
    [self dismissViewControllerAnimated: NO
                             completion: nil];
}

#pragma mark - Gesture Recognizer

- (void)didSingleTap{
    
    //// because this gesture does not register if the touch is in the keyboard or text field, simply have to check if the keyboard is showing, and dismiss it if so
    
    BOOL keyboardIsShowing = [self.nameTextField isFirstResponder];
    
    if (keyboardIsShowing){
        
        [self.nameTextField resignFirstResponder];
        
    }
    
}

#pragma mark - <UITextFieldDelegate>

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [self.nameTextField resignFirstResponder];
    
    return YES;
    
}

#pragma mark - <UIViewControllerRestoration>

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder{
    
    TJBCircuitDesignVC *vc = [[TJBCircuitDesignVC alloc] init];
    vc.wasRestored = [NSNumber numberWithBool: YES];
    return vc;
    
}

// for preserving state

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder{
    
    [super encodeRestorableStateWithCoder: coder];
    
    [coder encodeInt: _numberOfExercises
              forKey: @"numberOfExercises"];
    [coder encodeInt: _numberOfRounds
              forKey: @"numberOfRounds"];
    [coder encodeInteger: self.targetingWeightSC.selectedSegmentIndex
              forKey: @"targetingWeight"];
    [coder encodeInteger: self.targetingRepsSC.selectedSegmentIndex
                  forKey: @"targetingReps"];
    [coder encodeInteger: self.targetingRestSC.selectedSegmentIndex
                  forKey: @"targetingRest"];
    [coder encodeInteger: self.targetsVaryByRoundSC.selectedSegmentIndex
                  forKey: @"targetsVaryByRound"];
    
    [coder encodeObject: self.nameTextField.text
                 forKey: @"circuitName"];
    
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder{
    
    [super decodeRestorableStateWithCoder: coder];
    
    _numberOfExercises = [coder decodeIntForKey: @"numberOfExercises"];
    self.counterNumberOfExercises.text = [[NSNumber numberWithInt: _numberOfExercises] stringValue];
    self.numberOfExercisesStepper.value = _numberOfExercises;
    
    _numberOfRounds = [coder decodeIntForKey: @"numberOfRounds"];
    self.counterNumberOfRounds.text = [[NSNumber numberWithInt: _numberOfRounds] stringValue];
    self.numberOfRoundsStepper.value = _numberOfRounds;
    
    self.targetingWeightSC.selectedSegmentIndex = [coder decodeIntegerForKey: @"targetingWeight"];
    self.targetingRepsSC.selectedSegmentIndex = [coder decodeIntegerForKey: @"targetingReps"];
    self.targetingRestSC.selectedSegmentIndex = [coder decodeIntegerForKey: @"targetingRest"];
    self.targetsVaryByRoundSC.selectedSegmentIndex = [coder decodeIntegerForKey: @"targetsVaryByRound"];
    
    self.nameTextField.text = [coder decodeObjectForKey: @"circuitName"];
    
}

@end



































