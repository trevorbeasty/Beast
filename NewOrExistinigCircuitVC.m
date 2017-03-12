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
#import "TJBCompleteChainHistoryVC.h"

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
    
    BOOL _viewingChainHistory;
    
}

// IBOutlet

@property (strong) UITableView *activeTableView;
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
- (IBAction)didPressViewHistory:(id)sender;

// core

@property (nonatomic, strong) NSFetchedResultsController *frc;

//// state
// these are the content arrays. Due to algorithmic considerations, the sortedContent is such that the 0th array is December and the 11th array is January

@property (nonatomic, strong) NSMutableArray <NSMutableArray <TJBChainTemplate *> *> *tvSortedContent; // this is the array used by the table view as a data source. It holds a collection of chain templates for each month of the year actively displayed in the table view. It is also the array accessed when a user selects a table view cell. It should be reloaded anytime a date control object is selected that corresponds to a different year than it currently represents

@property (nonatomic, strong) NSMutableArray <NSMutableArray <TJBChainTemplate *> *> *dcSortedContent; // this is the date control sorted content.  It holds a collection of chain template collections that correspond to the year actively displayed in the date controls. It must be derived every time a new date control year is selected.  It is leveraged to draw circles appropriately on the date controls and also is assigned to tvSortedContent when a date control object in a new year is selected

// these two dates ultimately control what should be displayed for the date control and table view

@property (nonatomic, strong) NSDate *tvActiveDate; // table view reference date - designates which month of content should be displayed in the active table view
@property (nonatomic, strong) NSDate *dcActiveDate; // date control reference date - designates which year should be represented by the date controls

// table view selection - keeps track of user selections in the presented table view

@property (nonatomic, strong) TJBChainTemplate *selectedChainTemplate;
@property (nonatomic, strong) NSIndexPath *lastSelectedIndexPath;

// date control selection - keeps track of user date control selections

@property (nonatomic, strong) NSNumber *selectedDateObjectIndex;

// date control objects - must be tracked this way because they are created programmatically

@property (nonatomic, strong) UIStackView *dateStackView;
@property (nonatomic, strong) NSMutableArray <TJBSchemeSelectionDateComp *> *dateControlObjects;

// complete chain history vc - is presented on top of table view. This property keeps track of the object

@property (strong) TJBCompleteChainHistoryVC *chainHistoryVC;

@end

@implementation NewOrExistinigCircuitVC

#pragma mark - Instantiation

- (instancetype)init{
    
    self = [super init];
    
    // state
    
    NSDate *today = [NSDate date];
    
    self.tvActiveDate = today;
    self.dcActiveDate = today;
    
    // for restoration
    
    self.restorationIdentifier = @"TJBNewOrExistingCircuit";
    self.restorationClass = [NewOrExistinigCircuitVC class];
    
    //
    
    return self;
}

- (void)initializeActiveVariables{
    
    //// configure state variables for fresh state
    
    _viewingChainHistory = NO;
    
}

#pragma mark - View Cycle

- (void)viewDidLoad{
    
    // must sort content first so that the date control can easily know which months have content
    
    [self viewAesthetics];
    
    [self configureSegmentedControl];
    
    [self toggleButtonsToOffState];
    
    [self configureNotifications];
    
    //
    
    [self deriveSupportArraysAndConfigureInitialDisplay];
    
}

- (void)deriveSupportArraysAndConfigureInitialDisplay{
    
    [self fetchCoreData]; // fetches all chain templates and stores them in the 'frc' property
    
    // derive the supporting arrays for both the date controls and the table view. When this controller is first loaded, the date controls and table view will reference the same array, which corresponds to the year encapsulating the current day
    
    NSDate *today = [NSDate date];
    
    self.tvActiveDate = today;
    self.dcActiveDate = today;
    
    NSMutableArray<NSMutableArray<TJBChainTemplate *> *> *initialRefArray = [self annualSortedContentForReferenceDate: today];
    
    self.dcSortedContent = initialRefArray;
    self.tvSortedContent = initialRefArray;
    
    // must now configure the date controls and create the table view
    
    // date controls
    
    [self configureDateControlsBasedOnDCActiveDate]; // this does not select any particular date control. Call 'didSelectObjectWithIndex' to select a date control and load the corresponding table view
    
    // table view
    // the table view is created by artificially selecting a date control
    
    
    
    
    
}

- (void)configureNotifications{
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(fetchCoreData)
                                                 name: NSManagedObjectContextDidSaveNotification
                                               object: [[CoreDataController singleton] moc]];
    
    
}








- (void)configureSegmentedControl{
    
    //// configure action method for segmented control
    
    [self.sortBySegmentedControl addTarget: self
                                    action: @selector(segmentedControlValueChanged)
                          forControlEvents: UIControlEventValueChanged];
    
}


- (void)viewAesthetics{
    
    // meta view
    
    self.view.backgroundColor = [[TJBAestheticsController singleton] offWhiteColor];
    
    // filter
    
    self.sortBySegmentedControl.tintColor = [[TJBAestheticsController singleton] blueButtonColor];
    
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
    
    [self.activeTableView registerNib: nib
         forCellReuseIdentifier: @"TJBStructureTableViewCell"];
    
    UINib *nib2 = [UINib nibWithNibName: @"TJBWorkoutLogTitleCell"
                                 bundle: nil];
    
    [self.activeTableView registerNib: nib2
         forCellReuseIdentifier: @"TJBWorkoutLogTitleCell"];
    
    UINib *nib3 = [UINib nibWithNibName: @"TJBNoDataCell"
                                 bundle: nil];
    
    [self.activeTableView registerNib: nib3
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
    
}








#pragma mark - Derivation of Support Arrays


- (NSMutableArray<NSMutableArray<TJBChainTemplate *> *> *)annualSortedContentForReferenceDate:(NSDate *)referenceDate{
    
    //// given the chain templates in fetched results and the current sorting selection, derive the sorted content for the year designated by the reference date
    // this method independently evaluates the active index of the segmented control
    
    NSInteger sortSelection = self.sortBySegmentedControl.selectedSegmentIndex;
    BOOL sortByDateLastExecuted = sortSelection == 0;
    
    NSMutableArray<TJBChainTemplate *> *interimArray = [[NSMutableArray alloc] initWithArray: self.frc.fetchedObjects];
    
    if (sortByDateLastExecuted){
        
        [self filterAndSortArrayByDateLastExecuted: interimArray
                                     referenceDate: referenceDate];
        
        return [self bucketByMonthAccordingToDateLastExecuted: interimArray
                                                referenceDate: referenceDate];
        
    } else{
        
        [self filterAndSortArrayByDateCreated: interimArray
                                referenceDate: referenceDate];
        
        return [self bucketByMonthAccordingToDateCreated: interimArray
                                           referenceDate: referenceDate];
        
    }
    
}

- (void)filterAndSortArrayByDateLastExecuted:(NSMutableArray<TJBChainTemplate *> *)array referenceDate:(NSDate *)referenceDate{
    
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
                                                           equalToDate: referenceDate
                                                     toUnitGranularity: NSCalendarUnitYear];
            
            if (iterativeRealizedChainInActiveYear){
                isInActiveYear = YES; // if any of the realized chains are in the reference year, this BOOL becomes YES and that chain template is not filtered from the array
            }
            
        }
        
        if (hasNoRealizedChains || !isInActiveYear){
            
            [indexSet addIndex: [array indexOfObject: chainTemplate]];
            
        }
        
    }
    
    [array removeObjectsAtIndexes: indexSet];
    
    // now, only chain templates with realized chains in the active year remain.  Use an NSComparator to order the chain correctly
    
    [array sortUsingComparator: ^(TJBChainTemplate *chain1, TJBChainTemplate *chain2){
        
        NSDate *date1 = [self largestRealizeChainDateInReferenceYearForChainTemplate: chain1
                                                                       referenceDate: referenceDate];
        NSDate *date2 = [self largestRealizeChainDateInReferenceYearForChainTemplate: chain2
                                                                       referenceDate: referenceDate];
        
        int dateDifference = [date1 timeIntervalSinceDate: date2];
        BOOL date1IsLater = dateDifference > 0;
        
        if (date1IsLater){
            
            return NSOrderedAscending;
            
        } else{
            
            return NSOrderedDescending;
            
        }
        
    }];
    
}

- (void)filterAndSortArrayByDateCreated:(NSMutableArray<TJBChainTemplate *> *)array referenceDate:(NSDate *)referenceDate{
    
    // remove all chain templates that don't have realized sets in the active year
    
    NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier: NSCalendarIdentifierGregorian];
    
    for (TJBChainTemplate *chainTemplate in array){
        
        BOOL isInActiveYear = [calendar isDate: chainTemplate.dateCreated
                                   equalToDate: referenceDate
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
    
}


- (NSMutableArray<NSMutableArray<TJBChainTemplate *> *> *)bucketByMonthAccordingToDateLastExecuted:(NSMutableArray<TJBChainTemplate *> *)chainTemplatesArray referenceDate:(NSDate *)referenceDate{
    
    NSMutableArray<NSMutableArray<TJBChainTemplate *> *> *returnArray = [[NSMutableArray alloc] init];
    
    TJBChainTemplate *iterativeChainTemplate;
    TJBRealizedChain *iterativeRealizedChain;
    
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier: NSCalendarIdentifierGregorian];
    NSDateComponents *iterativeDateComps = [calendar components: (NSCalendarUnitYear | NSCalendarUnitMonth)
                                                       fromDate: referenceDate];
    
    int arrayTracker = 0;
    
    for (int i = 12 ; i > 0; i--){
        
        [iterativeDateComps setMonth: i];
        
        NSMutableArray *monthArray = [[NSMutableArray alloc] init];
        [returnArray addObject: monthArray];
        
        for (int j = arrayTracker; j < chainTemplatesArray.count; j++){
            
            iterativeChainTemplate = chainTemplatesArray[j];
            iterativeRealizedChain = [self largestRealizeChainInReferenceYearAndMonthForChainTemplate: iterativeChainTemplate
                                                                                        referenceDate: [iterativeDateComps date]];
            
            // nil will be returned if there are no matches for the relevant month and year.  If there is a match, add the chain to the return array
            // if there is no match, then all subsequent arrays will not contain any matches because the dates are in decreasing order, so break the for loop and continue to the next month
            
            if (iterativeRealizedChain){
                
                [returnArray[12-i] addObject: iterativeChainTemplate];
                
            } else{
                
                arrayTracker = j;  // the for loop begins searching through the passed in chain template collection at this index. This prevents the loop from analyzing chains that will not match the reference month
                break;
                
            }
            
        }
        
    }
    
    return returnArray;
    
}

- (NSMutableArray<NSMutableArray<TJBChainTemplate *> *> *)bucketByMonthAccordingToDateCreated:(NSMutableArray<TJBChainTemplate *> *)array referenceDate:(NSDate *)referenceDate{
    
    NSMutableArray<NSMutableArray<TJBChainTemplate *> *> *returnArray = [[NSMutableArray alloc] init];
    
    TJBChainTemplate *iterativeChainTemplate;
    
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier: NSCalendarIdentifierGregorian];
    NSDateComponents *iterativeDateComps = [calendar components: (NSCalendarUnitYear | NSCalendarUnitMonth)
                                                       fromDate: referenceDate];
    
    //    NSDate *referenceDate;
    
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

- (NSDate *)largestRealizeChainDateInReferenceYearForChainTemplate:(TJBChainTemplate *)chainTemplate referenceDate:(NSDate *)referenceDate{
    
    //// the goal is to get the largest date for the current year so that dates are correctly ordered.  This algorithm relies on the chain template's chains being in chronological order.  This method assumes there is a realized chain to be referenced
    
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
        
        if (iterativeChainInRefYear){
            
            return iterativeDate;
            
        }
        
    }
    
    return nil;
    
}

- (TJBRealizedChain *)largestRealizeChainInReferenceYearAndMonthForChainTemplate:(TJBChainTemplate *)chainTemplate referenceDate:(NSDate *)referenceDate {
    
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

#pragma mark - Date Controls

- (void)configureDateControlsBasedOnDCActiveDate{
    
    //// configures the date controls according to the date stored in the 'dcActiveDate' property.  Must be sure to first clear existing date control objects if they exist
    
    [self clearTransitoryDateControlObjects];
    
    // layout views so that the frame property is accurate
    
    [self.view layoutIfNeeded];
    
    NSDate *activeDate = self.dcActiveDate;
    
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
        
        //// create the child vc - exactly what configuration the vc receives is dependent upon the iterative date
        
        // determine if the month corresponding to the date control that is about to be created is in the future or the past (only controls in the past can be selected)
        
        NSComparisonResult todayMonthCompare = [calendar compareDate: iterativeDate
                                                              toDate: today
                                                   toUnitGranularity: NSCalendarUnitMonth];
        
        BOOL iterativeMonthGreaterThanCurrentMonth = todayMonthCompare == NSOrderedDescending;
        
        // determine if the date control object that is about to be created has content, and thus should have a circle drawn
        
        int reverseIndex = 11 - i;
        BOOL recordExistsForIterativeMonth = self.dcSortedContent[reverseIndex].count > 0;
        
        TJBSchemeSelectionDateComp *dateControlObject = [[TJBSchemeSelectionDateComp alloc] initWithMonthString: monthString
                                                                                                representedDate: iterativeDate
                                                                                                          index: [NSNumber numberWithInt: i]
                                                                                                      isEnabled: !iterativeMonthGreaterThanCurrentMonth
                                                                                                      isCircled: recordExistsForIterativeMonth
                                                                                          hasSelectedAppearance: NO
                                                                                                           size: dateControlSize
                                                                                               masterController: self];
        
        [self.dateControlObjects addObject: dateControlObject];
        
        [self addChildViewController: dateControlObject];
        
        [stackView addArrangedSubview: dateControlObject.view];
        
        [dateControlObject didMoveToParentViewController: self];
        
    }
    
//    [self drawCircles];
    
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
        BOOL recordExistsForIterativeMonth = self.dcSortedContent[reverseIndex].count > 0;
        
        if (recordExistsForIterativeMonth){
            
            [self.dateControlObjects[i] drawCircle];
            
        } else{
            
            [self.dateControlObjects[i] deleteCircle];
            
        }
        
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
    
    NSInteger rowCount = self.tvSortedContent[reversedIndex].count;
    
    if (rowCount == 0){
        
        return 2;
        
    } else{
        
        return rowCount + 1;
        
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (indexPath.row == 0){
        
        TJBWorkoutLogTitleCell *cell = [self.activeTableView dequeueReusableCellWithIdentifier: @"TJBWorkoutLogTitleCell"];
        
        NSString *primaryText;
        if (self.sortBySegmentedControl.selectedSegmentIndex == 0){
            primaryText = @"Routines by Date Last Executed";
        } else{
            primaryText = @"Routines by Date Created";
        }
        
        NSCalendar *calendar = [NSCalendar calendarWithIdentifier: NSCalendarIdentifierGregorian];
        NSDateComponents *dateComps = [calendar components: (NSCalendarUnitYear | NSCalendarUnitMonth)
                                                  fromDate: self.tvActiveDate];
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
        NSInteger chainCount = self.tvSortedContent[reversedIndex].count;
        
        if (chainCount == 0){
            
            TJBNoDataCell *cell = [self.activeTableView dequeueReusableCellWithIdentifier: @"TJBNoDataCell"];
            
            cell.mainLabel.text = @"No Routines";
            
            cell.backgroundColor = [UIColor clearColor];
            
            return cell;
            
        } else{
            
            BOOL isSelectedCell = NO;
            
            if (self.lastSelectedIndexPath){
                
                isSelectedCell = self.lastSelectedIndexPath.row == indexPath.row;
                
            }
            
            TJBStructureTableViewCell *cell = [self.activeTableView dequeueReusableCellWithIdentifier: @"TJBStructureTableViewCell"];
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.layer.borderColor = [[TJBAestheticsController singleton] blueButtonColor].CGColor;
            
            [cell clearExistingEntries];
            
            NSInteger adjustedRowIndex = indexPath.row - 1;
            
            TJBChainTemplate *chainTemplate = self.tvSortedContent[reversedIndex][adjustedRowIndex];
            
            NSInteger sortSelection = self.sortBySegmentedControl.selectedSegmentIndex;
            BOOL sortByDateLastExecuted = sortSelection == 0;
            BOOL sortByDateCreated = sortSelection == 1;
            
            NSDate *date;
            
            if (sortByDateLastExecuted){
                
                date = [self largestRealizeChainDateInReferenceYearForChainTemplate: chainTemplate
                                                                      referenceDate: self.tvActiveDate];
                
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
    NSInteger chainCount = self.tvSortedContent[reversedIndex].count;
    
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
    
    TJBChainTemplate *chainTemplate = self.tvSortedContent[reversedIndex][indexPath.row - 1];
    
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
        
        NSInteger chainCount = self.tvSortedContent[reversedIndex].count;
        
        if (chainCount == 0){
            
            [self.view layoutIfNeeded];
            
            return self.activeTableView.frame.size.height - titleHeight;
            
        } else{
            
            TJBChainTemplate *chainTemplate = self.tvSortedContent[reversedIndex][indexPath.row -1];
            
            return [TJBStructureTableViewCell suggestedCellHeightForChainTemplate: chainTemplate];
            
        }
        
    }
    
}


#pragma mark - Button Actions


- (IBAction)didPressBackButton:(id)sender{
    
    [self dismissViewControllerAnimated: NO
                             completion: nil];
    
}

- (IBAction)didPressViewHistory:(id)sender{
    
    // only attempt to present the VC if a chain template has been selected
    
    if (_viewingChainHistory == NO){
        
        TJBCompleteChainHistoryVC *chainHistoryVC = [[TJBCompleteChainHistoryVC alloc] initWithChainTemplate: self.selectedChainTemplate];
        self.chainHistoryVC = chainHistoryVC;
        
        // give the new vc's view the same rect as the current table view
        // must go through the necessary steps to add the chain history vc as a child view controller
        
        [self addChildViewController: chainHistoryVC];
        
        CGRect finalMainscreenFrame = self.mainContainer.frame;
        chainHistoryVC.view.frame = finalMainscreenFrame;
        [self.view insertSubview: chainHistoryVC.view
                    aboveSubview: self.activeTableView];
        
        [chainHistoryVC didMoveToParentViewController: self];
        
        // update state
        
        _viewingChainHistory = YES;
        
        // update button title
        
        [self.previousMarkButton setTitle: @"Back"
                                 forState: UIControlStateNormal];
        
    } else{
        
        // remove the chain history view and nullify the class property
        
        [self.chainHistoryVC.view removeFromSuperview];
        self.chainHistoryVC = nil;
        
        // update state and button title
        
        _viewingChainHistory = NO;
        
        [self.previousMarkButton setTitle: @"View History"
                                 forState: UIControlStateNormal];
        
    }
    

    
}

- (IBAction)didPressRightNewButton:(id)sender{
    
    TJBCircuitDesignVC *vc = [[TJBCircuitDesignVC alloc] init];
    
    [self.presentingViewController presentViewController: vc
                                        animated: NO
                                      completion: nil];

    
}

- (void)segmentedControlValueChanged{
    
//    [self configureSelectionAsNil];
//    
//    //// re-sort the content array based upon the new sorting preference
//    
//    [self configureSortedContentForActiveYear];
//    [self.tableView reloadData];
//    [self drawCircles];
//    
//    [self toggleButtonsToOffState];
//    
//    self.selectedChainTemplate = nil;
    
}

- (IBAction)didPressLaunchButton:(id)sender {
    
    if (self.selectedChainTemplate){
        
        TJBActiveRoutineGuidanceVC *vc1 = [[TJBActiveRoutineGuidanceVC alloc] initFreshRoutineWithChainTemplate: self.selectedChainTemplate];
        vc1.tabBarItem.title = @"Active";
        
        TJBWorkoutNavigationHub *vc3 = [[TJBWorkoutNavigationHub alloc] initWithHomeButton: NO];
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
    
    TJBStructureTableViewCell *cell = [self.activeTableView cellForRowAtIndexPath: self.lastSelectedIndexPath];
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
                                              fromDate: self.dcActiveDate];
    
    dateComps.year += yearDelta;
    self.dcActiveDate = [calendar dateFromComponents: dateComps];
    
//    [self configureDateControlsAndSelectToday: NO];
//    [self configureSortedContentForActiveYear];
    [self drawCircles];
//    [self.tableView reloadData];
//    
//    [self didSelectObjectWithIndex: self.selectedDateObjectIndex];
    
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
    [self.activeTableView reloadData];
    
    [self.dateControlObjects[[index intValue]] configureAsSelected];
    
}



@end






















