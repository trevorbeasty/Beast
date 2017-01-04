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

@interface RealizedSetPersonalRecordVC ()

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) UINavigationItem *navItem;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *columnLabelContainer;

@property (nonatomic, strong) NSFetchedResultsController *frc;
@property (nonatomic, strong) NSArray *refinedFRCResults;

@property (nonatomic, strong) TJBExercise *activeExercise;

@end

@implementation RealizedSetPersonalRecordVC

#pragma mark - Instantiation

- (void)viewDidLoad{
    // table view
    
    UINib *nib = [UINib nibWithNibName: @"RealizedSetPersonalRecordCell"
                                bundle: nil];
    
    [self.tableView registerNib: nib
         forCellReuseIdentifier: @"PRCell"];
    
    // nav bar/item
    
    [self configureNavObjects];
    
    [self.navBar.topItem setTitle: @"Select an Exercise"];
    
    [TJBAestheticsController configureNavigationBar: self.navBar];

    // NSFetchedResultsController
    
    [self createFRCIfNecessary];
    [self addBackgroundImage];
    [self viewAesthetics];
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

- (void)refineFetchedResults{
    NSMutableArray *refinedResults = [[NSMutableArray alloc] init];
    NSArray *fetchedObjects = self.frc.fetchedObjects;
    
    int FRCount = (int)[self.frc.fetchedObjects count];
    
    int currentRepIndex;
    int previousRepIndex;
    
    int currentArrayIndex;
    int previousArrayIndex;
    
    if (FRCount == 0)
    {
        return;
    }
    
    [refinedResults addObject: fetchedObjects[0]];

    if (FRCount > 1)
    {
        previousRepIndex = (int)[fetchedObjects[0] reps];
        previousArrayIndex = 0;
        
        currentRepIndex = (int)[fetchedObjects[1] reps];
        currentArrayIndex = 1;
        
        if (currentRepIndex > previousRepIndex)
        {
            [refinedResults addObject: fetchedObjects[currentArrayIndex]];
        }
        
        for (int generalIndex = 0; generalIndex < FRCount - 2; generalIndex++)
        {
            previousArrayIndex = currentArrayIndex;
            previousRepIndex = currentRepIndex;
            
            currentArrayIndex++;
            currentRepIndex = [fetchedObjects[currentArrayIndex] reps];
            
            if (currentRepIndex > previousRepIndex)
            {
                [refinedResults addObject: fetchedObjects[currentArrayIndex]];
            }
        }
    }
    
    self.refinedFRCResults = [refinedResults copy];
}

- (void)configureNavObjects{
    if (!self.navItem)
    {
        UINavigationItem *navItem = [[UINavigationItem alloc] init];
        self.navItem = navItem;
    }
    if (!self.navBar.items)
    {
        [self.navBar setItems: @[self.navItem]];
    }
}

- (void)createFRCIfNecessary{
    if (!self.frc)
    {
        NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName: @"RealizedSet"];
        
        NSSortDescriptor *repsSort = [NSSortDescriptor sortDescriptorWithKey: @"reps"
                                                                   ascending: YES];
        NSSortDescriptor *weightSort = [NSSortDescriptor sortDescriptorWithKey: @"weight"
                                                                     ascending: NO];
        
        [request setSortDescriptors: @[repsSort, weightSort]];
        
        NSManagedObjectContext *moc = [[CoreDataController singleton] moc];
        
        NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest: request
                                                                              managedObjectContext: moc
                                                                                sectionNameKeyPath: nil
                                                                                         cacheName: nil];
        
        frc.delegate = nil;
        
        self.frc = frc;
    }
}

#pragma mark - View Life Cycle

- (void)viewWillAppear:(BOOL)animated{
    if (self.activeExercise)
    {
        NSString *name = self.activeExercise.name;
    
        NSString *title = [NSString stringWithFormat: @"%@ PR's", name];
        
        [self.navBar.topItem setTitle: title];
    }
}

#pragma mark - <SelectedExerciseObserver>

- (void)didSelectExercise:(TJBExercise *)exercise{
    // fetched results
    
    [self createFRCIfNecessary];
    
    self.activeExercise = exercise;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"exercise.name = %@", exercise.name];
    
    [self.frc.fetchRequest setPredicate: predicate];
    
    [self refreshFRC];
}

- (void)newSetSubmitted{
    [self refreshFRC];
}

- (void)refreshFRC{
    NSError *error = nil;
    if (![self.frc performFetch: &error])
    {
        NSLog(@"Failed to initialize fetchedResultsController: %@\n%@", [error localizedDescription], [error userInfo]);
        abort();
    }
    
    [self refineFetchedResults];
    
    [self.tableView reloadData];
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self.refinedFRCResults count];
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
    
    NSDate *realizedSetStartDate = [realizedSet.endDate dateByAddingTimeInterval: realizedSet.lengthInSeconds * -1];
    
    cell.dateLabel.text = [dateFormatter stringFromDate: realizedSetStartDate];
    
    return cell;
}

@end




















