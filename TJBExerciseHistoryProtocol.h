//
//  TJBExerciseHistoryProtocol.h
//  Beast
//
//  Created by Trevor Beasty on 4/10/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <Foundation/Foundation.h>

// core data

@class TJBExercise;

@protocol TJBExerciseHistoryProtocol <NSObject>

- (void)activeExerciseDidUpdate:(TJBExercise *)exercise;

@end
