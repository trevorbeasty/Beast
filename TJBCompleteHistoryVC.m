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

@interface TJBCompleteHistoryVC () <UITableViewDelegate, UITableViewDataSource>

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
    
    //// add the fetched objects of the 2 FRC's to a mutable array and reorder it appropriately
    
    NSMutableArray *masterList = [[NSMutableArray alloc] init];
    
    [masterList addObjectsFromArray: self.realizedSetFRC.fetchedObjects];
    [masterList addObjectsFromArray: self.realizeChainFRC.fetchedObjects];
    
    [masterList sortUsingComparator: ^(id obj1, id obj2){
    
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
    
    // assign master list to respective property
    
    self.masterList = masterList;
    
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return [self.masterList count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //// for now, just give the cell text a dynamic name indicating whether it is a a RealizedSet or RealizedChain plus the date
    
    // date formatter
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterNoStyle;
    dateFormatter.timeStyle = NSDateFormatterShortStyle;
    
    // conditionals
    
    BOOL isRealizedSet = [self.masterList[indexPath.row] isKindOfClass: [TJBRealizedSet class]];
//    BOOL isLastExerciseInArray = indexPath.row == [self.masterList count] - 1;
//    BOOL isLastExerciseInSection;
    
    if (isRealizedSet){
        
        TJBRealizedSet *realizedSet = self.masterList[indexPath.row];
        
        // dequeue the realizedSetCell
        
        RealizedSetHistoryCell *cell = [self.historyTableView dequeueReusableCellWithIdentifier: @"realizedSetHistoryCell"];
        
        // labels
        
        cell.timeLabel.text = [dateFormatter stringFromDate: realizedSet.beginDate];
        cell.exerciseLabel.text = realizedSet.exercise.name;
        cell.weightLabel.text = [[NSNumber numberWithFloat: realizedSet.weight] stringValue];
        cell.repsLabel.text = [[NSNumber numberWithFloat: realizedSet.reps] stringValue];
        cell.restLabel.text = @"";
        
        return cell;
        
    } else{
        
        TJBRealizedChain *realizedChain = self.masterList[indexPath.row];
        
        // dequeue the realizedSetCell
        
        RealizedChainTableViewCell *cell = [self.historyTableView dequeueReusableCellWithIdentifier: @"realizedChainTableViewCell"];
        
        // labels
        
        cell.dateLabel.text = [dateFormatter stringFromDate: realizedChain.setBeginDateArrays[0].dates[0].value];
        cell.realizedChainNameLabel.text = realizedChain.chainTemplate.name;
    
        return cell;
        
    }

}


#pragma mark - View Life Cycle


- (void)viewDidLoad{
    
    [self configureHistoryTableView];
    
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


#pragma mark - <UITableViewDataSource>



#pragma mark - <UITableViewDelegate>







@end
