//
//  TJBExerciseHistoryVC.m
//  Beast
//
//  Created by Trevor Beasty on 4/10/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBExerciseHistoryVC.h"

// core data

#import "CoreDataController.h"

// table view cells

#import "TJBRealizedChainCell.h"
#import "TJBWorkoutLogTitleCell.h"
#import "TJBNoDataCell.h"


// aesthetics

#import "TJBAestheticsController.h"



@interface TJBExerciseHistoryVC () <UITableViewDelegate, UITableViewDataSource, UIViewControllerRestoration>

{
    
    BOOL _needsUpdating;
    
}



// IBOutlet

@property (weak, nonatomic) IBOutlet UIView *titleBar;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *exerciseDetailLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberPreviousRecordsLabel;

// programmatically created

@property (strong) UIActivityIndicatorView *aiView;

// core

@property (strong) TJBExercise *exercise;
@property (strong) NSArray *sortedContent;
@property (strong) NSMutableArray *preloadedCells;

// optimization

@property (strong) NSCalendar *calendar;

@end



#pragma mark - Constants

// content loading

static NSTimeInterval const contentLoadingSmoothingInterval = .2;

// restoration

static NSString * const restorationID = @"TJBExerciseHistoryVC";



@implementation TJBExerciseHistoryVC


#pragma mark - Instantiation


- (instancetype)init{
    
    self = [super init];
    
    [self configureNotifications];
    [self configureRestorationProperties];
    [self configureTabBar];
    
    return self;
    
}




#pragma mark - Init Helper Methods

- (void)configureNotifications{
    
    NSManagedObjectContext *moc = [[CoreDataController singleton] moc];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(coreDataDidUpdate)
                                                 name: NSManagedObjectContextDidSaveNotification
                                               object: moc];
    
}


- (void)configureRestorationProperties{
    
    self.restorationIdentifier = restorationID;
    self.restorationClass = [TJBExerciseHistoryVC class];
    
}

#pragma mark - View Life Cycle


- (void)viewDidAppear:(BOOL)animated{
    
    if (_needsUpdating){
        
        [self showActivityIndicator];
        
        [self performSelector: @selector(loadContentAndRemoveActivityIndicator)
                   withObject: self
                   afterDelay: contentLoadingSmoothingInterval];
    
    }
    
}



- (void)viewDidLoad{
    
    [super viewDidLoad];
    
    [self configureTableView];
    
    [self viewAesthetics];
    
    if (self.exercise){
        self.exerciseDetailLabel.text = self.exercise.name;
    }
    
}




#pragma mark - View Helper Methods

- (void)configureTabBar{
    
    self.tabBarItem.title = @"History";
    self.tabBarItem.image = [UIImage imageNamed: @"colosseumBlue25"];
    
}

- (void)loadContentAndRemoveActivityIndicator{
    
    [self deriveContentForActiveExercise];
    
    [self preloadCellsForActiveContent];
    
    [self configureNumberOfRecordsLabelAccordingToContent];
    
    [self.tableView reloadData];
    
    _needsUpdating = NO;
    
    [self.aiView stopAnimating];
    
}

- (void)configureTableView{
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    
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
    
}


- (void)viewAesthetics{
    
    self.view.backgroundColor = [UIColor blackColor];
    
    self.titleBar.backgroundColor = [UIColor blackColor];
    
    NSArray *titleLabels = @[self.titleLabel, self.exerciseDetailLabel];
    for (UILabel *label in titleLabels){
        
        label.backgroundColor = [UIColor darkGrayColor];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont boldSystemFontOfSize: 20];
        
    }
    
    self.numberPreviousRecordsLabel.backgroundColor = [UIColor grayColor];
    self.numberPreviousRecordsLabel.textColor = [UIColor whiteColor];
    self.numberPreviousRecordsLabel.font = [UIFont boldSystemFontOfSize: 15];
    
    self.tableView.backgroundColor = [[TJBAestheticsController singleton] yellowNotebookColor];
    
}

- (void)configureNumberOfRecordsLabelAccordingToContent{
    
    NSNumber *numberOfPreviousRecords = @(self.sortedContent.count);
    
    NSString *recordsWord = [numberOfPreviousRecords intValue] == 1 ? @"Record" : @"Records";
    
    self.numberPreviousRecordsLabel.text = [NSString stringWithFormat: @"%@ %@",
                                            [numberOfPreviousRecords stringValue],
                                            recordsWord];
    
}

#pragma mark - Content Derivation

- (void)deriveContentForActiveExercise{
    
    NSMutableArray *collector = [[NSMutableArray alloc] init];
    
    // collect all relevant TJBRealizedSets and TJBRealizedChains
    
    for (TJBRealizedSet *set in self.exercise.realizedSets){
        
        // only add the set if it is not associated with a routine. Otherwise, sets will be counted twice
        
        if (set.realizedSetCollector == nil){
            
            [collector addObject: set];
            
        }
        

        
    }
    
    for (TJBChainTemplate *ct in self.exercise.chainTemplates){
        
        for (TJBRealizedChain *rc in ct.realizedChains){
            
            [collector addObject: rc];
            
        }
        
    }
    
    // if there is only one entry or fewer, assign the sortedContent and return
    
    if (collector.count <= 1){
        
        self.sortedContent = collector;
        
        return;
        
    }
    
    // sort all collected items by date in descending order
    
    [collector sortUsingComparator: ^(id obj1, id obj2){
        
        NSDate *date1 = [self dateForObject: obj1];
        NSDate *date2 = [self dateForObject: obj2];
        
        NSTimeInterval diff = [date1 timeIntervalSinceDate: date2];
        
        if (diff > 0){
            
            return NSOrderedAscending;
            
        } else{
            
            return NSOrderedDescending;
            
        }
        
    }];
    
    // group adjacent realized sets from the same day together
    
    NSMutableArray *collector2 = [[NSMutableArray alloc] init];
    
    NSInteger groupSize = 1;
    
    NSInteger limit = collector.count;
    for (NSInteger i = 0; i < limit - 1; i++){
        
        id obj1 = collector[i];
        id obj2 = collector[i + 1];
        
        BOOL objectsAreRealizedSetsOfSameDay = [self objectsAreRealizedSetsOfSameDay_obj1: obj1
                                                                                     obj2: obj2];
        
        if (i == limit - 2){
            
            // different logic must be applied for the last two objects, otherwise the last object will not be added
            
            if (objectsAreRealizedSetsOfSameDay){
                
                groupSize += 1;
                
                id object = [self objectForSourceArray: collector
                                     iterationPosition: i + 1
                                             groupSize: groupSize];
                
                [collector2 addObject: object];
                
                break;
                
            } else{
                
                id object1 = [self objectForSourceArray: collector
                                     iterationPosition: i
                                             groupSize: groupSize];
                
                id object2 = [self objectForSourceArray: collector
                                      iterationPosition: i + 1
                                              groupSize: 1];
                
                [collector2 addObject: object1];
                [collector2 addObject: object2];
                
                break;
                
            }
            
            
        } else{
            
            if (objectsAreRealizedSetsOfSameDay){
                
                groupSize += 1;
                continue;
                
            } else{
                
                id object = [self objectForSourceArray: collector
                                     iterationPosition: i
                                             groupSize: groupSize];
                
                [collector2 addObject: object];
                
                groupSize = 1;
                
                continue;
                
            }
        }
    }
    
    self.sortedContent = collector2;
    
}



- (id)objectForSourceArray:(NSArray *)array iterationPosition:(NSInteger)iterationPosition groupSize:(NSInteger)groupSize{
    
    if (groupSize > 1){
        
        NSMutableArray *collector = [[NSMutableArray alloc] init];
        
        for (NSInteger i = iterationPosition - (groupSize - 1); i <= iterationPosition; i++){
            
            [collector addObject: array[i]];
            
        }
        
        TJBRealizedSetGrouping rsg = [NSArray arrayWithArray: collector];
        return rsg;
        
    } else{
        
        return array[iterationPosition];
        
    }
    
}

- (NSDate *)dateForObject:(id)object{
    
    if ([object isKindOfClass: [TJBRealizedSet class]]){
        
        TJBRealizedSet *rs = object;
        return rs.submissionTime;
        
    } else if ([object isKindOfClass: [TJBRealizedChain class]]){
        
        TJBRealizedChain *rc = object;
        return  rc.dateCreated;
        
    } else{
        
        return nil;
        
    }
    
}

- (BOOL)objectsAreRealizedSetsOfSameDay_obj1:(id)obj1 obj2:(id)obj2{
    
    BOOL obj1IsRealizedSet = [self objectIsRealizedSet: obj1];
    BOOL obj2IsRealizedSet = [self objectIsRealizedSet: obj2];
    
    if (obj1IsRealizedSet && obj2IsRealizedSet){
        
        if (!self.calendar){
            
            self.calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
            
        }
        
        TJBRealizedSet *rs1 = obj1;
        TJBRealizedSet *rs2 = obj2;
        
        return [self.calendar isDate: rs1.submissionTime
                     inSameDayAsDate: rs2.submissionTime];
        
    } else{
        
        return NO;
        
    }
    
}

- (BOOL)objectIsRealizedSet:(id)obj{
    
    return [obj isKindOfClass: [TJBRealizedSet class]];
    
}




#pragma mark - Activity Indicator View

- (void)showActivityIndicator{
    
    if (!self.aiView){
        
        UIActivityIndicatorView *aiView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
        self.aiView = aiView;
        
        aiView.backgroundColor = [[TJBAestheticsController singleton] yellowNotebookColor];
        aiView.frame = self.tableView.frame;
        aiView.hidesWhenStopped = YES;
        aiView.layer.opacity = .9;
        
        [self.view insertSubview: aiView
                    aboveSubview: self.tableView];
        
    }
    
    [self.aiView startAnimating];
    
}



#pragma mark - TJBExerciseHistoryProtocol

- (void)activeExerciseDidUpdate:(TJBExercise *)exercise{
    
    self.exercise = exercise;
    self.exerciseDetailLabel.text = exercise.name;
    
    if (self.aiView){
        
        self.aiView.hidden = NO;
        
    }
    
    _needsUpdating = YES;
    
}

- (void)replaceTableView{
    
    // this is done so that fresh cells are returned and true dequeuing does not occur
    
    UITableView *tv = [[UITableView alloc] init];
    tv.backgroundColor = [[TJBAestheticsController singleton] yellowNotebookColor];
    tv.frame = self.tableView.frame;
    [self.view insertSubview: tv
                aboveSubview: self.tableView];
    [self.tableView removeFromSuperview];
    
    self.tableView = tv;
    [self configureTableView];
    
}

#pragma mark - UITableViewDataSource


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (self.sortedContent.count == 0){
        
        return 1;
        
    } else{
        
        return self.sortedContent.count;
        
    }
    
    
}



- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.preloadedCells.count == 0){
        
        NSIndexPath *zeroethPth = [NSIndexPath indexPathForRow: 0
                                                     inSection: 0];
        
        return  [self cellForIndexPath: zeroethPth];
        
    }
    
    return self.preloadedCells[indexPath.row];
    
}



#pragma mark - Cell Preloading

- (void)preloadCellsForActiveContent{
    
    self.preloadedCells = [[NSMutableArray alloc] init];
    
    NSInteger limit = [self tableView: self.tableView
                numberOfRowsInSection: 0];
    
    for (int i = 0; i < limit; i++){
        
        NSIndexPath *path = [NSIndexPath indexPathForRow: i
                                               inSection: 0];
        
        UITableViewCell *cell = [self cellForIndexPath: path];
        [self.preloadedCells addObject: cell];
        
    }
    
}

- (UITableViewCell *)cellForIndexPath:(NSIndexPath *)indexPath{
    
    if (self.sortedContent.count == 0 || !self.sortedContent){
        
        TJBNoDataCell *cell = [self.tableView dequeueReusableCellWithIdentifier: @"TJBNoDataCell"];
        
        cell.mainLabel.text = @"No Entries";
        cell.backgroundColor = [UIColor clearColor];
        cell.referenceIndexPath = indexPath;
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
        
    } else{
        
        NSNumber *number = [NSNumber numberWithInteger: indexPath.row + 1];
        
        int rowIndex = (int)indexPath.row;
        
        BOOL isRealizedSet = [self.sortedContent[rowIndex] isKindOfClass: [TJBRealizedSet class]];
        BOOL isRealizedChain = [self.sortedContent[rowIndex] isKindOfClass: [TJBRealizedChain class]];
        
        NSArray *nibObjects = [[NSBundle mainBundle] loadNibNamed: @"TJBRealizedChainCell"
                                                            owner: self
                                                          options: nil];
        TJBRealizedChainCell *cell = nibObjects[0];
        
        if (isRealizedSet){
            
            TJBRealizedSet *realizedSet = self.sortedContent[rowIndex];
            
            // dequeue the realizedSetCell

            
            [self layoutCellToEnsureCorrectWidth: cell
                                       indexPath: indexPath];

            [cell configureWithContentObject: realizedSet
                                    cellType: RealizedSetCollectionCell
                                dateTimeType: TJBDayInYear
                                 titleNumber: number];
            
            cell.backgroundColor = [UIColor clearColor];
            
            return cell;
            
        } else if (isRealizedChain){
            
            TJBRealizedChain *realizedChain = self.sortedContent[rowIndex];
            
            // dequeue the realizedSetCell
            
            [self layoutCellToEnsureCorrectWidth: cell
                                       indexPath: indexPath];
            
            [cell configureWithContentObject: realizedChain
                                    cellType: RealizedChainCell
                                dateTimeType: TJBDayInYear
                                 titleNumber: number];
            
            cell.backgroundColor = [UIColor clearColor];
            
            return cell;
            
        } else{
            
            // if it is not a realized set or realized chain, then it is a TJBRealizedSetCollection
            
            [self layoutCellToEnsureCorrectWidth: cell
                                       indexPath: indexPath];
            
            cell.backgroundColor = [UIColor clearColor];
            
            TJBRealizedSetGrouping rsg = self.sortedContent[rowIndex];
            
            [cell configureWithContentObject: rsg
                                    cellType: RealizedSetCollectionCell
                                dateTimeType: TJBDayInYear
                                 titleNumber: number];
            
            return cell;
            
        }
    }
    
}

- (void)layoutCellToEnsureCorrectWidth:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath{
    
    [self.view layoutSubviews];
    
    CGFloat cellHeight = [self tableView: self.tableView
                 heightForRowAtIndexPath: indexPath];
    
    CGFloat cellWidth = self.tableView.frame.size.width;
    
    
    [cell setFrame: CGRectMake(0, 0, cellWidth, cellHeight)];
    [cell layoutSubviews];
    
}



#pragma mark - UITableViewDelegate


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.sortedContent.count == 0){
        
        [self.view layoutIfNeeded];
        
        return self.tableView.frame.size.height;
        
    } else{
        
        NSInteger adjustedIndex = indexPath.row;
        
        BOOL isRealizedSet = [self.sortedContent[adjustedIndex] isKindOfClass: [TJBRealizedSet class]];
        BOOL isRealizedChain = [self.sortedContent[adjustedIndex] isKindOfClass: [TJBRealizedChain class]];
        
        
        if (isRealizedSet){
            
            return [TJBRealizedChainCell suggestedHeightForRealizedSet];
            
        } else if (isRealizedChain) {
            
            TJBRealizedChain *realizedChain = self.sortedContent[adjustedIndex];
            
            return [TJBRealizedChainCell suggestedCellHeightForRealizedChain: realizedChain];
            
        } else{
            
            TJBRealizedSetGrouping rsg = self.sortedContent[adjustedIndex];
            
            return [TJBRealizedChainCell suggestedHeightForRealizedSetGrouping: rsg];
            
        }
    }
  
}





#pragma mark - Core Data

- (void)coreDataDidUpdate{
    
    if (self.aiView){
        
        self.aiView.hidden = NO;
        
    }
    
    _needsUpdating = YES;
    
}


#pragma mark - Restoration

+(UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder{
    
    return [[TJBExerciseHistoryVC alloc] init];
    
}

@end



























