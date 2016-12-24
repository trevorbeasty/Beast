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

@interface TJBActiveCircuitGuidance ()

{
    // active IV's
    
    int _activeExerciseIndex;
    int _activeRoundIndex;
    int _previousExerciseIndex;
    int _previousRoundIndex;
    
    float _activeTargetWeight;
    float _activeTargetReps;
    float _activeTargetRestTime;
    
    // user selection progression
    
    BOOL _setCompletedButtonPressed;
    BOOL _restLabelAddedAsStopwatchObserver;
}

- (IBAction)didPressBeginSet;

// UI

@property (weak, nonatomic) IBOutlet UIView *containerSubview;


@property (weak, nonatomic) IBOutlet UILabel *nextUpExerciseLabel;
@property (weak, nonatomic) IBOutlet UILabel *weightLabel;
@property (weak, nonatomic) IBOutlet UILabel *repsLabel;
@property (weak, nonatomic) IBOutlet UILabel *remainingRestLabel;

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;

// data

@property (nonatomic, strong) TJBChainTemplate *chainTemplate;

// derived IV's

@property (nonatomic, strong) NSNumber *numberOfExercises;
@property (nonatomic, strong) NSNumber *numberOfRounds;

// user selections

@property (nonatomic, strong) NSNumber *selectedTimeDelay;
@property (nonatomic, strong) NSNumber *selectedTimeLag;
@property (nonatomic, strong) NSNumber *selectedWeight;
@property (nonatomic, strong) NSNumber *selectedReps;

@end

@implementation TJBActiveCircuitGuidance

#pragma mark - Instantiation

- (void)configureViews{
    // nav bar
    
    UINavigationItem *navItem = [[UINavigationItem alloc] init];
    NSString *title = [NSString stringWithFormat: @"%@",
                       self.chainTemplate.name];
    [navItem setTitle: title];
    UIBarButtonItem *cancelBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCancel
                                                                                     target: self
                                                                                     action: @selector(didPressCancel)];
    [navItem setLeftBarButtonItem: cancelBarButton];
    [self.navBar setItems: @[navItem]];
    
    // dynamic views
    
    self.weightLabel.text = [[NSNumber numberWithDouble: _activeTargetWeight] stringValue];
    self.repsLabel.text = [[NSNumber numberWithDouble: _activeTargetReps] stringValue];
    
    self.remainingRestLabel.text = @"NA";

    TJBExercise *exercise = self.chainTemplate.exercises[0];
    NSString *activeExerciseTitle = [NSString stringWithFormat: @"First exercise: %@",
                                     exercise.name];
    self.nextUpExerciseLabel.text = activeExerciseTitle;
}

- (void)initializeActiveInstanceVariables{
    _activeExerciseIndex = 0;
    _activeRoundIndex = 0;
    
    TJBChainTemplate *chainTemplate = self.chainTemplate;
    
    _activeTargetWeight = chainTemplate.weightArrays[0].numbers[0].value;
    _activeTargetReps = chainTemplate.repsArrays[0].numbers[0].value;
    _activeTargetRestTime = chainTemplate.targetRestTimeArrays[0].numbers[0].value;
    
    _setCompletedButtonPressed = NO;
}

- (void)viewDidLoad{
    [self configureViews];
}

- (void)setDerivedInstanceVariables{
    TJBChainTemplate *chainTemplate = self.chainTemplate;
    
    NSNumber *numberOfExercises = [NSNumber numberWithUnsignedLong: [chainTemplate.exercises count]];
    self.numberOfExercises = numberOfExercises;
    
    TJBRepsArray *repsArray = chainTemplate.repsArrays[0];
    NSNumber *numberOfRounds = [NSNumber numberWithUnsignedLong: [repsArray.numbers count]];
    self.numberOfRounds = numberOfRounds;
}


- (instancetype)initWithChainTemplate:(TJBChainTemplate *)chainTemplate{
    self = [super init];
    
    // IV's
    
    self.chainTemplate = chainTemplate;
    
    [self setDerivedInstanceVariables];
    [self initializeActiveInstanceVariables];
    
    return self;
}

#pragma mark - Button Actions

-(void)didPressBeginSet{
    CancelBlock cancelBlock = ^{
        [self setUserSelectedValuesToNil];
        [self dismissViewControllerAnimated: NO
                                 completion: nil];
    };
    
    if(!self.selectedTimeDelay)
    {
        NumberSelectedBlock numberSelectedBlock = ^(NSNumber *number){
            self.selectedTimeDelay = number;
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
    }
    else if (_setCompletedButtonPressed == NO)
    {
        void(^block)(int) = ^(int timeInSeconds){
            _setCompletedButtonPressed = YES;
//            _timerAtSetCompletion = timeInSeconds;
            [self dismissViewControllerAnimated: NO
                                     completion: nil];
            [self didPressBeginSet];
        };
        
        TJBInSetVC *vc = [[TJBInSetVC alloc] initWithTimeDelay: [self.selectedTimeDelay intValue]
                                     DidPressSetCompletedBlock: block];
        
        [self presentViewController: vc
                           animated: NO
                         completion: nil];
    }
    else if (!self.selectedTimeLag)
    {
        NumberSelectedBlock numberSelectedBlock = ^(NSNumber *number){
            self.selectedTimeLag = number;
            [self dismissViewControllerAnimated: NO
                                     completion: nil];
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
    }
    else if (!self.selectedWeight)
    {
        NumberSelectedBlock numberSelectedBlock = ^(NSNumber *number){
            self.selectedWeight = number;
            [self dismissViewControllerAnimated: NO
                                     completion: nil];
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
    }
    else if (!self.selectedReps)
    {
        NumberSelectedBlock numberSelectedBlock = ^(NSNumber *number){
            self.selectedReps = number;
            [self dismissViewControllerAnimated: NO
                                     completion: nil];
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
    }
    else
    {
        [self incrementControllerAndUpdateViews];
        [self setUserSelectedValuesToNil];
    }
    
}

- (void)incrementControllerAndUpdateViews{
    _previousExerciseIndex = _activeExerciseIndex;
    _previousRoundIndex = _activeRoundIndex;
    
    BOOL atMaxRoundIndex = _activeRoundIndex == [self.numberOfRounds intValue] - 1;
    BOOL atMaxExerciseIndex = _activeExerciseIndex == [self.numberOfExercises intValue] - 1;
    
    if (atMaxExerciseIndex){
        if (atMaxRoundIndex){
            abort();
        } else{
            _activeRoundIndex++;
            _activeExerciseIndex = 0;
        }
    } else{
        _activeExerciseIndex++;
    }
    
    _activeTargetWeight = self.chainTemplate.weightArrays[_activeExerciseIndex].numbers[_activeRoundIndex].value;
    self.weightLabel.text = [[NSNumber numberWithFloat: _activeTargetWeight] stringValue];
    
    _activeTargetReps = self.chainTemplate.repsArrays[_activeExerciseIndex].numbers[_activeRoundIndex].value;
    self.repsLabel.text = [[NSNumber numberWithFloat: _activeTargetReps] stringValue];
    
    _activeTargetRestTime = self.chainTemplate.targetRestTimeArrays[_previousExerciseIndex].numbers[_previousRoundIndex].value;
    TJBStopwatch *stopwatch = [TJBStopwatch singleton];
    self.remainingRestLabel.text = [stopwatch minutesAndSecondsStringFromNumberOfSeconds: _activeTargetRestTime];
    [stopwatch setPrimaryStopWatchToTimeInSeconds: _activeTargetRestTime
                          withForwardIncrementing: NO];
    if (_restLabelAddedAsStopwatchObserver == NO){
        [[TJBStopwatch singleton] addPrimaryStopwatchObserver: self.remainingRestLabel];
    }
    
    TJBExercise *exercise = self.chainTemplate.exercises[_activeExerciseIndex];
    self.nextUpExerciseLabel.text = [NSString stringWithFormat: @"Next up: %@",
                                     exercise.name];
}

- (void)didPressCancel{
    [self dismissViewControllerAnimated: NO
                             completion: nil];
}

- (void)presentNumberSelectionSceneWithNumberType:(NumberType)numberType numberMultiple:(NSNumber *)numberMultiple numberLimit:(NSNumber *)numberLimit title:(NSString *)title cancelBlock:(void(^)(void))cancelBlock numberSelectedBlock:(void(^)(NSNumber *))numberSelectedBlock animated:(BOOL)animated modalTransitionStyle:(UIModalTransitionStyle)transitionStyle;
{
    
    UIStoryboard *numberSelectionStoryboard = [UIStoryboard storyboardWithName: @"TJBNumberSelection"
                                                                        bundle: nil];
    UINavigationController *numberSelectionNav = (UINavigationController *)[numberSelectionStoryboard instantiateInitialViewController];
    TJBNumberSelectionVC *numberSelectionVC = (TJBNumberSelectionVC *)[numberSelectionNav viewControllers][0];
    
    [numberSelectionVC setNumberTypeIdentifier: numberType
                                numberMultiple: numberMultiple
                                   numberLimit: numberLimit
                                         title: title
                                   cancelBlock: cancelBlock
                           numberSelectedBlock: numberSelectedBlock];
    
    numberSelectionNav.modalTransitionStyle = transitionStyle;
    
    [self presentViewController: numberSelectionNav
                       animated: animated
                     completion: nil];
}

- (void)setUserSelectedValuesToNil{
    self.selectedTimeDelay = nil;
    self.selectedTimeLag = nil;
    _setCompletedButtonPressed = NO;
    self.selectedWeight = nil;
    self.selectedReps = nil;
}

@end
































