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

#import "TJBAestheticsController.h"

@interface TJBRealizedSetActiveEntryVC () <UITableViewDelegate, UITableViewDataSource, NSFetchedResultsControllerDelegate, UIViewControllerRestoration>

{
    BOOL _setCompletedButtonPressed;
    int _timerAtSetCompletion;
    BOOL _whiteoutActive;
}

@property (weak, nonatomic) IBOutlet UITableView *exerciseTableView;

// UI buttons
- (IBAction)addNewExercise:(id)sender;
- (IBAction)didPressBeginNextSet:(id)sender;

@property (weak, nonatomic) IBOutlet UIButton *addNewExerciseButton;
@property (weak, nonatomic) IBOutlet UIButton *beginNextSetButton;

// core data
@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

// realized set user input
@property (nonatomic, strong) NSNumber *timeDelay;
@property (nonatomic, strong) NSNumber *timeLag;
@property (nonatomic, strong) NSNumber *weight;
@property (nonatomic, strong) NSNumber *reps;
@property (nonatomic, strong) TJBExercise *exercise;

@property (nonatomic, strong) UIView *whiteoutView;

// timer
@property (weak, nonatomic) IBOutlet UILabel *timerLabel;

// navigation bar
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
// need to keep it around to update the title as exercises are selected
// should this be a weak property?
@property (nonatomic, weak) UINavigationItem *navItem;

@end

@implementation TJBRealizedSetActiveEntryVC

#pragma mark - Instantiation

- (instancetype)init{
    self = [super init];
    
    // for restoration
    self.restorationIdentifier = @"TJBRealizedSetActiveEntryVC";
    self.restorationClass = [TJBRealizedSetActiveEntryVC class];
    
    return self;
}

#pragma mark - View Life Cycle

- (void)viewDidLoad{
    _setCompletedButtonPressed = NO;
    _whiteoutActive = NO;
    
    [self configureNavigationBar];
    [self fetchCoreDataAndConfigureTableView];
    [self configureTimer];
    [self addBackgroundImage];
    [self viewAesthetics];
}

- (void)viewAesthetics{
    self.exerciseTableView.layer.opacity = .85;
    
    NSArray *buttons = @[self.beginNextSetButton,
                         self.addNewExerciseButton];
    [[TJBAestheticsController singleton] configureButtonsInArray: buttons
                                                     withOpacity: .85];
}

- (void)addBackgroundImage{
    [[TJBAestheticsController singleton] addFullScreenBackgroundViewWithImage: [UIImage imageNamed: @"girlOverheadKettlebell"]
                                                                   toRootView: self.view
                                                                 imageOpacity: .35];
}

- (void)configureNavigationBar{
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle: @"Select an Exercise"];
    UIBarButtonItem *barButtonItem = [[UIBarButtonItem alloc] initWithTitle: @"Home"
                                                                      style: UIBarButtonItemStyleDone
                                                                     target: self
                                                                     action: @selector(didPressDone)];
    [navItem setLeftBarButtonItem: barButtonItem];
    self.navItem = navItem;
    [self.navigationBar setItems: @[navItem]];
    
    [TJBAestheticsController configureNavigationBar: self.navigationBar];
}

- (void)fetchCoreDataAndConfigureTableView{
    // table view configuration
    [self.exerciseTableView registerClass: [UITableViewCell class]
                   forCellReuseIdentifier: @"basicCell"];
    
    // NSFetchedResultsController
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
    frc.delegate = self;
    self.fetchedResultsController = frc;
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch: &error])
    {
        NSLog(@"Failed to initialize fetchedResultsController: %@\n%@", [error localizedDescription], [error userInfo]);
        abort();
    }
}

- (void)configureTimer{
    TJBStopwatch *stopwatch = [TJBStopwatch singleton];
    [stopwatch setPrimaryStopWatchToTimeInSeconds: 0
                          withForwardIncrementing: YES];
    [stopwatch addPrimaryStopwatchObserver: self.timerLabel];
    
    CALayer *layer = self.timerLabel.layer;
    layer.masksToBounds = YES;
    layer.cornerRadius = 8;
    layer.opacity = .85;
}

//- (void)viewWillAppear:(BOOL)animated{
//    self.timerLabel.text = [[TJBStopwatch singleton] primaryTimeElapsedAsString];
//    
//    NSError *error = nil;
//    [self.fetchedResultsController performFetch: &error];
//    [self.exerciseTableView reloadData];
//}

#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSUInteger sectionCount = [[[self fetchedResultsController] sections] count];
    return sectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    id<NSFetchedResultsSectionInfo> sectionInfo = [[self fetchedResultsController] sections][section];
    NSUInteger numberOfObjects = [sectionInfo numberOfObjects];
    return numberOfObjects;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [self.exerciseTableView dequeueReusableCellWithIdentifier: @"basicCell"];
    TJBExercise *exercise = [self.fetchedResultsController objectAtIndexPath: indexPath];
    cell.textLabel.text = exercise.name;
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    id<NSFetchedResultsSectionInfo> sectionInfo = [[self fetchedResultsController] sections][section];
    return [sectionInfo name];
}

#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    TJBExercise *exercise = [self.fetchedResultsController objectAtIndexPath: indexPath];
    self.exercise = exercise;
    [self.navItem setTitle: exercise.name];
    
    [self.personalRecordVC didSelectExercise: exercise];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UILabel *label = [[UILabel alloc] initWithFrame: CGRectMake(0, 0, tableView.bounds.size.width, 40)];
    label.backgroundColor = [[TJBAestheticsController singleton] labelType1Color];
    label.text = [self tableView: tableView
         titleForHeaderInSection: section];
    label.textAlignment = NSTextAlignmentCenter;
    return label;
}

#pragma mark - Button Actions

- (void)didPressDone{
    [self dismissViewControllerAnimated: NO
                             completion: nil];
}

- (IBAction)addNewExercise:(id)sender{
    TJBNewExerciseCreationVC *vc = [[TJBNewExerciseCreationVC alloc] init];
    
    [self presentViewController: vc
                       animated: YES
                     completion: nil];
}

- (IBAction)didPressBeginNextSet:(id)sender{
    __weak TJBRealizedSetActiveEntryVC *weakSelf = self;
    
    CancelBlock cancelBlock = ^{
        [weakSelf removeWhiteoutView];
        [weakSelf setRealizedSetParametersToNil];
        [weakSelf dismissViewControllerAnimated: NO
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
            weakSelf.timeDelay = number;
            [weakSelf dismissViewControllerAnimated: NO
                                     completion: nil];
            [weakSelf didPressBeginNextSet: nil];
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
        void(^block)(int) = ^(int timeInSeconds){
            _setCompletedButtonPressed = YES;
            _timerAtSetCompletion = timeInSeconds;
            [weakSelf dismissViewControllerAnimated: NO
                                     completion: nil];
            [weakSelf didPressBeginNextSet: nil];
        };
        
        TJBInSetVC *vc = [[TJBInSetVC alloc] initWithTimeDelay: [self.timeDelay intValue]
                                     DidPressSetCompletedBlock: block
                                                  exerciseName: self.exercise.name];
        
        [self presentViewController: vc
                           animated: NO
                         completion: nil];
    }
    else if (!self.timeLag)
    {
        NumberSelectedBlock numberSelectedBlock = ^(NSNumber *number){
            weakSelf.timeLag = number;
            [weakSelf dismissViewControllerAnimated: NO
                                     completion: nil];
            [weakSelf didPressBeginNextSet: nil];
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
            weakSelf.weight = number;
            [weakSelf dismissViewControllerAnimated: NO
                                     completion: nil];
            [weakSelf didPressBeginNextSet: nil];
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
            weakSelf.reps = number;
            [weakSelf dismissViewControllerAnimated: NO
                                     completion: nil];
            [weakSelf didPressBeginNextSet: nil];
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

- (void)addRealizedSetToCoreData{
    BOOL postMortem = FALSE;
    NSManagedObjectContext *moc = [[CoreDataController singleton] moc];
    TJBRealizedSet *realizedSet = [NSEntityDescription insertNewObjectForEntityForName: @"RealizedSet"
                                                                inManagedObjectContext: moc];
    
    realizedSet.endDate = [NSDate date];
    realizedSet.lengthInSeconds = _timerAtSetCompletion - [self.timeLag intValue];
    realizedSet.postMortem = postMortem;
    realizedSet.weight = [self.weight floatValue];
    realizedSet.reps = [self.reps floatValue];
    realizedSet.exercise = self.exercise;
    
    [[CoreDataController singleton] saveContext];
    
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
    [[TJBStopwatch singleton] resetPrimaryStopwatchWithForwardIncrementing: YES];
    
    [self addRealizedSetToCoreData];
    
    [self setRealizedSetParametersToNil];
}

#pragma mark - <UIViewControllerRestoration>

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder{
    TJBRealizedSetActiveEntryVC *vc = [[TJBRealizedSetActiveEntryVC alloc] init];
    
    return vc;
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder{
    [super encodeRestorableStateWithCoder: coder];
    
    int time = [[[TJBStopwatch singleton] primaryTimeElapsedInSeconds] intValue];
    [coder encodeInt: time
              forKey: @"time"];
    
    // table view
    
//    UIEdgeInsets scrollPosition = self.exerciseTableView.contentInset;
    
    NSIndexPath *path = self.exerciseTableView.indexPathForSelectedRow;
    if (path){
        [coder encodeObject: path
                     forKey: @"path"];
    }
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder{
    [super decodeRestorableStateWithCoder: coder];
    
    // timer
    int time = [coder decodeIntForKey: @"time"];
    [[TJBStopwatch singleton] setPrimaryStopWatchToTimeInSeconds: time
                                         withForwardIncrementing: YES];
    self.timerLabel.text = [[TJBStopwatch singleton] minutesAndSecondsStringFromNumberOfSeconds: time];
    
    // tabel view
    NSIndexPath *path = [coder decodeObjectForKey: @"path"];
    NSLog(@"%@", path);
    if (path){
        [self.exerciseTableView selectRowAtIndexPath: path
                                            animated: NO
                                      scrollPosition: UITableViewScrollPositionNone];
        [self tableView: self.exerciseTableView didSelectRowAtIndexPath: path];
    }
}

@end


















































