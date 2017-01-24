//
//  TJBCompleteHistoryVC.m
//  Beast
//
//  Created by Trevor Beasty on 1/17/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBCompleteHistoryVC.h"

// core data

#import "CoreDataController.h"

// table view cells

#import "RealizedChainTableViewCell.h"
#import "RealizedSetHistoryCell.h"

// aesthetics

#import "TJBAestheticsController.h"

// realized chain history

#import "TJBRealizedChainHistoryVC.h"




@interface TJBCompleteHistoryVC () <UITableViewDelegate, UITableViewDataSource, UIViewControllerRestoration>

// IBOutlet

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UITableView *historyTableView;

// core data

@property (nonatomic, strong) NSFetchedResultsController *realizedSetFRC;
@property (nonatomic, strong) NSFetchedResultsController *realizeChainFRC;

@property (nonatomic, strong) NSMutableArray *masterList;

@end






@implementation TJBCompleteHistoryVC

#pragma mark - Init

- (instancetype)init{
    
    //// this controller requires 2 NSFetchedResultsControllers because a fetched result controller can only handle 1 entity.  These FRC's will be instantiated in the init method and their resulting arrays will be combined into one master array.  This master array will be in descending date order and the table view will group sections according to day.  Clicking a realized set will do nothing.  Clicking a realized chain will present the realized chain
    
    self = [super init];
    
    // fetched results and master list.  Order dependent - the fetches must be executed before the master list can be populated
    
    [self configureRealizedSetFRC];
    
    [self configureRealizedChainFRC];
    
    [self configureMasterList];
    
    // for restoration
    
    [self setRestorationProperties];
    
    return self;
    
}

- (void)setRestorationProperties{
    
    //// for restoration
    
    self.restorationClass = [TJBCompleteHistoryVC class];
    self.restorationIdentifier = @"TJBCompleteHistoryVC";
    
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
    
    //// add the fetched objects of the 2 FRC's to a mutable array and reorder it appropriately.  Then, use the array to create the master list.  Master list will be an array of arrays, with the first set of indices designating section and the second set of indices designating row
    
    // create the interim array and sort it such that it holds realized sets and realized chains with set begin dates and chain created dates, respectively, in descending order
    
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
            
            return NSOrderedDescending;
            
        } else {
            
            return  NSOrderedAscending;
            
        }
    }];
    
    // use the resulting array to create the master list as specified in this method definition
    
    NSMutableArray *masterList = [[NSMutableArray alloc] init];
    self.masterList = masterList;
    
    // the following logic breaks for an interim array of count zero, so this logic is performed here to prevent the following logic from ever being performed if the interim array has no items
    
    if ([interimArray count] == 0){
        
        self.masterList = masterList;
        return;
        
    }
    
    // must iterate through the entire interim array.  A begin of day date is always calculated and each item's date is compared against this.  Create a new subarray when the item's date is less than and add the item to the current subarray when it's greater than
    
    NSDate *currentDayBeginDate = [self dayBeginDateForObject: interimArray[0]];
    
    int limit = (int)[interimArray count];
    int currentSectionIndex = 0;
    
    NSMutableArray *currentSectionArray = [[NSMutableArray alloc] init];
    [currentSectionArray addObject: interimArray[0]];
    
    [masterList addObject: currentSectionArray];
    
    // iteration correctly begins at 1.  Zeroth item is added in preceding logic
    
    for (int i = 1; i < limit; i++){
        
        NSDate *currentItemDate;
        
        BOOL iterativeItemIsRealizedSet = [interimArray[i] isKindOfClass: [TJBRealizedSet class]];
        
        if (iterativeItemIsRealizedSet){
            
            TJBRealizedSet *realizedSet = interimArray[i];
            
            currentItemDate = realizedSet.beginDate;
            
        } else{
            
            TJBRealizedChain *realizedChain = interimArray[i];
            
            currentItemDate = realizedChain.dateCreated;
            
        }
        
        // compare the currentItemDate to the currentDayBeginDate and proceed accordingly
        
        BOOL currentItemDateGreaterThanDayBeginDate = [currentItemDate timeIntervalSinceDate: currentDayBeginDate] > 0;
        
        if (currentItemDateGreaterThanDayBeginDate){
            
            [masterList[currentSectionIndex] addObject: interimArray[i]];
            
            continue;
            
        } else{
            
            currentSectionIndex++;
            
            currentSectionArray = [[NSMutableArray alloc] init];
            
            [currentSectionArray addObject: interimArray[i]];
            
            [masterList addObject: currentSectionArray];
            
            currentDayBeginDate = [self dayBeginDateForObject: interimArray[i]];
            
            continue;
            
        }
        
    }
    
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

#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    NSLog(@"section count: %d", (int)[self.masterList count]);
    
    return [self.masterList count];
    
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    
    return [NSString stringWithFormat: @"Section %d", (int)section + 1];
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [self.masterList[section] count];
   
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //// for now, just give the cell text a dynamic name indicating whether it is a a RealizedSet or RealizedChain plus the date
    
    // date formatter
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterNoStyle;
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    
    // conditionals
    
    int sectionIndex = (int)indexPath.section;
    int rowIndex = (int)indexPath.row;
    
    BOOL isRealizedSet = [self.masterList[sectionIndex][rowIndex] isKindOfClass: [TJBRealizedSet class]];
//    BOOL isLastExerciseInArray = indexPath.row == [self.masterList count] - 1;
//    BOOL isLastExerciseInSection;
    
    if (isRealizedSet){
        
        TJBRealizedSet *realizedSet = self.masterList[sectionIndex][rowIndex];
        
        // dequeue the realizedSetCell
        
        RealizedSetHistoryCell *cell = [self.historyTableView dequeueReusableCellWithIdentifier: @"realizedSetHistoryCell"];
        
        // labels
        
        cell.exerciseLabel.text = realizedSet.exercise.name;
        cell.weightLabel.text = [[NSNumber numberWithFloat: realizedSet.weight] stringValue];
        cell.repsLabel.text = [[NSNumber numberWithFloat: realizedSet.reps] stringValue];
        cell.restLabel.text = @"";
        
        return cell;
        
    } else{
        
        TJBRealizedChain *realizedChain = self.masterList[sectionIndex][rowIndex];
        
        // dequeue the realizedSetCell
        
        RealizedChainTableViewCell *cell = [self.historyTableView dequeueReusableCellWithIdentifier: @"realizedChainTableViewCell"];
        
        // labels
        
        cell.dateLabel.text = [dateFormatter stringFromDate: realizedChain.dateCreated];
        cell.realizedChainNameLabel.text = [NSString stringWithFormat: @"%@", realizedChain.chainTemplate.name];
    
        return cell;
        
    }

}


#pragma mark - View Life Cycle


- (void)viewDidLoad{
    
    [self configureHistoryTableView];
    
    [self configureNavigationBar];
    
}

- (void)configureNavigationBar{
    
    //// add a button to the navigation bar and give it the correct title
    
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle: @"Complete History"];
    
    UIBarButtonItem *leftBarButton = [[UIBarButtonItem alloc] initWithTitle: @"Home"
                                                                      style: UIBarButtonItemStyleDone
                                                                     target: self
                                                                     action: @selector(didPressHome)];
    [navItem setLeftBarButtonItem: leftBarButton];
    
    [self.navBar setItems: @[navItem]];
    
    [self.navBar setTitleTextAttributes: @{NSFontAttributeName: [UIFont boldSystemFontOfSize: 20.0]}];
    
}



- (void)configureHistoryTableView{
    
    //// register the appropriate table view cells with the table view.  Realized chain and realized set get their own cell types because they display slighty different information
    
    [self.historyTableView registerClass: [UITableViewCell class]
                  forCellReuseIdentifier: @"basicCell"];
    
    UINib *realizedSetNib = [UINib nibWithNibName: @"RealizedSetHistoryCell"
                                bundle: nil];
    [self.historyTableView registerNib: realizedSetNib
                forCellReuseIdentifier: @"realizedSetHistoryCell"];
    
    UINib *realizedChainNib = [UINib nibWithNibName: @"RealizedChainTableViewCell"
                                             bundle: nil];
    
    [self.historyTableView registerNib: realizedChainNib
                forCellReuseIdentifier: @"realizedChainTableViewCell"];
    
}


#pragma mark - Button Actions

- (void)didPressHome{
    
    //// simply dismiss this view controller to reveal the home screen
    
    [self dismissViewControllerAnimated: NO
                             completion: nil];
    
}



#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //// if the selected object is a realized chain, show the chain details.  Else, nothing
    
    int sectionIndex = (int)indexPath.section;
    int rowIndex = (int)indexPath.row;
    
    if ([self objectIsRealizedChain: self.masterList[sectionIndex][rowIndex]]){
        
        TJBRealizedChainHistoryVC *vc = [[TJBRealizedChainHistoryVC alloc] initWithRealizedChain: self.masterList[sectionIndex][rowIndex]];
        
        vc.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
        
        [self presentViewController: vc
                           animated: YES
                         completion: nil];
        
    }
    
    
}

- (BOOL)objectIsRealizedChain:(id)object{
    
    //// returns YES if the object is a realized chain.  NO, otherwise
    
    return [object isKindOfClass: [TJBRealizedChain class]];
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UILabel *label = [[UILabel alloc] init];
    
    label.backgroundColor = [[TJBAestheticsController singleton] labelType1Color];
    
    // the section title will be the date
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    
    NSDate *workoutDay = [self dateForObject: self.masterList[section][0]];
    
    label.text = [dateFormatter stringFromDate: workoutDay];
    
    label.font = [UIFont boldSystemFontOfSize: 20.0];
    
    label.textAlignment = NSTextAlignmentCenter;
    
    // label layer
    
    CALayer *labelLayer = label.layer;
    
    labelLayer.masksToBounds = YES;
    labelLayer.cornerRadius = 16;
    
    return label;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 40;
    
}

- (NSDate *)dateForObject:(id)object{
    
    //// returns the date created for realized chains and the begin date for realized sets
    
    BOOL objectIsRealizedSet = [object isKindOfClass: [TJBRealizedSet class]];
    
    if (objectIsRealizedSet){
        
        TJBRealizedSet *realizedSet = object;
        
        return realizedSet.beginDate;
        
    } else{
        
        TJBRealizedChain *realizedChain = object;
        
        return realizedChain.dateCreated;
        
    }

}


#pragma mark - <UIViewControllerRestoration>

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder{
    
    //// instantiate the VC.  Row selection and scroll position state restoration will be handled in the decode method
    
    TJBCompleteHistoryVC *vc = [[TJBCompleteHistoryVC alloc] init];
    
    return vc;
    
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder{
    
    //// handle the row selection and scroll position
    
    // scroll position
    
    CGFloat yScrollOffset = [coder decodeFloatForKey: @"tableViewContentOffset"];
    
    self.historyTableView.contentOffset = CGPointMake(0, yScrollOffset);
    
    // row selection.  If the decoded object exists, programmatically select the row
    
    NSIndexPath *selectedRowPath = [coder decodeObjectForKey: @"tableViewSelectedRow"];
    
    if (selectedRowPath){
        
        [self.historyTableView selectRowAtIndexPath: selectedRowPath
                                           animated: NO
                                     scrollPosition: UITableViewScrollPositionNone];
        
    }
    
    return;
    
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder{
    
    [super encodeRestorableStateWithCoder: coder];
    
    //// encode necessary state information.  Need to encode table view position and selection
    
    [coder encodeFloat: self.historyTableView.contentOffset.y
                forKey: @"tableViewContentOffset"];
    
    [coder encodeObject: self.historyTableView.indexPathForSelectedRow
                 forKey: @"tableViewSelectedRow"];
    
}



@end
























