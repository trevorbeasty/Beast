//
//  TJBActiveRoutineGuidanceVC.m
//  Beast
//
//  Created by Trevor Beasty on 2/9/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBActiveRoutineGuidanceVC.h"

// core data

#import "CoreDataController.h"

// child VC's

#import "TJBActiveRoutineExerciseItemVC.h"
#import "TJBActiveRoutineRestItem.h"

// utilities

#import "TJBAssortedUtilities.h"

// number selection

#import "TJBWeightRepsSelectionVC.h"
#import "TJBNumberSelectionVC.h"

// stopwatch

#import "TJBStopwatch.h"
#import "TJBStopwatchObserver.h"

// aesthetics

#import "TJBAestheticsController.h"

// audio - for phone vibrating

#import <AudioToolbox/AudioToolbox.h>

// for dismissing directly back to home screen

#import "TJBWorkoutNavigationHub.h"

// clock

#import "TJBClockConfigurationVC.h"

#import "TJBPreviousMarksDictionary.h" // previous marks
#import "TJBActiveLiftTargetsDictionary.h" // active lift targets

@interface TJBActiveRoutineGuidanceVC () <TJBStopwatchObserver>

{
    
    // state
    
    int _selectionIndex;
    BOOL _advancedControlsActive;
    
    // used for content view creation / configuration
    
    BOOL _isLastExerciseOfRoutine;
    BOOL _showingFirstTargets;
    
}

// IBOutlet

@property (weak, nonatomic) IBOutlet UILabel *timerTitleLabel;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (weak, nonatomic) IBOutlet UIButton *leftBarButton;
@property (weak, nonatomic) IBOutlet UIButton *alertTimingButton;
@property (weak, nonatomic) IBOutlet UILabel *activeRoutineLabel;
@property (weak, nonatomic) IBOutlet UIView *topTitleBar;
@property (weak, nonatomic) IBOutlet UIView *bottomTitleBar;
@property (weak, nonatomic) IBOutlet UILabel *alertValueLabel;

// IBAction

- (IBAction)didPressLeftBarButton:(id)sender;
- (IBAction)didPressClock:(id)sender;

// core

@property (nonatomic, strong) TJBChainTemplate *chainTemplate;

@property (nonatomic, strong) UIView *activeScrollContentView;
@property (nonatomic, strong) UIStackView *guidanceStackView;
@property (nonatomic, strong) NSMutableArray<TJBActiveRoutineExerciseItemVC *> *exerciseItemChildVCs;
@property (nonatomic, strong) TJBActiveRoutineRestItem *restItemChildVC;

// scroll content view

@property (nonatomic, strong) NSMutableDictionary *constraintMapping;

//// state

@property (nonatomic, strong) NSNumber *activeRoundIndexForTargets;
@property (nonatomic, strong) NSNumber *activeExerciseIndexForTargets;

@property (nonatomic, strong) NSNumber *activeRoundIndexForChain;
@property (nonatomic, strong) NSNumber *activeExerciseIndexForChain;

@property (nonatomic, strong) NSMutableArray<TJBActiveLiftTargetsDictionary   *> *activeLiftTargets;
@property (nonatomic, strong) NSMutableArray<NSArray<TJBPreviousMarksDictionary *> *> *activePreviousMarks;
@property (nonatomic, strong) NSNumber *futureRestTarget;
@property (nonatomic, strong) NSNumber *currentRestTarget;

@property (nonatomic, strong) NSNumber *cancelRestorationExerciseIndex;
@property (nonatomic, strong) NSNumber *cancelRestorationRoundIndex;

@property (nonatomic, strong) NSNumber *selectedAlertTiming;


// stopwatch state

@property (nonatomic, strong) NSDate *dateForTimerRecovery;

@end







#pragma mark - Constants



static float const animationTimeUnit = .4;


// header view (describing round and rest in content scroll view)

static CGFloat const headerViewTopLabelHeight = 50;
static CGFloat const headerViewBottomLabelHeight = 50;
static CGFloat const headerViewLabelSpacing = .5;
static CGFloat const headerViewComponentHorizontalInset = 8;
static CGFloat const headerViewTopSpacing = 16;
static CGFloat const componentToComponentSpacing = 16;







@implementation TJBActiveRoutineGuidanceVC

#pragma mark - Instantiation

- (instancetype)initFreshRoutineWithChainTemplate:(TJBChainTemplate *)chainTemplate{
    
    self = [super init];
    
    self.chainTemplate = chainTemplate;
    
    // because it is a fresh routine, give it active round and exercise indices of 0. Also, generate a new, skeleton realized chain
    
    self.activeRoundIndexForTargets = [NSNumber numberWithInt: 0];
    self.activeExerciseIndexForTargets = [NSNumber numberWithInt: 0];
    
    self.activeRoundIndexForChain = [NSNumber numberWithInt: 0];
    self.activeExerciseIndexForChain = [NSNumber numberWithInt: 0];
    
    _selectionIndex = 0;
    
    _isLastExerciseOfRoutine = NO;
    _showingFirstTargets = YES;
    
    self.realizedChain = [[CoreDataController singleton] createAndSaveSkeletonRealizedChainForChainTemplate: chainTemplate];
    
    return self;
    
}

#pragma mark - View Life Cycle

- (void)viewDidLoad{
    
    [self.view layoutIfNeeded];
    
    [self configureViewAesthetics];
    
    [self configureImmediateTargets];
    
    [self configureTimer];
    
    [self configureInitialDisplay];
    
}

- (void)configureTimer{
    
    [[TJBStopwatch singleton] addPrimaryStopwatchObserver: self
                                           withTimerLabel: self.timerTitleLabel];
    
    [[TJBStopwatch singleton] setPrimaryStopWatchToTimeInSeconds: 0
                                         withForwardIncrementing: YES
                                                  lastUpdateDate: nil];
    
}

- (void)configureInitialDisplay{
    
    // detail title label
    
    NSString *exercise;
    NSString *round;
    if (self.chainTemplate.numberOfRounds ==1){
        round = @"round";
    } else{
        round = @"rounds";
    }
    if (self.chainTemplate.numberOfExercises == 1){
        exercise = @"exercise";
    } else{
        exercise = @"exercises";
    }
    
}

- (void)configureImmediateTargets{
    
    // grab all targets and update the view accordingly
    
    //// state
    
    self.currentRestTarget = self.futureRestTarget; // when content is derived, the rest that will be displayed as the first item in the next set of targets is derived. I must give this value a new owner before deriving the next rest target
    
    self.activeLiftTargets = [[NSMutableArray alloc] init];
    self.futureRestTarget = nil;
    self.activePreviousMarks = [[NSMutableArray alloc] init];
    
    [self deriveStateContent];
    
    self.contentScrollView.contentOffset = CGPointMake(0, 0);
    
    UIView *newView;
    
    // if this is the first set of targets, there should be no rest item displayed
    // _showingFirstTargets is set to YES when this VC is initialized
    
    if (_showingFirstTargets){
        
        newView = [self scrollContentViewForTargetArrays_isInitialDisplay: YES];
        
    } else{
        
        newView = [self scrollContentViewForTargetArrays_isInitialDisplay: NO];
        
    }
    
    [UIView transitionWithView: self.contentScrollView
                      duration: animationTimeUnit * 2.0
                       options: UIViewAnimationOptionTransitionCurlDown
                    animations: ^{
                        
                        if (self.activeScrollContentView){
                            
                            [self.activeScrollContentView removeFromSuperview];
                            self.activeScrollContentView = nil;
                            
                        }
                        
                        [self.contentScrollView addSubview: newView];
                        self.activeScrollContentView = newView;
                        
                        self.contentScrollView.hidden = NO;
                        
                    }
                    completion: nil];
    
}

- (void)configureViewAesthetics{
    
    // title bars
    
    self.topTitleBar.backgroundColor = [UIColor darkGrayColor];
    self.bottomTitleBar.backgroundColor = [UIColor darkGrayColor];
    
    self.activeRoutineLabel.backgroundColor = [UIColor clearColor];
    self.activeRoutineLabel.textColor = [UIColor whiteColor];
    self.activeRoutineLabel.font = [UIFont boldSystemFontOfSize: 20];
    
    self.timerTitleLabel.font = [UIFont systemFontOfSize: 35];
    self.timerTitleLabel.backgroundColor = [UIColor darkGrayColor];
    self.timerTitleLabel.textColor = [UIColor whiteColor];
    
    NSArray *titleButtons = @[self.leftBarButton];
    for (UIButton *button in titleButtons){
        
        button.backgroundColor = [UIColor darkGrayColor];
        
    }
    
    // meta view
    
    self.view.backgroundColor = [UIColor blackColor];
    
    // content container
    
    self.contentScrollView.backgroundColor = [[TJBAestheticsController singleton] yellowNotebookColor];
    
    // alert timing controls
    
    NSArray *alertTimingControls = @[self.alertTimingButton];
    for (UIButton *but in alertTimingControls){
        
        but.backgroundColor = [UIColor darkGrayColor];
        [but setTitleColor: [[TJBAestheticsController singleton] titleBarButtonColor]
                  forState: UIControlStateNormal];
        
    }
    
    self.alertTimingButton.titleLabel.font = [UIFont boldSystemFontOfSize: 20];
    
    // alert value label
    
    self.alertValueLabel.backgroundColor = [UIColor clearColor];
    self.alertValueLabel.textColor = [UIColor whiteColor];
    self.alertValueLabel.font = [UIFont systemFontOfSize: 15];
    
}


#pragma mark - Scroll View Content

- (NSArray<TJBPreviousMarksDictionary *> *)extractPreviousMarksArrayForActiveIndices{
    
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    
    int exerciseIndex = [self.activeExerciseIndexForTargets intValue];
    int roundIndex = [self.activeRoundIndexForTargets intValue];
    
    // because a placeholder realized chain is created when a routine is initiated, there will be a realized chain representing the active routine.  It will be the last realized chain and should be ignored in this context
    // I collect them in reverse order so that the exercise item vc gets them with date descending order
    
    NSInteger numberOfValidRealizedChains = self.chainTemplate.realizedChains.count - 1;
    
    for (NSInteger i = numberOfValidRealizedChains - 1; i >= 0; i--){
        
        TJBRealizedChain *iterativeRealizedChain = self.chainTemplate.realizedChains[i];

        // it is possible that in historic realized chains, the user did not complete all sets, so it is necessary to check if a set is null
        
        TJBRealizedSet *rs = iterativeRealizedChain.realizedSetCollections[exerciseIndex].realizedSets[roundIndex];
        
        BOOL setIsNonnull = rs.holdsNullValues == NO;
        
        if ( setIsNonnull){
            
            NSNumber *weight = @(rs.submittedWeight);
            NSNumber *reps = @(rs.submittedReps);
            NSDate *date = rs.submissionTime;
            
            TJBPreviousMarksDictionary *pmDict = [[TJBPreviousMarksDictionary alloc] initWithDate: date
                                                                                           weight: weight
                                                                                             reps: reps];
            
            [returnArray addObject: pmDict];
            
        }
    }
    
    return returnArray;
    
}



- (void)deriveStateContent{
    
    // based on the active exercise and round index, give the appropriate content to the state target arrays
    // grab all exercises, beginning with the one corresponding to the active indices, and continuing to grab exercises until the rest is nonzero
    
    TJBActiveLiftTargetsDictionary *targets = [self extractTargetsArrayForActiveIndices];
    [self.activeLiftTargets addObject: targets];
    
    // it is possible that an array of length 0 is assigned to previousMarks.  I must check that the length is greater than zero before adding (if it has no content, I do not want to show it to the user)
    
    NSArray<TJBPreviousMarksDictionary *> *previousMarks = [self extractPreviousMarksArrayForActiveIndices];
    [self.activePreviousMarks addObject: previousMarks];
    
    // if the rest is zero, grab the next set of targets.  Otherwise, continue.  Will use recursion.
    
    BOOL canForwardIncrementIndices = [self incrementActiveIndicesForward];
    
    if (canForwardIncrementIndices){
        
        // the fourth position holds an NSNumber with the target rest value
        
        if ([[targets rest] floatValue] == 0.0){
            
            [self deriveStateContent];
            
        } else{
            
            self.futureRestTarget = [targets rest];
            
        }
        
    } 

}

- (BOOL)incrementActiveIndicesForward{
    
    // the utilities method only returns new indices if they are within the bounds of the number of exercises and rounds
    // I update a variable here that is used to indicate whether the given set is the last for the routine.  This is used in creating the content view
    
    int exerciseIndex = [self.activeExerciseIndexForTargets intValue];
    int roundIndex = [self.activeRoundIndexForTargets intValue];
    
    NSNumber *newExerciseIndex = nil;
    NSNumber *newRoundIndex = nil;
    
    BOOL forwardIndicesExist = [TJBAssortedUtilities nextIndiceValuesForCurrentExerciseIndex: exerciseIndex
                                                                           currentRoundIndex: roundIndex
                                                                            maxExerciseIndex: self.chainTemplate.numberOfExercises - 1
                                                                               maxRoundIndex: self.chainTemplate.numberOfRounds - 1
                                                                      exerciseIndexReference: &newExerciseIndex
                                                                         roundIndexReference: &newRoundIndex];
    
    self.activeExerciseIndexForTargets = newExerciseIndex;
    self.activeRoundIndexForTargets = newRoundIndex;
    
    if (forwardIndicesExist){
    
        return YES;
        
    } else{
        
        _isLastExerciseOfRoutine = YES;
        
        return NO;
        
    }
    
}

- (TJBActiveLiftTargetsDictionary *)extractTargetsArrayForActiveIndices{
    
    int exerciseIndex = [self.activeExerciseIndexForTargets intValue];
    int roundIndex = [self.activeRoundIndexForTargets intValue];
    
    float weight;
    float reps;
    float rest;
    
    TJBExercise *exercise = self.chainTemplate.exercises[exerciseIndex];
    
    TJBTargetUnit *tu = [self targetUnitForExerciseIndex: exerciseIndex
                                              roundIndex: roundIndex];
    
    if (tu.isTargetingWeight){
        
        weight = tu.weightTarget;
        
    } else{
        
        weight = -1.0;
        
    }
    
    if (tu.isTargetingReps){
        
        reps = tu.repsTarget;
        
    } else{
        
        reps = -1.0;
        
    }
    
    if (tu.isTargetingTrailingRest){
        
        rest = tu.trailingRestTarget;
        
    } else{
        
        rest = -1.0;
        
    }
    
    return [[TJBActiveLiftTargetsDictionary alloc] initWithExercise: exercise
                                                             weight: @(weight)
                                                               reps: @(reps)
                                                               rest: @(rest)];;
    
}



static NSString const *nextUpLabelKey = @"nextUpLabel";
static NSString const *guidanceStackViewKey = @"guidanceStackView";
static NSString const *restViewKey = @"restView";

- (UIView *)scrollContentViewForTargetArrays_isInitialDisplay:(BOOL)isInitialContentView{
    
    NSMutableDictionary *constraintMapping = [[NSMutableDictionary alloc] init];
    NSString *descendingTopViewKey;
    CGFloat heightSum = 0;
    
    UIView *containerView = [[UIView alloc] init];
    containerView.backgroundColor = [[TJBAestheticsController singleton] yellowNotebookColor];
    
    // header view describing round and rest
    
    NSString *restText;
    
    if (!isInitialContentView){
        
        if ([self.currentRestTarget floatValue] < 0.0){
            
            restText = @"Rest until ready";
            
        } else{
            
            NSString *formattedRest = [[TJBStopwatch singleton] minutesAndSecondsStringFromNumberOfSeconds: [self.currentRestTarget intValue]];
            restText = [NSString stringWithFormat: @"Rest for %@", formattedRest];
            
        }
        
    } else{
        
        restText = @"Begin when ready";
        
    }
    
    NSNumber *currentRound = self.activeRoundIndexForChain;
    NSNumber *totalNumberOfRounds = @(self.chainTemplate.numberOfRounds);
    NSString *roundText = [NSString stringWithFormat: @"Round %@ / %@",
                           [currentRound stringValue],
                           [totalNumberOfRounds stringValue]];
    
    UIView *headerView = [self headerViewWithRoundText: roundText
                                              restText: restText];
    [containerView addSubview: headerView];
    
    NSString *headerViewKey = @"headerView";
    [constraintMapping setObject: headerView
                          forKey: headerViewKey];
    headerView.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSString *headerComponentHorzVFLString = [NSString stringWithFormat: @"H:|-%f-[%@]-%f-|",
                                              headerViewComponentHorizontalInset,
                                              headerViewKey,
                                              headerViewComponentHorizontalInset];
    
    [containerView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: headerComponentHorzVFLString
                                                                          options: 0
                                                                          metrics: nil
                                                                            views: constraintMapping]];
    
    CGFloat totalHeaderComponentHeight = headerViewBottomLabelHeight + headerViewLabelSpacing + headerViewTopLabelHeight;
    NSString *headerComponentVertVFLString = [NSString stringWithFormat: @"V:|-%f-[%@(==%f)]",
                                              headerViewTopSpacing,
                                              headerViewKey,
                                              totalHeaderComponentHeight];
    
    [containerView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: headerComponentVertVFLString
                                                                          options: 0
                                                                          metrics: nil
                                                                            views: constraintMapping]];
    
    heightSum += totalHeaderComponentHeight + headerViewTopSpacing;
    
    // add previous marks content views
    
    descendingTopViewKey = headerViewKey;
    
    for (int i = 0; i < self.activeLiftTargets.count; i++){
        
        // grab the info necessary for creating the exercise item VC
        
        TJBActiveLiftTargetsDictionary *iterativeLiftTargets = self.activeLiftTargets[i];
        
        NSString *titleNumber = [NSString stringWithFormat: @"%d", i + 1];
        TJBExercise *exercise = [iterativeLiftTargets exercise];
        NSString *weightString = [self valueOrXFromNumber: [iterativeLiftTargets weight]];
        NSString *repsString = [self valueOrXFromNumber: [iterativeLiftTargets reps]];
    
        NSArray<TJBPreviousMarksDictionary *> *previousEntries = self.activePreviousMarks[i];
        
        TJBActiveRoutineExerciseItemVC *exerciseItemVC = [[TJBActiveRoutineExerciseItemVC alloc] initWithTitleNumber: titleNumber
                                                                                                  targetExerciseName: exercise.name
                                                                                                        targetWeight: weightString
                                                                                                          targetReps: repsString
                                                                                                     previousEntries: previousEntries];
        
        exerciseItemVC.view.translatesAutoresizingMaskIntoConstraints = NO;
        
        
        [self addChildViewController: exerciseItemVC];
        [containerView addSubview: exerciseItemVC.view];
        [exerciseItemVC didMoveToParentViewController: self];
        
        CGFloat exerciseComponentHeight = [exerciseItemVC suggestedHeight];
        NSString *exerciseComponentKey = [self dynamicExerciseComponentKeyForIndex: i];
        [constraintMapping setObject: exerciseItemVC.view
                              forKey: exerciseComponentKey];
        
        NSString *vertVFL = [self verticalVFLStringForTopViewKey: descendingTopViewKey
                                                   bottomViewKey: exerciseComponentKey
                                                         spacing: componentToComponentSpacing
                                                bottomViewHeight: exerciseComponentHeight];
        
        [containerView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: vertVFL
                                                                              options: 0
                                                                              metrics: nil
                                                                                views: constraintMapping]];
        
        NSString *horzVFL = [self fillSuperViewWidthVFLStringForViewKey: exerciseComponentKey];
        [containerView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: horzVFL
                                                                               options: 0
                                                                               metrics: nil
                                                                                 views: constraintMapping]];
        
        descendingTopViewKey = exerciseComponentKey;
        heightSum += exerciseComponentHeight + componentToComponentSpacing;
        
    }
    
    // stopwatch config
    
    [self configureStopwatchBasedOnCurrentTargets];
    
    [self.view layoutSubviews];
    CGFloat width = self.contentScrollView.frame.size.width;
    
    [containerView setFrame: CGRectMake(0, 0, width, heightSum)];
    [self.contentScrollView setContentSize: CGSizeMake(width, heightSum)];
    
    return containerView;
    
}

- (void)configureStopwatchBasedOnCurrentTargets{
    
    TJBStopwatch *stopwatch = [TJBStopwatch singleton];
    
    // reset timer
    
    [stopwatch setPrimaryStopWatchToTimeInSeconds: 0
                          withForwardIncrementing: YES
                                   lastUpdateDate: nil];
    
    // configure stopwatch based on current rest target
    // if rest is not being targeted, a value of -1 is held as the active rest target
    // do not set the stopwatch rest target when rest is not being targeted
    
    if ([self.currentRestTarget floatValue] >= 0.0){
        
        stopwatch.targetRest = self.currentRestTarget;
        
    }

    [stopwatch scheduleAlertBasedOnUserPermissions];
    
    // update alertValueLabel to reflect stopwatch parameters
    
    self.alertValueLabel.text = [stopwatch alertTextFromTargetValues];
    
}

#pragma mark - Visual Content Helper Methods

- (NSString *)dynamicExerciseComponentKeyForIndex:(int)index{
    
    return  [NSString stringWithFormat: @"exerciseComponent%d", index + 1];
    
}

- (NSString *)verticalVFLStringForTopViewKey:(NSString *)topViewKey bottomViewKey:(NSString *)bottomViewKey spacing:(CGFloat)spacing bottomViewHeight:(CGFloat)bottomViewHeight{
    
    return [NSString stringWithFormat: @"V:[%@]-%f-[%@(==%f)]",
            topViewKey,
            spacing,
            bottomViewKey,
            bottomViewHeight];
    
}

- (UIView *)headerViewWithRoundText:(NSString *)roundText restText:(NSString *)restText{
    
    UIView *container = [[UIView alloc] init];
    
    UILabel *topLabel = [[UILabel alloc] init];
    UILabel *bottomLabel = [[UILabel alloc] init];
    
    // view hieararchy and constraints
    
    topLabel.translatesAutoresizingMaskIntoConstraints = NO;
    bottomLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    [container addSubview: topLabel];
    [container addSubview: bottomLabel];
    
    NSMutableDictionary *constraintMapping = [[NSMutableDictionary alloc] init];
    NSString *topLabelKey = @"topLabel";
    NSString *bottomLabelKey = @"bottomLabel";
    [constraintMapping setObject: topLabel
                          forKey: topLabelKey];
    [constraintMapping setObject: bottomLabel
                          forKey: bottomLabelKey];
    
    NSArray *labelKeys = @[topLabelKey, bottomLabelKey];
    for (NSString *labelKey in labelKeys){
        
        [container addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: [self fillSuperViewWidthVFLStringForViewKey: labelKey]
                                                                           options: 0
                                                                           metrics: nil
                                                                             views: constraintMapping]];
        
    }
    
    NSString *vertVFLString = [NSString stringWithFormat: @"V:|-0-[%@(==%f)]-%f-[%@(==%f)]",
                               topLabelKey,
                               headerViewTopLabelHeight,
                               headerViewLabelSpacing,
                               bottomLabelKey,
                               headerViewBottomLabelHeight];
    
    [container addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: vertVFLString
                                                                      options: 0
                                                                      metrics: nil
                                                                        views: constraintMapping]];
    
    // label detail
    
    NSArray *labels = @[topLabel, bottomLabel];
    for (UILabel *l in labels){
        
        l.backgroundColor = [UIColor grayColor];
        l.textColor = [UIColor whiteColor];
        l.font = [UIFont boldSystemFontOfSize: 20];
        l.textAlignment = NSTextAlignmentCenter;
        l.numberOfLines = 0;
        l.lineBreakMode = NSLineBreakByWordWrapping;
        
    }
    
    topLabel.text = roundText;
    bottomLabel.text = restText;
    
    container.backgroundColor = [UIColor blackColor];
    CALayer *containerLayer = container.layer;
    containerLayer.masksToBounds = YES;
    containerLayer.cornerRadius = 4;
    
    return container;
    
    
}

- (NSString *)fillSuperViewWidthVFLStringForViewKey:(NSString *)viewKey{
    
    
    return [NSString stringWithFormat: @"H:|-0-[%@]-0-|", viewKey];
    
}

- (NSString *)valueOrXFromNumber:(NSNumber *)number{
    
    // returns the number as a string if it is positive and X otherwise
    // the convention here is that a value of negative one is assigned to weight or reps when it is not being targeted
    
    if ([number floatValue] >= 0){
        
        return  [number stringValue];
        
    } else{
        
        return @"X";
        
    }
    
}


#pragma mark - Button Actions

- (IBAction)didPressLeftBarButton:(id)sender{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"Are you sure?"
                                                                   message: @"A routine cannot be resumed after leaving"
                                                            preferredStyle: UIAlertControllerStyleAlert];
    
    UIAlertAction *stayAction = [UIAlertAction actionWithTitle: @"Stay"
                                                         style: UIAlertActionStyleDefault
                                                       handler: nil];
    [alert addAction: stayAction];
    
    __weak TJBActiveRoutineGuidanceVC *weakSelf = self;
    UIAlertAction *leaveAction = [UIAlertAction actionWithTitle: @"Leave"
                                                          style: UIAlertActionStyleDefault
                                                        handler: ^(UIAlertAction *action){
                                                            
                                                            // stopwatch courtesty
                                                            
                                                            [[TJBStopwatch singleton] resetAndPausePrimaryTimer];
                                                            [[TJBStopwatch singleton] removePrimaryStopwatchObserver: weakSelf.timerTitleLabel];
                                                            
                                                            UIViewController *homeVC = [[[[UIApplication sharedApplication] delegate] window] rootViewController];
                                                            
                                                            [homeVC dismissViewControllerAnimated: YES
                                                                                       completion: nil];
                                                            

                                                            
                                                            // disassociate with the timer
                                                            
                                                            [[TJBStopwatch singleton] removeAllPrimaryStopwatchObservers];
                                                            
                                                        }];
    [alert addAction: leaveAction];
    
    [self presentViewController: alert
                       animated: YES
                     completion: nil];
    
}



- (IBAction)didPressSetCompleted:(UIButton *)didPressSetCompleted{
    
    __weak TJBActiveRoutineGuidanceVC *weakSelf = self;
    
    // record first incomplete indices in case cancel block in called.  If cancel block is called, I will simply change the 'first incomplete' type properties of the realized chain.  I will not change the 'isDefaultObject' property of the weights, reps, and dates that may have been recorded.  I may have to change this later given broader system considerations
    // the cancellation restoration exercise and round objects should only exist during the selection process, they should otherwise be nil
    
    if (!self.cancelRestorationExerciseIndex){
        self.cancelRestorationExerciseIndex = self.activeExerciseIndexForChain;
    }
    
    if (!self.cancelRestorationRoundIndex){
        self.cancelRestorationRoundIndex = self.activeRoundIndexForChain;
    }
    
    NSString *title = [[self.activeLiftTargets[_selectionIndex] exercise] name];
        
    // cancel block
        
    void (^cancelBlock)(void) = ^{
        
        [weakSelf resetRealizedChainWithRespectToImmediateSelections];
        
        [weakSelf dismissViewControllerAnimated: NO
                                     completion: nil];
        
    };
    
    // number selected block
        
    NumberSelectedBlockDouble selectedBlock = ^(NSNumber *weight, NSNumber *reps){
            
        // fill in the realized chain with the selected values
            
        int exercise = [weakSelf.activeExerciseIndexForChain intValue];
        int round = [weakSelf.activeRoundIndexForChain intValue];
        
        TJBRealizedSet *rs = [weakSelf realizedSetForExerciseIndex: exercise
                                                        roundIndex: round];
        
        rs.submittedWeight = [weight floatValue];
        rs.submittedReps = [reps floatValue];
        rs.holdsNullValues = NO;
        rs.exerciseIndex = exercise;
        rs.roundIndex = round;
        rs.submissionTime = [NSDate date];
        rs.isStandaloneSet = NO;
        
        // increment the chain indices.  The first incomplete type properties of the realized chain are updated in the following method
            
        BOOL routineNotCompleted = [self incrementActiveChainIndices];
            
        // save the changes - this must be done after incrementing because 'incrementActiveChainIndices' is where the 'first incomplete' type properties are updated for the realized chain
            
        [[CoreDataController singleton] saveContext];
            
        // if the iterator has reached its max value (all selections have been made), refresh the timer and active scroll view content
        // must check that this is not the very last item in the chain
            
        if ([weakSelf allSelectionsMade]){
                
            if (routineNotCompleted){
                    
                _selectionIndex = 0;
                
                [weakSelf dismissViewControllerAnimated: YES
                                             completion: nil];
                
                // this is where the views are updated to reflect new targets. Must ensure the current run loop finishes before calling this next method so that the next method's animation is properly displayed (views only redraw when the run-loop finishes, and thus one must allow the run loop to finish in order to display some interim state
                
                self.contentScrollView.hidden = YES;
                
                self.timerTitleLabel.backgroundColor = [UIColor darkGrayColor];
                
                [weakSelf performSelector: @selector(showNextSetOfTargets)
                               withObject: nil
                               afterDelay: .25];
        
            } else{
                    
                // configure labels accordingly
                    
                weakSelf.timerTitleLabel.text = @"";
                [[TJBStopwatch singleton] removeAllPrimaryStopwatchObservers];
                
                // alert and dismissal
                
                [weakSelf dismissViewControllerAnimated: YES
                                         completion: nil];
                
                UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"Routine Completed"
                                                                               message: @""
                                                                        preferredStyle: UIAlertControllerStyleAlert];
                UIAlertAction *action = [UIAlertAction actionWithTitle: @"Continue"
                                                                 style: UIAlertActionStyleDefault
                                                               handler:  ^(UIAlertAction *action){
                                                                   
                                                                   // stopwatch courtesty
                                                                   
                                                                   [[TJBStopwatch singleton] resetAndPausePrimaryTimer];
                                                                   [[TJBStopwatch singleton] removePrimaryStopwatchObserver: self.timerTitleLabel];
                                                                   
                                                                   [[[[[UIApplication sharedApplication] delegate] window] rootViewController] dismissViewControllerAnimated: YES
                                                                                                                                                                  completion: nil];
                                                                   
                                                                   }];
                [alert addAction: action];
                    
                [weakSelf presentViewController: alert
                                   animated: YES
                                 completion: nil];
                    
                    
                    
            }
                
        } else{
                
            _selectionIndex++;
                
            [weakSelf dismissViewControllerAnimated: YES
                                        completion: ^{
                                             
                                            [weakSelf didPressSetCompleted: nil];
                                             
                                        }];
                
        }
        
    };
    
    // number selection vc
    
    TJBWeightRepsSelectionVC *selectionVC = [[TJBWeightRepsSelectionVC alloc] initWithTitle: title
                                                                                cancelBlock: cancelBlock
                                                                        numberSelectedBlock: selectedBlock];
        
    [self presentViewController: selectionVC
                       animated: YES
                     completion: nil];
    
}

- (void)resetRealizedChainWithRespectToImmediateSelections{
    
    // must delete the cancellation exercise and round state objects.  Must also reset the first incomplete type properties of the realized chain
    // must also reset the _selectionIndex to 0 (used by the setCompleted method to iterate through all active, immediate targets)
    
    _selectionIndex = 0;
    
    self.realizedChain.firstIncompleteRoundIndex = [self.cancelRestorationRoundIndex intValue];
    self.realizedChain.firstIncompleteExerciseIndex = [self.cancelRestorationExerciseIndex intValue];
    
    self.cancelRestorationRoundIndex = nil;
    self.cancelRestorationExerciseIndex = nil;
    
}


- (IBAction)didPressAlertTimingButton:(id)sender{
    
//    // present the rest selection scene and store the selected number in the appropriate state variable
//    
//    __weak TJBActiveRoutineGuidanceVC *weakSelf = self;
//    
//    CancelBlock cancelBlock = ^{
//        
//        [weakSelf dismissViewControllerAnimated: NO
//                                     completion: nil];
//        
//    };
//    
//    NumberSelectedBlockSingle numberSelectedBlock = ^(NSNumber *number){
//        
//        weakSelf.selectedAlertTiming = number;
//        
//        NSString *text = [[TJBStopwatch singleton] minutesAndSecondsStringFromNumberOfSeconds: [number intValue]];
//        [weakSelf.alertTimingButton setTitle: text
//                                    forState: UIControlStateNormal];
//        
//        [weakSelf dismissViewControllerAnimated: NO
//                                     completion: nil];
//        
//    };
//    
//    TJBNumberSelectionVC *vc = [[TJBNumberSelectionVC alloc] initWithNumberTypeIdentifier: TimeIntervalSelection
//                                                                                    title: @"Select Alert Timing"
//                                                                              cancelBlock: cancelBlock
//                                                                      numberSelectedBlock: numberSelectedBlock];
//    
//    [self presentViewController: vc
//                       animated: YES
//                     completion: nil];
    
}



- (BOOL)allSelectionsMade{
    
    // if the target and chain indices are equivalent, then all selections have been made
    
    BOOL exerciseSame = [self.activeExerciseIndexForTargets intValue] == [self.activeExerciseIndexForChain intValue];
    BOOL roundSame = [self.activeRoundIndexForTargets intValue] == [self.activeRoundIndexForChain intValue];
    
    return exerciseSame && roundSame;
    
}

- (BOOL)incrementActiveChainIndices{
    
    //// increment the indices and also update the first incomplete indices of the realized chain
    
    int exerciseIndex = [self.activeExerciseIndexForChain intValue];
    int roundIndex = [self.activeRoundIndexForChain intValue];
    
    NSNumber *newExerciseIndex = nil;
    NSNumber *newRoundIndex = nil;
    
    BOOL forwardIndicesExist = [TJBAssortedUtilities nextIndiceValuesForCurrentExerciseIndex: exerciseIndex
                                                                           currentRoundIndex: roundIndex
                                                                            maxExerciseIndex: self.chainTemplate.numberOfExercises - 1
                                                                               maxRoundIndex: self.chainTemplate.numberOfRounds - 1
                                                                      exerciseIndexReference: &newExerciseIndex
                                                                         roundIndexReference: &newRoundIndex];
    
    self.realizedChain.firstIncompleteRoundIndex = [newRoundIndex intValue];
    self.realizedChain.firstIncompleteExerciseIndex = [newExerciseIndex intValue];
    
    [[CoreDataController singleton] saveContext];
    
    self.activeExerciseIndexForChain = newExerciseIndex;
    self.activeRoundIndexForChain = newRoundIndex;
    
    if (forwardIndicesExist){
        
        return YES;
        
    } else{
        
        return NO;
        
    }
    

    
}

#pragma mark - <TJBStopwatchObserver>

- (void)primaryTimerDidUpdateWithUpdateDate:(NSDate *)date timerValue:(float)timerValue{
    
    self.dateForTimerRecovery = date;
    
    // if an alert timing has been selected, compare the timer value to the alert value
    
    if (self.selectedAlertTiming){
        
        BOOL inRedZone = [self.selectedAlertTiming floatValue] >= timerValue;
        
        float alertValue = [self.selectedAlertTiming floatValue];
        
        if (inRedZone){
            
            self.timerTitleLabel.backgroundColor = [UIColor redColor];
            
        } else{
            
            self.timerTitleLabel.backgroundColor = [UIColor darkGrayColor];
            
        }
        
        // because the stopwatch observer methods are sent every .1 seconds, the if structure must seek to match timer values over a span of .1 seconds.  Any less of a span might miss the vibration call, and any more may cause it to vibrate twice
        
        // the following is called three times so that the phone vibrates a total of three times.  The vibrate calls are spaced at equal intervals
        
        // this observer method is stilled called when an alternate scene is being presented
        
        if (timerValue <= alertValue + .25 && timerValue > alertValue + .15){
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        }
        
        if (timerValue <= alertValue - .15 && timerValue > alertValue - .25){
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        }
        
        if (timerValue <= alertValue - .55 && timerValue > alertValue - .65){
            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
        }
        
    }
}

- (void)secondaryTimerDidUpdateWithUpdateDate:(NSDate *)date{
    
    
    
}



#pragma mark - New Content Animation

- (void)showNextSetOfTargets{
    
    _showingFirstTargets = NO;
    
    // this method derives and displays the new targets. The transition to the new targets is animated to make it apparent to the user that a change has occurred
    // timer
    
//    [[TJBStopwatch singleton] setPrimaryStopWatchToTimeInSeconds: [self.futureRestTarget intValue]
//                                         withForwardIncrementing: YES
//                                                  lastUpdateDate: nil];
    
    // give the timer non red zone colors
    
//    self.timerTitleLabel.backgroundColor = [UIColor darkGrayColor];
    
    // animate the timer and round label changes - they fly out to the sides, have their values updated, and fly back in
    
//    [self roundRestLabelAnimation];
    
    // nullify the cancellation restoration exercise index and round index
    
    self.cancelRestorationExerciseIndex = nil;
    self.cancelRestorationRoundIndex = nil;
    
    // next animation
    
    [self performSelector: @selector(configureImmediateTargets)
               withObject: nil
               afterDelay: animationTimeUnit * 2.0];
    
}


- (void)roundRestLabelAnimation{
    
    // the new text to be displayed for the timer and round label
//    
//    NSString *newTimerText = [[TJBStopwatch singleton] minutesAndSecondsStringFromNumberOfSeconds: [self.currentRestTarget intValue]];
//    
//    
//    
//    NSString *newRoundText = [NSString stringWithFormat: @"%d/%d",
//                              [self.activeRoundIndexForTargets intValue] + 1,
//                              self.chainTemplate.numberOfRounds];
//    
//    // animation - fly the labels offscreen horizontally and then fly them back to original positions
//    
//    // must make the gap between the labels equal to the screen width and change both labels relationship with the screen edge appropriately so that the labels' width is maintained
//    
////    CGFloat buttonWidth = self.roundTitleLabel.bounds.size.width;
//    
//    __weak TJBActiveRoutineGuidanceVC *weakSelf = self;
//    
//    void (^secondAnimation)(void) = ^{
//        
//        [UIView animateWithDuration: animationTimeUnit
//                         animations: ^{
//                             
//                             // shift left
//                             
//                             NSArray *leftShiftViews = @[weakSelf.timerTitleLabel];
//                             
//                             for (UIView *view in leftShiftViews){
//                                 
//                                 CGRect viewRect = view.frame;
//                                 
//                                 view.frame = CGRectMake(viewRect.origin.x - buttonWidth, viewRect.origin.y, viewRect.size.width, viewRect.size.height);
//                                 
//                             }
//                             
//                             // shift right
//                             
//                             NSArray *rightShiftViews = @[weakSelf.roundTitleLabel, weakSelf.roundTopLabel];
//                             
//                             for (UIView *view in rightShiftViews){
//                                 
//                                 CGRect viewRect = view.frame;
//                                 
//                                 view.frame = CGRectMake(viewRect.origin.x + buttonWidth, viewRect.origin.y, viewRect.size.width, viewRect.size.height);
//                                 
//                             }
//                             
//                         }
//                         completion: nil];
//        
//    };
//    
//    [UIView animateWithDuration: animationTimeUnit
//                     animations: ^{
//                         
//                         // shift left
//                         
//                         NSArray *leftShiftViews = @[weakSelf.roundTitleLabel, weakSelf.roundTopLabel];
//                         
//                         for (UIView *view in leftShiftViews){
//                             
//                             CGRect viewRect = view.frame;
//                             
//                             view.frame = CGRectMake(viewRect.origin.x - buttonWidth, viewRect.origin.y, viewRect.size.width, viewRect.size.height);
//                             
//                         }
//                         
//                         // shift right
//                         
//                         NSArray *rightShiftViews = @[weakSelf.timerTitleLabel];
//                         
//                         for (UIView *view in rightShiftViews){
//                             
//                             CGRect viewRect = view.frame;
//                             
//                             view.frame = CGRectMake(viewRect.origin.x + buttonWidth, viewRect.origin.y, viewRect.size.width, viewRect.size.height);
//                             
//                         }
//                         
//                     }
//                     completion: ^(BOOL completed){
//                         
//                         weakSelf.roundTitleLabel.text = newRoundText;
//                         weakSelf.timerTitleLabel.text = newTimerText;
//                         
//                         secondAnimation();
//                         
//                     }];
    
}

#pragma mark - Convenience

- (TJBTargetUnit *)targetUnitForExerciseIndex:(int)exerciseIndex roundIndex:(int)roundIndex{
    
    return self.chainTemplate.targetUnitCollections[exerciseIndex].targetUnits[roundIndex];
    
}

- (TJBRealizedSet *)realizedSetForExerciseIndex:(int)exerciseIndex roundIndex:(int)roundIndex{
    
    return self.realizedChain.realizedSetCollections[exerciseIndex].realizedSets[roundIndex];
    
}

#pragma mark - Clock


- (IBAction)didPressClock:(id)sender{
    
    __weak TJBActiveRoutineGuidanceVC *weakSelf = self;
    
    CancelBlock cancelCallback = ^{
        
        [weakSelf dismissViewControllerAnimated: YES
                                     completion: nil];
        
    };
    
    AlertParametersBlock apBlock = ^(NSNumber *targetRest, NSNumber *alertTiming){
        
        // update the stopwatch
        TJBStopwatch *stopwatch = [TJBStopwatch singleton];
        [stopwatch setAlertParameters_targetRest: targetRest
                                     alertTiming: alertTiming];
        [stopwatch scheduleAlertBasedOnUserPermissions];
        
        // update the scheduled alert label
        int alertTimingValue = [targetRest intValue] - [alertTiming intValue];
        NSString *formattedAlertValue = [stopwatch minutesAndSecondsStringFromNumberOfSeconds: alertTimingValue];
        NSString *scheduledAlertString = [NSString stringWithFormat: @"Alert at %@", formattedAlertValue];
        weakSelf.alertValueLabel.text = scheduledAlertString;
        
        [weakSelf dismissViewControllerAnimated: YES
                                     completion: nil];
        
    };
    
    NSLog(@"showing first targets: %d", _showingFirstTargets);
    
    // the user will be allowed to change the rest target only before the routine truly begins.  Once it has begun, rest times are dictated as per user specifications
    // if there is no targeted rest, the user can
    // a value of -1 is held as the rest target when the user is not targeting rest, hence the logic below
    
    BOOL restTargetIsStatic;
    
    if (self.currentRestTarget){
        
        if ([self.currentRestTarget floatValue] < 0.0){
            
            restTargetIsStatic = NO;
            
        } else{
            
            restTargetIsStatic = YES;
            
        }
        
    } else{
        
        restTargetIsStatic = NO;
        
    }
    
    TJBClockConfigurationVC *clockVC = [[TJBClockConfigurationVC alloc] initWithApplyAlertParametersCallback: apBlock
                                                                                              cancelCallback: cancelCallback
                                                                                          restTargetIsStatic: restTargetIsStatic];
    
    [self presentViewController: clockVC
                       animated: YES
                     completion: nil];
    
}

@end



























