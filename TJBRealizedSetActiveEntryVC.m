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
@property (nonatomic, strong) NSDate *setBeginDate;
@property (nonatomic, strong) NSDate *setEndDate;
@property (nonatomic, strong) NSNumber *weight;
@property (nonatomic, strong) NSNumber *reps;
@property (nonatomic, strong) TJBExercise *exercise;

@property (nonatomic, strong) UIView *whiteoutView;

// timer and target rest time

@property (weak, nonatomic) IBOutlet UILabel *timerLabel;
@property (weak, nonatomic) IBOutlet UIButton *targetRestButton;

@property (nonatomic, strong) NSDate *lastPrimaryTimerUpdateDate;
@property (nonatomic, strong) NSDate *lastSecondaryTimerUpdateDate;

@property (nonatomic, strong) NSNumber *targetRestTime;

// navigation bar
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
// need to keep it around to update the title as exercises are selected
// should this be a weak property?
@property (nonatomic, weak) UINavigationItem *navItem;

// IBAction

- (IBAction)didPressTargetRestButton:(id)sender;

// for restoration

@property (nonatomic, strong) NSNumber *restoredSecondaryTimerValue;

// if user is in the middle of making selections when app enters the background state, this block will execute aftert the view loads and then be destroyed so that it is not called again when the view again loads

@property (copy) void (^restorationBlock)(void);

@end

@implementation TJBRealizedSetActiveEntryVC

#pragma mark - Instantiation

- (instancetype)init{
    
    self = [super init];
    
    [self configureStopwatchWithFreshValues];
    
    [self setRestorationProperties];
    
    return self;
    
}

- (instancetype)initRestoredVC{
    
    self = [super init];
    
    [self setRestorationProperties];
    
    return self;

}

- (void)setRestorationProperties{
    
    // for restoration
    
    self.restorationIdentifier = @"TJBRealizedSetActiveEntryVC";
    self.restorationClass = [TJBRealizedSetActiveEntryVC class];
    
}

#pragma mark - View Life Cycle


- (void)viewDidAppear:(BOOL)animated{
    
    if (self.restorationBlock){
        
        self.restorationBlock();
        
        self.restorationBlock = nil;
        
    }
    
}

- (void)viewDidLoad{
    
    _setCompletedButtonPressed = NO;
    
    _whiteoutActive = NO;
    
    [self configureNavigationBar];
    
    [self addAppropriateStopwatchObservers];
    
    [self fetchCoreDataAndConfigureTableView];
    
    [self addBackgroundImage];
    
    [self viewAesthetics];
    
}



- (void)viewAesthetics{
    
    self.exerciseTableView.layer.opacity = .85;
    
    NSArray *buttons = @[self.beginNextSetButton,
                         self.addNewExerciseButton,
                         self.targetRestButton];
    
    [[TJBAestheticsController singleton] configureButtonsInArray: buttons
                                                     withOpacity: .85];
    
    NSArray *type2Labels = @[self.timerLabel];
    
    [TJBAestheticsController configureLabelsWithType2Format: type2Labels
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
    
    // nav bar text appearance
    
    [self.navigationBar setTitleTextAttributes: @{NSFontAttributeName: [UIFont boldSystemFontOfSize: 25.0]}];
    
}

- (void)fetchCoreDataAndConfigureTableView{
    
    // table view reusable cell registration
    // notification center registration as well
    
    [self.exerciseTableView registerClass: [UITableViewCell class]
                   forCellReuseIdentifier: @"basicCell"];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(exerciseDataChanged)
                                                 name: ExerciseDataChanged
                                               object: nil];
    
    // NSFetchedResultsController
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName: @"Exercise"];
    
    NSPredicate *noPlaceholderExercisesPredicate = [NSPredicate predicateWithFormat: @"category.name != %@",
                                                    @"Placeholder"];
    
    request.predicate = noPlaceholderExercisesPredicate;
    
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
    
    if (![self.fetchedResultsController performFetch: &error]){
        
        NSLog(@"Failed to initialize fetchedResultsController: %@\n%@", [error localizedDescription], [error userInfo]);
        
        abort();
        
    }
    
}

- (void)exerciseDataChanged{
    
    NSError *error = nil;
    
    [self.fetchedResultsController performFetch: &error];
    
    [self.exerciseTableView reloadData];
    
}

- (void)addAppropriateStopwatchObservers{
    
    [[TJBStopwatch singleton] addPrimaryStopwatchObserver: self
                                           withTimerLabel: self.timerLabel];
    
    self.timerLabel.text = [[TJBStopwatch singleton] primaryTimeElapsedAsString];
    
}

- (void)configureStopwatchWithFreshValues{
    
    [[TJBStopwatch singleton] setPrimaryStopWatchToTimeInSeconds: 0
                                         withForwardIncrementing: YES
                                                  lastUpdateDate: nil];
    
}

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
    
    cell.textLabel.font = [UIFont systemFontOfSize: 20.0];
    
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
    
    label.font = [UIFont systemFontOfSize: 20.0];
    
    return label;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 40;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 40;
    
}

#pragma mark - Button Actions

- (IBAction)didPressTargetRestButton:(id)sender {
    
    //// present the number selection scene.  Store the selected value as a property and display it.  This value will be used in conjuction with the timer in order to send notifications to the user when it is almost time to get into set
    
    __weak TJBRealizedSetActiveEntryVC *weakSelf = self;
    
    void (^cancelBlock)(void) = ^{
        
        [weakSelf dismissViewControllerAnimated: NO
                                     completion: nil];
        
    };
    
    void (^numberSelectedBlock)(NSNumber *) = ^(NSNumber *selectedNumber){
        
        weakSelf.targetRestTime = selectedNumber;
        
        NSString *targetRestString = [[TJBStopwatch singleton] minutesAndSecondsStringFromNumberOfSeconds: [selectedNumber intValue]];
        
        [weakSelf.targetRestButton setTitle: targetRestString
                               forState: UIControlStateNormal];
        
        [weakSelf dismissViewControllerAnimated: NO
                                     completion: nil];
        
    };
    
    [self presentNumberSelectionSceneWithNumberType: RestType
                                     numberMultiple: [NSNumber numberWithDouble: 5.0]
                                        numberLimit: nil
                                              title: @"Select Target Rest"
                                        cancelBlock: cancelBlock
                                numberSelectedBlock: numberSelectedBlock
                                           animated: NO
                               modalTransitionStyle: UIModalTransitionStyleCoverVertical];
    
}

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
            weakSelf.setBeginDate = [NSDate dateWithTimeIntervalSinceNow: [number intValue]];
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
        
        // if the app was launched with state restoration and the user entered the background state from the InSetVC, adjustedSecondaryTimerTime will exist
        // if it does exist, that time should be used.  The object should be destroyed after it is used so that it is not used again
        
        TJBInSetVC *vc;
        
        if (self.restoredSecondaryTimerValue){
            
            vc = [[TJBInSetVC alloc] initWithTimeDelay: [self.restoredSecondaryTimerValue intValue] * -1
                             DidPressSetCompletedBlock: block
                                          exerciseName: self.exercise.name
                                   lastTimerUpdateDate: self.lastSecondaryTimerUpdateDate
                                      masterController: self];
            
            self.restoredSecondaryTimerValue = nil;
            
        } else{
            
            vc = [[TJBInSetVC alloc] initWithTimeDelay: [self.timeDelay intValue]
                             DidPressSetCompletedBlock: block
                                          exerciseName: self.exercise.name
                                   lastTimerUpdateDate: nil
                                      masterController: self];
        }
        
        [self presentViewController: vc
                           animated: NO
                         completion: nil];
    }
    else if (!self.timeLag)
    {
        NumberSelectedBlock numberSelectedBlock = ^(NSNumber *number){
            
            weakSelf.timeLag = number;
            
            weakSelf.setEndDate = [NSDate dateWithTimeIntervalSinceNow: [number intValue] * -1];
            
            [[TJBStopwatch singleton] setPrimaryStopWatchToTimeInSeconds: [number intValue] * -1
                                                 withForwardIncrementing: YES
                                                          lastUpdateDate: nil];
            
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

- (void)removeWhiteoutView{
    [self.whiteoutView removeFromSuperview];
    _whiteoutActive = NO;
}

- (void)presentNumberSelectionSceneWithNumberType:(NumberType)numberType numberMultiple:(NSNumber *)numberMultiple numberLimit:(NSNumber *)numberLimit title:(NSString *)title cancelBlock:(void(^)(void))cancelBlock numberSelectedBlock:(void(^)(NSNumber *))numberSelectedBlock animated:(BOOL)animated modalTransitionStyle:(UIModalTransitionStyle)transitionStyle{

    TJBNumberSelectionVC *numberSelectionVC = [[TJBNumberSelectionVC alloc] initWithNumberTypeIdentifier: numberType
                                                                                          numberMultiple: numberMultiple
                                                                                             numberLimit: numberLimit
                                                                                                   title: title
                                                                                             cancelBlock: cancelBlock
                                                                                     numberSelectedBlock: numberSelectedBlock];

    
    numberSelectionVC.modalTransitionStyle = transitionStyle;
    
    [self presentViewController: numberSelectionVC
                       animated: NO
                     completion: nil];
    
}

- (void)addRealizedSetToCoreData{
    BOOL postMortem = FALSE;
    NSManagedObjectContext *moc = [[CoreDataController singleton] moc];
    TJBRealizedSet *realizedSet = [NSEntityDescription insertNewObjectForEntityForName: @"RealizedSet"
                                                                inManagedObjectContext: moc];
    
    realizedSet.beginDate = self.setBeginDate;
    realizedSet.endDate = self.setEndDate;
    realizedSet.postMortem = postMortem;
    realizedSet.weight = [self.weight floatValue];
    realizedSet.reps = [self.reps floatValue];
    realizedSet.exercise = self.exercise;
    
    [[CoreDataController singleton] saveContext];
    
    [self.personalRecordVC newSetSubmitted];
}

#pragma mark - <NewExerciseCreationDelegate>

- (void)didCreateNewExercise:(TJBExercise *)exercise{
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

- (void)presentSubmittedSetSummary{
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
    
    UIAlertAction *action1 = [UIAlertAction actionWithTitle: @"Discard"
                                                      style: UIAlertActionStyleDefault
                                                    handler: action1Block];
    UIAlertAction *action2 = [UIAlertAction actionWithTitle: @"Save"
                                                      style: UIAlertActionStyleDefault
                                                    handler: action2Block];
    
    [alert addAction: action1];
    [alert addAction: action2];
    
    [self presentViewController: alert
                       animated: YES
                     completion: nil];
}

- (void)setRealizedSetParametersToNil{
    self.timeDelay = nil;
    _setCompletedButtonPressed = NO;
    self.timeLag = nil;
    self.weight = nil;
    self.reps = nil;
}

- (void)confirmSubmission{
    
    [self addRealizedSetToCoreData];
    
    [self setRealizedSetParametersToNil];
}

#pragma mark - <UIViewControllerRestoration>

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder{
    
    TJBRealizedSetActiveEntryVC *vc = [[TJBRealizedSetActiveEntryVC alloc] initRestoredVC];
    
    return vc;
    
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder{
    
    [super encodeRestorableStateWithCoder: coder];
    
    // timer
    
    int primaryTime = [[[TJBStopwatch singleton] primaryTimeElapsedInSeconds] floatValue];
    
    [coder encodeFloat: primaryTime
              forKey: @"primaryTime"];
    
    [coder encodeObject: self.lastPrimaryTimerUpdateDate
                 forKey: @"lastPrimaryTimerUpdateDate"];
    
    float secondaryTime = [[[TJBStopwatch singleton] secondaryTimeElapsedInSeconds] floatValue];
    
    [coder encodeFloat: secondaryTime
              forKey: @"secondaryTime"];
    
    [coder encodeObject: self.lastSecondaryTimerUpdateDate
                 forKey: @"lastSecondaryTimerUpdateDate"];
    
    // table view
    
    CGPoint scrollPosition = self.exerciseTableView.contentOffset;
    int y = scrollPosition.y;
    [coder encodeFloat: y
                forKey: @"scrollYPosition"];
    
    NSIndexPath *path = self.exerciseTableView.indexPathForSelectedRow;
    if (path){
        
        [coder encodeObject: path
                     forKey: @"path"];
        
    }
    
    // realized set user selections
    
    [coder encodeBool: _whiteoutActive
               forKey: @"whiteoutActive"];
    
    if (self.timeDelay){
        [coder encodeObject: self.timeDelay
                     forKey: @"timeDelay"];
        [coder encodeObject: self.setBeginDate
                     forKey: @"setBeginDate"];
    }
    
    [coder encodeBool: _setCompletedButtonPressed
               forKey: @"setCompletedButtonPressed"];
    
    if (self.timeLag){
        [coder encodeObject: self.timeLag
                     forKey: @"timeLag"];
        [coder encodeObject: self.setEndDate
                     forKey: @"setEndDate"];
    }
    
    if (self.weight){
        [coder encodeObject: self.weight
                     forKey: @"weight"];
    }
    
    if (self.reps){
        [coder encodeObject: self.reps
                     forKey: @"reps"];
    }
    
}


- (void)decodeRestorableStateWithCoder:(NSCoder *)coder{
    
    [super decodeRestorableStateWithCoder: coder];
    
    // primary timer
    
    int primaryTime = [coder decodeFloatForKey: @"primaryTime"];
    
    NSDate *lastPrimaryTimerUpdateDate = [coder decodeObjectForKey: @"lastPrimaryTimerUpdateDate"];
    self.lastPrimaryTimerUpdateDate = lastPrimaryTimerUpdateDate;
    
    [[TJBStopwatch singleton] setPrimaryStopWatchToTimeInSeconds: primaryTime
                                         withForwardIncrementing: YES
                                                  lastUpdateDate: lastPrimaryTimerUpdateDate];
    
    self.timerLabel.text = [[TJBStopwatch singleton] minutesAndSecondsStringFromNumberOfSeconds: primaryTime];
    
    // table view
    
    float y = [coder decodeDoubleForKey: @"scrollYPosition"];
    self.exerciseTableView.contentOffset = CGPointMake(0, y);
    
    NSIndexPath *path = [coder decodeObjectForKey: @"path"];
    if (path){
        
        // artificially make table view selections for state restoration
        
        [self.exerciseTableView selectRowAtIndexPath: path
                                            animated: NO
                                      scrollPosition: UITableViewScrollPositionNone];
        [self tableView: self.exerciseTableView didSelectRowAtIndexPath: path];
        
        // use the saved path to restore the 'exercise' property
        
        TJBExercise *exercise = [self.fetchedResultsController objectAtIndexPath: path];
        self.exercise = exercise;
    }
    
    // realized set user selections
    
    _whiteoutActive = [coder decodeObjectForKey: @"whiteoutActive"];
    self.timeDelay = [coder decodeObjectForKey: @"timeDelay"];
    self.setBeginDate = [coder decodeObjectForKey: @"setBeginDate"];
    _setCompletedButtonPressed = [coder decodeBoolForKey: @"setCompletedButtonPressed"];
    self.timeLag = [coder decodeObjectForKey: @"timeLag"];
    self.setEndDate = [coder decodeObjectForKey: @"setEndDate"];
    self.weight = [coder decodeObjectForKey: @"weight"];
    self.reps = [coder decodeObjectForKey: @"reps"];
    
    // store the time the secondary timer should start at if app entered background state from InSetVC

    if (self.timeDelay && _setCompletedButtonPressed == NO){
        
        float previousValueOfSecondaryTimer = [coder decodeFloatForKey: @"secondaryTime"];
        
        self.restoredSecondaryTimerValue = [NSNumber numberWithFloat: previousValueOfSecondaryTimer];
        
        self.lastSecondaryTimerUpdateDate = [coder decodeObjectForKey: @"lastSecondaryTimerUpdateDate"];
        
    }
    
    // kicks off the selection process if user ended mid-selection
    
    if (self.timeDelay){
        
        __weak TJBRealizedSetActiveEntryVC *weakSelf = self;
        
        void (^restorationBlock)(void) = ^{
            
            [weakSelf didPressBeginNextSet: nil];
            
        };
        
        self.restorationBlock = restorationBlock;
        
    }
    
}


#pragma mark - <TJBStopwatchObserver>

- (void)primaryTimerDidUpdateWithUpdateDate:(NSDate *)date{
    
    //// store the passed in date
    
    self.lastPrimaryTimerUpdateDate = date;
    
}

- (void)secondaryTimerDidUpdateWithUpdateDate:(NSDate *)date{
    
    self.lastSecondaryTimerUpdateDate = date;
    
}


@end


















































