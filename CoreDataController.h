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

#import "TJBWeightArray+CoreDataProperties.h"
#import "TJBRepsArray+CoreDataProperties.h"
#import "TJBTargetRestTimeArray+CoreDataProperties.h"
#import "TJBNumberArray+CoreDataProperties.h"
#import "TJBNumberTypeArrayComp+CoreDataClass.h"



// set begin and end dates

#import "SetEndDateArray+CoreDataProperties.h"
#import "SetBeginDateArray+CoreDataProperties.h"
#import "TJBEndDateComp+CoreDataProperties.h"
#import "TJBBeginDateComp+CoreDataProperties.h"


extern NSString * const ExerciseDataChanged;
extern NSString * const placeholderExerciseName;

typedef enum{
    ChainTemplateType,
    RealizedChainType
} ChainType;

@interface CoreDataController : NSObject

@property (readonly, strong) NSPersistentContainer *persistentContainer;

+ (instancetype)singleton;

// specific queries and inquiries

// the following assigns the value of TJBExercise via pass by reference because it also must report whether the object was newly created
// if newly created, it is the job of the calling class to assign the new exercise a category
// if a category is not assigned, an error will occur when attemting to save managed object changes

- (TJBExercise *)exerciseForName:(NSString *)name wasNewlyCreated:(NSNumber **)wasNewlyCreated;

- (BOOL)realizedSetExerciseExistsForName:(NSString *)name;

- (TJBExerciseCategory *)exerciseCategoryForName:(NSString *)name;

- (TJBRealizedChain *)realizedChainWithUniqueID:(NSString *)uniqueID;
- (TJBChainTemplate *)chainTemplateWithUniqueID:(NSString *)uniqueID;

//

- (void)saveContext;

- (NSManagedObjectContext *)moc;

- (void)deleteChainWithChainType:(ChainType)chainType chain:(TJBChain *)chain;

//// chains

// chain template

- (void)cloneFirstNumberForWeight:(TJBChainTemplate *)chainTemplate;
- (void)cloneFirstNumberForReps:(TJBChainTemplate *)chainTemplate;
- (void)cloneFirstNumberForRest:(TJBChainTemplate *)chainTemplate;

- (TJBChainTemplate *)createAndSaveSkeletonChainTemplateWithNumberOfExercises:(NSNumber *)numberOfExercises numberOfRounds:(NSNumber *)numberOfRounds name:(NSString *)name targetingWeight:(NSNumber *)targetingWeight targetingReps:(NSNumber *)targetingReps targetingRest:(NSNumber *)targetingRest targetsVaryByRound:(NSNumber *)targetsVaryByRound;

- (BOOL)chainTemplateHasCollectedAllRequisiteUserInput:(TJBChainTemplate *)chainTemplate;

// realized chain

- (TJBRealizedChain *)createAndSaveSkeletonRealizedChainForChainTemplate:(TJBChainTemplate *)chainTemplate;

// checking if an object is a default object

- (BOOL)exerciseIsDefaultObject:(TJBExercise *)exercise;
- (BOOL)numberTypeArrayCompIsDefaultObject:(TJBNumberTypeArrayComp *)numberTypeArrayComp;



@end
















