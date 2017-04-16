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

// cell preloading

#import "TJBCellFetchingOperation.h"


// state

typedef enum{
    TJBToolbarHidden,
    TJBToolbarNotHidden
}TJBToolbarState;




@interface TJBWorkoutNavigationHub () <UITableViewDataSource, UITableViewDelegate>

{
    // state
    
    int _activeSelectionIndex;
    BOOL _includesHomeButton;
    BOOL _cellsNeedUpdating; // used to indicate that core data has saved during this controller's lifetime while a different tab of the tab bar controller was selected
    TJBToolbarState _toolbarState;
    
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

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *jumpToLastButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *todayButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;

@property (weak, nonatomic) IBOutlet UILabel *myWorkoutLogLabel;
@property (weak, nonatomic) IBOutlet UILabel *activeDateLabel;
@property (weak, nonatomic) IBOutlet UIButton *toolbarControlArrow;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolbarBottomToContainerConstr;



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





// button specification constants

static const CGFloat buttonWidth = 60.0;
static const CGFloat buttonSpacing = 0.0;
static const CGFloat buttonHeight = 55.0;

static const CGFloat toolBarToContentBottomCushion = 8;

// animation

typedef void (^AnimationBlock)(void);
typedef void (^AnimationCompletionBlock)(BOOL);

typedef NSArray<TJBRealizedSet *> *TJBRealizedSetGrouping;





@implementation TJBWorkoutNavigationHub

#pragma mark - Master Notes

// ACTIVE DATE CONTROL DATE

// 1 - dateControlActiveDate is only set upon instantiation or when one of the arrows is pressed. This is true because these are the only two events that can impact the active date control date

// TABLE VIEW CELL SELECTION

// 1 - currentlySelectedWorkoutLogDate and its counterpart require granularity at the day level. These properties are used to jump between different workout logs, which are specified by a month and a day.  The month informs the date control bar of what content should be displayed, while the day informs the date control bar of which day should be selected

// 2 - the previous table view is destroyed when a new date control object is selected, so it is not necessary to manually deselect the previously selected cell

// STATE VARIABLES

// 1 - currentlySelectedWorkoutLogDate and workoutLogActiveDay may seem redundant, but they are necessary to handle selection transitions. The former is specific to cell selections while the latter is specific to only date control bar selections

#pragma mark - Instantiation

- (instancetype)initWithHomeButton:(BOOL)includeHomeButton{
    
    self = [super init];
    
    // for restoration
    
    self.restorationClass = [TJBWorkoutNavigationHub class];
    self.restorationIdentifier = @"TJBWorkoutNavigationHub";
    
    // state

    _toolbarState = TJBToolbarNotHidden;
    
    [self configureNotifications];
    
    // home button
    
    _includesHomeButton = includeHomeButton;
    
    // core data
    
    [self fetchManagedObjectsAndDeriveMasterList];
    
    return self;
}


#pragma mark - Init Helper Methods




#pragma mark - Core Data Queries And Algorithms

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

- (void)fetchManagedObjectsAndDeriveMasterList{
    
    NSMutableArray *interimArray1 = [[NSMutableArray alloc] init];
    
    NSManagedObjectContext *moc = [[CoreDataController singleton] moc];
    
    NSError *error;
    
    NSArray *fetchedSets = [moc executeFetchRequest: [self realizedSetRequest]
                                              error: &error];
    NSArray *fetchedChains = [moc executeFetchRequest: [self realizedChainRequest]
                                                error: &error];
    
    [interimArray1 addObjectsFromArray: fetchedSets];
    [interimArray1 addObjectsFromArray: fetchedChains];
    
    [interimArray1 sortUsingComparator: ^(id obj1, id obj2){
        
        NSDate *obj1Date;
        NSDate *obj2Date;
        
        // identify object class type in order to determine the correct key-value path for the date
        
        // obj1
        
        if ([obj1 isKindOfClass: [TJBRealizedSet class]]){
            
            TJBRealizedSet *obj1WithClass = (TJBRealizedSet *)obj1;
            obj1Date = obj1WithClass.submissionTime;
            
            
        } else if([obj1 isKindOfClass: [TJBRealizedChain class]]){
            
            TJBRealizedChain *obj1WithClass = (TJBRealizedChain *)obj1;
            obj1Date = obj1WithClass.dateCreated;
            
        }
        
        // obj2
        
        if ([obj2 isKindOfClass: [TJBRealizedSet class]]){
            
            TJBRealizedSet *obj2WithClass = (TJBRealizedSet *)obj2;
            obj2Date = obj2WithClass.submissionTime;
            
            
        } else if([obj2 isKindOfClass: [TJBRealizedChain class]]){
            
            TJBRealizedChain *obj2WithClass = (TJBRealizedChain *)obj2;
            obj2Date = obj2WithClass.dateCreated;
            
        }
        
        // return the appropriate NSComparisonResult
        
        BOOL obj2LaterThanObj1 = [obj2Date timeIntervalSinceDate: obj1Date] > 0;
        
        if (obj2LaterThanObj1){
            
            return NSOrderedAscending;
            
        } else {
            
            return  NSOrderedDescending;
            
        }
    }];
    
    // evaluate if consecutive array objects are realized sets of the same exercises.  Group these using TJBRealizedSetCollection
    // interim array 2 holds realized chains and TJBRealizedSetGrouping
    
    NSMutableArray *interimArray2 = [[NSMutableArray alloc] init];
    NSMutableArray *stagingArray = [[NSMutableArray alloc] init];
    
    // the above task will be completed by stepping through interim array 1
    // if interim array 1 only contains 1 object, the logic will not work (it will never even begin iterating).  In this case, simply assign interim array 2
    
    if (interimArray1.count == 1){
        
        self.masterList = interimArray1;
        return;
        
    }
    
    NSInteger limit2 = interimArray1.count - 1;
    
    for (int i = 0; i < limit2; i++){
        
        [stagingArray addObject: interimArray1[i]];
        
        BOOL object1IsRealizedSet = [interimArray1[i] isKindOfClass: [TJBRealizedSet class]];
        BOOL object2IsRealizedSet = [interimArray1[i+1] isKindOfClass: [TJBRealizedSet class]];
        BOOL objectsAreBothRealizedSets = object1IsRealizedSet && object2IsRealizedSet;
        BOOL isLastIteration = i == interimArray1.count - 2;
        
        // if the for loop is making its last iteration, special logic must be employed.  Otherwise, the last object will not be added
        
        if (isLastIteration){
            
            if (objectsAreBothRealizedSets){
                
                TJBRealizedSet *rs1 = interimArray1[i];
                TJBRealizedSet *rs2 = interimArray1[i+1];
                
                BOOL setsHaveSameExercise =  [rs1.exercise.name isEqualToString: rs2.exercise.name];
                
                if (setsHaveSameExercise){
                    
                    [stagingArray addObject: interimArray1[i+1]];
                    
                    TJBRealizedSetGrouping rsc = [NSArray arrayWithArray: stagingArray];
                    
                    [interimArray2 addObject: rsc];
                    
                } else{
                    
                    if (stagingArray.count > 1){
                        
                        TJBRealizedSetGrouping rsc = [NSArray arrayWithArray: stagingArray];
                        
                        [interimArray2 addObject: rsc];
                        
                        [interimArray2 addObject: interimArray1[i+1]];
                        
                    } else{
                        
                        [interimArray2 addObject: interimArray1[i]];
                        [interimArray2 addObject: interimArray1[i+1]];
                        
                    }
                    
                }
                
            } else{
                
                if (stagingArray.count > 1){
                    
                    TJBRealizedSetGrouping rsc = [NSArray arrayWithArray: stagingArray];
                    
                    [interimArray2 addObject: rsc];
                    
                    [interimArray2 addObject: interimArray1[i+1]];
                    
                } else{
                    
                    [interimArray2 addObject: interimArray1[i]];
                    [interimArray2 addObject: interimArray1[i+1]];
                    
                }
                
            }
            
            continue;
            
        }
        
        if (objectsAreBothRealizedSets){
            
            TJBRealizedSet *rs1 = interimArray1[i];
            TJBRealizedSet *rs2 = interimArray1[i+1];
            
            BOOL setsHaveSameExercise =  [rs1.exercise.name isEqualToString: rs2.exercise.name];
            
            if (setsHaveSameExercise){
                
                continue;
                
            }
            
        }
        
        // the index set will only have length greater than 1 if it has the indices of multiple realized sets
        
        if (stagingArray.count > 1){
            
            // give the rsc all realized sets
            
            TJBRealizedSetGrouping rsc = [NSArray arrayWithArray: stagingArray];
            
            // add the rsc to interim array 2 and clear all objects from the staging array
            
            [interimArray2 addObject: rsc];
            
            [stagingArray removeAllObjects];
            
            
        } else if (stagingArray.count == 1){
            
            // the object is either a lone realized set or realized chain.  Add it to interim array 2
            
            [interimArray2 addObject: stagingArray[0]];
            
            // clear all objects from the staging array
            
            [stagingArray removeAllObjects];
            
        } else{
            
            abort();
            
        }
    }
    
    // assign the master list using the appropriate interim array
    
    self.masterList = interimArray2;
    
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

// viewWillAppear and viewDidAppear are used to handle the animation that slides the date scroll view from right to left when the workout log becomes visible

- (void)viewWillAppear:(BOOL)animated{

    //// animation calculations
    // first position
    
    [self configureInitialDateControlAnimationPosition];
    
    // the following is used to update the cells if core data was updated while this controller existed but was not the active view controller (in the tab bar controller). The core data update will have prompted this controller to refetch core data objects and derive the master list. The following logic will then derive the daily list and active cells, showing the activity indicator while doing so
    
    if (_cellsNeedUpdating){
        
        NSInteger dayAsIndex = [self dayIndexForDate: self.workoutLogActiveDay];
        
        [self didSelectObjectWithIndex: @(dayAsIndex)
                       representedDate: self.workoutLogActiveDay];
        
        // the date controls should also be reloaded, in case a day that previously had not content now contains content
        
        [self configureDateControlsAccordingToActiveDateControlDateAndSelectActiveDateControlDay: YES];
        
        // update the state variable to reflect that cells no longer need updating
        
        _cellsNeedUpdating = NO;
        
    }
    
}



- (void)viewDidAppear:(BOOL)animated{
    
    [self executeDateControlAnimation];
    
}



- (void)viewDidLoad{
    
    [self configureViewAesthetics];
    
    [self configureToolBarAndBarButtons];
    
//    [self configureToolbarAppearanceAccordingToStateVariables];
    
//    [self configureDateControlsAccordingToActiveDateControlDateAndSelectActiveDateControlDay: YES];
    
    [self configureOptionalHomeButton];
    
//    [self artificiallySelectDate: [NSDate date]];
    
    [self showWorkoutLogForDate: [NSDate date]
          animateDateControlBar: YES
                      withDelay: .1];
    
    return;
    
}




#pragma mark - View Helper Methods

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
    
    self.dateScrollView.backgroundColor = [UIColor clearColor];
 
    self.monthTitle.backgroundColor = [UIColor clearColor];
    self.monthTitle.textColor = [UIColor whiteColor];
    self.monthTitle.font = [UIFont boldSystemFontOfSize: 20];
    
    NSArray *arrowButtons = @[self.leftArrowButton, self.rightArrowButton];
    for (UIButton *button in arrowButtons){
        
        button.backgroundColor = [UIColor clearColor];
        
    }
    
    // workout log and active date label
    
    NSArray *titleLabels = @[self.myWorkoutLogLabel, self.activeDateLabel];
    for (UILabel *lab in titleLabels){
        
        lab.backgroundColor = [UIColor grayColor];
        lab.font = [UIFont boldSystemFontOfSize: 15];
        lab.textColor = [UIColor whiteColor];
        
    }
    
    // toolbar control arrow
    
    self.toolbarControlArrow.backgroundColor = [UIColor grayColor];
    CALayer *tcaLayer = self.toolbarControlArrow.layer;
    tcaLayer.masksToBounds = YES;
    tcaLayer.cornerRadius = 25;
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

#pragma mark - Meta Workout Log Methods

- (void)showWorkoutLogForDate:(NSDate *)date animateDateControlBar:(BOOL)shouldAnimate withDelay:(NSTimeInterval)delay{
    
    self.dateControlActiveDate = date;
    self.workoutLogActiveDay = date;
    
    [self configureDateControlsAccordingToActiveDateControlDateAndSelectActiveDateControlDay: YES];
    [self artificiallySelectDate: date];
    
    if (shouldAnimate){
        
        [self configureInitialDateControlAnimationPosition];
        [self performSelector: @selector(executeDateControlAnimation)
                   withObject: self
                   afterDelay: delay];
        
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
    
    //// month title
    
    df.dateFormat = @"MMMM yyyy";
    NSString *monthTitle = [df stringFromDate: self.dateControlActiveDate];
    self.monthTitle.text = monthTitle;
    
    //// stack view and child VC's
    
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


- (void)executeDateControlAnimation{
    
//    [self.view layoutSubviews];
    
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
    
    //
    
    CGFloat firstPositionOffsetX = [self dateSVWidthGivenButtonSpecifications] - [UIScreen mainScreen].bounds.size.width;
    float percentScrollViewWidth = (firstPositionOffsetX - secondPositionOffsetX) / firstPositionOffsetX;
    float maxAnimationTime = .5;
    
    // animation call
    
    [self scrollToOffset: secondPosition
       animationDuration: maxAnimationTime * percentScrollViewWidth
     subsequentAnimation: nil];
    
}

- (void)artificiallySelectDate:(NSDate *)date{
    
    // extract the day component to back solve for the date object index
    
    NSInteger dayAsIndex = [self dayIndexForDate: date];
    
    [self didSelectObjectWithIndex: @(dayAsIndex)
                   representedDate: date];
    
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
    
    if (!self.activityIndicatorView){
        
        [self createAndPresentActivityIndicator];
        
    }
    
    // immediately change the colors of the previously selected and newly selected controls
    
    [self selectDateObjectCorrespondingToIndex: index];
    
    [self disableControlsAndGiveInactiveAppearance];
    
    [self updateActiveDateLabelWithDate: representedDate];
    
    // state
    
    self.selectedDateButtonIndex = index;
    self.workoutLogActiveDay = representedDate;
    
    [self updateSelectionStateVariablesInResponseToDateDateObjectWithRepresentedDate: representedDate];
    [self configureToolbarAppearanceAccordingToStateVariables];
    
    // the next method is called with a delay so that the stack empties and views are updated (and thus the activity indicator is show)
    // a delay of .2 seconds is given to assure that the presentation of the activity indicator is clear and doesn't come off as glitchy
    
    [self performSelector: @selector(prepareNewContentCellsAndRemoveActivityIndicator)
               withObject: nil
               afterDelay: .2];
    
    [self.view setNeedsDisplay];
    
}



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
    newTableView.separatorInset = UIEdgeInsetsMake(0, 0, 0, 0);
    newTableView.separatorColor = [UIColor blackColor];
    
    // make sure to remove the old table view from the view hierarchy or else it will not deallocate
    
    [self.tableView removeFromSuperview];
    self.tableView = newTableView;
    [self configureTableView];
    
    self.activeTableViewCells = [[NSMutableArray alloc] init];
    
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
    
    CGFloat minHeight = self.shadowContainer.frame.size.height;
    
    if (totalHeight < minHeight){
        
        totalHeight = minHeight;
        
    }
    
    // give the scroll view the correct dimensions and create a new table view
    
    [self.view layoutSubviews];
    
    CGFloat breatherRoom;
    
    if (self.dailyList.count == 0){
        
        breatherRoom = 0;
        
    } else{
        
        breatherRoom = [self toolBarHeightFromBottomOfScreen] + toolBarToContentBottomCushion;
        
    }

    CGSize contentSize = CGSizeMake(self.shadowContainer.frame.size.width, totalHeight + breatherRoom);
    
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
    
//    sv.layer.masksToBounds = YES;
    sv.scrollEnabled = YES;
    
    newTableView.frame = CGRectMake(0, 0, contentSize.width, contentSize.height);
    
    [sv addSubview: newTableView];
    [self.shadowContainer insertSubview: sv
                           belowSubview: self.toolbar];
    
    return;
    
}



- (void)prepareNewContentCellsAndRemoveActivityIndicator{
    
    [self deriveDailyList];
    
    // call the table view cellForIndexPath method for all daily list cells and store the results
    
    [self deriveActiveCellsAndCreateTableView];
    
    [self.tableView reloadData];
    
    // remove activity indicator and give the buttons active appearance / functionality
    
    [self removeActivityIndicator];
    
    [self enableControlsAndGiveActiveAppearance];
    
}





#pragma mark - Date Controls - Circle Date Selection Helper Methods


- (void)updateActiveDateLabelWithDate:(NSDate *)date{
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"MMMM d, yyyy";
    
    self.activeDateLabel.text = [df stringFromDate: date];
    
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

- (void)createAndPresentActivityIndicator{
    
    UIActivityIndicatorView *aiView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
    
    aiView.frame = self.shadowContainer.frame;
    aiView.hidesWhenStopped = YES;
    aiView.backgroundColor = [[TJBAestheticsController singleton] yellowNotebookColor];
    
    aiView.layer.opacity = .9;
    
    self.activityIndicatorView = aiView;
    
    [self.view addSubview: aiView];
    
    [self.activityIndicatorView startAnimating];
    
}

- (void)removeActivityIndicator{
    
    [self.activityIndicatorView removeFromSuperview];
    self.activityIndicatorView = nil;
    
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
    
    
    
}


- (void)animateToolbarToNotHiddenState{
    
    
    
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
    
    // delete and edit buttons
    
    NSArray *deleteEditButtons = @[self.deleteButton, self.editButton];
    for (UIBarButtonItem *bbi in deleteEditButtons){
        
        if (self.currentlySelectedPath){
            
            [self configureActiveStateForToolbarButton: bbi];
            
        } else{
            
            [self configureInactiveStateForToolbarButton: bbi];
            
        }
        
    }
    
}

- (void)configureActiveStateForToolbarButton:(UIBarButtonItem *)bbi{
    
    bbi.enabled = YES;
    bbi.tintColor = [[TJBAestheticsController singleton] paleLightBlueColor];
    
}

- (void)configureInactiveStateForToolbarButton:(UIBarButtonItem *)bbi{
    
    bbi.enabled = NO;
    bbi.tintColor = [UIColor grayColor];
    
}


#pragma mark - Toolbar Button Actions

- (IBAction)didPressJumpToLast:(id)sender{
    
    [self showWorkoutLogForDate: self.lastSelectedWorkoutLogDate
          animateDateControlBar: NO
                      withDelay: 0];
    
}

- (IBAction)didPressToday:(id)sender{

    [self showWorkoutLogForDate: [NSDate date]
          animateDateControlBar: YES
                      withDelay: .1];
    

    
}



- (IBAction)didPressEdit:(id)sender{
    
    
    
    
    
}

#pragma mark - Toolbar Delete Methods

- (IBAction)didPressDelete:(id)sender{
    
    [self.tableView beginUpdates];
    
    [self.tableView deleteRowsAtIndexPaths: @[self.currentlySelectedPath]
                          withRowAnimation: UITableViewRowAnimationLeft];
    
    [self.activeTableViewCells removeObjectAtIndex: self.currentlySelectedPath.row];
    
    // the daily list determines the table view row count so must be updated to prevent an exception from being thrown
    
    [self.dailyList removeObjectAtIndex: self.currentlySelectedPath.row];
    
    [self.tableView endUpdates];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        
        [self updateCellTitleNumbers];
        
        [self deleteCoreDataObjectsForIndexPath: self.currentlySelectedPath];
        [self fetchManagedObjectsAndDeriveMasterList];
        
        self.currentlySelectedPath = nil;
        [self configureToolbarAppearanceAccordingToStateVariables];
        
    });
    
    
}

- (void)updateCellTitleNumbers{
    
    for (int i = 0; i < self.activeTableViewCells.count; i++){
        
        TJBRealizedChainCell *cell = self.activeTableViewCells[i];
        [cell updateTitleNumber: @(i + 1)];
        
    }
    
}

- (void)deleteCoreDataObjectsForIndexPath:(NSIndexPath *)indexPath{
    
    id dailyListObject = self.dailyList[indexPath.row];
    
    if ([dailyListObject isKindOfClass: [TJBRealizedChain class]]){
        
        TJBRealizedChain *rc = dailyListObject;
        [self.dailyList removeObject: rc];
        [self.masterList removeObject: rc];
        
        [[CoreDataController singleton] deleteRealizedChain: rc];
        
    } else if ([dailyListObject isKindOfClass: [NSArray class]]){
        
        TJBRealizedSetGrouping rsg = dailyListObject;
        [self.dailyList removeObject: rsg];
        [self.masterList removeObject: rsg];
        
        for (TJBRealizedSet *rs in rsg){
            
            [[CoreDataController singleton] deleteRealizeSet: rs];
            
        }

    } else if ([dailyListObject isKindOfClass: [TJBRealizedSet class]]){
        
        TJBRealizedSet *rs = dailyListObject;
        [self.dailyList removeObject: rs];
        [self.masterList removeObject: rs];
        
        [[CoreDataController singleton] deleteRealizeSet: rs];

    }
    
}



#pragma mark - Core Data Notification

- (void)configureNotifications{
    
    //// configure managed context notification for updating
    
    NSManagedObjectContext *moc = [[CoreDataController singleton] moc];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(mocDidSave)
                                                 name: NSManagedObjectContextDidSaveNotification
                                               object: moc];
    
}

- (void)mocDidSave{
    
    //// refresh fetched managed objects and all trickle-down
    // the daily list is derived whenever a date control object is selected. Even when a date control object is not explicitly selected by the user, I programmatically make the selection to select the desired day.
    
    [self fetchManagedObjectsAndDeriveMasterList];
    
    if (self.tabBarController){
        
        if (![self.tabBarController.selectedViewController isEqual: self]){
            
            _cellsNeedUpdating = YES; // when this state BOOL == YES, it means that core data was saved while this was not the active view controller in a tab bar controller. When this is the case, it is necessary for the table view to reload its cells when its view appears
            
        }
        
    }

}


#pragma mark - Button Actions

- (IBAction)didPressLiftButton:(id)sender {
    
    TJBLiftOptionsVC *vc = [[TJBLiftOptionsVC alloc] init];
    
    [self presentViewController: vc
                       animated: NO
                     completion: nil];
    
}

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
                
                if (shouldDequeue){
                    
                    cell = [self.tableView dequeueReusableCellWithIdentifier: @"TJBRealizedChainCell"];
                    
                } else{
                    
                    UINib *cellNib = [UINib nibWithNibName: @"TJBRealizedChainCell"
                                                    bundle: nil];
                    NSArray *topLevelNibObjects = [cellNib instantiateWithOwner: nil
                                                                        options: nil];
                    
                    cell = topLevelNibObjects[0];
                    
                }
                
                [cell configureWithContentObject: realizedChain
                                        cellType: RealizedChainCell
                                    dateTimeType: TJBTimeOfDay
                                     titleNumber: number];
                
                cell.backgroundColor = [UIColor clearColor];
                
                return cell;
                
            } else{
                
                // if it is not a realized set or realized chain, then it is a TJBRealizedSetCollection
                
                TJBRealizedChainCell *cell = [self.tableView dequeueReusableCellWithIdentifier: @"TJBRealizedChainCell"];
                
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


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return self.activeTableViewCells[indexPath.row];
    
}

#pragma mark - <UITableViewDelegate>


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self updateStateVariablesAndCellAppearanceBasedOnSelectedPath: indexPath];
    
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    
        if (self.dailyList.count == 0){
            
            [self.view layoutIfNeeded];
            
            CGFloat heightDeduction = [self toolBarHeightFromBottomOfScreen] + toolBarToContentBottomCushion;
            
            return self.shadowContainer.frame.size.height - heightDeduction;
            
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
        
        NSLog(@"%@", selectedPath);
        
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

#pragma mark - Debugging

- (void)dealloc{
    
    NSLog(@"dealloc");
    
}



@end





















































