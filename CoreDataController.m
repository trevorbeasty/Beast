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

@end





































