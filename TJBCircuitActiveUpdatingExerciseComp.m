//
//  TJBCircuitActiveUpdatingExerciseComp.m
//  Beast
//
//  Created by Trevor Beasty on 1/11/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBCircuitActiveUpdatingExerciseComp.h"

// core data

#import "TJBNumberTypeArrayComp+CoreDataProperties.h"
#import "TJBExercise+CoreDataProperties.h"
#import "TJBBeginDateComp+CoreDataProperties.h"
#import "TJBEndDateComp+CoreDataProperties.h"

@interface TJBCircuitActiveUpdatingExerciseComp ()


// core

@property (nonatomic, strong) NSNumber *numberOfRounds;
@property (nonatomic, strong) NSNumber *targetsVaryByRound;
@property (nonatomic, strong) NSNumber *chainNumber;
@property (nonatomic, strong) TJBExercise *exercise;
@property (nonatomic, strong) NSNumber *maxExerciseIndexToFill;
@property (nonatomic, strong) NSNumber *maxRoundIndexToFill;
@property (nonatomic, strong) NSOrderedSet <TJBNumberTypeArrayComp *> *weightData;
@property (nonatomic, strong) NSOrderedSet <TJBNumberTypeArrayComp *> *repsData;
@property (nonatomic, strong) NSOrderedSet <TJBBeginDateComp *> *setBeginDates;
@property (nonatomic, strong) NSOrderedSet <TJBEndDateComp *> *setEndDates;

// IBOutlets

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *roundColumnLabel;
@property (weak, nonatomic) IBOutlet UILabel *weightColumnLabel;
@property (weak, nonatomic) IBOutlet UILabel *repsColumnLabel;
@property (weak, nonatomic) IBOutlet UILabel *restColumnLabel;
@property (weak, nonatomic) IBOutlet UILabel *thinLineLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectedExerciseButton;
@property (weak, nonatomic) IBOutlet UILabel *setLengthColumnLabel;

// for programmatic auto layout constraints

@property (nonatomic, strong) NSMutableDictionary *constraintMapping;

@end

@implementation TJBCircuitActiveUpdatingExerciseComp

- (instancetype)initWithNumberOfRounds:(NSNumber *)numberOfRounds targetsVaryByRound:(NSNumber *)targetsVaryByRound chainNumber:(NSNumber *)chainNumber exercise:(TJBExercise *)exercise weightData:(NSOrderedSet<TJBNumberTypeArrayComp *> *)weightData repsData:(NSOrderedSet<TJBNumberTypeArrayComp *> *)repsData setBeginDates:(NSOrderedSet<TJBBeginDateComp *> *)setBeginDates setEndDates:(NSOrderedSet<TJBEndDateComp *> *)setEndDates maxExerciseIndexToFill:(NSNumber *)maxExerciseIndexToFill maxRoundIndexToFill:(NSNumber *)maxRoundIndexToFill{
    
    self = [super init];
    
    self.numberOfRounds = numberOfRounds;
    self.targetsVaryByRound = targetsVaryByRound;
    self.chainNumber = chainNumber;
    self.exercise = exercise;
    self.weightData = weightData;
    self.repsData = repsData;
    self.setBeginDates = setBeginDates;
    self.setEndDates = setEndDates;
    self.maxExerciseIndexToFill = maxExerciseIndexToFill;
    self.maxRoundIndexToFill = maxRoundIndexToFill;
    
    
    return self;
}

@end




































