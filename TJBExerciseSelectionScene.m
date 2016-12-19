//
//  TJBExerciseSelectionScene.m
//  Beast
//
//  Created by Trevor Beasty on 12/19/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import "TJBExerciseSelectionScene.h"

#import "CoreDataController.h"

@interface TJBExerciseSelectionScene ()

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (weak, nonatomic) IBOutlet UITableView *exerciseTableView;

// navigation bar

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (nonatomic, strong) UINavigationItem *navItem;

@end

static NSString * const cellReuseIdentifier = @"basicCell";

@implementation TJBExerciseSelectionScene

#pragma mark - Instantiation

- (void)viewDidLoad
{
    [self configureTableView];
    
    [self createFetchedResultsController];
}

- (void)configureNavigationBar
{
    UINavigationItem *navItem = [[UINavigationItem alloc] init];
    
}

- (void)createFetchedResultsController
{
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName: @"Exercise"];
    NSSortDescriptor *nameSort = [NSSortDescriptor sortDescriptorWithKey: @"name"
                                                               ascending: YES];
    NSSortDescriptor *categorySort = [NSSortDescriptor sortDescriptorWithKey: @"category.name"
                                                                   ascending: YES];
    [request setSortDescriptors: @[categorySort, nameSort]];
    
    NSManagedObjectContext *moc = [[CoreDataController singleton] moc];
    
    NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest: request
                                                                          managedObjectContext: moc
                                                                            sectionNameKeyPath: @"category.name"
                                                                                     cacheName: nil];
    
    self.fetchedResultsController = frc;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch: &error])
    {
        NSLog(@"Failed to initialize fetchedResultsController: %@\n%@", [error localizedDescription], [error userInfo]);
        abort();
    }
}

- (void)configureTableView
{
    [self.exerciseTableView registerClass: [UITableViewCell class]
                   forCellReuseIdentifier: cellReuseIdentifier];
}



#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSUInteger sectionCount = [[[self fetchedResultsController] sections] count];
    return sectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id<NSFetchedResultsSectionInfo> sectionInfo = [[self fetchedResultsController] sections][section];
    NSUInteger numberOfObjects = [sectionInfo numberOfObjects];
    return numberOfObjects;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.exerciseTableView dequeueReusableCellWithIdentifier: cellReuseIdentifier];
    
    TJBRealizedSetExercise *exercise = [self.fetchedResultsController objectAtIndexPath: indexPath];
    
    cell.textLabel.text = exercise.name;
    
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    id<NSFetchedResultsSectionInfo> sectionInfo = [[self fetchedResultsController] sections][section];
    return [sectionInfo name];
}

@end


















