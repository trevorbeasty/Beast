//
//  TJBCircuitTemplateContainerVC.m
//  Beast
//
//  Created by Trevor Beasty on 1/10/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBCircuitTemplateContainerVC.h"

#import "TJBCircuitTemplateVC.h"

#import "TJBCircuitTemplateVCProtocol.h"

#import "TJBChainTemplate+CoreDataProperties.h"

// presented VC's

#import "TJBWorkoutNavigationHub.h"
#import "TJBActiveRoutineGuidanceVC.h"
#import "TJBCircuitReferenceContainerVC.h"

// aesthetics

#import "TJBAestheticsController.h"

// utilities

#import "TJBAssortedUtilities.h"

// core data

#import "CoreDataController.h"

@interface TJBCircuitTemplateContainerVC ()

{
    
    float _previousExercisesStepperValue;
    float _previousRoundsStepperValue;
    BOOL _advancedControlsHidden;
    
}

// IBOutlet


@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UILabel *mainTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *rightTitleButton;

@property (weak, nonatomic) IBOutlet UIView *titleBarContainer;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIView *leftControlsContainer;

@property (weak, nonatomic) IBOutlet UILabel *numberExercisesTitle;
@property (weak, nonatomic) IBOutlet UILabel *numberExercisesValue;
@property (weak, nonatomic) IBOutlet UILabel *numberRoundsTitle;
@property (weak, nonatomic) IBOutlet UILabel *numberRoundsValue;
@property (weak, nonatomic) IBOutlet UIStepper *numberExercisesStepper;
@property (weak, nonatomic) IBOutlet UIStepper *numberRoundsStepper;

@property (weak, nonatomic) IBOutlet UIButton *controlsArrow;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *controlsContainerBottomSpaceConstr;


// IBAction

- (IBAction)didPressBack:(id)sender;
- (IBAction)didPressAdd:(id)sender;
- (IBAction)didPressControlsArrow:(id)sender;

// core

@property (nonatomic, strong) TJBCircuitTemplateVC <TJBCircuitTemplateVCProtocol> *circuitTemplateVC;
@property (copy) TJBVoidCallback callback;

// pertinent chainTemplate

@property (nonatomic, strong) TJBChainTemplate *chainTemplate;

@end



#pragma mark - Constants

static int const _startingNumberExercises = 2;
static int const _startingNumberRounds = 3;

static NSString * const placeholderName = @"placeholderName";

static NSTimeInterval const bottomControlsAnimationTime = .2;
static CGFloat const bottomControlsSpaceValue = 8;



@implementation TJBCircuitTemplateContainerVC

#pragma mark - Instantiation

- (id)initWithCallback:(TJBVoidCallback)callback{
    
    self = [super init];
    
    [self createPlaceholderChainTemplate];
    
    self.callback = callback;
    
    // state
    
    _advancedControlsHidden = NO;
    
    return self;
    
}


#pragma mark - Init Helper Methods

- (void)createPlaceholderChainTemplate{
    
    TJBChainTemplate *chainTemplate = [[CoreDataController singleton] createAndSaveSkeletonChainTemplateWithNumberOfExercises: @(_startingNumberExercises)
                                                                                                               numberOfRounds: @(_startingNumberRounds)
                                                                                                                         name: placeholderName
                                                                                                            isTargetingWeight: YES
                                                                                                              isTargetingReps: YES
                                                                                                      isTargetingTrailingRest: YES];
    
    self.chainTemplate = chainTemplate;
    
}



#pragma mark - View Life Cycle

- (void)viewDidLoad{

    [self configureViewAesthetics];
    
    [self configureStartingContent];
    
    [self configureSteppers];

}

- (void)viewDidAppear:(BOOL)animated{
    

    
}

#pragma mark - View Helper Methods

- (void)configureSteppers{
    
    [self.numberExercisesStepper addTarget: self
                                    action: @selector(didChangeExerciseStepperValue)
                          forControlEvents: UIControlEventValueChanged];
    
    [self.numberRoundsStepper addTarget: self
                                 action: @selector(didChangeRoundStepperValue)
                       forControlEvents: UIControlEventValueChanged];
    
    NSArray *steppers = @[self.numberExercisesStepper, self.numberRoundsStepper];
    for (UIStepper *step in steppers){
        
        step.minimumValue = 1;
        step.maximumValue = 10;
        step.autorepeat = NO;
        step.stepValue = 1.0;
        step.continuous = YES;
        step.wraps = NO;
        
    }
    
    self.numberExercisesStepper.value = (float)_startingNumberExercises;
    self.numberRoundsStepper.value = (float)_startingNumberRounds;
    
}


- (void)configureViewAesthetics{
    
    // meta view
    
    self.view.backgroundColor = [UIColor clearColor];
    
    // title container
    
    self.titleBarContainer.backgroundColor = [UIColor darkGrayColor];
    
    // title bar items
    
    NSArray *titleButtons = @[self.backButton, self.rightTitleButton];
    for (UIButton *button in titleButtons){
        
        button.backgroundColor = [UIColor clearColor];
        
    }
    
    self.mainTitleLabel.backgroundColor = [UIColor clearColor];
    self.mainTitleLabel.textColor = [UIColor whiteColor];
    self.mainTitleLabel.font = [UIFont boldSystemFontOfSize: 20];
    
    // content container
    
    self.containerView.backgroundColor = [[TJBAestheticsController singleton] yellowNotebookColor];
    
    self.leftControlsContainer.backgroundColor = [UIColor grayColor];
    CALayer *ccLayer = self.leftControlsContainer.layer;
    ccLayer.borderWidth = 1.0;
    ccLayer.borderColor = [[TJBAestheticsController singleton] paleLightBlueColor].CGColor;
    ccLayer.masksToBounds = YES;
    ccLayer.cornerRadius = 16;
    // control labels and steppers
    
    NSArray *controlTitleLabels = @[self.numberExercisesTitle, self.numberRoundsTitle];
    for (UILabel *lab in controlTitleLabels){
        
        lab.backgroundColor = [UIColor clearColor];
        lab.font = [UIFont systemFontOfSize: 20];
        lab.textColor = [UIColor whiteColor];
        
    }
    
    NSArray *controlValueLabels = @[self.numberExercisesValue, self.numberRoundsValue];
    for (UILabel *lab in controlValueLabels){
        
        lab.backgroundColor = [UIColor clearColor];
        lab.font = [UIFont boldSystemFontOfSize: 25];
        lab.textColor = [UIColor whiteColor];
        
    }
    
    NSArray *steppers = @[self.numberExercisesStepper, self.numberRoundsStepper];
    for (UIStepper *step in steppers){
        
        step.tintColor = [[TJBAestheticsController singleton] paleLightBlueColor];
        
    }
    
    // controls arrow
    
    self.controlsArrow.backgroundColor = [UIColor grayColor];
    CALayer *controlArrowLayer = self.controlsArrow.layer;
    controlArrowLayer.masksToBounds = YES;
    controlArrowLayer.cornerRadius = 25;
    controlArrowLayer.borderWidth = 1;
    controlArrowLayer.borderColor = [[TJBAestheticsController singleton] paleLightBlueColor].CGColor;
    
}

- (void)configureStartingContent{
    
    // initial exercise and round values defined here
    
    NSNumber *startingNumberExercises = @(_startingNumberExercises);
    NSNumber *startingNumberRounds = @(_startingNumberRounds);
    
    self.numberExercisesValue.text = [startingNumberExercises stringValue];
    self.numberRoundsValue.text = [startingNumberRounds stringValue];
    
    _previousExercisesStepperValue = [startingNumberExercises floatValue];
    _previousRoundsStepperValue = [startingNumberRounds floatValue];
    
    // create the TJBCircuitTemplateVC
    
    TJBCircuitTemplateVC *ctVC = [[TJBCircuitTemplateVC alloc] initWithSkeletonChainTemplate: self.chainTemplate
                                                                   startingNumberOfExercises: startingNumberExercises
                                                                      startingNumberOfRounds: startingNumberRounds];
    
    self.circuitTemplateVC = ctVC;
    
    ctVC.view.frame = self.containerView.bounds;
    
    [self addChildViewController: ctVC];
    
    [self.containerView insertSubview: ctVC.view
                              atIndex: 0];
    
    [ctVC didMoveToParentViewController: self];
    
}

#pragma mark - Stepper Actions

- (void)didChangeExerciseStepperValue{
    
    // local label
    
    NSNumber *stepValue = @(self.numberExercisesStepper.value);
    self.numberExercisesValue.text = [stepValue stringValue];
    
    // TJBCircuitTemplateVCProtocol
    
    if ([stepValue floatValue] > _previousExercisesStepperValue){
        
        [[CoreDataController singleton] appendExerciseToChainTemplate: self.chainTemplate];
        
        [self.circuitTemplateVC didIncrementNumberOfExercisesInUpDirection: YES];
        
    } else{
        
        [[CoreDataController singleton] deleteLastExercisefromChainTemplate: self.chainTemplate];
        
        [self.circuitTemplateVC didIncrementNumberOfExercisesInUpDirection: NO];
        
    }
    
    [self.view updateConstraintsIfNeeded]; // needs to be called to update views when existing constraints have been changed
    [self.view layoutIfNeeded];
    
    _previousExercisesStepperValue = [stepValue floatValue];
    
}

- (void)didChangeRoundStepperValue{
    
    // local label
    
    NSNumber *stepValue = @(self.numberRoundsStepper.value);
    self.numberRoundsValue.text = [stepValue stringValue];
    
    // TJBCircuitTemplateVCProtocol
    
    if ([stepValue floatValue] > _previousRoundsStepperValue){
        
        [[CoreDataController singleton] appendRoundToChainTemplate: self.chainTemplate];
        
        [self.circuitTemplateVC didIncrementNumberOfRoundsInUpDirection: YES];
        
    } else{
        
        [[CoreDataController singleton] deleteLastRoundInChainTemplate: self.chainTemplate];
        
        [self.circuitTemplateVC didIncrementNumberOfRoundsInUpDirection: NO];
        
    }
    
    [self.view updateConstraintsIfNeeded]; // needs to be called to update views when existing constraints have been changed
    [self.view layoutIfNeeded];
    
    _previousRoundsStepperValue = [stepValue floatValue];
    
}

#pragma mark - Button Actions

- (void)alertUserInputIncomplete_nameIsBlank:(BOOL)nameIsBlank requisiteUserInputNotCollected:(BOOL)requisiteUserInputNotCollected{
    
    NSString *message;
    
    if (nameIsBlank && requisiteUserInputNotCollected){
        message = @"Please enter a routine name and make all active selections";
    } else if (nameIsBlank){
        message = @"Please enter a routine name";
    } else{
        message = @"Please make all active selections";
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"Routine Design Incomplete"
                                                                   message: message
                                                            preferredStyle: UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle: @"Continue"
                                                     style: UIAlertActionStyleDefault
                                                   handler: nil];
    [alert addAction: action];
    [self presentViewController: alert
                       animated: YES
                     completion: nil];
    
}



- (IBAction)didPressBack:(id)sender{
    
    [self.circuitTemplateVC dismissKeyboard];
    
    // alert controller
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"Proceed with Delete?"
                                                                   message: @"All entered information will be lost"
                                                            preferredStyle: UIAlertControllerStyleAlert];
    
    __weak TJBCircuitTemplateContainerVC *weakSelf = self;
    
    // confirm action
    
    void (^confirmAction)(UIAlertAction *) = ^(UIAlertAction *action){
        
        [[CoreDataController singleton] deleteChainTemplate: self.chainTemplate];
        
        [weakSelf dismissViewControllerAnimated: YES
                                 completion: nil];
        
    };
    
    UIAlertAction *confirm = [UIAlertAction actionWithTitle: @"Delete"
                                                      style: UIAlertActionStyleDestructive
                                                    handler: confirmAction];
    
    // cancel action
    
    void (^cancelAction)(UIAlertAction *) = ^(UIAlertAction *action){
        
        return;
        
    };
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle: @"Cancel"
                                                     style: UIAlertActionStyleCancel
                                                   handler: cancelAction];
    
    [alert addAction: cancel];
    [alert addAction: confirm];
    
    [self presentViewController: alert
                       animated: YES
                     completion: nil];
    
}

- (IBAction)didPressAdd:(id)sender{
    
    [self.circuitTemplateVC dismissKeyboard];
    
    BOOL requisiteUserInputCollected = [self.circuitTemplateVC allUserInputCollected];
    BOOL routineNameBlank = [self.circuitTemplateVC nameIsBlank];

    if (requisiteUserInputCollected && !routineNameBlank){
        
        [[CoreDataController singleton] saveContext];
        
        // alert
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        df.dateFormat = @"MMMM yyyy";
        NSString *thisMonth = [df stringFromDate: [NSDate date]];
        
        NSString *message = [NSString stringWithFormat: @"You can now find your routine in 'Routines by Date Created' for %@", thisMonth];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"Routine Successfully Saved"
                                                                       message: message
                                                                preferredStyle: UIAlertControllerStyleAlert];
        
        __weak TJBCircuitTemplateContainerVC *weakSelf = self;
        
        void (^alertBlock)(UIAlertAction *) = ^(UIAlertAction *action){
            
            weakSelf.callback();
            
        };
        
        UIAlertAction *action = [UIAlertAction actionWithTitle: @"Continue"
                                                         style: UIAlertActionStyleDefault
                                                       handler: alertBlock];
        [alert addAction: action];
        
        [self presentViewController: alert
                           animated: YES
                         completion: nil];
        
    } else{
        
        [self alertUserInputIncomplete_nameIsBlank: routineNameBlank
                    requisiteUserInputNotCollected: !requisiteUserInputCollected];
        
    }
}

#pragma mark - Advanced Controls Animation



- (IBAction)didPressControlsArrow:(id)sender{
    
    if (_advancedControlsHidden == NO){
        
        [self animateControlsContainerOffscreen];
        
        [self.controlsArrow setImage: [UIImage imageNamed: @"upArrowBlue30PDF"]
                            forState: UIControlStateNormal];
        
        _advancedControlsHidden = YES;
        
    } else if (_advancedControlsHidden == YES){
        
        [self animateControlsContainerOnscreen];
        
        [self.controlsArrow setImage: [UIImage imageNamed: @"downArrowBlue30PDF"]
                            forState: UIControlStateNormal];
        
        _advancedControlsHidden = NO;
        
    }
    
}

- (void)animateControlsContainerOffscreen{
    
    [UIView animateWithDuration: bottomControlsAnimationTime
                     animations: ^{
                         
                         self.controlsArrow.enabled = NO;
                         
                         CGFloat height = self.containerView.frame.size.height - self.leftControlsContainer.frame.origin.y;
                         
                         self.leftControlsContainer.frame = [TJBAssortedUtilities rectByTranslatingRect: self.leftControlsContainer.frame
                                                                                                originX: 0
                                                                                                originY: height];
                         
                         self.controlsArrow.frame = [TJBAssortedUtilities rectByTranslatingRect: self.controlsArrow.frame
                                                                                        originX: 0
                                                                                        originY: height];
                         
                     }
                     completion: ^(BOOL finished){
                         
                         self.controlsArrow.enabled = YES;
                         
                         CGFloat height = self.leftControlsContainer.frame.size.height;
                         
                         self.controlsContainerBottomSpaceConstr.constant = -1 * height;
                         
                     }];
    
}


- (void)animateControlsContainerOnscreen{
    
    
    [UIView animateWithDuration: bottomControlsAnimationTime
                     animations: ^{
                         
                         self.controlsArrow.enabled = NO;
                         
                         CGFloat height = (self.leftControlsContainer.frame.size.height + bottomControlsSpaceValue) * -1;
                         
                         self.leftControlsContainer.frame = [TJBAssortedUtilities rectByTranslatingRect: self.leftControlsContainer.frame
                                                                                                originX: 0
                                                                                                originY: height];
                         
                         self.controlsArrow.frame = [TJBAssortedUtilities rectByTranslatingRect: self.controlsArrow.frame
                                                                                        originX: 0
                                                                                        originY: height];
                         
                     }
                     completion: ^(BOOL finished){
                         
                         self.controlsArrow.enabled = YES;
                         
                         self.controlsContainerBottomSpaceConstr.constant = bottomControlsSpaceValue;
                         
                     }];
    
}

#pragma mark - <UIViewControllerRestoration>





@end




















































