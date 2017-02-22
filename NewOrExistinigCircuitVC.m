//
//  NewOrExistinigCircuitVC.m
//  Beast
//
//  Created by Trevor Beasty on 12/26/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import "NewOrExistinigCircuitVC.h"

// core data

#import "CoreDataController.h"

// VC's to present

#import "TJBCircuitDesignVC.h"
#import "TJBActiveRoutineGuidanceVC.h"
#import "TJBWorkoutNavigationHub.h"
#import "TJBCircuitReferenceContainerVC.h"

// views

#import "TJBCircuitReferenceVC.h"

// aesthetics

#import "TJBAestheticsController.h"

// table view cell

#import "TJBStructureTableViewCell.h"
#import "TJBWorkoutLogTitleCell.h"
#import "TJBNoDataCell.h"

// date control

#import "TJBSchemeSelectionDateComp.h"


@interface NewOrExistinigCircuitVC () <NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource, UIViewControllerRestoration>

{
    // user selection flow
    
    BOOL _inPreviewMode;
    
}

// IBOutlet

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sortBySegmentedControl;
@property (weak, nonatomic) IBOutlet UIButton *launchButton;
@property (weak, nonatomic) IBOutlet UIButton *previousMarkButton;
@property (weak, nonatomic) IBOutlet UIView *mainContainer;
@property (weak, nonatomic) IBOutlet UILabel *yearLabel;
@property (weak, nonatomic) IBOutlet UIButton *leftArrowButton;
@property (weak, nonatomic) IBOutlet UIButton *rightArrowButton;
@property (weak, nonatomic) IBOutlet UIScrollView *dateControlScrollView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UILabel *myRoutinesLabel;


// IBAction

- (IBAction)didPressLaunchButton:(id)sender;
- (IBAction)didPressLeftArrow:(id)sender;
- (IBAction)didPressRightArrow:(id)sender;
- (IBAction)didPressBackButton:(id)sender;

//// core data

@property (nonatomic, strong) NSFetchedResultsController *frc;

// this is the array that feeds the table view. Due to algorithmic considerations, the sortedContent is such that the 0th array is December and the 11th array is January
@property (nonatomic, strong) NSMutableArray <NSMutableArray <TJBChainTemplate *> *> *sortedContent;

// selection

@property (nonatomic, strong) TJBChainTemplate *selectedChainTemplate;
@property (nonatomic, strong) NSIndexPath *lastSelectedIndexPath;

// date control

@property (nonatomic, strong) UIStackView *dateStackView;
@property (nonatomic, strong) NSMutableArray <TJBSchemeSelectionDateComp *> *dateControlObjects;

// state

@property (nonatomic, strong) NSDate *activeDate;
@property (nonatomic, strong) NSNumber *selectedDateObjectIndex;



@end

@implementation NewOrExistinigCircuitVC

#pragma mark - Instantiation

- (instancetype)init{
    
    self = [super init];
    
    // state
    
    self.activeDate = [NSDate date];
    
    // for restoration
    
    self.restorationIdentifier = @"TJBNewOrExistingCircuit";
    self.restorationClass = [NewOrExistinigCircuitVC class];
    
    //
    
    return self;
}

- (void)initializeActiveVariables{
    
    //// configure state variables for fresh state
    
    _inPreviewMode = NO;
    
}

#pragma mark - View Cycle

- (void)viewWillAppear:(BOOL)animated{
    
    [self configureSelectionAsNil];
    
}

- (void)viewDidLoad{
    
    // must sort content first so that the date control can easily know which months have content
    
    [self configureTableView];
    
    [self configureDateControlsAndSelectToday: YES];
    
    [self viewAesthetics];
    
    [self configureSegmentedControl];
    
    [self toggleButtonsToOffState];
    
    [self fetchCoreData];
    
    [self drawCircles];
    
    [self configureNotifications];
    
}

- (void)configureNotifications{
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(fetchCoreData)
                                                 name: NSManagedObjectContextDidSaveNotification
                                               object: [[CoreDataController singleton] moc]];
    
    
}

- (void)clearTransitoryDateControlObjects{
    
    //// must clear the children view controller array as well as remove the stack view from the scroll view
    
    if (self.dateStackView){
        
        for (TJBSchemeSelectionDateComp *vc in self.dateControlObjects){
            
            [vc willMoveToParentViewController: nil];
            [vc removeFromParentViewController];
            
        }
        
        [self.dateStackView removeFromSuperview];
        self.dateStackView = nil;
        
    }
    
    self.dateControlObjects = [[NSMutableArray alloc] init];
    
}

- (void)drawCircles{
    
    //// this would ideally be called when creating the date objects, but I am getting strange behavior when I try to sort chainTemplates before configuring the date controls
    
    for (int i = 0; i < 12; i++){
        
        int reverseIndex = 11 - i;
        BOOL recordExistsForIterativeMonth = self.sortedContent[reverseIndex].count > 0;
        
        if (recordExistsForIterativeMonth){
            
            [self.dateControlObjects[i] drawCircle];
            
        } else{
            
            [self.dateControlObjects[i] deleteCircle];
            
        }
        
    }
    
}


- (void)configureDateControlsAndSelectToday:(BOOL)shouldSelectToday{
    
    //// configures the date controls according to the day stored in firstDayOfDateControlMonth.  Must be sure to first clear existing date control objects if they exist
    
    [self clearTransitoryDateControlObjects];
    
    // layout views so that the frame property is accurate
    
    [self.view layoutIfNeeded];
    
    NSDate *activeDate = self.activeDate;
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"YYYY";
    self.yearLabel.text = [df stringFromDate: activeDate];
    
    //// stack view and child VC's
    
    // stack view dimensions.  Need to know number of days in month and define widths of contained buttons
    
    const CGFloat buttonWidth = 60.0;
    const CGFloat buttonSpacing = 0.0;
    const CGFloat buttonHeight = self.dateControlScrollView.frame.size.height;
    
    const CGFloat stackViewWidth = buttonWidth * 12 + 11 * buttonSpacing;
    
    CGRect stackViewRect = CGRectMake(0, 0, stackViewWidth, buttonHeight);
    
    // create the stack view with the proper dimensions and also set the content size of the scroll view
    
    UIStackView *stackView = [[UIStackView alloc] initWithFrame: stackViewRect];
    self.dateStackView = stackView;
    
    self.dateControlScrollView.contentSize = stackViewRect.size;
    
    [self.dateControlScrollView addSubview: stackView];
    
    // configure the stack view's layout properties
    
    stackView.alignment = UIStackViewAlignmentFill;
    stackView.distribution = UIStackViewDistributionFillEqually;
    stackView.spacing = buttonSpacing;
    
    // give the stack view it's content.  All items preceding the for loop are used in the for loop
    
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier: NSCalendarIdentifierGregorian];
    NSDateComponents *dateComps = [calendar components: (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
                                              fromDate: activeDate];
    [dateComps setDay: 1];
    
    NSDate *iterativeDate;
    
    CGSize dateControlSize = CGSizeMake(buttonWidth, buttonHeight);
    
    NSDate *today = [NSDate date];
    
    for (int i = 0; i < 12; i++){
        
        // configure the month
        
        [dateComps setMonth: i + 1];
        iterativeDate = [calendar dateFromComponents: dateComps];
        
        df.dateFormat = @"MMM";
        NSString *monthString = [df stringFromDate: iterativeDate];
        
        // create the child vc - exactly what configuration the vc receives is dependent upon the iterative date
        
        NSComparisonResult todayMonthCompare = [calendar compareDate: iterativeDate
                                                         toDate: today
                                              toUnitGranularity: NSCalendarUnitMonth];
        
        BOOL iterativeMonthGreaterThanCurrentMonth = todayMonthCompare == NSOrderedDescending;
        
        BOOL isTheActiveMonth = NO;
        
        if (shouldSelectToday){
            
            isTheActiveMonth = todayMonthCompare == NSOrderedSame;
            
            if (isTheActiveMonth){
                
                self.selectedDateObjectIndex = [NSNumber numberWithInt: i];
                isTheActiveMonth = YES;
                
            }
            
        }
        
        TJBSchemeSelectionDateComp *dateControlObject = [[TJBSchemeSelectionDateComp alloc] initWithMonthString: monthString
                                                                                           representedDate: iterativeDate
                                                                                                     index: [NSNumber numberWithInt: i]
                                                                                                 isEnabled: !iterativeMonthGreaterThanCurrentMonth
                                                                                                      isCircled: NO
                                                                                     hasSelectedAppearance: isTheActiveMonth
                                                                                                      size: dateControlSize
                                                                                          masterController: self];
        
        [self.dateControlObjects addObject: dateControlObject];
        
        [self addChildViewController: dateControlObject];
        
        [stackView addArrangedSubview: dateControlObject.view];
        
        [dateControlObject didMoveToParentViewController: self];
        
    }
    
}

- (void)configureSegmentedControl{
    
    //// configure action method for segmented control
    
    [self.sortBySegmentedControl addTarget: self
                                    action: @selector(segmentedControlValueChanged)
                          forControlEvents: UIControlEventValueChanged];
    
}


- (void)viewAesthetics{
    
    // filter
    
    self.sortBySegmentedControl.tintColor = [[TJBAestheticsController singleton] blueButtonColor];
    
    // table view
    
    self.tableView.backgroundColor = [[TJBAestheticsController singleton] yellowNotebookColor];
    
    // buttons
    
    NSArray *buttons = @[self.launchButton,
                         self.previousMarkButton];
    
    for (UIButton *button in buttons){
        
        UIColor *color = [[TJBAestheticsController singleton] blueButtonColor];
        [button setBackgroundColor: color];
        [button setTitleColor: [UIColor whiteColor]
                     forState: UIControlStateNormal];
        button.titleLabel.font = [UIFont boldSystemFontOfSize: 20.0];
        
    }
    
    // container view shadow
    
    UIView *shadowView = self.mainContainer;
    shadowView.backgroundColor = [UIColor clearColor];
    shadowView.clipsToBounds = NO;
    
    CALayer *shadowLayer = shadowView.layer;
    shadowLayer.masksToBounds = NO;
    shadowLayer.shadowColor = [UIColor darkGrayColor].CGColor;
    shadowLayer.shadowOffset = CGSizeMake(0.0, 3.0);
    shadowLayer.shadowOpacity = 1.0;
    shadowLayer.shadowRadius = 3.0;
    
    //// date controls
    
    // year label
    
    NSArray *titleLabels = @[self.yearLabel, self.myRoutinesLabel];
    for (UILabel *label in titleLabels){
        
        label.backgroundColor = [UIColor darkGrayColor];
        label.textColor = [UIColor whiteColor];
        
    }
    
    self.yearLabel.font = [UIFont boldSystemFontOfSize: 15.0];
    self.myRoutinesLabel.font = [UIFont boldSystemFontOfSize: 20.0];
    
    // arrows and other bar buttons
    
    NSArray *arrows = @[self.rightArrowButton, self.leftArrowButton];
    for (UIButton *b in arrows){
        
        b.backgroundColor = [UIColor darkGrayColor];
        [b setTitleColor: [UIColor whiteColor]
                forState: UIControlStateNormal];
        [b.titleLabel setFont: [UIFont systemFontOfSize: 40.0]];
        
    }
    
    NSArray *barButtons = @[self.backButton];
    for (UIButton *button in barButtons){
        
        button.backgroundColor = [UIColor darkGrayColor];
        [button setTitleColor: [[TJBAestheticsController singleton] blueButtonColor]
                              forState: UIControlStateNormal];
        button.titleLabel.font = [UIFont boldSystemFontOfSize: 15.0];
        
    }
    

    
}


- (void)configureTableView{
    
    // table view configuration
    
    UINib *nib = [UINib nibWithNibName: @"TJBStructureTableViewCell"
                                bundle: nil];
    
    [self.tableView registerNib: nib
         forCellReuseIdentifier: @"TJBStructureTableViewCell"];
    
    UINib *nib2 = [UINib nibWithNibName: @"TJBWorkoutLogTitleCell"
                                 bundle: nil];
    
    [self.tableView registerNib: nib2
         forCellReuseIdentifier: @"TJBWorkoutLogTitleCell"];
    
    UINib *nib3 = [UINib nibWithNibName: @"TJBNoDataCell"
                                 bundle: nil];
    
    [self.tableView registerNib: nib3
         forCellReuseIdentifier: @"TJBNoDataCell"];
    
}

- (void)fetchCoreData{
    
    // NSFetchedResultsController
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName: @"ChainTemplate"];
    
    NSSortDescriptor *nameSort = [NSSortDescriptor sortDescriptorWithKey: @"name"
                                                               ascending: YES];
    
    [request setSortDescriptors: @[nameSort]];
    
    NSManagedObjectContext *moc = [[CoreDataController singleton] moc];
    
    NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest: request
                                                                          managedObjectContext: moc
                                                                            sectionNameKeyPath: @"name"
                                                                                     cacheName: nil];
    frc.delegate = self;
    
    self.frc = frc;
    
    NSError *error = nil;
    
    if (![self.frc performFetch: &error])
    {
        NSLog(@"Failed to initialize fetchedResultsController: %@\n%@", [error localizedDescription], [error userInfo]);
        abort();
    }
    
    // sorted content
    
    [self configureSortedContentForActiveYear];
    
    [self.tableView reloadData];
    
}

- (NSMutableArray<TJBChainTemplate *> *)sortArrayByDateLastExecuted:(NSMutableArray<TJBChainTemplate *> *)array{
    
    // remove all chain templates that don't have realized sets in the active year
    
    NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier: NSCalendarIdentifierGregorian];
    
    for (TJBChainTemplate *chainTemplate in array){
        
        NSOrderedSet *realizedChains = chainTemplate.realizedChains;
        
        BOOL hasNoRealizedChains = [realizedChains count] == 0;
        BOOL isInActiveYear = NO;
        
        for (int i = 0; i < realizedChains.count; i++){
            
            TJBRealizedChain *realizedChain = realizedChains[i];
            
            BOOL iterativeRealizedChainInActiveYear = [calendar isDate: realizedChain.dateCreated
                                                           equalToDate: self.activeDate
                                                     toUnitGranularity: NSCalendarUnitYear];
            
            if (iterativeRealizedChainInActiveYear){
                isInActiveYear = YES;
            }
            
        }
        
        if (hasNoRealizedChains || !isInActiveYear){
            
            [indexSet addIndex: [array indexOfObject: chainTemplate]];
            
        }
        
    }
    
    [array removeObjectsAtIndexes: indexSet];
    
    // now, only chain templates with realized chains in the active year remain.  Use an NSComparator to order the chain correctly
    
    [array sortUsingComparator: ^(TJBChainTemplate *chain1, TJBChainTemplate *chain2){
        
        NSDate *date1 = [self largestRealizeChainDateInActiveYearForChainTemplate: chain1];
        NSDate *date2 = [self largestRealizeChainDateInActiveYearForChainTemplate: chain2];
        
        int dateDifference = [date1 timeIntervalSinceDate: date2];
        BOOL date1IsLater = dateDifference > 0;
        
        if (date1IsLater){
            
            return NSOrderedAscending;
            
        } else{
            
            return NSOrderedDescending;
            
        }
        
    }];
    
    return array;
    
}

- (NSMutableArray<TJBChainTemplate *> *)sortArrayByDateCreated:(NSMutableArray<TJBChainTemplate *> *)array{
    
    // remove all chain templates that don't have realized sets in the active year
    
    NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier: NSCalendarIdentifierGregorian];
    
    for (TJBChainTemplate *chainTemplate in array){

        BOOL isInActiveYear = [calendar isDate: chainTemplate.dateCreated
                                   equalToDate: self.activeDate
                             toUnitGranularity: NSCalendarUnitYear];
        
        if (!isInActiveYear){
            
            [indexSet addIndex: [array indexOfObject: chainTemplate]];
            
        }
        
    }
    
    [array removeObjectsAtIndexes: indexSet];
    
    // now, only chain templates with realized chains in the active year remain.  Use an NSComparator to order the chain correctly
    
    [array sortUsingComparator: ^(TJBChainTemplate *chain1, TJBChainTemplate *chain2){
        
        NSDate *date1 = chain1.dateCreated;
        NSDate *date2 = chain2.dateCreated;
        
        int dateDifference = [date1 timeIntervalSinceDate: date2];
        BOOL date1IsLater = dateDifference > 0;
        
        if (date1IsLater){
            
            return NSOrderedAscending;
            
        } else{
            
            return NSOrderedDescending;
            
        }
        
    }];
    
    return array;
    
}

- (NSMutableArray<NSMutableArray<TJBChainTemplate *> *> *)bucketByMonthAccordingToDateLastExecuted:(NSMutableArray<TJBChainTemplate *> *)array{
    
    NSMutableArray<NSMutableArray<TJBChainTemplate *> *> *returnArray = [[NSMutableArray alloc] init];
    
    TJBChainTemplate *iterativeChainTemplate;
    TJBRealizedChain *iterativeRealizedChain;
    
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier: NSCalendarIdentifierGregorian];
    NSDateComponents *iterativeDateComps = [calendar components: (NSCalendarUnitYear | NSCalendarUnitMonth)
                                                       fromDate: self.activeDate];
    
    int arrayTracker = 0;
    
    for (int i = 12 ; i > 0; i--){
        
        [iterativeDateComps setMonth: i];
        
        NSMutableArray *monthArray = [[NSMutableArray alloc] init];
        [returnArray addObject: monthArray];
        
        for (int j = arrayTracker; j < array.count; j++){
            
            iterativeChainTemplate = array[j];
            iterativeRealizedChain = [self largestRealizeChainInActiveYearAndMonthForReferenceDate: [calendar dateFromComponents: iterativeDateComps]
                                                                                         chainTemplate: iterativeChainTemplate];
            
            // nil will be returned if there are no matches for the relevant month and year.  If there is a match, add the chain to the return array
            // if there is no match, then all subsequent arrays will not contain any matches because the dates are in decreasing order, so break the for loop and continue to the next month
            
            if (iterativeRealizedChain){
                
                [returnArray[12-i] addObject: iterativeChainTemplate];
                
            } else{
                
                arrayTracker = j;
                break;
                
            }
            
        }
        
    }
    
    return returnArray;
    
}

- (NSMutableArray<NSMutableArray<TJBChainTemplate *> *> *)bucketByMonthAccordingToDateCreated:(NSMutableArray<TJBChainTemplate *> *)array{
    
    NSMutableArray<NSMutableArray<TJBChainTemplate *> *> *returnArray = [[NSMutableArray alloc] init];
    
    TJBChainTemplate *iterativeChainTemplate;
    
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier: NSCalendarIdentifierGregorian];
    NSDateComponents *iterativeDateComps = [calendar components: (NSCalendarUnitYear | NSCalendarUnitMonth)
                                                       fromDate: self.activeDate];
    
    NSDate *referenceDate;
    
    int arrayTracker = 0;
    
    for (int i = 12 ; i > 0; i--){
        
        [iterativeDateComps setMonth: i];
        referenceDate = [calendar dateFromComponents: iterativeDateComps];
        
        NSMutableArray *monthArray = [[NSMutableArray alloc] init];
        [returnArray addObject: monthArray];
        
        for (int j = arrayTracker; j < array.count; j++){
            
            iterativeChainTemplate = array[j];
            
            BOOL iterativeChainInRefYear = [calendar isDate: iterativeChainTemplate.dateCreated
                                                equalToDate: referenceDate
                                          toUnitGranularity: NSCalendarUnitYear];
            
            BOOL iterativeChainInRefMonth = [calendar isDate: iterativeChainTemplate.dateCreated
                                                 equalToDate: referenceDate
                                           toUnitGranularity: NSCalendarUnitMonth];
            
            BOOL dateCreatedMatchesMonthAndYear = iterativeChainInRefYear && iterativeChainInRefMonth;
            
            if (dateCreatedMatchesMonthAndYear){
                
                [returnArray[12-i] addObject: iterativeChainTemplate];
                
            } else{
                
                arrayTracker = j;
                break;
                
            }
            
        }
        
    }
    
    return returnArray;
    
}

- (NSDate *)largestRealizeChainDateInActiveYearForChainTemplate:(TJBChainTemplate *)chainTemplate{
    
    //// the goal is to get the largest date for the current year so that dates are correctly expressed.  This algorithm relies on the chain template's chains being in chronological order.  This method assumes their is a valid return value.
    
    NSOrderedSet<TJBRealizedChain *> *realizedChains = chainTemplate.realizedChains;
    NSInteger limit = realizedChains.count;
    
    NSDate *iterativeDate;
    NSDate *referenceDate = self.activeDate;
    
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier: NSCalendarIdentifierGregorian];
    
    for (int i = 0; i < limit; i++){
        
        NSInteger reverseOrder = (limit - 1) - i;
        TJBRealizedChain *iterativeChain = realizedChains[reverseOrder];
        iterativeDate = iterativeChain.dateCreated;
        
        BOOL iterativeChainInRefYear = [calendar isDate: iterativeDate
                                            equalToDate: referenceDate
                                      toUnitGranularity: NSCalendarUnitYear];
        
        if (iterativeChainInRefYear){
            
            return iterativeDate;
            
        }
        
    }
    
    abort();
    
}

- (TJBRealizedChain *)largestRealizeChainInActiveYearAndMonthForReferenceDate:(NSDate *)referenceDate chainTemplate:(TJBChainTemplate *)chainTemplate{
    
    //// the goal is to get the largest date for the current year so that dates are correctly expressed.  This algorithm relies on the chain template's chains being in chronological order.  This method assumes their is a valid return value.
    
    NSOrderedSet<TJBRealizedChain *> *realizedChains = chainTemplate.realizedChains;
    NSInteger limit = realizedChains.count;
    
    NSDate *iterativeDate;
    
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier: NSCalendarIdentifierGregorian];
    
    for (int i = 0; i < limit; i++){
        
        NSInteger reverseOrder = (limit - 1) - i;
        TJBRealizedChain *iterativeChain = realizedChains[reverseOrder];
        iterativeDate = iterativeChain.dateCreated;
        
        BOOL iterativeChainInRefYear = [calendar isDate: iterativeDate
                                            equalToDate: referenceDate
                                      toUnitGranularity: NSCalendarUnitYear];
        
        BOOL iterativeChainInRefMonth = [calendar isDate: iterativeDate
                                             equalToDate: referenceDate
                                       toUnitGranularity: NSCalendarUnitMonth];
        
        if (iterativeChainInRefYear && iterativeChainInRefMonth){
            
            return iterativeChain;
            
        }
        
    }
    
    return nil;
    
}


- (void)configureSortedContentForActiveYear{
    
    //// given the fetched results and current sorting selection, derive the sorted content (which will be used to populate the table view)
    
    self.sortedContent = nil;
    
    NSInteger sortSelection = self.sortBySegmentedControl.selectedSegmentIndex;
    BOOL sortByDateLastExecuted = sortSelection == 0;
    BOOL sortByDateCreated = sortSelection == 1;
    
    NSMutableArray<TJBChainTemplate *> *interimArray = [[NSMutableArray alloc] initWithArray: self.frc.fetchedObjects];
    
    if (sortByDateLastExecuted){
        
        NSMutableArray<TJBChainTemplate *> *sortedChains = [self sortArrayByDateLastExecuted: interimArray];
        
        self.sortedContent = [self bucketByMonthAccordingToDateLastExecuted: sortedChains];
        
    } else if (sortByDateCreated){
        
        NSMutableArray<TJBChainTemplate *> *sortedChains = [self sortArrayByDateCreated: interimArray];
        
        self.sortedContent = [self bucketByMonthAccordingToDateCreated: sortedChains];
        
    }
    
}

#pragma mark - Convenience

- (void)toggleButtonsToOnStateWithViewHistoryEnabled:(BOOL)viewHistoryEnabled{
    
    NSArray *buttons = @[self.launchButton];
    
    for (UIButton *b in buttons){
        
        b.enabled = YES;
        b.layer.opacity = 1.0;
        
    }
    
    if (viewHistoryEnabled){
        
        self.previousMarkButton.enabled = YES;
        self.previousMarkButton.layer.opacity = 1.0;
        
    }
    
}

- (void)toggleButtonsToOffState{
    
    NSArray *buttons = @[self.launchButton,
                         self.previousMarkButton];
    
    for (UIButton *b in buttons){
        
        b.enabled = NO;
        b.layer.opacity = .2;
        
    }
    
}


#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    int reversedIndex = 11 - [self.selectedDateObjectIndex intValue];
    
    NSInteger rowCount = self.sortedContent[reversedIndex].count;
    
    if (rowCount == 0){
        
        return 2;
        
    } else{
        
        return rowCount + 1;
        
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == 0){
        
        TJBWorkoutLogTitleCell *cell = [self.tableView dequeueReusableCellWithIdentifier: @"TJBWorkoutLogTitleCell"];
        
        NSString *primaryText;
        if (self.sortBySegmentedControl.selectedSegmentIndex == 0){
            primaryText = @"Routines by Date Last Executed";
        } else{
            primaryText = @"Routines by Date Created";
        }
        
        NSCalendar *calendar = [NSCalendar calendarWithIdentifier: NSCalendarIdentifierGregorian];
        NSDateComponents *dateComps = [calendar components: (NSCalendarUnitYear | NSCalendarUnitMonth)
                                                  fromDate: self.activeDate];
        [dateComps setMonth: [self.selectedDateObjectIndex intValue] + 1];
        NSDate *titleDate = [calendar dateFromComponents: dateComps];
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        df.dateFormat = @"MMMM, yyyy";
        NSString *secondaryText = [df stringFromDate: titleDate];
        
        cell.primaryLabel.text = primaryText;
        cell.secondaryLabel.text = secondaryText;
        
        cell.backgroundColor = [UIColor clearColor];
        
        return cell;
        
        
    } else{
        
        int reversedIndex = 11 - [self.selectedDateObjectIndex intValue];
        NSInteger chainCount = self.sortedContent[reversedIndex].count;
        
        if (chainCount == 0){
            
            TJBNoDataCell *cell = [self.tableView dequeueReusableCellWithIdentifier: @"TJBNoDataCell"];
            
            cell.mainLabel.text = @"No Routines";
            
            cell.backgroundColor = [UIColor clearColor];
            
            return cell;
            
        } else{
            
            BOOL isSelectedCell = NO;
            
            if (self.lastSelectedIndexPath){
                
                isSelectedCell = self.lastSelectedIndexPath.row == indexPath.row;
                
            }
            
            TJBStructureTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier: @"TJBStructureTableViewCell"];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.layer.borderColor = [[TJBAestheticsController singleton] blueButtonColor].CGColor;
            
            [cell clearExistingEntries];
            
            NSInteger adjustedRowIndex = indexPath.row - 1;
            
            TJBChainTemplate *chainTemplate = self.sortedContent[reversedIndex][adjustedRowIndex];
            
            NSInteger sortSelection = self.sortBySegmentedControl.selectedSegmentIndex;
            BOOL sortByDateLastExecuted = sortSelection == 0;
            BOOL sortByDateCreated = sortSelection == 1;
            
            NSDate *date;
            
            if (sortByDateLastExecuted){
                
                date = [self largestRealizeChainDateInActiveYearForChainTemplate: chainTemplate];
                
            } else if (sortByDateCreated){
                
                date = chainTemplate.dateCreated;
                
            }
            
            [cell configureWithChainTemplate: chainTemplate
                                        date: date
                                      number: [NSNumber numberWithInteger: indexPath.row]];
            
            // configure border width and background color according to whether or not the cell is selected
            
            if (isSelectedCell){
                
                cell.backgroundColor = [UIColor clearColor];
                cell.layer.borderWidth = 4.0;
                
            } else{
                
                cell.backgroundColor = [UIColor clearColor];
                cell.layer.borderWidth = 0.0;
                
            }
            
            return cell;
            
        }
        
    }
    
}

#pragma mark - <UITableViewDelegate>

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    
    int reversedIndex = 11 - [self.selectedDateObjectIndex intValue];
    NSInteger chainCount = self.sortedContent[reversedIndex].count;
    
    if (indexPath.row == 0 || chainCount == 0){
        
        return NO;
        
    } else{
        
        return YES;
        
    }
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //// change the background color of the selected chain template and change the control state of the buttons to activate them.  Store the selected chain and the index path of the selected row
    
    // deal with unhighlighting

    TJBStructureTableViewCell *lastSelectedCell = [tableView cellForRowAtIndexPath: self.lastSelectedIndexPath];
    
    lastSelectedCell.backgroundColor = [UIColor clearColor];
    lastSelectedCell.layer.borderWidth = 0.0;
    
    self.lastSelectedIndexPath = indexPath;
    
    // highlight the new cell
    
    int reversedIndex = 11 - [self.selectedDateObjectIndex intValue];
    
    TJBChainTemplate *chainTemplate = self.sortedContent[reversedIndex][indexPath.row - 1];
    
    BOOL realizationsExist = chainTemplate.realizedChains.count > 0;
    
    self.selectedChainTemplate = chainTemplate;
    
    // add blue border to selected cell
    
    TJBStructureTableViewCell *selectedCell = [tableView cellForRowAtIndexPath: indexPath];
    
    selectedCell.backgroundColor = [UIColor clearColor];
    
    selectedCell.layer.borderWidth = 4.0;
    
    [self toggleButtonsToOnStateWithViewHistoryEnabled: realizationsExist];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat titleHeight = 60.0;
    
    if (indexPath.row == 0){
        
        return titleHeight;
        
    } else{
        
        int reversedIndex = 11 - [self.selectedDateObjectIndex intValue];
        
        NSInteger chainCount = self.sortedContent[reversedIndex].count;
        
        if (chainCount == 0){
            
            [self.view layoutIfNeeded];
            
            return self.tableView.frame.size.height - titleHeight;
            
        } else{
            
            TJBChainTemplate *chainTemplate = self.sortedContent[reversedIndex][indexPath.row -1];
            
            return [TJBStructureTableViewCell suggestedCellHeightForChainTemplate: chainTemplate];
            
        }
        
    }
    
}


#pragma mark - Button Actions


- (IBAction)didPressBackButton:(id)sender{
    
    [self dismissViewControllerAnimated: NO
                             completion: nil];
    
}

- (IBAction)didPressRightNewButton:(id)sender{
    
    TJBCircuitDesignVC *vc = [[TJBCircuitDesignVC alloc] init];
    
    [self.presentingViewController presentViewController: vc
                                        animated: NO
                                      completion: nil];

    
}

- (void)segmentedControlValueChanged{
    
    [self configureSelectionAsNil];
    
    //// re-sort the content array based upon the new sorting preference
    
    [self configureSortedContentForActiveYear];
    [self.tableView reloadData];
    [self drawCircles];
    
    [self toggleButtonsToOffState];
    
    self.selectedChainTemplate = nil;
    
}

- (IBAction)didPressLaunchButton:(id)sender {
    
    if (self.selectedChainTemplate){
        
        TJBActiveRoutineGuidanceVC *vc1 = [[TJBActiveRoutineGuidanceVC alloc] initFreshRoutineWithChainTemplate: self.selectedChainTemplate];
        vc1.tabBarItem.title = @"Active";
        
        TJBWorkoutNavigationHub *vc3 = [[TJBWorkoutNavigationHub alloc] init];
        vc3.tabBarItem.title = @"Workout Log";
        
        TJBCircuitReferenceContainerVC *vc2 = [[TJBCircuitReferenceContainerVC alloc] initWithRealizedChain: vc1.realizedChain];
        vc2.tabBarItem.title = @"Progress";
        
        // tab bar
        
        UITabBarController *tbc = [[UITabBarController alloc] init];
        [tbc setViewControllers: @[vc1, vc2, vc3]];
        tbc.tabBar.translucent = NO;

        
        [self presentViewController: tbc
                           animated: NO
                         completion: nil];
        
    } else{
        
        NSLog(@"no chain template selected");
        
    }
    
    
    
}



- (IBAction)didPressModifyButton:(id)sender{
    
    
}

- (IBAction)didPressLeftArrow:(id)sender{
    
    [self incrementActiveYearAndConfigureDownhillObjectsWithIncrementDirectionForward: NO];
    
}

- (IBAction)didPressRightArrow:(id)sender{
    
    [self incrementActiveYearAndConfigureDownhillObjectsWithIncrementDirectionForward: YES];
    
}



- (void)configureSelectionAsNil{
    
    // get rid of the border on the last selected cell and change state variables for selection
    
    self.selectedChainTemplate = nil;
    [self toggleButtonsToOffState];
    
    TJBStructureTableViewCell *cell = [self.tableView cellForRowAtIndexPath: self.lastSelectedIndexPath];
    cell.layer.borderWidth = 0.0;
    cell.backgroundColor = [UIColor clearColor];
    self.lastSelectedIndexPath = nil;
    
}

- (void)incrementActiveYearAndConfigureDownhillObjectsWithIncrementDirectionForward:(BOOL)incrementDirectionForward{
    
    [self configureSelectionAsNil];
    
    //
    
    int yearDelta;
    
    if (incrementDirectionForward){
        yearDelta = 1;
    } else{
        yearDelta = -1;
    }
    
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier: NSCalendarIdentifierGregorian];
    NSDateComponents *dateComps = [calendar components: (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
                                              fromDate: self.activeDate];
    
    dateComps.year += yearDelta;
    self.activeDate = [calendar dateFromComponents: dateComps];
    
    [self configureDateControlsAndSelectToday: NO];
    [self configureSortedContentForActiveYear];
    [self drawCircles];
    [self.tableView reloadData];
    
    [self didSelectObjectWithIndex: self.selectedDateObjectIndex];
    
}

#pragma mark - <UIViewControllerRestoration>

// will want to eventually store table view scroll position

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder{
    
    NewOrExistinigCircuitVC *vc = [[NewOrExistinigCircuitVC alloc] init];
    
    return vc;
    
}

#pragma mark - <TJBSchemeSelectionDateCompDelegate>

- (void)didSelectObjectWithIndex:(NSNumber *)index{
    
    [self configureSelectionAsNil];
    
    if (self.selectedDateObjectIndex){
        
        [self.dateControlObjects[[self.selectedDateObjectIndex intValue]] configureAsNotSelected];
        
    }
    
    self.selectedDateObjectIndex = index;
    [self.tableView reloadData];
    
    [self.dateControlObjects[[index intValue]] configureAsSelected];
    
}



@end






















