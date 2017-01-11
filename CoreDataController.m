//
//  CoreDataController.m
//  Beast
//
//  Created by Trevor Beasty on 12/9/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import "CoreDataController.h"

@interface CoreDataController ()

@property (nonatomic, strong) NSManagedObjectContext *moc;

@end

NSString * const ExerciseDataChanged = @"exerciseDataChanged";

@implementation CoreDataController

#pragma mark - Singleton

+ (instancetype)singleton
{
    static CoreDataController *singleton = nil;
    
    if (!singleton)
    {
        singleton = [[self alloc] initPrivate];
    }
    return singleton;
}

- (instancetype)initPrivate
{
    self = [super init];
    
    self.moc = [self.persistentContainer viewContext];
    
    return self;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName: @"Singleton"
                                   reason: @"Use +[CoreDataController singleton]"
                                 userInfo: nil];
}

#pragma mark - Retrieving IV's

- (NSManagedObjectContext *)moc
{
    return [self.persistentContainer viewContext];
}


#pragma mark - Core Data stack

@synthesize persistentContainer = _persistentContainer;

- (NSPersistentContainer *)persistentContainer {
    // The persistent container for the application. This implementation creates and returns a container, having loaded the store for the application to it.
    @synchronized (self) {
        if (_persistentContainer == nil) {
            _persistentContainer = [[NSPersistentContainer alloc] initWithName:@"Beast"];
            [_persistentContainer loadPersistentStoresWithCompletionHandler:^(NSPersistentStoreDescription *storeDescription, NSError *error) {
                if (error != nil) {
                    // Replace this implementation with code to handle the error appropriately.
                    // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                    
                    /*
                     Typical reasons for an error here include:
                     * The parent directory does not exist, cannot be created, or disallows writing.
                     * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                     * The device is out of space.
                     * The store could not be migrated to the current model version.
                     Check the error message to determine what the actual problem was.
                     */
                    NSLog(@"Unresolved error %@, %@", error, error.userInfo);
                    abort();
                }
            }];
        }
    }
    
    return _persistentContainer;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *context = self.persistentContainer.viewContext;
    NSError *error = nil;
    if ([context hasChanges] && ![context save:&error]) {
        // Replace this implementation with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, error.userInfo);
        abort();
    }
}

#pragma mark - Core Methods

- (BOOL)realizedSetExerciseExistsForName:(NSString *)name
{
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName: @"Exercise"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"name = %@", name];
    fetch.predicate = predicate;
    
    NSError *error =  nil;
    NSArray *results = [self.moc executeFetchRequest: fetch
                                               error: &error];
    
    NSUInteger arrayLength = [results count];
    
    if (arrayLength == 0)
    {
        return NO;
    }
    else if (arrayLength == 1)
    {
        return YES;
    }
    else
    {
        abort();
    }
}

#pragma mark - Queries

- (TJBExercise *)exerciseForName:(NSString *)name
{
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName: @"Exercise"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"name = %@", name];
    fetch.predicate = predicate;
    
    NSError *error =  nil;
    NSArray *results = [self.moc executeFetchRequest: fetch
                                               error: &error];
    
    NSUInteger arrayLength = [results count];
    
    if (arrayLength == 0)
    {
        TJBExercise *exercise = [NSEntityDescription insertNewObjectForEntityForName: @"Exercise"
                                                              inManagedObjectContext: self.moc];
        
        exercise.name = name;
        
        return exercise;
    }
    else if (arrayLength == 1)
    {
        return results[0];
    }
    else
    {
        abort();
    }
}

- (TJBExerciseCategory *)exerciseCategoryForName:(NSString *)name
{
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName: @"ExerciseCategory"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"name = %@", name];
    fetch.predicate = predicate;
    
    NSError *error =  nil;
    NSArray *results = [self.moc executeFetchRequest: fetch
                                               error: &error];
    
    NSUInteger arrayLength = [results count];
    
    if (arrayLength == 0)
    {
        TJBExerciseCategory *exerciseCategory = [NSEntityDescription insertNewObjectForEntityForName: @"ExerciseCategory"
                                                                              inManagedObjectContext: self.moc];
        
        exerciseCategory.name = name;
        
        return exerciseCategory;
    }
    else if (arrayLength == 1)
    {
        return results[0];
    }
    else
    {
        abort();
    }
}

- (TJBRealizedChain *)realizedChainWithUniqueID:(NSString *)uniqueID{
    
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName: @"RealizedChain"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"uniqueID = %@", uniqueID];
    fetch.predicate = predicate;
    
    NSError *error =  nil;
    NSArray *results = [self.moc executeFetchRequest: fetch
                                               error: &error];
    
    NSUInteger arrayLength = [results count];
    
    if (arrayLength == 1)
    {
        return results[0];
    }
    else
    {
        abort();
    }
}

- (TJBChainTemplate *)chainTemplateWithUniqueID:(NSString *)uniqueID{
    
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName: @"ChainTemplate"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"uniqueID = %@", uniqueID];
    fetch.predicate = predicate;
    
    NSError *error =  nil;
    NSArray *results = [self.moc executeFetchRequest: fetch
                                               error: &error];
    
    NSUInteger arrayLength = [results count];
    
    if (arrayLength == 1)
    {
        return results[0];
    }
    else
    {
        abort();
    }
}

- (void)deleteChainWithChainType:(ChainType)chainType chain:(TJBChain *)chain{
    // must guarantee that all trickle-down managed objects are deleted as well as the chain itself
    // only some objects must be deleted, others should continue to exist in their own right
    
    // some relationships are common to both chain types
    
    NSOrderedSet *weightArrays = chain.weightArrays;
    NSOrderedSet *repsArrays = chain.repsArrays;
    
    // weight arrays
    
    for (TJBWeightArray *array in weightArrays){
        
        NSOrderedSet *numbers = array.numbers;
        
        for (TJBNumberTypeArrayComp *comp in numbers){
            
            [_moc deleteObject: comp];
        }
        
        [_moc deleteObject: array];
    }
    
    // reps arrays
    
    for (TJBRepsArray *array in repsArrays){
        
        NSOrderedSet *numbers = array.numbers;
        
        for (TJBNumberTypeArrayComp *comp in numbers){
            
            [_moc deleteObject: comp];
        }
        
        [_moc deleteObject: array];
    }
    
    
    if (chainType == RealizedChainType){
        
        // cast the chain as a realized chain
        
        TJBRealizedChain *realizedChain = (TJBRealizedChain *)chain;
        
        // date arrays
        
        NSOrderedSet *beginDateArrays = realizedChain.setBegindateArrays;
        NSOrderedSet *endDateArrays = realizedChain.setEndDateArrays;
            
        for (SetBeginDateArray *array in beginDateArrays){
                
            NSOrderedSet *dates = array.dates;
                
            for (TJBBeginDateComp *comp in dates){
                    
                [_moc deleteObject: comp];
            }
                
            [_moc deleteObject: array];
        }
        
        for (SetEndDateArray *array in endDateArrays){
            
            NSOrderedSet *dates = array.dates;
            
            for (TJBEndDateComp *comp in dates){
                
                [_moc deleteObject: comp];
            }
            
            [_moc deleteObject: array];
        }
        

    }
    
    [_moc deleteObject: chain];
    
    NSError *error;
    [_moc save: &error];
}


- (TJBRealizedChain *)createAndSaveSkeletonRealizedChainForChainTemplate:(TJBChainTemplate *)chainTemplate{
    
    // create managed object
    
    NSManagedObjectContext *moc = [self moc];
    
    TJBRealizedChain *realizedChain = [NSEntityDescription insertNewObjectForEntityForName: @"RealizedChain"
                                                                    inManagedObjectContext: moc];
    
    // fill managed object with default values for weight, reps, dates
    
    realizedChain.uniqueID = [[NSUUID UUID] UUIDString];
    realizedChain.dateCreated = [NSDate date];
    realizedChain.postMortem = NO;
    realizedChain.isIncomplete = YES;
    realizedChain.firstIncompleteRoundIndex = 0;
    realizedChain.firstIncompleteExerciseIndex = 0;
    realizedChain.chainTemplate = chainTemplate;
    realizedChain.exercises = chainTemplate.exercises;
    
    int exerciseLimit = chainTemplate.numberOfExercises;
    int roundLimit = chainTemplate.numberOfRounds;
    
    // weight
    
    NSMutableOrderedSet *weightArrays = [[NSMutableOrderedSet alloc] init];
    realizedChain.weightArrays = weightArrays;
    
    // reps
    
    NSMutableOrderedSet *repsArrays = [[NSMutableOrderedSet alloc] init];
    realizedChain.repsArrays = repsArrays;
    
    // begin and end dates
    
    NSMutableOrderedSet *setBeginDateArrays = [[NSMutableOrderedSet alloc] init];
    realizedChain.setBegindateArrays = setBeginDateArrays;
    
    NSMutableOrderedSet *setEndDateArrays = [[NSMutableOrderedSet alloc] init];
    realizedChain.setEndDateArrays = setEndDateArrays;
    
    for (int i = 0; i < exerciseLimit; i++){
        
        // weight
        
        TJBWeightArray *weightArray = [NSEntityDescription insertNewObjectForEntityForName: @"WeightArray"
                                                                    inManagedObjectContext: moc];
        weightArray.chain = realizedChain;
        
        [weightArrays addObject: weightArray];
        NSMutableOrderedSet *weightArrayNumbers = [[NSMutableOrderedSet alloc] init];
        weightArray.numbers = weightArrayNumbers;
        
        // reps
        
        TJBRepsArray *repsArray = [NSEntityDescription insertNewObjectForEntityForName: @"RepsArray"
                                                                inManagedObjectContext: moc];
        repsArray.chain = realizedChain;
        
        [repsArrays addObject: repsArray];
        NSMutableOrderedSet *repsArrayNumbers = [[NSMutableOrderedSet alloc] init];
        repsArray.numbers = repsArrayNumbers;
        
        // set begin dates
        
        SetBeginDateArray *setBeginDateArray = [NSEntityDescription insertNewObjectForEntityForName: @"SetBeginDateArray"
                                                                             inManagedObjectContext: moc];
        setBeginDateArray.realizedChain = realizedChain;
        
        [setBeginDateArrays addObject: setBeginDateArray];
        NSMutableOrderedSet *setBeginDateArrayDates = [[NSMutableOrderedSet alloc] init];
        setBeginDateArray.dates = setBeginDateArrayDates;
        
        // set end dates
        
        SetEndDateArray *setEndDateArray = [NSEntityDescription insertNewObjectForEntityForName: @"SetEndDateArray"
                                                                         inManagedObjectContext: moc];
        setEndDateArray.realizedChain = realizedChain;
        
        [setEndDateArrays addObject: setEndDateArray];
        NSMutableOrderedSet *setEndDateArrayDates = [[NSMutableOrderedSet alloc] init];
        setEndDateArray.dates = setEndDateArrayDates;
        
        for (int j = 0; j < roundLimit; j++){
            
            // weight
            
            TJBNumberTypeArrayComp *weightNumberTypeArrayComponent = [NSEntityDescription insertNewObjectForEntityForName: @"NumberTypeArrayComponent"
                                                                                                   inManagedObjectContext: moc];
            [weightArrayNumbers addObject: weightNumberTypeArrayComponent];
            weightNumberTypeArrayComponent.isDefaultObject = YES;
            weightNumberTypeArrayComponent.owningArray = weightArray;
            
            // reps
            
            TJBNumberTypeArrayComp *repsNumberTypeArrayComponent = [NSEntityDescription insertNewObjectForEntityForName: @"NumberTypeArrayComponent"
                                                                                                 inManagedObjectContext: moc];
            [repsArrayNumbers addObject: repsNumberTypeArrayComponent];
            repsNumberTypeArrayComponent.isDefaultObject = YES;
            repsNumberTypeArrayComponent.owningArray = repsArray;
            
            // set begin dates
            
            TJBBeginDateComp *beginDateComp = [NSEntityDescription insertNewObjectForEntityForName: @"BeginDateComp"
                                                                            inManagedObjectContext: moc];
            
            [setBeginDateArrayDates addObject: beginDateComp];
            
            beginDateComp.isDefaultObject = YES;
            beginDateComp.owningArray = setBeginDateArray;
            
            // set end dates
            
            TJBEndDateComp *endDateComp = [NSEntityDescription insertNewObjectForEntityForName: @"EndDateComp"
                                                                        inManagedObjectContext: moc];
            
            [setEndDateArrayDates addObject: beginDateComp];
            
            endDateComp.isDefaultObject = YES;
            endDateComp.owningArray = setEndDateArray;
        }
    }
    
    [[CoreDataController singleton] saveContext];
    
    return realizedChain;
}

@end





































