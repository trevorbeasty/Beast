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

@property (strong) NSCalendar *calendar;

@end

NSString * const ExerciseDataChanged = @"exerciseDataChanged";

// the following string constant is used to create / fetch the placeholder exercise object used in creating chain template skeletons

NSString * const placeholderExerciseName = @"placeholderExercise";
NSString * const placeholderCategoryName = @"Placeholder";

@implementation CoreDataController

#pragma mark - Singleton

+ (instancetype)singleton{
    
    static CoreDataController *singleton = nil;
    
    if (!singleton){
        
        singleton = [[self alloc] initPrivate];
        
    }
    
    return singleton;
    
}

- (instancetype)initPrivate{
    
    self = [super init];
    
    self.moc = [self.persistentContainer viewContext];
    
    return self;
    
}

- (instancetype)init{
    
    @throw [NSException exceptionWithName: @"Singleton"
                                   reason: @"Use +[CoreDataController singleton]"
                                 userInfo: nil];
    
}

#pragma mark - Retrieving IV's

- (NSManagedObjectContext *)moc{
    
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
        
    }
}



#pragma mark - Queries and Inquiries




- (TJBExerciseCategory *)exerciseCategory:(TJBExerciseCategoryType)exerciseCategory{
    
    NSString *categoryString = [self categoryStingFromEnum: exerciseCategory];
    
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName: @"ExerciseCategory"];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"name = %@", categoryString];
    
    fetch.predicate = predicate;
    
    NSError *error =  nil;
    NSArray *results = [self.moc executeFetchRequest: fetch
                                               error: &error];
    
    NSUInteger arrayLength = [results count];
    
    if (arrayLength == 0)
    {
        TJBExerciseCategory *exerciseCategory = [NSEntityDescription insertNewObjectForEntityForName: @"ExerciseCategory"
                                                                              inManagedObjectContext: self.moc];
        
        exerciseCategory.name = categoryString;
        
        return exerciseCategory;
        
    } else{
        
        return results[0];
        
    }

}

- (TJBExerciseCategoryType)typeForExerciseCategory:(TJBExerciseCategory *)category{
    
    TJBExerciseCategoryType catType;
    
    if ([category.name isEqualToString: [self categoryStingFromEnum: PushType]]){
        
        catType = PushType;
        
    } else if ([category.name isEqualToString: [self categoryStingFromEnum: PullType]]){
        
        catType = PullType;
        
    } else if ([category.name isEqualToString: [self categoryStingFromEnum: LegsType]]){
        
        catType = LegsType;
        
    } else if ([category.name isEqualToString: [self categoryStingFromEnum: OtherType]]){
        
        catType = OtherType;
        
    } else if ([category.name containsString: [self categoryStingFromEnum: PlaceholderType]]){
        
        catType = PlaceholderType;
        
    }
    
    return catType;
    
}

- (NSString *)categoryStingFromEnum:(TJBExerciseCategoryType)categoryEnum{
    
    NSString *categoryName;
    
    switch (categoryEnum) {
        case PushType:
            categoryName = @"Push";
            break;
            
        case PullType:
            categoryName = @"Pull";
            break;
            
        case LegsType:
            categoryName = @"Legs";
            break;
            
        case OtherType:
            categoryName = @"Other";
            break;
            
        case PlaceholderType:
            categoryName = @"Placeholder";
            break;
            
        default:
            break;
    }
    
    return categoryName;
    
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
        return nil;
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
        return nil;
    }
}


#pragma mark - Persistent Store Management



- (void)deleteChainTemplate:(TJBChainTemplate *)ct{
    
    
    if (ct.realizedChains.count > 0){
        
        ct.showInRoutineList = NO;
        
        [self saveContext];
        
    } else{
        
        NSManagedObjectContext *moc = self.moc;
        
        for (TJBTargetUnitCollection *tuc in ct.targetUnitCollections){
            
            for (TJBTargetUnit *tu in tuc.targetUnits){
                
                [moc deleteObject: tu];
                
            }
            
            [moc deleteObject: tuc];
            
        }
        
        [moc deleteObject: ct];
        
        NSError *error;
        [moc save: &error];
        
    }
    
}

- (void)deleteRealizedChain:(TJBRealizedChain *)rc{
    
    NSManagedObjectContext *moc = self.moc;
    
    for (TJBRealizedSetCollection *rsc in rc.realizedSetCollections){
        
        for (TJBRealizedSet *rs in rsc.realizedSets){
            
            [moc deleteObject: rs];
            
        }
        
        [moc deleteObject: rsc];
        
    }
    
    [moc deleteObject: rc];
    
    NSError *error;
    [_moc save: &error];
    
}

- (void)deleteRealizeSet:(TJBRealizedSet *)rs{
    
    [self.moc deleteObject: rs];
    
    [self saveContext];
    
}

#pragma mark - Chains




- (BOOL)chainTemplateHasCollectedAllRequisiteUserInput:(TJBChainTemplate *)chainTemplate{
    
    NSOrderedSet<TJBTargetUnitCollection *> *targetUnitCollections = chainTemplate.targetUnitCollections;
    
    for (TJBTargetUnitCollection *tuc in targetUnitCollections){
        
        for (TJBTargetUnit *tu in tuc.targetUnits){
            
            // weight
            
            if (tu.isTargetingWeight){
                
                if (tu.weightIsNull){
                    
//                    NSLog(@"exercise index: %d\nround index: %d", tu.exerciseIndex, tu.roundIndex);
                    
                    return NO;
                    
                }
                
            }
            
            // reps
            
            if (tu.isTargetingReps){
                
                if (tu.repsIsNull){
                    
//                    NSLog(@"exercise index: %d\nround index: %d", tu.exerciseIndex, tu.roundIndex);
                    
                    return NO;
                    
                }
                
            }
            
            // rest
            
            if (tu.isTargetingTrailingRest){
                
                if (tu.trailingRestIsNull){
                    
//                    NSLog(@"exercise index: %d\nround index: %d", tu.exerciseIndex, tu.roundIndex);
                    
                    return NO;
                    
                }
                
            }
            
            
            
        }
        
    }
    
    // exercises
    
    NSOrderedSet *exercises = chainTemplate.exercises;
    
    if (!exercises){
        
        return NO;
        
    } else{
        
        for (TJBExercise *exercise in exercises){
            
//            NSLog(@"exercise name: %@", exercise.name);
            
            BOOL exerciseIsDefaultExercise = [exercise.name containsString: placeholderExerciseName];
            
            if (exerciseIsDefaultExercise){
                
                return NO;
                
            }
        
    }


        
    }
    
    
    // if control reaches this point, then no default objects have been found
    
    return YES;
    
}



//// realized chain

- (TJBRealizedChain *)createAndSaveSkeletonRealizedChainForChainTemplate:(TJBChainTemplate *)chainTemplate{
    
    // create managed object
    
    NSManagedObjectContext *moc = [self moc];
    
    TJBRealizedChain *realizedChain = [NSEntityDescription insertNewObjectForEntityForName: @"RealizedChain"
                                                                    inManagedObjectContext: moc];
    
    // fill managed object with default values for weight, reps, dates

    realizedChain.dateCreated = [NSDate date];
    realizedChain.firstIncompleteRoundIndex = 0;
    realizedChain.firstIncompleteExerciseIndex = 0;
    realizedChain.chainTemplate = chainTemplate;
    realizedChain.uniqueID = [[NSUUID UUID] UUIDString];
    
    int exerciseLimit = chainTemplate.numberOfExercises;
    int roundLimit = chainTemplate.numberOfRounds;
    
    NSMutableOrderedSet<TJBRealizedSetCollection *> *realizedSetCollectors = [[NSMutableOrderedSet alloc] init];
    realizedChain.realizedSetCollections = realizedSetCollectors;
    
    for (int i = 0; i < exerciseLimit; i++){
        
        TJBRealizedSetCollection *rsc = [NSEntityDescription insertNewObjectForEntityForName: @"RealizedSetCollection"
                                                                      inManagedObjectContext: moc];
        rsc.exerciseIndex = i;
        rsc.realizedChain = realizedChain;
        [realizedSetCollectors addObject: rsc];
        
        NSMutableOrderedSet<TJBRealizedSet *> *iterativeRealizedSets = [[NSMutableOrderedSet alloc] init];
        rsc.realizedSets = iterativeRealizedSets;
        
        for (int j = 0; j < roundLimit; j++){
            
            TJBRealizedSet *rs = [NSEntityDescription insertNewObjectForEntityForName: @"RealizedSet"
                                                               inManagedObjectContext: moc];
            rs.realizedSetCollector = rsc;
            [iterativeRealizedSets addObject: rs];
            
            rs.exerciseIndex = i;
            rs.roundIndex = j;
            
            rs.holdsNullValues = YES;
            rs.isStandaloneSet = NO;
            
            rs.exercise = chainTemplate.exercises[i];
            
        }
        
        
    }
    
    [[CoreDataController singleton] saveContext];
    
    return realizedChain;
    
}

#pragma mark - TJBExercise

- (void)deleteExercise:(TJBExercise *)exercise{
    
    // delete the managed object if it is not already in any chain templates, realized sets, or target units
    
    BOOL isRelatedToOtherManagedObjects = (exercise.chainTemplates.count > 0) || (exercise.targetUnits.count > 0) || (exercise.realizedSets.count > 0);
    
    if (isRelatedToOtherManagedObjects){
        
        exercise.showInExerciseList = NO;
        
    } else{
        
        [self.moc deleteObject: exercise];
        
    }
    
    [self saveContext];
    
}

- (void)appendPlaceholderExerciseToSelectedExercisesSet:(NSMutableOrderedSet<TJBExercise *> *)exercises{
    
    int exerciseIndex = (int)exercises.count;
    TJBExercise *placeholderExercise = [self placeholderExerciseForExerciseIndex: exerciseIndex];
    [exercises addObject: placeholderExercise];
    
}

- (TJBExercise *)placeholderExerciseForExerciseIndex:(int)exerciseIndex{
    
    // must append a number to make names distinct, otherwise orderedSet will not allow additional placeholder exercises to be added
    
    NSString *name = [NSString stringWithFormat: @"%@%d",
                      placeholderExerciseName,
                      exerciseIndex];
    
    NSNumber *wasNewlyCreated = nil;
    TJBExercise *exercise = [self exerciseForName: name
                                  wasNewlyCreated: &wasNewlyCreated
                      createAsPlaceholderExercise: [NSNumber numberWithBool: YES]];
    
    // if it was newly created, give it the placeholder category
    
    if ([wasNewlyCreated boolValue] == YES){
        
        TJBExerciseCategory *placeholderCategory = [self exerciseCategory: PlaceholderType];
        
        exercise.category = placeholderCategory;
        
    }
    
    return exercise;
    
}

- (NSMutableOrderedSet *)placeholderExerciseSetWithLength:(int)length{
    
    // create a set of placeholder exercises
    
    NSMutableOrderedSet *exercises = [[NSMutableOrderedSet alloc] init];
    
    for (int i = 0; i < length ; i++){
        
        TJBExercise *exercise = [self placeholderExerciseForExerciseIndex: i];
        
        [exercises addObject: exercise];
        
    }
    
    return exercises;
    
}

- (NSMutableArray *)placeholderExerciseArrayWithLength:(int)length{
    
    //// create a set of placeholder exercises
    
    NSMutableArray *exercises = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < length ; i++){
        
        TJBExercise *exercise = [self placeholderExerciseForExerciseIndex: i];
        
        [exercises addObject: exercise];
        
    }
    
    return exercises;
    
}





- (TJBExercise *)exerciseForName:(NSString *)name wasNewlyCreated:(NSNumber **)wasNewlyCreated createAsPlaceholderExercise:(NSNumber *)createAsPlaceholderExercise{
    
    //// returns an exercise with the passed name and indicates whether it was newly created or not
    
    // IMPORTANT - this class does not accept a category as an argument and thus does not assign a category to the created exercise.  Exercises are required to have a category as defined in the core data model.  It is the job of the calling class to assign a category and save the context if the exercise object was newly created
    
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName: @"Exercise"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"name = %@", name];
    fetch.predicate = predicate;
    
    NSError *error =  nil;
    NSArray *results = [self.moc executeFetchRequest: fetch
                                               error: &error];
    
    NSUInteger arrayLength = [results count];
    
    if (arrayLength == 0){
        
        TJBExercise *newExercise = [NSEntityDescription insertNewObjectForEntityForName: @"Exercise"
                                                                 inManagedObjectContext: self.moc];
        
        newExercise.name = name;
        newExercise.showInExerciseList = YES;
        
        
        // placeholder property
        
        BOOL isPlaceholder;
        
        if (!createAsPlaceholderExercise || [createAsPlaceholderExercise boolValue] == NO){
            
            isPlaceholder = NO;
            
        } else{
            
            isPlaceholder = YES;
            
        }
        
        newExercise.isPlaceholderExercise = isPlaceholder;
        
        // pass by reference
        
        *wasNewlyCreated = [NSNumber numberWithBool: YES];
        
        return newExercise;
        
    } else{
        
        *wasNewlyCreated = [NSNumber numberWithBool: NO];
        
        TJBExercise *existingExercise = results[0];
        
        return existingExercise;
        
    }
}

- (BOOL)exerciseIsPlaceholderExercise:(TJBExercise *)exercise{
    
    //// evaluates if the exercise object is a default object.  If so, returns YES
    
    return exercise.isPlaceholderExercise;
    
}


- (BOOL)exerciseExistsForName:(NSString *)name{
    
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName: @"Exercise"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"name = %@", name];
    fetch.predicate = predicate;
    
    NSError *error =  nil;
    NSArray *results = [self.moc executeFetchRequest: fetch
                                               error: &error];
    
    NSUInteger arrayLength = [results count];
    
    if (arrayLength == 0){
        
        return NO;
        
    } else{
        
        return YES;
        
    }
    
}


- (TJBExercise *)delistedExerciseForName:(NSString *)name{
    
    NSFetchRequest *fetch = [NSFetchRequest fetchRequestWithEntityName: @"Exercise"];
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"name = %@", name];
    fetch.predicate = predicate;
    
    NSError *error =  nil;
    NSArray *results = [self.moc executeFetchRequest: fetch
                                               error: &error];
    
    NSUInteger arrayLength = [results count];
    
    if (arrayLength == 0){
        
        return nil;
        
    } else{
        
        TJBExercise *fetchedExercise = results[0];
        if (fetchedExercise.showInExerciseList == NO){
            
            return fetchedExercise;
            
        } else{
            
            return nil;
            
        }
        
    }
    
}



#pragma mark - Chain Template Manipulation


- (TJBChainTemplate *)createAndSaveSkeletonChainTemplateWithNumberOfExercises:(NSNumber *)numberOfExercises numberOfRounds:(NSNumber *)numberOfRounds name:(NSString *)name isTargetingWeight:(BOOL)isTargetingWeight isTargetingReps:(BOOL)isTargetingReps isTargetingTrailingRest:(BOOL)isTargetingTrailingRest{
    
    //// this method takes all necessary chain parameters as arguments and creates a skelton chain.  If a category is being targeted, it is given default objects for all exercises and rounds.  A set of placeholder exercises is assigned to the exercises relationship
    
    NSManagedObjectContext *moc = [self moc];
    
    // create the chain template and NSMutableOrderedSets to capture information that will eventually be stored as relationships of the chain template
    
    TJBChainTemplate *chainTemplate = [NSEntityDescription insertNewObjectForEntityForName: @"ChainTemplate"
                                                                    inManagedObjectContext: moc];
    
    //// assign the chain template's attributes
    
    chainTemplate.numberOfExercises = [numberOfExercises intValue];
    chainTemplate.numberOfRounds = [numberOfRounds intValue];
    chainTemplate.dateCreated = [NSDate date];
    chainTemplate.uniqueID = [[NSUUID UUID] UUIDString];
    chainTemplate.name = name;
    chainTemplate.showInRoutineList = YES;
    
    // exercises
    
    chainTemplate.exercises = [self placeholderExerciseSetWithLength: [numberOfExercises intValue]];
    
    // target units
    
    NSMutableOrderedSet<TJBTargetUnitCollection *> *targetUnitCollectors = [[NSMutableOrderedSet alloc] init];
    chainTemplate.targetUnitCollections = targetUnitCollectors;
    
    for (int i = 0; i < [numberOfExercises intValue]; i++){
        
        TJBTargetUnitCollection *tuc = [NSEntityDescription insertNewObjectForEntityForName: @"TargetUnitCollection"
                                                                     inManagedObjectContext: moc];
        tuc.exerciseIndex = i;
        tuc.chainTemplate = chainTemplate;
        [targetUnitCollectors addObject: tuc];
        
        NSMutableOrderedSet<TJBTargetUnit *> *iterativeTargetUnits = [[NSMutableOrderedSet alloc] init];
        tuc.targetUnits = iterativeTargetUnits;
        
        for (int j = 0; j < [numberOfRounds intValue]; j++){
            
            TJBTargetUnit *iterativeTargetUnit = [NSEntityDescription insertNewObjectForEntityForName: @"TargetUnit"
                                                                               inManagedObjectContext: moc];
            iterativeTargetUnit.targetUnitCollector = tuc;
            [iterativeTargetUnits addObject: iterativeTargetUnit];
            
            iterativeTargetUnit.exerciseIndex = i;
            iterativeTargetUnit.roundIndex = j;
            
            iterativeTargetUnit.isTargetingWeight = isTargetingWeight;
            iterativeTargetUnit.isTargetingReps = isTargetingReps;
            iterativeTargetUnit.isTargetingTrailingRest = isTargetingTrailingRest;
            
            iterativeTargetUnit.weightIsNull = YES;
            iterativeTargetUnit.repsIsNull = YES;
            iterativeTargetUnit.trailingRestIsNull = YES;
            
            // exercise
            
            iterativeTargetUnit.exercise = [self placeholderExerciseForExerciseIndex: i];
            
        }
        
    }
    
    // save the newly created skeleton chain template and return it
    
    [[CoreDataController singleton] saveContext];
    
    return chainTemplate;
    
}

- (void)appendRoundToChainTemplate:(TJBChainTemplate *)chainTemplate{
    
    int previousNumberRounds = chainTemplate.numberOfRounds;
    chainTemplate.numberOfRounds = previousNumberRounds + 1;
    
    for (TJBTargetUnitCollection *tuc in chainTemplate.targetUnitCollections){
        
        NSMutableOrderedSet *targetUnitsCopy = [tuc.targetUnits mutableCopy];
        
        TJBTargetUnit *iterativeTargetUnit = [NSEntityDescription insertNewObjectForEntityForName: @"TargetUnit"
                                                                           inManagedObjectContext: [self moc]];
        iterativeTargetUnit.targetUnitCollector = tuc;
        
        TJBTargetUnit *zeroethTargetUnit = targetUnitsCopy[0];
        
        iterativeTargetUnit.exerciseIndex = zeroethTargetUnit.exerciseIndex;
        iterativeTargetUnit.roundIndex = previousNumberRounds;
        
        iterativeTargetUnit.isTargetingWeight = zeroethTargetUnit.isTargetingWeight;
        iterativeTargetUnit.isTargetingReps = zeroethTargetUnit.isTargetingReps;
        iterativeTargetUnit.isTargetingTrailingRest = zeroethTargetUnit.isTargetingTrailingRest;
        
        iterativeTargetUnit.weightIsNull = YES;
        iterativeTargetUnit.repsIsNull = YES;
        iterativeTargetUnit.trailingRestIsNull = YES;
        
        iterativeTargetUnit.exercise = zeroethTargetUnit.exercise;
        
        [targetUnitsCopy addObject: iterativeTargetUnit];
        
        tuc.targetUnits = targetUnitsCopy;

    }
    
    [self saveContext];
    
}

- (void)deleteLastRoundInChainTemplate:(TJBChainTemplate *)chainTemplate{
    
    int previousNumberRounds = chainTemplate.numberOfRounds;
    chainTemplate.numberOfRounds = previousNumberRounds - 1;
    
    for (TJBTargetUnitCollection *tuc in chainTemplate.targetUnitCollections){
        
        NSMutableOrderedSet *targetUnitsCopy = [tuc.targetUnits mutableCopy];
        
        TJBTargetUnit *tu = [targetUnitsCopy objectAtIndex: previousNumberRounds - 1];
        
        [[self moc] deleteObject: tu];
        [targetUnitsCopy removeObject: tu];
        
        tuc.targetUnits = targetUnitsCopy;

    }
    
    [self saveContext];
    
}

- (void)appendExerciseToChainTemplate:(TJBChainTemplate *)chainTemplate{
    
    int previousNumberExercises = chainTemplate.numberOfExercises;
    chainTemplate.numberOfExercises = previousNumberExercises + 1;
    
    int numberOfRounds = chainTemplate.numberOfRounds;
    
    // add a placeholder exercise to exercises
    
    NSMutableOrderedSet *exercisesCopy = [chainTemplate.exercises mutableCopy];
    TJBExercise *placeholderExercise = [self placeholderExerciseForExerciseIndex: previousNumberExercises];
    [exercisesCopy addObject: placeholderExercise];
    chainTemplate.exercises = exercisesCopy;
    
    // add an target unit collection to targetUnitCollections
    
    TJBTargetUnitCollection *tuc = [NSEntityDescription insertNewObjectForEntityForName: @"TargetUnitCollection"
                                                                 inManagedObjectContext: [self moc]];
    tuc.exerciseIndex = previousNumberExercises;
    tuc.chainTemplate = chainTemplate;
    NSMutableOrderedSet<TJBTargetUnit *> *iterativeTargetUnits = [[NSMutableOrderedSet alloc] init];
    
    NSMutableOrderedSet *targetUnitCollectionsCopy = [chainTemplate.targetUnitCollections mutableCopy];
    
    for (int i = 0; i < numberOfRounds; i++){
        
        TJBTargetUnit *iterativeTargetUnit = [NSEntityDescription insertNewObjectForEntityForName: @"TargetUnit"
                                                                           inManagedObjectContext: [self moc]];
        iterativeTargetUnit.targetUnitCollector = tuc;
        
        iterativeTargetUnit.exerciseIndex = previousNumberExercises;
        iterativeTargetUnit.roundIndex = i;
        
        iterativeTargetUnit.isTargetingWeight = YES;
        iterativeTargetUnit.isTargetingReps = YES;
        iterativeTargetUnit.isTargetingTrailingRest = YES;
        
        iterativeTargetUnit.weightIsNull = YES;
        iterativeTargetUnit.repsIsNull = YES;
        iterativeTargetUnit.trailingRestIsNull = YES;
        
        // exercise
        
        iterativeTargetUnit.exercise = placeholderExercise;
        
        [iterativeTargetUnits addObject: iterativeTargetUnit];
        
    }
    
    tuc.targetUnits = iterativeTargetUnits;
    
    [targetUnitCollectionsCopy addObject: tuc];
    
    chainTemplate.targetUnitCollections = targetUnitCollectionsCopy;

    [self saveContext];
    
}



- (void)deleteLastExercisefromChainTemplate:(TJBChainTemplate *)chainTemplate{
    
    int previousNumberExercises = chainTemplate.numberOfExercises;
    chainTemplate.numberOfExercises = previousNumberExercises - 1;
    
    // target units
    
    TJBTargetUnitCollection *tuc = chainTemplate.targetUnitCollections[previousNumberExercises - 1];
    
    for (TJBTargetUnit *tu in tuc.targetUnits){
        
        [[self moc] deleteObject: tu];
        
    }
    
    NSMutableOrderedSet *targetUnitCollectionsCopy = [chainTemplate.targetUnitCollections mutableCopy];
    [targetUnitCollectionsCopy removeObject: tuc];
    chainTemplate.targetUnitCollections = targetUnitCollectionsCopy;
    
    [[self moc] deleteObject: tuc];
    
    // exercises
    
    NSMutableOrderedSet *exercisesCopy = [chainTemplate.exercises mutableCopy];
    [exercisesCopy removeObjectAtIndex: exercisesCopy.count - 1];
    chainTemplate.exercises = exercisesCopy;

    [self saveContext];
    
}


#pragma mark - Model Object Grouping

- (NSMutableArray *)groupModelObjects:(NSMutableArray *)modelObjects{
    
    if (modelObjects.count <= 1){
        
        return modelObjects;
        
    }
    
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    
    NSInteger groupSize = 1;
    
    NSInteger limit = modelObjects.count;
    for (NSInteger i = 0; i < limit - 1; i++){
        
        id obj1 = modelObjects[i];
        id obj2 = modelObjects[i + 1];
        
        BOOL objectsAreRealizedSetsOfSameDay = [self objectsHaveSimilarExercisesAndDates_obj1: obj1
                                                                                         obj2: obj2];
        
        if (i == limit - 2){
            
            // different logic must be applied for the last two objects, otherwise the last object will not be added
            
            if (objectsAreRealizedSetsOfSameDay){
                
                groupSize += 1;
                
                id object = [self objectForSourceArray: modelObjects
                                     iterationPosition: i + 1
                                             groupSize: groupSize];
                
                [returnArray addObject: object];
                
                break;
                
            } else{
                
                id object1 = [self objectForSourceArray: modelObjects
                                      iterationPosition: i
                                              groupSize: groupSize];
                
                id object2 = [self objectForSourceArray: modelObjects
                                      iterationPosition: i + 1
                                              groupSize: 1];
                
                [returnArray addObject: object1];
                [returnArray addObject: object2];
                
                break;
                
            }
            
            
        } else{
            
            if (objectsAreRealizedSetsOfSameDay){
                
                groupSize += 1;
                continue;
                
            } else{
                
                id object = [self objectForSourceArray: modelObjects
                                     iterationPosition: i
                                             groupSize: groupSize];
                
                [returnArray addObject: object];
                
                groupSize = 1;
                
                continue;
                
            }
        }
        
    }
    
    return returnArray;
    
}

- (id)objectForSourceArray:(NSArray *)array iterationPosition:(NSInteger)iterationPosition groupSize:(NSInteger)groupSize{
    
    if (groupSize > 1){
        
        NSMutableArray *collector = [[NSMutableArray alloc] init];
        
        for (NSInteger i = iterationPosition - (groupSize - 1); i <= iterationPosition; i++){
            
            [collector addObject: array[i]];
            
        }
        
        TJBRealizedSetGrouping rsg = [NSArray arrayWithArray: collector];
        return rsg;
        
    } else{
        
        return array[iterationPosition];
        
    }
    
}

- (NSDate *)dateForObject:(id)object{
    
    if ([object isKindOfClass: [TJBRealizedSet class]]){
        
        TJBRealizedSet *rs = object;
        return rs.submissionTime;
        
    } else if ([object isKindOfClass: [TJBRealizedChain class]]){
        
        TJBRealizedChain *rc = object;
        return  rc.dateCreated;
        
    } else{
        
        return nil;
        
    }
    
}

- (BOOL)objectsHaveSimilarExercisesAndDates_obj1:(id)obj1 obj2:(id)obj2{
    
    BOOL obj1IsRealizedSet = [self objectIsRealizedSet: obj1];
    BOOL obj2IsRealizedSet = [self objectIsRealizedSet: obj2];
    
    if (obj1IsRealizedSet && obj2IsRealizedSet){
        
        if (!self.calendar){
            
            self.calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
            
        }
        
        TJBRealizedSet *rs1 = obj1;
        TJBRealizedSet *rs2 = obj2;
        
        BOOL objectsHaveSimilarDate = [self.calendar isDate: rs1.submissionTime
                                            inSameDayAsDate: rs2.submissionTime];
        
        BOOL objectsHaveSimilarExercise = [rs1.exercise isEqual: rs2.exercise];
        
        return objectsHaveSimilarDate && objectsHaveSimilarExercise;
        
    } else{
        
        return NO;
        
    }
    
}

- (BOOL)objectIsRealizedSet:(id)obj{
    
    return [obj isKindOfClass: [TJBRealizedSet class]];
    
}

@end





































