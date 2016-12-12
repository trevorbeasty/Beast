//
//  TJBRealizedSetActiveEntryVC.m
//  Beast
//
//  Created by Trevor Beasty on 12/8/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import "TJBRealizedSetActiveEntryVC.h"

#import "TJBRealizedSet+CoreDataProperties.h"

#import "TJBNumberSelectionVC.h"
#import "TJBNewExerciseCreationVC.h"

#import "TJBStopWatch.h"

#import "CoreDataController.h"

@interface TJBRealizedSetActiveEntryVC () <UITableViewDelegate, UITableViewDataSource, TJBNumberSelectionDelegate, NewExerciseCreationDelegate, NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *exerciseTableView;

// UI buttons

- (IBAction)setCompleted:(id)sender;
- (IBAction)addNewExercise:(id)sender;

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

// realized set

@property (nonatomic, strong) NSNumber *weight;
@property (nonatomic, strong) NSNumber *reps;
@property (nonatomic, strong) TJBRealizedSetExercise *exercise;

// core data controller

@property (nonatomic, strong) CoreDataController *cdc;
@property (nonatomic, strong) NSManagedObjectContext *moc;

// timer

@property (weak, nonatomic) IBOutlet UILabel *timerLabel;

// navigation bar

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, strong) UINavigationItem *navItem;

@end

@implementation TJBRealizedSetActiveEntryVC

#pragma mark - Instantiation

- (void)viewDidLoad
{
    // navigation bar
    
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle: @"Select an Exercise"];
    self.navItem = navItem;
    
    [self.navigationBar setItems: @[navItem]];
    
    // core data controller
    
    self.cdc = [CoreDataController singleton];
    self.moc = [self.cdc.persistentContainer viewContext];
    
    // table view setup
    
    [self.exerciseTableView registerClass: [UITableViewCell class]
                   forCellReuseIdentifier: @"basicCell"];
    
    // NSFetchedResultsController
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName: @"RealizedSetExercise"];
    NSSortDescriptor *nameSort = [NSSortDescriptor sortDescriptorWithKey: @"name"
                                                               ascending: YES];
    NSSortDescriptor *categorySort = [NSSortDescriptor sortDescriptorWithKey: @"category.name"
                                                                   ascending: YES];
    [request setSortDescriptors: @[categorySort, nameSort]];
    
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
    
    // timer
    
    [[TJBStopwatch singleton] addStopwatchObserver: self.timerLabel];
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
    
    TJBRealizedSetExercise *exercise = [self.fetchedResultsController objectAtIndexPath: indexPath];
    
    cell.textLabel.text = exercise.name;
    
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    id<NSFetchedResultsSectionInfo> sectionInfo = [[self fetchedResultsController] sections][section];
    return [sectionInfo name];
}

#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TJBRealizedSetExercise *exercise = [self.fetchedResultsController objectAtIndexPath: indexPath];
    self.exercise = exercise;
    [self.navItem setTitle: exercise.name];
    
    [self.personalRecordVC didSelectExercise: exercise];
}

#pragma mark - Button Actions

- (void)presentNumberSelectionSceneWithNumberTypeIdentifier:(NSString *)identifier numberMultiple:(NSNumber *)numberMultiple title:(NSString *)title animated:(BOOL)animated
{
    UIStoryboard *numberSelectionStoryboard = [UIStoryboard storyboardWithName: @"TJBNumberSelection"
                                                                        bundle: nil];
    UINavigationController *numberSelectionNav = (UINavigationController *)[numberSelectionStoryboard instantiateInitialViewController];
    TJBNumberSelectionVC *numberSelectionVC = (TJBNumberSelectionVC *)[numberSelectionNav viewControllers][0];
    
    numberSelectionVC.numberTypeIdentifier = identifier;
    numberSelectionVC.numberMultiple = numberMultiple;
    numberSelectionVC.associatedVC = self;
    numberSelectionVC.title = title;
    
    [self presentViewController: numberSelectionNav
                       animated: animated
                     completion: nil];
}

- (IBAction)setCompleted:(id)sender
{
    if (!self.exercise)
    {
        NSLog(@"Please select an exercise first");
    }
    else if (!self.weight)
    {
        [self presentNumberSelectionSceneWithNumberTypeIdentifier: @"weight"
                                                       numberMultiple: [NSNumber numberWithFloat: 2.5]
                                                                title: @"Select Weight"
                                                             animated: YES];
    }
    else if (!self.reps)
    {
        [self presentNumberSelectionSceneWithNumberTypeIdentifier: @"reps"
                                                   numberMultiple: [NSNumber numberWithFloat: 1.0]
                                                            title: @"SelectReps"
                                                         animated: YES];
    }
    else
    {
        [self dismissViewControllerAnimated: NO
                                 completion: nil];
            
        [self addRealizedSetToCoreData];
        [self.cdc saveContext];
            
        self.reps = nil;
        self.weight = nil;
        
        [[TJBStopwatch singleton] resetStopwatch];
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
    
    [self setCompleted: nil];
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
    realizedSet.exercise = self.exercise;
    
    [self.cdc saveContext];
    
    [self.personalRecordVC newSetSubmitted];
}

#pragma mark - <NewExerciseCreationDelegate>

- (void)didCreateNewExercise:(TJBRealizedSetExercise *)exercise
{
    self.exercise = exercise;
    [self.navItem setTitle: exercise.name];
    
    NSError *error = nil;
    [self.fetchedResultsController performFetch: &error];
    [self.exerciseTableView reloadData];
    
    [self dismissViewControllerAnimated: YES
                             completion: nil];
    
    [self.personalRecordVC didSelectExercise: exercise];
}

#pragma mark - <NSFetchedResultsControllerDelegate>





@end


















































