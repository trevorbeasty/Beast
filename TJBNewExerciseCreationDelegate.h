//
//  TJBNewExerciseCreationDelegate.h
//  Beast
//
//  Created by Trevor Beasty on 12/9/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CoreDataController.h"



@protocol NewExerciseCreationDelegate <NSObject>

- (void)didCreateNewExercise:(TJBExercise *)exercise;

@end
