//
//  TJBCircuitActiveUpdatingVC.m
//  Beast
//
//  Created by Trevor Beasty on 1/11/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBCircuitActiveUpdatingVC.h"

// core data

#import "TJBRealizedChain+CoreDataProperties.h"

@interface TJBCircuitActiveUpdatingVC ()

// core

@property (nonatomic, strong) TJBRealizedChain *realizedChain;
@property (nonatomic, strong) NSNumber *viewHeight;
@property (nonatomic, strong) NSNumber *viewWidth;

// IV's derived from chainTemplate

@property (nonatomic, strong) NSNumber *numberOfExercises;
@property (nonatomic, strong) NSNumber *numberOfRounds;

@property (nonatomic, strong) NSNumber *targetingWeight;
@property (nonatomic, strong) NSNumber *targetingReps;
@property (nonatomic, strong) NSNumber *targetingRest;
@property (nonatomic, strong) NSNumber *targetsVaryByRound;

@property (nonatomic, strong) NSString *name;

// for programmatic layout constraints

@property (nonatomic, strong) NSMutableDictionary *constraintMapping;

@end

@implementation TJBCircuitActiveUpdatingVC

#pragma mark - Instantiation

- (instancetype)initWithRealizedChain:(TJBRealizedChain *)realizedChain viewHeight:(NSNumber *)viewHeight viewWidth:(NSNumber *)viewWidth{
    
    self = [super init];
    
    // core
    
    self.realizedChain = realizedChain;
    self.viewHeight = viewHeight;
    self.viewWidth = viewWidth;
    
    // set IV's derived from chain template
    
    NSNumber *numberOfRounds;
    
    if (realizedChain.targetingWeight == YES){
        TJBWeightArray *weightArray = realizedChain.weightArrays[0];
        numberOfRounds = [NSNumber numberWithUnsignedLong: [weightArray.numbers count]];
    } else if (chainTemplate.targetingReps == YES){
        TJBRepsArray *repsArray = chainTemplate.repsArrays[0];
        numberOfRounds = [NSNumber numberWithUnsignedLong: [repsArray.numbers count]];
    } else if (chainTemplate.targetingRestTime == YES){
        TJBTargetRestTimeArray *restArray = chainTemplate.targetRestTimeArrays[0];
        numberOfRounds = [NSNumber numberWithUnsignedLong: [restArray.numbers count]];
    }
    
    self.numberOfRounds = numberOfRounds;
    
    self.numberOfExercises = [NSNumber numberWithUnsignedLong: chainTemplate.exercises.count];
    
    self.targetingWeight = [NSNumber numberWithBool: chainTemplate.targetingWeight];
    self.targetingReps = [NSNumber numberWithBool: chainTemplate.targetingReps];
    self.targetingRest = [NSNumber numberWithBool: chainTemplate.targetingRestTime];
    self.targetsVaryByRound = [NSNumber numberWithBool: chainTemplate.targetsVaryByRound];
    
    self.name = chainTemplate.name;
    
    return self;
}

@end





























