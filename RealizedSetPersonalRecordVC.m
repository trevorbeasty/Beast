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

// two fetches are required - realized chain and realized set.  A property must be kept for each

@property (nonatomic, strong) NSFetchedResultsController *realizedSetsFRC;

@property (nonatomic, strong) NSFetchedResultsController *realizedChainsFRC;


// an array of TJBRepsWeightRecordPairs.  Record pairs are always held for reps values of 1 through 12.  New pairs are added as needed

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

- (void)setRestorationProperties{
    
    //// for restoration
    
    self.restorationIdentifier = @"RealizedSetPersonalRecordVC";
    self.restorationClass = [RealizedSetPersonalRecordVC class];
    
}

- (void)instantiateRecordPairsArray{
    
    //// prepare the record pairs array for subsequent use.
    
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





#pragma mark - FRC / Core Data

- (void)fetchAndManipulateCoreDataForActiveExercise{
    
    if (self.activeExercise){
        
        [self fetchRealizedSets];
        
        [self fetchRealizedChains];
        
        
        
        
        
        
        
        
        
        
        
        
        
        
        

        
    }
    

    
}

- (void)fetchRealizedSets{
    
    //// fetch the realized set, sorting by both weight and reps to facillitate extraction of personal records
    
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName: @"RealizedSet"];
    
        NSSortDescriptor *repsSort = [NSSortDescriptor sortDescriptorWithKey: @"reps"
                                                                       ascending: YES];
        NSSortDescriptor *weightSort = [NSSortDescriptor sortDescriptorWithKey: @"weight"
                                                                     ascending: NO];
    
        [request setSortDescriptors: @[repsSort, weightSort]];
    
        NSManagedObjectContext *moc = [[CoreDataController singleton] moc];
    
        NSFetchedResultsController *realizedSetsFRC = [[NSFetchedResultsController alloc] initWithFetchRequest: request
                                                                              managedObjectContext: moc
                                                                                sectionNameKeyPath: nil
                                                                                         cacheName: nil];
    
        realizedSetsFRC.delegate = nil;
            
        self.realizedSetsFRC = realizedSetsFRC;
    
}

- (void)fetchRealizedChains{
    
    
    
    
}




- (void)refineFetchedResults{
//    NSMutableArray *refinedResults = [[NSMutableArray alloc] init];
//    NSArray *fetchedObjects = self.frc.fetchedObjects;
//    
//    int FRCount = (int)[self.frc.fetchedObjects count];
//    
//    int currentRepIndex;
//    int previousRepIndex;
//    
//    int currentArrayIndex;
//    int previousArrayIndex;
//    
//    if (FRCount == 0)
//    {
//        return;
//    }
//    
//    [refinedResults addObject: fetchedObjects[0]];
//    
//    if (FRCount > 1)
//    {
//        previousRepIndex = (int)[fetchedObjects[0] reps];
//        previousArrayIndex = 0;
//        
//        currentRepIndex = (int)[fetchedObjects[1] reps];
//        currentArrayIndex = 1;
//        
//        if (currentRepIndex > previousRepIndex)
//        {
//            [refinedResults addObject: fetchedObjects[currentArrayIndex]];
//        }
//        
//        for (int generalIndex = 0; generalIndex < FRCount - 2; generalIndex++)
//        {
//            previousArrayIndex = currentArrayIndex;
//            previousRepIndex = currentRepIndex;
//            
//            currentArrayIndex++;
//            currentRepIndex = [fetchedObjects[currentArrayIndex] reps];
//            
//            if (currentRepIndex > previousRepIndex)
//            {
//                [refinedResults addObject: fetchedObjects[currentArrayIndex]];
//            }
//        }
//    }
//    
//    self.refinedFRCResults = [refinedResults copy];
}



#pragma mark - <SelectedExerciseObserver>

- (void)didSelectExercise:(TJBExercise *)exercise{
    
    //// store the active exercise and fetch and manipulate core data objects
    
    self.activeExercise = exercise;
    
    [self fetchAndManipulateCoreDataForActiveExercise];
    
    [self.tableView reloadData];
    
}

- (void)newSetSubmitted{
    
    //// refetch relevant core data objects. This is done in case the submitted exercise is the same as the active exercise, in which case, there may be a new personal record to show
    
    [self fetchAndManipulateCoreDataForActiveExercise];
    
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
        
        return [self.refinedFRCResults count];
        
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    RealizedSetPersonalRecordCell *cell = [self.tableView dequeueReusableCellWithIdentifier: @"PRCell"];
    
    TJBRealizedSet *realizedSet = self.refinedFRCResults[indexPath.row];
    
    cell.repsLabel.text = [[NSNumber numberWithFloat: realizedSet.reps] stringValue];
    cell.weightLabel.text = [[NSNumber numberWithFloat: realizedSet.weight] stringValue];
    
    // date formatter
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    
    NSDate *realizedSetStartDate = realizedSet.beginDate;
    
    cell.dateLabel.text = [dateFormatter stringFromDate: realizedSetStartDate];
    
    return cell;
    
}




#pragma mark - <UIViewControllerRestoration>

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder{
    
    return [[RealizedSetPersonalRecordVC alloc] init];
    
}





@end






































