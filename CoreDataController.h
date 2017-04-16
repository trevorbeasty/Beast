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

typedef NSArray<TJBRealizedSet *> *TJBRealizedSetGrouping;








@interface CoreDataController : NSObject

@property (readonly, strong) NSPersistentContainer *persistentContainer;


#pragma mark - Meta Items

+ (instancetype)singleton;

- (void)saveContext;
- (NSManagedObjectContext *)moc;

#pragma mark - Managed Object Queries

// exercises and categories

- (BOOL)exerciseIsPlaceholderExercise:(TJBExercise *)exercise;
- (BOOL)exerciseExistsForName:(NSString *)name;
- (TJBExerciseCategory *)exerciseCategory:(TJBExerciseCategoryType)exerciseCategory;
- (NSString *)categoryStingFromEnum:(TJBExerciseCategoryType)categoryEnum;

// chain template

- (BOOL)chainTemplateHasCollectedAllRequisiteUserInput:(TJBChainTemplate *)chainTemplate;
- (TJBChainTemplate *)chainTemplateWithUniqueID:(NSString *)uniqueID;

// realized chain

- (TJBRealizedChain *)realizedChainWithUniqueID:(NSString *)uniqueID;

#pragma mark - Managed Object Creation

// realized chain

- (TJBRealizedChain *)createAndSaveSkeletonRealizedChainForChainTemplate:(TJBChainTemplate *)chainTemplate;

// chain template

- (TJBChainTemplate *)createAndSaveSkeletonChainTemplateWithNumberOfExercises:(NSNumber *)numberOfExercises numberOfRounds:(NSNumber *)numberOfRounds name:(NSString *)name isTargetingWeight:(BOOL)isTargetingWeight isTargetingReps:(BOOL)isTargetingReps isTargetingTrailingRest:(BOOL)isTargetingTrailingRest;

// exercises

- (NSMutableOrderedSet *)placeholderExerciseSetWithLength:(int)length;
- (NSMutableArray *)placeholderExerciseArrayWithLength:(int)length;
- (TJBExercise *)exerciseForName:(NSString *)name wasNewlyCreated:(NSNumber **)wasNewlyCreated createAsPlaceholderExercise:(NSNumber *)createAsPlaceholderExercise;

#pragma mark - Managed Object Deletion

- (void)deleteRealizedChain:(TJBRealizedChain *)rc;
- (void)deleteChainTemplate:(TJBChainTemplate *)ct;
- (void)deleteRealizeSet:(TJBRealizedSet *)rs;

#pragma mark - Chain Template Manipulation

- (void)appendRoundToChainTemplate:(TJBChainTemplate *)chainTemplate;
- (void)deleteLastRoundInChainTemplate:(TJBChainTemplate *)chainTemplate;

- (void)appendExerciseToChainTemplate:(TJBChainTemplate *)chainTemplate;
- (void)deleteLastExercisefromChainTemplate:(TJBChainTemplate *)chainTemplate;

- (void)appendPlaceholderExerciseToSelectedExercisesSet:(NSMutableOrderedSet <TJBExercise *> *)exercises;

@end
















