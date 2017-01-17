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
    
    
    
}


#pragma mark - View Life Cycle


- (void)viewDidLoad{
    
    [self configureHistoryTableView];
    
}


- (void)configureHistoryTableView{
    
    
    
}


#pragma mark - <UITableViewDataSource>



#pragma mark - <UITableViewDelegate>







@end
