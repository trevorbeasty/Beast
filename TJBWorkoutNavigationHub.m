//
//  TJBWorkoutNavigationHub.m
//  Beast
//
//  Created by Trevor Beasty on 12/12/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import "TJBWorkoutNavigationHub.h"

// aesthetics

#import "TJBAestheticsController.h"

// circle dates

#import "TJBCircleDateVC.h"

// core data

#import "CoreDataController.h"

// table view cells

#import "TJBRealizedChainCell.h"
#import "TJBNoDataCell.h"


// presented VC's

#import "TJBLiftOptionsVC.h"
#import "TJBCircuitReferenceContainerVC.h"

// cell preloading

#import "TJBCellFetchingOperation.h"


// state

typedef enum{
    TJBToolbarHidden,
    TJBToolbarNotHidden
}TJBToolbarState;




@interface TJBWorkoutNavigationHub () <UITableViewDataSource, UITableViewDelegate, UIViewControllerRestoration>

{
    // state
    
    int _activeSelectionIndex;
    BOOL _includesHomeButton;
    BOOL _displayedContentNeedsUpdating; // used to indicate that core data has saved during this controller's lifetime while a different tab of the tab bar controller was selected
    BOOL _fetchedObjectsNeedUpdating; // determines if the masterList needs to merge changes from the persistent store
    TJBToolbarState _toolbarState;
    
    BOOL _advancedControlsActive;
    
}

// IBOutlet

@property (weak, nonatomic) UITableView *tableView;
@property (weak, nonatomic) UIScrollView *tableViewScrollContainer;
@property (weak, nonatomic) IBOutlet UIButton *leftArrowButton;
@property (weak, nonatomic) IBOutlet UIButton *rightArrowButton;
@property (weak, nonatomic) IBOutlet UILabel *monthTitle;
@property (weak, nonatomic) IBOutlet UIScrollView *dateScrollView;
@property (weak, nonatomic) IBOutlet UIButton *homeButton;
@property (weak, nonatomic) IBOutlet UIView *shadowContainer;
@property (weak, nonatomic) IBOutlet UIView *titleBarContainer;
@property (weak, nonatomic) IBOutlet UILabel *numberOfEntriesLabel;

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *jumpToLastButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *todayButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;

@property (weak, nonatomic) IBOutlet UILabel *myWorkoutLogLabel;
@property (weak, nonatomic) IBOutlet UILabel *activeDateLabel;
@property (weak, nonatomic) IBOutlet UIButton *toolbarControlArrow;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolbarBottomToContainerConstr;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *leftArrowLeadingSpaceConstr;



// IBAction

- (IBAction)didPressLeftArrow:(id)sender;
- (IBAction)didPressRightArrow:(id)sender;
- (IBAction)didPressHomeButton:(id)sender;

// toolbar actions

- (IBAction)didPressToolbarControlArrow:(id)sender;

- (IBAction)didPressJumpToLast:(id)sender;
- (IBAction)didPressToday:(id)sender;
- (IBAction)didPressDelete:(id)sender;
- (IBAction)didPressEdit:(id)sender;


// circle dates

@property (strong) UIStackView *dateStackView;
@property (strong) NSMutableArray <TJBCircleDateVC *> *circleDateChildren;

// state

@property (strong) NSDate *workoutLogActiveDay;
@property (strong) NSDate *dateControlActiveDate;
@property (strong) NSNumber *selectedDateButtonIndex;
@property (strong) UIActivityIndicatorView *activityIndicatorView;
@property (strong) NSNumber *scrollPositionForUpdate;

@property (strong) NSIndexPath *currentlySelectedPath;

@property (strong) NSDate *lastSelectedWorkoutLogDate;
@property (strong) NSDate *currentlySelectedWorkoutLogDate;

// core data

@property (strong) NSMutableArray *masterList;
@property (strong) NSMutableArray *dailyList;

@property (strong) NSMutableArray *activeTableViewCells;

@end



#pragma mark - Constants

// date control specifications

static const CGFloat buttonWidth = 60.0;
static const CGFloat buttonSpacing = 0.0;
static const CGFloat buttonHeight = 55.0;


// animation

static const CGFloat toolbarToBottomSpacing = 8;
static const CGFloat toolbarAnimationTime = .2;

// content loading

static NSTimeInterval const contentLoadingSmoothingDelay = .2;

typedef void (^AnimationBlock)(void);
typedef void (^AnimationCompletionBlock)(BOOL);

typedef NSArray<TJBRealizedSet *> *TJBRealizedSetGrouping;

static const NSTimeInterval _maxDateControlAnimationTime = 2.0;

// restoration

static NSString * const restorationID = @"TJBWorkoutNavigationHub";
static NSString * const workoutLogActiveDateKey = @"workoutLogActiveDateForRestore";
static NSString * const dateControlActiveDateKey = @"dateControlActiveDateForRestore";
static NSString * const includeHomeButtonKey = @"includeHomeButtonForRestore";
static NSString * const includeAdvancedControlsKey = @"includeAdvancedControlsForRestore";




@implementation TJBWorkoutNavigationHub


#pragma mark - Instantiation


- (instancetype)initWithHomeButton:(BOOL)includeHomeButton advancedControlsActive:(BOOL)advancedControlsActive{
    
    NSDate *today = [NSDate date];
    
    return [self initWithHomeButton: includeHomeButton
             advancedControlsActive: advancedControlsActive
                     workoutLogDate: today
                    dateControlDate: today];
    
}

- (instancetype)initWithHomeButton:(BOOL)includeHomeButton advancedControlsActive:(BOOL)advancedControlsActive workoutLogDate:(NSDate *)workoutLogDate dateControlDate:(NSDate *)dateControlDate{
    
    self = [super init];
    
    // state
    
    _toolbarState = TJBToolbarNotHidden;
    _displayedContentNeedsUpdating = YES; // when this property is YES, all model object will be derived and all view objects created after the view appears
    _fetchedObjectsNeedUpdating = NO;
    
    [self configureCoreDataUpdateNotification]; // core data did save notification
    [self configureRestorationProperties]; // restoration
    
    // controls
    
    _includesHomeButton = includeHomeButton;
    _advancedControlsActive = advancedControlsActive;
    
    // workout log active date - the current day is initially shown when this controller first appears
    
    self.workoutLogActiveDay = workoutLogDate;
    self.dateControlActiveDate = dateControlDate;
    
    return self;
    
}


#pragma mark - Init Helper Methods

- (void)configureRestorationProperties{
    
    self.restorationClass = [TJBWorkoutNavigationHub class];
    self.restorationIdentifier = restorationID;
    
}


#pragma mark - Core Data Fetch Requests

- (NSFetchRequest *)realizedSetRequest{
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName: @"RealizedSet"];
    
    NSSortDescriptor *dateSort = [NSSortDescriptor sortDescriptorWithKey: @"submissionTime"
                                                               ascending: NO];
    [request setSortDescriptors: @[dateSort]];
    
    NSPredicate *standaloneSetPredicate = [NSPredicate predicateWithFormat: @"isStandaloneSet = YES"]; // only retrieve standalone sets. Realized chains are retrieved separately
    request.predicate = standaloneSetPredicate;
    
    return  request;
    
}


- (NSFetchRequest *)realizedChainRequest{
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName: @"RealizedChain"];
    
    NSSortDescriptor *dateSort = [NSSortDescriptor sortDescriptorWithKey: @"dateCreated"
                                                               ascending: NO];
    
    [request setSortDescriptors: @[dateSort]];
    
    return request;
    
}

#pragma mark - Core Data Object Fetching and Structuring

- (void)fetchManagedObjectsAndDeriveMasterList{
    
    // the master list holds model objects for all dates, not just the current month
    
    NSManagedObjectContext *moc = [[CoreDataController singleton] moc];
    
    // only standalone sets are fetched, so that no sets are duplicated
    // this is achieved through use of a predicate in the realizedSetRequest
    
    NSError *error;
    NSArray *fetchedSets = [moc executeFetchRequest: [self realizedSetRequest]
                                              error: &error];
    NSArray *fetchedChains = [moc executeFetchRequest: [self realizedChainRequest]
                                                error: &error];
    
    NSMutableArray *interimArray1 = [[NSMutableArray alloc] init];
    [interimArray1 addObjectsFromArray: fetchedSets];
    [interimArray1 addObjectsFromArray: fetchedChains];
    
    [self sortModelObjectsByDateProperty: interimArray1];
    
    // adjacent TJBRealizedSets of the same day are grouped together because they are displayed collectively in a table view cell
    
    self.masterList = [[CoreDataController singleton] groupModelObjects: interimArray1];
    

    
}

- (void)deriveDailyList{
    
    //// creats the dailyList from the masterList based on the active date and updates the table view
    
    self.dailyList = [[NSMutableArray alloc] init];
    
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier: NSCalendarIdentifierGregorian];
    
    for (NSObject *object in self.masterList){
        
        NSDate *objectDate = [self dateForRecordObject: object];
        
        BOOL recordIsForActiveDate = [calendar isDate: objectDate
                                      inSameDayAsDate: self.workoutLogActiveDay];
        
        if (recordIsForActiveDate){
            
            [self.dailyList addObject: object];
            
        }
        
    }
    
}

#pragma mark - Model Object Helper Methods

- (void)sortModelObjectsByDateProperty:(NSMutableArray *)modelObjects{
    
    [modelObjects sortUsingComparator: ^(id obj1, id obj2){
        
        NSDate *obj1Date = [self dateForModelObject: obj1];
        NSDate *obj2Date = [self dateForModelObject: obj2];

        // return the appropriate NSComparisonResult
        
        BOOL obj2LaterThanObj1 = [obj2Date timeIntervalSinceDate: obj1Date] > 0;
        
        if (obj2LaterThanObj1){
            
            return NSOrderedAscending;
            
        } else {
            
            return  NSOrderedDescending;
            
        }
    }];
    
}

- (NSDate *)dateForModelObject:(id)modelObject{
    
    if ([modelObject isKindOfClass: [TJBRealizedSet class]]){
        
        TJBRealizedSet *rs = (TJBRealizedSet *)modelObject;
        return rs.submissionTime;
        
        
    } else if([modelObject isKindOfClass: [TJBRealizedChain class]]){
        
        TJBRealizedChain *rc = (TJBRealizedChain *)modelObject;
        return rc.dateCreated;
        
    } else{
        
        return nil;
        
    }
    
}



- (NSDate *)dayBeginDateForObject:(id)object{
    
    //// evaluates whether the object is a realized set or realized chain and returns the corresponding day begin date.  For realized sets this in the 'beginDate' and for realized chains this is the 'dateCreated'.  Date created is used as opposed to set begin dates because the former is always going to exist while the latter may not
    
    BOOL objectIsRealizedSet = [object isKindOfClass: [TJBRealizedSet class]];
    
    if (objectIsRealizedSet){
        
        TJBRealizedSet *realizedSet = object;
        
        return [[NSCalendar calendarWithIdentifier: NSCalendarIdentifierGregorian] startOfDayForDate: realizedSet.submissionTime];
        
    } else{
        
        TJBRealizedChain *realizedChain = object;
        
        return [[NSCalendar calendarWithIdentifier: NSCalendarIdentifierGregorian] startOfDayForDate: realizedChain.dateCreated];
        
    }
    
}

- (BOOL)recordExistsForDate:(NSDate *)date{
    
    NSInteger limit = self.masterList.count;
    
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier: NSCalendarIdentifierGregorian];
    
    for (int i = 0; i < limit; i++){
        
        NSDate *exerciseDate = [self dateForRecordObject: self.masterList[i]];
        
        if ([calendar isDate:date inSameDayAsDate:exerciseDate]){
            
            return YES;
            
        }
        
    }
    
    return NO;
    
}

- (NSDate *)dateForRecordObject:(id)object{
    
    //// evaluates whether the object is a realized set or realized chain and returns the corresponding day begin date.  For realized sets this in the 'beginDate' and for realized chains this is the 'dateCreated'.  Date created is used as opposed to set begin dates because the former is always going to exist while the latter may not
    
    BOOL objectIsRealizedSet = [object isKindOfClass: [TJBRealizedSet class]];
    BOOL objectIsRealizedChain = [object isKindOfClass: [TJBRealizedChain class]];
    
    if (objectIsRealizedSet){
        
        TJBRealizedSet *realizedSet = object;
        
        return realizedSet.submissionTime;
        
    } else if (objectIsRealizedChain){
        
        TJBRealizedChain *realizedChain = object;
        
        return realizedChain.dateCreated;
        
    } else{
        
        // if it is not a realized set or realized chain, it must be a TJBRealizedSetCollection
        // simply return the end date of the first realized set
        // I believe they are in asending order (by date), so I am returning the end date of the earliest set
        
        TJBRealizedSetGrouping rsc = object;
        
        return rsc[0].submissionTime;
        
    }
    
}

#pragma mark - View Life Cycle

- (void)viewWillAppear:(BOOL)animated{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken,  ^{
        
        [self configureControlsAccordingToState];
        
    });
    
    if (_displayedContentNeedsUpdating){
        
        self.toolbar.hidden = YES;
        self.toolbarControlArrow.hidden = YES;
        
        [self disableControlsAndGiveInactiveAppearance];
        
    }
    
}


- (void)viewDidAppear:(BOOL)animated{
    
    if (_displayedContentNeedsUpdating == YES){
        
        // activity indicator
        
        [self showActivityIndicator];
        
        // the following methods are called asynchronously so that the view draws and shows the activity indicator while all tasks execute
        
        dispatch_async(dispatch_get_main_queue(),  ^{
            
            if (!self.masterList || _fetchedObjectsNeedUpdating == YES){
                
                [self fetchManagedObjectsAndDeriveMasterList];
                
            }
            
            
            [self deriveAndPresentContentAndRemoveActivityIndicatorForWorkoutLogDate: self.workoutLogActiveDay
                                                                     dateControlDate: self.dateControlActiveDate
                                                         shouldAnimateDateControlBar: YES];
            
            _displayedContentNeedsUpdating = NO;
            _fetchedObjectsNeedUpdating = NO;
            
        });
        
        return;
        
    }
    
}




- (void)viewDidLoad{
    
    [self configureViewAesthetics];
    
    [self configureToolBarAndBarButtons];
    
    return;
    
}




#pragma mark - View Helper Methods

- (void)configureControlsAccordingToState{
    
    [self configureOptionalHomeButton];
    
    if (_includesHomeButton == NO){
        
        [self modifyLeftDateControlArrowConstraint];
        
    }
    
}

- (void)modifyLeftDateControlArrowConstraint{
    
    [self.titleBarContainer removeConstraint: self.leftArrowLeadingSpaceConstr];
    
    NSMutableDictionary *constraintMapping = [[NSMutableDictionary alloc] init];
    NSString *leftArrowKey = @"leftDateControlArrow";
    [constraintMapping setObject: self.leftArrowButton
                          forKey: leftArrowKey];
    
    NSString *arrowLeadingSpaceConstr = [NSString stringWithFormat: @"H:|-0-[%@]", leftArrowKey];
    
    [self.titleBarContainer addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: arrowLeadingSpaceConstr
                                                                                    options: 0
                                                                                    metrics: nil
                                                                                      views: constraintMapping]];
    
}

- (void)configureOptionalHomeButton{
    
    if (_includesHomeButton){
        
        self.homeButton.backgroundColor = [UIColor clearColor];
        self.homeButton.titleLabel.font = [UIFont boldSystemFontOfSize: 15.0];
        [self.homeButton setTitleColor: [[TJBAestheticsController singleton] blueButtonColor]
                              forState: UIControlStateNormal];
        
        
    } else{
        
        self.homeButton.enabled = NO;
        self.homeButton.hidden = YES;
        
    }
    
}


- (void)configureTableView{
    
    UINib *realizedChainNib = [UINib nibWithNibName: @"TJBRealizedChainCell"
                                             bundle: nil];
    
    [self.tableView registerNib: realizedChainNib
         forCellReuseIdentifier: @"TJBRealizedChainCell"];
    
    UINib *noDataCell = [UINib nibWithNibName: @"TJBNoDataCell"
                                       bundle: nil];
    
    [self.tableView registerNib: noDataCell
         forCellReuseIdentifier: @"TJBNoDataCell"];
    
}






- (void)configureViewAesthetics{

    // meta view
    
    self.view.backgroundColor = [UIColor blackColor];
    
    // title bar container
    
    self.titleBarContainer.backgroundColor = [UIColor darkGrayColor];
    
    // scroll view
    
    self.dateScrollView.backgroundColor = [UIColor darkGrayColor];
 
    self.monthTitle.backgroundColor = [UIColor clearColor];
    self.monthTitle.textColor = [UIColor whiteColor];
    self.monthTitle.font = [UIFont boldSystemFontOfSize: 20];
    
    NSArray *arrowButtons = @[self.leftArrowButton, self.rightArrowButton];
    for (UIButton *button in arrowButtons){
        
        button.backgroundColor = [UIColor clearColor];
        
    }
    
    // workout log and active date label
    
    NSArray *titleLabels = @[self.myWorkoutLogLabel, self.activeDateLabel, self.numberOfEntriesLabel];
    for (UILabel *lab in titleLabels){
        
        lab.backgroundColor = [UIColor grayColor];
        lab.font = [UIFont boldSystemFontOfSize: 15];
        lab.textColor = [UIColor whiteColor];
        
    }
    
    // toolbar control arrow
    
    self.toolbarControlArrow.backgroundColor = [UIColor grayColor];
    CALayer *tcaLayer = self.toolbarControlArrow.layer;
    tcaLayer.masksToBounds = YES;
    tcaLayer.cornerRadius = 22;
    tcaLayer.borderColor = [[TJBAestheticsController singleton] paleLightBlueColor].CGColor;
    tcaLayer.borderWidth = 1;

    
}

- (NSString *)workoutLogTitleText{
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"MMM d, yyyy";
    NSString *formattedDate = [df stringFromDate: self.workoutLogActiveDay];
    
    return  [NSString stringWithFormat: @"%@", formattedDate];
    
}

#pragma mark - View Calculations

- (CGFloat)toolBarHeightFromBottomOfScreen{
    
    [self.view layoutSubviews];
    
    return self.shadowContainer.frame.size.height - self.toolbar.frame.origin.y ;
    
}

#pragma mark - Master Workout Log and Date Controls Method

- (void)deriveAndPresentContentAndRemoveActivityIndicatorForWorkoutLogDate:(NSDate *)workoutLogDate dateControlDate:(NSDate *)dateControlDate shouldAnimateDateControlBar:(BOOL)shouldAnimate{
    
    [NSThread sleepForTimeInterval: contentLoadingSmoothingDelay];
    
    self.dateControlActiveDate = dateControlDate;
    self.workoutLogActiveDay = workoutLogDate;
    
    [self configureDateControlsAccordingToActiveDateControlDateAndSelectActiveDateControlDay: YES];
    
    [self updateActiveDateLabelWithDate: workoutLogDate];
    
    [self updateSelectionStateVariablesInResponseToDateDateObjectWithRepresentedDate: workoutLogDate];
    [self configureToolbarAppearanceAccordingToStateVariables];
    
    [self deriveDailyList];
    [self updateNumberOfEntriesLabel];
    [self deriveActiveCellsAndCreateTableView];
    [self.tableView reloadData];
    
    [self.activityIndicatorView stopAnimating];
    
    [self enableControlsAndGiveActiveAppearance];
    self.toolbar.hidden = NO;
    self.toolbarControlArrow.hidden = NO;
    
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier: NSCalendarIdentifierGregorian];
    BOOL workoutLogDateInDateControlMonth = [calendar isDate: workoutLogDate
                                                 equalToDate: dateControlDate
                                           toUnitGranularity: NSCalendarUnitMonth];

    if (shouldAnimate && workoutLogDateInDateControlMonth){
        
        [self configureInitialDateControlAnimationPosition];
        
        dispatch_async(dispatch_get_main_queue(),  ^{
            
            [self executeDateControlAnimation];
            
        });
        
    }
    
}


#pragma mark - Date Control Action Methods

- (void)clearTransitoryDateControlObjects{
    
    //// must clear the children view controller array as well as remove the stack view from the scroll view
    
    if (self.dateStackView){
        
        for (TJBCircleDateVC *vc in self.circleDateChildren){
            
            [vc willMoveToParentViewController: nil];
            [vc removeFromParentViewController];
            
        }
        
        [self.dateStackView removeFromSuperview];
        self.dateStackView = nil;
        
    }
    
    self.circleDateChildren = [[NSMutableArray alloc] init];
    
}





- (void)configureDateControlsAccordingToActiveDateControlDateAndSelectActiveDateControlDay:(BOOL)shouldSelectActiveDateControlDay{

    [self clearTransitoryDateControlObjects];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    
    // month title
    
    df.dateFormat = @"MMMM yyyy";
    NSString *monthTitle = [df stringFromDate: self.dateControlActiveDate];
    self.monthTitle.text = monthTitle;
    
    // stack view and child VC's
    // stack view dimensions.  Need to know number of days in month and define widths of contained buttons
    
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier: NSCalendarIdentifierGregorian];
    NSRange daysInCurrentMonth = [calendar rangeOfUnit: NSCalendarUnitDay
                                                inUnit: NSCalendarUnitMonth
                                               forDate: self.dateControlActiveDate];
    
    
    
    const CGFloat stackViewWidth = [self dateSVWidthGivenButtonSpecifications];
    CGRect stackViewRect = CGRectMake(0, 0, stackViewWidth, buttonHeight);
    
    // create the stack view with the proper dimensions and also set the content size of the scroll view
    
    UIStackView *stackView = [[UIStackView alloc] initWithFrame: stackViewRect];
    self.dateStackView = stackView;
    
    self.dateScrollView.contentSize = stackViewRect.size;
    [self.dateScrollView addSubview: stackView];
    
    // configure the stack view's layout properties
    
    stackView.alignment = UIStackViewAlignmentFill;
    stackView.distribution = UIStackViewDistributionFillEqually;
    stackView.spacing = buttonSpacing;
    
    // give the stack view it's content.  All items preceding the for loop are used in the for loop
    
    NSDateComponents *dateComps = [calendar components: (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
                                              fromDate: self.dateControlActiveDate];
    
    NSDate *iterativeDate;
    CGSize buttonSize = CGSizeMake(buttonWidth, buttonHeight);
    NSDate *today = [NSDate date];
    
    for (int i = 0; i < daysInCurrentMonth.length; i++){
        
        // must get the day of the week from the calendar. The day number is simply the iterator plus one
        
        [dateComps setDay: i + 1];
        iterativeDate = [calendar dateFromComponents: dateComps];
        
        df.dateFormat = @"E";
        NSString *dayTitle = [df stringFromDate: iterativeDate];
        
        df.dateFormat = @"d";
        
        // create the child vc - exactly what configuration the vc receives is dependent upon the iterative date
        
        BOOL iterativeDateGreaterThanToday = [iterativeDate timeIntervalSinceDate: today] > 0;
        BOOL isTheActiveDate = NO;
        
        if (shouldSelectActiveDateControlDay){
            
            isTheActiveDate = [calendar isDate: iterativeDate
                               inSameDayAsDate: self.workoutLogActiveDay];
            
            if (isTheActiveDate){
                
                self.selectedDateButtonIndex = [NSNumber numberWithInt: i];
                
            }
            
        }
        
        
        
        BOOL recordExistsForIterativeDate = [self recordExistsForDate: iterativeDate];
        
        TJBCircleDateVC *circleDateVC = [[TJBCircleDateVC alloc] initWithDayIndex: [NSNumber numberWithInt: i]
                                                                         dayTitle: dayTitle
                                                                             size: buttonSize
                                                            hasSelectedAppearance: isTheActiveDate
                                                                        isEnabled: YES
                                                                        isCircled: recordExistsForIterativeDate
                                                                 masterController: self
                                                                  representedDate: [calendar dateFromComponents: dateComps]
                                                            representsHistoricDay: !iterativeDateGreaterThanToday];
        
        [self.circleDateChildren addObject: circleDateVC];
        [self addChildViewController: circleDateVC];
        [stackView addArrangedSubview: circleDateVC.view];
        [circleDateVC didMoveToParentViewController: self];
        
    }
    
}

- (void)configureInitialDateControlAnimationPosition{
    
    CGFloat firstPositionOffsetX = [self dateSVWidthGivenButtonSpecifications] - [UIScreen mainScreen].bounds.size.width;
    CGPoint firstPosition = CGPointMake(firstPositionOffsetX, 0);
    self.dateScrollView.contentOffset = firstPosition;
    
}

- (void)incrementDateControlMonthAndUpdateDateControlsInForwardDirection:(BOOL)inForwardDirection{
    
    // changing the month represented by the date controls does not automatically select a new date. Thus, the preloaded cells should not be nullified at this point
    
    NSInteger monthDelta;
    
    if (inForwardDirection){
        monthDelta = 1;
    } else{
        monthDelta = -1;
    }
    
    NSCalendar * calendar = [NSCalendar calendarWithIdentifier: NSCalendarIdentifierGregorian];
    NSDateComponents *dateComps = [calendar components: (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
                                              fromDate: self.dateControlActiveDate];
    dateComps.month += monthDelta;
    dateComps.day = 1; // the day is set to one to ensure that the date is valid (for example, February 30th is not a valid date but February 1st is)
    
    self.dateControlActiveDate = [calendar dateFromComponents: dateComps];
    
    
    [self configureDateControlsAccordingToActiveDateControlDateAndSelectActiveDateControlDay: NO];
    
}




- (void)setTitlesAccordingToDate:(NSDate *)date isLargestDate:(BOOL)isLargestDate{
    
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier: NSCalendarIdentifierGregorian];
    NSDateComponents *dateComps = [[NSDateComponents alloc] init];
    NSDate *newSmallDate;
    
    if (isLargestDate){
        
        dateComps.day = -6;
        newSmallDate = [calendar dateByAddingComponents: dateComps
                                                 toDate: date
                                                options: 0];
        
    } else{
        
        newSmallDate = self.workoutLogActiveDay;
        
    }
    
    int limit = 7;
    NSDateFormatter *dayNameDF = [[NSDateFormatter alloc] init];
    dayNameDF.dateFormat = @"E";
    NSDateFormatter *dayNumberDF = [[NSDateFormatter alloc] init];
    dayNumberDF.dateFormat = @"d";
    
    for (int i = 0; i < limit; i++){
        
        TJBCircleDateVC *activeVC = self.circleDateChildren[i];
        
        dateComps.day = i;
        NSDate *activeDate = [calendar dateByAddingComponents: dateComps
                                                       toDate: newSmallDate
                                                      options: 0];
        
        NSString *dayName = [dayNameDF stringFromDate: activeDate];
        NSString *dayNumber = [dayNumberDF stringFromDate: activeDate];
        [activeVC configureWithDayTitle: dayName
                            buttonTitle: dayNumber];
        
    }
    
}



#pragma mark - Date Control Algorithms and Convenience Methods

- (NSInteger)dayIndexForDate:(NSDate *)date{
    
    // extract the day component to back solve for the date object index
    
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier: NSCalendarIdentifierGregorian];
    NSInteger day = [calendar component: NSCalendarUnitDay
                               fromDate: date];
    
    // correct for indexing
    
    day -= 1;
    
    return day;
    
}


#pragma mark - Date Controls - Circle Date Selection Action Sequence

- (void)didSelectObjectWithIndex:(NSNumber *)index representedDate:(NSDate *)representedDate{
    
    [self showActivityIndicator];
    
    [self selectDateObjectCorrespondingToIndex: index];
    [self disableControlsAndGiveInactiveAppearance];
    
    [self updateActiveDateLabelWithDate: representedDate];
    self.numberOfEntriesLabel.text = @"";
    
    self.selectedDateButtonIndex = index;
    self.workoutLogActiveDay = representedDate;
    
    [self updateSelectionStateVariablesInResponseToDateDateObjectWithRepresentedDate: representedDate];
    [self configureToolbarAppearanceAccordingToStateVariables];
    
    [self performSelector: @selector(userDateControlObjectSelectionCompletionActions)
               withObject: nil
               afterDelay: contentLoadingSmoothingDelay];
    
}

- (void)userDateControlObjectSelectionCompletionActions{
    
    [self deriveDailyList];
    [self updateNumberOfEntriesLabel];
    
    [self deriveActiveCellsAndCreateTableView];
    [self.tableView reloadData];
    
    [self.activityIndicatorView stopAnimating];
    
    [self enableControlsAndGiveActiveAppearance];
    
}


#pragma mark - Table View Content

- (void)updateSelectionStateVariablesInResponseToDateDateObjectWithRepresentedDate:(NSDate *)representedDate{
    
    // cell selection state
    
    self.currentlySelectedPath = nil;
    
    // date control date
    
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
    BOOL currentWorkoutLogDayDifferentThanPrevious;
    
    if (self.currentlySelectedWorkoutLogDate){
        
        currentWorkoutLogDayDifferentThanPrevious = ![calendar isDate: representedDate
                                                          equalToDate: self.currentlySelectedWorkoutLogDate
                                                    toUnitGranularity: NSCalendarUnitDay];
        
        
        
        if (currentWorkoutLogDayDifferentThanPrevious){
            
            self.lastSelectedWorkoutLogDate = self.currentlySelectedWorkoutLogDate;
            self.currentlySelectedWorkoutLogDate = representedDate;
            
        }
        
    } else{
        
        self.currentlySelectedWorkoutLogDate = representedDate;
        
    }

    
}



- (void)deriveActiveCellsAndCreateTableView{
    
    // derive the active cells - the 'limit' describes the number of cells that will be shown based on the daily list
    
    NSInteger limit;
    
    if (self.dailyList.count == 0){
        
        limit = 1;
        
    } else{
        
        limit = self.dailyList.count;
        
    }
    
    // calculate and assign the table view container (scroll view) content size as well
    // must create the new table view first so that the cellForIndexPath method has a valid table to dequeue
    
    UITableView *newTableView = [[UITableView alloc] init];
    newTableView.dataSource = self;
    newTableView.delegate = self;
    newTableView.backgroundColor = [[TJBAestheticsController singleton] yellowNotebookColor];
    newTableView.scrollEnabled = YES;
    newTableView.separatorInset = UIEdgeInsetsMake(0, 16, 0, 0);
    newTableView.separatorColor = [UIColor lightGrayColor];
    
    // make sure to remove the old table view from the view hierarchy or else it will not deallocate
    
    [self.tableView removeFromSuperview];
    self.tableView = newTableView;
    [self configureTableView];
    
    self.activeTableViewCells = [[NSMutableArray alloc] init];


    CGSize contentSize = CGSizeMake(self.shadowContainer.frame.size.width, [self totalScrollHeightBasedOnContent]);
    
    // table view and container - a new table view is created at every method call because I believe the table view is leaking its old content cells
    
    UIScrollView *sv = [[UIScrollView alloc] init];
    self.tableViewScrollContainer = sv;
    
    sv.frame = CGRectMake(0, 0, contentSize.width, self.shadowContainer.frame.size.height);
    sv.contentSize = contentSize;
    sv.bounces = YES;
    
    // if there is an object for the scrollPositionForUpdate property, use that value to derive the correct CGPoint
    
    CGPoint newScrollPosition;
    
    if (self.scrollPositionForUpdate){
        
        newScrollPosition = CGPointMake(0, [self.scrollPositionForUpdate floatValue]);
        
        self.scrollPositionForUpdate = nil; // the logic is structured such that this object should be nullified once used.  Other objects will recreate it if they would like to influence scroll position
        
    } else{
        
        newScrollPosition = CGPointZero;
        
    }
    
    sv.contentOffset = newScrollPosition;

    sv.scrollEnabled = YES;
    
    newTableView.frame = CGRectMake(0, 0, contentSize.width, contentSize.height);
    
    [sv addSubview: newTableView];
    [self.shadowContainer insertSubview: sv
                           belowSubview: self.toolbar];
    
    return;
    
}

- (CGFloat)contentBreatherRoom{
    
    return self.toolbar.frame.size.height + toolbarToBottomSpacing + 8;
    
}

- (void)prepareNewContentCellsAndRemoveActivityIndicator{
    
    [self deriveDailyList];
    [self updateNumberOfEntriesLabel];
    
    // call the table view cellForIndexPath method for all daily list cells and store the results
    
    [self deriveActiveCellsAndCreateTableView];
    [self.tableView reloadData];
    

    [self.activityIndicatorView stopAnimating];
    
    [self enableControlsAndGiveActiveAppearance];
    
}





#pragma mark - Date Controls - Circle Date Selection Helper Methods


- (void)updateActiveDateLabelWithDate:(NSDate *)date{
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"MMM d, yyyy";
    
    self.activeDateLabel.text = [df stringFromDate: date];
    
}

- (void)updateNumberOfEntriesLabel{
    
    NSNumber *number = @(self.dailyList.count);
    
    BOOL hasOneEntry = [number intValue] == 1;
    NSString *entriesWord = hasOneEntry ? @"Entry" : @"Entries";
    
    NSString *text = [NSString stringWithFormat: @"%@ %@",
                      [number stringValue],
                      entriesWord];
    
    self.numberOfEntriesLabel.text = text;
    
}



- (void)enableControlsAndGiveActiveAppearance{
    
    for (TJBCircleDateVC *circVC in self.circleDateChildren){
        
        [circVC configureEnabledAppearance];
        
    }
    
    NSArray *buttons = @[self.homeButton];
    for (UIButton *b in buttons){
        
        b.enabled = YES;
        b.layer.opacity = 1.0;
        
    }
    
    NSArray *arrows = @[self.leftArrowButton, self.rightArrowButton];
    for (UIButton *b in arrows){
        
        b.enabled = YES;
        b.layer.opacity = 1.0;
        
    }
    
}

- (void)disableControlsAndGiveInactiveAppearance{
    
    NSArray *buttons = @[self.homeButton];
    for (UIButton *b in buttons){
        
        b.enabled = NO;
        b.layer.opacity = .4;
        
    }
    
    NSArray *arrows = @[self.leftArrowButton, self.rightArrowButton];
    for (UIButton *b in arrows){
        
        b.enabled = NO;
        b.layer.opacity = .4;
        
    }
    
}

- (void)selectDateObjectCorrespondingToIndex:(NSNumber *)index{
    
    if (self.selectedDateButtonIndex){
        
        [self.circleDateChildren[[self.selectedDateButtonIndex intValue]] configureButtonAsNotSelected];
        
    }
    
    [self.circleDateChildren[[index intValue]] configureButtonAsSelected];
    
    // reduce opacity of buttons and disable them until the cells have loaded
    
    for (TJBCircleDateVC *circVC in self.circleDateChildren){
        
        [circVC configureDisabledAppearance];
        
    }
    
}

- (void)showActivityIndicator{
    
    if (!self.activityIndicatorView){
        
        UIActivityIndicatorView *aiView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
        
        aiView.frame = self.shadowContainer.frame;
        aiView.hidesWhenStopped = YES;
        aiView.backgroundColor = [[TJBAestheticsController singleton] yellowNotebookColor];
        
        aiView.layer.opacity = .9;
        
        self.activityIndicatorView = aiView;
        
        [self.view addSubview: aiView];
        
    }
    
    [self.activityIndicatorView startAnimating];

    
}



- (CGFloat)totalScrollHeightBasedOnContent{
    
    NSInteger limit;
    
    if (self.dailyList.count == 0){
        
        limit = 1;
        
    } else{
        
        limit = self.dailyList.count;
        
    }
    
    CGFloat totalHeight = 0;
    
    for (int i = 0; i < limit; i++){
        
        NSIndexPath *path = [NSIndexPath indexPathForRow: i
                                               inSection: 0];
        
        TJBMasterCell *cell = [self cellForIndexPath: path
                                       shouldDequeue: YES];
        
        [self.activeTableViewCells addObject: cell];
        
        // height calc
        
        CGFloat iterativeHeight = [self tableView: self.tableView
                          heightForRowAtIndexPath: path];
        totalHeight += iterativeHeight;
        
    }
    
    // make sure the total height is as least as long as the table view container
    
    [self.view layoutIfNeeded];
    
    CGFloat minHeight = self.shadowContainer.frame.size.height - [self contentBreatherRoom];
    
    if (totalHeight < minHeight){
        
        totalHeight = minHeight;
        
    }
    
    return  totalHeight + [self contentBreatherRoom];
    
}

- (void)setScrollViewContentSizeBasedOnDailyList{
    
    self.tableViewScrollContainer.contentSize = CGSizeMake(self.tableViewScrollContainer.frame.size.width, [self totalScrollHeightBasedOnContent]);
    
}

#pragma mark - Toolbar

- (void)configureToolBarAndBarButtons{
    
    // tool bar
    
    self.toolbar.barTintColor = [UIColor grayColor];
    self.toolbar.tintColor = [[TJBAestheticsController singleton] paleLightBlueColor];
    CALayer *tbLayer = self.toolbar.layer;
    tbLayer.borderColor = [[TJBAestheticsController singleton] paleLightBlueColor].CGColor;
    tbLayer.borderWidth = 1.0;
    tbLayer.masksToBounds = YES;
    tbLayer.cornerRadius = 25;
    
    
}

- (void)toggleToolBarPositionAndUpdateRelevantControls{
    
    if (_toolbarState == TJBToolbarNotHidden){
        
        [self animateToolbarToHiddenState];
        
        [self.toolbarControlArrow setImage: [UIImage imageNamed: @"doubleUpArrowBlue32"]
                                  forState: UIControlStateNormal];
        
        _toolbarState = TJBToolbarHidden;
        
    } else{
        
        [self animateToolbarToNotHiddenState];
        
        [self.toolbarControlArrow setImage: [UIImage imageNamed: @"doubleDownArrowBlue32"]
                                  forState: UIControlStateNormal];
        
        _toolbarState = TJBToolbarNotHidden;
        
    }
    
}
                                   
- (void)animateToolbarToHiddenState{
    
    self.toolbarControlArrow.enabled = NO;
    
    [UIView animateWithDuration: toolbarAnimationTime
                     animations: ^{
                         
                         CGRect currentToolbarRect = self.toolbar.frame;
                         
                         CGPoint toolbarOrigin = currentToolbarRect.origin;
                         CGPoint newOrigin = CGPointMake(toolbarOrigin.x, toolbarOrigin.y + currentToolbarRect.size.height + self.toolbarBottomToContainerConstr.constant);
                         CGRect newFrame = CGRectMake(newOrigin.x, newOrigin.y, currentToolbarRect.size.width, currentToolbarRect.size.height);
                         
                         self.toolbar.frame = newFrame;
                         
                     }
                     completion: ^(BOOL finished){
                         
                         CGFloat newConstrConst = self.toolbar.frame.size.height;
                         self.toolbarBottomToContainerConstr.constant = -1 * newConstrConst;
                         
                         self.toolbarControlArrow.enabled = YES;
                         
                     }];
    
}


- (void)animateToolbarToNotHiddenState{
    
    self.toolbarControlArrow.enabled = NO;
    
    [UIView animateWithDuration: toolbarAnimationTime
                     animations: ^{
                         
                         CGRect currentToolbarRect = self.toolbar.frame;
                         
                         CGPoint toolbarOrigin = currentToolbarRect.origin;
                         CGPoint newOrigin = CGPointMake(toolbarOrigin.x, toolbarOrigin.y - currentToolbarRect.size.height - toolbarToBottomSpacing);
                         CGRect newFrame = CGRectMake(newOrigin.x, newOrigin.y, currentToolbarRect.size.width, currentToolbarRect.size.height);
                         
                         self.toolbar.frame = newFrame;
                         
                     }
                     completion: ^(BOOL finished){
                         
                         self.toolbarBottomToContainerConstr.constant = toolbarToBottomSpacing;
                         
                         self.toolbarControlArrow.enabled = YES;
                         
                     }];
    
}

- (void)configureToolbarAppearanceAccordingToStateVariables{
    
    // toolbar items have dependencies on state variables
    // some of them make no sense if the corresponding state variable does not exist
    
    // jump-to-last button
    
    if (self.lastSelectedWorkoutLogDate){
        
        [self configureActiveStateForToolbarButton: self.jumpToLastButton];
        
    } else{
        
        [self configureInactiveStateForToolbarButton: self.jumpToLastButton];
        
    }
    
    // edit button
    
    if (self.currentlySelectedPath){
        
        [self configureActiveStateForToolbarButton: self.editButton];
        
    } else{
        
        [self configureInactiveStateForToolbarButton: self.editButton];
        
    }
    
    // delete buttons
    // deleting is disallowed when workout log is part of tab bar controller (active entry scenes)
    
    if (_advancedControlsActive == YES){
        
        if (self.currentlySelectedPath){
            
            [self configureActiveStateForToolbarButton: self.deleteButton];
            
        } else{
            
            [self configureInactiveStateForToolbarButton: self.deleteButton];
            
        }
        
    } else{
        
        [self configureInactiveStateForToolbarButton: self.deleteButton];
        
    }
    
}

- (void)configureActiveStateForToolbarButton:(UIBarButtonItem *)bbi{
    
    bbi.enabled = YES;
    
}

- (void)configureInactiveStateForToolbarButton:(UIBarButtonItem *)bbi{
    
    bbi.enabled = NO;
    
}


#pragma mark - Toolbar Button Actions

- (IBAction)didPressJumpToLast:(id)sender{
    
    [self showActivityIndicator];
    
    dispatch_async(dispatch_get_main_queue(),  ^{
        
        [self deriveAndPresentContentAndRemoveActivityIndicatorForWorkoutLogDate: self.lastSelectedWorkoutLogDate
                                                                 dateControlDate: self.lastSelectedWorkoutLogDate
                                                     shouldAnimateDateControlBar: YES];
        
    });
    
}

- (IBAction)didPressToday:(id)sender{
    
    [self showActivityIndicator];
    
    dispatch_async(dispatch_get_main_queue(),  ^{
        
        NSDate *today = [NSDate date];
        
        [self deriveAndPresentContentAndRemoveActivityIndicatorForWorkoutLogDate: today
                                                                 dateControlDate: today
                                                     shouldAnimateDateControlBar: YES];
        
    });
    
}



- (IBAction)didPressEdit:(id)sender{
    
    id selecteDataObject = self.dailyList[self.currentlySelectedPath.row];
    
    TJBCircuitReferenceContainerVC *crcVC = [[TJBCircuitReferenceContainerVC alloc] initWithDataObject: selecteDataObject];
    
    [self presentViewController: crcVC
                       animated: YES
                     completion: nil];
    
    
}

#pragma mark - Toolbar Delete Methods

- (IBAction)didPressDelete:(id)sender{
    
    // alert controller
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"Proceed with Delete?"
                                                                   message: @"This action is permanent"
                                                            preferredStyle: UIAlertControllerStyleAlert];
    
    __weak TJBWorkoutNavigationHub *weakSelf = self;
    
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
    
    [self.tableView beginUpdates];
    
    [self.tableView deleteRowsAtIndexPaths: @[self.currentlySelectedPath]
                          withRowAnimation: UITableViewRowAnimationLeft];
    
    NSLog(@"%@", self.currentlySelectedPath);
    
    [self.activeTableViewCells removeObjectAtIndex: self.currentlySelectedPath.row];
    
    if (self.dailyList.count == 1){
        
        [self.activeTableViewCells addObject: [self noDataCell]];
        
        [self.tableView insertRowsAtIndexPaths: @[self.currentlySelectedPath]
                              withRowAnimation: UITableViewRowAnimationRight];
        
        [self.circleDateChildren[[self.selectedDateButtonIndex intValue]] getRidOfContentDot];
        
    }
    

    
    [self deleteCoreDataObjectsForIndexPath: self.currentlySelectedPath];
    _displayedContentNeedsUpdating = NO; // this is done so that the controller does not attempt to relaod data if it's view were to disappear and reappear. Core data reloading is already handled in the following logic
    
    [self.tableView endUpdates];
    
    
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self fetchManagedObjectsAndDeriveMasterList];
        
        self.currentlySelectedPath = nil;
        [self configureToolbarAppearanceAccordingToStateVariables];
        
        [self updateCellTitleNumbers];
        
        [self updateNumberOfEntriesLabel];
        
        [self setScrollViewContentSizeBasedOnDailyList];
        
    });
    
}

- (TJBNoDataCell *)noDataCell{
    
    TJBNoDataCell *cell = [self.tableView dequeueReusableCellWithIdentifier: @"TJBNoDataCell"];
    
    cell.mainLabel.text = @"No Entries";
    cell.backgroundColor = [UIColor clearColor];
    
    NSIndexPath *path = [NSIndexPath indexPathForRow: 0
                                           inSection: 0];
    cell.referenceIndexPath = path;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
    
}

- (void)updateCellTitleNumbers{
    
    for (int i = 0; i < self.activeTableViewCells.count; i++){
        
        UITableViewCell *cell = self.activeTableViewCells[i];
        
        if ([cell isKindOfClass: [TJBRealizedChainCell class]]){
            
            TJBRealizedChainCell *rcCell = (TJBRealizedChainCell *)cell;
            
            [rcCell updateTitleNumber: @(i + 1)];
            
        }
        
    }
    
}

- (void)deleteCoreDataObjectsForIndexPath:(NSIndexPath *)indexPath{
    
    id dailyListObject = self.dailyList[indexPath.row];
    [self.dailyList removeObject: dailyListObject];
    [self.masterList removeObject: dailyListObject];
    
    if ([dailyListObject isKindOfClass: [TJBRealizedChain class]]){
        
        TJBRealizedChain *rc = dailyListObject;
        [[CoreDataController singleton] deleteRealizedChain: rc];
        
    } else if ([dailyListObject isKindOfClass: [NSArray class]]){
        
        TJBRealizedSetGrouping rsg = dailyListObject;
        for (TJBRealizedSet *rs in rsg){
            
            [[CoreDataController singleton] deleteRealizeSet: rs];
            
        }

    } else if ([dailyListObject isKindOfClass: [TJBRealizedSet class]]){
        
        TJBRealizedSet *rs = dailyListObject;
        [[CoreDataController singleton] deleteRealizeSet: rs];

    }
    
}



#pragma mark - Core Data Notification

- (void)configureCoreDataUpdateNotification{
    
    //// configure managed context notification for updating
    
    NSManagedObjectContext *moc = [[CoreDataController singleton] moc];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(mocDidSave)
                                                 name: NSManagedObjectContextDidSaveNotification
                                               object: moc];
    
}

- (void)mocDidSave{
    
    _fetchedObjectsNeedUpdating = YES;
    _displayedContentNeedsUpdating = YES;
    
    return;

}


#pragma mark - Button Actions

- (IBAction)didPressLeftArrow:(id)sender{
    
    self.selectedDateButtonIndex = nil;
    
    [self incrementDateControlMonthAndUpdateDateControlsInForwardDirection: NO];
    
}

- (IBAction)didPressRightArrow:(id)sender{
    
    self.selectedDateButtonIndex = nil;	
    
    [self incrementDateControlMonthAndUpdateDateControlsInForwardDirection: YES];
    
}

- (IBAction)didPressHomeButton:(id)sender{
    
    [self dismissViewControllerAnimated: NO
                             completion: nil];
    
}


- (IBAction)didPressToolbarControlArrow:(id)sender {
    
    [self toggleToolBarPositionAndUpdateRelevantControls];
    
}




#pragma mark - <UITableViewDataSource>



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (self.dailyList.count == 0){
        
        return 1;
        
    } else{
        
        return self.dailyList.count;
        
    }
    
}

- (TJBMasterCell *)cellForIndexPath:(NSIndexPath *)indexPath shouldDequeue:(BOOL)shouldDequeue{

        if (self.dailyList.count == 0){
            
            TJBNoDataCell *cell = [self.tableView dequeueReusableCellWithIdentifier: @"TJBNoDataCell"];
            
            cell.mainLabel.text = @"No Entries";
            cell.backgroundColor = [UIColor clearColor];
            cell.referenceIndexPath = indexPath;
            
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            
            return cell;
            
        } else{
            
            NSNumber *number = [NSNumber numberWithInteger: indexPath.row + 1];
            
            int rowIndex = (int)indexPath.row;
            
            BOOL isRealizedSet = [self.dailyList[rowIndex] isKindOfClass: [TJBRealizedSet class]];
            BOOL isRealizedChain = [self.dailyList[rowIndex] isKindOfClass: [TJBRealizedChain class]];
            
            if (isRealizedSet){
                
                TJBRealizedSet *realizedSet = self.dailyList[rowIndex];
                
                // dequeue the realizedSetCell
                
                TJBRealizedChainCell *cell = [self.tableView dequeueReusableCellWithIdentifier: @"TJBRealizedChainCell"];
                
                [self layoutCellToEnsureCorrectWidth: cell
                                           indexPath: indexPath];
    
                [cell configureWithContentObject: realizedSet
                                        cellType: RealizedSetCollectionCell
                                    dateTimeType: TJBTimeOfDay
                                     titleNumber: number];
                
                cell.backgroundColor = [UIColor clearColor];
                
                return cell;
                
            } else if (isRealizedChain){
                
                TJBRealizedChain *realizedChain = self.dailyList[rowIndex];
                
                // dequeue the realizedSetCell
                
                TJBRealizedChainCell *cell = nil;
                    
                cell = [self.tableView dequeueReusableCellWithIdentifier: @"TJBRealizedChainCell"];
                
                
                [self layoutCellToEnsureCorrectWidth: cell
                                           indexPath: indexPath];
                
                [cell configureWithContentObject: realizedChain
                                        cellType: RealizedChainCell
                                    dateTimeType: TJBTimeOfDay
                                     titleNumber: number];
                
                cell.backgroundColor = [UIColor clearColor];
                
                return cell;
                
            } else{
                
                // if it is not a realized set or realized chain, then it is a TJBRealizedSetCollection
                
                TJBRealizedChainCell *cell = [self.tableView dequeueReusableCellWithIdentifier: @"TJBRealizedChainCell"];
                
                [self layoutCellToEnsureCorrectWidth: cell
                                           indexPath: indexPath];
                
                cell.backgroundColor = [UIColor clearColor];
                
                TJBRealizedSetGrouping rsg = self.dailyList[rowIndex];
                
                [cell configureWithContentObject: rsg
                                        cellType: RealizedSetCollectionCell
                                    dateTimeType: TJBTimeOfDay
                                     titleNumber: number];
                
                return cell;
                
            }
        }

    
}

- (void)layoutCellToEnsureCorrectWidth:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath{
    
    [self.view layoutSubviews];
    
    CGFloat cellHeight = [self tableView: self.tableView
                 heightForRowAtIndexPath: indexPath];
    
    CGFloat cellWidth = self.shadowContainer.frame.size.width;
    
    
    [cell setFrame: CGRectMake(0, 0, cellWidth, cellHeight)];
    [cell layoutSubviews];
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return self.activeTableViewCells[indexPath.row];
    
}

#pragma mark - <UITableViewDelegate>


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
        
    [self updateStateVariablesAndCellAppearanceBasedOnSelectedPath: indexPath];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    
        if (self.dailyList.count == 0){
            
            [self.view layoutSubviews];
            
            return self.shadowContainer.frame.size.height - [self contentBreatherRoom];
            
        } else{
            
            NSInteger adjustedIndex = indexPath.row;
            
            BOOL isRealizedSet = [self.dailyList[adjustedIndex] isKindOfClass: [TJBRealizedSet class]];
            BOOL isRealizedChain = [self.dailyList[adjustedIndex] isKindOfClass: [TJBRealizedChain class]];
            
            
            if (isRealizedSet){
                
                return [TJBRealizedChainCell suggestedHeightForRealizedSet];
                
            } else if (isRealizedChain) {
                
                TJBRealizedChain *realizedChain = self.dailyList[adjustedIndex];
                
                return [TJBRealizedChainCell suggestedCellHeightForRealizedChain: realizedChain];
                
            } else{
                
                TJBRealizedSetGrouping rsg = self.dailyList[adjustedIndex];
                
                return [TJBRealizedChainCell suggestedHeightForRealizedSetGrouping: rsg];
                
            }
        }

    
}



#pragma mark - Table View Cell Selection

- (void)jumpToLastSelection{
    
    
    
}

- (void)updateStateVariablesAndCellAppearanceBasedOnSelectedPath:(NSIndexPath *)selectedPath{
    
    // only perform selection actions if the new selection is different than the previous (or there is no previous)
    // also only select if content exists

    
    // content
    
    BOOL dailyListContainsContent = self.dailyList.count > 0;
    
    // selected index
    
    BOOL newSelectionIndexRowDifferentThanPrevious;
    
    if (self.currentlySelectedPath){
        
        newSelectionIndexRowDifferentThanPrevious = selectedPath.row != self.currentlySelectedPath.row;
        
    } else{
        
        newSelectionIndexRowDifferentThanPrevious = YES;
        
    }
    

    // actionable selection logic
    
    if (dailyListContainsContent &&  newSelectionIndexRowDifferentThanPrevious){
        
        // cell selection appearance
        
        if (self.currentlySelectedPath){
            [self giveCellAtIndexPathUnselectedAppearance: self.currentlySelectedPath];
        }
        
        [self giveCellAtIndexPathSelectedAppearance: selectedPath];
        
        // state variables
        
        self.currentlySelectedPath = selectedPath;
    
        // toolbar appearance
        
        [self configureToolbarAppearanceAccordingToStateVariables];
        
        
        
    }
    

    
}

- (void)giveCellAtIndexPathSelectedAppearance:(NSIndexPath *)path{
    
    TJBRealizedChainCell *cell = [self.tableView cellForRowAtIndexPath: path];
    
    CALayer *cLayer = cell.layer;
    cLayer.borderWidth = 4;
    cLayer.borderColor = [[TJBAestheticsController singleton] paleLightBlueColor].CGColor;
    
}


- (void)giveCellAtIndexPathUnselectedAppearance:(NSIndexPath *)path{
    
    TJBRealizedChainCell *cell = [self.tableView cellForRowAtIndexPath: path];
    
    CALayer *cLayer = cell.layer;
    cLayer.borderWidth = 0;
    cLayer.borderColor = [UIColor clearColor].CGColor;
    
}

#pragma mark - Animations and Date SV Calcs

- (void)executeDateControlAnimation{
    
    // second position
    
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier: NSCalendarIdentifierGregorian];
    NSInteger day = [calendar component: NSCalendarUnitDay
                               fromDate: self.workoutLogActiveDay];
    TJBCircleDateVC *vc = self.circleDateChildren[day - 1];
    CGFloat activeDateControlRightEdge = vc.view.frame.origin.x + vc.view.frame.size.width;
    
    // make sure the second position will not drag the view too far, revealing a white screen beneath
    
    CGFloat viewWidth = self.view.frame.size.width;
    
    if (activeDateControlRightEdge < viewWidth){
        
        activeDateControlRightEdge = viewWidth;
        
    }
    
    CGFloat secondPositionOffsetX = activeDateControlRightEdge - self.dateScrollView.frame.size.width;
    CGPoint secondPosition = CGPointMake(secondPositionOffsetX,  0);
    
    CGFloat firstPositionOffsetX = [self dateSVWidthGivenButtonSpecifications] - [UIScreen mainScreen].bounds.size.width;
    float percentScrollViewWidth = (firstPositionOffsetX - secondPositionOffsetX) / firstPositionOffsetX;
    float maxAnimationTime = _maxDateControlAnimationTime;
    
    // animation call
    
    [self scrollToOffset: secondPosition
       animationDuration: maxAnimationTime * percentScrollViewWidth
     subsequentAnimation: nil];
    
}

- (void)scrollToOffset:(CGPoint)offset animationDuration:(NSTimeInterval)animationDuration subsequentAnimation:(AnimationCompletionBlock)subsequentAnimation{
    
    [UIView animateWithDuration: animationDuration
                     animations: ^{
        
                         [self.dateScrollView setContentOffset: offset];
                         
                     }
                     completion: subsequentAnimation];
    
}

- (CGFloat)dateSVWidthGivenButtonSpecifications{
    
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier: NSCalendarIdentifierGregorian];
    NSRange daysInCurrentMonth = [calendar rangeOfUnit: NSCalendarUnitDay
                                                inUnit: NSCalendarUnitMonth
                                               forDate: self.dateControlActiveDate];
    
    return buttonWidth * daysInCurrentMonth.length + (daysInCurrentMonth.length - 1) * buttonSpacing;
    
}

- (float)scrollViewXOffsetAsFractionOfContentView{
    
    CGFloat xPosition = self.dateScrollView.contentOffset.x;
    CGFloat xRange = [self dateSVWidthGivenButtonSpecifications] - self.dateScrollView.frame.size.width;
    
    return xPosition / xRange;
    
}

#pragma mark - Restoration



- (void)encodeRestorableStateWithCoder:(NSCoder *)coder{
    
    [coder encodeObject: self.workoutLogActiveDay
                 forKey: workoutLogActiveDateKey];
    
    [coder encodeObject: self.dateControlActiveDate
                 forKey: dateControlActiveDateKey];
    
    [coder encodeBool: _includesHomeButton
               forKey: includeHomeButtonKey];
    
    [coder encodeBool: _advancedControlsActive
               forKey: includeAdvancedControlsKey];
    
}

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder{
    
    return [[TJBWorkoutNavigationHub alloc] initWithHomeButton: NO
                                        advancedControlsActive: NO];
    
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder{
    
    self.workoutLogActiveDay = [coder decodeObjectForKey: workoutLogActiveDateKey];
    self.dateControlActiveDate = [coder decodeObjectForKey: dateControlActiveDateKey];
    
    _includesHomeButton = [coder decodeBoolForKey: includeHomeButtonKey];
    _advancedControlsActive = [coder decodeBoolForKey: includeAdvancedControlsKey];
    
}


@end





















































