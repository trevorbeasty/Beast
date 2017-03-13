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
@property (strong) UIScrollView *activeScrollView;
@property (strong) UIActivityIndicatorView *activeActivityIndicator;
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
@property (weak, nonatomic) IBOutlet UILabel *leftArrowGrayBackgr;
@property (weak, nonatomic) IBOutlet UILabel *rightArrowGrayBackgr;

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

@property (nonatomic, strong) NSMutableArray <TJBChainTemplate *> *tvSortedContent; // this is the array used by the table view as a data source. It holds a collection of chain templates for each month of the year actively displayed in the table view. It is also the array accessed when a user selects a table view cell. It should be reloaded anytime a date control object is selected that corresponds to a different year than it currently represents

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
@property (strong) UIScrollView *chainHistoryScrollView;

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
    
    self.dcSortedContent = initialRefArray; // only the dc needs to store this annual, sorted content bucketed by month. The table view simply must choose the correct bucket when setting its tvSortedContent
    
    // must now configure the date controls and create the table view
    
    // date controls
    
    [self configureDateControlsBasedOnDCActiveDate]; // this does not select any particular date control. Call 'didSelectObjectWithIndex' to select a date control and load the corresponding table view
    
    // table view
    // the table view is created by artificially selecting a date control
    
    int dateControlIndex = [self dateControlObjectIndexForDate: self.tvActiveDate];
    
    [self didSelectObjectWithIndex: @(dateControlIndex)];
    
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
    
    // arrow background labels
    
    self.leftArrowGrayBackgr.backgroundColor = [UIColor darkGrayColor];
    [self.view insertSubview: self.leftArrowButton
                aboveSubview: self.leftArrowGrayBackgr];
    
    self.rightArrowGrayBackgr.backgroundColor = [UIColor darkGrayColor];
    [self.view insertSubview: self.rightArrowButton
                aboveSubview: self.rightArrowGrayBackgr];
    
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
                                                                                        referenceDate: [calendar dateFromComponents: iterativeDateComps]];
            
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
                                                                                                      isEnabled: YES
                                                                                                      isCircled: recordExistsForIterativeMonth
                                                                                          hasSelectedAppearance: NO
                                                                                                           size: dateControlSize
                                                                                               masterController: self
                                                                                             representsPastDate: !iterativeMonthGreaterThanCurrentMonth];
        
        [self.dateControlObjects addObject: dateControlObject];
        
        [self addChildViewController: dateControlObject];
        
        [stackView addArrangedSubview: dateControlObject.view];
        
        [dateControlObject didMoveToParentViewController: self];
        
    }
    
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

//    int reversedIndex = 11 - [self.selectedDateObjectIndex intValue];
    
    NSInteger rowCount = self.tvSortedContent.count;
    
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
        
        NSInteger chainCount = self.tvSortedContent.count;
        
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
            
            TJBChainTemplate *chainTemplate = self.tvSortedContent[adjustedRowIndex];
            
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
    
    NSInteger chainCount = self.tvSortedContent.count;
    
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
    
//    int reversedIndex = 11 - [self.selectedDateObjectIndex intValue];
    
    TJBChainTemplate *chainTemplate = self.tvSortedContent[indexPath.row - 1];
    
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
        
        NSInteger chainCount = self.tvSortedContent.count;
        
        if (chainCount == 0){
            
            [self.view layoutIfNeeded];
            
            return self.activeTableView.frame.size.height - titleHeight;
            
        } else{
            
            TJBChainTemplate *chainTemplate = self.tvSortedContent[indexPath.row -1];
            
            return [TJBStructureTableViewCell suggestedCellHeightForChainTemplate: chainTemplate];
            
        }
        
    }
    
}

#pragma mark - View History and Related Actions

- (IBAction)didPressViewHistory:(id)sender{
    
    // only attempt to present the VC if a chain template has been selected
    
    if (_viewingChainHistory == NO){
        
        // will need to show an activity indicator while loading the history table view because it could have enough cells to require a significant amount of loading time
        
        [self showActivityIndicator];
        
        [self giveControlsDisabledConfiguration];
        
        // the chain history table view is handled by a separate controller. I simply add it to a scroll view here and designate it as a a child view controller
        // this task must be completed after a short delay to allow the view to draw the activity indicator
        
        [self performSelector: @selector(showChainHistoryForSelectedChainAndUpdateStateVariables)
                   withObject: nil
                   afterDelay: .2];
        
    } else{
        
        // show activity indicator
        
        [self showActivityIndicator];
        
        // queue the uploading of the new table to allow the view to redraw itself
        
        [self performSelector: @selector(showChainOptionsForCurrentTVActiveDateAndUpdateStateVariables)
                   withObject: nil
                   afterDelay: .2];
        
        
        
    }
    
    
    
}

- (void)showChainOptionsForCurrentTVActiveDateAndUpdateStateVariables{
    
    // show the chain options for the current tvActiveDate
    
    // remove all existing table view objects
    
    [self clearAllTableViewsAndDirectlyAssociatedObjects];
    
    // clear all previous table view selections
    
    [self configureSelectionAsNil];
    
    // the tvSortedContent is not cleared when the chainHistoryVC is presented, thus, no work has to be done to derive tvSortedContent
    
    // show the new table view
    
    // new table view
    
    [self addEmbeddedTableViewToViewHierarchy];
    
    // enable all buttons and give enabled appearance
    
    [self giveControlsEnabledConfiguration];
    
    // remove the activity indicator
    
    [self removeActivityIndicatorIfExists];
    
    // update state and button title
    
    _viewingChainHistory = NO;
    
    [self.previousMarkButton setTitle: @"View History"
                             forState: UIControlStateNormal];
    
}

- (void)showChainHistoryForSelectedChainAndUpdateStateVariables{
    
    // get rid of all table views before adding current table view
    
    [self clearAllTableViewsAndDirectlyAssociatedObjects];
    
    // history table view
    
    TJBCompleteChainHistoryVC *chainHistoryVC = [[TJBCompleteChainHistoryVC alloc] initWithChainTemplate: self.selectedChainTemplate];
    self.chainHistoryVC = chainHistoryVC;
    
    CGFloat contentHeight = [chainHistoryVC contentHeight]; // gets the total height of cells based on provided chain template
    if (contentHeight < self.mainContainer.frame.size.height){
        contentHeight = self.mainContainer.frame.size.height;
    }
    
    CGRect rect = CGRectMake(0, 0, self.mainContainer.frame.size.width, contentHeight);
    chainHistoryVC.view.frame = rect;
    
    // scroll view
    
    UIScrollView *sv = [[UIScrollView alloc] initWithFrame: self.mainContainer.bounds];
    self.chainHistoryScrollView = sv;
    
    CGSize contentSize = CGSizeMake(self.mainContainer.frame.size.width, contentHeight);
    sv.contentSize = contentSize;
    
    [sv addSubview: chainHistoryVC.view];
    
    // give the new vc's view the same rect as the current table view
    // must go through the necessary steps to add the chain history vc as a child view controller
    
    [self addChildViewController: chainHistoryVC];
    
    [self.mainContainer addSubview: sv];
    
    [chainHistoryVC didMoveToParentViewController: self];
    
    // update state
    
    _viewingChainHistory = YES;
    
    // update button title
    
    [self.previousMarkButton setTitle: @"Back"
                             forState: UIControlStateNormal];
    
    // get rid of the activity indicator and old table view content. The content will be reloaded if it is later required
    
    [self removeActivityIndicatorIfExists];
    
    // only enable certain controls. Will force the user to press back to return to previous browsing mode
    
    self.backButton.enabled = YES;
    self.backButton.layer.opacity = 1.0;
    
}

- (void)clearAllTableViewsAndDirectlyAssociatedObjects{
    
    // chain template tv
    
    if (self.activeTableView){
        
        [self.activeTableView removeFromSuperview];
        self.activeTableView = nil;
        
    }
    
    if (self.activeScrollView){
        
        [self.activeScrollView removeFromSuperview];
        self.activeScrollView = nil;
        
    }
    
    // chain history tv
    
    if (self.chainHistoryScrollView){
        
        [self.chainHistoryScrollView removeFromSuperview];
        self.chainHistoryScrollView = nil;
        
    }
    
    if (self.chainHistoryVC){
        
        // remove the child view controller as dictated in apple's programming guide
        
        [self.chainHistoryVC willMoveToParentViewController: nil];
        
        [self.chainHistoryVC.view removeFromSuperview];
        
        [self.chainHistoryVC removeFromParentViewController];
        
        self.chainHistoryVC = nil;
        
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
    
    // must rederive and layout date controls because the filter criteria for chain templates has now changed
    
    self.dcSortedContent = [self annualSortedContentForReferenceDate: self.dcActiveDate];
    
    [self configureDateControlsBasedOnDCActiveDate];
    
    // will then artificially select the same date control object that was previously selected. This is done because it may otherwise be confusing to the user if the criteria changes but the content for the old criteria still remains
    
    [self didSelectObjectWithIndex: self.selectedDateObjectIndex];
    
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
    
    [self incrementDCACtiveYearWithIncrementDirectionForward: NO];
    
}

- (IBAction)didPressRightArrow:(id)sender{
    
    [self incrementDCACtiveYearWithIncrementDirectionForward: YES];
    
}



- (void)configureSelectionAsNil{
    
    // get rid of the border on the last selected cell and change state variables for selection
    
    self.selectedChainTemplate = nil;
    [self toggleButtonsToOffState];
    
    if (self.lastSelectedIndexPath){
        
        TJBStructureTableViewCell *cell = [self.activeTableView cellForRowAtIndexPath: self.lastSelectedIndexPath];
        cell.layer.borderWidth = 0.0;
        cell.backgroundColor = [UIColor clearColor];
        self.lastSelectedIndexPath = nil;
        
    }
    
}

- (void)incrementDCACtiveYearWithIncrementDirectionForward:(BOOL)incrementDirectionForward{
    
    int yearDelta;
    
    if (incrementDirectionForward){
        yearDelta = 1;
    } else{
        yearDelta = -1;
    }
    
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier: NSCalendarIdentifierGregorian];
    NSDateComponents *dateComps = [calendar components: NSCalendarUnitYear
                                              fromDate: self.dcActiveDate];
    
    dateComps.year += yearDelta;
    [dateComps setDay: 1];
    [dateComps setMonth: 1];
    self.dcActiveDate = [calendar dateFromComponents: dateComps];
    
    // source array and date control objects
    
    self.dcSortedContent = [self annualSortedContentForReferenceDate: self.dcActiveDate];
    
    [self configureDateControlsBasedOnDCActiveDate];
    
}

#pragma mark - <UIViewControllerRestoration>

// will want to eventually store table view scroll position

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder{
    
    NewOrExistinigCircuitVC *vc = [[NewOrExistinigCircuitVC alloc] init];
    
    return vc;
    
}

#pragma mark - <TJBSchemeSelectionDateCompDelegate>

- (void)didSelectObjectWithIndex:(NSNumber *)index{
    
    // disable controls and give disabled appearance
    
    [self giveControlsDisabledConfiguration];
    
    // must show the new selection in the date control objects, show the activity indicator while replacing the old table view, and adjust all state variables accordingly
    
    [self configureSelectionAsNil]; // adjusts certain state parameters
    
    // date objects
    
    if (self.selectedDateObjectIndex){
        
        [self.dateControlObjects[[self.selectedDateObjectIndex intValue]] configureAsNotSelected];
        
    }
    
    [self.dateControlObjects[[index intValue]] configureAsSelected];
    self.selectedDateObjectIndex = index;
    
    // activity indicator
    
    [self showActivityIndicator];
    
    // delayed call to load new table view and get rid of activity indicator. Delay is used to both ensure that the activity indicator actually appears (and spins) and to protect against the activity indicator only being visible for a millisecond or so (which just makes the app look glitchy)
    
    [self performSelector: @selector(updateTableViewAndRemoveActivityIndicator:)
               withObject: index
               afterDelay: .2];

}



- (void)showActivityIndicator{
    
    if (self.activeActivityIndicator){
        
        [self.activeActivityIndicator removeFromSuperview];
        self.activeActivityIndicator = nil;
        
    }
    
    UIActivityIndicatorView *indView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
    self.activeActivityIndicator = indView;
    
    indView.frame = self.mainContainer.frame;
    indView.backgroundColor = [[TJBAestheticsController singleton] yellowNotebookColor];
    indView.layer.opacity = .9;
    indView.hidesWhenStopped = YES;
    
    [self.view addSubview: indView];
    
    [indView startAnimating];
    
}

- (void)giveControlsDisabledConfiguration{
    
    self.backButton.enabled = NO;
    self.backButton.layer.opacity = .4;
    
    NSArray *arrows = @[self.leftArrowButton, self.rightArrowButton];
    for (UIButton *b in arrows){
        
        b.enabled = NO;
        b.layer.opacity = .4;
        
    }
    
    self.sortBySegmentedControl.enabled = NO;
    self.sortBySegmentedControl.layer.opacity = .4;
    
    for (TJBSchemeSelectionDateComp *comp in self.dateControlObjects){
        
        [comp configureAsDisabled];
        
    }
    
}

- (void)giveControlsEnabledConfiguration{
    
    self.backButton.enabled = YES;
    self.backButton.layer.opacity = 1.0;
    
    NSArray *arrows = @[self.leftArrowButton, self.rightArrowButton];
    for (UIButton *b in arrows){
        
        b.enabled = YES;
        b.layer.opacity = 1.0;
        
    }
    
    self.sortBySegmentedControl.enabled = YES;
    self.sortBySegmentedControl.layer.opacity = 1.0;
    
    for (TJBSchemeSelectionDateComp *comp in self.dateControlObjects){
        
        [comp configureAsEnabled];
        
    }
    
}

- (void)updateTableViewAndRemoveActivityIndicator:(NSNumber *)index{
    
    // get rid of all existing table before adding the new one
    
    [self clearAllTableViewsAndDirectlyAssociatedObjects];
    
    // table view UI and supporting array
    // supporting array must be derived before the table view is configured because the supporting array is required to determine table view size and to determine cell content
    
    int reversedIndex = 11 - [index intValue]; // must use a reversed index because December is in the 0th position of dcSortedContent
    self.tvSortedContent = self.dcSortedContent[reversedIndex]; // the chains being used by the tv will always be a subset of those stored in the dcSortedContent array
    
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
    NSDateComponents *dateComps = [cal components: NSCalendarUnitYear
                                         fromDate: self.dcActiveDate];
    [dateComps setMonth: [index intValue] + 1];
    [dateComps setDay: 1];
    self.tvActiveDate = [cal dateFromComponents: dateComps];
    
    // new table view
    
    [self addEmbeddedTableViewToViewHierarchy];
    
    // enable all buttons and give enabled appearance
    
    [self giveControlsEnabledConfiguration];
    
}

- (void)addEmbeddedTableViewToViewHierarchy{
    
    //// returns a table view embedded inside a scroll view. This is done so that the table view is forced to layout all its content
    
    UIScrollView *sv = [[UIScrollView alloc] initWithFrame: self.mainContainer.bounds];
    self.activeScrollView = sv;
    
    CGFloat tvContentHeight = [self totalTableViewHeightBasedOnTVSortedContent];
    
    if (tvContentHeight < self.mainContainer.frame.size.height){
        tvContentHeight = self.mainContainer.frame.size.height;
    }
    
    CGSize svContentSize = CGSizeMake(self.mainContainer.frame.size.width, tvContentHeight); // the scroll view is large enough that the table view will layout all of its content
    sv.contentSize = svContentSize;
    
    sv.backgroundColor = [UIColor clearColor];
    
    UITableView *tv = [[UITableView alloc] init];
    self.activeTableView = tv;
    
    [self configureTableView: tv];
    
    tv.frame = CGRectMake(0, 0, svContentSize.width, tvContentHeight);
    tv.backgroundColor = [[TJBAestheticsController singleton] yellowNotebookColor];
    
    tv.dataSource = self;
    tv.delegate = self;
    
    // ... other aesthetic properties
    
    //// view hierarchy
    // sv and tv
    
    [sv addSubview: tv];
    [self.mainContainer addSubview: sv];
    
    // activity indicator
    
    [self removeActivityIndicatorIfExists];

}

- (void)removeActivityIndicatorIfExists{
    
    if (self.activeActivityIndicator){
        
        [self.activeActivityIndicator stopAnimating];
        [self.activeActivityIndicator removeFromSuperview];
        self.activeActivityIndicator = nil;
        
        
    }
    
}

- (CGFloat)totalTableViewHeightBasedOnTVSortedContent{
    
    // based on the array of chain templates found in tvSortedContent, calculate the total table view height
    
    NSInteger iterationLimit; // based on the count of objects in tvSortedContent, the amount of cells presented by the table view will vary
    
    if (self.tvSortedContent.count == 0){
        
        iterationLimit = 2;
        
    } else{
        
        iterationLimit = self.tvSortedContent.count + 1;
        
    }
    
    CGFloat sum = 0;
    
    for (int i = 0; i < iterationLimit; i++){
        
        NSIndexPath *path = [NSIndexPath indexPathForRow: i
                                               inSection: 0];
        
        CGFloat height = [self tableView: self.activeTableView
                 heightForRowAtIndexPath: path];
        
        sum += height;
        
    }
    
    return sum;
    
}

- (int)dateControlObjectIndexForDate:(NSDate *)date{
    
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier: NSCalendarIdentifierGregorian];
    NSInteger monthAsInt = [calendar component: NSCalendarUnitMonth
                                      fromDate: date];
    
    return (int)monthAsInt - 1;
    
}

- (void)configureTableView:(UITableView *)tableView{
    
    // table view configuration
    
    // cells
    
    UINib *nib = [UINib nibWithNibName: @"TJBStructureTableViewCell"
                                bundle: nil];
    
    [tableView registerNib: nib
               forCellReuseIdentifier: @"TJBStructureTableViewCell"];
    
    UINib *nib2 = [UINib nibWithNibName: @"TJBWorkoutLogTitleCell"
                                 bundle: nil];
    
    [tableView registerNib: nib2
               forCellReuseIdentifier: @"TJBWorkoutLogTitleCell"];
    
    UINib *nib3 = [UINib nibWithNibName: @"TJBNoDataCell"
                                 bundle: nil];
    
    [tableView registerNib: nib3
               forCellReuseIdentifier: @"TJBNoDataCell"];
    
    // data source and delegate
    
    tableView.delegate = self;
    tableView.dataSource = self;
    
}



@end






















