//
//  CoreDataController.h
//  Beast
//
//  Created by Trevor Beasty on 12/9/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreData/CoreData.h>

// all core data classes
// I want to have it so that any class that interacts with core data can simply import the CoreDataController to get all required class imports

#import "TJBExercise+CoreDataProperties.h"
#import "TJBExerciseCategory+CoreDataProperties.h"

#import "TJBChainTemplate+CoreDataProperties.h"
#import "TJBTargetUnitCollection+CoreDataProperties.h"
#import "TJBTargetUnit+CoreDataProperties.h"

#import "TJBRealizedChain+CoreDataProperties.h"
#import "TJBRealizedSetCollection+CoreDataProperties.h"
#import "TJBRealizedSet+CoreDataProperties.h"


extern NSString * const ExerciseDataChanged;
extern NSString * const placeholderExerciseName;

typedef enum{
    ChainTemplateType,
    RealizedChainType
} ChainType;

typedef enum{
    PushType,
    PullType,
    LegsType,
    OtherType,
    PlaceholderType
}TJBExerciseCategoryType;

@interface CoreDataController : NSObject

@property (readonly, strong) NSPersistentContainer *persistentContainer;

+ (instancetype)singleton;

// specific queries and inquiries

// the following assigns the value of TJBExercise via pass by reference because it also must report whether the object was newly created
// if newly created, it is the job of the calling class to assign the new exercise a category
// if a category is not assigned, an error will occur when attemting to save managed object changes

- (TJBExercise *)exerciseForName:(NSString *)name wasNewlyCreated:(NSNumber **)wasNewlyCreated createAsPlaceholderExercise:(NSNumber *)createAsPlaceholderExercise;

- (BOOL)exerciseExistsForName:(NSString *)name;

- (TJBExerciseCategory *)exerciseCategory:(TJBExerciseCategoryType)exerciseCategory;
- (NSString *)categoryStingFromEnum:(TJBExerciseCategoryType)categoryEnum;

- (TJBRealizedChain *)realizedChainWithUniqueID:(NSString *)uniqueID;
- (TJBChainTemplate *)chainTemplateWithUniqueID:(NSString *)uniqueID;

//

- (void)saveContext;

- (NSManagedObjectContext *)moc;

- (void)deleteRealizedChain:(TJBRealizedChain *)rc;
- (void)deleteChainTemplate:(TJBChainTemplate *)ct;

//// chains

// chain template

- (NSMutableOrderedSet *)placeholderExerciseSetWithLength:(int)length;
- (NSMutableArray *)placeholderExerciseArrayWithLength:(int)length;

- (TJBChainTemplate *)createAndSaveSkeletonChainTemplateWithNumberOfExercises:(NSNumber *)numberOfExercises numberOfRounds:(NSNumber *)numberOfRounds name:(NSString *)name isTargetingWeight:(BOOL)isTargetingWeight isTargetingReps:(BOOL)isTargetingReps isTargetingTrailingRest:(BOOL)isTargetingTrailingRest;

- (BOOL)chainTemplateHasCollectedAllRequisiteUserInput:(TJBChainTemplate *)chainTemplate;

// realized chain

- (TJBRealizedChain *)createAndSaveSkeletonRealizedChainForChainTemplate:(TJBChainTemplate *)chainTemplate;

// checking if an object is a default object

- (BOOL)exerciseIsPlaceholderExercise:(TJBExercise *)exercise;

// existing chain template manipulation

- (void)appendRoundToChainTemplate:(TJBChainTemplate *)chainTemplate;
- (void)deleteLastRoundInChainTemplate:(TJBChainTemplate *)chainTemplate;

- (void)appendExerciseToChainTemplate:(TJBChainTemplate *)chainTemplate;
- (void)deleteLastExercisefromChainTemplate:(TJBChainTemplate *)chainTemplate;

- (void)appendPlaceholderExerciseToSelectedExercisesSet:(NSMutableOrderedSet <TJBExercise *> *)exercises;

@end
















