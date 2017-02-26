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

// history

#import "TJBCompleteHistoryVC.h"

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

// presented VC's

#import "TJBLiftOptionsVC.h"

// for prefetching table view cells

#import "TJBCellFetchingOperation.h"

@interface TJBWorkoutNavigationHub () <UITableViewDataSource, UITableViewDelegate, UITableViewDataSourcePrefetching>

{
    // state
    
    int _activeSelectionIndex;
    BOOL _includesHomeButton;
}

// IBOutlet

@property (weak) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *tableViewContainer;
@property (weak, nonatomic) IBOutlet UIButton *leftArrowButton;
@property (weak, nonatomic) IBOutlet UIButton *rightArrowButton;
@property (weak, nonatomic) IBOutlet UILabel *monthTitle;
@property (weak, nonatomic) IBOutlet UIScrollView *dateScrollView;
@property (weak, nonatomic) IBOutlet UILabel *topTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *homeButton;



// IBAction

- (IBAction)didPressLeftArrow:(id)sender;
- (IBAction)didPressRightArrow:(id)sender;
- (IBAction)didPressHomeButton:(id)sender;


// circle dates

@property (nonatomic, strong) UIStackView *dateStackView;
@property (nonatomic, strong) NSMutableArray <TJBCircleDateVC *> *circleDateChildren;

// state

@property (nonatomic, strong) NSDate *activeDate;
@property (nonatomic, strong) NSDate *firstDayOfDateControlMonth;
@property (nonatomic, strong) NSNumber *selectedDateButtonIndex;

// core data

@property (nonatomic, strong) NSFetchedResultsController *realizedSetFRC;
@property (nonatomic, strong) NSFetchedResultsController *realizeChainFRC;
@property (nonatomic, strong) NSMutableArray *masterList;
@property (nonatomic, strong) NSMutableArray *dailyList;

// cell prefetching

@property (strong) NSOperationQueue *operationQueue;

@end

// button specification constants

static const CGFloat buttonWidth = 60.0;
static const CGFloat buttonSpacing = 0.0;
static const CGFloat buttonHeight = 50.0;

// animation

typedef void (^AnimationBlock)(void);
typedef void (^AnimationCompletionBlock)(BOOL);

typedef NSArray<TJBRealizedSet *> *TJBRealizedSetCollection;

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
    
    
    // core data
    
    [self configureRealizedSetFRC];
    [self configureRealizedChainFRC];
    [self configureMasterList];
    [self deriveDailyList];
    
    [self configureNotifications];
    
    // home button
    
    _includesHomeButton = includeHomeButton;
    
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

- (void)configureRealizedSetFRC{
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName: @"RealizedSet"];
    
    NSSortDescriptor *dateSort = [NSSortDescriptor sortDescriptorWithKey: @"endDate"
                                                               ascending: NO];
    
    [request setSortDescriptors: @[dateSort]];
    
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
    
    //// add the fetched objects of the 2 FRC's to a mutable array and reorder it appropriately.  Then, use the array to create the master list.
    // create the interim array and sort it such that it holds realized sets and realized chains with set begin dates and chain created dates, respectively, in descending order
    // add adjacent realized sets with the same exercise to the same TJBRealizedSetCollection.  This type is used to group and present consecutive individual sets of the same exercise in a single table view cell
    // add all realized sets and realized chains to the same array, and then sort them by date is ascending order
    
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
            obj1Date = obj1WithClass.endDate;
            
            
        } else if([obj1 isKindOfClass: [TJBRealizedChain class]]){
            
            TJBRealizedChain *obj1WithClass = (TJBRealizedChain *)obj1;
            obj1Date = obj1WithClass.dateCreated;
            
        }
        
        // obj2
        
        if ([obj2 isKindOfClass: [TJBRealizedSet class]]){
            
            TJBRealizedSet *obj2WithClass = (TJBRealizedSet *)obj2;
            obj2Date = obj2WithClass.beginDate;
            
            
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
    // interim array 2 holds realized chains and TJBRealizedSetCollections
    
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
                    
                    TJBRealizedSetCollection rsc = [NSArray arrayWithArray: stagingArray];
                    
                    [interimArray2 addObject: rsc];
                    
                } else{
                    
                    if (stagingArray.count > 1){
                        
                        TJBRealizedSetCollection rsc = [NSArray arrayWithArray: stagingArray];
                        
                        [interimArray2 addObject: rsc];
                        
                        [interimArray2 addObject: interimArray1[i+1]];
                        
                    } else{
                        
                        [interimArray2 addObject: interimArray1[i]];
                        [interimArray2 addObject: interimArray1[i+1]];
                        
                    }
                    
                }
                
            } else{
                
                if (stagingArray.count > 1){
                    
                    TJBRealizedSetCollection rsc = [NSArray arrayWithArray: stagingArray];
                    
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
            
            TJBRealizedSetCollection rsc = [NSArray arrayWithArray: stagingArray];
            
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
        
        return [[NSCalendar calendarWithIdentifier: NSCalendarIdentifierGregorian] startOfDayForDate: realizedSet.beginDate];
        
    } else{
        
        TJBRealizedChain *realizedChain = object;
        
        return [[NSCalendar calendarWithIdentifier: NSCalendarIdentifierGregorian] startOfDayForDate: realizedChain.dateCreated];
        
    }
    
}

#pragma mark - View Life Cycle

- (void)viewWillAppear:(BOOL)animated{

    //// animation calculations
    // first position
    
    CGFloat firstPositionOffsetX = [self dateSVWidthGivenButtonSpecifications] - [UIScreen mainScreen].bounds.size.width;
    CGPoint firstPosition = CGPointMake(firstPositionOffsetX, 0);
    self.dateScrollView.contentOffset = firstPosition;
    
}

- (void)viewDidAppear:(BOOL)animated{
    
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
    
    [self configureDateControlsAndSelectActiveDate: YES];
    
    [self configureTableView];
    
    [self configureTableShadow];
    
    [self configureOptionalHomeButton];
    
//    [self configureGestureRecognizers];
    
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

- (void)configureTableShadow{
    
    UIView *shadowView = self.tableViewContainer;
    shadowView.backgroundColor = [UIColor clearColor];
    shadowView.clipsToBounds = NO;
    
    CALayer *shadowLayer = shadowView.layer;
    shadowLayer.masksToBounds = NO;
    shadowLayer.shadowColor = [UIColor darkGrayColor].CGColor;
    shadowLayer.shadowOffset = CGSizeMake(0.0, 3.0);
    shadowLayer.shadowOpacity = 1.0;
    shadowLayer.shadowRadius = 3.0;
    
}

- (void)configureTableView{
    
    //// register the appropriate table view cells with the table view.  Realized chain and realized set get their own cell types because they display slighty different information
    
    // for prefetching
    
//    self.tableView.prefetchDataSource = self;
    
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

- (void)configureGestureRecognizers{
    
    // left swipe GR
    
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget: self
                                                                                    action: @selector(didSwipeLeft)];
    
    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    leftSwipe.numberOfTouchesRequired = 1;
    
    [self.view addGestureRecognizer: leftSwipe];
    
    // right swipe GR
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget: self
                                                                                    action: @selector(didSwipeRight)];
    
    rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    rightSwipe.numberOfTouchesRequired = 1;
    
    [self.view addGestureRecognizer: rightSwipe];
    
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
                                                                        isEnabled: !iterativeDateGreaterThanToday
                                                                        isCircled: recordExistsForIterativeDate
                                                                 masterController: self
                                                                  representedDate: [calendar dateFromComponents: dateComps]];
        
        
        
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
        
        return realizedSet.endDate;
        
    } else if (objectIsRealizedChain){
        
        TJBRealizedChain *realizedChain = object;
        
        return realizedChain.dateCreated;
        
    } else{
        
        // if it is not a realized set or realized chain, it must be a TJBRealizedSetCollection
        // simply return the end date of the first realized set
        // I believe they are in asending order (by date), so I am returning the end date of the earliest set
        
        TJBRealizedSetCollection rsc = object;
        
        return rsc[0].endDate;
        
    }
    
}

- (void)configureViewAesthetics{
    
    // scroll view
    
    self.dateScrollView.backgroundColor = [UIColor clearColor];
    
    // month title and arrows
    
    NSArray *titleLabels = @[self.monthTitle, self.topTitleLabel];
    for (UILabel *label in titleLabels){
        
        
        label.backgroundColor = [UIColor darkGrayColor];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont boldSystemFontOfSize: 20.0];
        
    }
    
    self.monthTitle.font = [UIFont boldSystemFontOfSize: 15.0];
    
    NSArray *arrowButtons = @[self.leftArrowButton, self.rightArrowButton];
    for (UIButton *button in arrowButtons){
        
        button.backgroundColor = [UIColor darkGrayColor];
        [button setTitleColor: [UIColor whiteColor]
                     forState: UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize: 40.0];
        
    }
    
}

#pragma mark - Core Data

- (void)mocDidSave{
    
    //// refresh fetched managed objects and all trickle-down
    
    [self configureRealizedSetFRC];
    [self configureRealizedChainFRC];
    [self configureMasterList];
    [self deriveDailyList];
    
    [self.tableView reloadData];
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

- (void)incrementDateControlMonthAndUpdateDateControlsInForwardDirection:(BOOL)inForwardDirection{
    
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


#pragma mark - Gesture Recognizer Actions

- (void)didSwipeLeft{
    
    NSLog(@"swipe left");
    
    [self.tableView setEditing: NO
                      animated: YES];
    
}

- (void)didSwipeRight{
    
    NSLog(@"swipe right");
    
    [self.tableView setEditing: YES
                      animated: YES];
    
}

//- (void)incrementActiveDateByNumberOfDaysAndRefreshCircleDates:(int)numberOfDays{
//    
//    // active date
//    
//    NSCalendar *calendar = [NSCalendar calendarWithIdentifier: NSCalendarIdentifierGregorian];
//    
//    BOOL atMaxDate = [calendar isDateInToday: self.activeDate];
//    
//    if (!(atMaxDate && numberOfDays == 1)){
//        
//        NSDateComponents *dateComps = [[NSDateComponents alloc] init];
//        dateComps.day = numberOfDays;
//        
//        NSDate *newDate = [calendar dateByAddingComponents: dateComps
//                                                    toDate: self.activeDate
//                                                   options: 0];
//        
//        self.activeDate = newDate;
//        
//    }
//    
//    // active index and date button appearance
//    
//    BOOL atRightExtreme = _activeSelectionIndex == 6 && numberOfDays == 1;
//    BOOL atLeftExtreme = _activeSelectionIndex == 0 && numberOfDays == -1;
//    
//    
//    if (!atRightExtreme && !atLeftExtreme){
//        
//        [self configureSelectedAppearanceForDateButtonAtIndex: _activeSelectionIndex + numberOfDays];
//        
//    } else if (atLeftExtreme){
//        
//        // give the date buttons new titles
//        
//        [self setTitlesAccordingToDate: self.activeDate
//                         isLargestDate: YES];
//        
//        // change the selected date button
//        
//        [self configureSelectedAppearanceForDateButtonAtIndex: 6];
//        
//    } else if (atRightExtreme && !atMaxDate){
//        
//        // give the date buttons new titles
//        
//        [self setTitlesAccordingToDate: self.activeDate
//                         isLargestDate: NO];
//        
//        // change the selected date button
//        
//        [self configureSelectedAppearanceForDateButtonAtIndex: 0];
//        
//    }
//    
//}

//- (void)configureSelectedAppearanceForDateButtonAtIndex:(int)index{
//    
//    TJBCircleDateVC *circleDateVC =  self.circleDateChildren[_activeSelectionIndex];
//    [circleDateVC configureButtonAsNotSelected];
//    
//    _activeSelectionIndex = index;
//    
//    circleDateVC =  self.circleDateChildren[_activeSelectionIndex];
//    [circleDateVC configureButtonAsSelected];
//    
//}

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

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // a callback block is created here so that animations are not interrupted
    // deleting an object in core data has a trickle down effect that removes it from the master list.  Notifications cause the daily list to be derived and table view data reloaded upon core data saving
    // delete the managed object and cell designated by the index path
    
    if (editingStyle == UITableViewCellEditingStyleDelete){
        
        // CATransition allows me to control certain animation properties that are otherwise not accessible through the API
        // it is used here to create a completion block, which is not possible otherwise
        
        __weak TJBWorkoutNavigationHub *weakSelf = self;
        
        [CATransaction begin];
        
        // if only one content cell remains, must insert a no data cell
        
        BOOL oneContentCell = self.dailyList.count == 1;
        
        id dailyListObject = weakSelf.dailyList[indexPath.row -1];
        [self.dailyList removeObjectAtIndex: indexPath.row - 1];
        
        [CATransaction setCompletionBlock: ^{
            
            BOOL isRealizedSet = [dailyListObject isKindOfClass: [TJBRealizedSet class]];
            BOOL isRealizedChain = [dailyListObject isKindOfClass: [TJBRealizedChain class]];
            
            if (isRealizedSet){
                
                [[[CoreDataController singleton] moc] deleteObject: dailyListObject];
                
            } else if (isRealizedChain){
                
                [[CoreDataController singleton] deleteChainWithChainType: RealizedChainType
                                                                   chain: dailyListObject];
                
            } else{
                
                // it must be a collection of realized sets in this case
                
                for (TJBRealizedSet *realizedSet in dailyListObject){
                    
                    [[[CoreDataController singleton] moc] deleteObject: realizedSet];
                    
                }
            }
            
            [[CoreDataController singleton] saveContext];
        
        }];
        
        // these are the core messages that delete the row
        
        [self.tableView beginUpdates];
        
        [self.tableView deleteRowsAtIndexPaths: @[indexPath]
                              withRowAnimation: UITableViewRowAnimationNone];
        
        if (oneContentCell){
            
            // insert cell
            
            NSIndexPath *path = [NSIndexPath indexPathForRow: 1
                                                   inSection: 0];
            
            [self.tableView insertRowsAtIndexPaths: @[path]
                                  withRowAnimation: UITableViewRowAnimationNone];
            
        }
        
        [self.tableView endUpdates];
        
        [CATransaction commit];
        
    }
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (self.dailyList.count == 0){
        
        return 2;
        
    } else{
        
        return self.dailyList.count + 1;
        
    }
    
}

- (UITableViewCell *)cellForIndexPath:(NSIndexPath *)indexPath{
    
    //// for now, just give the cell text a dynamic name indicating whether it is a a RealizedSet or RealizedChain plus the date
    // if the row index is 0, it is the title cell
    
    if (indexPath.row == 0){
        
        TJBWorkoutLogTitleCell *cell = [self.tableView dequeueReusableCellWithIdentifier: @"TJBWorkoutLogTitleCell"];
        
        
        
        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
        BOOL isToday = [calendar isDate: self.activeDate
                        inSameDayAsDate: [NSDate date]];
        
        if (isToday){
            
            cell.secondaryLabel.text = @"Today";
            
        } else{
            
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            df.dateFormat = @"EEEE, MMMM d, yyyy";
            cell.secondaryLabel.text = [df stringFromDate: self.activeDate];
            
        }
        
        cell.primaryLabel.text = @"My Workout Log";
        cell.backgroundColor = [UIColor clearColor];
        
        return cell;
        
    } else{
        
        if (self.dailyList.count == 0){
            
            TJBNoDataCell *cell = [self.tableView dequeueReusableCellWithIdentifier: @"TJBNoDataCell"];
            
            cell.mainLabel.text = @"No Entries";
            cell.backgroundColor = [UIColor clearColor];
            
            return cell;
            
        } else{
            
            NSNumber *number = [NSNumber numberWithInteger: indexPath.row];
            
            int rowIndex = (int)indexPath.row - 1;
            
            BOOL isRealizedSet = [self.dailyList[rowIndex] isKindOfClass: [TJBRealizedSet class]];
            BOOL isRealizedChain = [self.dailyList[rowIndex] isKindOfClass: [TJBRealizedChain class]];
            
            if (isRealizedSet){
                
                TJBRealizedSet *realizedSet = self.dailyList[rowIndex];
                
                // dequeue the realizedSetCell
                
                TJBRealizedSetCell *cell = [self.tableView dequeueReusableCellWithIdentifier: @"TJBRealizedSetCell"];
                
                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
                dateFormatter.dateStyle = NSDateFormatterNoStyle;
                dateFormatter.timeStyle = NSDateFormatterShortStyle;
                NSString *date = [dateFormatter stringFromDate: realizedSet.endDate];
                
                [cell configureCellWithExercise: realizedSet.exercise.name
                                         weight: [NSNumber numberWithFloat: realizedSet.weight]
                                           reps: [NSNumber numberWithFloat: realizedSet.reps]
                                           rest: nil
                                           date: date
                                         number: number];
                
                cell.backgroundColor = [UIColor clearColor];
                
                return cell;
                
            } else if (isRealizedChain){
                
                TJBRealizedChain *realizedChain = self.dailyList[rowIndex];
                
                // dequeue the realizedSetCell
                
                TJBRealizedChainCell *cell = [self.tableView dequeueReusableCellWithIdentifier: @"TJBRealizedChainCell"];
                
                [cell clearExistingEntries];
                
                [cell configureWithRealizedChain: realizedChain
                                          number: number
                                       finalRest: nil];
                
                cell.backgroundColor = [UIColor clearColor];
                
                return cell;
                
            } else{
                
                // if it is not a realized set or realized chain, then it is a TJBRealizedSetCollection
                
                TJBRealizedSetCollectionCell *cell = [self.tableView dequeueReusableCellWithIdentifier: @"TJBRealizedSetCollectionCell"];
                
                [cell clearExistingEntries];
                
                cell.backgroundColor = [UIColor clearColor];
                
                [cell configureWithRealizedSetCollection: self.dailyList[rowIndex]
                                                  number: number
                                               finalRest: nil];
                
                return cell;
                
            }
        }
    }
    
}

- (TJBCellFetchingOperation *)operationForIndexPath:(NSIndexPath *)indexPath{
    
    // search for the operation designated by the passed-in index path.  If one does not exist, return nil
    
    if (self.operationQueue){
        
        for (TJBCellFetchingOperation *operation in self.operationQueue.operations){
            
            BOOL match = [self indexForOperation: operation
                                    matchesIndex: indexPath];
            
            if (match){
                
                return operation;
                
            }
        }
    }
    
    // if the control reaches this point, then no matches were found. Return nil
    
    return nil;
    
}

- (BOOL)indexForOperation:(TJBCellFetchingOperation *)operation matchesIndex:(NSIndexPath *)indexPath{
    
    BOOL sectionMatch = operation.indexPath.section == indexPath.section;
    BOOL rowMatch = operation.indexPath.row == indexPath.row;
    
    return  sectionMatch && rowMatch;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // check the operation queue for the specified index path.  If the cell has already been prepared, use that cell.  Otherwise, create and configure the cell
    // must check for existence of queue
    
    if (self.operationQueue){
        
//        NSLog(@"prefetch");
        
        // fetch the operation.  Will return nil when not found
        
        TJBCellFetchingOperation *operation = [self operationForIndexPath: indexPath];
        
        if (operation){
            
            // must evaluate the status of the operation in order to determine the appropriate course of action
            
            if (operation.isExecuting){
                
                [operation waitUntilFinished];
                
                return operation.result;
                
            } else if (operation.isFinished){
                
                return operation.result;
                
            } else{
                
                return [self cellForIndexPath: indexPath];
                
            }
            
        } else{
            
            return [self cellForIndexPath: indexPath];
            
        }
        
    } else{
        
//        NSLog(@"normal");
        
        // if there is no operation queue, create the cell as would normally be done
        
        NSLog(@"%lu", self.dailyList.count);
        
        return [self cellForIndexPath: indexPath];
        
    }
    
    
    
//    //// for now, just give the cell text a dynamic name indicating whether it is a a RealizedSet or RealizedChain plus the date
//    // if the row index is 0, it is the title cell
//    
//    if (indexPath.row == 0){
//        
//        TJBWorkoutLogTitleCell *cell = [self.tableView dequeueReusableCellWithIdentifier: @"TJBWorkoutLogTitleCell"];
//        
//        
//        
//        NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
//        BOOL isToday = [calendar isDate: self.activeDate
//                        inSameDayAsDate: [NSDate date]];
//        
//        if (isToday){
//            
//            cell.secondaryLabel.text = @"Today";
//            
//        } else{
//            
//            NSDateFormatter *df = [[NSDateFormatter alloc] init];
//            df.dateFormat = @"EEEE, MMMM d, yyyy";
//            cell.secondaryLabel.text = [df stringFromDate: self.activeDate];
//            
//        }
//        
//        cell.primaryLabel.text = @"My Workout Log";
//        cell.backgroundColor = [UIColor clearColor];
//        
//        return cell;
//        
//    } else{
//        
//        if (self.dailyList.count == 0){
//            
//            TJBNoDataCell *cell = [self.tableView dequeueReusableCellWithIdentifier: @"TJBNoDataCell"];
//            
//            cell.mainLabel.text = @"No Entries";
//            cell.backgroundColor = [UIColor clearColor];
//            
//            return cell;
//            
//        } else{
//            
//            NSNumber *number = [NSNumber numberWithInteger: indexPath.row];
//            
//            int rowIndex = (int)indexPath.row - 1;
//            
//            BOOL isRealizedSet = [self.dailyList[rowIndex] isKindOfClass: [TJBRealizedSet class]];
//            BOOL isRealizedChain = [self.dailyList[rowIndex] isKindOfClass: [TJBRealizedChain class]];
//            
//            if (isRealizedSet){
//                
//                TJBRealizedSet *realizedSet = self.dailyList[rowIndex];
//                
//                // dequeue the realizedSetCell
//                
//                TJBRealizedSetCell *cell = [self.tableView dequeueReusableCellWithIdentifier: @"TJBRealizedSetCell"];
//                
//                NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//                dateFormatter.dateStyle = NSDateFormatterNoStyle;
//                dateFormatter.timeStyle = NSDateFormatterShortStyle;
//                NSString *date = [dateFormatter stringFromDate: realizedSet.endDate];
//                
//                [cell configureCellWithExercise: realizedSet.exercise.name
//                                         weight: [NSNumber numberWithFloat: realizedSet.weight]
//                                           reps: [NSNumber numberWithFloat: realizedSet.reps]
//                                           rest: nil
//                                           date: date
//                                         number: number];
//                
//                cell.backgroundColor = [UIColor clearColor];
//                
//                return cell;
//                
//            } else if (isRealizedChain){
//                
//                TJBRealizedChain *realizedChain = self.dailyList[rowIndex];
//                
//                // dequeue the realizedSetCell
//                
//                TJBRealizedChainCell *cell = [self.tableView dequeueReusableCellWithIdentifier: @"TJBRealizedChainCell"];
//                
//                [cell clearExistingEntries];
//                
//                [cell configureWithRealizedChain: realizedChain
//                                          number: number
//                                       finalRest: nil];
//                
//                cell.backgroundColor = [UIColor clearColor];
//                
//                return cell;
//                
//            } else{
//                
//                // if it is not a realized set or realized chain, then it is a TJBRealizedSetCollection
//                
//                TJBRealizedSetCollectionCell *cell = [self.tableView dequeueReusableCellWithIdentifier: @"TJBRealizedSetCollectionCell"];
//                
//                [cell clearExistingEntries];
//                
//                cell.backgroundColor = [UIColor clearColor];
//                
//                [cell configureWithRealizedSetCollection: self.dailyList[rowIndex]
//                                                  number: number
//                                               finalRest: nil];
//                
//                return cell;
//                
//            }
//        }
//    }
}











#pragma mark - <UITableViewDelegate>

- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.dailyList.count == 0){
        
        return UITableViewCellEditingStyleNone;
        
    } else if (indexPath.row == 0){
        
        return UITableViewCellEditingStyleNone;
        
    } else{
        
        return UITableViewCellEditingStyleDelete;
        
    }
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat titleHeight = 60.0;
    
    if (indexPath.row == 0){
        
        return titleHeight;
        
    } else{
        
        if (self.dailyList.count == 0){
            
            [self.view layoutIfNeeded];
            
            return self.tableView.frame.size.height - titleHeight;
            
        } else{
            
            NSInteger adjustedIndex = indexPath.row - 1;
            
            BOOL isRealizedSet = [self.dailyList[adjustedIndex] isKindOfClass: [TJBRealizedSet class]];
            BOOL isRealizedChain = [self.dailyList[adjustedIndex] isKindOfClass: [TJBRealizedChain class]];
            
            
            if (isRealizedSet){
                
                return 60;
                
            } else if (isRealizedChain) {
                
                TJBRealizedChain *realizedChain = self.dailyList[adjustedIndex];
                
                return [TJBRealizedChainCell suggestedCellHeightForRealizedChain: realizedChain];
                
            } else{
                
                TJBRealizedSetCollection rsc = self.dailyList[adjustedIndex];
                
                return [TJBRealizedSetCollectionCell suggestedCellHeightForRealizedSetCollection: rsc];
                
            }
        }
    }
}


#pragma mark - <TJBDateSelectionMaster>

- (void)didSelectObjectWithIndex:(NSNumber *)index representedDate:(NSDate *)representedDate{
    
    if (self.selectedDateButtonIndex){
        
        [self.circleDateChildren[[self.selectedDateButtonIndex intValue]] configureButtonAsNotSelected];
        
    }
    
    [self.circleDateChildren[[index intValue]] configureButtonAsSelected];
    
    self.selectedDateButtonIndex = index;
    
    self.activeDate = representedDate;
    [self deriveDailyList];
    [self.tableView reloadData];
    
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

#pragma mark - <UITableViewDataSourcePrefetching>

- (void)tableView:(UITableView *)tableView prefetchRowsAtIndexPaths:(NSArray<NSIndexPath *> *)indexPaths{
    
    // if there is no operation queue, create one
    
    if (!self.operationQueue){
        
        self.operationQueue = [[NSOperationQueue alloc] init];
        
    }
    
    for (NSIndexPath *path in indexPaths){
        
        // create the operation object for the given index path
        
        TJBCellFetchingOperation *operation = [[TJBCellFetchingOperation alloc] initWithTarget: self
                                                                                      selector: @selector(cellForIndexPath:)
                                                                                        object: path];
        // add the operation object to the operation queue
        
        [self.operationQueue addOperation: operation];
        
    }
    
}

@end





















































