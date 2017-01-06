//
//  CoreDataController.h
//  Beast
//
//  Created by Trevor Beasty on 12/9/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreData/CoreData.h>

#import "TJBExercise+CoreDataProperties.h"
#import "TJBExerciseCategory+CoreDataProperties.h"

#import "TJBRealizedSet+CoreDataProperties.h"

#import "TJBChainTemplate+CoreDataProperties.h"

#import "TJBRealizedChain+CoreDataProperties.h"

#import "TJBDateTypeArrayComp+CoreDataProperties.h"

extern NSString * const ExerciseDataChanged;

@interface CoreDataController : NSObject

@property (readonly, strong) NSPersistentContainer *persistentContainer;

+ (instancetype)singleton;

- (TJBExercise *)exerciseForName:(NSString *)name;
- (BOOL)realizedSetExerciseExistsForName:(NSString *)name;

- (TJBExerciseCategory *)exerciseCategoryForName:(NSString *)name;

- (void)saveContext;

- (NSManagedObjectContext *)moc;





@end
