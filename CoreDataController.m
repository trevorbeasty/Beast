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



#pragma mark - Queries and Inquiries

- (BOOL)exerciseIsPlaceholderExercise:(TJBExercise *)exercise{
    
    //// evaluates if the exercise object is a default object.  If so, returns YES
    
    return exercise.isPlaceholderExercise;
    
}

//- (BOOL)numberTypeArrayCompIsDefaultObject:(TJBNumberTypeArrayComp *)numberTypeArrayComp{
//    
//    //// evaluates if the component is a default object.  If so, returns YES
//    
//    return numberTypeArrayComp.isDefaultObject;
//    
//}

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
//    else
//    {
//        abort();
//    }
    
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

#pragma mark - Persistent Store Management

//- (void)deleteChainWithChainType:(ChainType)chainType chain:(TJBChain *)chain{
//    
//    // must guarantee that all trickle-down managed objects are deleted as well as the chain itself
//    // only some objects must be deleted, others should continue to exist in their own right
//    
//    // some relationships are common to both chain types, hence the motivation for not separating this method out into two methods
//    
//    NSOrderedSet *weightArrays = chain.weightArrays;
//    NSOrderedSet *repsArrays = chain.repsArrays;
//    
//    // exercises continue to exist in their own right
//    
//    // weight arrays
//    
//    for (TJBWeightArray *array in weightArrays){
//        
//        NSOrderedSet *numbers = array.numbers;
//        
//        for (TJBNumberTypeArrayComp *comp in numbers){
//            
//            [_moc deleteObject: comp];
//        }
//        
//        [_moc deleteObject: array];
//    }
//    
//    // reps arrays
//    
//    for (TJBRepsArray *array in repsArrays){
//        
//        NSOrderedSet *numbers = array.numbers;
//        
//        for (TJBNumberTypeArrayComp *comp in numbers){
//            
//            [_moc deleteObject: comp];
//        }
//        
//        [_moc deleteObject: array];
//    }
//    
//    //// chain template specific deletions
//    // need to delete target rest time arrays
//    
//    if (chainType == ChainTemplateType){
//        
//        TJBChainTemplate *chainTemplate = (TJBChainTemplate *)chain;
//        
//        NSOrderedSet *restTimeArrays = chainTemplate.targetRestTimeArrays;
//        
//        for (TJBTargetRestTimeArray *array in restTimeArrays){
//            
//            NSOrderedSet *arrayComps = array.numbers;
//            
//            for (TJBNumberTypeArrayComp *comp in arrayComps){
//                
//                [_moc deleteObject: comp];
//            }
//            
//            [_moc deleteObject: array];
//        }
//    }
//    
//    
//    if (chainType == RealizedChainType){
//        
//        // cast the chain as a realized chain
//        
//        TJBRealizedChain *realizedChain = (TJBRealizedChain *)chain;
//        
//        // date arrays
//        
//        NSOrderedSet *beginDateArrays = realizedChain.setBeginDateArrays;
//        NSOrderedSet *endDateArrays = realizedChain.setEndDateArrays;
//            
//        for (SetBeginDateArray *array in beginDateArrays){
//                
//            NSOrderedSet *dates = array.dates;
//                
//            for (TJBBeginDateComp *comp in dates){
//                    
//                [_moc deleteObject: comp];
//            }
//                
//            [_moc deleteObject: array];
//        }
//        
//        for (SetEndDateArray *array in endDateArrays){
//            
//            NSOrderedSet *dates = array.dates;
//            
//            for (TJBEndDateComp *comp in dates){
//                
//                [_moc deleteObject: comp];
//            }
//            
//            [_moc deleteObject: array];
//        }
//
//    }
//    
//    [_moc deleteObject: chain];
//    
//    NSError *error;
//    [_moc save: &error];
//    
//}

- (void)deleteChainTemplate:(TJBChainTemplate *)ct{
    
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

#pragma mark - Chains

//// chain template

//- (void)cloneFirstNumberForWeight:(TJBChainTemplate *)chainTemplate{
//    
//    int numberOfRounds = chainTemplate.numberOfRounds;
//    
//    // weight
//    
//    BOOL weightIsTargeted = chainTemplate.targetingWeight;
//    
//    NSOrderedSet <TJBWeightArray *> *weightArrays = chainTemplate.weightArrays;
//    
//    if (weightIsTargeted){
//        
//        for (TJBWeightArray *weightArray in weightArrays){
//            
//            float userSelectedValue = weightArray.numbers[0].value;
//            
//            for (int i = 1; i < numberOfRounds; i++){
//                
//                TJBNumberTypeArrayComp *arrayComp = weightArray.numbers[i];
//                arrayComp.isDefaultObject = NO;
//                arrayComp.value = userSelectedValue;
//                
//            }
//        }
//    }
//    
//}

//- (void)cloneFirstNumberForReps:(TJBChainTemplate *)chainTemplate{
//    
//    int numberOfRounds = chainTemplate.numberOfRounds;
//    
//    // reps
//    
//    BOOL repsIsTargeted = chainTemplate.targetingReps;
//    
//    NSOrderedSet <TJBRepsArray *> *repsArrays = chainTemplate.repsArrays;
//    
//    if (repsIsTargeted){
//        
//        for (TJBRepsArray *repsArray in repsArrays){
//            
//            float userSelectedValue = repsArray.numbers[0].value;
//            
//            for (int i = 1; i < numberOfRounds; i++){
//                
//                TJBNumberTypeArrayComp *arrayComp = repsArray.numbers[i];
//                arrayComp.isDefaultObject = NO;
//                arrayComp.value = userSelectedValue;
//                
//            }
//        }
//    }
//    
//}

//- (void)cloneFirstNumberForRest:(TJBChainTemplate *)chainTemplate{
//    
//    int numberOfRounds = chainTemplate.numberOfRounds;
//    
//    // rest
//    
//    BOOL restIsTargeted = chainTemplate.targetingRestTime;
//    
//    NSOrderedSet <TJBTargetRestTimeArray *> *restArrays = chainTemplate.targetRestTimeArrays;
//    
//    if (restIsTargeted){
//        
//        for (TJBTargetRestTimeArray *restArray in restArrays){
//            
//            float userSelectedValue = restArray.numbers[0].value;
//            
//            for (int i = 1; i < numberOfRounds; i++){
//                
//                TJBNumberTypeArrayComp *arrayComp = restArray.numbers[i];
//                arrayComp.isDefaultObject = NO;
//                arrayComp.value = userSelectedValue;
//                
//            }
//        }
//    }
//    
//}

//- (void)cloneFirstNumberForAllTargetedCategories:(TJBChainTemplate *)chainTemplate{
//    
//    //// this method is intended to be used on chain templates for which targets do not vary by round.  If the category is being targeted, this method clones the single selected value and applies it to all rounds
//    
//    // weight
//    
//    [self cloneFirstNumberForWeight: chainTemplate];
//    
//    // reps
//    
//    [self cloneFirstNumberForReps: chainTemplate];
//    
//    // rest
//    
//    [self cloneFirstNumberForRest: chainTemplate];
//
//}





- (BOOL)chainTemplateHasCollectedAllRequisiteUserInput:(TJBChainTemplate *)chainTemplate{
    
    NSOrderedSet<TJBTargetUnitCollection *> *targetUnitCollections = chainTemplate.targetUnitCollections;
    
    for (TJBTargetUnitCollection *tuc in targetUnitCollections){
        
        for (TJBTargetUnit *tu in tuc.targetUnits){
            
            // weight
            
            if (tu.isTargetingWeight){
                
                if (tu.weightIsNull){
                    
                    return NO;
                    
                }
                
            }
            
            // reps
            
            if (tu.isTargetingReps){
                
                if (tu.repsIsNull){
                    
                    return NO;
                    
                }
                
            }
            
            // rest
            
            if (tu.isTargetingTrailingRest){
                
                if (tu.trailingRestIsNull){
                    
                    return NO;
                    
                }
                
            }
            
            
            
        }
        
    }
    
    // exercises
    
    NSOrderedSet *exercises = chainTemplate.exercises;
    
    if (!exercises){
        
        return NO;
        
    }

    for (TJBExercise *exercise in exercises){
        
        BOOL exerciseIsDefaultExercise = [exercise.name containsString: placeholderExerciseName];
        
        if (exerciseIsDefaultExercise){
            
            return NO;
            
        }
        
    }
    
    
    // if control reaches this point, then no default objects have been found
    
    return YES;
    
}

//- (BOOL)defaultObjectFoundInOrderedSet:(NSOrderedSet <TJBNumberTypeArrayComp *> *)set{
//    
//    //// internal method.  Given an NSOrderedSet of NSNumberTypeArrayComponents, this method determines whether any of them are default objects and returns YES if it does.  Otherwise, returns NO
//    
//    for (TJBNumberTypeArrayComp *comp in set){
//        
//        BOOL isDefault = comp.isDefaultObject;
//        
//        if (isDefault){
//            
//            return YES;
//        }
//        
//    }
//    
//    // if control reaches this point, then no default objects have been found
//
//    return NO;
//    
//}

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
            
            iterativeTargetUnit.exercise = [self placeholderExercise];

        }
        
    }
    
    // save the newly created skeleton chain template and return it
    
    [[CoreDataController singleton] saveContext];
    
    return chainTemplate;
    
}

//- (NSOrderedSet *)defaultNumberArrayNumbersWithNumberOfRounds:(NSNumber *)numberOfRounds{
//    
//    int roundLimit = [numberOfRounds intValue];
//    
//    NSMutableOrderedSet *mor = [[NSMutableOrderedSet alloc] init];
//    
//    for (int i = 0; i < roundLimit; i++){
//        
//        TJBNumberTypeArrayComp *numberTypeArrayComp = [NSEntityDescription insertNewObjectForEntityForName: @"NumberTypeArrayComponent"
//                                                                                    inManagedObjectContext: self.moc];
//        numberTypeArrayComp.isDefaultObject = YES;
//        
//        [mor addObject: numberTypeArrayComp];
//        
//    }
//    
//    return mor;
//    
//}

- (TJBExercise *)placeholderExercise{
    
    NSString *placeholderExerciseName = @"Placeholder Exercise";
    
    NSNumber *wasNewlyCreated = nil;
    TJBExercise *exercise = [self exerciseForName: placeholderExerciseName
                                  wasNewlyCreated: &wasNewlyCreated
                      createAsPlaceholderExercise: [NSNumber numberWithBool: YES]];
    
    // if it was newly created, give it the placeholder category
    
    if ([wasNewlyCreated boolValue] == YES){
        
        TJBExerciseCategory *placeholderCategory = [self exerciseCategory: PlaceholderType];
        
        exercise.category = placeholderCategory;
        
    }
    
    return exercise;
    
}

- (NSOrderedSet *)placeholderExerciseSetWithLength:(int)length{
    
    //// create a set of placeholder exercises
    
    NSMutableOrderedSet *exercises = [[NSMutableOrderedSet alloc] init];
    
    for (int i = 0; i < length ; i++){
        
        // the placeholder name must change with every iteration.  Otherwise, the exercise objects will not be unique and only 1 of them will be added to the set (because sets only add unique objects)
        
        NSString *placeholderExerciseDynamicName = [NSString stringWithFormat: @"%@%d",
                                                    placeholderExerciseName,
                                                    i];
        
        NSNumber *wasNewlyCreated = nil;
        TJBExercise *exercise = [self exerciseForName: placeholderExerciseDynamicName
                                      wasNewlyCreated: &wasNewlyCreated
                          createAsPlaceholderExercise: [NSNumber numberWithBool: YES]];
        
        // if it was newly created, give it the placeholder category
        
        if ([wasNewlyCreated boolValue] == YES){
            
            TJBExerciseCategory *placeholderCategory = [self exerciseCategory: PlaceholderType];
            
            exercise.category = placeholderCategory;
            
        }
        
        [exercises addObject: exercise];
        
    }
    
    return exercises;
    
}

- (NSArray *)placeholderExerciseArrayWithLength:(int)length{
    
    //// create a set of placeholder exercises
    
    NSMutableArray *exercises = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < length ; i++){
        
        // the placeholder name must change with every iteration.  Otherwise, the exercise objects will not be unique and only 1 of them will be added to the set (because sets only add unique objects)
        
        NSString *placeholderExerciseDynamicName = [NSString stringWithFormat: @"%@%d",
                                                    placeholderExerciseName,
                                                    i];
        
        NSNumber *wasNewlyCreated = nil;
        TJBExercise *exercise = [self exerciseForName: placeholderExerciseDynamicName
                                      wasNewlyCreated: &wasNewlyCreated
                          createAsPlaceholderExercise: [NSNumber numberWithBool: YES]];
        
        // if it was newly created, give it the placeholder category
        
        if ([wasNewlyCreated boolValue] == YES){
            
            TJBExerciseCategory *placeholderCategory = [self exerciseCategory: PlaceholderType];
            
            exercise.category = placeholderCategory;
            
        }
        
        [exercises addObject: exercise];
        
    }
    
    return exercises;
    
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

@end





































