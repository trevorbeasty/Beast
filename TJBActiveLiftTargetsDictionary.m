//
//  TJBActiveLiftTargetsDictionary.m
//  Beast
//
//  Created by Trevor Beasty on 4/20/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBActiveLiftTargetsDictionary.h"

#import "TJBExercise+CoreDataProperties.h" // core data

@interface TJBActiveLiftTargetsDictionary ()

@property (strong) NSMutableDictionary *proxy;

@end

#pragma mark - Keys

static NSString * const exerciseKey = @"exercise";
static NSString * const repsKey = @"reps";
static NSString * const weightKey = @"weight";
static NSString * const restKey = @"restKey";

@implementation TJBActiveLiftTargetsDictionary


#pragma mark - Writing

- (instancetype)initWithExercise:(TJBExercise *)exercise weight:(NSNumber *)weight reps:(NSNumber *)reps rest:(NSNumber *)rest{
    
    self = [super init];
    
    self.proxy = [[NSMutableDictionary alloc] initWithObjects: @[exercise, weight, reps, rest]
                                                      forKeys: @[exerciseKey, weightKey, repsKey, restKey]];
    
    return self;
    
}



#pragma mark - Reading


- (TJBExercise *)exercise{
    
    return  [self.proxy objectForKey: exerciseKey];
    
}

- (NSNumber *)weight{
    
    return [self.proxy objectForKey: weightKey];
    
}


- (NSNumber *)reps{
    
    return  [self.proxy objectForKey: repsKey];
    
}

- (NSNumber *)rest{
    
    return [self.proxy objectForKey: restKey];
    
}











@end

































