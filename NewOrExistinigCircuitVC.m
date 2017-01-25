//
//  NewOrExistinigCircuitVC.m
//  Beast
//
//  Created by Trevor Beasty on 12/26/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import "NewOrExistinigCircuitVC.h"

// core data

#import "CoreDataController.h"

// VC's to present

#import "TJBCircuitDesignVC.h"
#import "TJBCircuitModeTBC.h"

// aesthetics

#import "TJBAestheticsController.h"

// table view cell

#import "TJBStructureTableViewCell.h"

@interface NewOrExistinigCircuitVC () <NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource, UIViewControllerRestoration>

// IBOutlet

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UILabel *sortByLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sortBySegmentedControl;

@property (weak, nonatomic) IBOutlet UIButton *launchButton;
@property (weak, nonatomic) IBOutlet UIButton *modifyButton;
@property (weak, nonatomic) IBOutlet UIButton *previewButton;

// IBAction

- (IBAction)didPressLaunchButton:(id)sender;
- (IBAction)didPressPreviewButton:(id)sender;
- (IBAction)didPressModifyButton:(id)sender;

// core data

@property (nonatomic, strong) NSFetchedResultsController *frc;
@property (nonatomic, strong) NSMutableArray <NSMutableArray <TJBChainTemplate *> *> *sortedContent;

// selection

@property (nonatomic, strong) TJBChainTemplate *selectedChainTemplate;
@property (nonatomic, strong) NSIndexPath *lastSelectedIndexPath;


@end

@implementation NewOrExistinigCircuitVC

#pragma mark - Instantiation

- (instancetype)init{
    
    self = [super init];
    
    // for restoration
    
    self.restorationIdentifier = @"TJBNewOrExistingCircuit";
    self.restorationClass = [NewOrExistinigCircuitVC class];
    
    return self;
}

#pragma mark - View Cycle

- (void)viewDidLoad{
    
    [self configureNavigationBar];
    
    [self viewAesthetics];
    
    [self configureSegmentedControl];
    
    [self toggleButtonsToOffState];
    
}

- (void)configureSegmentedControl{
    
    //// configure action method for segmented control
    
    [self.sortBySegmentedControl addTarget: self
                                    action: @selector(segmentedControlValueChanged)
                          forControlEvents: UIControlEventValueChanged];
    
}


- (void)viewAesthetics{
    
    // table view
    
    self.tableView.layer.opacity = .85;
    
    // buttons
    
    NSArray *buttons = @[self.launchButton,
                         self.previewButton,
                         self.modifyButton];
    
    for (UIButton *button in buttons){
        
        UIColor *color = [[TJBAestheticsController singleton] color2];
        [button setBackgroundColor: color];
        [button setTitleColor: [UIColor whiteColor]
                     forState: UIControlStateNormal];
        
    }
    
}

- (void)addBackground{
    
    [[TJBAestheticsController singleton] addFullScreenBackgroundViewWithImage: [UIImage imageNamed: @"girlOverheadKettlebell"]
                                                                   toRootView: self.view
                                                                 imageOpacity: .35];
}

- (void)viewWillAppear:(BOOL)animated{
    
    NSError *error = nil;
    [self.frc performFetch: &error];
    
    [self fetchCoreDataAndConfigureTableView];

}

- (void)configureNavigationBar{
    
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle: @"Scheme"];
    
    // left button
    
    UIBarButtonItem *homeButton = [[UIBarButtonItem alloc] initWithTitle: @"Home"
                                                                   style: UIBarButtonItemStyleDone
                                                                  target: self
                                                                  action: @selector(didPressHomeButton)];
    
    [navItem setLeftBarButtonItem: homeButton];
    
    // right button
    
    UIBarButtonItem *newButton = [[UIBarButtonItem alloc] initWithTitle: @"New"
                                                                  style: UIBarButtonItemStyleDone
                                                                 target: self
                                                                 action: @selector(didPressNew)];
    
    [navItem setRightBarButtonItem: newButton];
    
    // nav bar
    
    [self.navBar setItems: @[navItem]];
    
    [self.navBar setTitleTextAttributes: @{NSFontAttributeName: [UIFont boldSystemFontOfSize: 20.0]}];
    
}


- (void)fetchCoreDataAndConfigureTableView{
    
    // table view configuration
    
    UINib *nib = [UINib nibWithNibName: @"TJBStructureTableViewCell"
                                bundle: nil];
    
    [self.tableView registerNib: nib
         forCellReuseIdentifier: @"detailCell"];
    
    // NSFetchedResultsController
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName: @"ChainTemplate"];
    
    NSSortDescriptor *nameSort = [NSSortDescriptor sortDescriptorWithKey: @"name"
                                                               ascending: YES];
    
    [request setSortDescriptors: @[nameSort]];
    
    NSManagedObjectContext *moc = [[CoreDataController singleton] moc];
    
    NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest: request
                                                                          managedObjectContext: moc
                                                                            sectionNameKeyPath: @"name"
                                                                                     cacheName: nil];
    frc.delegate = self;
    
    self.frc = frc;
    
    NSError *error = nil;
    
    if (![self.frc performFetch: &error])
    {
        NSLog(@"Failed to initialize fetchedResultsController: %@\n%@", [error localizedDescription], [error userInfo]);
        abort();
    }
    
    // sorted content
    
    [self configureSortedContentAndReloadTableData];
    
}

- (void)configureSortedContentAndReloadTableData{
    
    //// given the fetched results and current sorting selection, derive the sorted content (which will be used to populate the table view)
    
    self.sortedContent = [[NSMutableArray alloc] init];
    
    NSInteger sortSelection = self.sortBySegmentedControl.selectedSegmentIndex;
    BOOL sortByDateLastExecuted = sortSelection == 0;
    BOOL sortByDateCreated = sortSelection == 1;
    
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier: NSCalendarIdentifierGregorian];
    
    if (sortByDateLastExecuted){
        
        NSMutableArray<TJBChainTemplate *> *interimArray = [[NSMutableArray alloc] initWithArray: self.frc.fetchedObjects];
        
        // first, remove all chain templates that don't have realized sets
        
        NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
        
        for (TJBChainTemplate *chainTemplate in interimArray){
            
            NSOrderedSet *realizedChains = chainTemplate.realizedChains;
            
            BOOL noRealizedChains = [realizedChains count] == 0;
            
            if (noRealizedChains){
                
                [indexSet addIndex: [interimArray indexOfObject: chainTemplate]];
                
            }
            
        }
        
        [interimArray removeObjectsAtIndexes: indexSet];
        
        // now, only chain templates with realized chains remain.  Use an NSComparator to order the chain correctly
        
        [interimArray sortUsingComparator: ^(TJBChainTemplate *chain1, TJBChainTemplate *chain2){
            
            NSDate *date1 = chain1.realizedChains.lastObject.dateCreated;
            NSDate *date2 = chain2.realizedChains.lastObject.dateCreated;
            
            int dateDifference = [date1 timeIntervalSinceDate: date2];
            BOOL date1IsLater = dateDifference > 0;
            
            if (date1IsLater){
                
                return NSOrderedAscending;
                
            } else{
                
                return NSOrderedDescending;
                
            }
            
        }];
        
        // now, the remaining chain templates have realized chains and are ordered from most recent to least recent.  The sortedContent structure must now be filled
        
        NSInteger limit = [interimArray count];
        
        if (limit > 0){
            
            NSMutableArray *initialArray = [[NSMutableArray alloc] init];
            [initialArray addObject: interimArray[0]];
            [self.sortedContent addObject: initialArray];
            
            NSMutableArray *iterativeArray = initialArray;
            
            NSDate *referenceDate = interimArray[0].realizedChains.lastObject.dateCreated;
            NSDate *iterativeDate;
            
            for (int i = 1; i < limit; i++){
                
                iterativeDate = interimArray[i].realizedChains.lastObject.dateCreated;
                
                NSComparisonResult monthCompare = [calendar compareDate: iterativeDate
                                                                 toDate: referenceDate
                                                      toUnitGranularity: NSCalendarUnitMonth];
                
                if (monthCompare == NSOrderedSame){
                    
                    [iterativeArray addObject: interimArray[i]];
                    
                } else{
                    
                    iterativeArray = [[NSMutableArray alloc] init];
                    [iterativeArray addObject: interimArray[i]];
                    
                    [self.sortedContent addObject: iterativeArray];
                    
                }
                
                referenceDate = iterativeDate;
                
            }
            
        } else{
            
            self.sortedContent = nil;
            
        }
        
    } else if (sortByDateCreated){
        
        NSMutableArray<TJBChainTemplate *> *interimArray = [[NSMutableArray alloc] initWithArray: self.frc.fetchedObjects];
        
        NSSortDescriptor *sd = [NSSortDescriptor sortDescriptorWithKey: @"dateCreated"
                                                             ascending: NO];
        
        [interimArray sortUsingDescriptors: @[sd]];
        
        NSInteger limit = [interimArray count];
        
        if (limit > 0){
            
            NSMutableArray *initialArray = [[NSMutableArray alloc] init];
            [initialArray addObject: interimArray[0]];
            [self.sortedContent addObject: initialArray];
            
            NSMutableArray *iterativeArray = initialArray;
            
            NSDate *referenceDate = interimArray[0].dateCreated;
            NSDate *iterativeDate;
            
            for (int i = 1; i < limit; i++){
                
                iterativeDate = interimArray[i].dateCreated;
                
                NSComparisonResult monthCompare = [calendar compareDate: iterativeDate
                                                  toDate: referenceDate
                                       toUnitGranularity: NSCalendarUnitMonth];
                
                if (monthCompare == NSOrderedSame){
                    
                    [iterativeArray addObject: interimArray[i]];
                    
                } else{
                    
                    iterativeArray = [[NSMutableArray alloc] init];
                    [iterativeArray addObject: interimArray[i]];
                    
                    [self.sortedContent addObject: iterativeArray];
                    
                }
                
                referenceDate = iterativeDate;
                
            }
            
        } else{
            
            self.sortedContent = nil;
            
        }
    }
    
    [self.tableView reloadData];
    
}

#pragma mark - Convenience

- (void)toggleButtonsToOnState{
    
    NSArray *buttons = @[self.launchButton,
                         self.previewButton,
                         self.modifyButton];
    
    for (UIButton *b in buttons){
        
        b.enabled = YES;
        b.layer.opacity = 1;
        
    }
    
}

- (void)toggleButtonsToOffState{
    
    NSArray *buttons = @[self.launchButton,
                         self.previewButton,
                         self.modifyButton];
    
    for (UIButton *b in buttons){
        
        b.enabled = NO;
        b.layer.opacity = .2;
        
    }
    
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{

    return [self.sortedContent count];
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    return [self.sortedContent[section] count];
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    TJBStructureTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier: @"detailCell"];
    
    [cell clearExistingEntries];
    
    TJBChainTemplate *chainTemplate = self.sortedContent[indexPath.section][indexPath.row];
    
    NSInteger sortSelection = self.sortBySegmentedControl.selectedSegmentIndex;
    BOOL sortByDateLastExecuted = sortSelection == 0;
    BOOL sortByDateCreated = sortSelection == 1;
    
    NSDate *date;
    if (sortByDateLastExecuted){
        
        date = chainTemplate.realizedChains.lastObject.dateCreated;
        
    } else if (sortByDateCreated){
        
        date = chainTemplate.dateCreated;
        
    }
    
    [cell configureWithChainTemplate: chainTemplate
                                date: date];
    
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
    
}

#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //// change the background color of the selected chain template and change the control state of the buttons to activate them.  Store the selected chain and the index path of the selected row
    
    // deal with unhighlighting
    
    if (self.lastSelectedIndexPath){
        
        TJBStructureTableViewCell *lastSelectedCell = [self.tableView cellForRowAtIndexPath: self.lastSelectedIndexPath];
        
        UIColor *unselectedColor = [[TJBAestheticsController singleton] color1];
        [lastSelectedCell setOverallColor: unselectedColor];
        
    }
    self.lastSelectedIndexPath = indexPath;
    
    // deal with highlighting
    
    TJBStructureTableViewCell *currentCell = [self.tableView cellForRowAtIndexPath: indexPath];
    
    UIColor *selectedColor = [UIColor redColor];
    [currentCell setOverallColor: selectedColor];
    
    // store the selected chain template and configure the buttons
    
    TJBChainTemplate *chainTemplate = self.sortedContent[indexPath.section][indexPath.row];
    
    self.selectedChainTemplate = chainTemplate;

    [self toggleButtonsToOnState];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //// will need to dynamically evaluate the corresponding chain template and return the correct height based on number of exercises and desired label dimensions
    
    TJBChainTemplate *chainTemplate = self.sortedContent[indexPath.section][indexPath.row];
    
    int numExercises = chainTemplate.numberOfExercises;
    int spacing = 16;
    int chainNameLabelHeight = 30;
    int componentHeight = 35;
    int error = 0;
    
    int totalHeight = spacing + chainNameLabelHeight + componentHeight * numExercises + error;
    
    return totalHeight;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UILabel *label = [[UILabel alloc] init];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"MMMM yyyy";
    
    NSInteger sortSelection = self.sortBySegmentedControl.selectedSegmentIndex;
    BOOL sortByDateLastExecuted = sortSelection == 0;
    BOOL sortByDateCreated = sortSelection == 1;
    
    if (sortByDateLastExecuted){
        
        label.text = [df stringFromDate: self.sortedContent[section].lastObject.dateCreated];
        
    } else if (sortByDateCreated){
        
        label.text = [df stringFromDate: self.sortedContent[section][0].dateCreated];
        
    }
    
    label.backgroundColor = [UIColor darkGrayColor];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize: 20.0];
    label.textAlignment = NSTextAlignmentCenter;
    
    return label;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 40;
    
}

#pragma mark - Button Actions

- (void)didPressNew{
    
    TJBCircuitDesignVC *vc = [[TJBCircuitDesignVC alloc] init];
    
    [self presentViewController: vc
                       animated: YES
                     completion: nil];
    
}

- (void)didPressHomeButton{
    
    [self dismissViewControllerAnimated: NO
                             completion: nil];
    
}

- (void)segmentedControlValueChanged{
    
    //// re-sort the content array based upon the new sorting preference
    
    [self configureSortedContentAndReloadTableData];
    
    //
    
    [self toggleButtonsToOffState];
    
    self.selectedChainTemplate = nil;
    
}

#pragma mark - <UIViewControllerRestoration>

// will want to eventually store table view scroll position

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder{
    
    NewOrExistinigCircuitVC *vc = [[NewOrExistinigCircuitVC alloc] init];
    
    return vc;
    
}

- (IBAction)didPressLaunchButton:(id)sender {
}

- (IBAction)didPressPreviewButton:(id)sender {
}

- (IBAction)didPressModifyButton:(id)sender {
}

@end






















