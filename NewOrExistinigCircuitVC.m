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

// views

#import "TJBCircuitReferenceVC.h"

// aesthetics

#import "TJBAestheticsController.h"

// table view cell

#import "TJBStructureTableViewCell.h"

// date control

#import "TJBSchemeSelectionDateComp.h"


@interface NewOrExistinigCircuitVC () <NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource, UIViewControllerRestoration>

{
    // user selection flow
    
    BOOL _inPreviewMode;
    
}

// IBOutlet

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (weak, nonatomic) IBOutlet UISegmentedControl *sortBySegmentedControl;

@property (weak, nonatomic) IBOutlet UIButton *launchButton;
@property (weak, nonatomic) IBOutlet UIButton *modifyButton;

@property (weak, nonatomic) IBOutlet UIButton *previousMarkButton;

@property (weak, nonatomic) IBOutlet UIView *mainContainer;


@property (weak, nonatomic) IBOutlet UILabel *yearLabel;
@property (weak, nonatomic) IBOutlet UIButton *leftArrowButton;
@property (weak, nonatomic) IBOutlet UIButton *rightArrowButton;
@property (weak, nonatomic) IBOutlet UIScrollView *dateControlScrollView;


// IBAction

- (IBAction)didPressLaunchButton:(id)sender;
- (IBAction)didPressModifyButton:(id)sender;

- (IBAction)didPressLeftArrow:(id)sender;
- (IBAction)didPressRightArrow:(id)sender;


// core data

@property (nonatomic, strong) NSFetchedResultsController *frc;
@property (nonatomic, strong) NSMutableArray <NSMutableArray <TJBChainTemplate *> *> *sortedContent;

// selection

@property (nonatomic, strong) TJBChainTemplate *selectedChainTemplate;
@property (nonatomic, strong) NSIndexPath *lastSelectedIndexPath;

// date control

@property (nonatomic, strong) UIStackView *dateStackView;
@property (nonatomic, strong) NSMutableArray <TJBSchemeSelectionDateComp *> *dateControlObjects;

// state

@property (nonatomic, strong) NSDate *activeDate;
@property (nonatomic, strong) NSNumber *selectedDateObjectIndex;


@end

@implementation NewOrExistinigCircuitVC

#pragma mark - Instantiation

- (instancetype)init{
    
    self = [super init];
    
    // state
    
    self.activeDate = [NSDate date];
    
    // for restoration
    
    self.restorationIdentifier = @"TJBNewOrExistingCircuit";
    self.restorationClass = [NewOrExistinigCircuitVC class];
    
    return self;
}

- (void)initializeActiveVariables{
    
    //// configure state variables for fresh state
    
    _inPreviewMode = NO;
    
}

#pragma mark - View Cycle

- (void)viewDidLoad{
    
    [self configureNavigationBar];
    
    [self viewAesthetics];
    
    [self configureSegmentedControl];
    
    [self toggleButtonsToOffState];
    
    [self fetchCoreDataAndConfigureTableView];
    
    [self configureDateControlsAndSelectToday: YES];
    
}

- (void)clearTransitoryDateControlObjects{
    
    //// must clear the children view controller array as well as remove the stack view from the scroll view
    
    if (self.dateStackView){
        
        for (TJBSchemeSelectionDateComp *vc in self.dateControlObjects){
            
            [vc willMoveToParentViewController: nil];
            [vc removeFromParentViewController];
            
        }
        
        [self.dateStackView removeFromSuperview];
        self.dateStackView = nil;
        
    }
    
    self.dateControlObjects = [[NSMutableArray alloc] init];
    
}


- (void)configureDateControlsAndSelectToday:(BOOL)shouldSelectToday{
    
    //// configures the date controls according to the day stored in firstDayOfDateControlMonth.  Must be sure to first clear existing date control objects if they exist
    
    [self clearTransitoryDateControlObjects];
    
    // layout views so that the frame property is accurate
    
    [self.view layoutIfNeeded];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    
    // month string
    
//    df.dateFormat = @"MMM";
//    NSString *monthString = [df stringFromDate: self.firstDayOfDateControlMonth];
//    self.monthTitle.text = monthTitle;
    
    
    //// stack view and child VC's
    
    // stack view dimensions.  Need to know number of days in month and define widths of contained buttons
    

//    NSRange daysInCurrentMonth = [calendar rangeOfUnit: NSCalendarUnitDay
//                                                inUnit: NSCalendarUnitMonth
//                                               forDate: self.firstDayOfDateControlMonth];
    
    const CGFloat buttonWidth = 60.0;
    const CGFloat buttonSpacing = 0.0;
    const CGFloat buttonHeight = self.dateControlScrollView.frame.size.height;
    
    const CGFloat stackViewWidth = buttonWidth * 12 + 11 * buttonSpacing;
    
    CGRect stackViewRect = CGRectMake(0, 0, stackViewWidth, buttonHeight);
    
    // create the stack view with the proper dimensions and also set the content size of the scroll view
    
    UIStackView *stackView = [[UIStackView alloc] initWithFrame: stackViewRect];
    self.dateStackView = stackView;
    
    self.dateControlScrollView.contentSize = stackViewRect.size;
    
    [self.dateControlScrollView addSubview: stackView];
    
    // configure the stack view's layout properties
    
    stackView.alignment = UIStackViewAlignmentFill;
    stackView.distribution = UIStackViewDistributionFillEqually;
    stackView.spacing = buttonSpacing;
    
    // give the stack view it's content.  All items preceding the for loop are used in the for loop
    
    NSDate *activeDate = self.activeDate;
    
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier: NSCalendarIdentifierGregorian];
    NSDateComponents *dateComps = [calendar components: (NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay)
                                              fromDate: activeDate];
    [dateComps setDay: 1];
    
    NSDate *iterativeDate;
    
    CGSize dateControlSize = CGSizeMake(buttonWidth, buttonHeight);
    
    NSDate *today = [NSDate date];
    
    for (int i = 0; i < 12; i++){
        
        // configure the month
        
        [dateComps setMonth: i + 1];
        iterativeDate = [calendar dateFromComponents: dateComps];
        
        NSLog(@"active date: %@", activeDate);
        
        df.dateFormat = @"MMM";
        NSString *monthString = [df stringFromDate: iterativeDate];
        
        // create the child vc - exactly what configuration the vc receives is dependent upon the iterative date
        
        NSComparisonResult todayMonthCompare = [calendar compareDate: iterativeDate
                                                         toDate: today
                                              toUnitGranularity: NSCalendarUnitMonth];
        
        BOOL iterativeMonthGreaterThanCurrentMonth = todayMonthCompare == NSOrderedAscending;
        
//        NSComparisonResult activeDateMonthCompare = [calendar compareDate: iterativeDate
//                                                                   toDate: activeDate
//                                                        toUnitGranularity: NSCalendarUnitMonth];
        
        BOOL isTheActiveMonth = NO;
        
        if (shouldSelectToday){
            
            isTheActiveMonth = todayMonthCompare == NSOrderedSame;
            
            if (isTheActiveMonth){
                
                self.selectedDateObjectIndex = [NSNumber numberWithInt: i];
                isTheActiveMonth = YES;
                
            }
            
        }
        
        BOOL recordExistsForIterativeDate = NO;
        
        
        
        TJBSchemeSelectionDateComp *dateControlObject = [[TJBSchemeSelectionDateComp alloc] initWithMonthString: monthString
                                                                                           representedDate: iterativeDate
                                                                                                     index: [NSNumber numberWithInt: i]
                                                                                                 isEnabled: !iterativeMonthGreaterThanCurrentMonth
                                                                                                 isCircled: recordExistsForIterativeDate
                                                                                     hasSelectedAppearance: isTheActiveMonth
                                                                                                      size: dateControlSize
                                                                                          masterController: self];
        
        [self.dateControlObjects addObject: dateControlObject];
        
        [self addChildViewController: dateControlObject];
        
        [stackView addArrangedSubview: dateControlObject.view];
        
        [dateControlObject didMoveToParentViewController: self];
        
    }
    
}

- (void)configureSegmentedControl{
    
    //// configure action method for segmented control
    
    [self.sortBySegmentedControl addTarget: self
                                    action: @selector(segmentedControlValueChanged)
                          forControlEvents: UIControlEventValueChanged];
    
}


- (void)viewAesthetics{
    
    // table view
    
    self.tableView.backgroundColor = [[TJBAestheticsController singleton] yellowNotebookColor];
    
    // buttons
    
    NSArray *buttons = @[self.launchButton,
                         self.modifyButton,
                         self.previousMarkButton];
    
    for (UIButton *button in buttons){
        
        UIColor *color = [[TJBAestheticsController singleton] color2];
        [button setBackgroundColor: color];
        [button setTitleColor: [UIColor whiteColor]
                     forState: UIControlStateNormal];
        
    }
    
    // title label
    
//    self.titleLabel.font = [UIFont boldSystemFontOfSize: 20.0];
    
    // container view shadow
    
    UIView *shadowView = self.mainContainer;
    shadowView.backgroundColor = [UIColor clearColor];
    shadowView.clipsToBounds = NO;
    
    CALayer *shadowLayer = shadowView.layer;
    shadowLayer.masksToBounds = NO;
    shadowLayer.shadowColor = [UIColor darkGrayColor].CGColor;
    shadowLayer.shadowOffset = CGSizeMake(0.0, 3.0);
    shadowLayer.shadowOpacity = 1.0;
    shadowLayer.shadowRadius = 3.0;
    
}

- (void)configureNavigationBar{
    
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle: @"Designed"];
    
    // left button
    
    UIBarButtonItem *homeButton = [[UIBarButtonItem alloc] initWithTitle: @"Options"
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
         forCellReuseIdentifier: @"TJBStructureTableViewCell"];
    
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
                         self.modifyButton];
    
    for (UIButton *b in buttons){
        
        b.enabled = YES;
        b.layer.opacity = 1;
        
    }
    
}

- (void)toggleButtonsToOffState{
    
    NSArray *buttons = @[self.launchButton,
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
    
    TJBStructureTableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier: @"TJBStructureTableViewCell"];
    
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
                                date: date
                              number: [NSNumber numberWithInteger: indexPath.row]];
    
    cell.backgroundColor = [UIColor clearColor];
    
    return cell;
    
}

#pragma mark - <UITableViewDelegate>

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return YES;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //// change the background color of the selected chain template and change the control state of the buttons to activate them.  Store the selected chain and the index path of the selected row
    
    // deal with unhighlighting
    
    if (self.lastSelectedIndexPath){
        
//        TJBStructureTableViewCell *lastSelectedCell = [self.tableView cellForRowAtIndexPath: self.lastSelectedIndexPath];
        
//        UIColor *unselectedColor = [[TJBAestheticsController singleton] color1];
//        [lastSelectedCell setOverallColor: unselectedColor];
        
    }
    self.lastSelectedIndexPath = indexPath;
    
    // deal with highlighting
    
//    TJBStructureTableViewCell *currentCell = [self.tableView cellForRowAtIndexPath: indexPath];
    
//    UIColor *selectedColor = [UIColor redColor];
//    [currentCell setOverallColor: selectedColor];
    
    // store the selected chain template and configure the buttons
    
    TJBChainTemplate *chainTemplate = self.sortedContent[indexPath.section][indexPath.row];
    
    self.selectedChainTemplate = chainTemplate;

    [self toggleButtonsToOnState];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    TJBChainTemplate *chainTemplate = self.sortedContent[indexPath.section][indexPath.row];
    return [TJBStructureTableViewCell suggestedCellHeightForChainTemplate: chainTemplate];
    
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
    
    label.backgroundColor = [UIColor lightGrayColor];
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize: 20.0];
    label.textAlignment = NSTextAlignmentCenter;
    
    return label;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 60;
    
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
    
    // state
    
//    self.mainContainer.hidden = YES;
//    self.tableView.hidden = NO;
//    _inPreviewMode = NO;
//    [self.previewButton setTitle: @"Preview"
//                        forState: UIControlStateNormal];
    
//    if (self.activeCircuitReferenceVC){
//        
//        [self.activeCircuitReferenceVC removeFromParentViewController];
//        [self.activeCircuitReferenceVC.view removeFromSuperview];
//        self.activeCircuitReferenceVC = nil;
//        
//    }
    
    //
    
    [self toggleButtonsToOffState];
    
    self.selectedChainTemplate = nil;
    
}

- (IBAction)didPressLaunchButton:(id)sender {
    
    TJBCircuitModeTBC *tbc = [[TJBCircuitModeTBC alloc] initWithNewRealizedChainAndChainTemplateFromChainTemplate: self.selectedChainTemplate];
    
    [self presentViewController: tbc
                       animated: YES
                     completion: nil];
    
}

//- (IBAction)didPressPreviewButton:(id)sender{
//    
//    if (_inPreviewMode == NO){
//        
//        //// hide the table view and present the chain template in its place.  Update state variables.  Change preview button appearance
//        
//        _inPreviewMode = YES;
//        
//        self.mainContainer.hidden = NO;
//        self.tableView.hidden = YES;
//        
//        // create a TJBCircuitReferenceVC with the dimensions of the mainContainer
//        
//        CGSize containerViewSize = self.mainContainer.frame.size;
//        
//        NSNumber *viewHeight = [NSNumber numberWithFloat: containerViewSize.height];
//        NSNumber *viewWidth = [NSNumber numberWithFloat: containerViewSize.width];
//        
//        TJBCircuitReferenceVC *vc = [[TJBCircuitReferenceVC alloc] initWithChainTemplate: self.selectedChainTemplate
//                                                                       contentViewHeight: viewHeight
//                                                                        contentViewWidth: viewWidth];
//        
//        self.activeCircuitReferenceVC = vc;
//        
//        [self addChildViewController: vc];
//        
//        [self.mainContainer addSubview: vc.view];
//        
//        [vc didMoveToParentViewController: self];
//        
//        // preview button
//        
//        [self.previewButton setTitle: @"List"
//                            forState: UIControlStateNormal];
//        
//    } else if (_inPreviewMode == YES){
//        
//        //// toggle the preview button appearance, update state variables, eliminate the child VC and subview, un-hide the table view
//        
//        // state
//        
//        self.mainContainer.hidden = YES;
//        _inPreviewMode = NO;
//        
//        // preview button
//        
//        [self.previewButton setTitle: @"Preview"
//                            forState: UIControlStateNormal];
//        
//        // child VC and subview
//        
//        [self.activeCircuitReferenceVC removeFromParentViewController];
//        [self.activeCircuitReferenceVC.view removeFromSuperview];
//        self.activeCircuitReferenceVC = nil;
//        
//        // table view
//        
//        self.tableView.hidden = NO;
//        
//    }
//
//}

- (IBAction)didPressModifyButton:(id)sender {
}

- (IBAction)didPressLeftArrow:(id)sender {
}

- (IBAction)didPressRightArrow:(id)sender {
}

#pragma mark - <UIViewControllerRestoration>

// will want to eventually store table view scroll position

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder{
    
    NewOrExistinigCircuitVC *vc = [[NewOrExistinigCircuitVC alloc] init];
    
    return vc;
    
}



@end






















