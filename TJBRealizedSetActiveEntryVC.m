//
//  TJBRealizedSetActiveEntryVC.m
//  Beast
//
//  Created by Trevor Beasty on 12/8/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "AppDelegate.h"

#import "TJBRealizedSetActiveEntryVC.h"

#import "TJBExercise+CoreDataProperties.h"
//#import "TJBExerciseCategory+CoreDataProperties.h"



@interface TJBRealizedSetActiveEntryVC () <UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *exerciseTableView;

- (IBAction)setCompleted:(id)sender;
- (IBAction)addNewExercise:(id)sender;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@end

@implementation TJBRealizedSetActiveEntryVC

#pragma mark - Instantiation

- (void)viewDidLoad
{
    // table view setup
    
    [self.exerciseTableView registerClass: [UITableViewCell class]
                   forCellReuseIdentifier: @"basicCell"];
    
    // NSFetchedResultsController
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName: @"Exercise"];
    NSSortDescriptor *nameSort = [NSSortDescriptor sortDescriptorWithKey: @"name"
                                                               ascending: YES];
    [request setSortDescriptors: @[nameSort]];
    
    AppDelegate *ad = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    NSManagedObjectContext *moc = [ad.persistentContainer viewContext];
    
    NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest: request
                                                                          managedObjectContext: moc
                                                                            sectionNameKeyPath: nil
                                                                                     cacheName: nil];
    frc.delegate = nil;
    
    self.fetchedResultsController = frc;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch: &error])
    {
        NSLog(@"Failed to initialize fetchedResultsController: %@\n%@", [error localizedDescription], [error userInfo]);
        abort();
    }
    
    
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [[self.fetchedResultsController fetchedObjects] count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.exerciseTableView dequeueReusableCellWithIdentifier: @"basicCell"];
    
//    TJBExercise *exercise = [self.fetchedResultsController objectAtIndexPath: indexPath];
    return cell;
}

#pragma mark - <UITableViewDelegate>



#pragma mark - Button Actions

- (IBAction)setCompleted:(id)sender
{
    
}

- (IBAction)addNewExercise:(id)sender
{
    
}
@end
