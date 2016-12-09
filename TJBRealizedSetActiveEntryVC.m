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
#import "TJBRealizedSet+CoreDataProperties.h"

#import "TJBNumberSelectionVC.h"
#import "TJBNewExerciseCreationVC.h"

#import "CoreDataController.h"

@interface TJBRealizedSetActiveEntryVC () <UITableViewDelegate, UITableViewDataSource, TJBNumberSelectionDelegate, NewExerciseCreationDelegate, NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *exerciseTableView;

- (IBAction)setCompleted:(id)sender;
- (IBAction)addNewExercise:(id)sender;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

// realized set

@property (nonatomic, strong) NSNumber *weight;
@property (nonatomic, strong) NSNumber *reps;
@property (nonatomic, strong) TJBExercise *exercise;

// core data controller

@property (nonatomic, strong) CoreDataController *cdc;
@property (nonatomic, strong) NSManagedObjectContext *moc;

@end

@implementation TJBRealizedSetActiveEntryVC

#pragma mark - Instantiation

- (void)viewDidLoad
{
    // core data controller
    
    self.cdc = [CoreDataController singleton];
    self.moc = [self.cdc.persistentContainer viewContext];
    
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
                                                                            sectionNameKeyPath: @"category.name"
                                                                                     cacheName: nil];
    frc.delegate = self;
    
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
    UITableViewCell *cell = [self.exerciseTableView dequeueReusableCellWithIdentifier: @"basicCell"];
    
    TJBExercise *exercise = [self.fetchedResultsController objectAtIndexPath: indexPath];
    
    cell.textLabel.text = exercise.name;
    
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    id<NSFetchedResultsSectionInfo> sectionInfo = [[self fetchedResultsController] sections][section];
    return [sectionInfo name];
}

#pragma mark - <UITableViewDelegate>



#pragma mark - Button Actions

- (IBAction)setCompleted:(id)sender
{
    // modal presentation of number selection for weight if exercise has been selected
    
    if (self.exercise)
    {
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
    else
    {
        // notification to please select an exercise first
        
        
    }

}

- (IBAction)addNewExercise:(id)sender
{
    TJBNewExerciseCreationVC *necVC = [[TJBNewExerciseCreationVC alloc] init];
    
    necVC.associateVC = self;
    
    [self presentViewController: necVC
                       animated: YES
                     completion: nil];
}

#pragma mark - <TJBNumberSelectionDelegate>

- (void)didSelectNumber:(NSNumber *)number numberTypeIdentifier:(NSString *)identifier
{
    if ([identifier isEqualToString: @"reps"])
    {
        self.reps = number;
    }
    else if ([identifier isEqualToString: @"weight"])
    {
        self.weight = number;
    }
    
    [self dismissViewControllerAnimated: NO
                             completion: nil];
    
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
    
    if (self.weight && self.reps)
    {
        [self addRealizedSetToCoreData];
    }
}

- (void)addRealizedSetToCoreData
{
    NSDate *date = [NSDate date];
    BOOL postMortem = FALSE;
    
    TJBRealizedSet *realizedSet = [NSEntityDescription insertNewObjectForEntityForName: @"RealizedSet"
                                                                inManagedObjectContext: self.moc];
    
    realizedSet.date = date;
    realizedSet.postMortem = postMortem;
    realizedSet.weight = [self.weight floatValue];
    realizedSet.reps = [self.reps floatValue];
    
    [self.cdc saveContext];
}

#pragma mark - <NewExerciseCreationDelegate>

- (void)didCreateNewExercise:(TJBExercise *)exercise
{
    self.exercise = exercise;
    
    NSError *error = nil;
    [self.fetchedResultsController performFetch: &error];
    [self.exerciseTableView reloadData];
    
    [self dismissViewControllerAnimated: YES
                             completion: nil];
}

#pragma mark - <NSFetchedResultsControllerDelegate>



@end


















































