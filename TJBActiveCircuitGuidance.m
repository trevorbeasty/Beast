//
//  TJBActiveCircuitGuidance.m
//  Beast
//
//  Created by Trevor Beasty on 12/24/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import "TJBActiveCircuitGuidance.h"

#import "CoreDataController.h"

#import "TJBWeightArray+CoreDataProperties.h"
#import "TJBRepsArray+CoreDataProperties.h"

#import "TJBTargetRestTimeArray+CoreDataProperties.h"
#import "TJBNumberArray+CoreDataProperties.h"
#import "TJBNumberTypeArrayComp+CoreDataProperties.h"

#import "TJBStopwatch.h"

#import "TJBInSetVC.h"

#import "TJBNumberSelectionVC.h"

#import "TJBAestheticsController.h"

// Utility

#import "TJBAssortedUtilities.h"

// delegate

#import "TJBCircuitActiveUpdatingVC.h"




@interface TJBActiveCircuitGuidance () <UIViewControllerRestoration>

// active IV's

@property NSNumber *activeExerciseIndex;
@property NSNumber *activeRoundIndex;

@property NSNumber *previousExerciseIndex;
@property NSNumber *previousRoundIndex;
    
@property NSNumber *activeTargetWeight;
@property NSNumber *activeTargetReps;
@property NSNumber *activeTargetRestTime;
    
// user selection progression

@property NSNumber *setCompletedButtonPressed;
@property NSNumber *restLabelAddedAsStopwatchObserver;


// derived IV's

@property (nonatomic, strong) NSNumber *numberOfExercises;
@property (nonatomic, strong) NSNumber *numberOfRounds;

// IBAction

- (IBAction)didPressBeginSet;

// IBOutlet

@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (weak, nonatomic) IBOutlet UILabel *weightColumnLabel;
@property (weak, nonatomic) IBOutlet UILabel *repsColumnLabel;
@property (weak, nonatomic) IBOutlet UILabel *exerciseColumnLabel;
@property (weak, nonatomic) IBOutlet UILabel *roundColumnLabel;

@property (weak, nonatomic) IBOutlet UILabel *exerciseLabel;
@property (weak, nonatomic) IBOutlet UILabel *weightLabel;
@property (weak, nonatomic) IBOutlet UILabel *repsLabel;
@property (weak, nonatomic) IBOutlet UILabel *restLabel;

@property (weak, nonatomic) IBOutlet UIButton *beginSetButton;

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;

// user selections

@property (nonatomic, strong) NSNumber *selectedTimeDelay;
@property (nonatomic, strong) NSDate *impliedBeginDate;
@property (nonatomic, strong) NSNumber *selectedTimeLag;
@property (nonatomic, strong) NSDate *impliedEndDate;
@property (nonatomic, strong) NSNumber *selectedWeight;
@property (nonatomic, strong) NSNumber *selectedReps;

// core data

@property (nonatomic, strong) TJBChainTemplate *chainTemplate;

@property (nonatomic, strong) TJBRealizedChain *realizedChain;

// delegate

// timer

@property (nonatomic, strong) NSDate *lastPrimaryTimerUpdatedDate;
@property (nonatomic, strong) NSDate *lastSecondaryTimerUpdateDate;


// state restoration

@property (copy) void (^userInputRestorationBlock)(void);
@property (nonatomic, strong) NSNumber *secondaryTimerFromStateRestoration;

@end





static NSString * const defaultValue = @"default value";






@implementation TJBActiveCircuitGuidance

#pragma mark - View Cycle

- (void)viewDidLoad{
    
    [self configureViewData];
    
    [self addBackgroundImage];
    
    [self viewAesthetics];
    
}

- (void)viewDidAppear:(BOOL)animated{
    
    //// this kicks off the user selections process.  It exists if the user entered the background state mid-selection-process
    
    if (self.userInputRestorationBlock){
        
        self.userInputRestorationBlock();
        
        // once it is called once it should be destroyed
        
        self.userInputRestorationBlock = nil;
        
    }
    
}

- (void)addBackgroundImage{
    
    [[TJBAestheticsController singleton] addFullScreenBackgroundViewWithImage: [UIImage imageNamed: @"FinlandBackSquat"]
                                                                   toRootView: self.view
                                                                 imageOpacity: .45];
    
}

- (void)viewAesthetics{
    
    // container view
    
    UIView *container = self.containerView;
    container.backgroundColor = [UIColor whiteColor];
    CALayer *containerLayer = container.layer;
    containerLayer.masksToBounds = YES;
    containerLayer.cornerRadius = 8.0;
    containerLayer.opacity = .75;
    
    // labels
    
    NSArray *labels = @[self.exerciseColumnLabel,
                        self.weightColumnLabel,
                        self.repsColumnLabel];
    
    for (UILabel *label in labels){
        
        label.backgroundColor = [[TJBAestheticsController singleton] labelType1Color];
        
    }
    
    // buttons
    
    [[TJBAestheticsController singleton] configureButtonsInArray: @[self.beginSetButton]
                                                     withOpacity: 1];
    
    // round and timer labels
    
    NSArray *otherLabels = @[self.roundColumnLabel,
                             self.restLabel];
    
    for (UILabel *label in otherLabels){
        
        label.backgroundColor = [UIColor darkGrayColor];
        
        [label setTextColor: [UIColor whiteColor]];
        
    }
}

- (void)configureViewData{
    
    //// dynamic views and nav bar will be populated based on whether the realized chain is complete or incomplete
    
    if (self.realizedChain.isIncomplete){
        
        // nav bar
        
        UINavigationItem *navItem = [[UINavigationItem alloc] init];
        NSString *title = [NSString stringWithFormat: @"%@",
                           self.chainTemplate.name];
        [navItem setTitle: title];
        UIBarButtonItem *cancelBarButton = [[UIBarButtonItem alloc] initWithTitle: @"Quit"
                                                                            style: UIBarButtonItemStyleDone
                                                                           target: self
                                                                           action: @selector(quit)];
        [navItem setLeftBarButtonItem: cancelBarButton];
        [self.navBar setItems: @[navItem]];
        
        NSString *notTargetedString = @"not targeted";
        
        // weight
        
        if (self.chainTemplate.targetingWeight == YES){
            
            self.weightLabel.text = [self.activeTargetWeight stringValue];
            
        } else{
            
            self.weightLabel.text = notTargetedString;
            
        }
        
        // reps
        
        if (self.chainTemplate.targetingReps == YES){
            
            self.repsLabel.text = [self.activeTargetReps stringValue];
            
        } else{
            
            self.repsLabel.text = notTargetedString;
            
        }
        
        // rest
        
        // the NSNumber activeTargetRestTime is only created upon state restoration. It is set to nil during normal instantiation because, by definition, there is no rest time before the very first exercise of a chain
        
        if (self.activeTargetRestTime){
            
            NSString *restString = [[TJBStopwatch singleton] minutesAndSecondsStringFromNumberOfSeconds: [self.activeTargetRestTime intValue]];
            
            self.restLabel.text = restString;
            
        } else{
            
            self.restLabel.text = @"";
            
        }
        
        // exercise
        
        int exerciseIndexAsInt = [self.activeExerciseIndex intValue];
        
        TJBExercise *exercise = self.chainTemplate.exercises[exerciseIndexAsInt];
        
        self.exerciseLabel.text = exercise.name;
        
        // round
        
        NSString *roundText = [NSString stringWithFormat: @"Round %d/%d",
                               [self.activeRoundIndex intValue] + 1,
                               [self.numberOfRounds intValue]];
        
        self.roundColumnLabel.text = roundText;
        
    } else{
        
        [self configureViewsWithCircuitCompletedAppearance];
        
        [self configureNavBarWithCircuitCompletedAppearance];
        
    }

}

- (void)configureNavBarWithCircuitCompletedAppearance{
    
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle: @"Circuit Completed"];
    
    UIBarButtonItem *exitBarButton = [[UIBarButtonItem alloc] initWithTitle: @"Exit"
                                                                      style: UIBarButtonItemStylePlain
                                                                     target: self
                                                                     action: @selector(didPressExit)];
    [navItem setLeftBarButtonItem: exitBarButton];
    
    [self.navBar setItems: @[navItem]];
    
}


#pragma mark - Init

- (instancetype)initWithChainTemplate:(TJBChainTemplate *)chainTemplate realizedChainCorrespondingToChainTemplate:(TJBRealizedChain *)realizedChain circuitActiveUpdatingVC:(TJBCircuitActiveUpdatingVC<TJBCircuitActiveUpdatingVCProtocol> *)circuitActiveUpdatingVC wasRestored:(BOOL)wasRestored{
    
    self = [super init];
    
    // IV's
    
    self.chainTemplate = chainTemplate;
    self.realizedChain = realizedChain;
    
    // associated VC
    
    self.circuitActiveUpdatingVC = circuitActiveUpdatingVC;
    
    // other methods
    
    [self setDerivedInstanceVariables];
    
    [self setRestorationProperties];
    
    // set the active instance variables.  If was restored, active instance variables will be set in the class restoration method, and as such, they should not be set here.  If was not restored, initialize active instance variables with starting values
    
    if (!wasRestored){
        
        [self initializeActiveInstanceVariablesWithStartingValues];
    }
    
    return self;
    
}

- (void)initializeActiveInstanceVariablesWithStartingValues{
    
    self.activeRoundIndex = [NSNumber numberWithInt: 0];
    self.activeExerciseIndex = [NSNumber numberWithInt: 0];
    
    self.previousRoundIndex = nil;
    self.previousExerciseIndex = nil;
    
    self.activeTargetRestTime = nil;
    
    TJBChainTemplate *chainTemplate = self.chainTemplate;
    
    if (chainTemplate.targetingWeight == YES){
        
        self.activeTargetWeight = [NSNumber numberWithDouble: chainTemplate.weightArrays[0].numbers[0].value];
        
    }
    
    if (chainTemplate.targetingReps == YES){
        
        self.activeTargetReps = [NSNumber numberWithDouble: chainTemplate.repsArrays[0].numbers[0].value];
        
    }
}

- (void)setRestorationProperties{
    
    self.restorationIdentifier = @"TJBActiveCircuitGuidance";
    self.restorationClass = [TJBActiveCircuitGuidance class];
    
}


- (void)setDerivedInstanceVariables{
    
    self.numberOfExercises = [NSNumber numberWithInt: self.chainTemplate.numberOfExercises];
    self.numberOfRounds = [NSNumber numberWithInt: self.chainTemplate.numberOfRounds];
    
}

#pragma mark - Button Actions

- (void)didPressExit{
    
    //// can only be called when the circuit is complete.  Simply dismisses the circuit mode tab bar
    
    [self dismissViewControllerAnimated: NO
                             completion: nil];
    
}

- (BOOL)setCompletedButtonWasNotPressed{
    
    //// return YES if the set completed button has not been pressed for the active exercise/round.  Else, return NO
    
    BOOL buttonWasNotPressed =  [self.setCompletedButtonPressed boolValue] == NO || !self.setCompletedButtonPressed;
    
    return buttonWasNotPressed;
    
}


-(void)didPressBeginSet{
    
    CancelBlock cancelBlock = ^{
        
        [self setUserSelectedValuesToNil];
        
        [self dismissViewControllerAnimated: NO
                                 completion: nil];
        
    };
    
    // these int's are used in following statements
    
    int exerciseIndex = [self.activeExerciseIndex intValue];
    int roundIndex = [self.activeRoundIndex intValue];
    
    // recursive if tree
    
    if(!self.selectedTimeDelay){
        
        NumberSelectedBlock numberSelectedBlock = ^(NSNumber *number){
            
            self.selectedTimeDelay = number;
            
            // calculate the implied begin date and store it
            
            self.impliedBeginDate = [NSDate dateWithTimeIntervalSinceNow: [number intValue]];
            
            [self dismissViewControllerAnimated: NO
                                     completion: nil];
            [self didPressBeginSet];
 
        };
        
        [self presentNumberSelectionSceneWithNumberType: RestType
                                         numberMultiple: [NSNumber numberWithInt: 5]
                                            numberLimit: nil
                                                  title: @"Select Delay"
                                            cancelBlock: cancelBlock
                                    numberSelectedBlock: numberSelectedBlock
                                               animated: YES
                                   modalTransitionStyle: UIModalTransitionStyleCoverVertical];
        
    } else if ([self setCompletedButtonWasNotPressed] ){
        
        void(^block)(int) = ^(int timeInSeconds){
            
            self.setCompletedButtonPressed = [NSNumber numberWithBool: YES];
            
            [self dismissViewControllerAnimated: NO
                                     completion: nil];
            
            [self didPressBeginSet];
            
        };
        
        // the existence of secondaryTimerFromStateRestoration indicates the app entered the background scene from the InSetVC and the timer should be updated accordingly
        
        // object must be destroyed after first use to allow for normal logic flow to resume
        
        TJBInSetVC *vc;
        
        if (self.secondaryTimerFromStateRestoration){
            
            vc = [[TJBInSetVC alloc] initWithTimeDelay: [self.secondaryTimerFromStateRestoration intValue] * -1
                             DidPressSetCompletedBlock: block
                                          exerciseName: self.chainTemplate.exercises[exerciseIndex].name
                                   lastTimerUpdateDate: self.lastSecondaryTimerUpdateDate
                                      masterController: self];
            
            self.secondaryTimerFromStateRestoration = nil;
            
        } else{
            
            vc = [[TJBInSetVC alloc] initWithTimeDelay: [self.selectedTimeDelay intValue]
                             DidPressSetCompletedBlock: block
                                          exerciseName: self.chainTemplate.exercises[exerciseIndex].name
                                   lastTimerUpdateDate: nil
                                      masterController: self];
        }
    
        [self presentViewController: vc
                           animated: NO
                         completion: nil];
        
    }else if (!self.selectedTimeLag){
        
        NumberSelectedBlock numberSelectedBlock = ^(NSNumber *number){
            
            self.selectedTimeLag = number;
            
            [self dismissViewControllerAnimated: NO
                                     completion: nil];
            
            // store the implied end date
            
            self.impliedEndDate = [NSDate dateWithTimeIntervalSinceNow: [number intValue] * -1];
            
            // stopwatch
            
            self.activeTargetRestTime = [NSNumber numberWithDouble: self.chainTemplate.targetRestTimeArrays[exerciseIndex].numbers[roundIndex].value];
            
            TJBStopwatch *stopwatch = [TJBStopwatch singleton];
            
            int restTimeAccountingForLag = [self.activeTargetRestTime doubleValue] - [number intValue];
            
            self.restLabel.text = [stopwatch minutesAndSecondsStringFromNumberOfSeconds: restTimeAccountingForLag];
            
            [stopwatch setPrimaryStopWatchToTimeInSeconds: restTimeAccountingForLag
                                  withForwardIncrementing: NO
                                           lastUpdateDate: nil];
            
            if ( [self.restLabelAddedAsStopwatchObserver boolValue] == NO || !self.restLabelAddedAsStopwatchObserver){
                
                [[TJBStopwatch singleton] addPrimaryStopwatchObserver: self
                                                       withTimerLabel: self.restLabel];
                
                self.restLabelAddedAsStopwatchObserver = [NSNumber numberWithBool: YES];
                
            }
        
            // recursive
            
            [self didPressBeginSet];
            
        };
        
        [self presentNumberSelectionSceneWithNumberType: RestType
                                         numberMultiple: [NSNumber numberWithInt: 5]
                                            numberLimit: nil
                                                  title: @"Select Lag"
                                            cancelBlock: cancelBlock
                                    numberSelectedBlock: numberSelectedBlock
                                               animated: YES
                                   modalTransitionStyle: UIModalTransitionStyleCoverVertical];
        
    }else if (!self.selectedWeight){
        
        NumberSelectedBlock numberSelectedBlock = ^(NSNumber *number){
            
            self.selectedWeight = number;
            
            [self dismissViewControllerAnimated: NO
                                     completion: nil];
            
            // core data
            
            TJBNumberTypeArrayComp *arrayComp = self.realizedChain.weightArrays[exerciseIndex].numbers[roundIndex];
            
            arrayComp.value = [number floatValue];
            arrayComp.isDefaultObject = NO;
            
            
            [self didPressBeginSet];
            
        };
        
        
        [self presentNumberSelectionSceneWithNumberType: WeightType
                                         numberMultiple: [NSNumber numberWithFloat: 2.5]
                                            numberLimit: nil
                                                  title: @"Select Weight"
                                            cancelBlock: cancelBlock
                                    numberSelectedBlock: numberSelectedBlock
                                               animated: YES
                                   modalTransitionStyle: UIModalTransitionStyleCoverVertical];
        
    }else if (!self.selectedReps){
        
        NumberSelectedBlock numberSelectedBlock = ^(NSNumber *number){
            
            self.selectedReps = number;
            
            [self dismissViewControllerAnimated: NO
                                     completion: nil];
            
            // core data
            
            TJBNumberTypeArrayComp *arrayComp = self.realizedChain.repsArrays[exerciseIndex].numbers[roundIndex];
            
            arrayComp.value = [number floatValue];
            arrayComp.isDefaultObject = NO;
            
            [self didPressBeginSet];
            
        };
        
        
        [self presentNumberSelectionSceneWithNumberType: RepsType
                                         numberMultiple: [NSNumber numberWithInt: 1]
                                            numberLimit: nil
                                                  title: @"Select Reps"
                                            cancelBlock: cancelBlock
                                    numberSelectedBlock: numberSelectedBlock
                                               animated: YES
                                   modalTransitionStyle: UIModalTransitionStyleCoverVertical];
        
    } else{
        
        // order dependent - addSelectedValues must be called before incrementController
        
        [self sendCompletedSetDetailsToCircuitActiveUpdatingVC];
        
        [self addSelectedValuesToRealizedChainObject];
        
        // this method also performs necessary actions at circuit completion
        
        [self incrementControllerAndUpdateViews];
        
        [self setUserSelectedValuesToNil];
        
        [self postNotificationThatRealizedSetHasBeenUpdated];
        
    }
}

- (void)sendCompletedSetDetailsToCircuitActiveUpdatingVC{
    
    //// notify the active updating vc of the just-completed set via its protocol
    
    [self.circuitActiveUpdatingVC didCompleteSetWithExerciseIndex: [self.activeExerciseIndex intValue]
                                                       roundIndex: [self.activeRoundIndex intValue]
                                                           weight: self.selectedWeight
                                                             reps: self.selectedReps
                                                     setBeginDate: self.impliedBeginDate
                                                       setEndDate: self.impliedEndDate];
    
}

- (void)postNotificationThatRealizedSetHasBeenUpdated{
    
    [[NSNotificationCenter defaultCenter] postNotificationName: NSManagedObjectContextDidSaveNotification
                                                        object: self.realizedChain];
    
}


- (void)addSelectedValuesToRealizedChainObject{
    
    // update TJBRealizedChain to account for just completed set
    
    TJBRealizedChain *chain = self.realizedChain;
    
    int exerciseIndex = [self.activeExerciseIndex intValue];
    int roundIndex = [self.activeRoundIndex intValue];
    
    // weight
    
    TJBNumberTypeArrayComp *weight = chain.weightArrays[exerciseIndex].numbers[roundIndex];
    
    weight.value = [self.selectedWeight floatValue];
    weight.isDefaultObject = NO;
    
    // reps
    
    TJBNumberTypeArrayComp *reps = chain.repsArrays[exerciseIndex].numbers[roundIndex];
    
    reps.value = [self.selectedReps floatValue];
    reps.isDefaultObject = NO;
    
    // begin and end set dates
    
    chain.setBeginDateArrays[exerciseIndex].dates[roundIndex].value = self.impliedBeginDate;
    
    chain.setEndDateArrays[exerciseIndex].dates[roundIndex].value = self.impliedEndDate;
    
    // save the managed object context to persist progress made so far
    
    [[CoreDataController singleton] saveContext];
    
}

- (void)configureViewsWithCircuitCompletedAppearance{
    
    //// give views the circuit completed appearance
    
    // button
    
    UIButton *button = self.beginSetButton;
    
    button.backgroundColor = [UIColor clearColor];
    
    [button setTitleColor: [UIColor clearColor]
                 forState: UIControlStateNormal];
    
    button.enabled = NO;
    
    // views
    
    NSString *emptyString = @"";
    
    self.restLabel.text = emptyString;
    self.exerciseLabel.text = emptyString;
    self.weightLabel.text = emptyString;
    self.repsLabel.text = emptyString;
    self.roundColumnLabel.text = emptyString;
    
    // stopwatch - must remove timer label as observer
    
    [[TJBStopwatch singleton] removePrimaryStopwatchObserver: self.restLabel];
    
}

- (void)incrementControllerAndUpdateViews{
    
    //// this method is also responsible for updating the 'first incomplete' type properties of the realized chain
    
    self.previousExerciseIndex = self.activeExerciseIndex;
    self.previousRoundIndex = self.activeRoundIndex;
    
    BOOL atMaxRoundIndex = [self.activeRoundIndex intValue] == [self.numberOfRounds intValue] - 1;
    BOOL atMaxExerciseIndex = [self.activeExerciseIndex intValue] == [self.numberOfExercises intValue] - 1;
    
    if (atMaxExerciseIndex){
        
        if (atMaxRoundIndex){
            
            //// will make proper updates to realized chain, present a message, and put this VC in its chain completed state (turn off begin set button and change views appropriately)
            
            // core data - must update all completeness type properties
            
            self.realizedChain.isIncomplete = NO;
            [[CoreDataController singleton] saveContext];
            
            NSNumber *nextExerciseIndex = nil;
            NSNumber *nextRoundIndex = nil;
            [TJBAssortedUtilities nextIndiceValuesForCurrentExerciseIndex: self.activeExerciseIndex
                                                        currentRoundIndex: self.activeRoundIndex
                                                         maxExerciseIndex: [NSNumber numberWithInt: [self.numberOfExercises intValue] - 1]
                                                            maxRoundIndex: [NSNumber numberWithInt: [self.numberOfRounds intValue] - 1]
                                                   exerciseIndexReference: &nextExerciseIndex
                                                      roundIndexReference: &nextRoundIndex];
            
            self.activeExerciseIndex = nextExerciseIndex;
            self.activeRoundIndex = nextRoundIndex;
            
            // UI
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"Circuit Completed" message: @"You have completed this circuit. Please make any necessary corrections and then press quit to continue"
                                                                    preferredStyle: UIAlertControllerStyleAlert];
            
            void (^continueAction)(UIAlertAction *) = ^(UIAlertAction *action){
                
                __weak TJBActiveCircuitGuidance *weakSelf = self;
                
                [weakSelf configureViewsWithCircuitCompletedAppearance];
                
                [weakSelf configureNavBarWithCircuitCompletedAppearance];
                
            };
            
            UIAlertAction *action = [UIAlertAction actionWithTitle: @"Continue"
                                                             style: UIAlertActionStyleDefault
                                                           handler: continueAction];
            
            [alert addAction: action];
            
            [self presentViewController: alert
                               animated: YES
                             completion: nil];
            
        } else{
            
            self.activeRoundIndex = [NSNumber numberWithInt: [self.activeRoundIndex intValue] + 1];
            self.activeExerciseIndex = [NSNumber numberWithInt: 0];
            
            NSString *roundText = [NSString stringWithFormat: @"Round %d/%d",
                                   [self.activeRoundIndex intValue] + 1,
                                   [self.numberOfRounds intValue]];
            
            self.roundColumnLabel.text = roundText;
        }
        
    } else{

        self.activeExerciseIndex = [NSNumber numberWithInt: [self.activeExerciseIndex intValue] + 1];
        
    }
    
    // update the first incomplete round and exercise properties of the realized chain and save the context
    
    self.realizedChain.firstIncompleteRoundIndex = [self.activeRoundIndex intValue];
    self.realizedChain.firstIncompleteExerciseIndex = [self.activeExerciseIndex intValue];
    
    [[CoreDataController singleton] saveContext];
    
    // if the chain is incomplete, pull the next target values and update the views
    
    if (self.realizedChain.isIncomplete){
        
        // pull next target values from the chain template
        
        TJBChainTemplate *chainTemplate = self.chainTemplate;
        
        int exerciseIndex = [self.activeExerciseIndex intValue];
        int roundIndex = [self.activeRoundIndex intValue];
        
        if (chainTemplate.targetingWeight == YES){
            
            self.activeTargetWeight = [NSNumber numberWithDouble: self.chainTemplate.weightArrays[exerciseIndex].numbers[roundIndex].value];
            
            self.weightLabel.text = [self.activeTargetWeight stringValue];
            
        }
        
        if (chainTemplate.targetingReps == YES){
            
            self.activeTargetReps = [NSNumber numberWithDouble: self.chainTemplate.repsArrays[exerciseIndex].numbers[roundIndex].value];
            
            self.repsLabel.text = [self.activeTargetReps stringValue];
            
        }
        
        TJBExercise *exercise = self.chainTemplate.exercises[exerciseIndex];
        
        self.exerciseLabel.text = exercise.name;
        
    }

}


- (void)quit{
    
    // this will only ever be called before the chain has been completed, so no need to check if the set is completed in method body

    // present alert controller that gives the option to save or discard progress
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"Circuit Not Completed"
                                                                   message: @"Save or discard progress that has been made?"
                                                            preferredStyle: UIAlertControllerStyleAlert];
    
    void (^discardHandler)(UIAlertAction *) = ^(UIAlertAction *action){
        
        // reset the managed object context and nullify the IV referencing the previously inserted TJBRealizedChain
        
        TJBRealizedChain *chain = self.realizedChain;
        
        self.realizedChain = nil;
        
        [[CoreDataController singleton] deleteChainWithChainType: RealizedChainType
                                                           chain: chain];
        
        [self.tabBarController.presentingViewController dismissViewControllerAnimated: NO
                                                                           completion: nil];
        
    };
    
    void (^saveHandler)(UIAlertAction *) = ^(UIAlertAction *action){
        
        // save the managed object context and update the 'first complete' type core data properties of TJBRealizedCHain
        
        self.realizedChain.firstIncompleteRoundIndex = [self.activeRoundIndex intValue];
        self.realizedChain.firstIncompleteExerciseIndex = [self.activeExerciseIndex intValue];
        
        [[CoreDataController singleton] saveContext];
        
        [self.tabBarController.presentingViewController dismissViewControllerAnimated: NO
                                                                           completion: nil];
    };
    
    UIAlertAction *discardAction = [UIAlertAction actionWithTitle: @"Discard"
                                                            style: UIAlertActionStyleDefault
                                                          handler: discardHandler];
    UIAlertAction *saveAction = [UIAlertAction actionWithTitle: @"Save"
                                                         style: UIAlertActionStyleDefault
                                                       handler: saveHandler];
    
    [alert addAction: discardAction];
    [alert addAction: saveAction];
    
    [self presentViewController: alert
                       animated: YES
                     completion: nil];
    
}

- (void)presentNumberSelectionSceneWithNumberType:(NumberType)numberType numberMultiple:(NSNumber *)numberMultiple numberLimit:(NSNumber *)numberLimit title:(NSString *)title cancelBlock:(void(^)(void))cancelBlock numberSelectedBlock:(void(^)(NSNumber *))numberSelectedBlock animated:(BOOL)animated modalTransitionStyle:(UIModalTransitionStyle)transitionStyle{
    
    TJBNumberSelectionVC *numberSelectionVC = [[TJBNumberSelectionVC alloc] initWithNumberTypeIdentifier: numberType
                                                                                          numberMultiple: numberMultiple
                                                                                             numberLimit: numberLimit
                                                                                                   title: title
                                                                                             cancelBlock: cancelBlock
                                                                                     numberSelectedBlock: numberSelectedBlock];
    
    numberSelectionVC.modalTransitionStyle = transitionStyle;
    
    [self presentViewController: numberSelectionVC
                       animated: animated
                     completion: nil];
}

- (void)setUserSelectedValuesToNil{
    
    self.selectedTimeDelay = nil;
    self.selectedTimeLag = nil;
    self.impliedBeginDate = nil;
    self.impliedEndDate = nil;
    self.setCompletedButtonPressed = nil;
    self.selectedWeight = nil;
    self.selectedReps = nil;
}

#pragma mark - <UIViewControllerRestoration>

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder{
    
    //// instantiation will require a realized chain and chain template as it does for normal instantiation.  The only exception for state restoration is the the active variables must be assigned upon restoration
    
    // get the appropriate chain template and realized chain
    
    NSString *chainTemplateUniqueID = [coder decodeObjectForKey: @"chainTemplateUniqueID"];
    TJBChainTemplate *chainTemplate = [[CoreDataController singleton] chainTemplateWithUniqueID: chainTemplateUniqueID];
    
    NSString *realizedChainUniqueID = [coder decodeObjectForKey: @"realizedChainUniqueID"];
    TJBRealizedChain *realizedChain = [[CoreDataController singleton] realizedChainWithUniqueID: realizedChainUniqueID];
    
    // instantiate the VC
    
    TJBActiveCircuitGuidance * vc = [[TJBActiveCircuitGuidance alloc] initWithChainTemplate: chainTemplate
                                                  realizedChainCorrespondingToChainTemplate: realizedChain
                                                                    circuitActiveUpdatingVC: nil
                                                                                wasRestored: YES];
    
    // decode and assign active variables
    
    vc.activeExerciseIndex = [coder decodeObjectForKey: @"activeExerciseIndex"];
    vc.activeRoundIndex = [coder decodeObjectForKey: @"activeRoundIndex"];
    
    vc.previousExerciseIndex = [coder decodeObjectForKey: @"previousRoundIndex"];
    vc.previousRoundIndex = [coder decodeObjectForKey: @"previousRoundIndex"];
    
    vc.activeTargetWeight = [coder decodeObjectForKey: @"activeTargetWeight"];
    vc.activeTargetReps = [coder decodeObjectForKey: @"activeTargetReps"];
    vc.activeTargetRestTime = [coder decodeObjectForKey: @"activeTargetRestTime"];
    
    // return
    
    return vc;
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder{
    
    //// encode the active instance variables and the unique identifiers for the chain template and realized chain. Also encode current user selection info if they are in the selection process.  Need to also encode date in order to calculate elapsed time in background state when the app once again becomes active. Also must encode the 'circuitActiveUpdatingVC' property, which must be reassigned in the decode method (after the active updating circuit has already called its class restoration method)
    
    [super encodeRestorableStateWithCoder: coder];
    
    // active IV's
    
    [coder encodeObject: self.activeExerciseIndex
                 forKey: @"activeExerciseIndex"];
    
    [coder encodeObject: self.activeRoundIndex
                 forKey: @"activeRoundIndex"];
    
    [coder encodeObject: self.previousExerciseIndex
                 forKey: @"previousExerciseIndex"];
    
    [coder encodeObject: self.previousRoundIndex
                 forKey: @"previousRoundIndex"];
    
    [coder encodeObject: self.activeTargetWeight
                 forKey: @"activeTargetWeight"];
    
    [coder encodeObject: self.activeTargetReps
                 forKey: @"activeTargetReps"];
    
    [coder encodeObject: self.activeTargetRestTime
                 forKey: @"activeTargetRestTime"];
    
    // chain template ane realized chain unique identifiers
    
    [coder encodeObject: self.chainTemplate.uniqueID
                 forKey: @"chainTemplateUniqueID"];
    
    [coder encodeObject: self.realizedChain.uniqueID
                 forKey: @"realizedChainUniqueID"];

    
    //// user selection
    
        [coder encodeObject: self.selectedTimeDelay
                     forKey: @"selectedTimeDelay"];
        
        [coder encodeObject: self.impliedBeginDate
                     forKey: @"impliedBeginDate"];
        
        [coder encodeObject: self.setCompletedButtonPressed
                     forKey: @"setCompletedButtonPressed"];
        
        [coder encodeObject: self.selectedTimeLag
                     forKey: @"selectedTimeLag"];
        
        [coder encodeObject: self.impliedEndDate
                     forKey: @"impliedEndDate"];
        
        [coder encodeObject: self.selectedWeight
                     forKey: @"selectedWeight"];
        
        [coder encodeObject: self.selectedReps
                     forKey: @"selectedReps"];
    
    //// timer and date
    
    // the primary stopwatch holds the value of the timer for this VC's view
    // the primary timer's value is significant throughout the entire selection process and should thus always be saved
    
    float primaryTimerValue = [[[TJBStopwatch singleton] primaryTimeElapsedInSeconds] floatValue];
    
    [coder encodeFloat: primaryTimerValue
                forKey: @"primaryTimerValue"];
    
    // the secondary timer is only pertinent if the InSetVC is currently being displayed
    
    BOOL userIsInSet = self.selectedTimeDelay && [self setCompletedButtonWasNotPressed];
    
    if (userIsInSet){
        
        float secondaryTimerValue = [[[TJBStopwatch singleton] secondaryTimeElapsedInSeconds] floatValue];
        
        [coder encodeFloat: secondaryTimerValue
                  forKey: @"secondaryTimerValue"];
        
        [coder encodeObject: self.lastSecondaryTimerUpdateDate
                     forKey: @"lastSecondaryTimerUpdateDate"];
        
    }
    
    // date - used to determine elapsed time in background state
    
    [coder encodeObject: self.lastPrimaryTimerUpdatedDate
                 forKey: @"lastPrimaryTimerUpdatedDate"];
    
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder{
    
    [super decodeRestorableStateWithCoder: coder];
    
    // user selection
    
    self.selectedTimeDelay = [coder decodeObjectForKey: @"selectedTimeDelay"];
    
    self.impliedBeginDate = [coder decodeObjectForKey: @"impliedBeginDate"];
    
    self.setCompletedButtonPressed = [coder decodeObjectForKey: @"setCompletedButtonPressed"];
    
    self.selectedTimeLag = [coder decodeObjectForKey: @"selectedTimeLag"];
    
    self.impliedEndDate = [coder decodeObjectForKey: @"impliedEndDate"];
    
    self.selectedWeight = [coder decodeObjectForKey: @"selectedWeight"];
    
    self.selectedReps = [coder decodeObjectForKey: @"selectedReps"];
    
    // kick off the user selection process if the user is mid-selection
    // this is accomplished by storing this block and executing it in viewDidAppear
    // if selectedTimeDelay exists, the user must be mid-selection because it is not nullified until the selection process ends
    
    if (self.selectedTimeDelay){
        
        __weak TJBActiveCircuitGuidance *weakSelf = self;
        
        self.userInputRestorationBlock = ^{
            [weakSelf didPressBeginSet];
            
        };
        
    }
    
    //// timer - should only be added if circuit is incomplete
    
    if (self.realizedChain.isIncomplete){
        
        // if this is the very first exercise, the rest label should be blank
        
        BOOL isFirstExerciseInFirstRound = [self.activeExerciseIndex intValue] == 0 && [self.activeRoundIndex intValue] == 0;
        
        if (!isFirstExerciseInFirstRound){
            
            // primary
            
            float primaryTimerValue = [coder decodeFloatForKey: @"primaryTimerValue"];
            
            NSDate *lastPrimaryTimerUpdatedDate = [coder decodeObjectForKey: @"lastPrimaryTimerUpdatedDate"];
            self.lastPrimaryTimerUpdatedDate = lastPrimaryTimerUpdatedDate;
            
            TJBStopwatch *stopwatch = [TJBStopwatch singleton];
            
            [stopwatch addPrimaryStopwatchObserver: self
                                    withTimerLabel: self.restLabel];
            
            self.restLabelAddedAsStopwatchObserver = [NSNumber numberWithBool: YES];
            
            self.restLabel.text = [stopwatch minutesAndSecondsStringFromNumberOfSeconds: primaryTimerValue];
            
            [stopwatch setPrimaryStopWatchToTimeInSeconds: primaryTimerValue
                                  withForwardIncrementing: NO
                                           lastUpdateDate: lastPrimaryTimerUpdatedDate];
            
        }
        
        // secondary
        
        BOOL userWasInSet = self.selectedTimeDelay && [self setCompletedButtonWasNotPressed];
        
        if (userWasInSet){
            
            float secondaryTimerValue = [coder decodeFloatForKey: @"secondaryTimerValue"];
            
            self.secondaryTimerFromStateRestoration  = [NSNumber numberWithFloat: secondaryTimerValue];
            
            self.lastSecondaryTimerUpdateDate = [coder decodeObjectForKey: @"lastSecondaryTimerUpdateDate"];
            
        }
        
    }
    

    
}

#pragma mark - <TJBStopwatchObserver>

- (void)primaryTimerDidUpdateWithUpdateDate:(NSDate *)date{
    
    self.lastPrimaryTimerUpdatedDate = date;
    
}

- (void)secondaryTimerDidUpdateWithUpdateDate:(NSDate *)date{
    
    self.lastSecondaryTimerUpdateDate = date;
    
}

@end
































