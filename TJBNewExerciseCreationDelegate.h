//
//  TJBNewExerciseCreationDelegate.h
//  Beast
//
//  Created by Trevor Beasty on 12/9/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "CoreDataController.h"

#import "TJBRealizedSetExercise+CoreDataProperties.h"

@protocol NewExerciseCreationDelegate <NSObject>

- (void)didCreateNewExercise:(TJBRealizedSetExercise *)exercise;

@end
