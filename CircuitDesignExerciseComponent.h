//
//  CircuitDesignExerciseComponent.h
//  Beast
//
//  Created by Trevor Beasty on 12/13/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

// break it out.  Use xibs as much as possible cause adding constraints programmatically sucks ass.     One exercise component will consist of 2 classes - (1) a class that has the title bar and column labels and dynamically adds rows as needed (2) the class that constitutes a single row;  it's container view will be added as a subview to class in (1) and I will need to add programmatic constraints there.  (1) will also load 1 of 2 nibs based on whether or not targets vary across rounds;

@interface CircuitDesignExerciseComponent : UIViewController

@property (nonatomic, strong) NSNumber *numberOfRounds;
@property (nonatomic, strong) NSNumber *targetingWeight;
@property (nonatomic, strong) NSNumber *targetingReps;
@property (nonatomic, strong) NSNumber *targetingRest;
@property (nonatomic, strong) NSNumber *targetsVaryByRound;

@property (nonatomic, strong) NSNumber *chainIndex;
@property (nonatomic, strong) NSString *exerciseName;

@property (nonatomic, strong) NSMutableDictionary *codedViewMapping;

- (instancetype)initWithNumberOfRounds:(NSNumber *)numberOfRounds targetingWeight:(NSNumber *)targetingWeight targetingReps:(NSNumber *)targetingReps targetingRest:(NSNumber *)targetingRest targetsVaryByRound:(NSNumber *)targetsVaryByRound chainIndex:(NSNumber *)chainIndex exerciseName:(NSString *)exerciseName;

@end
