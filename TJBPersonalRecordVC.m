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
#import "TJBNoDataCell.h"

#import "TJBAssortedUtilities.h" // utilities

@interface TJBPersonalRecordVC () <UIViewControllerRestoration, UITableViewDataSource, UITableViewDelegate>

// IBOutlet

@property (weak, nonatomic) IBOutlet UITableView *personalRecordsTableView;
@property (weak, nonatomic) IBOutlet UILabel *mainTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *exerciseValueSubtitle;
@property (weak, nonatomic) IBOutlet UIView *columnHeaderContainer;
@property (weak, nonatomic) IBOutlet UILabel *repsColumnLabel;
@property (weak, nonatomic) IBOutlet UILabel *weightColumnLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateColumnLabel;

// core

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSMutableArray<TJBRepsWeightRecordPair *> *repsWeightRecordPairs;

@property (strong) TJBExercise *exercise;

@end


#pragma mark - Constants

static NSString * const restorationID = @"TJBPersonalRecordsVC";


@implementation TJBPersonalRecordVC


#pragma mark - Instantiation

- (instancetype)init{
    
    self = [super init];
    
    [self configureNotifications];
    [self configureRestorationProperties];
    [self configureTabBar];
    
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

- (void)configureRestorationProperties{
    
    self.restorationIdentifier = restorationID;
    self.restorationClass = [TJBPersonalRecordVC class];
    
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

- (void)configureTabBar{
    
    self.tabBarItem.title = @"PR's";
    self.tabBarItem.image = [UIImage imageNamed: @"trophyBlue25"];
    
}


- (void)configureTableView{
    
    UINib *nib = [UINib nibWithNibName: @"TJBPersonalRecordCell"
                                bundle: nil];
    
    [self.personalRecordsTableView registerNib: nib
                        forCellReuseIdentifier: @"PRCell"];
    
    
    UINib *noDataCell = [UINib nibWithNibName: @"TJBNoDataCell"
                                       bundle: nil];
    
    [self.personalRecordsTableView registerNib: noDataCell
                        forCellReuseIdentifier: @"TJBNoDataCell"];
    
    self.personalRecordsTableView.bounces = YES;
    
}

- (void)viewAesthetics{
    
    self.view.backgroundColor = [UIColor blackColor];
    
    NSArray *mainTitles = @[self.mainTitleLabel, self.exerciseValueSubtitle];
    for (UILabel *label in mainTitles){
        
        label.backgroundColor = [UIColor darkGrayColor];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont boldSystemFontOfSize: 20];
        
    }
    
    self.columnHeaderContainer.backgroundColor = [[TJBAestheticsController singleton] yellowNotebookColor];
    
    NSArray *columnHeaderLabels = @[self.repsColumnLabel, self.weightColumnLabel, self.dateColumnLabel];
    for (UILabel *label in columnHeaderLabels){
        
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor blackColor];
        label.font = [UIFont systemFontOfSize: 15];
        
    }
    
    self.personalRecordsTableView.backgroundColor = [[TJBAestheticsController singleton] yellowNotebookColor];
    
    [self drawDetailedLines];
    
}



- (void)drawDetailedLines{
    
    [self.view layoutSubviews];
    [self.columnHeaderContainer layoutSubviews];
    
    NSArray *lineViews = @[self.repsColumnLabel, self.weightColumnLabel];
    for (UILabel *label in lineViews){
        
        [TJBAssortedUtilities drawVerticalDividerToRightOfLabel: label
                                               horizontalOffset: 0
                                                      thickness: 2
                                                 verticalOffset: self.columnHeaderContainer.frame.size.height / 3.0
                                                       metaView: self.columnHeaderContainer];
        
    }
    
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
        
        [self layoutCellToEnsureCorrectWidth: cell
                                   indexPath: indexPath];
        
        TJBRepsWeightRecordPair *repsWeightRecordPair = self.repsWeightRecordPairs[adjustedRowIndex];
        
        [cell configureWithReps: repsWeightRecordPair.reps
                         weight: repsWeightRecordPair.weight
                           date: repsWeightRecordPair.date];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [[TJBAestheticsController singleton] yellowNotebookColor];
        
        return cell;
        
    }
    
}

- (void)layoutCellToEnsureCorrectWidth:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath{
    
    [self.view layoutSubviews];
    
    CGFloat cellHeight = [self tableView: self.personalRecordsTableView
                 heightForRowAtIndexPath: indexPath];
    
    CGFloat cellWidth = self.personalRecordsTableView.frame.size.width;
    
    
    [cell setFrame: CGRectMake(0, 0, cellWidth, cellHeight)];
    [cell layoutSubviews];
    
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
    
    return;
    
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

#pragma mark - Restoration

+(UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder{
    
    return [[TJBPersonalRecordVC alloc] init];
    
}

@end

















