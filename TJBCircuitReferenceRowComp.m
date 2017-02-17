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

@interface TJBCircuitReferenceRowComp ()

// core

@property (nonatomic, strong) NSNumber *exerciseIndex;
@property (nonatomic, strong) NSNumber *roundIndex;

@property (nonatomic, strong) TJBRealizedChain *realizedChain;

// IBOutlet

@property (weak, nonatomic) IBOutlet UIButton *weightButton;
@property (weak, nonatomic) IBOutlet UIButton *repsButton;
@property (weak, nonatomic) IBOutlet UIButton *restButton;
@property (weak, nonatomic) IBOutlet UILabel *roundLabel;

@end

@implementation TJBCircuitReferenceRowComp

#pragma mark - Instantiation

- (instancetype)initWithRealizedChain:(TJBRealizedChain *)realizedChain exerciseIndex:(int)exerciseIndex roundIndex:(int)roundIndex{
    
    self = [super init];
    
    self.exerciseIndex = [NSNumber numberWithInt: exerciseIndex];
    self.roundIndex = [NSNumber numberWithInt: roundIndex];
    self.realizedChain = realizedChain;
    
    return self;
    
}

#pragma mark - View Life Cycle

- (void)viewDidLoad{
    
    [self configureViewData];
}

- (void)configureViewData{

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
        
    } else{
        
        // weight
        
        if (chainTemplate.targetingWeight){
            
            [self.weightButton setTitle: [self displayStringForRealizedNumber: realizedWeight
                                                                 targetNumber: weightTarget
                                                         realizedNumberExists: NO
                                                           targetNumberExists: YES
                                                                   isTimeType: NO]
                               forState: UIControlStateNormal];
            
        } else{
            
            [self.weightButton setTitle: [self displayStringForRealizedNumber: realizedWeight
                                                                 targetNumber: weightTarget
                                                         realizedNumberExists: NO
                                                           targetNumberExists: NO
                                                                   isTimeType: NO]
                               forState: UIControlStateNormal];
            
        }
        
        // reps
        
        if (chainTemplate.targetingReps){
            
            [self.repsButton setTitle: [self displayStringForRealizedNumber: realizedReps
                                                               targetNumber: repsTarget
                                                       realizedNumberExists: NO
                                                         targetNumberExists: YES
                                                                 isTimeType: NO]
                             forState: UIControlStateNormal];
            
        } else{
            
            [self.repsButton setTitle: [self displayStringForRealizedNumber: realizedReps
                                                               targetNumber: repsTarget
                                                       realizedNumberExists: NO
                                                         targetNumberExists: NO
                                                                 isTimeType: NO]
                             forState: UIControlStateNormal];
            
        }
        
    }
    
    // rest
    
    if (chainTemplate.targetingRestTime){
        
        // a realized rest will be shown only if all of the following conditions are met
        
        if (nextSetHasOccurred && nextSetIsWithinIndiceRange && setEndDate && nextSetBeginDate){
            
            NSNumber *realizedRest = [NSNumber numberWithFloat: [nextSetBeginDate timeIntervalSinceDate: setEndDate]];
            
            [self.restButton setTitle: [self displayStringForRealizedNumber: realizedRest
                                                              targetNumber: restTarget
                                                      realizedNumberExists: YES
                                                        targetNumberExists: YES
                                                                isTimeType: YES]
                             forState: UIControlStateNormal];
            
            
        } else{
            
            [self.restButton setTitle: [self displayStringForRealizedNumber: nil
                                                               targetNumber: restTarget
                                                       realizedNumberExists: NO
                                                         targetNumberExists: YES
                                                                 isTimeType: YES]
                             forState:UIControlStateNormal];
            
        }
        
    } else{
        
        // a realized rest will be shown only if all of the following conditions are met
        
        if (nextSetHasOccurred && nextSetIsWithinIndiceRange && setEndDate && nextSetBeginDate){
            
            NSNumber *realizedRest = [NSNumber numberWithFloat: [nextSetBeginDate timeIntervalSinceDate: setEndDate]];
            
            [self.restButton setTitle: [self displayStringForRealizedNumber: realizedRest
                                                               targetNumber: nil
                                                       realizedNumberExists: YES
                                                         targetNumberExists: NO
                                                                 isTimeType: YES]
                             forState: UIControlStateNormal];
            
            
        } else{
            
            [self.restButton setTitle: [self displayStringForRealizedNumber: nil
                                                               targetNumber: nil
                                                       realizedNumberExists: NO
                                                         targetNumberExists: NO
                                                                 isTimeType: YES]
                             forState: UIControlStateNormal];
            
        }
        
    }
    
    
    
}

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



@end
























































