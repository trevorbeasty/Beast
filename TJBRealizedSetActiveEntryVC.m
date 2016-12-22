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

@interface TJBRealizedSetActiveEntryVC () <UITableViewDelegate, UITableViewDataSource, NewExerciseCreationDelegate, NSFetchedResultsControllerDelegate>

@property (weak, nonatomic) IBOutlet UITableView *exerciseTableView;

// UI buttons

//- (IBAction)setCompleted:(id)sender;
- (IBAction)addNewExercise:(id)sender;

- (IBAction)didPressBeginNextSet:(id)sender;


@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

// realized set

@property (nonatomic, strong) NSNumber *weight;
@property (nonatomic, strong) NSNumber *reps;
@property (nonatomic, strong) TJBExercise *exercise;

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
    
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle: @"Home"
                                                                      style: UIBarButtonItemStyleDone
                                                                     target: self
                                                                     action: @selector(didPressDone)];
    
    [navItem setLeftBarButtonItem: barButtonItem];
    
    self.navItem = navItem;
    
    [self.navigationBar setItems: @[navItem]];
    
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

- (void)viewWillAppear:(BOOL)animated
{
    self.timerLabel.text = [[TJBStopwatch singleton] elapsedTimeAsFormattedString];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TJBExercise *exercise = [self.fetchedResultsController objectAtIndexPath: indexPath];
    self.exercise = exercise;
    [self.navItem setTitle: exercise.name];
    
    [self.personalRecordVC didSelectExercise: exercise];
}

#pragma mark - Button Actions

- (void)didPressDone
{
    [self dismissViewControllerAnimated: NO
                             completion: nil];
}

- (void)presentNumberSelectionSceneWithNumberTypeIdentifier:(NumberType)identifier numberMultiple:(NSNumber *)numberMultiple title:(NSString *)title animated:(BOOL)animated
{
    UIStoryboard *numberSelectionStoryboard = [UIStoryboard storyboardWithName: @"TJBNumberSelection"
                                                                        bundle: nil];
    UINavigationController *numberSelectionNav = (UINavigationController *)[numberSelectionStoryboard instantiateInitialViewController];
    TJBNumberSelectionVC *numberSelectionVC = (TJBNumberSelectionVC *)[numberSelectionNav viewControllers][0];
    
    [numberSelectionVC setNumberTypeIdentifier: identifier
                                numberMultiple: numberMultiple
                                  associatedVC: self
                                         title: title];
    
    [self presentViewController: numberSelectionNav
                       animated: animated
                     completion: nil];
}

- (IBAction)setCompleted:(id)sender
{
    if (!self.exercise)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"No Exercise Selected"
                                                                       message: @"Please select an exercise before submitting a completed set"
                                                                preferredStyle: UIAlertControllerStyleAlert];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle: @"Continue"
                                                         style: UIAlertActionStyleDefault
                                                       handler: nil];
        
        [alert addAction: action];
        
        [self presentViewController: alert
                           animated: YES
                         completion: nil];
    }
    else if (!self.weight)
    {
        [self presentNumberSelectionSceneWithNumberTypeIdentifier: WeightType
                                                   numberMultiple: [NSNumber numberWithFloat: 2.5]
                                                            title: @"Select Weight"
                                                         animated: YES];
    }
    else if (!self.reps)
    {
        [self presentNumberSelectionSceneWithNumberTypeIdentifier: RepsType
                                                   numberMultiple: [NSNumber numberWithFloat: 1.0]
                                                            title: @"SelectReps"
                                                         animated: YES];
    }
    else
    {
        [self presentSubmittedSetSummary];
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

- (IBAction)didPressBeginNextSet:(id)sender
{
    [self presentNumberSelectionSceneWithNumberTypeIdentifier: RestType
                                               numberMultiple: [NSNumber numberWithInt: 5]
                                                        title: @"Select Time Delay"
                                                     animated: YES];
}

#pragma mark - <TJBNumberSelectionDelegate>

- (void)didCancelNumberSelection
{
    self.reps = nil;
    self.weight = nil;
    
    [self dismissViewControllerAnimated: NO
                             completion: nil];
}

- (void)didSelectNumber:(NSNumber *)number numberTypeIdentifier:(NumberType)identifier
{
    if (identifier == RepsType)
    {
        self.reps = number;
    }
    else if (identifier == WeightType)
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

- (void)didCreateNewExercise:(TJBExercise *)exercise
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

#pragma mark - Notification to User

- (void)presentSubmittedSetSummary
{
    // UIAlertController
    
    NSString *string = [NSString stringWithFormat: @"%@: %.01f lbs for %.00f reps",
                        self.exercise.name,
                        [self.weight floatValue],
                        [self.reps floatValue]];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"Detail Confirmation"
                                                                   message: string
                                                            preferredStyle: UIAlertControllerStyleAlert];
    
    // capture a weak reference to self in order to avoid a strong reference cycle
    
    __weak TJBRealizedSetActiveEntryVC *weakSelf = self;
    
    void (^action1Block)(UIAlertAction *) = ^(UIAlertAction *action){
        [weakSelf cancelSubmission];
    };
    
    void (^action2Block)(UIAlertAction *) = ^(UIAlertAction *action){
        [weakSelf confirmSubmission];
    };
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle: @"Cancel"
                                                      style: UIAlertActionStyleDefault
                                                    handler: action1Block];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle: @"Confirm"
                                                      style: UIAlertActionStyleDefault
                                                    handler: action2Block];
    
    [alert addAction: action1];
    [alert addAction: action2];
    
    [self presentViewController: alert
                       animated: YES
                     completion: nil];
}

- (void)cancelSubmission
{
    self.reps = nil;
    self.weight = nil;
}

- (void)confirmSubmission
{
    [[TJBStopwatch singleton] resetStopwatch];
    
    [self addRealizedSetToCoreData];
    
    self.reps = nil;
    self.weight = nil;
}

@end


















































