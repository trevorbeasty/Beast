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
@property (weak, nonatomic) IBOutlet UIButton *createNewChainButton;
@property (weak, nonatomic) IBOutlet UILabel *sortByLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sortBySegmentedControl;

// for restoration

//@property (copy) void (^restorationBlock)(void);

- (IBAction)didPressCreateNewChain:(id)sender;

// core data

@property (nonatomic, strong) NSFetchedResultsController *frc;
@property (nonatomic, strong) NSMutableArray <NSMutableArray <TJBChainTemplate *> *> *sortedContent;

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
    
    [self fetchCoreDataAndConfigureTableView];
    
    [self addBackground];
    
    [self viewAesthetics];
    
    [self configureSegmentedControl];
    
}

- (void)configureSegmentedControl{
    
    //// configure action method for segmented control
    
    [self.sortBySegmentedControl addTarget: self
                                    action: @selector(segmentedControlValueChanged)
                          forControlEvents: UIControlEventValueChanged];
    
}


- (void)viewAesthetics{
    
    [[TJBAestheticsController singleton] configureButtonsInArray: @[self.createNewChainButton]
                                                     withOpacity: .85];
    
    self.tableView.layer.opacity = .85;
    
}

- (void)addBackground{
    
    [[TJBAestheticsController singleton] addFullScreenBackgroundViewWithImage: [UIImage imageNamed: @"girlOverheadKettlebell"]
                                                                   toRootView: self.view
                                                                 imageOpacity: .35];
}

- (void)viewWillAppear:(BOOL)animated{
    
    NSError *error = nil;
    [self.frc performFetch: &error];
    
    [self configureSortedContentAndReloadTableData];

}

- (void)configureNavigationBar{
    
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle: @"Scheme Selection"];
    
    UIBarButtonItem *homeButton = [[UIBarButtonItem alloc] initWithTitle: @"Home"
                                                                   style: UIBarButtonItemStyleDone
                                                                  target: self
                                                                  action: @selector(didPressHomeButton)];
    
    [navItem setLeftBarButtonItem: homeButton];
    
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
    
    NSMutableArray<TJBChain *> *interimArray = [[NSMutableArray alloc] initWithArray: self.frc.fetchedObjects];
    
    NSInteger sortSelection = self.sortBySegmentedControl.selectedSegmentIndex;
    BOOL sortByDateLastExecuted = sortSelection == 0;
    BOOL sortByDateCreated = sortSelection == 1;
    
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier: NSCalendarIdentifierGregorian];
    
    if (sortByDateLastExecuted){
        
        self.sortedContent = nil;
        
    } else if (sortByDateCreated){
        
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
        }
    }
    
    [self.tableView reloadData];
    
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
    
    [cell configureWithChainTemplate: chainTemplate];
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
    
}

#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    TJBChainTemplate *chainTemplate = [self.frc objectAtIndexPath: indexPath];
    
    TJBCircuitModeTBC *tbc = [[TJBCircuitModeTBC alloc] initWithNewRealizedChainAndChainTemplateFromChainTemplate: chainTemplate];
    
    [self presentViewController: tbc
                       animated: YES
                     completion: nil];
    
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
    
    label.text = [[NSNumber numberWithInteger: section] stringValue];
    
    return label;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 40;
    
}

#pragma mark - Button Actions

- (IBAction)didPressCreateNewChain:(id)sender {
    
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
    
}

#pragma mark - <UIViewControllerRestoration>

// will want to eventually store table view scroll position

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder{
    
    NewOrExistinigCircuitVC *vc = [[NewOrExistinigCircuitVC alloc] init];
    
    return vc;
    
}

@end






















