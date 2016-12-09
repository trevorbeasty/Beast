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
#import "TJBExerciseCategory+CoreDataProperties.h"

#import "TJBNumberSelectionVC.h"

#import "CoreDataController.h"

@interface TJBRealizedSetActiveEntryVC () <UITableViewDelegate, UITableViewDataSource, TJBNumberSelectionDelegate>

@property (weak, nonatomic) IBOutlet UITableView *exerciseTableView;

- (IBAction)setCompleted:(id)sender;
- (IBAction)addNewExercise:(id)sender;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

// realized set

@property (nonatomic, strong) NSNumber *weight;
@property (nonatomic, strong) NSNumber *reps;

// core data controller

@property (nonatomic, strong) CoreDataController *cdc;

@end

@implementation TJBRealizedSetActiveEntryVC

#pragma mark - Instantiation

- (void)viewDidLoad
{
    // core data controller
    
    self.cdc = [CoreDataController singleton];
    
    // table view setup
    
    [self.exerciseTableView registerClass: [UITableViewCell class]
                   forCellReuseIdentifier: @"basicCell"];
    
    // NSFetchedResultsController
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName: @"Exercise"];
    NSSortDescriptor *nameSort = [NSSortDescriptor sortDescriptorWithKey: @"name"
                                                               ascending: YES];
    [request setSortDescriptors: @[nameSort]];
    
    NSManagedObjectContext *moc = [self.cdc.persistentContainer viewContext];
    
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
    
    TJBExercise *exercise = [self.fetchedResultsController objectAtIndexPath: indexPath];
    
    cell.textLabel.text = exercise.name;
    
    return cell;
}

#pragma mark - <UITableViewDelegate>



#pragma mark - Button Actions

- (IBAction)setCompleted:(id)sender
{
    // modal presentation of number selection for weight
    
    UIStoryboard *numberSelectionStoryboard = [UIStoryboard storyboardWithName: @"TJBNumberSelection"
                                                                        bundle: nil];
    UINavigationController *numberSelectionNav = (UINavigationController *)[numberSelectionStoryboard instantiateInitialViewController];
    TJBNumberSelectionVC *numberSelectionVC = (TJBNumberSelectionVC *)[numberSelectionNav viewControllers][0];
    
    numberSelectionVC.numberTypeIdentifier = @"weight";
    numberSelectionVC.numberMultiple = [NSNumber numberWithFloat: 2.5];
    numberSelectionVC.associatedVC = self;
    numberSelectionVC.title = @"Weight";
    
    [self presentViewController: numberSelectionNav
                       animated: NO
                     completion: nil];
}

- (IBAction)addNewExercise:(id)sender
{
    
}

#pragma mark - <TJBNumberSelectionDelegate>

- (void)didSelectNumber:(NSNumber *)number numberTypeIdentifier:(NSString *)identifier
{
    if ([identifier isEqualToString: @"reps"])
    {
        self.reps = number;
        [self dismissViewControllerAnimated: NO
                                 completion: nil];
    }
    else if ([identifier isEqualToString: @"weight"])
    {
        self.weight = number;
        [self dismissViewControllerAnimated: NO
                                 completion: nil];
    }
    
    if (!self.reps)
    {
        UIStoryboard *numberSelectionStoryboard = [UIStoryboard storyboardWithName: @"TJBNumberSelection"
                                                                            bundle: nil];
        UINavigationController *numberSelectionNav = (UINavigationController *)[numberSelectionStoryboard instantiateInitialViewController];
        TJBNumberSelectionVC *numberSelectionVC = (TJBNumberSelectionVC *)[numberSelectionNav viewControllers][0];
        
        numberSelectionVC.numberTypeIdentifier = @"reps";
        numberSelectionVC.numberMultiple = [NSNumber numberWithFloat: 1.0];
        numberSelectionVC.associatedVC = self;
        numberSelectionVC.title = @"Reps";
        
        [self presentViewController: numberSelectionNav
                           animated: NO
                         completion: nil];
    }
    
    NSLog(@"\nweight: %f\nreps: %f\n", [self.weight floatValue], [self.reps floatValue]);
}





@end












