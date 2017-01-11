//
//  TJBCircuitReferenceExerciseComp.m
//  Beast
//
//  Created by Trevor Beasty on 1/11/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBCircuitReferenceExerciseComp.h"

// core data

#import "TJBExercise+CoreDataProperties.h"

@interface TJBCircuitReferenceExerciseComp ()

// core

@property (nonatomic, strong) NSNumber *numberOfRounds;
@property (nonatomic, strong) NSNumber *targetingWeight;
@property (nonatomic, strong) NSNumber *targetingReps;
@property (nonatomic, strong) NSNumber *targetingRest;
@property (nonatomic, strong) NSNumber *targetsVaryByRound;
@property (nonatomic, strong) NSNumber *chainNumber;
@property (nonatomic, strong) TJBExercise *exercise;
@property (nonatomic, strong) NSOrderedSet <TJBNumberTypeArrayComp *> *weightData;
@property (nonatomic, strong) NSOrderedSet <TJBNumberTypeArrayComp *> *repsData;
@property (nonatomic, strong) NSOrderedSet <TJBNumberTypeArrayComp *> *restData;


@end

@implementation TJBCircuitReferenceExerciseComp

- (instancetype)initWithNumberOfRounds:(NSNumber *)numberOfRounds targetingWeight:(NSNumber *)targetingWeight targetingReps:(NSNumber *)targetingReps targetingRest:(NSNumber *)targetingRest targetsVaryByRound:(NSNumber *)targetsVaryByRound chainNumber:(NSNumber *)chainNumber exercise:(TJBExercise *)exercise weightData:(NSOrderedSet<TJBNumberTypeArrayComp *> *)weightData repsData:(NSOrderedSet<TJBNumberTypeArrayComp *> *)repsData restData:(NSOrderedSet<TJBNumberTypeArrayComp *> *)restData{
    
    self = [super init];
    
    self.numberOfRounds = numberOfRounds;
    self.targetingWeight = targetingWeight;
    self.targetingReps = targetingReps;
    self.targetingRest = targetingRest;
    self.targetsVaryByRound = targetsVaryByRound;
    self.chainNumber = chainNumber;
    self.exercise = exercise;
    self.weightData = weightData;
    self.repsData = repsData;
    self.restData = restData;

    
    return self;
}



@end
