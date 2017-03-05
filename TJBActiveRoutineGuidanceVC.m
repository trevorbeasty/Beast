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

@interface TJBActiveRoutineGuidanceVC () <TJBStopwatchObserver>

{
    
    //// state
    
    int _selectionIndex;
    BOOL _advancedControlsActive;
    
    // used for content view creation / configuration
    
    BOOL _isLastExerciseOfRoutine;
    
}

// IBOutlet

@property (weak, nonatomic) IBOutlet UILabel *roundTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timerTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *alertTimingButton;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (weak, nonatomic) IBOutlet UIButton *setCompletedButton;
@property (weak, nonatomic) IBOutlet UILabel *mainTitle;
@property (weak, nonatomic) IBOutlet UIButton *leftBarButton;
@property (weak, nonatomic) IBOutlet UIButton *rightBarButtoon;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *advancedControlsConstraint;
@property (weak, nonatomic) IBOutlet UIView *advancedControlsContainer;
@property (weak, nonatomic) IBOutlet UIView *titleContainer;
@property (weak, nonatomic) IBOutlet UILabel *alertTimingLabel;
@property (weak, nonatomic) IBOutlet UILabel *activeRoutineLabel;
@property (weak, nonatomic) IBOutlet UILabel *roundTopLabel;
@property (weak, nonatomic) IBOutlet UILabel *remainingRestTopLabel;
@property (weak, nonatomic) IBOutlet UILabel *nextUpLabel;

// IBAction

- (IBAction)didPressLeftBarButton:(id)sender;
- (IBAction)didPressSetCompleted:(id)sender;
- (IBAction)didPressRightBarButton:(id)sender;
- (IBAction)didPressAlertTimingButton:(id)sender;


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

@property (nonatomic, strong) NSMutableArray<NSArray *> *activeLiftTargets;
@property (nonatomic, strong) NSMutableArray<NSArray<NSArray *> *> *activePreviousMarks;
@property (nonatomic, strong) NSNumber *activeRestTarget;

@property (nonatomic, strong) NSNumber *cancelRestorationExerciseIndex;
@property (nonatomic, strong) NSNumber *cancelRestorationRoundIndex;

@property (nonatomic, strong) NSNumber *selectedAlertTiming;


// stopwatch state

@property (nonatomic, strong) NSDate *dateForTimerRecovery;

@end

static CGFloat const advancedControlSlidingHeight = 38.0;

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
    
    self.realizedChain = [[CoreDataController singleton] createAndSaveSkeletonRealizedChainForChainTemplate: chainTemplate];
    
    return self;
    
}

#pragma mark - View Life Cycle

- (void)viewDidLoad{
    
    // prep
    
    [self.view layoutIfNeeded];
    
    //
    
    [self setAdvancedControlsToOffPosition];
    
    [self configureViewAesthetics];
    
    [self configureImmediateTargets];
    
    [self configureTimer];
    
    [self configureInitialDisplay];
    
}

- (void)setAdvancedControlsToOffPosition{
    
    self.advancedControlsConstraint.constant = -1 * advancedControlSlidingHeight;
    
    [self.view insertSubview: self.advancedControlsContainer
                belowSubview: self.titleContainer];
    
    _advancedControlsActive = NO;
    
}

- (void)configureTimer{
    
    [[TJBStopwatch singleton] addPrimaryStopwatchObserver: self
                                           withTimerLabel: self.timerTitleLabel];
    
}

- (void)configureInitialDisplay{
    
    //// title labels
    
    self.roundTitleLabel.text = [NSString stringWithFormat: @"1/%d", self.chainTemplate.numberOfRounds];
    self.mainTitle.text = self.chainTemplate.name;
    
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
    
    self.activeLiftTargets = [[NSMutableArray alloc] init];
    self.activeRestTarget = nil;
    self.activePreviousMarks = [[NSMutableArray alloc] init];
    
    [self deriveStateContent];
    
    self.contentScrollView.contentOffset = CGPointMake(0, 0);
    
    UIView *newView = [self scrollContentViewForTargetArrays];
    
    [UIView transitionWithView: self.contentScrollView
                      duration: 1.5
                       options: UIViewAnimationOptionTransitionCurlDown
                    animations: ^{
                        
                        if (self.activeScrollContentView){
                            
                            [self.activeScrollContentView removeFromSuperview];
                            self.activeScrollContentView = nil;
                            
                        }
                        
                        [self.contentScrollView addSubview: newView];
                        self.activeScrollContentView = newView;
                        
                    }
                    completion: nil];
    
}

- (void)configureViewAesthetics{
    
    // next up label
    
    self.nextUpLabel.backgroundColor = [UIColor lightGrayColor];
    self.nextUpLabel.textColor = [UIColor whiteColor];
    self.nextUpLabel.font = [UIFont boldSystemFontOfSize: 20];
    
    NSArray *labels = @[self.roundTitleLabel,
                        self.timerTitleLabel,
                        self.activeRoutineLabel];
    
    for (UILabel *label in labels){
        
        label.backgroundColor = [UIColor darkGrayColor];
        label.font = [UIFont boldSystemFontOfSize: 20.0];
        label.textColor = [UIColor whiteColor];
        
    }
    
    NSArray *smallTextTitles = @[self.mainTitle,
                                 self.roundTopLabel,
                                 self.remainingRestTopLabel];
    for (UILabel *label in smallTextTitles){
        
        label.backgroundColor = [UIColor darkGrayColor];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont boldSystemFontOfSize: 15.0];
        
    }
    
    NSArray *titleButtons = @[self.leftBarButton, self.rightBarButtoon];
    for (UIButton *button in titleButtons){
        
        button.backgroundColor = [UIColor clearColor];
        button.titleLabel.font = [UIFont boldSystemFontOfSize: 15.0];
        [button setTitleColor: [[TJBAestheticsController singleton] blueButtonColor]
                     forState: UIControlStateNormal];
        
    }
    
    self.rightBarButtoon.titleLabel.font = [UIFont boldSystemFontOfSize: 20.0];
    
    // advanced control buttons
    
    self.alertTimingButton.backgroundColor = [[TJBAestheticsController singleton] blueButtonColor];
    self.alertTimingButton.titleLabel.font = [UIFont boldSystemFontOfSize: 20.0];
    [self.alertTimingButton setTitleColor: [UIColor whiteColor]
                                 forState: UIControlStateNormal];
    self.alertTimingButton.layer.masksToBounds = YES;
    self.alertTimingButton.layer.cornerRadius = 4.0;
    
    // advanced control labels
    
    self.alertTimingLabel.font = [UIFont systemFontOfSize: 15.0];
    self.alertTimingLabel.textColor = [UIColor darkGrayColor];
    self.alertTimingLabel.backgroundColor = [UIColor clearColor];
    
    // give the timer labels a red appearance to start
    
    self.timerTitleLabel.backgroundColor = [UIColor redColor];
    self.remainingRestTopLabel.backgroundColor = [UIColor redColor];
    
}

#pragma mark - Scroll View Content

- (NSArray<NSArray *> *)extractPreviousMarksArrayForActiveIndices{
    
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    
    int exerciseIndex = [self.activeExerciseIndexForTargets intValue];
    int roundIndex = [self.activeRoundIndexForTargets intValue];
    
    // because a placeholder realized chain is created when a routine is initiated, there will be a realized chain representing the active routine.  It will be the last realized chain and should be ignored in this context
    // I collect them in reverse order so that the exercise item vc gets them with date descending order
    
    NSInteger numberOfValidRealizedChains = self.chainTemplate.realizedChains.count - 1;
    
    for (NSInteger i = numberOfValidRealizedChains - 1; i >= 0; i--){
        
        NSMutableArray *previousMarksArray = [[NSMutableArray alloc] init];
        
        TJBRealizedChain *iterativeRealizedChain = self.chainTemplate.realizedChains[i];
        
        float weight;
        float reps;
        NSDate *date;
        
        // it is possible that in historic realized chains, the user did not complete all sets.  Must check the 'first incomplete' type properties to check for this.  If the set occurred, weight, reps, and the creation date of the realized chain should be grabbed.  We only need the creation date because we only care to report the day executed to the user, not the rest or in-set time
        
        BOOL setExists = [TJBAssortedUtilities indiceWithExerciseIndex: exerciseIndex
                                                            roundIndex: roundIndex
                                       isPriorToReferenceExerciseIndex: iterativeRealizedChain.firstIncompleteExerciseIndex
                                                   referenceRoundIndex: iterativeRealizedChain.firstIncompleteRoundIndex];
        if (setExists){
            
            weight = iterativeRealizedChain.weightArrays[exerciseIndex].numbers[roundIndex].value;
            reps = iterativeRealizedChain.repsArrays[exerciseIndex].numbers[roundIndex].value;
            date = iterativeRealizedChain.dateCreated;
            
            [previousMarksArray addObject: [NSNumber numberWithFloat: weight]];
            [previousMarksArray addObject: [NSNumber numberWithFloat: reps]];
            [previousMarksArray addObject: date];
            
            [returnArray addObject: previousMarksArray];
            
        }
    }
    
    return returnArray;
    
}

- (void)deriveStateContent{
    
    // based on the active exercise and round index, give the appropriate content to the state target arrays
    // grab all exercises, beginning with the one corresponding to the active indices, and continuing to grab exercises until the rest is nonzero
    
    NSArray *targets = [self extractTargetsArrayForActiveIndices];
    [self.activeLiftTargets addObject: targets];
    
    // it is possible that an array of length 0 is assigned to previousMarks.  I must check that the length is greater than zero before adding (if it has no content, I do not want to show it to the user)
    
    NSArray<NSArray *> *previousMarks = [self extractPreviousMarksArrayForActiveIndices];
    
    if (previousMarks.count > 0){
        
        [self.activePreviousMarks addObject: previousMarks];
        
    }
    
    // if the rest is zero, grab the next set of targets.  Otherwise, continue.  Will use recursion.
    
    BOOL canForwardIncrementIndices = [self incrementActiveIndicesForward];
    
    if (canForwardIncrementIndices){
        
        // the fourth position holds an NSNumber with the target rest value
        
        if ([targets[3] floatValue] == 0.0){
            
            [self deriveStateContent];
            
        } else{
            
            self.activeRestTarget = targets[3];
            
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
    
    if (forwardIndicesExist){
        
        self.activeExerciseIndexForTargets = newExerciseIndex;
        self.activeRoundIndexForTargets = newRoundIndex;
    
        return YES;
        
    } else{
        
        _isLastExerciseOfRoutine = YES;
        
        return NO;
        
    }
    
}

- (NSMutableArray *)extractTargetsArrayForActiveIndices{
    
    NSMutableArray *targetsCollector = [[NSMutableArray alloc] init];
    
    int exerciseIndex = [self.activeExerciseIndexForTargets intValue];
    int roundIndex = [self.activeRoundIndexForTargets intValue];
    
    float weight;
    float reps;
    float rest;
    
    [targetsCollector addObject: self.chainTemplate.exercises[exerciseIndex].name];
    
    if (self.chainTemplate.targetingWeight){
        
        weight = self.chainTemplate.weightArrays[exerciseIndex].numbers[roundIndex].value;
        
    } else{
        
        weight = -1.0;
        
    }
    
    if (self.chainTemplate.targetingReps){
        
        reps = self.chainTemplate.repsArrays[exerciseIndex].numbers[roundIndex].value;
        
    } else{
        
        reps = -1.0;
        
    }
    
    if (self.chainTemplate.targetingRestTime){
        
        rest = self.chainTemplate.targetRestTimeArrays[exerciseIndex].numbers[roundIndex].value;
        
    } else{
        
        // a value of negative one is assigned in this case so that it is nonzero and hence does not conflict with the logic used to determine how many exercise targets to collect
        
        rest = -1.0;
        
    }
    
    [targetsCollector addObject: [NSNumber numberWithFloat: weight]];
    [targetsCollector addObject: [NSNumber numberWithFloat: reps]];
    [targetsCollector addObject: [NSNumber numberWithFloat: rest]];
    
    return targetsCollector;
    
}



static NSString const *nextUpLabelKey = @"nextUpLabel";
static NSString const *guidanceStackViewKey = @"guidanceStackView";
static NSString const *restViewKey = @"restView";

- (UIView *)scrollContentViewForTargetArrays{
    
    self.constraintMapping = [[NSMutableDictionary alloc] init];
    self.exerciseItemChildVCs = [[NSMutableArray alloc] init];
    
    //// create the master view and give it the appropriate frame. Set the scroll view's content area according to the masterFrame's size
    
    CGFloat width = self.contentScrollView.frame.size.width;
    float numberOfExerciseComps = (float)self.activeLiftTargets.count;
    CGFloat exerciseCompHeight = 300;
    CGFloat restCompHeight = 100;
    CGFloat initialTopSpacing = 16.0;
    CGFloat height = exerciseCompHeight * (numberOfExerciseComps) + restCompHeight + initialTopSpacing;
    
    CGRect masterFrame = CGRectMake(0, 0, width, height);
    [self.contentScrollView setContentSize: CGSizeMake(width, height)];
    
    UIView *masterView = [[UIView alloc] initWithFrame: masterFrame];
    masterView.backgroundColor = [UIColor whiteColor];
//    self.activeScrollContentView = masterView;
    
    //// create and add on a stack view.  This stack view will fill the rest of the scrollable content and its individual views will be the immediate targets along with previous marks
    
    UIStackView *guidanceStackView = [[UIStackView alloc] init];
    guidanceStackView.axis = UILayoutConstraintAxisVertical;
    guidanceStackView.distribution = UIStackViewDistributionFillEqually;
    guidanceStackView.alignment = UIStackViewDistributionFill;
    guidanceStackView.spacing = 0;
    
    guidanceStackView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // layout constraints
    
    [self.constraintMapping setObject: guidanceStackView
                               forKey: guidanceStackViewKey];
    [masterView addSubview: guidanceStackView];
    
    NSArray *guidanceStackViewHorC = [NSLayoutConstraint constraintsWithVisualFormat: @"H:|-0-[guidanceStackView]-0-|"
                                                                             options: 0
                                                                             metrics: nil
                                                                               views: self.constraintMapping];
    
    
    NSString *verticalStringStackView = [NSString stringWithFormat: @"V:|-%.01f-[guidanceStackView]", initialTopSpacing];
    NSArray *guidanceStackViewVerC = [NSLayoutConstraint constraintsWithVisualFormat: verticalStringStackView
                                                                             options: 0
                                                                             metrics: nil
                                                                               views: self.constraintMapping];
    
    [masterView addConstraints: guidanceStackViewHorC];
    [masterView addConstraints: guidanceStackViewVerC];
    
    // add views to the guidance stack view
    
    for (int i = 0; i < self.activeLiftTargets.count; i++){
        
        NSString *titleNumber = [NSString stringWithFormat: @"%d", i + 1];
        NSString *exerciseName = self.activeLiftTargets[i][0];
        NSString *weight;
        NSString *reps;
        
        if (self.chainTemplate.targetingWeight){
            
            weight = [self.activeLiftTargets[i][1] stringValue];
            
        } else{
            
            weight = @"X";
            
        }
        
        if (self.chainTemplate.targetingReps){
            
            reps = [self.activeLiftTargets[i][2] stringValue];
            
        } else{
            
            reps = @"X";
            
        }
        
        // grab the previous entries to be passed to the exerciseItemVC based on the active targets index
        // must make sure that a sub-array exists at the index before attempting to grab it.  If info exists at a certain index, it must exist at a lesser index given how chains work.  This allows me to just evaluate chain length when determining if info exists or not
        
        NSInteger numberOfPreviousEntries = self.activePreviousMarks.count;
        
        NSArray<NSArray *> *previousEntries = nil;
        
        if (i < numberOfPreviousEntries){
            
            previousEntries = self.activePreviousMarks[i];
            
        }
        
   
        
        TJBActiveRoutineExerciseItemVC *exerciseItemVC = [[TJBActiveRoutineExerciseItemVC alloc] initWithTitleNumber: titleNumber
                                                                                                  targetExerciseName: exerciseName
                                                                                                        targetWeight: weight
                                                                                                          targetReps: reps
                                                                                                     previousEntries: previousEntries];
        [self.exerciseItemChildVCs addObject: exerciseItemVC];
        [self addChildViewController: exerciseItemVC];
        
        [guidanceStackView addArrangedSubview: exerciseItemVC.view];
        
        [exerciseItemVC didMoveToParentViewController: self];
        
    }
    
    // add single rest view to stack view
    // the rest view needs to know if it is the last view.  If so, it will indicate the routine ends instead of showing a rest value.  The active target indices will stop at their max values when all chain values have been pulled.  I keep track of this with a state variable
    
    NSNumber *titleNumber = [NSNumber numberWithInteger: self.activeLiftTargets.count + 1];
    TJBActiveRoutineRestItem *restItemVC = [[TJBActiveRoutineRestItem alloc] initWithTitleNumber: titleNumber
                                                                                      restNumber: self.activeRestTarget
                                                                               marksEndOfRoutine: _isLastExerciseOfRoutine
                                                                                 isTargetingRest: self.chainTemplate.targetingRestTime];
    restItemVC.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.restItemChildVC = restItemVC;
    [self addChildViewController: restItemVC];
    
    // layout constraints
    
    [masterView addSubview: restItemVC.view];
    
    [self.constraintMapping setObject: restItemVC.view
                               forKey: restViewKey];
    
    NSArray *restViewHorC = [NSLayoutConstraint constraintsWithVisualFormat: @"H:|-0-[restView]-0-|"
                                                                             options: 0
                                                                             metrics: nil
                                                                               views: self.constraintMapping];
    
    NSString *verticalString = [NSString stringWithFormat: @"V:[guidanceStackView]-0-[restView(==%d)]-0-|",
                                (int)restCompHeight];
    NSArray *restViewVerC = [NSLayoutConstraint constraintsWithVisualFormat: verticalString
                                                                             options: 0
                                                                             metrics: nil
                                                                               views: self.constraintMapping];
    
    [masterView addConstraints: restViewHorC];
    [masterView addConstraints: restViewVerC];
    
    [restItemVC didMoveToParentViewController: self];
    
    return masterView;
    
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
                                                            
                                                            [weakSelf dismissViewControllerAnimated: YES
                                                                                         completion: nil];
                                                            
                                                            // disassociate with the timer
                                                            
                                                            [[TJBStopwatch singleton] removeAllPrimaryStopwatchObservers];
                                                            
                                                        }];
    [alert addAction: leaveAction];
    
    [self presentViewController: alert
                       animated: YES
                     completion: nil];
    
}


- (void)didPressBack{
    
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
                                                            
                                                            [weakSelf dismissViewControllerAnimated: YES
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
    
    NSInteger selectionsToBeMade = self.activeLiftTargets.count;
    BOOL isLastLocalSelection = _selectionIndex == selectionsToBeMade - 1;
    
    // record first incomplete indices in case cancel block in called.  If cancel block is called, I will simply change the 'first incomplete' type properties of the realized chain.  I will not change the 'isDefaultObject' property of the weights, reps, and dates that may have been recorded.  I may have to change this later given broader system considerations
    // the cancellation restoration exercise and round objects should only exist during the selection process, they should otherwise be nil
    
    if (!self.cancelRestorationExerciseIndex){
        self.cancelRestorationExerciseIndex = self.activeExerciseIndexForChain;
    }
    
    if (!self.cancelRestorationRoundIndex){
        self.cancelRestorationRoundIndex = self.activeRoundIndexForChain;
    }
    
    NSString *title = self.activeLiftTargets[_selectionIndex][0];
        
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
            
        weakSelf.realizedChain.weightArrays[exercise].numbers[round].value = [weight floatValue];
        weakSelf.realizedChain.repsArrays[exercise].numbers[round].value = [reps floatValue];
        
        weakSelf.realizedChain.weightArrays[exercise].numbers[round].isDefaultObject = NO;
        weakSelf.realizedChain.repsArrays[exercise].numbers[round].isDefaultObject = NO;
            
        // set begin dates will always be default objects.  It will vary for set end dates
            
        weakSelf.realizedChain.setBeginDateArrays[exercise].dates[round].isDefaultObject = YES;
            
        if (isLastLocalSelection){
                
            weakSelf.realizedChain.setEndDateArrays[exercise].dates[round].value = [NSDate date];
            weakSelf.realizedChain.setEndDateArrays[exercise].dates[round].isDefaultObject = NO;
                
        } else{
                
            weakSelf.realizedChain.setEndDateArrays[exercise].dates[round].isDefaultObject = YES;
                
        }
            
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
                
                [weakSelf performSelector: @selector(showNextSetOfTargets)
                               withObject: nil
                               afterDelay: .5];
        
            } else{
                    
            // configure labels accordingly
                    
            weakSelf.timerTitleLabel.text = @"";
            [[TJBStopwatch singleton] removeAllPrimaryStopwatchObservers];
                    
            weakSelf.roundTitleLabel.text = @"";
                    
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
                                                                   
                                                                   [weakSelf dismissViewControllerAnimated: YES
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

- (void)showNextSetOfTargets{
    
    // this method derives and displays the new targets. The transition to the new targets is animated to make it apparent to the user that a change has occurred
    
    // configure the round and timer labels
    
    NSString *newTimerText = [[TJBStopwatch singleton] minutesAndSecondsStringFromNumberOfSeconds: [self.activeRestTarget intValue]];
    
    self.timerTitleLabel.backgroundColor = [UIColor darkGrayColor];
    
    CALayer *timerLabelLayer = self.timerTitleLabel.layer;
    
    timerLabelLayer.shadowColor = [[UIColor whiteColor] CGColor];
    timerLabelLayer.shadowRadius = 12.0;
    timerLabelLayer.shadowOpacity = 0;
    timerLabelLayer.shadowOffset = CGSizeZero;
    timerLabelLayer.masksToBounds = NO;
    

    
    [[TJBStopwatch singleton] setPrimaryStopWatchToTimeInSeconds: [self.activeRestTarget intValue]
                                         withForwardIncrementing: NO
                                                  lastUpdateDate: nil];
    
    // give the timer non red zone colors
    
    self.remainingRestTopLabel.backgroundColor = [UIColor darkGrayColor];
    
    self.roundTitleLabel.text = [NSString stringWithFormat: @"%d/%d",
                                     [self.activeRoundIndexForTargets intValue] + 1,
                                     self.chainTemplate.numberOfRounds];
    
    
    [self configureImmediateTargets];
    
    // nullify the cancellation restoration exercise index and round index
    
    self.cancelRestorationExerciseIndex = nil;
    self.cancelRestorationRoundIndex = nil;
    
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

- (IBAction)didPressRightBarButton:(id)sender{
    
    if (_advancedControlsActive){
        
        [self toggleButtonControlsToDefaultDisplay];
        
    } else{
        
        [self toggleButtonControlsToAdvancedDisplay];
        
    }
    
}

- (IBAction)didPressAlertTimingButton:(id)sender{
    
    // present the rest selection scene and store the selected number in the appropriate state variable
    
    __weak TJBActiveRoutineGuidanceVC *weakSelf = self;
    
    CancelBlock cancelBlock = ^{
        
        [weakSelf dismissViewControllerAnimated: NO
                                     completion: nil];
        
    };
    
    NumberSelectedBlockSingle numberSelectedBlock = ^(NSNumber *number){
        
        weakSelf.selectedAlertTiming = number;
        
        NSString *text = [[TJBStopwatch singleton] minutesAndSecondsStringFromNumberOfSeconds: [number intValue]];
        [weakSelf.alertTimingButton setTitle: text
                                    forState: UIControlStateNormal];
        
        [weakSelf dismissViewControllerAnimated: NO
                                     completion: nil];
        
    };
    
    TJBNumberSelectionVC *vc = [[TJBNumberSelectionVC alloc] initWithNumberTypeIdentifier: TimeIntervalSelection
                                                                                    title: @"Select Alert Timing"
                                                                              cancelBlock: cancelBlock
                                                                      numberSelectedBlock: numberSelectedBlock];
    
    [self presentViewController: vc
                       animated: YES
                     completion: nil];
    
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
    
    if (forwardIndicesExist){
        
        self.activeExerciseIndexForChain = newExerciseIndex;
        self.activeRoundIndexForChain = newRoundIndex;
        
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
        
        if (inRedZone){
            
            self.remainingRestTopLabel.backgroundColor = [UIColor redColor];
            self.timerTitleLabel.backgroundColor = [UIColor redColor];
            
        } else{
            
            self.remainingRestTopLabel.backgroundColor = [UIColor darkGrayColor];
            self.timerTitleLabel.backgroundColor = [UIColor darkGrayColor];
            
        }
        
    }
    
}

- (void)secondaryTimerDidUpdateWithUpdateDate:(NSDate *)date{
    
    
    
}

#pragma mark - Animation

- (void)toggleButtonControlsToAdvancedDisplay{
    
    [UIView animateWithDuration: .4
                     animations: ^{
                         
                         self.advancedControlsConstraint.constant = 0;
                         
                         NSArray *views = @[self.advancedControlsContainer, self.nextUpLabel];
                         
                         for (UIView *view in views){
                             
                             CGRect currentFrame = view.frame;
                             CGRect newFrame = CGRectMake(currentFrame.origin.x, currentFrame.origin.y + advancedControlSlidingHeight, currentFrame.size.width, currentFrame.size.height);
                             view.frame = newFrame;
                             
                         }
                         
                         CGRect currentSVFrame = self.contentScrollView.frame;
                         CGRect newSVFrame = CGRectMake(currentSVFrame.origin.x, currentSVFrame.origin.y + advancedControlSlidingHeight, currentSVFrame.size.width, currentSVFrame.size.height - advancedControlSlidingHeight);
                         self.contentScrollView.frame = newSVFrame;
                         
                     }];
    
    _advancedControlsActive = YES;
    [self.rightBarButtoon setTitle: @"-"
                          forState: UIControlStateNormal];
    
    
}

- (void)toggleButtonControlsToDefaultDisplay{
    
    [UIView animateWithDuration: .4
                     animations: ^{
                         
                         self.advancedControlsConstraint.constant = -1 * advancedControlSlidingHeight;
                         
                         
                         NSArray *views = @[self.advancedControlsContainer, self.nextUpLabel];
                         
                         for (UIView *view in views){
                             
                             CGRect currentFrame = view.frame;
                             CGRect newFrame = CGRectMake(currentFrame.origin.x, currentFrame.origin.y - advancedControlSlidingHeight, currentFrame.size.width, currentFrame.size.height);
                             view.frame = newFrame;
                             
                         }
                         
                         CGRect currentSVFrame = self.contentScrollView.frame;
                         CGRect newSVFrame = CGRectMake(currentSVFrame.origin.x, currentSVFrame.origin.y - advancedControlSlidingHeight, currentSVFrame.size.width, currentSVFrame.size.height + advancedControlSlidingHeight);
                         self.contentScrollView.frame = newSVFrame;
                         
                     }];
    
    _advancedControlsActive = NO;
    [self.rightBarButtoon setTitle: @"+"
                          forState: UIControlStateNormal];
    
    
}


@end



























