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
#import "TJBInSetVC.h"

#import "TJBStopWatch.h"

#import "CoreDataController.h"

@interface TJBRealizedSetActiveEntryVC () <UITableViewDelegate, UITableViewDataSource, NewExerciseCreationDelegate, NSFetchedResultsControllerDelegate>

{
    BOOL _setCompletedButtonPressed;
    BOOL _whiteoutActive;
}

@property (weak, nonatomic) IBOutlet UITableView *exerciseTableView;

// UI buttons

//- (IBAction)setCompleted:(id)sender;
- (IBAction)addNewExercise:(id)sender;

- (IBAction)didPressBeginNextSet:(id)sender;


@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

// realized set

@property (nonatomic, strong) NSNumber *timeDelay;
@property (nonatomic, strong) NSNumber *timeLag;
@property (nonatomic, strong) NSNumber *weight;
@property (nonatomic, strong) NSNumber *reps;
@property (nonatomic, strong) TJBExercise *exercise;

@property (nonatomic, strong) UIView *whiteoutView;

// core data controller

@property (nonatomic, strong) CoreDataController *cdc;
@property (nonatomic, strong) NSManagedObjectContext *moc;

// timer

@property (weak, nonatomic) IBOutlet UILabel *timerLabel;

// navigation bar

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, strong) UINavigationItem *navItem;



@end


typedef void(^CancelBlock)(void);
typedef void(^NumberSelectedBlock)(NSNumber *);

@implementation TJBRealizedSetActiveEntryVC

#pragma mark - Instantiation

- (void)viewDidLoad
{
    _setCompletedButtonPressed = NO;
    _whiteoutActive = NO;
    
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
    
    [[TJBStopwatch singleton] addPrimaryStopwatchObserver: self.timerLabel];
}

- (void)viewWillAppear:(BOOL)animated
{
    self.timerLabel.text = [[TJBStopwatch singleton] primaryTimeElapsedAsString];
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
    CancelBlock cancelBlock = ^{
        [self removeWhiteoutView];
        [self setRealizedSetParametersToNil];
        [self dismissViewControllerAnimated: NO
                                 completion: nil];
    };
    
    if (_whiteoutActive == NO)
    {
        UIView *whiteout = [[UIView alloc] initWithFrame: [self.view bounds]];
        whiteout.backgroundColor = [UIColor whiteColor];
        
        self.whiteoutView = whiteout;
        [self.view addSubview: whiteout];
        _whiteoutActive = YES;
    }
    
    if (!self.exercise)
    {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"No Exercise Selected"
                                                                       message: @"Please select an exercise before submitting a completed set"
                                                                preferredStyle: UIAlertControllerStyleAlert];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle: @"Continue"
                                                         style: UIAlertActionStyleDefault
                                                       handler: nil];
        
        [alert addAction: action];
        
        [self removeWhiteoutView];
        
        [self presentViewController: alert
                           animated: YES
                         completion: nil];
   
    }
    else if(!self.timeDelay)
    {
        NumberSelectedBlock numberSelectedBlock = ^(NSNumber *number){
            self.timeDelay = number;
            [self dismissViewControllerAnimated: NO
                                     completion: nil];
            [self didPressBeginNextSet: nil];
        };
        
        
        [self presentNumberSelectionSceneWithNumberType: RestType
                                         numberMultiple: [NSNumber numberWithInt: 5]
                                            numberLimit: nil
                                                  title: @"Select Delay"
                                            cancelBlock: cancelBlock
                                    numberSelectedBlock: numberSelectedBlock
                                               animated: YES
                                   modalTransitionStyle: UIModalTransitionStyleCoverVertical];
    }
    else if (_setCompletedButtonPressed == NO)
    {
        void(^block)(void) = ^{
            _setCompletedButtonPressed = YES;
            [self dismissViewControllerAnimated: NO
                                     completion: nil];
            [self didPressBeginNextSet: nil];
        };
        
        TJBInSetVC *vc = [[TJBInSetVC alloc] initWithDidPressSetCompletedBlock: block];
        
        [self presentViewController: vc
                           animated: NO
                         completion: nil];
    }
    else if (!self.timeLag)
    {
        NumberSelectedBlock numberSelectedBlock = ^(NSNumber *number){
            self.timeLag = number;
            [self dismissViewControllerAnimated: NO
                                     completion: nil];
            [self didPressBeginNextSet: nil];
        };
        
        [self presentNumberSelectionSceneWithNumberType: RestType
                                         numberMultiple: [NSNumber numberWithInt: 5]
                                            numberLimit: nil
                                                  title: @"Select Lag"
                                            cancelBlock: cancelBlock
                                    numberSelectedBlock: numberSelectedBlock
                                               animated: YES
                                   modalTransitionStyle: UIModalTransitionStyleCoverVertical];
    }
    else if (!self.weight)
    {
        NumberSelectedBlock numberSelectedBlock = ^(NSNumber *number){
            self.weight = number;
            [self dismissViewControllerAnimated: NO
                                     completion: nil];
            [self didPressBeginNextSet: nil];
        };
        
        
        [self presentNumberSelectionSceneWithNumberType: WeightType
                                         numberMultiple: [NSNumber numberWithFloat: 2.5]
                                            numberLimit: nil
                                                  title: @"Select Weight"
                                            cancelBlock: cancelBlock
                                    numberSelectedBlock: numberSelectedBlock
                                               animated: YES
                                   modalTransitionStyle: UIModalTransitionStyleCoverVertical];
    }
    else if (!self.reps)
    {
        NumberSelectedBlock numberSelectedBlock = ^(NSNumber *number){
            self.reps = number;
            [self dismissViewControllerAnimated: NO
                                     completion: nil];
            [self didPressBeginNextSet: nil];
        };
        
        
        [self presentNumberSelectionSceneWithNumberType: RepsType
                                         numberMultiple: [NSNumber numberWithInt: 1]
                                            numberLimit: nil
                                                  title: @"Select Reps"
                                            cancelBlock: cancelBlock
                                    numberSelectedBlock: numberSelectedBlock
                                               animated: YES
                                   modalTransitionStyle: UIModalTransitionStyleCoverVertical];
    }
    else
    {
        [self removeWhiteoutView];
        [self presentSubmittedSetSummary];
    }
}

- (void)removeWhiteoutView
{
    [self.whiteoutView removeFromSuperview];
    _whiteoutActive = NO;
}

- (void)presentNumberSelectionSceneWithNumberType:(NumberType)numberType numberMultiple:(NSNumber *)numberMultiple numberLimit:(NSNumber *)numberLimit title:(NSString *)title cancelBlock:(void(^)(void))cancelBlock numberSelectedBlock:(void(^)(NSNumber *))numberSelectedBlock animated:(BOOL)animated modalTransitionStyle:(UIModalTransitionStyle)transitionStyle;
{
    
    UIStoryboard *numberSelectionStoryboard = [UIStoryboard storyboardWithName: @"TJBNumberSelection"
                                                                        bundle: nil];
    UINavigationController *numberSelectionNav = (UINavigationController *)[numberSelectionStoryboard instantiateInitialViewController];
    TJBNumberSelectionVC *numberSelectionVC = (TJBNumberSelectionVC *)[numberSelectionNav viewControllers][0];
    
    [numberSelectionVC setNumberTypeIdentifier: numberType
                                numberMultiple: numberMultiple
                                   numberLimit: numberLimit
                                         title: title
                                   cancelBlock: cancelBlock
                           numberSelectedBlock: numberSelectedBlock];
    
    numberSelectionNav.modalTransitionStyle = transitionStyle;
    
    [self presentViewController: numberSelectionNav
                       animated: animated
                     completion: nil];
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
        [weakSelf setRealizedSetParametersToNil];
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

- (void)setRealizedSetParametersToNil
{
    self.timeDelay = nil;
    _setCompletedButtonPressed = NO;
    self.timeLag = nil;
    self.weight = nil;
    self.reps = nil;
}

- (void)confirmSubmission
{
    [[TJBStopwatch singleton] resetPrimaryStopwatch];
    
    [self addRealizedSetToCoreData];
    
    [self setRealizedSetParametersToNil];
}

@end


















































