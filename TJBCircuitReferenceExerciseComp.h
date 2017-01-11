//
//  TJBCircuitReferenceExerciseComp.h
//  Beast
//
//  Created by Trevor Beasty on 1/11/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

// core data

@class  TJBExercise;
#import "TJBNumberTypeArrayComp+CoreDataClass.h"

//#import "TJBExercise+CoreDataProperties.h"


@interface TJBCircuitReferenceExerciseComp : UIViewController

- (instancetype)initWithNumberOfRounds:(NSNumber *)numberOfRounds targetingWeight:(NSNumber *)targetingWeight targetingReps:(NSNumber *)targetingReps targetingRest:(NSNumber *)targetingRest targetsVaryByRound:(NSNumber *)targetsVaryByRound chainNumber:(NSNumber *)chainNumber exercise:(TJBExercise *)exercise weightData:(NSOrderedSet<TJBNumberTypeArrayComp *> *)weightData repsData:(NSOrderedSet<TJBNumberTypeArrayComp *> *)repsData restData:(NSOrderedSet<TJBNumberTypeArrayComp *> *)restData;

@end
