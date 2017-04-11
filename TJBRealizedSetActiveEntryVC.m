//
//  TJBRealizedSetActiveEntryVC.m
//  Beast
//
//  Created by Trevor Beasty on 12/8/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import "TJBRealizedSetActiveEntryVC.h"

#import "TJBRealizedSet+CoreDataProperties.h"



// audio - for phone vibrating

#import <AudioToolbox/AudioToolbox.h>

// stopwatch

#import "TJBStopWatch.h"

// core data

#import "CoreDataController.h"

// aesthetics

#import "TJBAestheticsController.h"

// personal records / exercise history

#import "TJBPersonalRecordVC.h"
#import "TJBExerciseHistoryVC.h"



// selection vc's

#import "TJBExerciseSelectionScene.h"
#import "TJBNumberSelectionVC.h"
#import "TJBWeightRepsSelectionVC.h"

// set completed summary

#import "TJBSetCompletedSummaryVC.h"

// timer config

#import "TJBClockConfigurationVC.h"


@interface TJBRealizedSetActiveEntryVC () <NSFetchedResultsControllerDelegate>

// IBOutlet

@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UIButton *beginNextSetButton;
@property (weak, nonatomic) IBOutlet UIButton *exerciseButton;
@property (weak, nonatomic) IBOutlet UIButton *leftBarButton;
@property (weak, nonatomic) IBOutlet UILabel *topTopLabel;
@property (weak, nonatomic) IBOutlet UIView *bottomButtonContainer;
@property (weak, nonatomic) IBOutlet UIView *topTitleBar;
@property (weak, nonatomic) IBOutlet UIView *bottomTitleBar;
@property (weak, nonatomic) IBOutlet UILabel *scheduledAlertLabel;
@property (weak, nonatomic) IBOutlet UIView *mainContentContainer;
@property (weak, nonatomic) IBOutlet UILabel *activeExerciseLabel;
@property (weak, nonatomic) IBOutlet UILabel *exerciseValueLabel;


// IBAction

- (IBAction)didPressBeginNextSet:(id)sender;
- (IBAction)didPressExerciseButton:(id)sender;
- (IBAction)didPressLeftBarButton:(id)sender;
- (IBAction)didPressClockButton:(id)sender;

// user input
@property (nonatomic, strong) NSNumber *weight;
@property (nonatomic, strong) NSNumber *reps;

@property (nonatomic, strong) NSNumber *targetRestTime;
@property (nonatomic, strong) NSNumber *alertTiming;
@property (nonatomic, strong) TJBExercise *exercise;

// for stopwatch related behaviour

@property (nonatomic, strong) NSDate *lastPrimaryTimerUpdateDate;
@property (nonatomic, strong) NSNumber *lastPrimaryTimerValue;

// for timer recovery

@property (nonatomic, strong) NSDate *timerUpdateDateForRecovery;
@property (nonatomic, strong) NSNumber *timerValueForRecovery;

// personal records sibling

@property (weak) TJBPersonalRecordVC <TJBPersonalRecordsVCProtocol> *personalRecordsVC;
@property (weak) TJBExerciseHistoryVC <TJBExerciseHistoryProtocol> *exerciseHistoryVC;

// state

@property (strong) TJBSetCompletedSummaryVC *activeSetCompletedSummaryVC;

// for restoration

@property (nonatomic, strong) NSNumber *restoredSecondaryTimerValue;

// if user is in the middle of making selections when app enters the background state, this block will execute aftert the view loads and then be destroyed so that it is not called again when the view again loads

@property (copy) void (^restorationBlock)(void);

@end

@implementation TJBRealizedSetActiveEntryVC

#pragma mark - Instantiation

- (instancetype)init{
    
    self = [super init];
    
    [self configureStopwatchWithFreshValues];
    
    return self;
    
}

#pragma mark - View Life Cycle

- (void)viewDidLoad{

    [self addAppropriateStopwatchObservers];
    
    [self viewAesthetics];
    
    [self configureStartingDisplayValues];
    
}

#pragma mark - View Helper Methods

- (void)configureStartingDisplayValues{
    
    [self.beginNextSetButton setTitle: @"Set Completed"
                             forState: UIControlStateNormal];
    
    self.scheduledAlertLabel.text = [[TJBStopwatch singleton] alertTextFromTargetValues];
    
}

- (void)viewAesthetics{
    
    // meta view
    
    self.view.backgroundColor = [UIColor blackColor];
    
    self.topTitleBar.backgroundColor = [UIColor darkGrayColor];
    self.bottomTitleBar.backgroundColor = [UIColor darkGrayColor];
    
    // buttons
    
    self.bottomButtonContainer.backgroundColor = [[TJBAestheticsController singleton] yellowNotebookColor];
    
    NSArray *bottomButtons = @[self.exerciseButton, self.beginNextSetButton];
    for (UIButton *butt in bottomButtons){
        
        butt.backgroundColor = [[TJBAestheticsController singleton] paleLightBlueColor];
        butt.titleLabel.font = [UIFont boldSystemFontOfSize: 20];
        [butt setTitleColor: [UIColor darkGrayColor]
                   forState: UIControlStateNormal];
        
        CALayer *layer = butt.layer;
        layer.borderColor = [UIColor darkGrayColor].CGColor;
        layer.borderWidth = 1.0;
        layer.cornerRadius = 25;
        layer.masksToBounds = YES;
        
    }
    
    NSArray *titleLabels = @[self.topTopLabel];
    
    for (UILabel *label in titleLabels){
        
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont boldSystemFontOfSize: 20];
        
    }
    
    self.timerLabel.backgroundColor = [UIColor clearColor];
    self.timerLabel.font = [UIFont systemFontOfSize: 35];
    self.timerLabel.textColor = [UIColor whiteColor];
    

    
    NSArray *titleButtons = @[self.leftBarButton];
    for (UIButton *button in titleButtons){
        
        button.backgroundColor = [UIColor darkGrayColor];
        button.titleLabel.font = [UIFont boldSystemFontOfSize: 15.0];
        [button setTitleColor: [[TJBAestheticsController singleton] titleBarButtonColor]
                     forState: UIControlStateNormal];
        
    }
    
    // schedule alert label
    
    self.scheduledAlertLabel.textColor = [UIColor whiteColor];
    self.scheduledAlertLabel.font = [UIFont systemFontOfSize: 15];
    self.scheduledAlertLabel.backgroundColor = [UIColor clearColor];
    
    self.mainContentContainer.backgroundColor = [UIColor clearColor];
    
    NSArray *exerciseLabels = @[self.exerciseValueLabel, self.activeExerciseLabel];
    for (UILabel *lab in exerciseLabels){
        
        lab.textColor = [UIColor whiteColor];
        lab.backgroundColor = [UIColor clearColor];
        
    }
    
    self.activeExerciseLabel.font = [UIFont boldSystemFontOfSize: 20];
    self.exerciseValueLabel.font = [UIFont systemFontOfSize: 35];
  
}




- (void)addAppropriateStopwatchObservers{
    
    [[TJBStopwatch singleton] addPrimaryStopwatchObserver: self
                                           withTimerLabel: self.timerLabel];
    
    self.timerLabel.text = [[TJBStopwatch singleton] primaryTimeElapsedAsString];
    
}

- (void)configureStopwatchWithFreshValues{
    
    [[TJBStopwatch singleton] setPrimaryStopWatchToTimeInSeconds: 0
                                         withForwardIncrementing: YES
                                                  lastUpdateDate: nil];
    
}




#pragma mark - Button Actions

- (IBAction)didPressExerciseButton:(id)sender{
    
    __weak TJBRealizedSetActiveEntryVC *weakSelf = self;
    
    void (^callback)(TJBExercise *) = ^(TJBExercise *selectedExercise){
        
        weakSelf.exercise = selectedExercise;
        
        weakSelf.exerciseValueLabel.text = selectedExercise.name;
        
        [weakSelf.personalRecordsVC activeExerciseDidUpdate: selectedExercise];
        [weakSelf.exerciseHistoryVC activeExerciseDidUpdate: selectedExercise];
    
        [weakSelf dismissViewControllerAnimated: YES
                                     completion: nil];
        
    };
    
    TJBExerciseSelectionScene *vc = [[TJBExerciseSelectionScene alloc] initWithCallbackBlock: callback];
    
    [self presentViewController: vc
                       animated: YES
                     completion: nil];
    
}

- (IBAction)didPressClockButton:(id)sender{
    
    __weak TJBRealizedSetActiveEntryVC *weakSelf = self;
    
    VoidBlock cancelCallback = ^{
        
        [weakSelf dismissViewControllerAnimated: YES
                                 completion: nil];
        
    };
    
    AlertParametersBlock aapCallback = ^(NSNumber *targetRest, NSNumber *alertTiming){
    
        // update the stopwatch
        TJBStopwatch *stopwatch = [TJBStopwatch singleton];
        [stopwatch setAlertParameters_targetRest: targetRest
                                     alertTiming: alertTiming];
        [stopwatch scheduleAlertBasedOnUserPermissions];
        
        // update the scheduled alert label
        int alertTimingValue = [targetRest intValue] - [alertTiming intValue];
        NSString *formattedAlertValue = [stopwatch minutesAndSecondsStringFromNumberOfSeconds: alertTimingValue];
        NSString *scheduledAlertString = [NSString stringWithFormat: @"Alert at %@", formattedAlertValue];
        weakSelf.scheduledAlertLabel.text = scheduledAlertString;
        
        [weakSelf dismissViewControllerAnimated: YES
                                     completion: nil];
        
    };
    
    TJBClockConfigurationVC *vc = [[TJBClockConfigurationVC alloc] initWithApplyAlertParametersCallback: aapCallback
                                                                                         cancelCallback: cancelCallback];
    
    [self presentViewController: vc
                       animated: YES
                     completion: nil];
    
}


- (IBAction)didPressLeftBarButton:(id)sender{
    
    // stopwatch courtesty - reset and pause the stopwatch and remove this label as an observer.  The stopwatch needs to be reset and paused so that it does not populate views with nonsense values (if the active routine scene is navigated to after leaving this scene).  This also prevents irrelevant alert messages from being sent
    
    [[TJBStopwatch singleton] removePrimaryStopwatchObserver: self.timerLabel];
    [[TJBStopwatch singleton] resetAndPausePrimaryTimer];
    
    // delete the scheduled alert, if one exists, when freeform mode is exited
    
    [[TJBStopwatch singleton] deleteActiveLocalAlert];
    
    [self dismissViewControllerAnimated: NO
                             completion: nil];
    
}


- (void)recoverTimer{
    
    [[TJBStopwatch singleton] setPrimaryStopWatchToTimeInSeconds: [self.timerValueForRecovery intValue]
                                         withForwardIncrementing: YES
                                                  lastUpdateDate: self.timerUpdateDateForRecovery];
    
}

- (IBAction)didPressBeginNextSet:(id)sender{
    
    // record timer information in case recovery is necessary (if the user does not complete their entry)
    
    if (!self.timerUpdateDateForRecovery){
        
        self.timerUpdateDateForRecovery = self.lastPrimaryTimerUpdateDate;
        
    }
    
    if (!self.timerValueForRecovery){
        
        self.timerValueForRecovery = [[TJBStopwatch singleton] primaryTimeElapsedInSeconds];
        
    }
    
    __weak TJBRealizedSetActiveEntryVC *weakSelf = self;
    
    CancelBlock cancelBlock = ^{
        
        // timer recovery
        
        [weakSelf recoverTimer];
        
        // set necessary parameters to nil to maintain functionality of recursive method here
        
        [weakSelf setRealizedSetParametersToNil];
        
        [weakSelf dismissViewControllerAnimated: YES
                                     completion: nil];

    };
    
    if (!self.exercise){
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"No Exercise Selected"
                                                                       message: @"Please select an exercise"
                                                                preferredStyle: UIAlertControllerStyleAlert];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle: @"Continue"
                                                         style: UIAlertActionStyleDefault
                                                       handler: nil];
        
        [alert addAction: action];
        
        [self presentViewController: alert
                           animated: YES
                         completion: nil];
   
    } else if (!self.weight){
        
        NumberSelectedBlockDouble numberSelectedBlock = ^(NSNumber *weight, NSNumber *reps){
            
            weakSelf.weight = weight;
            weakSelf.reps = reps;
            
            [weakSelf dismissViewControllerAnimated: YES
                                     completion: nil];
            
            [weakSelf didPressBeginNextSet: nil];
            
        };
        
        NSString *title = [NSString stringWithFormat: @"%@", self.exercise.name];
        
        TJBWeightRepsSelectionVC *vc = [[TJBWeightRepsSelectionVC alloc] initWithTitle: title
                                                                           cancelBlock: cancelBlock
                                                                   numberSelectedBlock: numberSelectedBlock];
        [self presentViewController: vc
                           animated: YES
                         completion: nil];
        
    } else{

        [self presentConfirmationToUser];
        
    }
}


- (void)presentNumberSelectionSceneWithNumberType:(NumberType)numberType numberMultiple:(NSNumber *)numberMultiple numberLimit:(NSNumber *)numberLimit title:(NSString *)title cancelBlock:(void(^)(void))cancelBlock numberSelectedBlock:(void(^)(NSNumber *))numberSelectedBlock animated:(BOOL)animated modalTransitionStyle:(UIModalTransitionStyle)transitionStyle{

    TJBNumberSelectionVC *numberSelectionVC = [[TJBNumberSelectionVC alloc] initWithNumberTypeIdentifier: numberType
                                                                                                   title: title
                                                                                             cancelBlock: cancelBlock
                                                                                     numberSelectedBlock: numberSelectedBlock];

    
    numberSelectionVC.modalTransitionStyle = transitionStyle;
    
    [self presentViewController: numberSelectionVC
                       animated: YES
                     completion: nil];
    
}

#pragma mark - Set Completion Actions


- (void)addRealizedSetToCoreData{
    
    NSManagedObjectContext *moc = [[CoreDataController singleton] moc];
    
    TJBRealizedSet *realizedSet = [NSEntityDescription insertNewObjectForEntityForName: @"RealizedSet"
                                                                inManagedObjectContext: moc];
    
    realizedSet.submittedWeight = [self.weight floatValue];
    realizedSet.submittedReps = [self.reps floatValue];
    realizedSet.exercise = self.exercise;
    realizedSet.holdsNullValues = NO;
    realizedSet.isStandaloneSet = YES;
    realizedSet.submissionTime = [NSDate date];
    
    [[CoreDataController singleton] saveContext];
    
}

- (void)setRealizedSetParametersToNil{
    
    self.weight = nil;
    self.reps = nil;
    
    
    self.timerUpdateDateForRecovery = nil;
    self.timerValueForRecovery = nil;
    
}

- (void)removeConfirmationFromViewHierarchy{
    
    // a view is added to the hierarchy for completed set confirmation.  This method removes the view and nullifies its controller
    
    // I call the methods suggested by apple documentation for removing a child view controller
    
    [self.activeSetCompletedSummaryVC willMoveToParentViewController: nil];
    
    [self.activeSetCompletedSummaryVC.view removeFromSuperview];
    self.activeSetCompletedSummaryVC = nil;
    
    [self.activeSetCompletedSummaryVC removeFromParentViewController];
    
}

- (void)presentConfirmationToUser{
    
    // present the confirmation scene to the user and schedule it to dismiss itself after a set time interval.  It will also be dismissed when the user touches anywhere on screen
    
    // the callback block removes the child view from the view hierarchy
    
    __weak TJBRealizedSetActiveEntryVC *weakSelf = self;
    
    TJBVoidCallback confirmCallback = ^{
        
        [weakSelf removeConfirmationFromViewHierarchy];
        
        [weakSelf addRealizedSetToCoreData];
        
        [weakSelf setRealizedSetParametersToNil];
        
        // reset the stopwatch appropriately
        // maintains the rest target and alert timing values previously set
        [[TJBStopwatch singleton] setPrimaryStopWatchToTimeInSeconds: 0
                                             withForwardIncrementing: YES
                                                      lastUpdateDate: nil]; // reset the stopwatch; when a lastUpdateDate is provided, the stopwatch will add the elapsed time (up until this moment) to the provided time (first argument)
        [[TJBStopwatch singleton] scheduleAlertBasedOnUserPermissions];
        
    };
    
    TJBVoidCallback cancelCallback = ^{
        
        [weakSelf setRealizedSetParametersToNil];
        
        [weakSelf removeConfirmationFromViewHierarchy];
        
    };
    
    TJBVoidCallback editCallback = ^{
        
        [weakSelf setRealizedSetParametersToNil];
        
        [weakSelf removeConfirmationFromViewHierarchy];
        
        [weakSelf didPressBeginNextSet: nil];
        
    };
    
    TJBSetCompletedSummaryVC *vc = [[TJBSetCompletedSummaryVC alloc] initWithExerciseName: self.exercise.name
                                                                                   weight: self.weight
                                                                                     reps: self.reps
                                                                            cancelCallback: cancelCallback
                                                                             editCallback: editCallback
                                                                          confirmCallback: confirmCallback];
    
    self.activeSetCompletedSummaryVC = vc;
    
    // add the view and configure as child view controller
    
    [self addChildViewController: vc];
    
    [self.view addSubview: vc.view];
    
    [vc didMoveToParentViewController: self];
    
}




#pragma mark - <TJBStopwatchObserver>

- (void)primaryTimerDidUpdateWithUpdateDate:(NSDate *)date timerValue:(float)timerValue{

    self.lastPrimaryTimerUpdateDate = date;

    
}

- (void)secondaryTimerDidUpdateWithUpdateDate:(NSDate *)date{
    
    
}

#pragma mark - API

- (void)configureSiblingPersonalRecordsVC:(TJBPersonalRecordVC<TJBPersonalRecordsVCProtocol> *)personalRecordsVC{
    
    self.personalRecordsVC = personalRecordsVC;
    
}

- (void)configureSiblingExerciseHistoryVC:(TJBExerciseHistoryVC<TJBExerciseHistoryProtocol> *)exerciseHistoryVC{
    
    self.exerciseHistoryVC = exerciseHistoryVC;
    
}


@end


















































