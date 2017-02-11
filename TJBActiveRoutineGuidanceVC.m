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

@interface TJBActiveRoutineGuidanceVC ()

// IBOutlet

@property (weak, nonatomic) IBOutlet UILabel *roundTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timerTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *alertTimingButton;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;
@property (weak, nonatomic) IBOutlet UILabel *nextUpDetailLabel;

// IBAction

// core

@property (nonatomic, strong) TJBChainTemplate *chainTemplate;

@property (nonatomic, strong) UIView *activeScrollContentView;
@property (nonatomic, strong) UILabel *nextUpLabel;
@property (nonatomic, strong) UIStackView *guidanceStackView;
@property (nonatomic, strong) NSMutableArray<TJBActiveRoutineExerciseItemVC *> *exerciseItemChildVCs;
@property (nonatomic, strong) TJBActiveRoutineRestItem *restItemChildVC;

// scroll content view

@property (nonatomic, strong) NSMutableDictionary *constraintMapping;

// state

@property (nonatomic, strong) NSNumber *activeRoundIndex;
@property (nonatomic, strong) NSNumber *activeExerciseIndex;

@property (nonatomic, strong) NSMutableArray<NSArray *> *activeLiftTargets;
@property (nonatomic, strong) NSNumber *activeRestTarget;

@end

@implementation TJBActiveRoutineGuidanceVC

#pragma mark - Instantiation

- (instancetype)initFreshRoutineWithChainTemplate:(TJBChainTemplate *)chainTemplate{
    
    self = [super init];
    
    self.chainTemplate = chainTemplate;
    
    // because it is a fresh routine, give it active round and exercise indices of 0
    
    self.activeRoundIndex = [NSNumber numberWithInt: 0];
    self.activeExerciseIndex = [NSNumber numberWithInt: 0];
    
    return self;
    
}

#pragma mark - View Life Cycle

- (void)viewDidLoad{
    
    // prep
    
    [self.view layoutIfNeeded];
    
    //
    
    [self configureViewAesthetics];
    
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
    
}

- (void)configureViewAesthetics{
    
    // shadow for title objects to create separation
    
    CALayer *shadowLayer = self.nextUpDetailLabel.layer;
    shadowLayer.masksToBounds = NO;
    shadowLayer.shadowColor = [UIColor darkGrayColor].CGColor;
    shadowLayer.shadowOffset = CGSizeMake(0.0, 3.0);
    shadowLayer.shadowOpacity = 1.0;
    shadowLayer.shadowRadius = 3.0;
    
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
    
    int exerciseIndex = [self.activeExerciseIndex intValue];
    int roundIndex = [self.activeRoundIndex intValue];
    
    NSNumber *newExerciseIndex = nil;
    NSNumber *newRoundIndex = nil;
    
    BOOL forwardIndicesExist = [TJBAssortedUtilities nextIndiceValuesForCurrentExerciseIndex: exerciseIndex
                                                                           currentRoundIndex: roundIndex
                                                                            maxExerciseIndex: self.chainTemplate.numberOfExercises - 1
                                                                               maxRoundIndex: self.chainTemplate.numberOfRounds - 1
                                                                      exerciseIndexReference: &newExerciseIndex
                                                                         roundIndexReference: &newRoundIndex];
    
    if (forwardIndicesExist){
        
        self.activeExerciseIndex = newExerciseIndex;
        self.activeRoundIndex = newRoundIndex;
        
        return YES;
        
    } else{
        
        return NO;
        
    }
    
}

- (NSMutableArray *)extractTargetsArrayForActiveIndices{
    
    NSMutableArray *targetsCollector = [[NSMutableArray alloc] init];
    
    int exerciseIndex = [self.activeExerciseIndex intValue];
    int roundIndex = [self.activeRoundIndex intValue];
    
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
    CGFloat exerciseCompHeight = 220;
    float numberOfRestComps = 1.0;
    CGFloat restCompHeight = 100;
    CGFloat height = exerciseCompHeight * numberOfExerciseComps + numberOfRestComps * restCompHeight;
    
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



@end



























