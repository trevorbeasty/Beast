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

// presented VC's

#import "TJBLiftOptionsVC.h"


@interface TJBWorkoutNavigationHub () <UITableViewDataSource, UITableViewDelegate>

{
    // state
    
    int _activeSelectionIndex;
}

// IBOutlet


@property (weak, nonatomic) IBOutlet UIButton *liftButton;
@property (weak, nonatomic) IBOutlet UIStackView *dateStackView;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIView *tableViewContainer;



// IBAction

- (IBAction)didPressLiftButton:(id)sender;


// circle dates

@property (nonatomic, strong) NSMutableArray <TJBCircleDateVC *> *circleDateChildren;

// state variables

@property (nonatomic, strong) NSDate *activeDate;

// core data

@property (nonatomic, strong) NSFetchedResultsController *realizedSetFRC;
@property (nonatomic, strong) NSFetchedResultsController *realizeChainFRC;
@property (nonatomic, strong) NSMutableArray *masterList;

@end

@implementation TJBWorkoutNavigationHub

#pragma mark - Instantiation

- (instancetype)init{
    
    self = [super init];
    
    // for restoration
    
    self.restorationClass = [TJBWorkoutNavigationHub class];
    self.restorationIdentifier = @"TJBWorkoutNavigationHub";
    
    // state
    
    self.activeDate = [NSDate date];
    
    // core data
    
    [self configureRealizedSetFRC];
    [self configureRealizedChainFRC];
    [self configureMasterList];
    
    return self;
}

- (void)configureRealizedSetFRC{
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName: @"RealizedSet"];
    
    NSSortDescriptor *dateSort = [NSSortDescriptor sortDescriptorWithKey: @"beginDate"
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
    
    if (!self.masterList){
        
        self.masterList = [[NSMutableArray alloc] init];
        
    }
    
    NSMutableArray *interimArray = [[NSMutableArray alloc] init];
    
    [interimArray addObjectsFromArray: self.realizedSetFRC.fetchedObjects];
    [interimArray addObjectsFromArray: self.realizeChainFRC.fetchedObjects];
    
    [interimArray sortUsingComparator: ^(id obj1, id obj2){
        
        NSDate *obj1Date;
        NSDate *obj2Date;
        
        // identify object class type in order to determine the correct key-value path for the date
        
        // obj1
        
        if ([obj1 isKindOfClass: [TJBRealizedSet class]]){
            
            TJBRealizedSet *obj1WithClass = (TJBRealizedSet *)obj1;
            obj1Date = obj1WithClass.beginDate;
            
            
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
    
    self.masterList = interimArray;
    
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

- (void)viewDidLoad{
    
    [self configureViewAesthetics];
    
    [self configureCircleDates];
    
    [self configureGestureRecognizers];
    
    [self configureTableView];
    
    [self configureTableShadow];
    
}

- (void)configureTableShadow{
    
    UIView *shadowView = self.tableViewContainer;
    shadowView.backgroundColor = [UIColor clearColor];
    shadowView.clipsToBounds = NO;
    
    CALayer *shadowLayer = shadowView.layer;
    shadowLayer.masksToBounds = NO;
    shadowLayer.shadowColor = [UIColor blackColor].CGColor;
    shadowLayer.shadowOffset = CGSizeMake(0, 0);
    shadowLayer.shadowOpacity = .8;
    shadowLayer.shadowRadius = 5.0;
    
}

- (void)configureTableView{
    
    //// register the appropriate table view cells with the table view.  Realized chain and realized set get their own cell types because they display slighty different information
    
    UINib *realizedSetNib = [UINib nibWithNibName: @"TJBRealizedSetCell"
                                           bundle: nil];
    
    [self.tableView registerNib: realizedSetNib
         forCellReuseIdentifier: @"TJBRealizedSetCell"];
    
    UINib *realizedChainNib = [UINib nibWithNibName: @"TJBRealizedChainCell"
                                             bundle: nil];
    
    [self.tableView registerNib: realizedChainNib
         forCellReuseIdentifier: @"TJBRealizedChainCell"];
    
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

- (void)configureCircleDates{
    
    // active selection index
    
    _activeSelectionIndex = 6;
    
    self.circleDateChildren = [[NSMutableArray alloc] init];
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    int numberOfDateButtons = 7;
    float dateButtonSpacing = 8.0;
    CGFloat buttonWidth = (screenWidth - (numberOfDateButtons - 1) * dateButtonSpacing) / (float)numberOfDateButtons;
    
    CGFloat buttonHeight = 40;
    float buttonCenterY = buttonHeight / 2.0;
    
    CGPoint center = CGPointMake(buttonWidth / 2.0, buttonCenterY);
    
    // calendar
    
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier: NSCalendarIdentifierGregorian];
    NSDateComponents *dateComps = [[NSDateComponents alloc] init];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    int dayOffset;
    NSDate *iterativeDate;
    
    BOOL selected;
    
    for (int i = 0; i < numberOfDateButtons; i++){
        
        // using the activeDate as the fourth button, configure all buttons with the appropriate date
        
        dayOffset = -6 + i;
        dateComps.day = dayOffset;
        
        iterativeDate = [calendar dateByAddingComponents: dateComps
                                                  toDate: self.activeDate
                                                 options: 0];
        
        dateFormatter.dateFormat = @"E";
        NSString *day = [dateFormatter stringFromDate: iterativeDate];
        
        dateFormatter.dateFormat = @"d";
        NSString *buttonTitle = [dateFormatter stringFromDate: iterativeDate];
        
        if (i == 6){
            
            selected = YES;
            
        } else{
            
            selected = NO;
            
        }
        
        // create the child vc
        
        TJBCircleDateVC *circleDateVC = [[TJBCircleDateVC alloc] initWithMainButtonTitle: buttonTitle
                                                                                dayTitle: day
                                                                                  radius: buttonWidth / 2.0
                                                                                  center: center
                                                                      selectedAppearance: selected];
        
        [self.circleDateChildren addObject: circleDateVC];
        
        [self addChildViewController: circleDateVC];
        
        [self.dateStackView addArrangedSubview: circleDateVC.view];
        
        [circleDateVC didMoveToParentViewController: self];
        
    }
    
}

- (void)configureViewAesthetics{
    
    NSArray *buttons = @[self.liftButton];
    
    for (UIButton *button in buttons){
        
        button.backgroundColor = [[TJBAestheticsController singleton] color2];
        [button setTitleColor: [UIColor whiteColor]
                     forState: UIControlStateNormal];
        button.titleLabel.font = [UIFont boldSystemFontOfSize: 20.0];
        
    }
    
}


#pragma mark - Button Actions

- (IBAction)didPressLiftButton:(id)sender {
    
    TJBLiftOptionsVC *vc = [[TJBLiftOptionsVC alloc] init];
    
    [self presentViewController: vc
                       animated: NO
                     completion: nil];
    
}


#pragma mark - Gesture Recognizer Actions

- (void)didSwipeLeft{
    
    [self incrementActiveDateByNumberOfDaysAndRefreshCircleDates: -1];
    
}

- (void)didSwipeRight{
    
    [self incrementActiveDateByNumberOfDaysAndRefreshCircleDates: 1];
    
}

- (void)incrementActiveDateByNumberOfDaysAndRefreshCircleDates:(int)numberOfDays{
    
    // active date
    
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier: NSCalendarIdentifierGregorian];
    
    BOOL atMaxDate = [calendar isDateInToday: self.activeDate];
    
    if (!(atMaxDate && numberOfDays == 1)){
        
        NSDateComponents *dateComps = [[NSDateComponents alloc] init];
        dateComps.day = numberOfDays;
        
        NSDate *newDate = [calendar dateByAddingComponents: dateComps
                                                    toDate: self.activeDate
                                                   options: 0];
        
        self.activeDate = newDate;
        
    }
    
    // active index and date button appearance
    
    BOOL atRightExtreme = _activeSelectionIndex == 6 && numberOfDays == 1;
    BOOL atLeftExtreme = _activeSelectionIndex == 0 && numberOfDays == -1;
    
    
    if (!atRightExtreme && !atLeftExtreme){
        
        [self configureSelectedAppearanceForDateButtonAtIndex: _activeSelectionIndex + numberOfDays];
        
    } else if (atLeftExtreme){
        
        // give the date buttons new titles
        
        [self setTitlesAccordingToDate: self.activeDate
                         isLargestDate: YES];
        
        // change the selected date button
        
        [self configureSelectedAppearanceForDateButtonAtIndex: 6];
        
    } else if (atRightExtreme && !atMaxDate){
        
        // give the date buttons new titles
        
        [self setTitlesAccordingToDate: self.activeDate
                         isLargestDate: NO];
        
        // change the selected date button
        
        [self configureSelectedAppearanceForDateButtonAtIndex: 0];
        
    }
    
}

- (void)configureSelectedAppearanceForDateButtonAtIndex:(int)index{
    
    TJBCircleDateVC *circleDateVC =  self.circleDateChildren[_activeSelectionIndex];
    [circleDateVC configureButtonAsNotSelected];
    
    _activeSelectionIndex = index;
    
    circleDateVC =  self.circleDateChildren[_activeSelectionIndex];
    [circleDateVC configureButtonAsSelected];
    
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
    
    return self.masterList.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //// for now, just give the cell text a dynamic name indicating whether it is a a RealizedSet or RealizedChain plus the date
    // conditionals
    
    NSNumber *number = [NSNumber numberWithInteger: indexPath.row + 1];
    
    int rowIndex = (int)indexPath.row;
    
    BOOL isRealizedSet = [self.masterList[rowIndex] isKindOfClass: [TJBRealizedSet class]];
    
    if (isRealizedSet){
        
        TJBRealizedSet *realizedSet = self.masterList[rowIndex];
        
        // dequeue the realizedSetCell
        
        TJBRealizedSetCell *cell = [self.tableView dequeueReusableCellWithIdentifier: @"TJBRealizedSetCell"];
        
        
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        dateFormatter.dateStyle = NSDateFormatterNoStyle;
        dateFormatter.timeStyle = NSDateFormatterShortStyle;
        NSString *date = [dateFormatter stringFromDate: realizedSet.beginDate];
        
        [cell configureCellWithExercise: realizedSet.exercise.name
                                 weight: [NSNumber numberWithFloat: realizedSet.weight]
                                   reps: [NSNumber numberWithFloat: realizedSet.reps]
                                   rest: nil
                                   date: date
                                 number: number];
        
        cell.backgroundColor = [UIColor clearColor];
        
        return cell;
        
    } else{
        
        TJBRealizedChain *realizedChain = self.masterList[rowIndex];
        
        // dequeue the realizedSetCell
        
        TJBRealizedChainCell *cell = [self.tableView dequeueReusableCellWithIdentifier: @"TJBRealizedChainCell"];
        
        [cell configureWithRealizedChain: realizedChain
                                  number: number];
        
        cell.backgroundColor = [UIColor clearColor];
        
        return cell;
        
    }
    
}











#pragma mark - <UITableViewDelegate>

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    BOOL isRealizedSet = [self.masterList[indexPath.row] isKindOfClass: [TJBRealizedSet class]];
//    BOOL isRealizedChain = [self.masterList[indexPath.row] isKindOfClass: [TJBRealizedChain class]];
//    BOOL isLastEntry = indexPath.row == self.masterList.count - 1;
    
    if (isRealizedSet){
        
        return 60;
        
    } else {
        
        TJBRealizedChain *realizedChain = self.masterList[indexPath.row];
        
        return [TJBRealizedChainCell suggestedCellHeightForRealizedChain: realizedChain];
        
    }
 
}















@end





















































