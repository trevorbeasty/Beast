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

// stopwatch

#import "TJBStopwatch.h"
#import "TJBStopwatchObserver.h"

@interface TJBActiveRoutineGuidanceVC () <TJBStopwatchObserver>

{
    
    // state
    
    int _selectionIndex;
    
}

// IBOutlet

@property (weak, nonatomic) IBOutlet UILabel *roundTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timerTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *alertTimingButton;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (weak, nonatomic) IBOutlet UILabel *nextUpDetailLabel;
@property (weak, nonatomic) IBOutlet UIButton *setCompletedButton;

// IBAction

@property (weak, nonatomic) IBOutlet UIButton *didPressSetCompleted;


// core

@property (nonatomic, strong) TJBChainTemplate *chainTemplate;
@property (nonatomic, strong) TJBRealizedChain *realizedChain;

@property (nonatomic, strong) UIView *activeScrollContentView;
@property (nonatomic, strong) UILabel *nextUpLabel;
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
@property (nonatomic, strong) NSNumber *activeRestTarget;

// stopwatch state

@property (nonatomic, strong) NSDate *dateForTimerRecovery;

@end

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
    
    self.realizedChain = [[CoreDataController singleton] createAndSaveSkeletonRealizedChainForChainTemplate: chainTemplate];
    
    return self;
    
}

#pragma mark - View Life Cycle

- (void)viewDidLoad{
    
    // prep
    
    [self.view layoutIfNeeded];
    
    //
    
    [self configureViewAesthetics];
    
    [self configureImmediateTargets];
    
    [self configureTimer];
    
    [self configureInitialDisplay];
    
}

- (void)configureTimer{
    
    [[TJBStopwatch singleton] addPrimaryStopwatchObserver: self
                                           withTimerLabel: self.timerTitleLabel];
    
}

- (void)configureInitialDisplay{
    
    self.roundTitleLabel.text = [NSString stringWithFormat: @"Round 1/%d", self.chainTemplate.numberOfRounds];
    self.timerTitleLabel.text = @"";
    
}

- (void)configureImmediateTargets{
    
    // grab all targets and update the view accordingly
    
    //// state
    
    self.activeLiftTargets = [[NSMutableArray alloc] init];
    self.activeRestTarget = nil;
    
    [self deriveStateContent];
    
    // get the scrollContentView and make it a subview of the scroll view
    
    if (self.activeScrollContentView){
        
        [self.activeScrollContentView removeFromSuperview];
        self.activeScrollContentView = nil;
        
    }
    
    [self.contentScrollView addSubview: [self scrollContentViewForTargetArrays]];
    
    self.contentScrollView.contentOffset = CGPointMake(0, 0);
    
}

- (void)configureViewAesthetics{
    
    // shadow for title objects to create separation
    
//    CALayer *shadowLayer = self.nextUpDetailLabel.layer;
//    shadowLayer.masksToBounds = NO;
//    shadowLayer.shadowColor = [UIColor darkGrayColor].CGColor;
//    shadowLayer.shadowOffset = CGSizeMake(0.0, 3.0);
//    shadowLayer.shadowOpacity = 1.0;
//    shadowLayer.shadowRadius = 3.0;
    
}

#pragma mark - Scroll View Content

- (void)deriveStateContent{
    
    // based on the active exercise and round index, give the appropriate content to the state target arrays
    // grab all exercises, beginning with the one corresponding to the active indices, and continuing to grab exercises until the rest is nonzero or the round ends
    
    NSArray *targets = [self extractTargetsArrayForActiveIndices];
    [self.activeLiftTargets addObject: targets];
    
    // if the rest is zero, grab the next set of targets.  Otherwise, continue.  Will use recursion.
    
    BOOL canForwardIncrementIndices = [self incrementActiveIndicesForward];
    
    if (canForwardIncrementIndices){
        
        // the fourth index holds an NSNumber with the target rest value
        
        if ([targets[3] floatValue] == 0.0){
            
            [self deriveStateContent];
            
        } else{
            
            self.activeRestTarget = targets[3];
            
        }
        
    } else{
        
        return;
        
    }

}

- (BOOL)incrementActiveIndicesForward{
    
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
        
        weight = 0.0;
        
    }
    
    if (self.chainTemplate.targetingReps){
        
        reps = self.chainTemplate.repsArrays[exerciseIndex].numbers[roundIndex].value;
        
    } else{
        
        reps = 0.0;
        
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

- (UIView *)scrollContentViewForTargetArrays{
    
    self.constraintMapping = [[NSMutableDictionary alloc] init];
    self.exerciseItemChildVCs = [[NSMutableArray alloc] init];
    
    //// create the master view and give it the appropriate frame. Set the scroll view's content area according to the masterFrame's size
    
    CGFloat width = self.contentScrollView.frame.size.width;
    float numberOfExerciseComps = (float)self.activeLiftTargets.count;
    CGFloat exerciseCompHeight = 330;
//    float numberOfRestComps = 1.0;
//    CGFloat restCompHeight = 100;
    CGFloat height = exerciseCompHeight * (numberOfExerciseComps + 1.0);
    
    CGRect masterFrame = CGRectMake(0, 0, width, height);
    [self.contentScrollView setContentSize: CGSizeMake(width, height)];
    
    UIView *masterView = [[UIView alloc] initWithFrame: masterFrame];
    masterView.backgroundColor = [UIColor redColor];
    self.activeScrollContentView = masterView;
    
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
    NSArray *guidanceStackViewVerC = [NSLayoutConstraint constraintsWithVisualFormat: @"V:|-0-[guidanceStackView]-0-|"
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
        
        TJBActiveRoutineExerciseItemVC *exerciseItemVC = [[TJBActiveRoutineExerciseItemVC alloc] initWithTitleNumber: titleNumber
                                                                                                  targetExerciseName: exerciseName
                                                                                                        targetWeight: weight
                                                                                                          targetReps: reps
                                                                                                     previousEntries: nil];
        [self.exerciseItemChildVCs addObject: exerciseItemVC];
        [self addChildViewController: exerciseItemVC];
        
        [guidanceStackView addArrangedSubview: exerciseItemVC.view];
        
        [exerciseItemVC didMoveToParentViewController: self];
        
    }
    
    // add single rest view to stack view
    
    NSNumber *titleNumber = [NSNumber numberWithInteger: self.activeLiftTargets.count + 1];
    TJBActiveRoutineRestItem *restItemVC = [[TJBActiveRoutineRestItem alloc] initWithTitleNumber: titleNumber
                                                                                      restNumber: self.activeRestTarget];
    self.restItemChildVC = restItemVC;
    [self addChildViewController: restItemVC];
    
    [guidanceStackView addArrangedSubview: restItemVC.view];
    
    [restItemVC didMoveToParentViewController: self];
    
    return masterView;
    
}


#pragma mark - Button Actions

- (void)didPressBack{
    
    [self dismissViewControllerAnimated: NO
                             completion: nil];
    
}

- (IBAction)didPressSetCompleted:(UIButton *)didPressSetCompleted{
    
    __weak TJBActiveRoutineGuidanceVC *weakSelf = self;
    
    NSInteger selectionsToBeMade = self.activeLiftTargets.count;
    BOOL isLastLocalSelection = _selectionIndex == selectionsToBeMade - 1;
    
//    for (int i = 0; i < selectionsToBeMade; i++){
    
        NSString *title = self.activeLiftTargets[_selectionIndex][0];
        
        // cancel block
        
        void (^cancelBlock)(void) = ^{
            
            
            
        };
        
        // number selected block
        
        NumberSelectedBlockDouble selectedBlock = ^(NSNumber *weight, NSNumber *reps){
            
            // fill in the realized chain with the selected values
            // be sure to use the active round indices for 'chain'.  There are two pairs of round indices - one for grabbing targets and one for filling in the realized chain
            // the skeleton chain template already has the appropriate exercises filled in, so must enter all other info here
            // for now, I will offer no advanced options for user input.  The end of the second set will be recorded as the time the user presses 'set completed'.  All exercises that are not the last in this local sequence will not have rest times recorded
            // the timer will be reset upon pressing of the set completed button. It will countdown backwards and should use the target rest value that is already stored as its starting value
            
            int exercise = [weakSelf.activeExerciseIndexForChain intValue];
            int round = [weakSelf.activeRoundIndexForChain intValue];
            
            weakSelf.realizedChain.weightArrays[exercise].numbers[round].value = [weight floatValue];
            weakSelf.realizedChain.repsArrays[exercise].numbers[round].value = [reps floatValue];
            
            // set begin dates will always be default objects.  It will vary for set end dates
            
            weakSelf.realizedChain.setBeginDateArrays[exercise].dates[round].isDefaultObject = YES;
            
            if (isLastLocalSelection){
                
                weakSelf.realizedChain.setEndDateArrays[exercise].dates[round].value = [NSDate date];
                weakSelf.realizedChain.setEndDateArrays[exercise].dates[round].isDefaultObject = NO;
                
            } else{
                
                weakSelf.realizedChain.setEndDateArrays[exercise].dates[round].isDefaultObject = YES;
                
            }
            
            // increment the chain indices
            
            BOOL routineNotCompleted = [self incrementActiveChainIndices];
            
            // if the iterator has reached its max value (all selections have been made), refresh the timer and active scroll view content
            // must check that this is not the very last item in the chain
            
            if ([weakSelf allSelectionsMade]){
                
                if (routineNotCompleted){
                    
                    _selectionIndex = 0;
                    
                    // configure the round and timer labels
                    
                    [[TJBStopwatch singleton] setPrimaryStopWatchToTimeInSeconds: [self.activeRestTarget intValue]
                                                         withForwardIncrementing: NO
                                                                  lastUpdateDate: nil];
                    
                    weakSelf.roundTitleLabel.text = [NSString stringWithFormat: @"Round %d/%d",
                                                     [weakSelf.activeRoundIndexForTargets intValue] + 1,
                                                     weakSelf.chainTemplate.numberOfRounds];
                    
                    
                    [weakSelf configureImmediateTargets];
                    
                } else{
                    
                    abort();
                    
                }
                
                [weakSelf dismissViewControllerAnimated: YES
                                         completion: nil];
                
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
        
//    }
    
}

- (BOOL)allSelectionsMade{
    
    // if the target and chain indices are equivalent, then all selections have been made
    
    BOOL exerciseSame = [self.activeExerciseIndexForTargets intValue] == [self.activeExerciseIndexForChain intValue];
    BOOL roundSame = [self.activeRoundIndexForTargets intValue] == [self.activeRoundIndexForChain intValue];
    
    return exerciseSame && roundSame;
    
}

- (BOOL)incrementActiveChainIndices{
    
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
    
    if (forwardIndicesExist){
        
        self.activeExerciseIndexForChain = newExerciseIndex;
        self.activeRoundIndexForChain = newRoundIndex;
        
        return YES;
        
    } else{
        
        return NO;
        
    }
    
}

#pragma mark - <TJBStopwatchObserver>

- (void)primaryTimerDidUpdateWithUpdateDate:(NSDate *)date{
    
    self.dateForTimerRecovery = date;
    
}

- (void)secondaryTimerDidUpdateWithUpdateDate:(NSDate *)date{
    
    
    
}

@end



























