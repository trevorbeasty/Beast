//
//  TJBRealizedSetHistoryByDay.m
//  Beast
//
//  Created by Trevor Beasty on 12/9/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import "TJBRealizedSetHistoryByDay.h"

#import "CoreDataController.h"

@interface TJBRealizedSetHistoryByDay () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, strong) UINavigationItem *navItem;

@property (nonatomic, strong) NSFetchedResultsController *frc;

@end

@implementation TJBRealizedSetHistoryByDay

#pragma mark - Instantiation

- (void)viewDidLoad
{
    // navigation bar
    
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle: @"Today's Sets"];
    self.navItem = navItem;
    
    [self.navigationBar setItems: @[navItem]];
    
    // NSFetchedResultsController
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName: @"RealizedSet"];
    NSSortDescriptor *nameSort = [NSSortDescriptor sortDescriptorWithKey: @"date"
                                                               ascending: NO];
    
    // create NSDate objects defining the first and last seconds of today in order to effectively filter the retrieved 'realized set' objects
    
    NSDate *todayBegin = [[NSCalendar calendarWithIdentifier: NSCalendarIdentifierGregorian] startOfDayForDate: [NSDate date]];
    
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.day = 1;
    NSDate *todayEnd = [[NSCalendar calendarWithIdentifier: NSCalendarIdentifierGregorian] dateByAddingComponents: dateComponents
                                                                                                           toDate: todayBegin
                                                                                                          options: 0];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"(date >= %@) AND (date <= %@)", todayBegin, todayEnd];
    
    [request setPredicate: predicate];
    
    [request setSortDescriptors: @[nameSort]];
    
    NSManagedObjectContext *moc = [[CoreDataController singleton] moc];
    
    NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest: request
                                                                          managedObjectContext: moc
                                                                            sectionNameKeyPath: nil
                                                                                     cacheName: nil];
    NSLog(@"\ntotal sets fetched: %lu\n", [[frc fetchedObjects] count]);
    
    frc.delegate = nil;
    
    self.frc = frc;
    
    NSError *error = nil;
    if (![self.frc performFetch: &error])
    {
        NSLog(@"Failed to initialize fetchedResultsController: %@\n%@", [error localizedDescription], [error userInfo]);
        abort();
    }
    
    // table view
    
    [self.tableView registerClass: [UITableViewCell class]
           forCellReuseIdentifier: @"basicCell"];
}

- (void)viewWillAppear:(BOOL)animated
{
    NSError *error = nil;
    [self.frc performFetch: &error];
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
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier: @"basicCell"];
    
    TJBRealizedSet *realizedSet = [self.frc objectAtIndexPath: indexPath];
    
    cell.textLabel.text = realizedSet.exercise.name;
    
    return cell;
}

//-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
//{
//    id<NSFetchedResultsSectionInfo> sectionInfo = [[self fetchedResultsController] sections][section];
//    return [sectionInfo name];
//}

#pragma mark - <UITableViewDelegate>

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    TJBRealizedSetExercise *exercise = [self.fetchedResultsController objectAtIndexPath: indexPath];
//    self.exercise = exercise;
//    [self.navItem setTitle: exercise.name];
//}



@end










































