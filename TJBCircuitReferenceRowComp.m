//
//  TJBCircuitReferenceRowComp.m
//  Beast
//
//  Created by Trevor Beasty on 1/11/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBCircuitReferenceRowComp.h"

// aesthetics

#import "TJBAestheticsController.h"

// stopwatch

#import "TJBStopwatch.h"

// core data

#import "CoreDataController.h"

// utilities

#import "TJBAssortedUtilities.h"

// number selection

#import "TJBNumberSelectionVC.h"

@interface TJBCircuitReferenceRowComp ()

{
    
    // state
    
    TJBRoutineReferenceMode _activeMode;
    
}

// core

@property (nonatomic, strong) NSNumber *exerciseIndex;
@property (nonatomic, strong) NSNumber *roundIndex;

@property (nonatomic, strong) TJBRealizedChain *realizedChain;

// IBOutlet

@property (weak, nonatomic) IBOutlet UIButton *weightButton;
@property (weak, nonatomic) IBOutlet UIButton *repsButton;
@property (weak, nonatomic) IBOutlet UIButton *restButton;
@property (weak, nonatomic) IBOutlet UILabel *roundLabel;

// IBAction

- (IBAction)didPressWeightButton:(id)sender;
- (IBAction)didPressRepsButton:(id)sender;

@end

@implementation TJBCircuitReferenceRowComp

#pragma mark - Instantiation

- (instancetype)initWithRealizedChain:(TJBRealizedChain *)realizedChain exerciseIndex:(int)exerciseIndex roundIndex:(int)roundIndex{
    
    self = [super init];
    
    self.exerciseIndex = [NSNumber numberWithInt: exerciseIndex];
    self.roundIndex = [NSNumber numberWithInt: roundIndex];
    self.realizedChain = realizedChain;
    
    // staying current with user input
    
    [self registerForCoreDataNotification];
    
    // state
    
    _activeMode = EditingMode;
    
    return self;
    
}

- (void)registerForCoreDataNotification{
    
    // this class will take it upon itself to refresh it display data when core data is updated
    // can refine later for improved performence (iterative updates / updates only for specific situations)
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(coreDataDidSave)
                                                 name: NSManagedObjectContextDidSaveNotification
                                               object: [[CoreDataController singleton] moc]];
    
}

#pragma mark - View Life Cycle

- (void)viewDidLoad{
    
    [self configureViewAesthetics];
    
    [self configureViewForAbsoluteComparisonMode];
    
}

- (void)configureViewAesthetics{
    
    // meta view
    
    self.view.backgroundColor = [[TJBAestheticsController singleton] yellowNotebookColor];
    
    // round label
    
    self.roundLabel.backgroundColor = [UIColor lightGrayColor];
    self.roundLabel.textColor = [UIColor whiteColor];
    self.roundLabel.font = [UIFont boldSystemFontOfSize: 20.0];
    self.roundLabel.layer.opacity = 1.0;
    
    // buttons
    
    NSArray *buttons = @[self.weightButton,
                         self.repsButton,
                         self.restButton];
    for (UIButton *button in buttons){
        
        button.backgroundColor = [UIColor clearColor];
        [button setTitleColor: [UIColor blackColor]
                     forState: UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize: 15.0];
        
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = 8.0;
        
    }
    
    
    
}


#pragma mark - Notifications

- (void)coreDataDidSave{
    
    // have the controller refresh its view data every time core data saves
    
    [self activateMode: _activeMode];
    
}

#pragma mark - Modes

- (void)configureViewForTargetsMode{
    
    // state
    
    _activeMode = TargetsMode;
    
    // buttons
    
    NSArray *buttons = @[self.weightButton,
                         self.repsButton,
                         self.restButton];
    for (UIButton *button in buttons){
        
        button.enabled = NO;
        
    }
    
    // aesthetis and functionality
    
    for (UIButton *b in buttons){
        
        b.enabled = NO;
        
        b.backgroundColor = [UIColor clearColor];
        [b setTitleColor: [UIColor blackColor]
                forState: UIControlStateNormal];
        
    }
    
    // must first gather all of the appropriate data and then format it appropriately
    
    int exerciseInd = [self.exerciseIndex intValue];
    int roundInd = [self.roundIndex intValue];
    
    // targets
    
    TJBChainTemplate *chainTemplate = self.realizedChain.chainTemplate;
    
    // only grab targets if the type is being targeted, otherwise leave them as nil
    
    NSNumber *weightTarget;
    NSNumber *repsTarget;
    NSNumber *restTarget;
    
    if (chainTemplate.targetingWeight){
        weightTarget = [NSNumber numberWithFloat: chainTemplate.weightArrays[exerciseInd].numbers[roundInd].value];
    }
    
    if (chainTemplate.targetingReps){
        repsTarget = [NSNumber numberWithFloat: chainTemplate.repsArrays[exerciseInd].numbers[roundInd].value];
    }
    
    if (chainTemplate.targetingRestTime){
        restTarget = [NSNumber numberWithFloat: chainTemplate.targetRestTimeArrays[exerciseInd].numbers[roundInd].value];
    }
    
    // weight
    
    if (chainTemplate.targetingWeight){
        
        NSString *weightString = [NSString stringWithFormat: @"%@ lbs", [weightTarget stringValue]];
        
        [self.weightButton setTitle: weightString
                           forState: UIControlStateNormal];
        
    } else{
        
        [self.weightButton setTitle: @"X"
                           forState: UIControlStateNormal];
        
    }
    
    // reps
    
    if (chainTemplate.targetingReps){
        
        NSString *repsString = [NSString stringWithFormat: @"%@ reps", [repsTarget stringValue]];
        
        [self.repsButton setTitle: repsString
                         forState: UIControlStateNormal];
        
    } else{
        
        [self.repsButton setTitle: @"X"
                         forState: UIControlStateNormal];
        
    }
    
    // rest
    
    if (chainTemplate.targetingRestTime){
        
        [self.restButton setTitle: [[TJBStopwatch singleton] minutesAndSecondsStringFromNumberOfSeconds: [restTarget intValue]]
                         forState: UIControlStateNormal];
        
    } else{
        
        [self.restButton setTitle: @""
                         forState: UIControlStateNormal];
        
    }
    
}

- (void)configureViewForRelativeComparisonMode{
    
    // state
    
    _activeMode = RelativeComparisonMode;
    
    // buttons
    
    NSArray *buttons = @[self.weightButton,
                         self.repsButton,
                         self.restButton];
    for (UIButton *button in buttons){
        
        button.enabled = NO;
        
    }
    
    // aesthetis and functionality
    
    for (UIButton *b in buttons){
        
        b.enabled = NO;
        
        b.backgroundColor = [UIColor clearColor];
        [b setTitleColor: [UIColor blackColor]
                forState: UIControlStateNormal];
        
    }
    
    // round label text
    
    self.roundLabel.text = [NSString stringWithFormat: @"%d", [self.roundIndex intValue] + 1];
    
    // the data displayed in each button depends on the state.  There are three possible states: absolute comparison, relative comparison, editing
    
    //// absolute comparison
    // must first gather all of the appropriate data and then format it appropriately
    
    int exerciseInd = [self.exerciseIndex intValue];
    int roundInd = [self.roundIndex intValue];
    
    // targets
    
    TJBChainTemplate *chainTemplate = self.realizedChain.chainTemplate;
    
    // only grab targets if the type is being targeted, otherwise leave them as nil
    
    NSNumber *weightTarget;
    NSNumber *repsTarget;
    NSNumber *restTarget;
    
    if (chainTemplate.targetingWeight){
        weightTarget = [NSNumber numberWithFloat: chainTemplate.weightArrays[exerciseInd].numbers[roundInd].value];
    }
    
    if (chainTemplate.targetingReps){
        repsTarget = [NSNumber numberWithFloat: chainTemplate.repsArrays[exerciseInd].numbers[roundInd].value];
    }
    
    if (chainTemplate.targetingRestTime){
        restTarget = [NSNumber numberWithFloat: chainTemplate.targetRestTimeArrays[exerciseInd].numbers[roundInd].value];
    }
    
    // realizations
    // only grab realizations if this round and exercise are prior to the first incomplete round and exercise
    
    BOOL instanceHasOccurred = [TJBAssortedUtilities indiceWithExerciseIndex: exerciseInd
                                                                  roundIndex: roundInd
                                             isPriorToReferenceExerciseIndex: self.realizedChain.firstIncompleteExerciseIndex
                                                         referenceRoundIndex: self.realizedChain.firstIncompleteRoundIndex];
    
    NSNumber *realizedWeight;
    NSNumber *realizedReps;
    
    // the rest shown for a particular row is the rest that occurs after the set is completed, before the next set.  Thus I need to know when this set ended and when the next began
    
    NSDate *setEndDate;
    NSDate *nextSetBeginDate;
    
    NSNumber *nextRoundIndex;
    NSNumber *nextExerciseIndex;
    BOOL nextSetIsWithinIndiceRange = [TJBAssortedUtilities nextIndiceValuesForCurrentExerciseIndex: exerciseInd
                                                                                  currentRoundIndex: roundInd
                                                                                   maxExerciseIndex: chainTemplate.numberOfExercises - 1
                                                                                      maxRoundIndex: chainTemplate.numberOfRounds - 1
                                                                             exerciseIndexReference: &nextExerciseIndex
                                                                                roundIndexReference: &nextRoundIndex];
    BOOL nextSetHasOccurred = [TJBAssortedUtilities indiceWithExerciseIndex: [nextExerciseIndex intValue]
                                                                 roundIndex: [nextRoundIndex intValue]
                                            isPriorToReferenceExerciseIndex: self.realizedChain.firstIncompleteExerciseIndex
                                                        referenceRoundIndex: self.realizedChain.firstIncompleteRoundIndex];
    
    if (instanceHasOccurred){
        
        realizedWeight = [NSNumber numberWithFloat: self.realizedChain.weightArrays[exerciseInd].numbers[roundInd].value];
        realizedReps = [NSNumber numberWithFloat: self.realizedChain.repsArrays[exerciseInd].numbers[roundInd].value];
        
        // only grab the set end date if it is not a default object.  If an exact or approximate date was recorded, isDefaultObject should be NO
        
        if (self.realizedChain.setEndDateArrays[exerciseInd].dates[roundInd].isDefaultObject == NO){
            setEndDate = self.realizedChain.setEndDateArrays[exerciseInd].dates[roundInd].value;
        }
        
        // only grab the next set begin date if both (1) that instance occurred and (2) the next set begin date is not a default object
        
        if (nextSetIsWithinIndiceRange && nextSetHasOccurred){
            
            if (self.realizedChain.setBeginDateArrays[[nextExerciseIndex intValue]].dates[[nextRoundIndex intValue]].isDefaultObject == NO){
                
                nextSetBeginDate = self.realizedChain.setBeginDateArrays[[nextExerciseIndex intValue]].dates[[nextRoundIndex intValue]].value;
                
            }
            
        }
        
    }
    
    // now that all the data has been grabbed, it is time to format it
    // formatting will differ according to whether this instance has occurred
    // the rest string will require both the set end date and next set begin date exist in order to display a realized value
    
    // weight and reps
    
    if (instanceHasOccurred){
        
        // weight
        
        if (chainTemplate.targetingWeight){
            
            float weightDiff = [realizedWeight floatValue] - [weightTarget floatValue];
            NSString *weightText;
            if (weightDiff == 0){
                
                weightText = @"0 lbs";
                
            } else if (weightDiff > 0){
                
                weightText = [NSString stringWithFormat: @"+%.01f lbs", weightDiff];
                
            } else{
                
                weightText = [NSString stringWithFormat: @"%.01f lbs", weightDiff];
                
            }
            
            [self.weightButton setTitle: weightText
                               forState: UIControlStateNormal];
            
        } else{
            
            [self.weightButton setTitle: @"X"
                               forState: UIControlStateNormal];
            
        }
        
        // reps
        
        if (chainTemplate.targetingReps){
            
            float repsDiff = [realizedReps floatValue] - [repsTarget floatValue];
            NSString *repsText;
            if (repsDiff == 0){
                
                repsText = @"0 reps";
                
            } else if (repsDiff > 0){
                
                repsText = [NSString stringWithFormat: @"+%.00f reps", repsDiff];
                
            } else{
                
                repsText = [NSString stringWithFormat: @"%.00f reps", repsDiff];
                
            }
            
            [self.repsButton setTitle: repsText
                             forState: UIControlStateNormal];
            
        } else{
            
            [self.repsButton setTitle: @"X"
                             forState: UIControlStateNormal];
            
        }
        
    } else{
        
        // weight
        
        [self.weightButton setTitle: @""
                           forState: UIControlStateNormal];
        
        // reps
        
        [self.repsButton setTitle: @""
                         forState: UIControlStateNormal];
        
    }
    
    // rest
    
    // a realized rest will be shown only if all of the following conditions are met
    
    if (chainTemplate.targetingRestTime && nextSetHasOccurred && nextSetIsWithinIndiceRange && setEndDate && nextSetBeginDate){
        
        NSNumber *realizedRest = [NSNumber numberWithFloat: [nextSetBeginDate timeIntervalSinceDate: setEndDate]];
        float timeDiff = [realizedRest floatValue] - [restTarget floatValue];
        NSString *timeText = [[TJBStopwatch singleton] minutesAndSecondsStringFromNumberOfSeconds: (int)timeDiff];
        
        [self.restButton setTitle: timeText
                         forState: UIControlStateNormal];
        
        
    } else if(nextSetHasOccurred && nextSetIsWithinIndiceRange){
        
        [self.restButton setTitle: @"X"
                         forState:UIControlStateNormal];
        
    } else{
        
        [self.restButton setTitle: @""
                         forState: UIControlStateNormal];
        
    }
    
}

- (void)configureViewForAbsoluteComparisonMode{
    
    // state
    
    _activeMode = AbsoluteComparisonMode;
    
    // buttons
    
    NSArray *buttons = @[self.weightButton,
                         self.repsButton,
                         self.restButton];
    for (UIButton *button in buttons){
        
        button.enabled = NO;
        
    }
    
    // aesthetis and functionality
    
    for (UIButton *b in buttons){
        
        b.enabled = NO;
        
        b.backgroundColor = [UIColor clearColor];
        [b setTitleColor: [UIColor blackColor]
                forState: UIControlStateNormal];
        
    }
    
    
    
    // round label text
    
    self.roundLabel.text = [NSString stringWithFormat: @"%d", [self.roundIndex intValue] + 1];
    
    // the data displayed in each button depends on the state.  There are three possible states: absolute comparison, relative comparison, editing
    
    //// absolute comparison
    // must first gather all of the appropriate data and then format it appropriately
    
    int exerciseInd = [self.exerciseIndex intValue];
    int roundInd = [self.roundIndex intValue];
    
    // targets
    
    TJBChainTemplate *chainTemplate = self.realizedChain.chainTemplate;
    
    // only grab targets if the type is being targeted, otherwise leave them as nil
    
    NSNumber *weightTarget;
    NSNumber *repsTarget;
    NSNumber *restTarget;
    
    if (chainTemplate.targetingWeight){
        weightTarget = [NSNumber numberWithFloat: chainTemplate.weightArrays[exerciseInd].numbers[roundInd].value];
    }
    
    if (chainTemplate.targetingReps){
        repsTarget = [NSNumber numberWithFloat: chainTemplate.repsArrays[exerciseInd].numbers[roundInd].value];
    }
    
    if (chainTemplate.targetingRestTime){
        restTarget = [NSNumber numberWithFloat: chainTemplate.targetRestTimeArrays[exerciseInd].numbers[roundInd].value];
    }
    
    // realizations
    // only grab realizations if this round and exercise are prior to the first incomplete round and exercise
    
    BOOL instanceHasOccurred = [TJBAssortedUtilities indiceWithExerciseIndex: exerciseInd
                                                                  roundIndex: roundInd
                                             isPriorToReferenceExerciseIndex: self.realizedChain.firstIncompleteExerciseIndex
                                                         referenceRoundIndex: self.realizedChain.firstIncompleteRoundIndex];
    
    NSNumber *realizedWeight;
    NSNumber *realizedReps;
    
    // the rest shown for a particular row is the rest that occurs after the set is completed, before the next set.  Thus I need to know when this set ended and when the next began
    
    NSDate *setEndDate;
    NSDate *nextSetBeginDate;
    
    NSNumber *nextRoundIndex;
    NSNumber *nextExerciseIndex;
    BOOL nextSetIsWithinIndiceRange = [TJBAssortedUtilities nextIndiceValuesForCurrentExerciseIndex: exerciseInd
                                                                                  currentRoundIndex: roundInd
                                                                                   maxExerciseIndex: chainTemplate.numberOfExercises - 1
                                                                                      maxRoundIndex: chainTemplate.numberOfRounds - 1
                                                                             exerciseIndexReference: &nextExerciseIndex
                                                                                roundIndexReference: &nextRoundIndex];
    BOOL nextSetHasOccurred = [TJBAssortedUtilities indiceWithExerciseIndex: [nextExerciseIndex intValue]
                                                                 roundIndex: [nextRoundIndex intValue]
                                            isPriorToReferenceExerciseIndex: self.realizedChain.firstIncompleteExerciseIndex
                                                        referenceRoundIndex: self.realizedChain.firstIncompleteRoundIndex];
    
    if (instanceHasOccurred){
        
        realizedWeight = [NSNumber numberWithFloat: self.realizedChain.weightArrays[exerciseInd].numbers[roundInd].value];
        realizedReps = [NSNumber numberWithFloat: self.realizedChain.repsArrays[exerciseInd].numbers[roundInd].value];
        
        // only grab the set end date if it is not a default object.  If an exact or approximate date was recorded, isDefaultObject should be NO
        
        if (self.realizedChain.setEndDateArrays[exerciseInd].dates[roundInd].isDefaultObject == NO){
            setEndDate = self.realizedChain.setEndDateArrays[exerciseInd].dates[roundInd].value;
        }
        
        // only grab the next set begin date if both (1) that instance occurred and (2) the next set begin date is not a default object
        
        if (nextSetIsWithinIndiceRange && nextSetHasOccurred){
            
            if (self.realizedChain.setBeginDateArrays[[nextExerciseIndex intValue]].dates[[nextRoundIndex intValue]].isDefaultObject == NO){
                
                nextSetBeginDate = self.realizedChain.setBeginDateArrays[[nextExerciseIndex intValue]].dates[[nextRoundIndex intValue]].value;
                
            }
            
        }
        
    }
    
    // now that all the data has been grabbed, it is time to format it
    // formatting will differ according to whether this instance has occurred
    // the rest string will require both the set end date and next set begin date exist in order to display a realized value
    
    // weight and reps
    
    if (instanceHasOccurred){
        
        // weight
        
        if (chainTemplate.targetingWeight){
            
            [self.weightButton setTitle: [self displayStringForRealizedNumber: realizedWeight
                                                                 targetNumber: weightTarget
                                                         realizedNumberExists: YES
                                                           targetNumberExists: YES
                                                                   isTimeType: NO]
                               forState: UIControlStateNormal];
            
        } else{
            
            [self.weightButton setTitle: [self displayStringForRealizedNumber: realizedWeight
                                                                 targetNumber: weightTarget
                                                         realizedNumberExists: YES
                                                           targetNumberExists: NO
                                                                   isTimeType: NO]
                               forState: UIControlStateNormal];
            
        }
        
        // reps
        
        if (chainTemplate.targetingReps){
            
            [self.repsButton setTitle: [self displayStringForRealizedNumber: realizedReps
                                                               targetNumber: repsTarget
                                                       realizedNumberExists: YES
                                                         targetNumberExists: YES
                                                                 isTimeType: NO]
                             forState: UIControlStateNormal];
            
        } else{
            
            [self.repsButton setTitle: [self displayStringForRealizedNumber: realizedReps
                                                               targetNumber: repsTarget
                                                       realizedNumberExists: YES
                                                         targetNumberExists: NO
                                                                 isTimeType: NO]
                             forState: UIControlStateNormal];
            
        }
        
    }  else{
        
        // weight
        
        [self.weightButton setTitle: @""
                           forState: UIControlStateNormal];
        
        // reps
        
        [self.repsButton setTitle: @""
                         forState: UIControlStateNormal];
        
    }
    
    // rest
    
    // a realized rest will be shown only if all of the following conditions are met
    
    if (chainTemplate.targetingRestTime && nextSetHasOccurred && nextSetIsWithinIndiceRange && setEndDate && nextSetBeginDate){
        
        NSNumber *realizedRest = [NSNumber numberWithFloat: [nextSetBeginDate timeIntervalSinceDate: setEndDate]];
        float timeDiff = [realizedRest floatValue] - [restTarget floatValue];
        NSString *timeText = [[TJBStopwatch singleton] minutesAndSecondsStringFromNumberOfSeconds: (int)timeDiff];
        
        [self.restButton setTitle: timeText
                         forState: UIControlStateNormal];
        
        
    } else if(nextSetHasOccurred && nextSetIsWithinIndiceRange){
        
        [self.restButton setTitle: @"X"
                         forState:UIControlStateNormal];
        
    } else{
        
        [self.restButton setTitle: @""
                         forState: UIControlStateNormal];
        
    }
    
//    else{
//        
//        // weight
//        
//        if (chainTemplate.targetingWeight){
//            
//            [self.weightButton setTitle: [self displayStringForRealizedNumber: realizedWeight
//                                                                 targetNumber: weightTarget
//                                                         realizedNumberExists: NO
//                                                           targetNumberExists: YES
//                                                                   isTimeType: NO]
//                               forState: UIControlStateNormal];
//            
//        } else{
//            
//            [self.weightButton setTitle: [self displayStringForRealizedNumber: realizedWeight
//                                                                 targetNumber: weightTarget
//                                                         realizedNumberExists: NO
//                                                           targetNumberExists: NO
//                                                                   isTimeType: NO]
//                               forState: UIControlStateNormal];
//            
//        }
//        
//        // reps
//        
//        if (chainTemplate.targetingReps){
//            
//            [self.repsButton setTitle: [self displayStringForRealizedNumber: realizedReps
//                                                               targetNumber: repsTarget
//                                                       realizedNumberExists: NO
//                                                         targetNumberExists: YES
//                                                                 isTimeType: NO]
//                             forState: UIControlStateNormal];
//            
//        } else{
//            
//            [self.repsButton setTitle: [self displayStringForRealizedNumber: realizedReps
//                                                               targetNumber: repsTarget
//                                                       realizedNumberExists: NO
//                                                         targetNumberExists: NO
//                                                                 isTimeType: NO]
//                             forState: UIControlStateNormal];
//            
//        }
//        
//    }
//    
//    // rest
//    
//    if (chainTemplate.targetingRestTime){
//        
//        // a realized rest will be shown only if all of the following conditions are met
//        
//        if (nextSetHasOccurred && nextSetIsWithinIndiceRange && setEndDate && nextSetBeginDate){
//            
//            NSNumber *realizedRest = [NSNumber numberWithFloat: [nextSetBeginDate timeIntervalSinceDate: setEndDate]];
//            
//            [self.restButton setTitle: [self displayStringForRealizedNumber: realizedRest
//                                                               targetNumber: restTarget
//                                                       realizedNumberExists: YES
//                                                         targetNumberExists: YES
//                                                                 isTimeType: YES]
//                             forState: UIControlStateNormal];
//            
//            
//        } else{
//            
//            [self.restButton setTitle: [self displayStringForRealizedNumber: nil
//                                                               targetNumber: restTarget
//                                                       realizedNumberExists: NO
//                                                         targetNumberExists: YES
//                                                                 isTimeType: YES]
//                             forState:UIControlStateNormal];
//            
//        }
//        
//    } else{
//        
//        // a realized rest will be shown only if all of the following conditions are met
//        
//        if (nextSetHasOccurred && nextSetIsWithinIndiceRange && setEndDate && nextSetBeginDate){
//            
//            NSNumber *realizedRest = [NSNumber numberWithFloat: [nextSetBeginDate timeIntervalSinceDate: setEndDate]];
//            
//            [self.restButton setTitle: [self displayStringForRealizedNumber: realizedRest
//                                                               targetNumber: nil
//                                                       realizedNumberExists: YES
//                                                         targetNumberExists: NO
//                                                                 isTimeType: YES]
//                             forState: UIControlStateNormal];
//            
//            
//        } else{
//            
//            [self.restButton setTitle: [self displayStringForRealizedNumber: nil
//                                                               targetNumber: nil
//                                                       realizedNumberExists: NO
//                                                         targetNumberExists: NO
//                                                                 isTimeType: YES]
//                             forState: UIControlStateNormal];
//            
//        }
//        
//    }
    
}


- (void)configureViewForEditingMode{
    
    // state
    
    _activeMode = EditingMode;
    
    // aesthetics and functionality
    
    int exerciseInd = [self.exerciseIndex intValue];
    int roundInd = [self.roundIndex intValue];
    
    BOOL setHasOccurred = [TJBAssortedUtilities indiceWithExerciseIndex: exerciseInd
                                                             roundIndex: roundInd
                                        isPriorToReferenceExerciseIndex: self.realizedChain.firstIncompleteExerciseIndex
                                                    referenceRoundIndex: self.realizedChain.firstIncompleteRoundIndex];
    
    NSArray *buttons = @[self.weightButton,
                         self.repsButton];
    
    // if the set has actually occurred, then give it an active button appearance and enable it.  If not, simply give it a blank text string
    
    if (setHasOccurred){
        
        for (UIButton *button in buttons){
            
            button.backgroundColor = [[TJBAestheticsController singleton] blueButtonColor];
            [button setTitleColor: [UIColor whiteColor]
                         forState: UIControlStateNormal];
            button.enabled = YES;
            
        }
        
    } else{
        
        for (UIButton *button in buttons){
            
            button.enabled = NO;
            [button setTitle: @""
                    forState: UIControlStateNormal];\
            
        }
        
    }
    
    // display data
    // if the set has occurred, then fill in the appropriate data
    
    if (setHasOccurred){
        
        [self.weightButton setTitle: [self realizedWeightString]
                           forState: UIControlStateNormal];
        
        [self.repsButton setTitle: [self realizedRepsString]
                         forState: UIControlStateNormal];
        
    } else{
        
        for (UIButton *button in buttons){
            
            [button setTitle: @""
                    forState: UIControlStateNormal];
            
        }
        
    }
    
    // the user cannot edit rest times.  Simply show a blank string as the rest button title
    
    [self.restButton setTitle: @""
                     forState: UIControlStateNormal];
    
}

#pragma mark - Convenience


- (NSString *)displayStringForRealizedNumber:(NSNumber *)realizedNumber targetNumber:(NSNumber *)targetNumber realizedNumberExists:(BOOL)realizedNumberExists targetNumberExists:(BOOL)targetNumberExists isTimeType:(BOOL)isTimeType{
    
    if (isTimeType){
        
        NSString *realizedTime = [[TJBStopwatch singleton] minutesAndSecondsStringFromNumberOfSeconds: [realizedNumber intValue]];
        NSString *targetTime = [[TJBStopwatch singleton] minutesAndSecondsStringFromNumberOfSeconds: [targetNumber intValue]];
        
        if (realizedNumberExists && targetNumberExists){
            
            return [NSString stringWithFormat: @"%@ / %@", realizedTime, targetTime];
            
        } else if (!realizedNumberExists && targetNumberExists){
            
            return [NSString stringWithFormat: @"X / %@", targetTime];
            
        } else if (realizedNumberExists & !targetNumberExists){
            
            return [NSString stringWithFormat: @"%@ / X", realizedTime];
            
        } else{
            
            return [NSString stringWithFormat: @"X / X"];
            
        }
        
    } else{
        
        if (realizedNumberExists && targetNumberExists){
            
            return [NSString stringWithFormat: @"%@ / %@", [realizedNumber stringValue], [targetNumber stringValue]];
            
        } else if (!realizedNumberExists && targetNumberExists){
            
            return [NSString stringWithFormat: @"X / %@", [targetNumber stringValue]];
            
        } else if (realizedNumberExists & !targetNumberExists){
            
            return [NSString stringWithFormat: @"%@ / X", [realizedNumber stringValue]];
            
        } else{
            
            return [NSString stringWithFormat: @"X / X"];
            
        }
        
    }
    
}



- (NSString *)realizedWeightString{
    
    NSNumber *weight = [NSNumber numberWithFloat: self.realizedChain.weightArrays[[self.exerciseIndex intValue]].numbers[[self.roundIndex intValue]].value];
    
    return [weight stringValue];
    
}

- (NSString *)realizedRepsString{
    
    NSNumber *reps = [NSNumber numberWithFloat: self.realizedChain.repsArrays[[self.exerciseIndex intValue]].numbers[[self.roundIndex intValue]].value];
    
    return [reps stringValue];
    
}

#pragma mark - Class API

- (void)activateMode:(TJBRoutineReferenceMode)mode{
    
    switch (mode) {
        case EditingMode:
            [self configureViewForEditingMode];
            break;
            
        case AbsoluteComparisonMode:
            [self configureViewForAbsoluteComparisonMode];
            break;
            
        case RelativeComparisonMode:
            [self configureViewForRelativeComparisonMode];
            break;
            
        case TargetsMode:
            [self configureViewForTargetsMode];
            break;
            
        default:
            break;
    
    }
    
}

#pragma mark - Target Action

- (IBAction)didPressWeightButton:(id)sender{
    
    // present the single number selection scene.  If a number is chosen, update core data and refresh the view
    
    CancelBlock cancelBlock = ^{
        
      [self dismissViewControllerAnimated: NO
                               completion: nil];
        
    };
    
    NumberSelectedBlockSingle numberSelectedBlock = ^(NSNumber *selectedNumber){
        
        // update the realized chain and save core data changes
        
        int exerciseInd = [self.exerciseIndex intValue];
        int roundInd = [self.roundIndex intValue];
        
        self.realizedChain.weightArrays[exerciseInd].numbers[roundInd].value = [selectedNumber floatValue];
        
        [[CoreDataController singleton] saveContext];
        
        // reload view data
        
        [self activateMode: _activeMode];
         
        // presented VC
        
        [self dismissViewControllerAnimated: NO
                                 completion: nil];
        
    };
    
    TJBNumberSelectionVC *vc = [[TJBNumberSelectionVC alloc] initWithNumberTypeIdentifier: WeightType
                                                                                    title: @"Select Weight"
                                                                              cancelBlock: cancelBlock
                                                                      numberSelectedBlock: numberSelectedBlock];
    
    [self presentViewController: vc
                       animated: YES
                     completion: nil];
    
}

- (IBAction)didPressRepsButton:(id)sender{
    
    // present the single number selection scene.  If a number is chosen, update core data and refresh the view
    
    // present the single number selection scene.  If a number is chosen, update core data and refresh the view
    
    CancelBlock cancelBlock = ^{
        
        [self dismissViewControllerAnimated: NO
                                 completion: nil];
        
    };
    
    NumberSelectedBlockSingle numberSelectedBlock = ^(NSNumber *selectedNumber){
        
        // update the realized chain and save core data changes
        
        int exerciseInd = [self.exerciseIndex intValue];
        int roundInd = [self.roundIndex intValue];
        
        self.realizedChain.repsArrays[exerciseInd].numbers[roundInd].value = [selectedNumber floatValue];
        
        [[CoreDataController singleton] saveContext];
        
        // reload view data
        
        [self activateMode: _activeMode];
        
        // presented VC
        
        [self dismissViewControllerAnimated: NO
                                 completion: nil];
        
    };
    
    TJBNumberSelectionVC *vc = [[TJBNumberSelectionVC alloc] initWithNumberTypeIdentifier: RepsType
                                                                                    title: @"Select Reps"
                                                                              cancelBlock: cancelBlock
                                                                      numberSelectedBlock: numberSelectedBlock];
    
    [self presentViewController: vc
                       animated: YES
                     completion: nil];
    
}









@end






























































