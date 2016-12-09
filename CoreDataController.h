//
//  CoreDataController.h
//  Beast
//
//  Created by Trevor Beasty on 12/9/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreData/CoreData.h>

#import "TJBExerciseCategory+CoreDataProperties.h"
#import "TJBRealizedSetExercise+CoreDataProperties.h"

@interface CoreDataController : NSObject

@property (readonly, strong) NSPersistentContainer *persistentContainer;

+ (instancetype)singleton;

- (TJBRealizedSetExercise *)realizedSetExerciseForName:(NSString *)name;
- (BOOL)realizedSetExerciseExistsForName:(NSString *)name;

- (TJBExerciseCategory *)exerciseCategoryForName:(NSString *)name;

- (void)saveContext;





@end
