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

#import "TJBActiveGuidanceTBC.h" // tab bar controller for active guidance

// VC's to present

//#import "TJBActiveRoutineGuidanceVC.h"
//#import "TJBWorkoutNavigationHub.h"
#import "TJBCircuitReferenceContainerVC.h"
#import "TJBCompleteChainHistoryVC.h"
#import "TJBCircuitTemplateContainerVC.h"

// views

#import "TJBCircuitReferenceVC.h"

// aesthetics

#import "TJBAestheticsController.h"

// table view cell

#import "TJBRealizedChainCell.h"
//#import "TJBWorkoutLogTitleCell.h"
#import "TJBNoDataCell.h"

// date control

#import "TJBSchemeSelectionDateComp.h"


#pragma mark - Constants


typedef enum{
    TJBToolbarHidden,
    TJBToolBarNotHidden
}TJBToolbarState;



@interface NewOrExistinigCircuitVC () <NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource>

{
    // user selection flow
    
    BOOL _viewingChainHistory;
    BOOL _coreDataUpdateRequired;
    TJBToolbarState _toolbarState;
    
}

// IBOutlet

@property (strong) UIActivityIndicatorView *activeActivityIndicator;

@property (weak, nonatomic) IBOutlet UIView *mainContainer;
@property (weak, nonatomic) IBOutlet UILabel *yearLabel;
@property (weak, nonatomic) IBOutlet UIButton *leftArrowButton;
@property (weak, nonatomic) IBOutlet UIButton *rightArrowButton;
@property (weak, nonatomic) IBOutlet UIScrollView *dateControlScrollView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIView *topTitleBar;

@property (weak, nonatomic) IBOutlet UILabel *routinesByLabel;
@property (weak, nonatomic) IBOutlet UILabel *monthYearTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfRecordsLabel;

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UILabel *sortByBottomLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sortBySegmentedControl;
@property (weak, nonatomic) IBOutlet UIButton *arrowControlButton;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *launchButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *historyButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *createNewButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolbarBottomSpacingConstr;


// IBAction

- (IBAction)didPressLeftArrow:(id)sender;
- (IBAction)didPressRightArrow:(id)sender;
- (IBAction)didPressBackButton:(id)sender;
- (IBAction)didPressArrowControlButton:(id)sender;


// toolbar button actions

- (IBAction)didPressLaunchButton:(id)sender;
- (IBAction)didPressHistoryButton:(id)sender;
- (IBAction)didPressDeleteButton:(id)sender;
- (IBAction)didPressNewRoutine:(id)sender;




// core

//@property (nonatomic, strong) NSFetchedResultsController *frc;
@property (strong) UITableView *activeTableView;
@property (strong) UIScrollView *activeScrollView;

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
@property (strong) UIButton *viewHistoryReturnButton;

@end


#pragma mark - Constants

static NSTimeInterval const toolbarSlidingAnimationTime = .2;

static CGFloat const historyReturnButtonHeight = 44;
static CGFloat const historyReturnButtonBottomSpacing = 8;











@implementation NewOrExistinigCircuitVC

#pragma mark - Instantiation

- (instancetype)init{
    
    self = [super init];
    
    // active dates
    
    NSDate *today = [NSDate date];
    self.tvActiveDate = today;
    self.dcActiveDate = today;
    
    // state
    
    _toolbarState = TJBToolBarNotHidden;
    _coreDataUpdateRequired = NO;
    
    
    return self;
}

- (void)initializeActiveVariables{
    
    //// configure state variables for fresh state
    
    _viewingChainHistory = NO;
    
}

#pragma mark - View Cycle

- (void)viewDidLoad{
    
    [self viewAesthetics];
    
    // segmented control
    
    [self configureSegmentedControlNotifications];
    [self configureCoreDataNotifications];
    
    [self selectDateControlCorrespondingToDate: [NSDate date]];
    
    return;
    
}

- (void)viewWillAppear:(BOOL)animated{
    
    // core data will be saved many times as a routine is created
    // this method of updating this controller prevents needless, repetitive updates
    
    if (_coreDataUpdateRequired == YES){
        
        [self createAndShowDateControlsForDate: self.tvActiveDate];
        [self selectDateControlCorrespondingToDate: self.tvActiveDate];
        
        _coreDataUpdateRequired = NO;
        
    }
    
}

#pragma mark - View Helper Methods

- (void)configureSegmentedControlNotifications{
    
    [self.sortBySegmentedControl addTarget: self
                                    action: @selector(segmentedControlValueDidChange)
                          forControlEvents: UIControlEventValueChanged];
    
}





- (void)viewAesthetics{
    
    self.topTitleBar.backgroundColor = [UIColor darkGrayColor];
    
    // meta view
    
    self.view.backgroundColor = [UIColor blackColor];
    
    // container view shadow
    
    UIView *shadowView = self.mainContainer;
    shadowView.backgroundColor = [[TJBAestheticsController singleton] yellowNotebookColor];
    shadowView.clipsToBounds = NO;
    
    CALayer *shadowLayer = shadowView.layer;
    shadowLayer.masksToBounds = NO;
    shadowLayer.shadowColor = [UIColor darkGrayColor].CGColor;
    shadowLayer.shadowOffset = CGSizeMake(0.0, 3.0);
    shadowLayer.shadowOpacity = 1.0;
    shadowLayer.shadowRadius = 3.0;
    
    //// date controls
    
    // year label
    
    NSArray *titleLabels = @[self.yearLabel];
    for (UILabel *label in titleLabels){
        
        label.backgroundColor = [UIColor darkGrayColor];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont boldSystemFontOfSize: 20];
        
    }
    
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
    
    // title labels
    
    NSArray *grayBarTitleLabels = @[self.routinesByLabel, self.monthYearTitleLabel, self.numberOfRecordsLabel];
    for (UILabel *lab in grayBarTitleLabels){
        
        lab.backgroundColor = [UIColor grayColor];
        lab.textColor = [UIColor whiteColor];
        lab.font = [UIFont boldSystemFontOfSize: 15];
        
    }

    // bottom controls
    
    self.arrowControlButton.backgroundColor = [UIColor grayColor];
    CALayer *acbLayer = self.arrowControlButton.layer;
    acbLayer.cornerRadius = 25;
    acbLayer.masksToBounds = YES;
    acbLayer.borderWidth = 1;
    acbLayer.borderColor = [[TJBAestheticsController singleton] paleLightBlueColor].CGColor;
    
    self.toolbar.backgroundColor = [UIColor grayColor];
    
    self.sortBySegmentedControl.backgroundColor = [UIColor grayColor];
    self.sortBySegmentedControl.tintColor = [[TJBAestheticsController singleton] paleLightBlueColor];
    CALayer *sbscLayer = self.sortBySegmentedControl.layer;
    sbscLayer.masksToBounds = YES;
    sbscLayer.cornerRadius = 22;
    sbscLayer.borderColor = [[TJBAestheticsController singleton] paleLightBlueColor].CGColor;
    sbscLayer.borderWidth = 1.0;
    
    self.toolbar.barTintColor = [UIColor grayColor];
    self.toolbar.tintColor = [[TJBAestheticsController singleton] paleLightBlueColor];
    CALayer *tbLayer = self.toolbar.layer;
    tbLayer.cornerRadius = 22;
    tbLayer.masksToBounds = YES;
    tbLayer.borderColor = [[TJBAestheticsController singleton] paleLightBlueColor].CGColor;
    tbLayer.borderWidth = 1.0;
    
    self.sortByBottomLabel.font = [UIFont boldSystemFontOfSize: 15];
    self.sortByBottomLabel.backgroundColor = [UIColor clearColor];
    self.sortByBottomLabel.textColor = [UIColor grayColor];
    
}

- (void)configureTableView:(UITableView *)tableView{
    
    // table view configuration
    
    // cells
    
    UINib *nib = [UINib nibWithNibName: @"TJBRealizedChainCell"
                                bundle: nil];
    
    [tableView registerNib: nib
    forCellReuseIdentifier: @"TJBRealizedChainCell"];
    
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

#pragma mark - Routine Content Generation Sequence


- (void)selectDateControlCorrespondingToDate:(NSDate *)date{
    
    // must check that the passed-in date is within the year for the current dcActiveDate
    // if it is not, must reload date controls for the passed-in date
    // the didSelectObjectAtIndex method does no date checking
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
    
    BOOL correctDateControlsDisplayed = [calendar isDate: date
                                             equalToDate: self.dcActiveDate
                                       toUnitGranularity: NSCalendarUnitYear];
    
    // loads the date controls if the dates are incompatible or there are no date control objects currently displayed
    
    if (correctDateControlsDisplayed == NO || !self.dateStackView){
        
        [self createAndShowDateControlsForDate: date];
        
    }
    
    int dateControlIndex = [self dateControlObjectIndexForDate: self.tvActiveDate];
    [self didSelectObjectWithIndex: @(dateControlIndex)];
    
}



- (NSMutableArray<NSMutableArray<TJBChainTemplate *> *> *)annualSortedContentForReferenceDate:(NSDate *)referenceDate{
    
    //// given the chain templates in fetched results and the current sorting selection, derive the sorted content for the year designated by the reference date
    // this method independently evaluates the active index of the segmented control
    
    BOOL sortByDateLastExecuted = self.sortBySegmentedControl.selectedSegmentIndex == 1;
    
    
    NSFetchRequest *fr = [self chainTemplateFetchRequest];
    NSManagedObjectContext *moc = [[CoreDataController singleton] moc];
    NSError *error = nil;
    NSArray *chainTemplates = [moc executeFetchRequest: fr
                                                 error: &error];
    NSMutableArray<TJBChainTemplate *> *interimArray = [[NSMutableArray alloc] initWithArray: chainTemplates];
    
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


- (void)didSelectObjectWithIndex:(NSNumber *)index{
    
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
    NSDateComponents *dateComps = [cal components: NSCalendarUnitYear
                                         fromDate: self.dcActiveDate];
    [dateComps setMonth: [index intValue] + 1];
    [dateComps setDay: 1];
    
    NSDate *selectedDate = [cal dateFromComponents: dateComps];
    self.tvActiveDate = selectedDate;
    
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


- (void)updateTableViewAndRemoveActivityIndicator:(NSNumber *)index{
    
    // get rid of all existing table before adding the new one
    
    [self clearAllTableViewsAndDirectlyAssociatedObjects];
    
    // table view UI and supporting array
    // supporting array must be derived before the table view is configured because the supporting array is required to determine table view size and to determine cell content
    
    int reversedIndex = 11 - [index intValue]; // must use a reversed index because December is in the 0th position of dcSortedContent
    self.tvSortedContent = self.dcSortedContent[reversedIndex]; // the chains being used by the tv will always be a subset of those stored in the dcSortedContent array
    
    // new table view
    
    [self addEmbeddedTableViewToViewHierarchy];
    
    // controls state
    
    [self giveControlsEnabledConfiguration];
    [self configureToolbarButtonsAccordingToActiveState];
    
    
    return;
    
}




- (void)addEmbeddedTableViewToViewHierarchy{
    
    [self.view layoutSubviews];
    
    //// returns a table view embedded inside a scroll view. This is done so that the table view is forced to layout all its content
    
    UIScrollView *sv = [[UIScrollView alloc] initWithFrame: self.mainContainer.bounds];
    self.activeScrollView = sv;
    
    CGFloat tvContentHeight = [self totalTableViewHeightBasedOnTVSortedContent];
    
    if (tvContentHeight < self.mainContainer.frame.size.height){
        tvContentHeight = self.mainContainer.frame.size.height;
    }
    
    CGSize svContentSize = [self scrollViewContentSize]; // the scroll view is large enough that the table view will layout all of its content plus a little breather room above the bottom controls
    sv.contentSize = svContentSize;
    
    sv.backgroundColor = [UIColor clearColor];
    sv.bounces = YES;
    
    UITableView *tv = [[UITableView alloc] init];
    self.activeTableView = tv;
    
    [self configureTableView: tv];
    
    tv.frame = CGRectMake(0, 0, svContentSize.width, tvContentHeight);
    tv.backgroundColor = [[TJBAestheticsController singleton] yellowNotebookColor];
    tv.separatorColor = [UIColor blackColor];
    tv.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    
    tv.dataSource = self;
    tv.delegate = self;
    
    // ... other aesthetic properties
    
    //// view hierarchy
    // sv and tv
    
    [sv addSubview: tv];
    [self.mainContainer insertSubview: sv
                              atIndex: 0];
    
    // activity indicator
    
    [self removeActivityIndicatorIfExists];
    
    // labels
    
    [self updateAllTitleLabelsForNewContent];
    
    return;
    
}





#pragma mark - Routine Content Generation Sequence Helper Methods

- (CGSize)scrollViewContentSize{
    
    CGFloat svContentHeight = [self totalTableViewHeightBasedOnTVSortedContent] + [self breatherRoomForChainTemplateScrollView];
    
    if (svContentHeight < self.mainContainer.frame.size.height){
        svContentHeight = self.mainContainer.frame.size.height;
    }
    
    return  CGSizeMake(self.mainContainer.frame.size.width, svContentHeight);
    
}

- (CGFloat)breatherRoomForChainTemplateScrollView{
    
    [self.view layoutSubviews];
    
    CGFloat bottomControlsHeight =  self.mainContainer.frame.size.height - self.arrowControlButton.frame.origin.y;
    CGFloat extraSpace = 8;
    
    return bottomControlsHeight + extraSpace;
    
}


- (int)dateControlObjectIndexForDate:(NSDate *)date{
    
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier: NSCalendarIdentifierGregorian];
    NSInteger monthAsInt = [calendar component: NSCalendarUnitMonth
                                      fromDate: date];
    
    return (int)monthAsInt - 1;
    
}


- (CGFloat)totalTableViewHeightBasedOnTVSortedContent{
    
    // based on the array of chain templates found in tvSortedContent, calculate the total table view height
    
    NSInteger iterationLimit; // based on the count of objects in tvSortedContent, the amount of cells presented by the table view will vary
    
    if (self.tvSortedContent.count == 0){
        
        iterationLimit = 1;
        
    } else{
        
        iterationLimit = self.tvSortedContent.count;
        
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


- (void)removeActivityIndicatorIfExists{
    
    if (self.activeActivityIndicator){
        
        [self.activeActivityIndicator stopAnimating];
        [self.activeActivityIndicator removeFromSuperview];
        self.activeActivityIndicator = nil;
        
        
    }
    
}


#pragma mark - Title Labels Describing Content

- (void)updateAllTitleLabelsForNewContent{
    
    [self updateTitleLabelCorrespondingToActiveTVDate];
    [self updateNumberOfRecordsTitleLabel];
    
}

- (void)updateTitleLabelCorrespondingToActiveTVDate{
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"MMM yyyy";
    self.monthYearTitleLabel.text = [df stringFromDate: self.tvActiveDate];
    
}

- (void)updateNumberOfRecordsTitleLabel{
    
    NSString *recordsWord = self.tvSortedContent.count == 1 ? @"Record" : @"Records";
    
    NSString *text = [NSString stringWithFormat: @"%d %@",
                      (int)self.tvSortedContent.count,
                      recordsWord];
    self.numberOfRecordsLabel.text = text;
    
}


#pragma mark - Content Sorting and Grouping


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



#pragma mark - Content Sorting and Grouping Helper Methods


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



#pragma mark - Core Data

- (NSFetchRequest *)chainTemplateFetchRequest{

    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName: @"ChainTemplate"];
    
    NSSortDescriptor *nameSort = [NSSortDescriptor sortDescriptorWithKey: @"name"
                                                               ascending: YES];
    
    [request setSortDescriptors: @[nameSort]];
    
    // predicate
    // the showInRoutineList property determines if a chain should appear in the routine list
    
    NSPredicate *showInRoutineListPred = [NSPredicate predicateWithFormat: @"showInRoutineList == YES"];
    [request setPredicate: showInRoutineListPred];
    
    return request;
    
}


- (void)configureCoreDataNotifications{
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(coreDataUpdateRequiredForRoutineSelection)
                                                 name: NSManagedObjectContextDidSaveNotification
                                               object: [[CoreDataController singleton] moc]];
    
}


- (void)coreDataUpdateRequiredForRoutineSelection{
    
    _coreDataUpdateRequired = YES;
    
}






#pragma mark - Date Controls

- (void)createAndShowDateControlsForDate:(NSDate *)date{
    
    self.dcActiveDate = date;
    NSMutableArray<NSMutableArray<TJBChainTemplate *> *> *initialRefArray = [self annualSortedContentForReferenceDate: date];
    self.dcSortedContent = initialRefArray;
    [self configureDateControlsBasedOnDCActiveDate];
    
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
    
    // it is arbitrary what day in the year the dcActiveDate represents
    // I set the month and day to 1 here as a convention
    
    dateComps.year += yearDelta;
    [dateComps setDay: 1];
    [dateComps setMonth: 1];
    self.dcActiveDate = [calendar dateFromComponents: dateComps];
    
    // source array and date control objects
    
    self.dcSortedContent = [self annualSortedContentForReferenceDate: self.dcActiveDate];
    
    [self configureDateControlsBasedOnDCActiveDate];
    
}


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

#pragma mark - Date Controls Helper Methods

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

//- (void)toggleButtonsToOnStateWithViewHistoryEnabled:(BOOL)viewHistoryEnabled{
//    
////    NSArray *buttons = @[self.launchButton];
////    
////    for (UIButton *b in buttons){
////        
////        b.enabled = YES;
////        b.layer.opacity = 1.0;
////        
////    }
////    
////    if (viewHistoryEnabled){
////        
////        self.previousMarkButton.enabled = YES;
////        self.previousMarkButton.layer.opacity = 1.0;
////        
////    }
//    
//}
//
//- (void)toggleButtonsToOffState{
//    
////    NSArray *buttons = @[self.launchButton,
////                         self.previousMarkButton];
////    
////    for (UIButton *b in buttons){
////        
////        b.enabled = NO;
////        b.layer.opacity = .4;
////        
////    }
//    
//}


#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

//    int reversedIndex = 11 - [self.selectedDateObjectIndex intValue];
    
    NSInteger rowCount = self.tvSortedContent.count;
    
    if (rowCount == 0){
        
        return 1;
        
    } else{
        
        return rowCount;
        
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
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
        
        TJBRealizedChainCell *cell = [self.activeTableView dequeueReusableCellWithIdentifier: @"TJBRealizedChainCell"];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.layer.borderColor = [[TJBAestheticsController singleton] paleLightBlueColor].CGColor;
        
        [cell clearExistingEntries];
        
        NSInteger adjustedRowIndex = indexPath.row ;
        
        TJBChainTemplate *chainTemplate = self.tvSortedContent[adjustedRowIndex];
        
        BOOL sortByDateLastExecuted = self.sortBySegmentedControl.selectedSegmentIndex == 1;
        
        NSDate *date;
        
        if (sortByDateLastExecuted){
            
            date = [self largestRealizeChainDateInReferenceYearForChainTemplate: chainTemplate
                                                                  referenceDate: self.tvActiveDate];
            
        } else{
            
            date = chainTemplate.dateCreated;
            
        }
        
//        [cell configureWithContentObject: chainTemplate
//                                cellType: ChainTemplateAdvCell
//                            dateTimeType: TJBDayInYear
//                             titleNumber: @(indexPath.row + 1)];
        
        TJBChainTemplateSortingType sortingType = self.sortBySegmentedControl.selectedSegmentIndex == 0 ? TJBChainTemplateByDateCreated : TJBChainTemplateByDateLastExecuted;
        
        [cell configureChainTemplateCellWithChainTemplate: chainTemplate
                                             dateTimeType: TJBDayInYear
                                              titleNumber: @(indexPath.row + 1)
                                              sortingType: sortingType];
        
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

#pragma mark - <UITableViewDelegate>

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.tvSortedContent.count > 0) {
        
        return YES;
        
    } else{
        
        return NO;
        
    }

    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //// change the background color of the selected chain template and change the control state of the buttons to activate them.  Store the selected chain and the index path of the selected row
    
    // deal with unhighlighting

    TJBRealizedChainCell *lastSelectedCell = [tableView cellForRowAtIndexPath: self.lastSelectedIndexPath];
    
    lastSelectedCell.backgroundColor = [UIColor clearColor];
    lastSelectedCell.layer.borderWidth = 0.0;
    
    self.lastSelectedIndexPath = indexPath;
    
    // highlight the new cell
    
    TJBChainTemplate *chainTemplate = self.tvSortedContent[indexPath.row];
    self.selectedChainTemplate = chainTemplate;
    
    // add blue border to selected cell
    
    TJBRealizedChainCell *selectedCell = [tableView cellForRowAtIndexPath: indexPath];
    
    selectedCell.backgroundColor = [UIColor clearColor];
    
    selectedCell.layer.borderWidth = 4.0;
    
    // controls state
    
    [self configureToolbarButtonsAccordingToActiveState];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self.view layoutSubviews];
    
    NSInteger chainCount = self.tvSortedContent.count;
    
    if (chainCount == 0){
        
        return self.mainContainer.frame.size.height - [self breatherRoomForChainTemplateScrollView];
        
    } else{
        
        TJBChainTemplate *chainTemplate = self.tvSortedContent[indexPath.row];
        
        return [TJBRealizedChainCell suggestedCellHeightForChainTemplate: chainTemplate];
        
    }
    
    
}

#pragma mark - View History


- (IBAction)didPressHistoryButton:(id)sender{
    
    // only attempt to present the VC if a chain template has been selected
    
    if (_viewingChainHistory == NO){
        
        // will need to show an activity indicator while loading the history table view because it could have enough cells to require a significant amount of loading time
        
        [self showActivityIndicator];
        
        [self giveControlsDisabledConfiguration];
        
        // the chain history table view is handled by a separate controller. I simply add it to a scroll view here and designate it as a a child view controller
        // this task must be completed after a short delay to allow the view to draw the activity indicator
        
        dispatch_async(dispatch_get_main_queue(), ^{
            
            [self showChainHistoryForSelectedChainAndUpdateStateVariables];
            [self showViewHistoryReturnButton];
            [self configureTitleLabelsAccordingToRoutineHistory];
            
        });
        
    }
    
}

- (void)didPressHistoryReturnButton{

        
    // show activity indicator
    
    [self showActivityIndicator];
    
    // queue the uploading of the new table to allow the view to redraw itself
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self showChainOptionsForCurrentTVActiveDateAndUpdateStateVariables];
        [self hideViewHistoryReturnButton];
        [self configureToolbarButtonsAccordingToActiveState];
        [self unhideAllBottomControls];
        
    });
    
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
    
    
}

- (void)showChainHistoryForSelectedChainAndUpdateStateVariables{
    
    [self.view layoutSubviews];
    
    // get rid of all table views before adding current table view
    
    [self clearAllTableViewsAndDirectlyAssociatedObjects];
    [self hideAllBottomControls];
    
    // history table view
    
    TJBCompleteChainHistoryVC *chainHistoryVC = [[TJBCompleteChainHistoryVC alloc] initWithChainTemplate: self.selectedChainTemplate];
    self.chainHistoryVC = chainHistoryVC;
    
    CGFloat breatherRoom = historyReturnButtonBottomSpacing + historyReturnButtonHeight + 8;
    CGFloat contentHeight = [chainHistoryVC contentHeight]; // gets the total height of cells based on provided chain template
    CGFloat svHeight;
    
    if (contentHeight < self.mainContainer.frame.size.height - breatherRoom){
        
        svHeight = self.mainContainer.frame.size.width;

    } else{
        
        svHeight = contentHeight + breatherRoom;
        
    }
    
    // scroll view
    
    UIScrollView *sv = [[UIScrollView alloc] initWithFrame: self.mainContainer.bounds];
    self.chainHistoryScrollView = sv;
    
    CGRect rect = CGRectMake(0, 0, self.mainContainer.frame.size.width, contentHeight);
    chainHistoryVC.view.frame = rect;
    
    CGSize contentSize = CGSizeMake(self.mainContainer.frame.size.width, svHeight);
    sv.contentSize = contentSize;
    sv.bounces = YES;
    
    [sv addSubview: chainHistoryVC.view];
    
    // give the new vc's view the same rect as the current table view
    // must go through the necessary steps to add the chain history vc as a child view controller
    
    [self addChildViewController: chainHistoryVC];
    
    [self.mainContainer insertSubview: sv
                              atIndex: 0];
    
    [chainHistoryVC didMoveToParentViewController: self];
    
    // update state
    
    _viewingChainHistory = YES;
    
    // get rid of the activity indicator and old table view content. The content will be reloaded if it is later required
    
    [self removeActivityIndicatorIfExists];
    
    // only enable certain controls. Will force the user to press back to return to previous browsing mode
    
    self.backButton.enabled = YES;
    self.backButton.layer.opacity = 1.0;
    
}

#pragma mark - View History Helper Methods

- (void)configureTitleLabelsAccordingToRoutineHistory{
    
    self.routinesByLabel.text = @"Routine History";
    self.monthYearTitleLabel.text = @"";
    
    NSNumber *numberOfRoutines = @(self.selectedChainTemplate.realizedChains.count);
    NSString *recordsWord = [numberOfRoutines intValue] == 1 ? @"Record" : @"Records";
    self.numberOfRecordsLabel.text = [NSString stringWithFormat: @"%@ %@",
                                      [numberOfRoutines stringValue],
                                      recordsWord];
    
}

- (void)showViewHistoryReturnButton{
    
    if (!self.viewHistoryReturnButton){
        
        UIButton *vhrButton = [[UIButton alloc] init];
        self.viewHistoryReturnButton = vhrButton;
        
        [self configureViewHistoryReturnButtonAppearanceAndFunctionality];
        
        NSMutableDictionary *constraintMapping = [[NSMutableDictionary alloc] init];
        NSString *vhrButtonKey = @"viewHistoryReturnButton";
        [constraintMapping setObject: vhrButton
                              forKey: vhrButtonKey];
        
        [self.mainContainer insertSubview: vhrButton
                             aboveSubview: self.chainHistoryScrollView];
        
        vhrButton.translatesAutoresizingMaskIntoConstraints = NO;
    
        NSString *horzLayoutVFL = [NSString stringWithFormat: @"H:|-16-[%@]-16-|", vhrButtonKey];
        [self.mainContainer addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: horzLayoutVFL
                                                                                    options: 0
                                                                                    metrics: nil
                                                                                      views: constraintMapping]];
        
        NSString *vertLayoutVFL = [NSString stringWithFormat: @"V:[%@(==%f)]-%f-|",
                                   vhrButtonKey,
                                   historyReturnButtonHeight,
                                   historyReturnButtonBottomSpacing];
        [self.mainContainer addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: vertLayoutVFL
                                                                                    options: 0
                                                                                    metrics: nil
                                                                                      views: constraintMapping]];
        
        [vhrButton addTarget: self
                      action: @selector(didPressHistoryReturnButton)
            forControlEvents: UIControlEventTouchUpInside];
        
        
    }
    
    self.viewHistoryReturnButton.hidden = NO;
    
}

- (void)configureViewHistoryReturnButtonAppearanceAndFunctionality{
    
    self.viewHistoryReturnButton.backgroundColor = [UIColor grayColor];
    [self.viewHistoryReturnButton setTitleColor: [[TJBAestheticsController singleton] paleLightBlueColor]
                                       forState: UIControlStateNormal];
    self.viewHistoryReturnButton.titleLabel.font = [UIFont boldSystemFontOfSize: 20];
    [self.viewHistoryReturnButton setTitle: @"Back to List"
                                  forState: UIControlStateNormal];
    
    CALayer *vhrbLayer = self.viewHistoryReturnButton.layer;
    vhrbLayer.masksToBounds = YES;
    vhrbLayer.cornerRadius = 22;
    vhrbLayer.borderColor = [[TJBAestheticsController singleton] paleLightBlueColor].CGColor;
    vhrbLayer.borderWidth = 1.0;
    
    
}

- (void)hideViewHistoryReturnButton{
    
    self.viewHistoryReturnButton.hidden = YES;
    
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


- (IBAction)didPressLeftArrow:(id)sender{
    
    [self incrementDCACtiveYearWithIncrementDirectionForward: NO];
    
}

- (IBAction)didPressRightArrow:(id)sender{
    
    [self incrementDCACtiveYearWithIncrementDirectionForward: YES];
    
}

#pragma mark - Selections

- (void)configureSelectionAsNil{
    
    // get rid of the border on the last selected cell and change state variables for selection
    
    self.selectedChainTemplate = nil;
    
    if (self.lastSelectedIndexPath){
        
        TJBRealizedChainCell *cell = [self.activeTableView cellForRowAtIndexPath: self.lastSelectedIndexPath];
        cell.layer.borderWidth = 0.0;
        cell.backgroundColor = [UIColor clearColor];
        self.lastSelectedIndexPath = nil;
        
    }
    
}





#pragma mark - Controls Appearance / State

- (void)giveControlsDisabledConfiguration{
    
    self.backButton.enabled = NO;
    self.backButton.layer.opacity = .4;
    
    NSArray *arrows = @[self.leftArrowButton, self.rightArrowButton];
    for (UIButton *b in arrows){
        
        b.enabled = NO;
        b.layer.opacity = .4;
        
    }

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
    
    for (TJBSchemeSelectionDateComp *comp in self.dateControlObjects){
        
        [comp configureAsEnabled];
        
    }
    
}

- (void)configureToolbarButtonsAccordingToActiveState{
    
    NSArray *buttons = @[self.launchButton, self.deleteButton];
    
    for (UIBarButtonItem *bbi in buttons){
        
        if (self.lastSelectedIndexPath){
            
            [self giveToolbarButtonEnabledAppearance: bbi];
            
        } else{
            
            [self giveToolbarButtonDisabledAppearance: bbi];
            
        }
        
    }
    
    // must check whether the selected cell has any realized chains before showing the history button
    
    if (self.lastSelectedIndexPath){
        
        BOOL realizationsExist = self.selectedChainTemplate.realizedChains.count > 0;
        
        if (realizationsExist){
            
            [self giveToolbarButtonEnabledAppearance: self.historyButton];
            
        } else{
            
            [self giveToolbarButtonDisabledAppearance: self.historyButton];
            
        }
        
    } else{
        
        [self giveToolbarButtonDisabledAppearance: self.historyButton];
        
    }
    

    
}

- (void)giveToolbarButtonDisabledAppearance:(UIBarButtonItem *)bbi{
    
    bbi.tintColor = [UIColor grayColor];
    bbi.enabled = NO;
    
}


- (void)giveToolbarButtonEnabledAppearance:(UIBarButtonItem *)bbi{
    
    bbi.tintColor = [[TJBAestheticsController singleton] paleLightBlueColor];
    bbi.enabled = YES;
    
}

- (void)hideAllBottomControls{
    
    NSArray *views = @[self.toolbar, self.sortBySegmentedControl, self.sortByBottomLabel, self.arrowControlButton];
    for (UIView *v in views){
        
        v.hidden = YES;
        
    }
    
}

- (void)unhideAllBottomControls{
    
    NSArray *views = @[self.toolbar, self.sortBySegmentedControl, self.sortByBottomLabel, self.arrowControlButton];
    for (UIView *v in views){
        
        v.hidden = NO;
        
    }
    
}

#pragma mark - Toolbar Animation


- (IBAction)didPressArrowControlButton:(id)sender{
    
    if (_toolbarState == TJBToolbarHidden){
        
        [self animateToolbarOnscreen];
      
        [self.arrowControlButton setImage: [UIImage imageNamed: @"doubleDownArrowBlue32"]
                                 forState: UIControlStateNormal];
        
        _toolbarState = TJBToolBarNotHidden;
        
    } else if (_toolbarState == TJBToolBarNotHidden){
        
        [self animateToolbarOffscreen];
        
        [self.arrowControlButton setImage: [UIImage imageNamed: @"doubleUpArrowBlue32"]
                                 forState: UIControlStateNormal];
        
        _toolbarState = TJBToolbarHidden;
        
    }
    
    
}

- (void)animateToolbarOffscreen{
    

    [UIView animateWithDuration: toolbarSlidingAnimationTime
                     animations: ^{
                         
                         self.arrowControlButton.enabled = NO;
    
                         CGFloat vertAnimationDist = self.mainContainer.frame.size.height - self.toolbar.frame.origin.y;
                         
                         NSArray *viewsToTranslate = @[self.arrowControlButton, self.toolbar, self.sortByBottomLabel, self.sortBySegmentedControl];
                         for (UIView *v in viewsToTranslate){
                             
                             v.frame = [self rectByTranslatingRect: v.frame
                                                           originX: 0
                                                           originY: vertAnimationDist];
                             
                         }
                         
                         self.sortByBottomLabel.hidden = YES;
                         
                     }
                     completion: ^(BOOL finished){
                         
                         self.arrowControlButton.enabled = YES;
    
                         CGFloat toolbarHeight = self.toolbar.frame.size.height;
                         self.toolbarBottomSpacingConstr.constant = -1 * toolbarHeight;
                         
                         self.activeScrollView.contentSize = [self scrollViewContentSize];
    
                     }];
    
}


- (void)animateToolbarOnscreen{
    
    [UIView animateWithDuration: toolbarSlidingAnimationTime
                     animations: ^{
                         
                         self.arrowControlButton.enabled = NO;
                         
                         CGFloat vertAnimationDist = self.toolbar.frame.size.height + 8;
                         
                         NSArray *viewsToTranslate = @[self.arrowControlButton, self.toolbar, self.sortByBottomLabel, self.sortBySegmentedControl];
                         for (UIView *v in viewsToTranslate){
                             
                             v.frame = [self rectByTranslatingRect: v.frame
                                                           originX: 0
                                                           originY: -1 * vertAnimationDist];
                             
                         }
                         
                         self.sortByBottomLabel.hidden = NO;
                         
                     }
                     completion: ^(BOOL finished){
                         
                         self.arrowControlButton.enabled = YES;
                         
                         self.toolbarBottomSpacingConstr.constant = 8;
                         
                         self.activeScrollView.contentSize = [self scrollViewContentSize];
                         
                     }];
    

    
    
}


- (CGRect)rectByTranslatingRect:(CGRect)initialRect originX:(CGFloat)originX originY:(CGFloat)originY{
    
    return CGRectMake(initialRect.origin.x + originX, initialRect.origin.y + originY, initialRect.size.width, initialRect.size.height);
    
}


#pragma mark - Toolbar Actions





- (IBAction)didPressLaunchButton:(id)sender {
        
    if (self.selectedChainTemplate){
        
//        TJBActiveRoutineGuidanceVC *vc1 = [[TJBActiveRoutineGuidanceVC alloc] initFreshRoutineWithChainTemplate: self.selectedChainTemplate];
//        vc1.tabBarItem.title = @"Active";
//        vc1.tabBarItem.image = [UIImage imageNamed: @"activeLift"];
//        
//        TJBWorkoutNavigationHub *vc3 = [[TJBWorkoutNavigationHub alloc] initWithHomeButton: NO
//                                                                    advancedControlsActive: NO];
//        vc3.tabBarItem.title = @"Workout Log";
//        vc3.tabBarItem.image = [UIImage imageNamed: @"workoutLog"];
//        
////        TJBCircuitReferenceContainerVC *vc2 = [[TJBCircuitReferenceContainerVC alloc] initWithRealizedChain: vc1.realizedChain];
////        vc2.tabBarItem.title = @"Progress";
////        vc2.tabBarItem.image = [UIImage imageNamed: @"routineProgress"];
////        
//        // tab bar
//        
//        UITabBarController *tbc = [[UITabBarController alloc] init];
//        [tbc setViewControllers: @[vc1, vc3]];
//        tbc.tabBar.translucent = NO;
//        tbc.tabBar.barTintColor = [UIColor darkGrayColor];
//        tbc.tabBar.tintColor = [[TJBAestheticsController singleton] paleLightBlueColor];
        
        TJBActiveGuidanceTBC *activeGuidanceTBC = [[TJBActiveGuidanceTBC alloc] initWithChainTemplate: self.selectedChainTemplate];
        
        [self presentViewController: activeGuidanceTBC
                           animated: YES
                         completion: nil];
        
    } else{
        
        NSLog(@"no chain template selected");
        
    }
    
}



- (IBAction)didPressNewRoutine:(id)sender{
    
    __weak NewOrExistinigCircuitVC *weakSelf = self;
    
    TJBVoidCallback callback = ^{
        
        [weakSelf dismissViewControllerAnimated: YES
                                     completion: nil];
        
        [weakSelf selectDateControlCorrespondingToDate: [NSDate date]];
        
    };
    
    TJBCircuitTemplateContainerVC *ctcVC = [[TJBCircuitTemplateContainerVC alloc] initWithCallback: callback];
    
    [self presentViewController: ctcVC
                       animated: YES
                     completion: nil];
    
}


#pragma mark - Delete Actions

- (IBAction)didPressDeleteButton:(id)sender{
    
    // alert controller
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"Proceed with Delete?"
                                                                   message: @"This action is permanent. Submissions cannot be ressurected following deletion"
                                                            preferredStyle: UIAlertControllerStyleAlert];
    
    __weak NewOrExistinigCircuitVC *weakSelf = self;
    
    // confirm action
    
    void (^confirmAction)(UIAlertAction *) = ^(UIAlertAction *action){
        
        [weakSelf deleteCurrentlySelectedCell];
        
    };
    
    UIAlertAction *confirm = [UIAlertAction actionWithTitle: @"Delete"
                                                      style: UIAlertActionStyleDestructive
                                                    handler: confirmAction];
    
    // cancel action
    
    void (^cancelAction)(UIAlertAction *) = ^(UIAlertAction *action){
        
        return;
        
    };
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle: @"Cancel"
                                                     style: UIAlertActionStyleCancel
                                                   handler: cancelAction];
    
    [alert addAction: cancel];
    [alert addAction: confirm];
    
    [self presentViewController: alert
                       animated: YES
                     completion: nil];
    
    
    
    
}

- (void)deleteCurrentlySelectedCell{
    
    // if the the chain template has realizations, must keep it around but change its showInRoutineListProperty
    // otherwise, simply delete the chain template
    
    [self.activeTableView beginUpdates];
    
    [self.activeTableView deleteRowsAtIndexPaths: @[self.lastSelectedIndexPath]
                          withRowAnimation: UITableViewRowAnimationLeft];
    
    [self.tvSortedContent removeObject: self.selectedChainTemplate];
    
    int dateControlObjectIndex = [self dateControlObjectIndexForDate: self.tvActiveDate];
    int reversedIndex = 11 - dateControlObjectIndex; // must use a reversed index because December is in the 0th position of dcSortedContent
    [self.dcSortedContent[reversedIndex] removeObject: self.selectedChainTemplate];
    
    if (self.tvSortedContent.count == 0){
        
        [self.activeTableView insertRowsAtIndexPaths: @[self.lastSelectedIndexPath]
                                    withRowAnimation: UITableViewRowAnimationRight];
        
        [self.dateControlObjects[[self.selectedDateObjectIndex intValue]] deleteCircle];
        
    }

    
    [self deleteChainTemplate: self.selectedChainTemplate];
    
    self.selectedChainTemplate = nil;
    
    [self.activeTableView endUpdates];
    
    [self updateAllTitleLabelsForNewContent];
    
    
}

- (void)deleteChainTemplate:(TJBChainTemplate *)ct{
    
        if (ct.realizedChains.count > 0){
    
            ct.showInRoutineList = NO;
            
            [[CoreDataController singleton] saveContext];
    
        } else{
    
            [[CoreDataController singleton] deleteChainTemplate: self.selectedChainTemplate];
            
        }
    
}




#pragma mark - Segmented Control 

- (void)segmentedControlValueDidChange{
    
    // date controls must be reloaded because sorting change has significant changes on what month chain templates are associated with
    
    [self createAndShowDateControlsForDate: self.tvActiveDate];
    
    [self selectDateControlCorrespondingToDate: self.tvActiveDate];
    
}



@end






























