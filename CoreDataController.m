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

- (BOOL)numberTypeArrayCompIsDefaultObject:(TJBNumberTypeArrayComp *)numberTypeArrayComp{
    
    //// evaluates if the component is a default object.  If so, returns YES
    
    return numberTypeArrayComp.isDefaultObject;
    
}

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
            
        } else if ([createAsPlaceholderExercise boolValue] == YES){
            
            isPlaceholder = YES;
            
        } else{
            
            abort();
            
        }
        
        newExercise.isPlaceholderExercise = isPlaceholder;
        
        // pass by reference
        
        *wasNewlyCreated = [NSNumber numberWithBool: YES];
        
        return newExercise;
        
    }
    else if (arrayLength == 1){
        
        *wasNewlyCreated = [NSNumber numberWithBool: NO];
        
        TJBExercise *existingExercise = results[0];
        
        return existingExercise;
        
    } else {
        
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

#pragma mark - Persistent Store Management

- (void)deleteChainWithChainType:(ChainType)chainType chain:(TJBChain *)chain{
    
    // must guarantee that all trickle-down managed objects are deleted as well as the chain itself
    // only some objects must be deleted, others should continue to exist in their own right
    
    // some relationships are common to both chain types, hence the motivation for not separating this method out into two methods
    
    NSOrderedSet *weightArrays = chain.weightArrays;
    NSOrderedSet *repsArrays = chain.repsArrays;
    
    // exercises continue to exist in their own right
    
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
    
    //// chain template specific deletions
    // need to delete target rest time arrays
    
    if (chainType == ChainTemplateType){
        
        TJBChainTemplate *chainTemplate = (TJBChainTemplate *)chain;
        
        NSOrderedSet *restTimeArrays = chainTemplate.targetRestTimeArrays;
        
        for (TJBTargetRestTimeArray *array in restTimeArrays){
            
            NSOrderedSet *arrayComps = array.numbers;
            
            for (TJBNumberTypeArrayComp *comp in arrayComps){
                
                [_moc deleteObject: comp];
            }
            
            [_moc deleteObject: array];
        }
    }
    
    
    if (chainType == RealizedChainType){
        
        // cast the chain as a realized chain
        
        TJBRealizedChain *realizedChain = (TJBRealizedChain *)chain;
        
        // date arrays
        
        NSOrderedSet *beginDateArrays = realizedChain.setBeginDateArrays;
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

#pragma mark - Chains

//// chain template

- (void)cloneFirstNumberForWeight:(TJBChainTemplate *)chainTemplate{
    
    int numberOfRounds = chainTemplate.numberOfRounds;
    
    // weight
    
    BOOL weightIsTargeted = chainTemplate.targetingWeight;
    
    NSOrderedSet <TJBWeightArray *> *weightArrays = chainTemplate.weightArrays;
    
    if (weightIsTargeted){
        
        for (TJBWeightArray *weightArray in weightArrays){
            
            float userSelectedValue = weightArray.numbers[0].value;
            
            for (int i = 1; i < numberOfRounds; i++){
                
                TJBNumberTypeArrayComp *arrayComp = weightArray.numbers[i];
                arrayComp.isDefaultObject = NO;
                arrayComp.value = userSelectedValue;
                
            }
        }
    }
    
}

- (void)cloneFirstNumberForReps:(TJBChainTemplate *)chainTemplate{
    
    int numberOfRounds = chainTemplate.numberOfRounds;
    
    // reps
    
    BOOL repsIsTargeted = chainTemplate.targetingReps;
    
    NSOrderedSet <TJBRepsArray *> *repsArrays = chainTemplate.repsArrays;
    
    if (repsIsTargeted){
        
        for (TJBRepsArray *repsArray in repsArrays){
            
            float userSelectedValue = repsArray.numbers[0].value;
            
            for (int i = 1; i < numberOfRounds; i++){
                
                TJBNumberTypeArrayComp *arrayComp = repsArray.numbers[i];
                arrayComp.isDefaultObject = NO;
                arrayComp.value = userSelectedValue;
                
            }
        }
    }
    
}

- (void)cloneFirstNumberForRest:(TJBChainTemplate *)chainTemplate{
    
    int numberOfRounds = chainTemplate.numberOfRounds;
    
    // rest
    
    BOOL restIsTargeted = chainTemplate.targetingRestTime;
    
    NSOrderedSet <TJBTargetRestTimeArray *> *restArrays = chainTemplate.targetRestTimeArrays;
    
    if (restIsTargeted){
        
        for (TJBTargetRestTimeArray *restArray in restArrays){
            
            float userSelectedValue = restArray.numbers[0].value;
            
            for (int i = 1; i < numberOfRounds; i++){
                
                TJBNumberTypeArrayComp *arrayComp = restArray.numbers[i];
                arrayComp.isDefaultObject = NO;
                arrayComp.value = userSelectedValue;
                
            }
        }
    }
    
}

- (void)cloneFirstNumberForAllTargetedCategories:(TJBChainTemplate *)chainTemplate{
    
    //// this method is intended to be used on chain templates for which targets do not vary by round.  If the category is being targeted, this method clones the single selected value and applies it to all rounds
    
    // weight
    
    [self cloneFirstNumberForWeight: chainTemplate];
    
    // reps
    
    [self cloneFirstNumberForReps: chainTemplate];
    
    // rest
    
    [self cloneFirstNumberForRest: chainTemplate];

}





- (BOOL)chainTemplateHasCollectedAllRequisiteUserInput:(TJBChainTemplate *)chainTemplate{
    
    //// checks all required categories for default values and returns NO if it finds any.  If a category is not being targeted, do not check it, and vice versa.  Always check exercises
    
    // first, check if targets vary by round.  If they do, clone the single user input value for targeted categories
    
    BOOL targetsVaryByRound = chainTemplate.targetsVaryByRound;
    
    if (!targetsVaryByRound){
        
        [self cloneFirstNumberForAllTargetedCategories: chainTemplate];
        
    }
    
    // this is reaused throughout
    
    NSOrderedSet <TJBNumberTypeArrayComp *> *arrayNumbers;
    
    // weight
    
    BOOL isTargetingWeight = chainTemplate.targetingWeight;
    
    if (isTargetingWeight){
        
        NSOrderedSet<TJBWeightArray *> *weightArrays = chainTemplate.weightArrays;
        
        for (TJBWeightArray *weightArray in weightArrays){
            
            arrayNumbers = weightArray.numbers;
            
            BOOL containsDefaultValue = [self defaultObjectFoundInOrderedSet: arrayNumbers];
            
            if (containsDefaultValue){
                
                NSLog(@"not all weight user input collected");
                return NO;
            }
            
        }
        
    }
    
    // reps
    
    BOOL isTargetingReps = chainTemplate.targetingReps;
    
    if (isTargetingReps){
        
        NSOrderedSet<TJBRepsArray *> *repsArrays = chainTemplate.repsArrays;
        
        for (TJBRepsArray *repsArray in repsArrays){
            
            arrayNumbers = repsArray.numbers;
            
            BOOL containsDefaultValue = [self defaultObjectFoundInOrderedSet: arrayNumbers];
            
            if (containsDefaultValue){
                
                NSLog(@"not all reps user input collected");
                return NO;
            }
            
        }
        
    }
    
    // rest
    
    BOOL isTargetingRest = chainTemplate.targetingRestTime;
    
    if (isTargetingRest){
        
        NSOrderedSet<TJBTargetRestTimeArray *> *restArrays = chainTemplate.targetRestTimeArrays;
        
        for (TJBTargetRestTimeArray *restArray in restArrays){
            
            arrayNumbers = restArray.numbers;
            
            BOOL containsDefaultValue = [self defaultObjectFoundInOrderedSet: arrayNumbers];
            
            if (containsDefaultValue){
                
                NSLog(@"not all rest user input collected");
                return NO;
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

- (BOOL)defaultObjectFoundInOrderedSet:(NSOrderedSet <TJBNumberTypeArrayComp *> *)set{
    
    //// internal method.  Given an NSOrderedSet of NSNumberTypeArrayComponents, this method determines whether any of them are default objects and returns YES if it does.  Otherwise, returns NO
    
    for (TJBNumberTypeArrayComp *comp in set){
        
        BOOL isDefault = comp.isDefaultObject;
        
        if (isDefault){
            
            return YES;
        }
        
    }
    
    // if control reaches this point, then no default objects have been found

    return NO;
    
}

- (TJBChainTemplate *)createAndSaveSkeletonChainTemplateWithNumberOfExercises:(NSNumber *)numberOfExercises numberOfRounds:(NSNumber *)numberOfRounds name:(NSString *)name targetingWeight:(NSNumber *)targetingWeight targetingReps:(NSNumber *)targetingReps targetingRest:(NSNumber *)targetingRest targetsVaryByRound:(NSNumber *)targetsVaryByRound{
    
    //// this method takes all necessary chain parameters as arguments and creates a skelton chain.  If a category is being targeted, it is given default objects for all exercises and rounds.  A set of placeholder exercises is assigned to the exercises relationship
    
    NSManagedObjectContext *moc = [self moc];
    
    // create the chain template and NSMutableOrderedSets to capture information that will eventually be stored as relationships of the chain template
    
    TJBChainTemplate *chainTemplate = [NSEntityDescription insertNewObjectForEntityForName: @"ChainTemplate"
                                                                    inManagedObjectContext: moc];
    
    //// assign the chain template's attributes
    
    // pertinent to Chain
    
    chainTemplate.numberOfExercises = [numberOfExercises intValue];
    chainTemplate.numberOfRounds = [numberOfRounds intValue];
    chainTemplate.dateCreated = [NSDate date];
    chainTemplate.uniqueID = [[NSUUID UUID] UUIDString];
    chainTemplate.isIncomplete = YES;
    
    // pertinent to ChainTemplate
    
    chainTemplate.name = name;
    chainTemplate.targetingWeight = [targetingWeight boolValue];
    chainTemplate.targetingReps = [targetingReps boolValue];
    chainTemplate.targetingRestTime = [targetingRest boolValue];
    chainTemplate.targetsVaryByRound = [targetsVaryByRound boolValue];
    
    //// chain template relationships
    
    int exerciseLimit = [numberOfExercises intValue];
    
    // exercises
    
    NSArray *exercisesArray = [self placeholderExerciseArrayWithLenght: exerciseLimit];
    
    NSOrderedSet *exercisesOrderedSet = [[NSOrderedSet alloc] initWithArray: exercisesArray];
    
    chainTemplate.exercises = exercisesOrderedSet;
    
    // only create placeholder data structures for weight, reps, and rest if they are being targeted
    
    // weight
    
    if ([targetingWeight boolValue] == YES){
        
        NSMutableOrderedSet *weightArrays = [[NSMutableOrderedSet alloc] init];
        
        for (int i = 0; i < exerciseLimit; i++){
            
            // create the data structure expected  by core data and assign all pertinent / non-optional property values
            
            TJBWeightArray *weightArray = [NSEntityDescription insertNewObjectForEntityForName: @"WeightArray"
                                                                        inManagedObjectContext: moc];
            weightArray.chain = chainTemplate;
//            NSOrderedSet *numbers = [self defaultNumberArrayNumbersWithNumberOfRounds: numberOfRounds];
            weightArray.numbers = [self defaultNumberArrayNumbersWithNumberOfRounds: numberOfRounds];
            [weightArrays addObject: weightArray];
            
        }
        
        chainTemplate.weightArrays = weightArrays;
    }
    
    // reps
    
    if ([targetingReps boolValue] == YES){
        
        NSMutableOrderedSet *repsArrays = [[NSMutableOrderedSet alloc] init];
        
        for (int i = 0; i < exerciseLimit; i++){
            
            // create the data structure expected  by core data and assign all pertinent / non-optional property values
            
            TJBRepsArray *repsArray = [NSEntityDescription insertNewObjectForEntityForName: @"RepsArray"
                                                                        inManagedObjectContext: moc];
            repsArray.chain = chainTemplate;
            repsArray.numbers = [self defaultNumberArrayNumbersWithNumberOfRounds: numberOfRounds];
            
            [repsArrays addObject: repsArray];
            
        }
        
        chainTemplate.repsArrays = repsArrays;
    }
    
    // rest
    
    if ([targetingRest boolValue] == YES){
        
        NSMutableOrderedSet *restArrays = [[NSMutableOrderedSet alloc] init];
        
        for (int i = 0; i < exerciseLimit; i++){
            
            // create the data structure expected  by core data and assign all pertinent / non-optional property values
            
            TJBTargetRestTimeArray *restArray = [NSEntityDescription insertNewObjectForEntityForName: @"TargetRestTimeArray"
                                                                        inManagedObjectContext: moc];
            restArray.chainTemplate = chainTemplate;
            restArray.numbers = [self defaultNumberArrayNumbersWithNumberOfRounds: numberOfRounds];
            
            [restArrays addObject: restArray];
            
        }
        
        chainTemplate.targetRestTimeArrays = restArrays;
    }
    
    // save the newly created skeleton chain template and return it
    
    [[CoreDataController singleton] saveContext];
    
    return chainTemplate;
    
}

- (NSOrderedSet *)defaultNumberArrayNumbersWithNumberOfRounds:(NSNumber *)numberOfRounds{
    
    int roundLimit = [numberOfRounds intValue];
    
    NSMutableOrderedSet *mor = [[NSMutableOrderedSet alloc] init];
    
    for (int i = 0; i < roundLimit; i++){
        
        TJBNumberTypeArrayComp *numberTypeArrayComp = [NSEntityDescription insertNewObjectForEntityForName: @"NumberTypeArrayComponent"
                                                                                    inManagedObjectContext: self.moc];
        numberTypeArrayComp.isDefaultObject = YES;
        
        [mor addObject: numberTypeArrayComp];
        
    }
    
    return mor;
    
}

- (NSArray *)placeholderExerciseArrayWithLenght:(int)length{
    
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
            
            TJBExerciseCategory *placeholderCategory = [self exerciseCategoryForName: placeholderCategoryName];
            
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
    
    realizedChain.numberOfRounds = chainTemplate.numberOfRounds;
    realizedChain.numberOfExercises = chainTemplate.numberOfExercises;
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
    realizedChain.setBeginDateArrays = setBeginDateArrays;
    
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





































