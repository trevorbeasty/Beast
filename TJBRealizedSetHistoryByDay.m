//
//  TJBRealizedSetHistoryByDay.m
//  Beast
//
//  Created by Trevor Beasty on 12/9/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import "TJBRealizedSetHistoryByDay.h"

#import "CoreDataController.h"

#import "RealizedSetHistoryCell.h"

#import "TJBStopwatch.h"

#import "TJBAestheticsController.h"

@interface TJBRealizedSetHistoryByDay () <UITableViewDelegate, UITableViewDataSource, UIViewControllerRestoration>

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UIView *columnLabelSubview;

@property (nonatomic, strong) NSFetchedResultsController *frc;

@end

@implementation TJBRealizedSetHistoryByDay

#pragma mark - Instantiation

- (instancetype)init{
    self = [super init];
    
    self.restorationClass = [TJBRealizedSetHistoryByDay class];
    self.restorationIdentifier = @"TJBRealizedSetHistoryByDay";
    
    return self;
}


#pragma mark - View Life Cycle

- (void)viewDidLoad{
    
    [self configureNavigationBar];
    
    [self configureFetchedResultsController];
    
    [self configureTableView];
    
    [self addBackgroundImage];
    
    [self viewAesthetics];
    
}

- (void)configureNavigationBar{
    
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle: @"Today's Sets"];
    [self.navigationBar setItems: @[navItem]];
//    [TJBAestheticsController configureNavigationBar: self.navigationBar];
}

- (void)addBackgroundImage{
    [[TJBAestheticsController singleton] addFullScreenBackgroundViewWithImage: [UIImage imageNamed: @"girlOverheadKettlebell"]
                                                                   toRootView: self.view
                                                                 imageOpacity: .35];
}

- (void)configureTableView{
    UINib *nib = [UINib nibWithNibName: @"RealizedSetHistoryCell"
                                bundle: nil];
    [self.tableView registerNib: nib
         forCellReuseIdentifier: @"setHistoryCell"];
}

- (void)configureFetchedResultsController{
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName: @"RealizedSet"];
    
    NSSortDescriptor *dateSort = [NSSortDescriptor sortDescriptorWithKey: @"endDate"
                                                               ascending: NO];
    
    // create NSDate objects defining the first and last seconds of today in order to effectively filter the retrieved 'realized set' objects
    
    NSDate *todayBegin = [[NSCalendar calendarWithIdentifier: NSCalendarIdentifierGregorian] startOfDayForDate: [NSDate date]];
    
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    dateComponents.day = 1;
    NSDate *todayEnd = [[NSCalendar calendarWithIdentifier: NSCalendarIdentifierGregorian] dateByAddingComponents: dateComponents
                                                                                                           toDate: todayBegin
                                                                                                          options: 0];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat: @"(endDate >= %@) AND (endDate <= %@)", todayBegin, todayEnd];
    
    [request setPredicate: predicate];
    
    [request setSortDescriptors: @[dateSort]];
    
    NSManagedObjectContext *moc = [[CoreDataController singleton] moc];
    
    NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest: request
                                                                          managedObjectContext: moc
                                                                            sectionNameKeyPath: nil
                                                                                     cacheName: nil];
    frc.delegate = nil;
    
    self.frc = frc;
    
    NSError *error = nil;
    
    if (![self.frc performFetch: &error]){
        
        abort();
    }
    
}

- (void)viewAesthetics{
    self.tableView.layer.opacity = .85;
    
    [TJBAestheticsController configureViewsWithType1Format: @[self.columnLabelSubview]
                                               withOpacity: .85];
}

- (void)viewWillAppear:(BOOL)animated{
    NSError *error = nil;
    [self.frc performFetch: &error];
    [self.tableView reloadData];
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSUInteger sectionCount = [[[self frc] sections] count];
    return sectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    id<NSFetchedResultsSectionInfo> sectionInfo = [[self frc] sections][section];
    NSUInteger numberOfObjects = [sectionInfo numberOfObjects];
    return numberOfObjects;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    RealizedSetHistoryCell *cell = [self.tableView dequeueReusableCellWithIdentifier: @"setHistoryCell"];
    
    TJBRealizedSet *realizedSet = [self.frc objectAtIndexPath: indexPath];
    
    // rest leading up to set
    
    id<NSFetchedResultsSectionInfo> sectionInfo = [[self frc] sections][indexPath.section];
    NSUInteger numberOfObjects = [sectionInfo numberOfObjects];
    
    NSInteger previousSetRowIndex = indexPath.row + 1;
    
    if ( previousSetRowIndex < numberOfObjects ){
        
        NSIndexPath *previousSetPath = [NSIndexPath indexPathForRow: previousSetRowIndex
                                                          inSection: indexPath.section];
        
        TJBRealizedSet *previousSet = [self.frc objectAtIndexPath: previousSetPath];
        
        int restTimeFromPreviousSet = (int)[realizedSet.beginDate timeIntervalSinceDate: previousSet.endDate];
        
        NSString *restTimeString = [[TJBStopwatch singleton] minutesAndSecondsStringFromNumberOfSeconds: restTimeFromPreviousSet];
        
        NSString *fullRestTimeString = [NSString stringWithFormat: @"+ %@",
                                        restTimeString];
        
        cell.restLabel.text = fullRestTimeString;
        
    }
    else{
        
        cell.restLabel.text = @"";
        
    }
    
    // weight
    cell.weightLabel.text = [[NSNumber numberWithFloat: realizedSet.weight] stringValue];
    
    // reps
    cell.repsLabel.text = [[NSNumber numberWithFloat: realizedSet.reps] stringValue];
    
    // exercise
    cell.exerciseLabel.text = realizedSet.exercise.name;
    
    return cell;
    
}

#pragma mark - <UIViewControllerRestoration>

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder{
    return [[TJBRealizedSetHistoryByDay alloc] init];
}

@end










































