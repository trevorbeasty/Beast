//
//  TJBRealizedSetActiveEntryVC.m
//  Beast
//
//  Created by Trevor Beasty on 12/8/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import "TJBRealizedSetActiveEntryVC.h"

#import "TJBRealizedSet+CoreDataProperties.h"


#import "TJBNewExerciseCreationVC.h"
//#import "TJBInSetVC.h"

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
#import "TJBWorkoutLogTitleCell.h"
#import "TJBNoDataCell.h"

// selection vc's

#import "TJBExerciseSelectionScene.h"
#import "TJBNumberSelectionVC.h"
#import "TJBWeightRepsSelectionVC.h"


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
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UIButton *alertTimingButton;
@property (weak, nonatomic) IBOutlet UILabel *alertTimingLabel;
@property (weak, nonatomic) IBOutlet UILabel *exerciseLabel;
@property (weak, nonatomic) IBOutlet UIButton *exerciseButton;
@property (weak, nonatomic) IBOutlet UILabel *targetRestLabel;
@property (weak, nonatomic) IBOutlet UITableView *personalRecordsTableView;
@property (weak, nonatomic) IBOutlet UIView *shadowView;
@property (weak, nonatomic) IBOutlet UILabel *largeStatusLabel;
@property (weak, nonatomic) IBOutlet UIView *grayBackdropView;
@property (weak, nonatomic) IBOutlet UILabel *setStartTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *setEndTimeLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *setStartTimeSegmentedControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *setEndTimeSegmentedControl;
@property (weak, nonatomic) IBOutlet UILabel *trackSetLengthLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *trackSetLengthSegmentedControl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *buttonsContainerConstraint;
@property (weak, nonatomic) IBOutlet UIView *titleLabelsContainer;
@property (weak, nonatomic) IBOutlet UIButton *advancedOptionsButton;


// IBAction

- (IBAction)didPressBeginNextSet:(id)sender;
- (IBAction)didPressTargetRestButton:(id)sender;
- (IBAction)didPressAlertTimingButton:(id)sender;
- (IBAction)didPressExerciseButton:(id)sender;
- (IBAction)didPressAdvancedOptions:(id)sender;


//// core data

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

// two fetches are required - realized chain and realized set.  The results are stored for each.  Because fetched results are not being directly fed into a table view, NSFetchedResultsController is not used

@property (nonatomic, strong) NSArray *realizedSetFetchResults;
@property (nonatomic, strong) NSArray *realizedChainFetchResults;

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

//// timer and target rest time

@property (nonatomic, strong) UIView *whiteoutView;

@property (nonatomic, strong) NSDate *lastPrimaryTimerUpdateDate;
@property (nonatomic, strong) NSDate *lastSecondaryTimerUpdateDate;

// for timer recovery

@property (nonatomic, strong) NSDate *timerUpdateDateForRecovery;
@property (nonatomic, strong) NSNumber *timerValueForRecovery;

////

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
    
    [self configureNavigationBar];
    
    [self addAppropriateStopwatchObservers];
    
    [self configureTableView];
    
    [self viewAesthetics];
    
    [self configureTableShadow];
    
    [self configureStartingDisplayValues];
    
    [self configureSegmentedControls];
    
    [self configureButtonControlStartingState];
    
}

- (void)configureButtonControlStartingState{
    
    [self.view insertSubview: self.titleLabelsContainer
                belowSubview: self.navigationBar];
    
    [self.view insertSubview: self.grayBackdropView
                belowSubview: self.titleLabelsContainer];
    
    self.buttonsContainerConstraint.constant = -1 * slidingHeight;
    
}

- (void)configureSegmentedControls{
    
    [self.trackSetLengthSegmentedControl addTarget: self
                                            action: @selector(trackSetLengthSCValueChanged)
                                  forControlEvents: UIControlEventValueChanged];
    
    // because the 'track set length' control starts in the NO position, the 'set begin timing' control must be disabled - set begin times are not recorded when 'track set length' is no, so it would make no sense to allow for options to further specify how to record the set start time
    
    self.setStartTimeSegmentedControl.enabled = NO;
    
}

- (void)configureStartingDisplayValues{
    
    if (self.trackSetLengthSegmentedControl.selectedSegmentIndex == 0){
        
        self.largeStatusLabel.text = @"";
        [self.beginNextSetButton setTitle: @"Set Completed"
                                 forState: UIControlStateNormal];
        
    }
    
}

- (void)configureTableShadow{
    
    UIView *shadowView = self.shadowView;
    shadowView.backgroundColor = [UIColor clearColor];
    shadowView.clipsToBounds = NO;
    
    CALayer *shadowLayer = shadowView.layer;
    shadowLayer.masksToBounds = NO;
    shadowLayer.shadowColor = [UIColor darkGrayColor].CGColor;
    shadowLayer.shadowOffset = CGSizeMake(0.0, 3.0);
    shadowLayer.shadowOpacity = 1.0;
    shadowLayer.shadowRadius = 3.0;
    
}



- (void)configureTableView{
    
    UINib *nib = [UINib nibWithNibName: @"TJBPersonalRecordCell"
                                bundle: nil];
    
    [self.personalRecordsTableView registerNib: nib
                        forCellReuseIdentifier: @"PRCell"];
    
    UINib *nib2 = [UINib nibWithNibName: @"TJBWorkoutLogTitleCell"
                                bundle: nil];
    
    [self.personalRecordsTableView registerNib: nib2
                        forCellReuseIdentifier: @"TJBWorkoutLogTitleCell"];
    
    UINib *noDataCell = [UINib nibWithNibName: @"TJBNoDataCell"
                                 bundle: nil];
    
    [self.personalRecordsTableView registerNib: noDataCell
                        forCellReuseIdentifier: @"TJBNoDataCell"];
    
}

- (void)viewAesthetics{
    
    // buttons
    
    NSArray *buttons = @[self.targetRestButton,
                         self.alertTimingButton,
                         self.exerciseButton];
    
    for (UIButton *button in buttons){
        
        button.backgroundColor = [[TJBAestheticsController singleton] blueButtonColor];
        [button setTitleColor: [UIColor whiteColor]
                     forState: UIControlStateNormal];
        button.titleLabel.font = [UIFont boldSystemFontOfSize: 20.0];
        
        CALayer *bl = button.layer;
        bl.masksToBounds = YES;
        bl.cornerRadius = 4.0;
        
    }
    
    self.beginNextSetButton.backgroundColor = [[TJBAestheticsController singleton] blueButtonColor];
    [self.beginNextSetButton setTitleColor: [UIColor whiteColor]
                                  forState: UIControlStateNormal];
    self.beginNextSetButton.titleLabel.font = [UIFont boldSystemFontOfSize: 20.0];
    
    // title labels
    
    NSArray *titleLabels = @[self.largeStatusLabel,
                             self.timerLabel];
    
    for (UILabel *label in titleLabels){
        
        label.backgroundColor = [UIColor darkGrayColor];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont systemFontOfSize: 40.0];
        
    }
    
    // selection row labels
    
    NSArray *rowLabels = @[self.targetRestLabel,
                           self.alertTimingLabel,
                           self.exerciseLabel,
                           self.setStartTimeLabel,
                           self.setEndTimeLabel,
                           self.trackSetLengthLabel];
    
    for (UILabel *label in rowLabels){
        
        label.font = [UIFont boldSystemFontOfSize: 20.0];
        label.textColor = [UIColor whiteColor];
        
    }

    
    // table view
    
    self.personalRecordsTableView.backgroundColor = [[TJBAestheticsController singleton] yellowNotebookColor];
    
    // give the light gray backdrop rounded corners for the bottom two corners.  Must layout views to update autolayout before calling frame
    
    [self.view layoutIfNeeded];
    
    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect: self.grayBackdropView.bounds
                                               byRoundingCorners: (UIRectCornerBottomLeft | UIRectCornerBottomRight)
                                                     cornerRadii: CGSizeMake(8.0, 8.0)];
    
    shapeLayer.path = path.CGPath;
    shapeLayer.frame = self.grayBackdropView.bounds;
    shapeLayer.fillRule = kCAFillRuleNonZero;
    shapeLayer.fillColor = [UIColor redColor].CGColor;
    
    self.grayBackdropView.layer.mask = shapeLayer;

    
    // segmented controls
    
    NSArray *segmentedControls = @[self.setEndTimeSegmentedControl,
                                   self.setStartTimeSegmentedControl,
                                   self.trackSetLengthSegmentedControl];
    for (UISegmentedControl *sc in segmentedControls){
        
        sc.tintColor = [[TJBAestheticsController singleton] blueButtonColor];
        sc.backgroundColor = [UIColor whiteColor];
        
        sc.layer.masksToBounds = YES;
        sc.layer.cornerRadius = 4.0;
        NSDictionary *textDict = [[NSDictionary alloc] initWithObjects: @[[UIFont boldSystemFontOfSize: 12.0]]
                                                               forKeys: @[NSFontAttributeName]];
        [sc setTitleTextAttributes: textDict
                          forState: UIControlStateNormal];
        
    }
    
}


- (void)configureNavigationBar{
    
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle: @"Freeform Lift"];
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle: @"Back"
                                                                      style: UIBarButtonItemStyleDone
                                                                     target: self
                                                                     action: @selector(didPressHome)];
    
    [navItem setLeftBarButtonItem: barButtonItem];
    
    [self.navigationBar setItems: @[navItem]];
    
    // nav bar text
    
    [self.navigationBar setTitleTextAttributes: @{NSFontAttributeName: [UIFont boldSystemFontOfSize: 20.0]}];
    
}

//- (void)fetchCoreDataAndConfigureTableView{
//    
//    // table view reusable cell registration
//    // notification center registration as well
//    
//    [self.exerciseTableView registerClass: [UITableViewCell class]
//                   forCellReuseIdentifier: @"basicCell"];
//    
//    [[NSNotificationCenter defaultCenter] addObserver: self
//                                             selector: @selector(exerciseDataChanged)
//                                                 name: ExerciseDataChanged
//                                               object: nil];
//    
//    // NSFetchedResultsController
//    
//    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName: @"Exercise"];
//    
//    NSPredicate *noPlaceholderExercisesPredicate = [NSPredicate predicateWithFormat: @"category.name != %@",
//                                                    @"Placeholder"];
//    
//    request.predicate = noPlaceholderExercisesPredicate;
//    
//    NSSortDescriptor *nameSort = [NSSortDescriptor sortDescriptorWithKey: @"name"
//                                                               ascending: YES];
//    
//    NSSortDescriptor *categorySort = [NSSortDescriptor sortDescriptorWithKey: @"category.name"
//                                                                   ascending: YES];
//    
//    [request setSortDescriptors: @[categorySort, nameSort]];
//    
//    NSManagedObjectContext *moc = [[CoreDataController singleton] moc];
//    
//    NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest: request
//                                                                          managedObjectContext: moc
//                                                                            sectionNameKeyPath: @"category.name"
//                                                                                     cacheName: nil];
//    
//    frc.delegate = self;
//    
//    self.fetchedResultsController = frc;
//    
//    NSError *error = nil;
//    
//    if (![self.fetchedResultsController performFetch: &error]){
//        
//        NSLog(@"Failed to initialize fetchedResultsController: %@\n%@", [error localizedDescription], [error userInfo]);
//        
//        abort();
//        
//    }
//    
//}

- (void)exerciseDataChanged{
    
    NSError *error = nil;
    
    [self.fetchedResultsController performFetch: &error];
    
//    [self.exerciseTableView reloadData];
    
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
    
    if (!self.repsWeightRecordPairs || self.repsWeightRecordPairs.count == 0){
        
        return 2;
        
    } else{
        
        return self.repsWeightRecordPairs.count + 1;
        
    }

}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == 0){
        
        TJBWorkoutLogTitleCell *cell = [self.personalRecordsTableView dequeueReusableCellWithIdentifier: @"TJBWorkoutLogTitleCell"];
        
        if (self.exercise){
            
            cell.secondaryLabel.text = self.exercise.name;
            
        } else{
            
            cell.secondaryLabel.text = @"Select an exercise";
            
        }
        
        cell.primaryLabel.text = @"Personal Records";
        
        cell.backgroundColor = [UIColor clearColor];
        
        return cell;
        
    } else{
        
        if (!self.repsWeightRecordPairs || self.repsWeightRecordPairs.count == 0){
            
            TJBNoDataCell *cell = [self.personalRecordsTableView dequeueReusableCellWithIdentifier: @"TJBNoDataCell"];
            
            cell.mainLabel.text = @"No Personal Records";
            cell.backgroundColor = [UIColor clearColor];
            
            return cell;
            
        } else{
            
            NSInteger adjustedRowIndex = indexPath.row - 1;
            
            TJBPersonalRecordCell *cell = [self.personalRecordsTableView dequeueReusableCellWithIdentifier: @"PRCell"];
            
            TJBRepsWeightRecordPair *repsWeightRecordPair = self.repsWeightRecordPairs[adjustedRowIndex];
            
            [cell configureWithReps: repsWeightRecordPair.reps
                             weight: repsWeightRecordPair.weight
                               date: repsWeightRecordPair.date];
            
            return cell;
            
        }
        

    }
    
}



#pragma mark - <UITableViewDelegate>

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat titleHeight = 60.0;
    
    if (indexPath.row == 0){
        
        return titleHeight;
        
    } else{
        
        if (!self.repsWeightRecordPairs || self.repsWeightRecordPairs.count ==0){
            
            [self.view layoutIfNeeded];
            
            return self.personalRecordsTableView.frame.size.height - titleHeight;
            
        } else{
            
                return 60;
            
        }
    }
}


#pragma mark - Button Actions

- (void)trackSetLengthSCValueChanged{
    
    if (self.trackSetLengthSegmentedControl.selectedSegmentIndex == 0){
        
        self.largeStatusLabel.text = @"";
        [self.beginNextSetButton setTitle: @"Set Completed"
                                 forState: UIControlStateNormal];
        
        // disable other segmented control as follows logically
        
        self.setStartTimeSegmentedControl.enabled = NO;
        
    } else{
        
        self.largeStatusLabel.text = @"Resting";
        [self.beginNextSetButton setTitle: @"Begin Next Set"
                                 forState: UIControlStateNormal];
        
        // enable other segmented control as follows logically
        
        self.setStartTimeSegmentedControl.enabled = YES;
        
    }
    
}

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
        
        [weakSelf.exerciseButton setTitle: selectedExercise.name
                                 forState: UIControlStateNormal];
        
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

- (IBAction)didPressAdvancedOptions:(id)sender{
    
    if (_advancedOptionsActive == YES){
        
        [self toggleButtonControlsToDefaultDisplay];
        
    } else{
        
        [self toggleButtonControlsToAdvancedDisplay];
        
    }
    
    
    
}

- (void)didPressHome{
    
    [self dismissViewControllerAnimated: NO
                             completion: nil];
    
}

//- (IBAction)addNewExercise:(id)sender{
//    
//    TJBNewExerciseCreationVC *vc = [[TJBNewExerciseCreationVC alloc] init];
//    
//    [self presentViewController: vc
//                       animated: YES
//                     completion: nil];
//    
//}

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
        
        [weakSelf enableAllSegmentedControls];
        
        [weakSelf removeWhiteoutView];
        
        // VC appearance
    
        if (self.trackSetLengthSegmentedControl.selectedSegmentIndex == 1){
            
            self.largeStatusLabel.text = @"Resting";
            
            [self.beginNextSetButton setTitle: @"Begin Next Set"
                                     forState: UIControlStateNormal];
        }
        
        // timer recovery
        
        [weakSelf recoverTimer];
        
        // set necessary parameters to nil to maintain functionality of recursive method here
        
        [weakSelf setRealizedSetParametersToNil];
        
        [weakSelf dismissViewControllerAnimated: NO
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
   
    } else if (!self.timeDelay){
        
        [self disableAllSegmentedControls];
        
        if (self.trackSetLengthSegmentedControl.selectedSegmentIndex == 1 && self.setStartTimeSegmentedControl.selectedSegmentIndex == 1){
            
            NumberSelectedBlockSingle numberSelectedBlock = ^(NSNumber *number){
                
                weakSelf.timeDelay = number;
                weakSelf.setBeginDate = [NSDate dateWithTimeIntervalSinceNow: [number intValue]];
                
                // change display items accordingly
                
                self.largeStatusLabel.text = @"In Set";
                
                [[TJBStopwatch singleton] setPrimaryStopWatchToTimeInSeconds: [number intValue] * -1
                                                     withForwardIncrementing: YES
                                                              lastUpdateDate: nil];
                
                [self.beginNextSetButton setTitle: @"Set Completed"
                                         forState: UIControlStateNormal];
                
                [weakSelf dismissViewControllerAnimated: YES
                                             completion: nil];
        
            };
            
            [self presentNumberSelectionSceneWithNumberType: TimeIntervalSelection
                                             numberMultiple: [NSNumber numberWithInt: 5]
                                                numberLimit: nil
                                                      title: @"Select Delay"
                                                cancelBlock: cancelBlock
                                        numberSelectedBlock: numberSelectedBlock
                                                   animated: YES
                                       modalTransitionStyle: UIModalTransitionStyleCoverVertical];
            
        } else if (self.trackSetLengthSegmentedControl.selectedSegmentIndex == 1 && self.setStartTimeSegmentedControl.selectedSegmentIndex == 0){
            
            self.timeDelay = [NSNumber numberWithInt: 0];
            self.setBeginDate = [NSDate date];
            
            // change display items accordingly
            
            self.largeStatusLabel.text = @"In Set";
            
            [[TJBStopwatch singleton] setPrimaryStopWatchToTimeInSeconds: 0
                                                 withForwardIncrementing: YES
                                                          lastUpdateDate: nil];
            
            [self.beginNextSetButton setTitle: @"Set Completed"
                                     forState: UIControlStateNormal];
            
        } else{
            
            self.timeDelay = [NSNumber numberWithInt: 0];
            self.setBeginDate = nil;
            
            [self didPressBeginNextSet: nil];
            
        }
        
    } else if (!self.timeLag){
        
        if (self.setEndTimeSegmentedControl.selectedSegmentIndex == 1){
            
            NumberSelectedBlockSingle numberSelectedBlock = ^(NSNumber *number){
                
                weakSelf.timeLag = number;
                weakSelf.setEndDate = [NSDate dateWithTimeIntervalSinceNow: [number intValue] * -1];
                
                [[TJBStopwatch singleton] setPrimaryStopWatchToTimeInSeconds: [number intValue]
                                                     withForwardIncrementing: YES
                                                              lastUpdateDate: nil];
                
                [weakSelf dismissViewControllerAnimated: YES
                                             completion: nil];
                
                [weakSelf didPressBeginNextSet: nil];
                
            };
            
            
            
            [self presentNumberSelectionSceneWithNumberType: TimeIntervalSelection
                                             numberMultiple: [NSNumber numberWithInt: 5]
                                                numberLimit: nil
                                                      title: @"Select Lag"
                                                cancelBlock: cancelBlock
                                        numberSelectedBlock: numberSelectedBlock
                                                   animated: YES
                                       modalTransitionStyle: UIModalTransitionStyleCoverVertical];
            
        } else{
            
            self.timeLag = [NSNumber numberWithInt: 0];
            self.setEndDate = [NSDate date];
                
            [[TJBStopwatch singleton] setPrimaryStopWatchToTimeInSeconds: 0
                                                 withForwardIncrementing: YES
                                                          lastUpdateDate: nil];
            
            [weakSelf didPressBeginNextSet: nil];
            
        }
        
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
        
        // give the VC the appropriate appearance according to selected advanced settings
        
        if (self.trackSetLengthSegmentedControl.selectedSegmentIndex == 1){
            
            [self.beginNextSetButton setTitle: @"Begin Next Set"
                                     forState: UIControlStateNormal];
            
            self.largeStatusLabel.text = @"Resting";
            
        } else{
            
            [self.beginNextSetButton setTitle: @"Set Completed"
                                     forState: UIControlStateNormal];
            
            self.largeStatusLabel.text = @"";
            
        }

//        [self presentSubmittedSetSummary];
        [self confirmSubmission];
        
        [self enableAllSegmentedControls];
        
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
    
    // begin and end dates are optional and may not be recorded depending on the user's advanced settings.  BOOLs are non-optional and indicate user selections active during creation of the realized set
    
    // set begin date and associated BOOLs
    
    if (self.trackSetLengthSegmentedControl.selectedSegmentIndex == 1){
        
        realizedSet.beginDate = self.setBeginDate;
        realizedSet.recordedBeginDate = YES;
    
    } else{
        
        realizedSet.recordedBeginDate = NO;
        
    }
    
    if (self.setStartTimeSegmentedControl.selectedSegmentIndex == 1){
        
        realizedSet.exactBeginDate = YES;
        
    } else{
        
        realizedSet.exactBeginDate = NO;
        
    }
    
    // set end date and associated BOOLs
    
    realizedSet.recordedEndDate = YES;
    realizedSet.endDate = self.setEndDate;
    
    if (self.setEndTimeSegmentedControl.selectedSegmentIndex == 1){
        
        realizedSet.exactEndDate = YES;
        
    } else{
        
        realizedSet.exactEndDate = NO;
        
    }
    
    // other
    
    realizedSet.postMortem = postMortem;
    realizedSet.weight = [self.weight floatValue];
    realizedSet.reps = [self.reps floatValue];
    realizedSet.exercise = self.exercise;
    
    [[CoreDataController singleton] saveContext];
    
//    [self.personalRecordVC newSetSubmitted];
    
}

#pragma mark - <NewExerciseCreationDelegate>

- (void)didCreateNewExercise:(TJBExercise *)exercise{
    self.exercise = exercise;
//    [self.navItem setTitle: exercise.name];
    
    NSError *error = nil;
    [self.fetchedResultsController performFetch: &error];
//    [self.exerciseTableView reloadData];
    
    [self dismissViewControllerAnimated: YES
                             completion: nil];
    
//    [self.personalRecordVC didSelectExercise: exercise];
}

#pragma mark - Notification to User

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
    
    [self setRealizedSetParametersToNil];
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
    
    // table view
    
//    CGPoint scrollPosition = self.exerciseTableView.contentOffset;
//    int y = scrollPosition.y;
//    [coder encodeFloat: y
//                forKey: @"scrollYPosition"];
    
//    NSIndexPath *path = self.exerciseTableView.indexPathForSelectedRow;
//    if (path){
//        
//        [coder encodeObject: path
//                     forKey: @"path"];
    
//    }
    
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
    
    // table view
    
//    float y = [coder decodeDoubleForKey: @"scrollYPosition"];
//    self.exerciseTableView.contentOffset = CGPointMake(0, y);
//    
//    NSIndexPath *path = [coder decodeObjectForKey: @"path"];
//    if (path){
//        
//        // artificially make table view selections for state restoration
//        
//        [self.exerciseTableView selectRowAtIndexPath: path
//                                            animated: NO
//                                      scrollPosition: UITableViewScrollPositionNone];
//        [self tableView: self.exerciseTableView didSelectRowAtIndexPath: path];
//        
//        // use the saved path to restore the 'exercise' property
//        
//        TJBExercise *exercise = [self.fetchedResultsController objectAtIndexPath: path];
//        self.exercise = exercise;
//    }
    
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

- (void)primaryTimerDidUpdateWithUpdateDate:(NSDate *)date{
    
    //// store the passed in date
    
    self.lastPrimaryTimerUpdateDate = date;
    
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
        
        [self fetchRealizedSets];
        [self fetchRealizedChains];
        
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


- (void)fetchRealizedSets{
    
    //// fetch the realized set, sorting by both weight and reps to facillitate extraction of personal records
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName: @"RealizedSet"];
    
    NSSortDescriptor *repsSort = [NSSortDescriptor sortDescriptorWithKey: @"reps"
                                                               ascending: YES];
    
    NSSortDescriptor *weightSort = [NSSortDescriptor sortDescriptorWithKey: @"weight"
                                                                 ascending: NO];
    
    NSString *activeExerciseName = self.exercise.name;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"exercise.name = %@", activeExerciseName];
    
    [request setSortDescriptors: @[repsSort, weightSort]];
    request.predicate = predicate;
    
    NSError *error = nil;
    NSArray *fetchResults = [[[CoreDataController singleton] moc] executeFetchRequest: request
                                                                                error: &error];
    self.realizedSetFetchResults = fetchResults;
    
}

- (void)fetchRealizedChains{
    
    //// fetch the realized set, sorting by both weight and reps to facillitate extraction of personal records
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName: @"RealizedChain"];
    
    NSSortDescriptor *dateSort = [NSSortDescriptor sortDescriptorWithKey: @"dateCreated"
                                                               ascending: NO];
    
    [request setSortDescriptors: @[dateSort]];
    
    NSError *error = nil;
    
    NSArray *fetchResults = [[[CoreDataController singleton] moc] executeFetchRequest: request
                                                                                error: &error];
    self.realizedChainFetchResults = fetchResults;
    
}

- (TJBRepsWeightRecordPair *)repsWeightRecordPairForNumberOfReps:(int)reps{
    
    //// returns the TJBRepsWeightRecordPair corresponding to the specified reps
    
    // because I always display records for reps 1 through 12, they're positions in the array are known by definition
    
    if (reps == 0){
        
        return nil;
        
    }
    
//    BOOL repsWithinStaticRange = reps <= 12;
//    
//    if (repsWithinStaticRange){
//        
//        return self.repsWeightRecordPairs[reps - 1];
//        
//    }
//    else{
    
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

#pragma mark - Convenience

- (void)disableAllSegmentedControls{
    
    NSArray *segmentedControls = @[self.trackSetLengthSegmentedControl,
                                   self.setStartTimeSegmentedControl,
                                   self.setEndTimeSegmentedControl];
    
    for (UISegmentedControl *sc in segmentedControls){
        
        sc.enabled = NO;
        
    }
    
}

- (void)enableAllSegmentedControls{
    
    NSArray *segmentedControls = @[self.trackSetLengthSegmentedControl,
                                   self.setStartTimeSegmentedControl,
                                   self.setEndTimeSegmentedControl];
    
    for (UISegmentedControl *sc in segmentedControls){
        
        sc.enabled = YES;
        
    }
    
}

#pragma mark - Animation

static CGFloat const slidingHeight = 103;

- (void)toggleButtonControlsToAdvancedDisplay{
    
    [UIView animateWithDuration: .4
                     animations: ^{
                         
                         self.buttonsContainerConstraint.constant = 0;
                         
                         CGRect currentFrame = self.grayBackdropView.frame;
                         CGRect newFrame = CGRectMake(currentFrame.origin.x, currentFrame.origin.y + slidingHeight, currentFrame.size.width, currentFrame.size.height);
                         self.grayBackdropView.frame = newFrame;
                         
                         CGRect currentTVFrame = self.personalRecordsTableView.frame;
                         CGRect newTVFrame = CGRectMake(currentTVFrame.origin.x, currentTVFrame.origin.y + slidingHeight, currentTVFrame.size.width, currentTVFrame.size.height - slidingHeight);
                         self.personalRecordsTableView.frame = newTVFrame;
                         
                     }];
    
    _advancedOptionsActive = YES;
    [self.advancedOptionsButton setTitle: @"- Advanced Options"
                                forState: UIControlStateNormal];
    
}

- (void)toggleButtonControlsToDefaultDisplay{
    
    [UIView animateWithDuration: .4
                     animations: ^{
                         
                         self.buttonsContainerConstraint.constant = -1 * slidingHeight;
                         
                         CGRect currentFrame = self.grayBackdropView.frame;
                         CGRect newFrame = CGRectMake(currentFrame.origin.x, currentFrame.origin.y - slidingHeight, currentFrame.size.width, currentFrame.size.height);
                         self.grayBackdropView.frame = newFrame;
                         
                         CGRect currentTVFrame = self.personalRecordsTableView.frame;
                         CGRect newTVFrame = CGRectMake(currentTVFrame.origin.x, currentTVFrame.origin.y - slidingHeight, currentTVFrame.size.width, currentTVFrame.size.height + slidingHeight);
                         self.personalRecordsTableView.frame = newTVFrame;
                         
                     }];
    
    _advancedOptionsActive = NO;
    [self.advancedOptionsButton setTitle: @"+ Advanced Options"
                                forState: UIControlStateNormal];
    
}

@end


















































