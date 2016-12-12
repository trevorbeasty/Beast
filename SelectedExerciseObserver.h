//
//  SelectedExerciseObserver.h
//  Beast
//
//  Created by Trevor Beasty on 12/12/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TJBRealizedSetExercise;

@protocol SelectedExerciseObserver <NSObject>

- (void)didSelectExercise:(TJBRealizedSetExercise *)exercise;
- (void)newSetSubmitted;

@end
