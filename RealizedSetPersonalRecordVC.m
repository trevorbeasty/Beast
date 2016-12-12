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

@interface RealizedSetPersonalRecordVC ()

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) UINavigationItem *navItem;

@property (nonatomic, strong) NSFetchedResultsController *frc;

@property (nonatomic, strong) TJBRealizedSetExercise *activeExercise;

@end

@implementation RealizedSetPersonalRecordVC

#pragma mark - Instantiation

- (void)viewDidLoad
{
    // table view
    
    UINib *nib = [UINib nibWithNibName: @"RealizedSetPersonalRecordCell"
                                bundle: nil];
    
    [self.tableView registerNib: nib
         forCellReuseIdentifier: @"PRCell"];
    
    // nav bar/item
    
    [self configureNavObjects];
    
    [self.navBar.topItem setTitle: @"Select an Exercise"];

    // NSFetchedResultsController
    
    [self createFRCIfNecessary];
}

- (void)refineFetchedResults
{
    
}

- (void)configureNavObjects
{
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

- (void)createFRCIfNecessary
{
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

- (void)viewWillAppear:(BOOL)animated
{
    if (self.activeExercise)
    {
        NSString *name = self.activeExercise.name;
    
        NSString *title = [NSString stringWithFormat: @"%@ PR's", name];
        
        [self.navBar.topItem setTitle: title];
    }
}

#pragma mark - <SelectedExerciseObserver>

- (void)didSelectExercise:(TJBRealizedSetExercise *)exercise
{
    NSLog(@"didSelectExercise called");

    // fetched results
    
    [self createFRCIfNecessary];
    
    self.activeExercise = exercise;
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"exercise.name = %@", exercise.name];
    
    [self.frc.fetchRequest setPredicate: predicate];
    
    NSError *error = nil;
    if (![self.frc performFetch: &error])
    {
        NSLog(@"Failed to initialize fetchedResultsController: %@\n%@", [error localizedDescription], [error userInfo]);
        abort();
    }
    
    [self.tableView reloadData];
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSUInteger sectionCount = [[[self frc] sections] count];
    return sectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id<NSFetchedResultsSectionInfo> sectionInfo = [[self frc] sections][section];
    NSUInteger numberOfObjects = [sectionInfo numberOfObjects];
    return numberOfObjects;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RealizedSetPersonalRecordCell *cell = [self.tableView dequeueReusableCellWithIdentifier: @"PRCell"];
    
    TJBRealizedSet *realizedSet = [self.frc objectAtIndexPath: indexPath];
    
    cell.repsLabel.text = [[NSNumber numberWithFloat: realizedSet.reps] stringValue];
    cell.weightLabel.text = [[NSNumber numberWithFloat: realizedSet.weight] stringValue];
    
    // date formatter
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    
    cell.dateLabel.text = [dateFormatter stringFromDate: realizedSet.date];
    
    return cell;
}

#pragma mark - <UITableViewDelegate>


@end




















