//
//  CircuitDesignExerciseComponent.h
//  Beast
//
//  Created by Trevor Beasty on 12/13/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CircuitDesignExerciseComponent : UIViewController

@property (nonatomic, strong) NSNumber *numberOfRounds;
@property (nonatomic, strong) NSNumber *targetingWeight;
@property (nonatomic, strong) NSNumber *targetingReps;
@property (nonatomic, strong) NSNumber *targetingRest;
@property (nonatomic, strong) NSNumber *targetsVaryByRound;

@property (nonatomic, strong) NSNumber *chainIndex;
@property (nonatomic, strong) NSString *exerciseName;

@property (nonatomic, strong) NSMutableDictionary *codedViewMapping;

- (instancetype)initWithNumberOfRounds:(NSNumber *)numberOfRounds targetingWeight:(NSNumber *)targetingWeight targetingReps:(NSNumber *)targetingReps targetingRest:(NSNumber *)targetingRest targetsVaryByRound:(NSNumber *)targetsVaryByRound;

@end
