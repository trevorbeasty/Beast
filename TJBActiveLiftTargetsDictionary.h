//
//  TJBActiveLiftTargetsDictionary.h
//  Beast
//
//  Created by Trevor Beasty on 4/20/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TJBExercise; // core data

@interface TJBActiveLiftTargetsDictionary : NSObject


#pragma mark - Writing

- (instancetype)initWithExercise:(TJBExercise *)exercise weight:(NSNumber *)weight reps:(NSNumber *)reps rest:(NSNumber *)rest;

#pragma mark - Reading

- (TJBExercise *)exercise;
- (NSNumber *)weight;
- (NSNumber *)reps;
- (NSNumber *)rest;

@end
