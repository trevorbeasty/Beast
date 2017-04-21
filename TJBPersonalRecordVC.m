//
//  TJBPersonalRecordVC.m
//  Beast
//
//  Created by Trevor Beasty on 4/10/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBPersonalRecordVC.h"

// core data

#import "CoreDataController.h"

// pr's

#import "TJBRepsWeightRecordPair.h"

// aesthetics

#import "TJBAestheticsController.h"

// table view cells

#import "TJBPersonalRecordCell.h"
#import "TJBDetailTitleCell.h"
#import "TJBNoDataCell.h"

@interface TJBPersonalRecordVC () 

// IBOutlet

@property (weak, nonatomic) IBOutlet UITableView *personalRecordsTableView;
@property (weak, nonatomic) IBOutlet UIView *titleBarContainer;
@property (weak, nonatomic) IBOutlet UILabel *mainTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *exerciseValueSubtitle;

// core

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSMutableArray<TJBRepsWeightRecordPair *> *repsWeightRecordPairs;
@property (strong) TJBExercise *exercise;

@end

@implementation TJBPersonalRecordVC



#pragma mark - Instantiation

- (instancetype)init{
    
    self = [super init];
    
    [self configureNotifications];
    
    
    
    
    return self;
    
}


#pragma mark - Init Helper Methods

- (void)configureNotifications{
    
    NSManagedObjectContext *moc = [[CoreDataController singleton] moc];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(coreDataDidUpdate)
                                                 name: NSManagedObjectContextDidSaveNotification
                                               object: moc];
    
}

#pragma mark - View Life Cycle

- (void)viewDidLoad{
    
    [super viewDidLoad];
    
    [self configureTableView];
    
    [self viewAesthetics];
    
    if (self.exercise){
        self.exerciseValueSubtitle.text = self.exercise.name;
    }
    
}

#pragma mark - View Helper Methods


- (void)configureTableView{
    
    UINib *nib = [UINib nibWithNibName: @"TJBPersonalRecordCell"
                                bundle: nil];
    
    [self.personalRecordsTableView registerNib: nib
                        forCellReuseIdentifier: @"PRCell"];
    
    UINib *nib2 = [UINib nibWithNibName: @"TJBDetailTitleCell"
                                 bundle: nil];
    
    [self.personalRecordsTableView registerNib: nib2
                        forCellReuseIdentifier: @"TJBDetailTitleCell"];
    
    UINib *noDataCell = [UINib nibWithNibName: @"TJBNoDataCell"
                                       bundle: nil];
    
    [self.personalRecordsTableView registerNib: noDataCell
                        forCellReuseIdentifier: @"TJBNoDataCell"];
    
    self.personalRecordsTableView.bounces = YES;
    
}

- (void)viewAesthetics{
    
    self.view.backgroundColor = [UIColor blackColor];
    
    self.titleBarContainer.backgroundColor = [UIColor darkGrayColor];
    
    self.mainTitleLabel.backgroundColor = [UIColor clearColor];
    self.mainTitleLabel.font = [UIFont boldSystemFontOfSize: 20];
    self.mainTitleLabel.textColor = [UIColor whiteColor];
    
    self.exerciseValueSubtitle.backgroundColor = [UIColor clearColor];
    self.exerciseValueSubtitle.font = [UIFont systemFontOfSize: 15];
    self.exerciseValueSubtitle.textColor = [UIColor whiteColor];
    
    self.personalRecordsTableView.backgroundColor = [[TJBAestheticsController singleton] yellowNotebookColor];
    
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (!self.repsWeightRecordPairs || self.repsWeightRecordPairs.count == 0 || !self.exercise){
        
        return 1;
        
    } else{
        
        return self.repsWeightRecordPairs.count;
        
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if (!self.repsWeightRecordPairs || self.repsWeightRecordPairs.count == 0 || !self.exercise){
        
        TJBNoDataCell *cell = [self.personalRecordsTableView dequeueReusableCellWithIdentifier: @"TJBNoDataCell"];
        
        cell.mainLabel.text = @"No Entries";
        cell.backgroundColor = [UIColor clearColor];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
        
    } else{
        
        NSInteger adjustedRowIndex = indexPath.row;
        
        TJBPersonalRecordCell *cell = [self.personalRecordsTableView dequeueReusableCellWithIdentifier: @"PRCell"];
        
        TJBRepsWeightRecordPair *repsWeightRecordPair = self.repsWeightRecordPairs[adjustedRowIndex];
        
        [cell configureWithReps: repsWeightRecordPair.reps
                         weight: repsWeightRecordPair.weight
                           date: repsWeightRecordPair.date];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [[TJBAestheticsController singleton] yellowNotebookColor];
        
        return cell;
        
    }
    
}

#pragma mark - <UITableViewDelegate>

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (!self.repsWeightRecordPairs || self.repsWeightRecordPairs.count == 0 || !self.exercise){
        
        return tableView.frame.size.height;
        
    } else{
        
        return 60;
        
    }

}

#pragma mark - Core Data

- (void)coreDataDidUpdate{
    
    [self fetchManagedObjectsAndDetermineRecordsForActiveExercise];
    
    [self.personalRecordsTableView reloadData];
    
}


#pragma mark - Personal Records

- (void)fetchManagedObjectsAndDetermineRecordsForActiveExercise{
    
    TJBExercise *activeExercise = self.exercise;
    
    if (activeExercise){
        
        // the recordsPairArray must be cleaned with each new selected exercise.  Instantiating it again achieves this
        
        [self instantiateRecordPairsArray];
        
        // realized sets
        
        for (TJBRealizedSet *realizedSet in activeExercise.realizedSets){
            
            TJBRepsWeightRecordPair *currentRecordForPrescribedReps = [self repsWeightRecordPairForNumberOfReps: realizedSet.submittedReps];
            
            // compare the weight of the current realized set to that of the current record to determine what should be done
            
            [self configureRepsWeightRecordPair: currentRecordForPrescribedReps
                            withCandidateWeight: [NSNumber numberWithDouble: realizedSet.submittedWeight]
                                  candidateDate: realizedSet.submissionTime];
            
        }
    }
}

- (void)instantiateRecordPairsArray{
    
    //// prepare the record pairs array and tracker for subsequent use
    
    NSMutableArray *repsWeightRecordPairs = [[NSMutableArray alloc] init];
    self.repsWeightRecordPairs = repsWeightRecordPairs;
    
}

- (TJBRepsWeightRecordPair *)repsWeightRecordPairForNumberOfReps:(int)reps{
    
    //// returns the TJBRepsWeightRecordPair corresponding to the specified reps
    
    // because I always display records for reps 1 through 12, they're positions in the array are known by definition
    
    if (reps == 0){
        
        return nil;
        
    }
    
    // create the record pair for the new reps number and assign it appropriate values.  Configure the tracker array as well
    
    int limit = (int)[self.repsWeightRecordPairs count];
    NSNumber *extractedPairReps;
    
    for (int i = 0; i < limit; i++){
        
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
    
    // control only reaches this point if the collection array has length zero because no pairs yet exist
    
    TJBRepsWeightRecordPair *newPair = [[TJBRepsWeightRecordPair alloc] initDefaultObjectWithReps: reps];
    
    [self.repsWeightRecordPairs addObject: newPair];
    
    return newPair;
    
    
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

#pragma mark - TJBPersonalRecordsVCProtocol

- (void)activeExerciseDidUpdate:(TJBExercise *)exercise{
    
    self.exercise = exercise;
    self.exerciseValueSubtitle.text = exercise.name;
    
    [self fetchManagedObjectsAndDetermineRecordsForActiveExercise];
    
    [self.personalRecordsTableView reloadData];
    
}

@end

















