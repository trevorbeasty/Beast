//
//  RealizedSetPersonalRecordVC.m
//  Beast
//
//  Created by Trevor Beasty on 12/11/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import "RealizedSetPersonalRecordVC.h"

#import "RealizedSetPersonalRecordCell.h"

#import "CoreDataController.h"

#import "TJBAestheticsController.h"

// for help with refining fetched results

#import "TJBRepsWeightRecordPair.h"

@interface RealizedSetPersonalRecordVC () <UIViewControllerRestoration>

// IBOutlet and associated

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) UINavigationItem *navItem;

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *columnLabelContainer;

//// core data

// two fetches are required - realized chain and realized set.  The results are stored for each.  Because fetched results are not being directly fed into a table view, NSFetchedResultsController is not used

@property (nonatomic, strong) NSArray *realizedSetFetchResults;

@property (nonatomic, strong) NSArray *realizedChainFetchResults;


//// an array of TJBRepsWeightRecordPairs.  Record pairs are always held for reps values of 1 through 12.  New pairs are added as needed

@property (nonatomic, strong) NSMutableArray<TJBRepsWeightRecordPair *> *repsWeightRecordPairs;

// core

@property (nonatomic, strong) TJBExercise *activeExercise;

@end

@implementation RealizedSetPersonalRecordVC

#pragma mark - Instantiation

- (instancetype)init{
    
    self = [super init];
    
    [self setRestorationProperties];
    
    [self instantiateRecordPairsArray];
    
    return self;
    
}

- (void)registerForExerciseChangeNotification{
    
    
    
}

- (void)setRestorationProperties{
    
    //// for restoration
    
    self.restorationIdentifier = @"RealizedSetPersonalRecordVC";
    self.restorationClass = [RealizedSetPersonalRecordVC class];
    
}

- (void)instantiateRecordPairsArray{
    
    //// prepare the record pairs array and tracker for subsequent use
    
    NSMutableArray *repsWeightRecordPairs = [[NSMutableArray alloc] init];
    self.repsWeightRecordPairs = repsWeightRecordPairs;
    
    int limit = 12;
    
    for (int i = 0; i < limit; i++){
        
        TJBRepsWeightRecordPair *recordPair = [[TJBRepsWeightRecordPair alloc] initDefaultObjectWithReps: i + 1];
        
        [repsWeightRecordPairs addObject: recordPair];
        
    }
    
}

#pragma mark - View Life Cycle

- (void)viewDidLoad{
    
    [self configureTableView];
    
    [self configureNavigationBarAndItem];
    
    [self addBackgroundImage];
    
    [self viewAesthetics];
    
}

- (void)viewWillAppear:(BOOL)animated{
    
    if (self.activeExercise){
        
        NSString *name = self.activeExercise.name;
        
        NSString *title = [NSString stringWithFormat: @"%@ PR's", name];
        
        [self.navBar.topItem setTitle: title];
        
    }
}

- (void)configureTableView{
    
    UINib *nib = [UINib nibWithNibName: @"RealizedSetPersonalRecordCell"
                                bundle: nil];
    
    [self.tableView registerNib: nib
         forCellReuseIdentifier: @"PRCell"];
    
}

- (void)addBackgroundImage{
    
    [[TJBAestheticsController singleton] addFullScreenBackgroundViewWithImage: [UIImage imageNamed: @"girlOverheadKettlebell"]
                                                                   toRootView: self.view
                                                                 imageOpacity: .35];
    
}

- (void)viewAesthetics{
    
    self.tableView.layer.opacity = .85;
    
    [TJBAestheticsController configureViewsWithType1Format: @[self.columnLabelContainer]
                                               withOpacity: .85];
    
}



- (void)configureNavigationBarAndItem{
    
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle: @"Select an Exercise"];
    
    self.navItem = navItem;
    
    [self.navBar setItems: @[self.navItem]];
    
}





#pragma mark - PR List Creation

- (void)fetchManagedObjectsAndDetermineRecordsForActiveExercise{
    
    TJBExercise *activeExercise = self.activeExercise;
    
    if (activeExercise){
        
        // the recordsPairArray must be cleaned with each new selected exercise.  Instantiating it again achieves this
        
        [self instantiateRecordPairsArray];
        
        [self fetchRealizedSets];
        [self fetchRealizedChains];

        // realized sets
        
        for (TJBRealizedSet *realizedSet in activeExercise.realizedSets){
            
            TJBRepsWeightRecordPair *currentRecordForPrescribedReps = [self repsWeightRecordPairForNumberOfReps: realizedSet.reps];
            
            // compare the weight of the current realized set to that of the current record to determine what should be done
            
            [self configureRepsWeightRecordPair: currentRecordForPrescribedReps
                            withCandidateWeight: [NSNumber numberWithDouble: realizedSet.weight]
                                  candidateDate: realizedSet.beginDate];
            
        }
        
        // realized chains
        
        for (TJBRealizedChain *realizedChain in activeExercise.chains){
            
            if ([realizedChain isKindOfClass: [TJBChainTemplate class]]){
                
                continue;
                
            }
            
            NSArray *exerciseIndices = [self indicesContainingExercise: activeExercise
                                                      forRealizedChain: realizedChain];
            
            int roundLimit = realizedChain.numberOfRounds;
            
            for (NSNumber *number in exerciseIndices){
                
                int exerciseIndex = [number intValue];
                
                for (int i = 0; i < roundLimit; i++){
                    
                    BOOL isDefaultEntry = realizedChain.weightArrays[exerciseIndex].numbers[i].isDefaultObject;
                    
                    if (!isDefaultEntry){
                        
                        int reps = (int)realizedChain.repsArrays[exerciseIndex].numbers[i].value;
                        NSNumber *weight = [NSNumber numberWithDouble: realizedChain.weightArrays[exerciseIndex].numbers[i].value];
                        NSDate *date = realizedChain.setBeginDateArrays[exerciseIndex].dates[i].value;
                        
                        TJBRepsWeightRecordPair *currentRecordForPrescribedReps = [self repsWeightRecordPairForNumberOfReps: reps];
                        
                        [self configureRepsWeightRecordPair: currentRecordForPrescribedReps
                                        withCandidateWeight: weight
                                              candidateDate: date];
                        
                    }
                }
            }
        }
    }
}

- (void)configureRepsWeightRecordPair:(TJBRepsWeightRecordPair *)recordPair withCandidateWeight:(NSNumber *)weight candidateDate:(NSDate *)date{
    
    BOOL currentRecordIsDefaultObject = [recordPair.isDefaultObject boolValue];
    
    if (!currentRecordIsDefaultObject){
        
        BOOL newWeightIsANewRecord = [weight doubleValue] > [recordPair.weight doubleValue];
        
        if (newWeightIsANewRecord){
            
            recordPair.weight = weight;
            recordPair.date = date;
            recordPair.isDefaultObject = [NSNumber numberWithBool: NO];
            
        }
        
    } else{
        
        recordPair.weight = weight;
        recordPair.date = date;
        recordPair.isDefaultObject = [NSNumber numberWithBool: NO];
        
    }
    
}

- (NSArray<NSNumber *> *)indicesContainingExercise:(TJBExercise *)exercise forRealizedChain:(TJBRealizedChain *)realizedChain{
    
    int limit = realizedChain.numberOfExercises;
    
    NSMutableArray *collector = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < limit; i++){
        
        BOOL currentIndexContainsTargetedExercise = [realizedChain.exercises[i] isEqual: exercise];
        
        if (currentIndexContainsTargetedExercise){
            
            NSNumber *number = [NSNumber numberWithInt: i];
            
            [collector addObject: number];
            
        }
        
    }
    
    return collector;
    
}

- (TJBRepsWeightRecordPair *)repsWeightRecordPairForNumberOfReps:(int)reps{
    
    //// returns the TJBRepsWeightRecordPair corresponding to the specified reps
    
    // because I always display records for reps 1 through 12, they're positions in the array are known by definition
    
    if (reps == 0){
        
        return nil;
        
    }
    
    BOOL repsWithinStaticRange = reps <= 12;
    
    if (repsWithinStaticRange){
        
        return self.repsWeightRecordPairs[reps - 1];
        
    } else{
        
        // create the record pair for the new reps number and assign it appropriate values.  Configure the tracker array as well
        
        int limit = (int)[self.repsWeightRecordPairs count];
        NSNumber *extractedPairReps;
        
        for (int i = 12; i < limit; i++){
            
            extractedPairReps = self.repsWeightRecordPairs[i].reps;
            int extractedPairRepsAsInt = [extractedPairReps intValue];
            
            if (extractedPairRepsAsInt == reps){
                
                return self.repsWeightRecordPairs[i];
                
            } else if(extractedPairRepsAsInt < reps){
                
                continue;
                
            } else if(extractedPairRepsAsInt > reps){
                
                TJBRepsWeightRecordPair *newPair = [[TJBRepsWeightRecordPair alloc] initDefaultObjectWithReps: reps];
                
                [self.repsWeightRecordPairs insertObject: newPair
                                                 atIndex: i];
                
                return newPair;
                
            }
            
        }
        
        // control only reaches this point if the passed-in reps are greater than reps for all records currently held by repsWeightRecordPairs
        
        TJBRepsWeightRecordPair *newPair = [[TJBRepsWeightRecordPair alloc] initDefaultObjectWithReps: reps];
        
        [self.repsWeightRecordPairs addObject: newPair];
        
        return newPair;
        
    }
}





- (void)fetchRealizedSets{
    
    //// fetch the realized set, sorting by both weight and reps to facillitate extraction of personal records
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName: @"RealizedSet"];
    
    NSSortDescriptor *repsSort = [NSSortDescriptor sortDescriptorWithKey: @"reps"
                                                               ascending: YES];
    
    NSSortDescriptor *weightSort = [NSSortDescriptor sortDescriptorWithKey: @"weight"
                                                                 ascending: NO];
    
    NSString *activeExerciseName = self.activeExercise.name;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"exercise.name = %@", activeExerciseName];
    
    [request setSortDescriptors: @[repsSort, weightSort]];
    request.predicate = predicate;
    
    NSError *error = nil;
    NSArray *fetchResults = [[[CoreDataController singleton] moc] executeFetchRequest: request
                                                                                error: &error];
    self.realizedSetFetchResults = fetchResults;
    
}

- (void)fetchRealizedChains{
    
    //// fetch the realized set, sorting by both weight and reps to facillitate extraction of personal records
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName: @"RealizedChain"];
    
    NSSortDescriptor *dateSort = [NSSortDescriptor sortDescriptorWithKey: @"dateCreated"
                                                               ascending: NO];
    
    [request setSortDescriptors: @[dateSort]];
    
    NSError *error = nil;
    
    NSArray *fetchResults = [[[CoreDataController singleton] moc] executeFetchRequest: request
                                                                                error: &error];
    self.realizedChainFetchResults = fetchResults;
    
}



#pragma mark - <SelectedExerciseObserver>

- (void)didSelectExercise:(TJBExercise *)exercise{
    
    //// store the active exercise and fetch and manipulate core data objects
    
    self.activeExercise = exercise;
    
    [self fetchManagedObjectsAndDetermineRecordsForActiveExercise];
    
    [self.tableView reloadData];
    
}



- (void)newSetSubmitted{
    
    //// refetch relevant core data objects. This is done in case the submitted exercise is the same as the active exercise, in which case, there may be a new personal record to show
    
    [self fetchManagedObjectsAndDetermineRecordsForActiveExercise];
    
    [self.tableView reloadData];
    
}


#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    //// if no exercise has been selected, return 0.  Else, return 1
    
    if (!self.activeExercise){
        
        return 0;
        
    } else{
        
        return 1;
        
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    //// if no exercise has been selected, return 0.  Else, return the count of items in the refined fetched results
    
    if (!self.activeExercise){
        
        return 0;
        
    } else{
        
        return [self.repsWeightRecordPairs count];
        
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    RealizedSetPersonalRecordCell *cell = [self.tableView dequeueReusableCellWithIdentifier: @"PRCell"];
    
    TJBRepsWeightRecordPair *repsWeightRecordPair = self.repsWeightRecordPairs[indexPath.row];
    
    cell.repsLabel.text = [[repsWeightRecordPair reps] stringValue];
    cell.weightLabel.text = [[repsWeightRecordPair weight] stringValue];
    
    // date formatter
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    
    cell.dateLabel.text = [dateFormatter stringFromDate: repsWeightRecordPair.date];
    
    return cell;
    
}




#pragma mark - <UIViewControllerRestoration>

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder{
    
    return [[RealizedSetPersonalRecordVC alloc] init];
    
}





@end






































