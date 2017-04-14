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

#import "TJBRealizedSetCell.h"
#import "TJBRealizedChainCell.h"
#import "TJBWorkoutLogTitleCell.h"
#import "TJBNoDataCell.h"
#import "TJBRealizedSetCollectionCell.h"
#import "TJBMasterCell.h"

// presented VC's

#import "TJBLiftOptionsVC.h"

// cell preloading

#import "TJBCellFetchingOperation.h"

@interface TJBWorkoutNavigationHub () <UITableViewDataSource, UITableViewDelegate>

{
    // state
    
    int _activeSelectionIndex;
    BOOL _includesHomeButton;
    BOOL _cellsNeedUpdating; // used to indicate that core data has saved during this controller's lifetime while a different tab of the tab bar controller was selected
    
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
@property (weak, nonatomic) IBOutlet UIButton *todayButton;
@property (weak, nonatomic) IBOutlet UIView *titleBarContainer;
@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;

// IBAction

- (IBAction)didPressLeftArrow:(id)sender;
- (IBAction)didPressRightArrow:(id)sender;
- (IBAction)didPressHomeButton:(id)sender;
- (IBAction)didPressTodayButton:(id)sender;


// circle dates

@property (strong) UIStackView *dateStackView;
@property (strong) NSMutableArray <TJBCircleDateVC *> *circleDateChildren;

// state

@property (strong) NSDate *activeDate;
@property (strong) NSDate *firstDayOfDateControlMonth;
@property (strong) NSNumber *selectedDateButtonIndex;
@property (strong) UIActivityIndicatorView *activityIndicatorView;
@property (strong) NSNumber *scrollPositionForUpdate;

// core data

@property (strong) NSFetchedResultsController *realizedSetFRC;
@property (strong) NSFetchedResultsController *realizeChainFRC;
@property (strong) NSMutableArray *masterList;
@property (strong) NSMutableArray *dailyList;

@property (strong) NSMutableArray *activeTableViewCells;

@end

// button specification constants

static const CGFloat buttonWidth = 60.0;
static const CGFloat buttonSpacing = 0.0;
static const CGFloat buttonHeight = 55.0;

// animation

typedef void (^AnimationBlock)(void);
typedef void (^AnimationCompletionBlock)(BOOL);

typedef NSArray<TJBRealizedSet *> *TJBRealizedSetGrouping;

@implementation TJBWorkoutNavigationHub

#pragma mark - Instantiation

- (instancetype)initWithHomeButton:(BOOL)includeHomeButton{
    
    self = [super init];
    
    // for restoration
    
    self.restorationClass = [TJBWorkoutNavigationHub class];
    self.restorationIdentifier = @"TJBWorkoutNavigationHub";
    
    // state
    // set the active date as well of the first day of the month for date control
    
    NSDate *today = [NSDate date];
    
    self.activeDate = today;
    
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier: NSCalendarIdentifierGregorian];
    NSDateComponents *dateComps = [calendar components: (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
                                              fromDate: today];
    [dateComps setDay: 1];
    self.firstDayOfDateControlMonth = [calendar dateFromComponents: dateComps];
    
    [self configureNotifications];
    
    // home button
    
    _includesHomeButton = includeHomeButton;
    
    // core data
    
    [self configureRealizedSetFRC];
    [self configureRealizedChainFRC];
    [self configureMasterList];
    
    return self;
}

- (void)configureNotifications{
    
    //// configure managed context notification for updating
    
    NSManagedObjectContext *moc = [[CoreDataController singleton] moc];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                            selector: @selector(mocDidSave)
                                                name: NSManagedObjectContextDidSaveNotification
                                               object: moc];
    
}

#pragma mark - Core Data Queries

- (void)configureRealizedSetFRC{
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName: @"RealizedSet"];
    
    NSSortDescriptor *dateSort = [NSSortDescriptor sortDescriptorWithKey: @"submissionTime"
                                                               ascending: NO];
    [request setSortDescriptors: @[dateSort]];
    
    NSPredicate *standaloneSetPredicate = [NSPredicate predicateWithFormat: @"isStandaloneSet = YES"]; // only retrieve standalone sets. Realized chains are retrieved separately
    request.predicate = standaloneSetPredicate;
    
    NSManagedObjectContext *moc = [[CoreDataController singleton] moc];
    
    NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest: request
                                                                          managedObjectContext: moc
                                                                            sectionNameKeyPath: nil
                                                                                     cacheName: nil];
    frc.delegate = nil;
    
    self.realizedSetFRC = frc;
    
    NSError *error = nil;
    
    if (![frc performFetch: &error]){
        
        abort();
        
    }
    
    return;
    
}


- (void)configureRealizedChainFRC{
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName: @"RealizedChain"];
    
    NSSortDescriptor *dateSort = [NSSortDescriptor sortDescriptorWithKey: @"dateCreated"
                                                               ascending: NO];
    
    [request setSortDescriptors: @[dateSort]];
    
    NSManagedObjectContext *moc = [[CoreDataController singleton] moc];
    
    NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest: request
                                                                          managedObjectContext: moc
                                                                            sectionNameKeyPath: nil
                                                                                     cacheName: nil];
    frc.delegate = nil;
    
    self.realizeChainFRC = frc;
    
    NSError *error = nil;
    
    if (![frc performFetch: &error]){
        
        abort();
        
    }
    
}

- (void)configureMasterList{
    
    NSMutableArray *interimArray1 = [[NSMutableArray alloc] init];
    
    [interimArray1 addObjectsFromArray: self.realizedSetFRC.fetchedObjects];
    [interimArray1 addObjectsFromArray: self.realizeChainFRC.fetchedObjects];
    
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

#pragma mark - View Life Cycle

// viewWillAppear and viewDidAppear are used to handle the animation that slides the date scroll view from right to left when the workout log becomes visible

- (void)viewWillAppear:(BOOL)animated{

    //// animation calculations
    // first position
    
    [self configureInitialDateControlAnimationPosition];
    
//    CGFloat firstPositionOffsetX = [self dateSVWidthGivenButtonSpecifications] - [UIScreen mainScreen].bounds.size.width;
//    CGPoint firstPosition = CGPointMake(firstPositionOffsetX, 0);
//    self.dateScrollView.contentOffset = firstPosition;
    
    // the following is used to update the cells if core data was updated while this controller existed but was not the active view controller (in the tab bar controller). The core data update will have prompted this controller to refetch core data objects and derive the master list. The following logic will then derive the daily list and active cells, showing the activity indicator while doing so
    
    if (_cellsNeedUpdating){
        
        NSInteger dayAsIndex = [self dayIndexForDate: self.activeDate];
        
        [self didSelectObjectWithIndex: @(dayAsIndex)
                       representedDate: self.activeDate];
        
        // the date controls should also be reloaded, in case a day that previously had not content now contains content
        
        [self configureDateControlsAndSelectActiveDate: YES];
        
        // update the state variable to reflect that cells no longer need updating
        
        _cellsNeedUpdating = NO;
        
    }
    
}

- (void)configureInitialDateControlAnimationPosition{
    
    CGFloat firstPositionOffsetX = [self dateSVWidthGivenButtonSpecifications] - [UIScreen mainScreen].bounds.size.width;
    CGPoint firstPosition = CGPointMake(firstPositionOffsetX, 0);
    self.dateScrollView.contentOffset = firstPosition;
    
}

- (void)viewDidAppear:(BOOL)animated{
    
    [self executeDateControlAnimation];
    
}

- (void)executeDateControlAnimation{
    
    // second position
    
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier: NSCalendarIdentifierGregorian];
    NSInteger day = [calendar component: NSCalendarUnitDay
                               fromDate: self.activeDate];
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

- (void)viewDidLoad{
    
    [self configureViewAesthetics];
    
    [self configureToolBar];
    
    [self configureDateControlsAndSelectActiveDate: YES];
    
    [self configureOptionalHomeButton];
    
    [self artificiallySelectToday];
    
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
    
    //// register the appropriate table view cells with the table view.  Realized chain and realized set get their own cell types because they display slighty different information
    
    // for prefetching
    
    UINib *realizedSetNib = [UINib nibWithNibName: @"TJBRealizedSetCell"
                                           bundle: nil];
    
    [self.tableView registerNib: realizedSetNib
         forCellReuseIdentifier: @"TJBRealizedSetCell"];
    
    UINib *realizedChainNib = [UINib nibWithNibName: @"TJBRealizedChainCell"
                                             bundle: nil];
    
    [self.tableView registerNib: realizedChainNib
         forCellReuseIdentifier: @"TJBRealizedChainCell"];
    
    UINib *titleCellNib = [UINib nibWithNibName: @"TJBWorkoutLogTitleCell"
                                         bundle: nil];
    
    [self.tableView registerNib: titleCellNib
         forCellReuseIdentifier: @"TJBWorkoutLogTitleCell"];
    
    UINib *noDataCell = [UINib nibWithNibName: @"TJBNoDataCell"
                                       bundle: nil];
    
    [self.tableView registerNib: noDataCell
         forCellReuseIdentifier: @"TJBNoDataCell"];
    
    UINib *realizedSetCollectionCell = [UINib nibWithNibName: @"TJBRealizedSetCollectionCell"
                                                      bundle: nil];
    
    [self.tableView registerNib: realizedSetCollectionCell
         forCellReuseIdentifier: @"TJBRealizedSetCollectionCell"];
    
}


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





- (void)configureDateControlsAndSelectActiveDate:(BOOL)shouldSelectActiveDate{
    
    //// configures the date controls according to the day stored in firstDayOfDateControlMonth.  Must be sure to first clear existing date control objects if they exist
    
    [self clearTransitoryDateControlObjects];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    
    //// month title
    
    df.dateFormat = @"MMMM yyyy";
    NSString *monthTitle = [df stringFromDate: self.firstDayOfDateControlMonth];
    self.monthTitle.text = monthTitle;
    
    //// stack view and child VC's
    
    // stack view dimensions.  Need to know number of days in month and define widths of contained buttons
    
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier: NSCalendarIdentifierGregorian];
    NSRange daysInCurrentMonth = [calendar rangeOfUnit: NSCalendarUnitDay
                                                inUnit: NSCalendarUnitMonth
                                               forDate: self.firstDayOfDateControlMonth];
    

    
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
                                              fromDate: self.firstDayOfDateControlMonth];
    
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
        
        if (shouldSelectActiveDate){

            isTheActiveDate = [calendar isDate: iterativeDate
                               inSameDayAsDate: self.activeDate];
            
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

- (void)configureViewAesthetics{
    
    // today button
    
    self.todayButton.backgroundColor = [UIColor clearColor];

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

    
}

- (NSString *)workoutLogTitleText{
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"MMM d, yyyy";
    NSString *formattedDate = [df stringFromDate: self.activeDate];
    
    return  [NSString stringWithFormat: @"%@", formattedDate];
    
}

#pragma mark - Toolbar

- (void)configureToolBar{
    
    
    
}

#pragma mark - Core Data

- (void)mocDidSave{
    
    //// refresh fetched managed objects and all trickle-down
    // the daily list is derived whenever a date control object is selected. Even when a date control object is not explicitly selected by the user, I programmatically make the selection to select the desired day.
    
    [self configureRealizedSetFRC];
    [self configureRealizedChainFRC];
    [self configureMasterList];
    
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

- (IBAction)didPressTodayButton:(id)sender{
    
    NSCalendar * calendar = [NSCalendar calendarWithIdentifier: NSCalendarIdentifierGregorian];
    NSDate *today = [NSDate date];
    
    // the date controls are governed by the 'firstDayOfDateControlMonth' property. Get the first day of the current month and assign it to this property. Then call 'configureDateControlsAndSelectActiveDate'
    
    
    NSDateComponents *dateControlComps = [calendar components: (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
                                                     fromDate: today];
    
    dateControlComps.day = 1;
    
    self.firstDayOfDateControlMonth = [calendar dateFromComponents: dateControlComps];
    
    [self configureDateControlsAndSelectActiveDate: NO];
    
    // make today the active date and load the proper date controls and artificially select today
    
    self.activeDate = today;
    
    NSInteger dayAsIndex = [self dayIndexForDate: self.activeDate];
    
    [self didSelectObjectWithIndex: @(dayAsIndex)
                   representedDate: self.activeDate];
    
    // date control animation
    
    [self configureInitialDateControlAnimationPosition];
    [self executeDateControlAnimation];
    
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
                                              fromDate: self.firstDayOfDateControlMonth];
    dateComps.month += monthDelta;
    self.firstDayOfDateControlMonth = [calendar dateFromComponents: dateComps];
    
    [self configureDateControlsAndSelectActiveDate: NO];
    
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
        
        newSmallDate = self.activeDate;
        
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
                                    dateTimeType: TJBMaxDetailDate
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
                                    dateTimeType: TJBMaxDetailDate
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
                                    dateTimeType: TJBMaxDetailDate
                                     titleNumber: number];
                
                return cell;
                
            }
        }

    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return self.activeTableViewCells[indexPath.row];
    
}

#pragma mark - <UITableViewDelegate>


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{

    
        if (self.dailyList.count == 0){
            
            [self.view layoutIfNeeded];
            
            return self.shadowContainer.frame.size.height;
            
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


#pragma mark - <TJBDateSelectionMaster>

- (void)artificiallySelectToday{

    // extract the day component to back solve for the date object index
    
    NSDate *today = [NSDate date];
    
    NSInteger dayAsIndex = [self dayIndexForDate: today];

    [self didSelectObjectWithIndex: @(dayAsIndex)
                   representedDate: today];
    
}

- (NSInteger)dayIndexForDate:(NSDate *)date{
    
    // extract the day component to back solve for the date object index
    
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier: NSCalendarIdentifierGregorian];
    NSInteger day = [calendar component: NSCalendarUnitDay
                               fromDate: date];
    
    // correct for indexing
    
    day -= 1;
    
    return day;
    
}

- (void)didSelectObjectWithIndex:(NSNumber *)index representedDate:(NSDate *)representedDate{
    
    // present an activity indicator and also dull the date selection options and home button
    // I am disabling user interaction while cell content is being loaded because I have no better alternative.  All UI objects must be manipulated on the main thread, which is the thread that serially handles user interaction.  The cells take a relatively long time to prepare (a second or two) when the daily list for a particular day is very long (about 40+ chain objects).  This is the major work being done when a user presses a date control button - the daily list is derived in addition to loading all cells, but the derivation of the daily list takes relatively no time.  Even if I try to create an operation object and dispatch it in a background queue, the odds that the user will be able to press a date before the main queue begins loading cells is almost zero.  Essentialy, I would need to find a way to drastically reduce the amount of UI work that needs to be done if I want to increase app responsiveness and leave the main thread open to accept and process new events
    
    if (!self.activityIndicatorView){
        
        UIActivityIndicatorView *aiView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
        
        aiView.frame = self.shadowContainer.frame;
        aiView.hidesWhenStopped = YES;
        aiView.backgroundColor = [[TJBAestheticsController singleton] yellowNotebookColor];
        
        aiView.layer.opacity = .9;
        
        self.activityIndicatorView = aiView;
        
        [self.view addSubview: aiView];
        
        [self.activityIndicatorView startAnimating];
        
    }
    
    // immediately change the colors of the previously selected and newly selected controls
    
    if (self.selectedDateButtonIndex){
        
        [self.circleDateChildren[[self.selectedDateButtonIndex intValue]] configureButtonAsNotSelected];
        
    }
    
    [self.circleDateChildren[[index intValue]] configureButtonAsSelected];
    
    // reduce opacity of buttons and disable them until the cells have loaded
    
    for (TJBCircleDateVC *circVC in self.circleDateChildren){
        
        [circVC configureDisabledAppearance];
        
    }
    
    NSArray *buttons = @[self.homeButton, self.todayButton];
    for (UIButton *b in buttons){
        
        b.enabled = NO;
        b.layer.opacity = .4;
        
    }
    
    NSArray *arrows = @[self.leftArrowButton, self.rightArrowButton];
    for (UIButton *b in arrows){
        
        b.enabled = NO;
        b.layer.opacity = .4;
        
    }
    
    // state
    
    self.selectedDateButtonIndex = index;
    self.activeDate = representedDate;
    
    [self.view layoutIfNeeded];
    
    [self performSelector: @selector(prepareNewContentCellsAndRemoveActivityIndicator)
               withObject: nil
               afterDelay: .2];
    
    [self.view setNeedsDisplay];
    
}

- (void)prepareNewContentCellsAndRemoveActivityIndicator{
    
    [self deriveDailyList];
    
    // call the table view cellForIndexPath method for all daily list cells and store the results
    
    [self deriveActiveCellsAndCreateTableView];
    
    [self.tableView reloadData];
    
    // remove activity indicator and give the buttons active appearance / functionality
    
    [self.activityIndicatorView removeFromSuperview];
    self.activityIndicatorView = nil;
    
    for (TJBCircleDateVC *circVC in self.circleDateChildren){
        
        [circVC configureEnabledAppearance];
        
    }
    
    NSArray *buttons = @[self.homeButton, self.todayButton];
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
    
    CGSize contentSize = CGSizeMake(self.shadowContainer.frame.size.width, totalHeight);
    
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
    
    sv.layer.masksToBounds = YES;
    sv.scrollEnabled = YES;
    
    newTableView.frame = CGRectMake(0, 0, contentSize.width, contentSize.height);
    
    [sv addSubview: newTableView];
    [self.shadowContainer addSubview: sv];
    
    return;
    
}


- (void)deriveDailyList{
    
    //// creats the dailyList from the masterList based on the active date and updates the table view
    
    self.dailyList = [[NSMutableArray alloc] init];
    
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier: NSCalendarIdentifierGregorian];
    
    for (NSObject *object in self.masterList){
        
        NSDate *objectDate = [self dateForRecordObject: object];
        
        BOOL recordIsForActiveDate = [calendar isDate: objectDate
                                      inSameDayAsDate: self.activeDate];
        
        if (recordIsForActiveDate){
            
            [self.dailyList addObject: object];
            
        }
        
    }
    
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
                                               forDate: self.firstDayOfDateControlMonth];
    
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





















































