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

// personal records

#import "TJBRepsWeightRecordPair.h"

// table view cells

#import "TJBPersonalRecordCell.h"
#import "TJBDetailTitleCell.h"
#import "TJBNoDataCell.h"

// selection vc's

#import "TJBExerciseSelectionScene.h"
#import "TJBNumberSelectionVC.h"
#import "TJBWeightRepsSelectionVC.h"

// set completed summary

#import "TJBSetCompletedSummaryVC.h"


@interface TJBRealizedSetActiveEntryVC () <NSFetchedResultsControllerDelegate, UIViewControllerRestoration, UITableViewDelegate, UITableViewDataSource>

{
    
    // user input
    
    BOOL _setCompletedButtonPressed;
    int _timerAtSetCompletion;
    BOOL _whiteoutActive;
    
    // state
    
    BOOL _advancedOptionsActive;
    
}

// IBOutlet

@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UIButton *targetRestButton;
@property (weak, nonatomic) IBOutlet UIButton *beginNextSetButton;
@property (weak, nonatomic) IBOutlet UIButton *alertTimingButton;
@property (weak, nonatomic) IBOutlet UIButton *exerciseButton;
@property (weak, nonatomic) IBOutlet UITableView *personalRecordsTableView;
@property (weak, nonatomic) IBOutlet UIView *shadowView;
@property (weak, nonatomic) IBOutlet UIView *titleLabelsContainer;
@property (weak, nonatomic) IBOutlet UILabel *freeformTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *leftBarButton;
@property (weak, nonatomic) IBOutlet UIButton *targetRestTitle;
@property (weak, nonatomic) IBOutlet UIButton *alertTimingTitle;
@property (weak, nonatomic) IBOutlet UILabel *topTopLabel;
@property (weak, nonatomic) IBOutlet UIView *bottomButtonContainer;
@property (weak, nonatomic) IBOutlet UILabel *thinTitleLabel;

// IBAction

- (IBAction)didPressBeginNextSet:(id)sender;
- (IBAction)didPressTargetRestButton:(id)sender;
- (IBAction)didPressAlertTimingButton:(id)sender;
- (IBAction)didPressExerciseButton:(id)sender;
- (IBAction)didPressLeftBarButton:(id)sender;
- (IBAction)didPressAlertTimingTitle:(id)sender;
- (IBAction)didPressTargetRestTitle:(id)sender;
//// core data

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

// two fetches are required - realized chain and realized set.  The results are stored for each.  Because fetched results are not being directly fed into a table view, NSFetchedResultsController is not used

//@property (nonatomic, strong) NSArray *realizedSetFetchResults;
//@property (nonatomic, strong) NSArray *realizedChainFetchResults;

// an array of TJBRepsWeightRecordPairs.  Record pairs are always held for reps values of 1 through 12.  New pairs are added as needed

@property (nonatomic, strong) NSMutableArray<TJBRepsWeightRecordPair *> *repsWeightRecordPairs;


////

// user input

@property (nonatomic, strong) NSNumber *timeDelay;
@property (nonatomic, strong) NSNumber *timeLag;
@property (nonatomic, strong) NSDate *setBeginDate;
@property (nonatomic, strong) NSDate *setEndDate;
@property (nonatomic, strong) NSNumber *weight;
@property (nonatomic, strong) NSNumber *reps;

@property (nonatomic, strong) NSNumber *targetRestTime;
@property (nonatomic, strong) NSNumber *alertTiming;
@property (nonatomic, strong) TJBExercise *exercise;
//@property (weak, nonatomic) IBOutlet UILabel *topBarRightLabel;

//// timer and target rest time

@property (nonatomic, strong) UIView *whiteoutView;

// for stopwatch related behaviour

@property (nonatomic, strong) NSDate *lastPrimaryTimerUpdateDate;
@property (nonatomic, strong) NSDate *lastSecondaryTimerUpdateDate;

@property (nonatomic, strong) NSNumber *lastPrimaryTimerValue;

// for timer recovery

@property (nonatomic, strong) NSDate *timerUpdateDateForRecovery;
@property (nonatomic, strong) NSNumber *timerValueForRecovery;

////

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
    
    [self setRestorationProperties];
    
    [self configureNotifications];
    
    return self;
    
}

- (void)configureNotifications{
    
    NSManagedObjectContext *moc = [[CoreDataController singleton] moc];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(coreDataDidUpdate)
                                                 name: NSManagedObjectContextDidSaveNotification
                                               object: moc];
    
}

- (instancetype)initRestoredVC{
    
    self = [super init];
    
    [self setRestorationProperties];
    
    return self;

}

- (void)setRestorationProperties{
    
    // for restoration
    
    self.restorationIdentifier = @"TJBRealizedSetActiveEntryVC";
    self.restorationClass = [TJBRealizedSetActiveEntryVC class];
    
}

#pragma mark - View Life Cycle


- (void)viewDidAppear:(BOOL)animated{
    
    if (self.restorationBlock){
        
        self.restorationBlock();
        
        self.restorationBlock = nil;
        
    }
    
}

- (void)viewDidLoad{
    
    _setCompletedButtonPressed = NO;
    
    _whiteoutActive = NO;
    
    [self addAppropriateStopwatchObservers];
    
    [self configureTableView];
    
    [self viewAesthetics];
    
    [self configureStartingDisplayValues];
    
}



- (void)configureStartingDisplayValues{
    
    
        
    [self.beginNextSetButton setTitle: @"Set Completed"
                             forState: UIControlStateNormal];
        
    
    
}


- (void)configureTableView{
    
    UINib *nib = [UINib nibWithNibName: @"TJBPersonalRecordCell"
                                bundle: nil];
    
    [self.personalRecordsTableView registerNib: nib
                        forCellReuseIdentifier: @"PRCell"];
    
    UINib *nib2 = [UINib nibWithNibName: @"TJBDetailTitleCell"
                                bundle: nil];
    
    [self.personalRecordsTableView registerNib: nib2
                        forCellReuseIdentifier: @"TJBDetailTitleCell"];
    
    UINib *noDataCell = [UINib nibWithNibName: @"TJBNoDataCell"
                                 bundle: nil];
    
    [self.personalRecordsTableView registerNib: noDataCell
                        forCellReuseIdentifier: @"TJBNoDataCell"];
    
    self.personalRecordsTableView.bounces = YES;
    
}

- (void)viewAesthetics{
    
    // meta view
    
    self.view.backgroundColor = [UIColor blackColor];
    
    // buttons
    
    self.bottomButtonContainer.backgroundColor = [[TJBAestheticsController singleton] yellowNotebookColor];
    
//    [self.view insertSubview: self.bottomButtonContainer
//                aboveSubview: self.personalRecordsTableView];
//    CALayer *bbcLayer = self.bottomButtonContainer.layer;
//    bbcLayer.shadowColor = [[TJBAestheticsController singleton] titleBarButtonColor].CGColor;
//    bbcLayer.shadowOffset = CGSizeMake(0, -4.0);
//    bbcLayer.masksToBounds = NO;
//    bbcLayer.shadowOpacity = .4;
//    bbcLayer.shadowRadius = 4.0;
//    self.bottomButtonContainer.clipsToBounds = NO;
    
    NSArray *bottomButtons = @[self.exerciseButton, self.beginNextSetButton];
    for (UIButton *butt in bottomButtons){
        
        butt.backgroundColor = [UIColor clearColor];
        butt.titleLabel.font = [UIFont systemFontOfSize: 20];
        [butt setTitleColor: [UIColor blackColor]
                   forState: UIControlStateNormal];
        
        CALayer *layer = butt.layer;
        layer.borderColor = [UIColor blackColor].CGColor;
        layer.borderWidth = 1.0;
        layer.cornerRadius = 15;
        layer.masksToBounds = YES;
        
    }
    
    // title labels and title buttons and container
    
    self.thinTitleLabel.backgroundColor = [[TJBAestheticsController singleton] titleBarButtonColor];
    
    self.titleLabelsContainer.backgroundColor = [UIColor darkGrayColor];
    
    NSArray *titleLabels = @[self.freeformTitleLabel, self.topTopLabel];
    
    for (UILabel *label in titleLabels){
        
        label.backgroundColor = [UIColor darkGrayColor];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont boldSystemFontOfSize: 20];
        
    }
    
    self.freeformTitleLabel.font = [UIFont systemFontOfSize: 15];
    self.topTopLabel.font = [UIFont boldSystemFontOfSize: 25];
    
    self.timerLabel.backgroundColor = [UIColor darkGrayColor];
    self.timerLabel.font = [UIFont systemFontOfSize: 35];
    self.timerLabel.textColor = [UIColor whiteColor];
    

    
    NSArray *titleButtons = @[self.leftBarButton];
    for (UIButton *button in titleButtons){
        
        button.backgroundColor = [UIColor darkGrayColor];
        button.titleLabel.font = [UIFont boldSystemFontOfSize: 15.0];
        [button setTitleColor: [[TJBAestheticsController singleton] titleBarButtonColor]
                     forState: UIControlStateNormal];
        
    }
    
    // table view
    
    self.personalRecordsTableView.backgroundColor = [[TJBAestheticsController singleton] yellowNotebookColor];
    
    // rest time buttons and labels
    
    NSArray *restButtons = @[self.targetRestButton, self.alertTimingButton];
    for (UIButton *b in restButtons){
        
        [b setTitleColor: [[TJBAestheticsController singleton] titleBarButtonColor]
                forState: UIControlStateNormal];
        
        b.backgroundColor = [UIColor clearColor];
        b.titleLabel.font = [UIFont systemFontOfSize: 20];
        
    }
    
    NSArray *restTitleButtons = @[self.targetRestTitle, self.alertTimingTitle];
    for (UIButton *b in restTitleButtons){
        
        b.backgroundColor = [UIColor clearColor];
        b.titleLabel.font = [UIFont systemFontOfSize: 15];
        [b setTitleColor: [[TJBAestheticsController singleton] titleBarButtonColor]
                forState: UIControlStateNormal];
        
    }
    
    // button images
    
    UIImage *homeButtonImage = [UIImage imageNamed: @"titleBarHomeButton"];
    [self.leftBarButton setBackgroundImage: homeButtonImage
                                  forState: UIControlStateNormal];
  
}


- (void)exerciseDataChanged{
    
    NSError *error = nil;
    
    [self.fetchedResultsController performFetch: &error];
    
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

#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    //// add 1 to account for title cell
    
    if (!self.exercise){
        return 1;
    }
    
    if (!self.repsWeightRecordPairs || self.repsWeightRecordPairs.count == 0){
        
        return 2;
        
    } else{
        
        return self.repsWeightRecordPairs.count + 1;
        
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (!self.exercise){
        
        TJBNoDataCell *cell = [self.personalRecordsTableView dequeueReusableCellWithIdentifier: @"TJBNoDataCell"];
        
        cell.mainLabel.text = @"No Exercise Selected";
        cell.backgroundColor = [UIColor clearColor];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
        
    }
    
    if (indexPath.row == 0){
        
        TJBDetailTitleCell *cell = [self.personalRecordsTableView dequeueReusableCellWithIdentifier: @"TJBDetailTitleCell"];
        
        if (self.exercise){
            
            cell.subtitleLabel.text = self.exercise.name;
            
        } else{
            
            cell.subtitleLabel.text = @"Select an exercise";
            
        }
        
        cell.titleLabel.text = @"Personal Records";
        cell.detail1Label.text = @"reps";
        cell.detail2Label.text = @"weight";
        cell.detail3Label.text = @"date";
        
        cell.backgroundColor = [UIColor clearColor];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
        
    } else{
        
        if (!self.repsWeightRecordPairs || self.repsWeightRecordPairs.count == 0){
            
            TJBNoDataCell *cell = [self.personalRecordsTableView dequeueReusableCellWithIdentifier: @"TJBNoDataCell"];
            
            cell.mainLabel.text = @"No Personal Records";
            cell.backgroundColor = [UIColor clearColor];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            return cell;
            
        } else{
            
            NSInteger adjustedRowIndex = indexPath.row - 1;
            
            TJBPersonalRecordCell *cell = [self.personalRecordsTableView dequeueReusableCellWithIdentifier: @"PRCell"];
            
            TJBRepsWeightRecordPair *repsWeightRecordPair = self.repsWeightRecordPairs[adjustedRowIndex];
            
            [cell configureWithReps: repsWeightRecordPair.reps
                             weight: repsWeightRecordPair.weight
                               date: repsWeightRecordPair.date];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            return cell;
            
        }
        

    }
    
}



#pragma mark - <UITableViewDelegate>

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (!self.exercise){
        return self.personalRecordsTableView.frame.size.height;
    }
    
    CGFloat titleHeight = 90;
    
    if (indexPath.row == 0){
        
        return titleHeight;
        
    } else{
        
        if (!self.repsWeightRecordPairs || self.repsWeightRecordPairs.count ==0){
            
//            [self.view layoutIfNeeded];
            
            return self.shadowView.frame.size.height - titleHeight;
            
        } else{
            
                return 60;
            
        }
    }
}


#pragma mark - Button Actions


- (IBAction)didPressTargetRestButton:(id)sender {
    
    //// present the number selection scene.  Store the selected value as a property and display it.  This value will be used in conjuction with the timer in order to send notifications to the user when it is almost time to get into set
    
    __weak TJBRealizedSetActiveEntryVC *weakSelf = self;
    
    void (^cancelBlock)(void) = ^{
        
        [weakSelf dismissViewControllerAnimated: NO
                                     completion: nil];
        
    };
    
    void (^numberSelectedBlock)(NSNumber *) = ^(NSNumber *selectedNumber){
        
        weakSelf.targetRestTime = selectedNumber;
        
        NSString *targetRestString = [[TJBStopwatch singleton] minutesAndSecondsStringFromNumberOfSeconds: [selectedNumber intValue]];
        
        [weakSelf.targetRestButton setTitle: targetRestString
                               forState: UIControlStateNormal];
        
        [weakSelf dismissViewControllerAnimated: YES
                                     completion: nil];
        
    };
    
    [self presentNumberSelectionSceneWithNumberType: TargetRestType
                                     numberMultiple: [NSNumber numberWithDouble: 5.0]
                                        numberLimit: nil
                                              title: @"Select Target Rest"
                                        cancelBlock: cancelBlock
                                numberSelectedBlock: numberSelectedBlock
                                           animated: NO
                               modalTransitionStyle: UIModalTransitionStyleCoverVertical];
    
}

- (IBAction)didPressAlertTimingButton:(id)sender{
    
    //// present the number selection scene.  Store the selected value as a property and display it.  This value will be used in conjuction with the timer in order to send notifications to the user when it is almost time to get into set
    
    __weak TJBRealizedSetActiveEntryVC *weakSelf = self;
    
    void (^cancelBlock)(void) = ^{
        
        [weakSelf dismissViewControllerAnimated: NO
                                     completion: nil];
        
    };
    
    void (^numberSelectedBlock)(NSNumber *) = ^(NSNumber *selectedNumber){
        
        weakSelf.alertTiming = selectedNumber;
        
        NSString *targetRestString = [[TJBStopwatch singleton] minutesAndSecondsStringFromNumberOfSeconds: [selectedNumber intValue]];
        
        [weakSelf.alertTimingButton setTitle: targetRestString
                                    forState: UIControlStateNormal];
        
        [weakSelf dismissViewControllerAnimated: YES
                                     completion: nil];
        
    };
    
    [self presentNumberSelectionSceneWithNumberType: TimeIntervalSelection
                                     numberMultiple: [NSNumber numberWithDouble: 5.0]
                                        numberLimit: nil
                                              title: @"Select Alert Timing"
                                        cancelBlock: cancelBlock
                                numberSelectedBlock: numberSelectedBlock
                                           animated: NO
                               modalTransitionStyle: UIModalTransitionStyleCoverVertical];
    
}

- (IBAction)didPressExerciseButton:(id)sender{
    
    __weak TJBRealizedSetActiveEntryVC *weakSelf = self;
    
    void (^callback)(TJBExercise *) = ^(TJBExercise *selectedExercise){
        
        weakSelf.exercise = selectedExercise;
        
        self.freeformTitleLabel.text = selectedExercise.name;
        
        [weakSelf fetchManagedObjectsAndDetermineRecordsForActiveExercise];
        
        [weakSelf.personalRecordsTableView reloadData];
        
        [weakSelf dismissViewControllerAnimated: YES
                                     completion: nil];
        
    };
    
    TJBExerciseSelectionScene *vc = [[TJBExerciseSelectionScene alloc] initWithCallbackBlock: callback];
    
    [self presentViewController: vc
                       animated: YES
                     completion: nil];
    
}


- (IBAction)didPressLeftBarButton:(id)sender{
    
    // stopwatch courtesty - reset and pause the stopwatch and remove this label as an observer.  The stopwatch needs to be reset and paused so that it does not populate views with nonsense values (if the active routine scene is navigated to after leaving this scene).  This also prevents irrelevant alert messages from being sent
    
    [[TJBStopwatch singleton] removePrimaryStopwatchObserver: self.timerLabel];
    [[TJBStopwatch singleton] resetAndPausePrimaryTimer];
    
    //
    
    [self dismissViewControllerAnimated: NO
                             completion: nil];
    
}

- (IBAction)didPressAlertTimingTitle:(id)sender{
    
    [self didPressAlertTimingButton: nil];
    
}

- (IBAction)didPressTargetRestTitle:(id)sender{
    
    [self didPressTargetRestButton: nil];
    
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
        
        [weakSelf removeWhiteoutView];
        
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
        
        [self removeWhiteoutView];
        
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
        
        self.setEndDate = [NSDate date];
        
        NSString *title = [NSString stringWithFormat: @"%@", self.exercise.name];
        
        TJBWeightRepsSelectionVC *vc = [[TJBWeightRepsSelectionVC alloc] initWithTitle: title
                                                                           cancelBlock: cancelBlock
                                                                   numberSelectedBlock: numberSelectedBlock];
        [self presentViewController: vc
                           animated: YES
                         completion: nil];
        
    } else{

        [self confirmSubmission];
        
    }
}

- (void)removeWhiteoutView{
    [self.whiteoutView removeFromSuperview];
    _whiteoutActive = NO;
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

- (void)addRealizedSetToCoreData{
    
    BOOL postMortem = FALSE;
    
    NSManagedObjectContext *moc = [[CoreDataController singleton] moc];
    
    TJBRealizedSet *realizedSet = [NSEntityDescription insertNewObjectForEntityForName: @"RealizedSet"
                                                                inManagedObjectContext: moc];
    
    realizedSet.recordedBeginDate = NO;
    realizedSet.exactBeginDate = NO;

    // set end date and associated BOOLs
    
    realizedSet.recordedEndDate = YES;
    realizedSet.endDate = self.setEndDate;
    realizedSet.exactEndDate = NO;
    
    // other
    
    realizedSet.postMortem = postMortem;
    realizedSet.weight = [self.weight floatValue];
    realizedSet.reps = [self.reps floatValue];
    realizedSet.exercise = self.exercise;
    
    [[CoreDataController singleton] saveContext];
    
}

#pragma mark - <NewExerciseCreationDelegate>

- (void)didCreateNewExercise:(TJBExercise *)exercise{
    self.exercise = exercise;
    
    NSError *error = nil;
    [self.fetchedResultsController performFetch: &error];
    
    [self dismissViewControllerAnimated: YES
                             completion: nil];

}

#pragma mark - Set Completion Actions

- (void)presentSubmittedSetSummary{
    // UIAlertController
    
    NSString *string = [NSString stringWithFormat: @"%@: %.01f lbs for %.00f reps",
                        self.exercise.name,
                        [self.weight floatValue],
                        [self.reps floatValue]];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"Detail Confirmation"
                                                                   message: string
                                                            preferredStyle: UIAlertControllerStyleAlert];
    
    // capture a weak reference to self in order to avoid a strong reference cycle
    
    __weak TJBRealizedSetActiveEntryVC *weakSelf = self;
    
    void (^action1Block)(UIAlertAction *) = ^(UIAlertAction *action){
        [weakSelf setRealizedSetParametersToNil];
    };
    
    void (^action2Block)(UIAlertAction *) = ^(UIAlertAction *action){
        [weakSelf confirmSubmission];
    };
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle: @"Discard"
                                                      style: UIAlertActionStyleDefault
                                                    handler: action1Block];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle: @"Save"
                                                      style: UIAlertActionStyleDefault
                                                    handler: action2Block];
    
    [alert addAction: action1];
    [alert addAction: action2];
    
    [self presentViewController: alert
                       animated: YES
                     completion: nil];
}

- (void)setRealizedSetParametersToNil{
    
    self.timeDelay = nil;
    _setCompletedButtonPressed = NO;
    self.timeLag = nil;
    self.weight = nil;
    self.reps = nil;
    
    
    self.timerUpdateDateForRecovery = nil;
    self.timerValueForRecovery = nil;
    
}

- (void)confirmSubmission{
    
    [self addRealizedSetToCoreData];
    
    [self presentConfirmationToUser];
    
    [self setRealizedSetParametersToNil];
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
    
    TJBCompletedSetCallback callbackBlock = ^{
        
        [self removeConfirmationFromViewHierarchy];
        
    };
    
    TJBSetCompletedSummaryVC *vc = [[TJBSetCompletedSummaryVC alloc] initWithExerciseName: self.exercise.name
                                                                                   weight: self.weight
                                                                                     reps: self.reps
                                                                            callbackBlock: callbackBlock];
    
    self.activeSetCompletedSummaryVC = vc;
    
    // add the view and configure as child view controller
    
    [self addChildViewController: vc];
    
    [self.view addSubview: vc.view];
    
    [vc didMoveToParentViewController: self];
    
}

#pragma mark - <UIViewControllerRestoration>

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder{
    
    TJBRealizedSetActiveEntryVC *vc = [[TJBRealizedSetActiveEntryVC alloc] initRestoredVC];
    
    return vc;
    
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder{
    
    [super encodeRestorableStateWithCoder: coder];
    
    // timer
    
    int primaryTime = [[[TJBStopwatch singleton] primaryTimeElapsedInSeconds] floatValue];
    
    [coder encodeFloat: primaryTime
              forKey: @"primaryTime"];
    
    [coder encodeObject: self.lastPrimaryTimerUpdateDate
                 forKey: @"lastPrimaryTimerUpdateDate"];
    
    float secondaryTime = [[[TJBStopwatch singleton] secondaryTimeElapsedInSeconds] floatValue];
    
    [coder encodeFloat: secondaryTime
              forKey: @"secondaryTime"];
    
    [coder encodeObject: self.lastSecondaryTimerUpdateDate
                 forKey: @"lastSecondaryTimerUpdateDate"];
    
    // realized set user selections
    
    [coder encodeBool: _whiteoutActive
               forKey: @"whiteoutActive"];
    
    if (self.timeDelay){
        [coder encodeObject: self.timeDelay
                     forKey: @"timeDelay"];
        [coder encodeObject: self.setBeginDate
                     forKey: @"setBeginDate"];
    }
    
    [coder encodeBool: _setCompletedButtonPressed
               forKey: @"setCompletedButtonPressed"];
    
    if (self.timeLag){
        [coder encodeObject: self.timeLag
                     forKey: @"timeLag"];
        [coder encodeObject: self.setEndDate
                     forKey: @"setEndDate"];
    }
    
    if (self.weight){
        [coder encodeObject: self.weight
                     forKey: @"weight"];
    }
    
    if (self.reps){
        [coder encodeObject: self.reps
                     forKey: @"reps"];
    }
    
}


- (void)decodeRestorableStateWithCoder:(NSCoder *)coder{
    
    [super decodeRestorableStateWithCoder: coder];
    
    // primary timer
    
    int primaryTime = [coder decodeFloatForKey: @"primaryTime"];
    
    NSDate *lastPrimaryTimerUpdateDate = [coder decodeObjectForKey: @"lastPrimaryTimerUpdateDate"];
    self.lastPrimaryTimerUpdateDate = lastPrimaryTimerUpdateDate;
    
    [[TJBStopwatch singleton] setPrimaryStopWatchToTimeInSeconds: primaryTime
                                         withForwardIncrementing: YES
                                                  lastUpdateDate: lastPrimaryTimerUpdateDate];
    
    self.timerLabel.text = [[TJBStopwatch singleton] minutesAndSecondsStringFromNumberOfSeconds: primaryTime];
    
    // realized set user selections
    
    _whiteoutActive = [coder decodeBoolForKey: @"whiteoutActive"];
    self.timeDelay = [coder decodeObjectForKey: @"timeDelay"];
    self.setBeginDate = [coder decodeObjectForKey: @"setBeginDate"];
    _setCompletedButtonPressed = [coder decodeBoolForKey: @"setCompletedButtonPressed"];
    self.timeLag = [coder decodeObjectForKey: @"timeLag"];
    self.setEndDate = [coder decodeObjectForKey: @"setEndDate"];
    self.weight = [coder decodeObjectForKey: @"weight"];
    self.reps = [coder decodeObjectForKey: @"reps"];
    
    // store the time the secondary timer should start at if app entered background state from InSetVC

    if (self.timeDelay && _setCompletedButtonPressed == NO){
        
        float previousValueOfSecondaryTimer = [coder decodeFloatForKey: @"secondaryTime"];
        
        self.restoredSecondaryTimerValue = [NSNumber numberWithFloat: previousValueOfSecondaryTimer];
        
        self.lastSecondaryTimerUpdateDate = [coder decodeObjectForKey: @"lastSecondaryTimerUpdateDate"];
        
    }
    
    // kicks off the selection process if user ended mid-selection
    
    if (self.timeDelay){
        
        __weak TJBRealizedSetActiveEntryVC *weakSelf = self;
        
        void (^restorationBlock)(void) = ^{
            
            [weakSelf didPressBeginNextSet: nil];
            
        };
        
        self.restorationBlock = restorationBlock;
        
    }
    
}


#pragma mark - <TJBStopwatchObserver>

- (void)primaryTimerDidUpdateWithUpdateDate:(NSDate *)date timerValue:(float)timerValue{
    
    // store the passed in date
    
    self.lastPrimaryTimerUpdateDate = date;
    
    // if the timer value is greater than the target rest minus the alert timing, turn the timer labels red
    // must only execute if the targetRestTime and alerTiming have been selected
    
    if (self.targetRestTime && self.alertTiming){
        
        float alertValue = [self.targetRestTime floatValue] - [self.alertTiming floatValue];
        
        BOOL inRedZone = timerValue > alertValue;
        
        // because the stopwatch observer methods are sent every .1 seconds, the if structure must seek to match timer values over a span of .1 seconds.  Any less of a span might miss the vibration call, and any more may cause it to vibrate twice
        
        // the following is called three times so that the phone vibrates a total of three times.  The vibrate calls are spaced at equal intervals
        
        // this observer method is stilled called when an alternate scene is being presented
        
        if (timerValue >= alertValue - .25 && timerValue < alertValue - .15){
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        }
        
        if (timerValue >= alertValue + .15 && timerValue < alertValue + .25){
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        }
        
        if (timerValue >= alertValue + .55 && timerValue < alertValue + .65){
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        }
        
        if (inRedZone){
            
            [self toggleRestControlsToRedZone];
            
        } else{
            
            [self toggleRestControlsToDefaultState];
            
        }
        
    }
    
}

- (void)toggleRestControlsToRedZone{
    
    self.timerLabel.backgroundColor = [UIColor redColor];
    
    // rest time buttons and labels
    
    NSArray *restButtons = @[self.targetRestButton, self.alertTimingButton];
    for (UIButton *b in restButtons){
        
        [b setTitleColor: [UIColor whiteColor]
                forState: UIControlStateNormal];
        
    }
    
    NSArray *restTitleButtons = @[self.targetRestTitle, self.alertTimingTitle];
    for (UIButton *b in restTitleButtons){
    
        [b setTitleColor: [UIColor whiteColor]
                forState: UIControlStateNormal];
        
    }
    
}

- (void)toggleRestControlsToDefaultState{
    
    self.timerLabel.backgroundColor = [UIColor darkGrayColor];
    
    // rest time buttons and labels
    
    NSArray *restButtons = @[self.targetRestButton, self.alertTimingButton];
    for (UIButton *b in restButtons){
        
        [b setTitleColor: [[TJBAestheticsController singleton] yellowNotebookColor]
                forState: UIControlStateNormal];
        
    }
    
    NSArray *restTitleButtons = @[self.targetRestTitle, self.alertTimingTitle];
    for (UIButton *b in restTitleButtons){
        
        [b setTitleColor: [[TJBAestheticsController singleton] yellowNotebookColor]
                forState: UIControlStateNormal];
        
    }
    
}

- (void)secondaryTimerDidUpdateWithUpdateDate:(NSDate *)date{
    
    self.lastSecondaryTimerUpdateDate = date;
    
}

#pragma mark - Personal Records

- (void)fetchManagedObjectsAndDetermineRecordsForActiveExercise{
    
    TJBExercise *activeExercise = self.exercise;
    
    if (activeExercise){
        
        // the recordsPairArray must be cleaned with each new selected exercise.  Instantiating it again achieves this
        
        [self instantiateRecordPairsArray];
        
        // realized sets
        
        for (TJBRealizedSet *realizedSet in activeExercise.realizedSets){
            
            TJBRepsWeightRecordPair *currentRecordForPrescribedReps = [self repsWeightRecordPairForNumberOfReps: realizedSet.reps];
            
            // compare the weight of the current realized set to that of the current record to determine what should be done
            
            [self configureRepsWeightRecordPair: currentRecordForPrescribedReps
                            withCandidateWeight: [NSNumber numberWithDouble: realizedSet.weight]
                                  candidateDate: realizedSet.endDate];
            
        }
        
        // realized chains
        
        for (TJBRealizedChain *realizedChain in activeExercise.chains){
            
            if ([realizedChain isKindOfClass: [TJBChainTemplate class]]){
                
                continue;
                
            }
            
            NSArray *exerciseIndices = [self indicesContainingExercise: activeExercise
                                                      forRealizedChain: realizedChain];
            
            int roundLimit = realizedChain.numberOfRounds;
            
            for (NSNumber *number in exerciseIndices){
                
                int exerciseIndex = [number intValue];
                
                for (int i = 0; i < roundLimit; i++){
                    
                    BOOL isDefaultEntry = realizedChain.weightArrays[exerciseIndex].numbers[i].isDefaultObject;
                    
                    if (!isDefaultEntry){
                        
                        int reps = (int)realizedChain.repsArrays[exerciseIndex].numbers[i].value;
                        NSNumber *weight = [NSNumber numberWithDouble: realizedChain.weightArrays[exerciseIndex].numbers[i].value];
                        NSDate *date = realizedChain.setBeginDateArrays[exerciseIndex].dates[i].value;
                        
                        TJBRepsWeightRecordPair *currentRecordForPrescribedReps = [self repsWeightRecordPairForNumberOfReps: reps];
                        
                        [self configureRepsWeightRecordPair: currentRecordForPrescribedReps
                                        withCandidateWeight: weight
                                              candidateDate: date];
                        
                    }
                }
            }
        }
    }
}

- (void)instantiateRecordPairsArray{
    
    //// prepare the record pairs array and tracker for subsequent use
    
    NSMutableArray *repsWeightRecordPairs = [[NSMutableArray alloc] init];
    self.repsWeightRecordPairs = repsWeightRecordPairs;
    
}

- (TJBRepsWeightRecordPair *)repsWeightRecordPairForNumberOfReps:(int)reps{
    
    //// returns the TJBRepsWeightRecordPair corresponding to the specified reps
    
    // because I always display records for reps 1 through 12, they're positions in the array are known by definition
    
    if (reps == 0){
        
        return nil;
        
    }
    
        // create the record pair for the new reps number and assign it appropriate values.  Configure the tracker array as well
        
        int limit = (int)[self.repsWeightRecordPairs count];
        NSNumber *extractedPairReps;
        
        for (int i = 0; i < limit; i++){
            
            extractedPairReps = self.repsWeightRecordPairs[i].reps;
            int extractedPairRepsAsInt = [extractedPairReps intValue];
            
            if (extractedPairRepsAsInt == reps){
                
                return self.repsWeightRecordPairs[i];
                
            } else if(extractedPairRepsAsInt < reps){
                
                continue;
                
            } else if(extractedPairRepsAsInt > reps){
                
                TJBRepsWeightRecordPair *newPair = [[TJBRepsWeightRecordPair alloc] initDefaultObjectWithReps: reps];
                
                [self.repsWeightRecordPairs insertObject: newPair
                                                 atIndex: i];
                
                return newPair;
                
            }
            
        }
    
        // control only reaches this point if the collection array has length zero because no pairs yet exist
    
        TJBRepsWeightRecordPair *newPair = [[TJBRepsWeightRecordPair alloc] initDefaultObjectWithReps: reps];
        
        [self.repsWeightRecordPairs addObject: newPair];
        
        return newPair;
    
    
}

- (void)configureRepsWeightRecordPair:(TJBRepsWeightRecordPair *)recordPair withCandidateWeight:(NSNumber *)weight candidateDate:(NSDate *)date{
    
    BOOL currentRecordIsDefaultObject = [recordPair.isDefaultObject boolValue];
    
    if (!currentRecordIsDefaultObject){
        
        BOOL newWeightIsANewRecord = [weight doubleValue] > [recordPair.weight doubleValue];
        
        if (newWeightIsANewRecord){
            
            recordPair.weight = weight;
            recordPair.date = date;
            recordPair.isDefaultObject = [NSNumber numberWithBool: NO];
            
        }
        
    } else{
        
        recordPair.weight = weight;
        recordPair.date = date;
        recordPair.isDefaultObject = [NSNumber numberWithBool: NO];
        
    }
    
}

- (NSArray<NSNumber *> *)indicesContainingExercise:(TJBExercise *)exercise forRealizedChain:(TJBRealizedChain *)realizedChain{
    
    int limit = realizedChain.numberOfExercises;
    
    NSMutableArray *collector = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < limit; i++){
        
        BOOL currentIndexContainsTargetedExercise = [realizedChain.exercises[i] isEqual: exercise];
        
        if (currentIndexContainsTargetedExercise){
            
            NSNumber *number = [NSNumber numberWithInt: i];
            
            [collector addObject: number];
            
        }
        
    }
    
    return collector;
    
}

#pragma mark - Core Data

- (void)coreDataDidUpdate{
    
    [self fetchManagedObjectsAndDetermineRecordsForActiveExercise];
    
    [self.personalRecordsTableView reloadData];
    
}

@end


















































