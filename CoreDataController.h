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
#import "TJBNumberArray+CoreDataProperties.h"
#import "TJBNumberTypeArrayComp+CoreDataClass.h"



// set begin and end dates

#import "SetEndDateArray+CoreDataProperties.h"
#import "SetBeginDateArray+CoreDataProperties.h"
#import "TJBEndDateComp+CoreDataProperties.h"
#import "TJBBeginDateComp+CoreDataProperties.h"


extern NSString * const ExerciseDataChanged;

typedef enum{
    ChainTemplateType,
    RealizedChainType
} ChainType;

@interface CoreDataController : NSObject

@property (readonly, strong) NSPersistentContainer *persistentContainer;

+ (instancetype)singleton;

// specific queries

- (TJBExercise *)exerciseForName:(NSString *)name;
- (BOOL)realizedSetExerciseExistsForName:(NSString *)name;

- (TJBExerciseCategory *)exerciseCategoryForName:(NSString *)name;

- (TJBRealizedChain *)realizedChainWithUniqueID:(NSString *)uniqueID;
- (TJBChainTemplate *)chainTemplateWithUniqueID:(NSString *)uniqueID;

//

- (void)saveContext;

- (NSManagedObjectContext *)moc;

- (void)deleteChainWithChainType:(ChainType)chainType chain:(TJBChain *)chain;

// chains

- (TJBRealizedChain *)createAndSaveSkeletonRealizedChainForChainTemplate:(TJBChainTemplate *)chainTemplate;



@end
