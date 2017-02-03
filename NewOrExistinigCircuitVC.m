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
#import "TJBCircuitModeTBC.h"

// views

#import "TJBCircuitReferenceVC.h"

// aesthetics

#import "TJBAestheticsController.h"

// table view cell

#import "TJBStructureTableViewCell.h"

// date control

#import "TJBSchemeSelectionDateComp.h"


@interface NewOrExistinigCircuitVC () <NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource, UIViewControllerRestoration>

{
    // user selection flow
    
    BOOL _inPreviewMode;
    
}

// IBOutlet

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UISegmentedControl *sortBySegmentedControl;

@property (weak, nonatomic) IBOutlet UIButton *launchButton;
@property (weak, nonatomic) IBOutlet UIButton *modifyButton;

@property (weak, nonatomic) IBOutlet UIButton *previousMarkButton;

@property (weak, nonatomic) IBOutlet UIView *mainContainer;


@property (weak, nonatomic) IBOutlet UILabel *yearLabel;
@property (weak, nonatomic) IBOutlet UIButton *leftArrowButton;
@property (weak, nonatomic) IBOutlet UIButton *rightArrowButton;
@property (weak, nonatomic) IBOutlet UIScrollView *dateControlScrollView;


// IBAction

- (IBAction)didPressLaunchButton:(id)sender;
- (IBAction)didPressModifyButton:(id)sender;

- (IBAction)didPressLeftArrow:(id)sender;
- (IBAction)didPressRightArrow:(id)sender;


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

- (void)viewDidLoad{
    
    // must sort content first so that the date control can easily know which months have content
    
    [self configureTableView];
    
    [self configureDateControlsAndSelectToday: YES];
    
    [self configureNavigationBar];
    
    [self viewAesthetics];
    
    [self configureSegmentedControl];
    
    [self toggleButtonsToOffState];
    
    [self fetchCoreData];
    
    [self drawCircles];
    
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
            
        }
        
    }
    
}


- (void)configureDateControlsAndSelectToday:(BOOL)shouldSelectToday{
    
    //// configures the date controls according to the day stored in firstDayOfDateControlMonth.  Must be sure to first clear existing date control objects if they exist
    
    [self clearTransitoryDateControlObjects];
    
    // layout views so that the frame property is accurate
    
    [self.view layoutIfNeeded];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    
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
    
    NSDate *activeDate = self.activeDate;
    
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
        
//        NSComparisonResult activeDateMonthCompare = [calendar compareDate: iterativeDate
//                                                                   toDate: activeDate
//                                                        toUnitGranularity: NSCalendarUnitMonth];
        
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
    
    // table view
    
    self.tableView.backgroundColor = [[TJBAestheticsController singleton] yellowNotebookColor];
    
    // buttons
    
    NSArray *buttons = @[self.launchButton,
                         self.modifyButton,
                         self.previousMarkButton];
    
    for (UIButton *button in buttons){
        
        UIColor *color = [[TJBAestheticsController singleton] color2];
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
    
    self.yearLabel.backgroundColor = [UIColor darkGrayColor];
    self.yearLabel.textColor = [UIColor whiteColor];
    self.yearLabel.font = [UIFont boldSystemFontOfSize: 20.0];
    
    // arrows
    
    NSArray *arrows = @[self.rightArrowButton, self.leftArrowButton];
    for (UIButton *b in arrows){
        
        b.backgroundColor = [UIColor darkGrayColor];
        [b setTitleColor: [UIColor whiteColor]
                forState: UIControlStateNormal];
        [b.titleLabel setFont: [UIFont systemFontOfSize: 40.0]];
        
    }
    
}

- (void)configureNavigationBar{
    
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle: @"Designed Lift"];
    
    // left button
    
    UIBarButtonItem *homeButton = [[UIBarButtonItem alloc] initWithTitle: @"Options"
                                                                   style: UIBarButtonItemStyleDone
                                                                  target: self
                                                                  action: @selector(didPressHomeButton)];
    
    [navItem setLeftBarButtonItem: homeButton];
    
    // right button
    
    UIBarButtonItem *newButton = [[UIBarButtonItem alloc] initWithTitle: @"New"
                                                                  style: UIBarButtonItemStyleDone
                                                                 target: self
                                                                 action: @selector(didPressNew)];
    
    [navItem setRightBarButtonItem: newButton];
    
    // nav bar
    
    [self.navBar setItems: @[navItem]];
    
    [self.navBar setTitleTextAttributes: @{NSFontAttributeName: [UIFont boldSystemFontOfSize: 20.0]}];
    
}

- (void)configureTableView{
    
    // table view configuration
    
    UINib *nib = [UINib nibWithNibName: @"TJBStructureTableViewCell"
                                bundle: nil];
    
    [self.tableView registerNib: nib
         forCellReuseIdentifier: @"TJBStructureTableViewCell"];
    
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
    TJBRealizedChain *iterativeRealizedChain;
    
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

- (void)toggleButtonsToOnState{
    
    NSArray *buttons = @[self.launchButton,
                         self.modifyButton];
    
    for (UIButton *b in buttons){
        
        b.enabled = YES;
        b.layer.opacity = 1;
        
    }
    
}

- (void)toggleButtonsToOffState{
    
    NSArray *buttons = @[self.launchButton,
                         self.modifyButton];
    
    for (UIButton *b in buttons){
        
        b.enabled = NO;
        b.layer.opacity = .2;
        
    }
    
}

//#pragma mark - Convenience



#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    int reversedIndex = 11 - [self.selectedDateObjectIndex intValue];
    
    NSInteger rowCount = self.sortedContent[reversedIndex].count;
    
    return rowCount;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    TJBStructureTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier: @"TJBStructureTableViewCell"];
    
    [cell clearExistingEntries];
    
    int reversedIndex = 11 - [self.selectedDateObjectIndex intValue];
    
    TJBChainTemplate *chainTemplate = self.sortedContent[reversedIndex][indexPath.row];
    
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
                              number: [NSNumber numberWithInteger: indexPath.row + 1]];
    
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
    
}

#pragma mark - <UITableViewDelegate>

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return NO;
    
}

//- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
//    
//    //// change the background color of the selected chain template and change the control state of the buttons to activate them.  Store the selected chain and the index path of the selected row
//    
//    // deal with unhighlighting
//
//    self.lastSelectedIndexPath = indexPath;
//    
//    TJBChainTemplate *chainTemplate = self.sortedContent[indexPath.section][indexPath.row];
//    
//    self.selectedChainTemplate = chainTemplate;
//
//    [self toggleButtonsToOnState];
//    
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    int reversedIndex = 11 - [self.selectedDateObjectIndex intValue];
    
    TJBChainTemplate *chainTemplate = self.sortedContent[reversedIndex][indexPath.row];
    
    return [TJBStructureTableViewCell suggestedCellHeightForChainTemplate: chainTemplate];
    
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    
//    UILabel *label = [[UILabel alloc] init];
//    
//    NSDateFormatter *df = [[NSDateFormatter alloc] init];
//    df.dateFormat = @"MMMM yyyy";
//    
//    NSInteger sortSelection = self.sortBySegmentedControl.selectedSegmentIndex;
//    BOOL sortByDateLastExecuted = sortSelection == 0;
//    BOOL sortByDateCreated = sortSelection == 1;
//    
//    if (sortByDateLastExecuted){
//        
//        label.text = [df stringFromDate: self.sortedContent[section].lastObject.dateCreated];
//        
//    } else if (sortByDateCreated){
//        
//        label.text = [df stringFromDate: self.sortedContent[section][0].dateCreated];
//        
//    }
//    
//    label.backgroundColor = [UIColor lightGrayColor];
//    label.textColor = [UIColor blackColor];
//    label.font = [UIFont systemFontOfSize: 20.0];
//    label.textAlignment = NSTextAlignmentCenter;
//    
//    return label;
//    
//}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    
//    return 60;
//    
//}

#pragma mark - Button Actions

- (void)didPressNew{
    
    TJBCircuitDesignVC *vc = [[TJBCircuitDesignVC alloc] init];
    
    [self presentViewController: vc
                       animated: YES
                     completion: nil];
    
}

- (void)didPressHomeButton{
    
    [self dismissViewControllerAnimated: NO
                             completion: nil];
    
}

- (void)segmentedControlValueChanged{
    
    //// re-sort the content array based upon the new sorting preference
    
    [self configureSortedContentForActiveYear];
    [self.tableView reloadData];
    
    [self toggleButtonsToOffState];
    
    self.selectedChainTemplate = nil;
    
}

- (IBAction)didPressLaunchButton:(id)sender {
    
    TJBCircuitModeTBC *tbc = [[TJBCircuitModeTBC alloc] initWithNewRealizedChainAndChainTemplateFromChainTemplate: self.selectedChainTemplate];
    
    [self presentViewController: tbc
                       animated: YES
                     completion: nil];
    
}



- (IBAction)didPressModifyButton:(id)sender{
    
    
}

- (IBAction)didPressLeftArrow:(id)sender{
    
    [self incrementActiveYearAndConfigureDownhillObjectsWithIncrementDirectionForward: NO];
    
}

- (IBAction)didPressRightArrow:(id)sender{
    
    [self incrementActiveYearAndConfigureDownhillObjectsWithIncrementDirectionForward: YES];
    
}

- (void)incrementActiveYearAndConfigureDownhillObjectsWithIncrementDirectionForward:(BOOL)incrementDirectionForward{
    
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
    
}

#pragma mark - <UIViewControllerRestoration>

// will want to eventually store table view scroll position

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder{
    
    NewOrExistinigCircuitVC *vc = [[NewOrExistinigCircuitVC alloc] init];
    
    return vc;
    
}

#pragma mark - <TJBSchemeSelectionDateCompDelegate>

- (void)didSelectObjectWithIndex:(NSNumber *)index representedDate:(NSDate *)representedDate{
    
    if (self.selectedDateObjectIndex){
        
        [self.dateControlObjects[[self.selectedDateObjectIndex intValue]] configureAsNotSelected];
        
    }
    
    self.selectedDateObjectIndex = index;
    [self.tableView reloadData];
    
    [self.dateControlObjects[[index intValue]] configureAsSelected];
    
}



@end






















