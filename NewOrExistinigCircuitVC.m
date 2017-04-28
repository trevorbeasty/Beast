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

#import "TJBActiveGuidanceTBC.h" // tab bar controller for active guidance

// VC's to present

#import "TJBCircuitReferenceContainerVC.h"
#import "TJBCompleteChainHistoryVC.h"
#import "TJBCircuitTemplateContainerVC.h"

// views

#import "TJBCircuitReferenceVC.h"

// aesthetics

#import "TJBAestheticsController.h"

// table view cell

#import "TJBRealizedChainCell.h"
#import "TJBNoDataCell.h"

// date control

#import "TJBSchemeSelectionDateComp.h"


#pragma mark - Constants


typedef enum{
    TJBToolbarHidden,
    TJBToolBarNotHidden
}TJBToolbarState;



@interface NewOrExistinigCircuitVC () <NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource>

{
    // user selection flow
    
    BOOL _viewingChainHistory;
    BOOL _fetchedObjectsNeedUpdating;
    BOOL _displayedContentNeedsUpdating;
    TJBToolbarState _toolbarState;
    
}

// IBOutlet

@property (strong) UIActivityIndicatorView *activeActivityIndicator;

@property (weak, nonatomic) IBOutlet UIView *mainContainer;
@property (weak, nonatomic) IBOutlet UILabel *yearLabel;
@property (weak, nonatomic) IBOutlet UIButton *leftArrowButton;
@property (weak, nonatomic) IBOutlet UIButton *rightArrowButton;
@property (weak, nonatomic) IBOutlet UIScrollView *dateControlScrollView;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UIView *topTitleBar;

@property (weak, nonatomic) IBOutlet UILabel *routinesByLabel;
@property (weak, nonatomic) IBOutlet UILabel *monthYearTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfRecordsLabel;

@property (weak, nonatomic) IBOutlet UIToolbar *toolbar;
@property (weak, nonatomic) IBOutlet UILabel *sortByBottomLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *sortBySegmentedControl;
@property (weak, nonatomic) IBOutlet UIButton *arrowControlButton;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *launchButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *historyButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *createNewButton;

//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *toolbarBottomSpacingConstr;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *segmentedControlBottomSpaceConstr;


// IBAction

- (IBAction)didPressLeftArrow:(id)sender;
- (IBAction)didPressRightArrow:(id)sender;
- (IBAction)didPressBackButton:(id)sender;
- (IBAction)didPressArrowControlButton:(id)sender;


// toolbar button actions

- (IBAction)didPressLaunchButton:(id)sender;
- (IBAction)didPressHistoryButton:(id)sender;
- (IBAction)didPressDeleteButton:(id)sender;
- (IBAction)didPressNewRoutine:(id)sender;

// core

@property (strong) UITableView *activeTableView;
@property (strong) UIScrollView *activeScrollView;

//// state
// these are the content arrays. Due to algorithmic considerations, the sortedContent is such that the 0th array is December and the 11th array is January

@property (nonatomic, strong) NSMutableArray <TJBChainTemplate *> *tvSortedContent; // this is the array used by the table view as a data source. It holds a collection of chain templates for each month of the year actively displayed in the table view. It is also the array accessed when a user selects a table view cell. It should be reloaded anytime a date control object is selected that corresponds to a different year than it currently represents

@property (nonatomic, strong) NSMutableArray <TJBChainTemplate *> *dcSortedContent; // holds all chain templates, sorted according to the sorting state

// these two dates ultimately control what should be displayed for the date control and table view

@property (nonatomic, strong) NSDate *tvActiveDate; // table view reference date - designates which month of content should be displayed in the active table view
@property (nonatomic, strong) NSDate *dcActiveDate; // date control reference date - designates which year should be represented by the date controls

// table view selection - keeps track of user selections in the presented table view

@property (nonatomic, strong) TJBChainTemplate *selectedChainTemplate;
@property (nonatomic, strong) NSIndexPath *lastSelectedIndexPath;

// date control selection - keeps track of user date control selections

@property (nonatomic, strong) NSNumber *selectedDateObjectIndex;

// date control objects - must be tracked this way because they are created programmatically

@property (nonatomic, strong) UIStackView *dateStackView;
@property (nonatomic, strong) NSMutableArray <TJBSchemeSelectionDateComp *> *dateControlObjects;

// complete chain history vc - is presented on top of table view. This property keeps track of the object

@property (strong) TJBCompleteChainHistoryVC *chainHistoryVC;
@property (strong) UIScrollView *chainHistoryScrollView;
@property (strong) UIButton *viewHistoryReturnButton;

@property (strong) NSCalendar *calendar; // for optimization

@end


#pragma mark - Constants

static NSTimeInterval const toolbarSlidingAnimationTime = .2;

static CGFloat const historyReturnButtonHeight = 44;
static CGFloat const historyReturnButtonBottomSpacing = 8;


// content generation

static NSTimeInterval const contentLoadingSmoothingDelay = .25;


// date controls

static const CGFloat buttonWidth = 60.0;
static const CGFloat buttonSpacing = 0.0;




@implementation NewOrExistinigCircuitVC

#pragma mark - Instantiation

- (instancetype)init{
    
    self = [super init];
    

    [self initializeStateVariables];
    
    return self;
}


#pragma mark - Instantiation Helper Methods

- (void)initializeStateVariables{
    
    // configure state variables for fresh state
    
    _viewingChainHistory = NO;
    
    // active dates
    
    NSDate *today = [NSDate date];
    self.tvActiveDate = today;
    self.dcActiveDate = today;
    
    // state
    
    _toolbarState = TJBToolBarNotHidden;
    _fetchedObjectsNeedUpdating = NO;
    _displayedContentNeedsUpdating = YES;
    
}

#pragma mark - View Cycle

- (void)viewDidLoad{
    
    [self viewAesthetics];
    
    // segmented control
    
    [self configureSegmentedControlNotifications];
    [self configureCoreDataNotifications];
    
    [self configureBasicLabelText];
    
    return;
    
}

- (void)viewWillAppear:(BOOL)animated{
    
    if (_displayedContentNeedsUpdating == YES){
        
        [self hideAllBottomControls];
        
    }
    
}

- (void)viewDidAppear:(BOOL)animated{
    
    [self showActivityIndicator];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, contentLoadingSmoothingDelay * NSEC_PER_SEC),  dispatch_get_main_queue(),  ^{
        
        if (_fetchedObjectsNeedUpdating == YES || !self.dcSortedContent){
            
            self.dcSortedContent = [self allChainTemplatesFetchedAndSortedAccordingToSortingState];
            self.tvSortedContent = [self chainTemplatesForTVActiveDate];
            
        }
        
        if (_displayedContentNeedsUpdating){
            
            // create the date controls
            
            [self configureDateControlsBasedOnDCActiveDate];
            
            // configure the correct selection appearance for the date controls
            
            int selectedDateControlIndex = [self dateControlObjectIndexForDate: self.tvActiveDate];
            
            if (self.selectedDateObjectIndex){
                
                [self.dateControlObjects[[self.selectedDateObjectIndex intValue]] configureAsNotSelected];
                
            }
            
            [self.dateControlObjects[selectedDateControlIndex] configureAsSelected];
            self.selectedDateObjectIndex = @(selectedDateControlIndex);
            
            // content generation
            
            [self clearAllTableViewsAndDirectlyAssociatedObjects];
            
            [self addEmbeddedTableViewToViewHierarchy];
            
            [self updateAllTitleLabelsForNewContent];
            
            // visual state
            
            [self giveControlsEnabledConfiguration];
            [self configureToolbarButtonsAccordingToActiveState];
            
            [self.activeActivityIndicator stopAnimating];
            [self unhideAllBottomControls];
            
        }
        
        _fetchedObjectsNeedUpdating = NO;
        _displayedContentNeedsUpdating = NO;
        
    });

    
}

#pragma mark - View Helper Methods

- (void)configureSegmentedControlNotifications{
    
    [self.sortBySegmentedControl addTarget: self
                                    action: @selector(segmentedControlValueDidChange)
                          forControlEvents: UIControlEventValueChanged];
    
}





- (void)viewAesthetics{
    
    self.topTitleBar.backgroundColor = [UIColor darkGrayColor];
    
    // meta view
    
    self.view.backgroundColor = [UIColor blackColor];
    
    
    // container view shadow
    
    UIView *shadowView = self.mainContainer;
    shadowView.backgroundColor = [[TJBAestheticsController singleton] yellowNotebookColor];
    shadowView.clipsToBounds = NO;
    
    CALayer *shadowLayer = shadowView.layer;
    shadowLayer.masksToBounds = NO;
    shadowLayer.shadowColor = [UIColor darkGrayColor].CGColor;
    shadowLayer.shadowOffset = CGSizeMake(0.0, 3.0);
    shadowLayer.shadowOpacity = 1.0;
    shadowLayer.shadowRadius = 3.0;
    
    // date controls
    
    self.dateControlScrollView.backgroundColor = [UIColor darkGrayColor];
    
    // year label
    
    NSArray *titleLabels = @[self.yearLabel];
    for (UILabel *label in titleLabels){
        
        label.backgroundColor = [UIColor darkGrayColor];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont boldSystemFontOfSize: 20];
        
    }
    
    // arrows and other bar buttons
    
    NSArray *arrows = @[self.rightArrowButton, self.leftArrowButton];
    for (UIButton *b in arrows){
        
        b.backgroundColor = [UIColor darkGrayColor];
        [b setTitleColor: [UIColor whiteColor]
                forState: UIControlStateNormal];
        [b.titleLabel setFont: [UIFont systemFontOfSize: 40.0]];
        
    }
    
    NSArray *barButtons = @[self.backButton];
    for (UIButton *button in barButtons){
        
        button.backgroundColor = [UIColor darkGrayColor];
        [button setTitleColor: [[TJBAestheticsController singleton] blueButtonColor]
                              forState: UIControlStateNormal];
        button.titleLabel.font = [UIFont boldSystemFontOfSize: 15.0];
        
    }
    
    // title labels
    
    NSArray *grayBarTitleLabels = @[self.routinesByLabel, self.monthYearTitleLabel, self.numberOfRecordsLabel];
    for (UILabel *lab in grayBarTitleLabels){
        
        lab.backgroundColor = [UIColor grayColor];
        lab.textColor = [UIColor whiteColor];
        lab.font = [UIFont boldSystemFontOfSize: 15];
        
    }

    // bottom controls
    
    self.arrowControlButton.backgroundColor = [UIColor grayColor];
    CALayer *acbLayer = self.arrowControlButton.layer;
    acbLayer.cornerRadius = 25;
    acbLayer.masksToBounds = YES;
    acbLayer.borderWidth = 1;
    acbLayer.borderColor = [[TJBAestheticsController singleton] paleLightBlueColor].CGColor;
    
    self.toolbar.backgroundColor = [UIColor grayColor];
    
    self.sortBySegmentedControl.backgroundColor = [UIColor grayColor];
    self.sortBySegmentedControl.tintColor = [[TJBAestheticsController singleton] paleLightBlueColor];
    CALayer *sbscLayer = self.sortBySegmentedControl.layer;
    sbscLayer.masksToBounds = YES;
    sbscLayer.cornerRadius = 22;
    sbscLayer.borderColor = [[TJBAestheticsController singleton] paleLightBlueColor].CGColor;
    sbscLayer.borderWidth = 1.0;
    
    self.toolbar.barTintColor = [UIColor grayColor];
    self.toolbar.tintColor = [[TJBAestheticsController singleton] paleLightBlueColor];
    CALayer *tbLayer = self.toolbar.layer;
    tbLayer.cornerRadius = 22;
    tbLayer.masksToBounds = YES;
    tbLayer.borderColor = [[TJBAestheticsController singleton] paleLightBlueColor].CGColor;
    tbLayer.borderWidth = 1.0;
    
    self.sortByBottomLabel.font = [UIFont boldSystemFontOfSize: 15];
    self.sortByBottomLabel.backgroundColor = [UIColor clearColor];
    self.sortByBottomLabel.textColor = [UIColor blackColor];
    
}

- (void)configureTableView:(UITableView *)tableView{
    
    // table view configuration
    
    // cells
    
    UINib *nib = [UINib nibWithNibName: @"TJBRealizedChainCell"
                                bundle: nil];
    
    [tableView registerNib: nib
    forCellReuseIdentifier: @"TJBRealizedChainCell"];
    
    UINib *nib2 = [UINib nibWithNibName: @"TJBWorkoutLogTitleCell"
                                 bundle: nil];
    
    [tableView registerNib: nib2
    forCellReuseIdentifier: @"TJBWorkoutLogTitleCell"];
    
    UINib *nib3 = [UINib nibWithNibName: @"TJBNoDataCell"
                                 bundle: nil];
    
    [tableView registerNib: nib3
    forCellReuseIdentifier: @"TJBNoDataCell"];
    
    // data source and delegate
    
    tableView.delegate = self;
    tableView.dataSource = self;
    
}

- (void)configureBasicLabelText{
    
    self.sortByBottomLabel.text = @"sort by\ndate:";
    
}


#pragma mark - SchemeSelectionDateCompDelegate

- (void)didSelectObjectWithIndex:(NSNumber *)index{
    
    // update the tvActiveDate
    
    NSCalendar *cal = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
    NSDateComponents *dateComps = [cal components: NSCalendarUnitYear
                                         fromDate: self.dcActiveDate];
    [dateComps setMonth: [index intValue] + 1];
    [dateComps setDay: 1];
    
    NSDate *selectedDate = [cal dateFromComponents: dateComps];
    self.tvActiveDate = selectedDate;
    
    // select the newly selected date control
    
    if (self.selectedDateObjectIndex){
        
        [self.dateControlObjects[[self.selectedDateObjectIndex intValue]] configureAsNotSelected];
        
    }
    
    [self.dateControlObjects[[index intValue]] configureAsSelected];
    self.selectedDateObjectIndex = index;
    
    
    // give view loading appearance
    
    [self giveControlsDisabledConfiguration];
    [self showActivityIndicator];
    
    // configure labels appropriately
    
    [self updateTitleLabelCorrespondingToActiveTVDate];
    self.numberOfRecordsLabel.text = @"";
    
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, contentLoadingSmoothingDelay * NSEC_PER_SEC), dispatch_get_main_queue(),  ^{
        
        // relaod tvSortedContent
        
        self.tvSortedContent = [self chainTemplatesForTVActiveDate];

        // content generation
        
        [self clearAllTableViewsAndDirectlyAssociatedObjects];
        [self addEmbeddedTableViewToViewHierarchy];
        
        // view appearance
        
        [self.activeActivityIndicator stopAnimating];
        [self configureSelectionAsNil];
        [self giveControlsEnabledConfiguration];
        [self configureToolbarButtonsAccordingToActiveState];
        [self updateAllTitleLabelsForNewContent];
        
        
    });
    

    

    
    
}







#pragma mark - Routine Content Generation Helper Methods


- (void)addEmbeddedTableViewToViewHierarchy{
    
    //// returns a table view embedded inside a scroll view. This is done so that the table view is forced to layout all its content
    
    UIScrollView *sv = [[UIScrollView alloc] initWithFrame: self.mainContainer.bounds];
    self.activeScrollView = sv;
    
    CGFloat tvContentHeight = [self totalTableViewHeightBasedOnTVSortedContent];
    
    if (tvContentHeight < self.mainContainer.frame.size.height){
        tvContentHeight = self.mainContainer.frame.size.height;
    }
    
    CGSize svContentSize = [self scrollViewContentSize]; // the scroll view is large enough that the table view will layout all of its content plus a little breather room above the bottom controls
    sv.contentSize = svContentSize;
    
    sv.backgroundColor = [UIColor clearColor];
    sv.bounces = YES;
    
    UITableView *tv = [[UITableView alloc] init];
    self.activeTableView = tv;
    
    [self configureTableView: tv];
    
    tv.frame = CGRectMake(0, 0, svContentSize.width, tvContentHeight);
    tv.backgroundColor = [[TJBAestheticsController singleton] yellowNotebookColor];
    tv.separatorColor = [UIColor lightGrayColor];
    tv.separatorInset = UIEdgeInsetsMake(0, 16, 0, 0);
    
    tv.dataSource = self;
    tv.delegate = self;
    
    [sv addSubview: tv];
    [self.mainContainer insertSubview: sv
                              atIndex: 0];
    
}


- (CGSize)scrollViewContentSize{
    
    CGFloat width = self.mainContainer.frame.size.width;
    
    CGFloat contentNaturalHeight = [self totalTableViewHeightBasedOnTVSortedContent];
    CGFloat bottomSpaceOccupiedByControls = [self breatherRoomForChainTemplateScrollView];
    CGFloat mainContainerHeight = self.mainContainer.frame.size.height;
    CGFloat spaceNotOccupiedByControls = mainContainerHeight - bottomSpaceOccupiedByControls;
    
    // the following if structure brackets the content height into 3 separate groups
    
    if (contentNaturalHeight < spaceNotOccupiedByControls){
        
        return CGSizeMake(width, contentNaturalHeight);
        
    } else if (contentNaturalHeight < mainContainerHeight){
        
        CGFloat height = mainContainerHeight + bottomSpaceOccupiedByControls;
        return CGSizeMake(width, height);
        
    } else{
        
        CGFloat height = contentNaturalHeight + bottomSpaceOccupiedByControls;
        return CGSizeMake(width,  height);
        
    }
    
    
//    CGFloat svContentHeight = [self totalTableViewHeightBasedOnTVSortedContent] + [self breatherRoomForChainTemplateScrollView];
//    
//    if (svContentHeight < self.mainContainer.frame.size.height){
//        svContentHeight = self.mainContainer.frame.size.height;
//    }
//    
//    return  CGSizeMake(self.mainContainer.frame.size.width, svContentHeight);
    
}

- (CGFloat)breatherRoomForChainTemplateScrollView{
    
    // the extra room is intended to allow the contents bottom edge to sit 8 points below the control arrow's bottom edge at all points
    
    [self.view layoutSubviews];
    
    CGFloat bottomControlsHeight =  self.mainContainer.frame.size.height - self.toolbar.frame.origin.y;
    CGFloat extraSpace = 8;
    
    return bottomControlsHeight + extraSpace;
    
}


- (int)dateControlObjectIndexForDate:(NSDate *)date{
    
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier: NSCalendarIdentifierGregorian];
    NSInteger monthAsInt = [calendar component: NSCalendarUnitMonth
                                      fromDate: date];
    
    return (int)monthAsInt - 1;
    
}


- (CGFloat)totalTableViewHeightBasedOnTVSortedContent{
    
    // based on the array of chain templates found in tvSortedContent, calculate the total table view height
    
    NSInteger iterationLimit; // based on the count of objects in tvSortedContent, the amount of cells presented by the table view will vary
    
    if (self.tvSortedContent.count == 0){
        
        iterationLimit = 1;
        
    } else{
        
        iterationLimit = self.tvSortedContent.count;
        
    }
    
    CGFloat sum = 0;
    
    for (int i = 0; i < iterationLimit; i++){
        
        NSIndexPath *path = [NSIndexPath indexPathForRow: i
                                               inSection: 0];
        
        CGFloat height = [self tableView: self.activeTableView
                 heightForRowAtIndexPath: path];
        
        sum += height;
        
    }
    
    return sum;
    
}


- (void)showActivityIndicator{
    
    if (!self.activeActivityIndicator){
        
        UIActivityIndicatorView *indView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
        self.activeActivityIndicator = indView;
        
        indView.frame = self.mainContainer.frame;
        indView.backgroundColor = [[TJBAestheticsController singleton] yellowNotebookColor];
        indView.layer.opacity = .9;
        indView.hidesWhenStopped = YES;
        
        [self.view addSubview: indView];
        
    }
    
    [self.activeActivityIndicator startAnimating];
    
}



#pragma mark - Title Labels Describing Content

- (void)updateAllTitleLabelsForNewContent{
    
    [self updateTitleLabelCorrespondingToActiveTVDate];
    [self updateNumberOfRecordsTitleLabel];
    
}

- (void)updateTitleLabelCorrespondingToActiveTVDate{
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"MMM yyyy";
    self.monthYearTitleLabel.text = [df stringFromDate: self.tvActiveDate];
    
}

- (void)updateNumberOfRecordsTitleLabel{
    
    NSString *recordsWord = self.tvSortedContent.count == 1 ? @"Record" : @"Records";
    
    NSString *text = [NSString stringWithFormat: @"%d %@",
                      (int)self.tvSortedContent.count,
                      recordsWord];
    self.numberOfRecordsLabel.text = text;
    
}


#pragma mark - Model Object Fetching and Manipulation

- (NSFetchRequest *)chainTemplateFetchRequest{
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName: @"ChainTemplate"];
    
    NSSortDescriptor *nameSort = [NSSortDescriptor sortDescriptorWithKey: @"name"
                                                               ascending: YES];
    
    [request setSortDescriptors: @[nameSort]];
    
    // predicate
    // the showInRoutineList property determines if a chain should appear in the routine list
    
    NSPredicate *showInRoutineListPred = [NSPredicate predicateWithFormat: @"showInRoutineList == YES"];
    [request setPredicate: showInRoutineListPred];
    
    return request;
    
}


- (NSMutableArray<TJBChainTemplate *> *)allChainTemplatesFetchedAndSortedAccordingToSortingState{
    
    //// given the chain templates in fetched results and the current sorting selection, derive the sorted content for the year designated by the reference date
    // this method independently evaluates the active index of the segmented control
    
    BOOL sortByDateLastExecuted = self.sortBySegmentedControl.selectedSegmentIndex == 1;
    
    
    NSFetchRequest *fr = [self chainTemplateFetchRequest];
    NSManagedObjectContext *moc = [[CoreDataController singleton] moc];
    NSError *error = nil;
    NSArray *chainTemplates = [moc executeFetchRequest: fr
                                                 error: &error];
    NSMutableArray<TJBChainTemplate *> *interimArray = [[NSMutableArray alloc] initWithArray: chainTemplates];
    
    if (sortByDateLastExecuted){
        
        [self filterAndSortArrayByDateLastExecuted: interimArray];
        return interimArray;
        
    } else{
        
        [self filterAndSortArrayByDateCreated: interimArray];
        return interimArray;
        
    }
    
}

- (NSMutableArray<TJBChainTemplate *> *)chainTemplatesForTVActiveDate{
    
    if (!self.dcSortedContent){
        
        self.dcSortedContent = [self allChainTemplatesFetchedAndSortedAccordingToSortingState];
        
    }
    
    NSMutableArray *collector = [[NSMutableArray alloc] init];
    NSCalendar *calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
    NSDate *iterativeChainDate;
    TJBChainTemplate *iterativeChain;
    
    for (int i = 0; i < self.dcSortedContent.count; i++){
        
        iterativeChain = self.dcSortedContent[i];
        iterativeChainDate = [self dateForChainTemplateBasedOnSortingState: iterativeChain];
        
        BOOL chainDateInActiveMonth = [calendar isDate: iterativeChainDate
                                           equalToDate: self.tvActiveDate
                                     toUnitGranularity: NSCalendarUnitMonth];
        
        if (chainDateInActiveMonth){
            
            [collector addObject: iterativeChain];
            
        }

    }
    
    
    return collector;
    
}

- (NSDate *)dateForChainTemplateBasedOnSortingState:(TJBChainTemplate *)ct{
    
    NSDate *date;
    
    if (self.sortBySegmentedControl.selectedSegmentIndex == 1){
        
        date = [self largestRealizeChainDateForChainTemplate: ct];
        
    } else{
        
        date = ct.dateCreated;
        
    }
    
    return date;
    
}


- (void)filterAndSortArrayByDateLastExecuted:(NSMutableArray<TJBChainTemplate *> *)array{
    
    NSMutableIndexSet *indexSet = [[NSMutableIndexSet alloc] init];
    
    for (TJBChainTemplate *chainTemplate in array){
        
        NSOrderedSet *realizedChains = chainTemplate.realizedChains;
        
        BOOL hasNoRealizedChains = [realizedChains count] == 0;
        
        if (hasNoRealizedChains){
            
            [indexSet addIndex: [array indexOfObject: chainTemplate]];
            
        }
        
    }
    
    [array removeObjectsAtIndexes: indexSet];
    
    // now, only chain templates with realized chains remain
    
    [array sortUsingComparator: ^(TJBChainTemplate *chain1, TJBChainTemplate *chain2){
        
        NSDate *date1 = [self largestRealizeChainDateForChainTemplate: chain1];
        NSDate *date2 = [self largestRealizeChainDateForChainTemplate: chain2];
        
        int dateDifference = [date1 timeIntervalSinceDate: date2];
        BOOL date1IsLater = dateDifference > 0;
        
        return date1IsLater ? NSOrderedAscending : NSOrderedDescending;
        
    }];
    
}


- (void)filterAndSortArrayByDateCreated:(NSMutableArray<TJBChainTemplate *> *)array{
    
    
    [array sortUsingComparator: ^(TJBChainTemplate *chain1, TJBChainTemplate *chain2){
        
        NSDate *date1 = chain1.dateCreated;
        NSDate *date2 = chain2.dateCreated;
        
        int dateDifference = [date1 timeIntervalSinceDate: date2];
        BOOL date1IsLater = dateDifference > 0;
        
        return date1IsLater ? NSOrderedAscending : NSOrderedDescending;
        
    }];
    
}

- (BOOL)chainTemplateExistsForMonth:(NSDate *)date{
    
    for (TJBChainTemplate *ct in self.dcSortedContent){
        
        BOOL dateMatch = [self chainTemplate: ct
                                   isInMonth: date];
        
        if (dateMatch){
            
            return YES;
            
        }
    }
    
    return NO;
    
}

- (BOOL)chainTemplate:(TJBChainTemplate *)ct isInMonth:(NSDate *)date{
    
    if (!self.calendar){
        
        self.calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];

    }
    
    NSDate *ctDate = [self dateForChainTemplateBasedOnSortingState: ct];
    
    return [self.calendar isDate: ctDate
                     equalToDate: date
               toUnitGranularity: NSCalendarUnitMonth];

}


#pragma mark - Content Sorting and Grouping Helper Methods


- (NSDate *)largestRealizeChainDateForChainTemplate:(TJBChainTemplate *)chainTemplate{
    
    
    return chainTemplate.realizedChains.lastObject.dateCreated;
    
    
}

- (TJBRealizedChain *)largestRealizeChainInReferenceYearAndMonthForChainTemplate:(TJBChainTemplate *)chainTemplate referenceDate:(NSDate *)referenceDate {
    
    //// the goal is to get the largest date for the current year so that dates are correctly expressed.  This algorithm relies on the chain template's chains being in chronological order.  This method assumes their is a valid return value.
    
    NSOrderedSet<TJBRealizedChain *> *realizedChains = chainTemplate.realizedChains;
    NSInteger limit = realizedChains.count;
    
    NSDate *iterativeDate;
    
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier: NSCalendarIdentifierGregorian];
    
    for (int i = 0; i < limit; i++){
        
        NSInteger reverseOrder = (limit - 1) - i;
        TJBRealizedChain *iterativeChain = realizedChains[reverseOrder];
        iterativeDate = iterativeChain.dateCreated;
        
        BOOL iterativeChainInRefYear = [calendar isDate: iterativeDate
                                            equalToDate: referenceDate
                                      toUnitGranularity: NSCalendarUnitYear];
        
        BOOL iterativeChainInRefMonth = [calendar isDate: iterativeDate
                                             equalToDate: referenceDate
                                       toUnitGranularity: NSCalendarUnitMonth];
        
        if (iterativeChainInRefYear && iterativeChainInRefMonth){
            
            return iterativeChain;
            
        }
        
    }
    
    return nil;
    
}



#pragma mark - Core Data Notifications




- (void)configureCoreDataNotifications{
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(coreDataUpdateRequiredForRoutineSelection)
                                                 name: NSManagedObjectContextDidSaveNotification
                                               object: [[CoreDataController singleton] moc]];
    
}


- (void)coreDataUpdateRequiredForRoutineSelection{
    
    _fetchedObjectsNeedUpdating = YES;
    _displayedContentNeedsUpdating = YES;
    
}






#pragma mark - Date Controls


- (void)incrementDCACtiveYearWithIncrementDirectionForward:(BOOL)incrementDirectionForward{
    
    int yearDelta = incrementDirectionForward ? 1 : -1;
    
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier: NSCalendarIdentifierGregorian];
    NSDateComponents *dateComps = [calendar components: NSCalendarUnitYear
                                              fromDate: self.dcActiveDate];
    
    // it is arbitrary what day in the year the dcActiveDate represents
    // I set the month and day to 1 here as a convention
    
    dateComps.year += yearDelta;
    [dateComps setDay: 1];
    [dateComps setMonth: 1];
    self.dcActiveDate = [calendar dateFromComponents: dateComps];
    
    [self configureDateControlsBasedOnDCActiveDate];
    
}


- (void)configureDateControlsBasedOnDCActiveDate{
    
    // configures the date controls according to the date stored in the 'dcActiveDate' property.  Must be sure to first clear existing date control objects if they exist
    
    [self clearTransitoryDateControlObjects];
    
    NSDate *activeDate = self.dcActiveDate;
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"YYYY";
    self.yearLabel.text = [df stringFromDate: activeDate];
    
    // stack view and child VC's
    // stack view dimensions.  Need to know number of days in month and define widths of contained buttons
    

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
        
        df.dateFormat = @"MMM";
        NSString *monthString = [df stringFromDate: iterativeDate];
        
        // create the child vc - exactly what configuration the vc receives is dependent upon the iterative date
        // determine if the month corresponding to the date control that is about to be created is in the future or the past (only controls in the past can be selected)
        
        NSComparisonResult todayMonthCompare = [calendar compareDate: iterativeDate
                                                              toDate: today
                                                   toUnitGranularity: NSCalendarUnitMonth];
        
        BOOL iterativeMonthGreaterThanCurrentMonth = todayMonthCompare == NSOrderedDescending;
        BOOL recordExistsForIterativeMonth = [self chainTemplateExistsForMonth: iterativeDate];
        
        TJBSchemeSelectionDateComp *dateControlObject = [[TJBSchemeSelectionDateComp alloc] initWithMonthString: monthString
                                                                                                representedDate: iterativeDate
                                                                                                          index: [NSNumber numberWithInt: i]
                                                                                                      isEnabled: YES
                                                                                                      isCircled: recordExistsForIterativeMonth
                                                                                          hasSelectedAppearance: NO
                                                                                                           size: dateControlSize
                                                                                               masterController: self
                                                                                             representsPastDate: !iterativeMonthGreaterThanCurrentMonth];
        
        [self.dateControlObjects addObject: dateControlObject];
        
        [self addChildViewController: dateControlObject];
        
        [stackView addArrangedSubview: dateControlObject.view];
        
        [dateControlObject didMoveToParentViewController: self];
        
    }
    
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



#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{

    NSInteger rowCount = self.tvSortedContent.count;
    
    if (rowCount == 0){
        
        return 1;
        
    } else{
        
        return rowCount;
        
    }
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger chainCount = self.tvSortedContent.count;
    
    if (chainCount == 0){
        
        TJBNoDataCell *cell = [self.activeTableView dequeueReusableCellWithIdentifier: @"TJBNoDataCell"];
        
        cell.mainLabel.text = @"No Routines";
        
        cell.backgroundColor = [UIColor clearColor];
        
        return cell;
        
    } else{
        
        BOOL isSelectedCell = NO;
        
        if (self.lastSelectedIndexPath){
            
            isSelectedCell = self.lastSelectedIndexPath.row == indexPath.row;
            
        }
        
        TJBRealizedChainCell *cell = [self.activeTableView dequeueReusableCellWithIdentifier: @"TJBRealizedChainCell"];
        
        [self layoutCellToEnsureCorrectWidth: cell
                                   indexPath: indexPath];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.layer.borderColor = [[TJBAestheticsController singleton] paleLightBlueColor].CGColor;
        
        [cell clearExistingEntries];
        
        NSInteger adjustedRowIndex = indexPath.row ;
        
        TJBChainTemplate *chainTemplate = self.tvSortedContent[adjustedRowIndex];
        
        BOOL sortByDateLastExecuted = self.sortBySegmentedControl.selectedSegmentIndex == 1;
        
        NSDate *date;
        
        if (sortByDateLastExecuted){
            
            date = [self largestRealizeChainDateForChainTemplate: chainTemplate];
            
        } else{
            
            date = chainTemplate.dateCreated;
            
        }
        
        
        TJBChainTemplateSortingType sortingType = self.sortBySegmentedControl.selectedSegmentIndex == 0 ? TJBChainTemplateByDateCreated : TJBChainTemplateByDateLastExecuted;
        
        [cell configureChainTemplateCellWithChainTemplate: chainTemplate
                                             dateTimeType: TJBDayInYear
                                              titleNumber: @(indexPath.row + 1)
                                              sortingType: sortingType];
        
        // configure border width and background color according to whether or not the cell is selected
        
        if (isSelectedCell){
            
            cell.backgroundColor = [UIColor clearColor];
            cell.layer.borderWidth = 4.0;
            
        } else{
            
            cell.backgroundColor = [UIColor clearColor];
            cell.layer.borderWidth = 0.0;
            
        }
        
        return cell;
        
    }
    

    
}

- (void)layoutCellToEnsureCorrectWidth:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath{
    
    [self.view layoutSubviews];
    
    CGFloat cellHeight = [self tableView: self.activeTableView
                 heightForRowAtIndexPath: indexPath];
    
    CGFloat cellWidth = self.mainContainer.frame.size.width;
    
    
    [cell setFrame: CGRectMake(0, 0, cellWidth, cellHeight)];
    [cell layoutSubviews];
    
}

#pragma mark - <UITableViewDelegate>

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.tvSortedContent.count > 0) {
        
        return YES;
        
    } else{
        
        return NO;
        
    }

    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    //// change the background color of the selected chain template and change the control state of the buttons to activate them.  Store the selected chain and the index path of the selected row
    
    // deal with unhighlighting

    TJBRealizedChainCell *lastSelectedCell = [tableView cellForRowAtIndexPath: self.lastSelectedIndexPath];
    
    lastSelectedCell.backgroundColor = [UIColor clearColor];
    lastSelectedCell.layer.borderWidth = 0.0;
    
    self.lastSelectedIndexPath = indexPath;
    
    // highlight the new cell
    
    TJBChainTemplate *chainTemplate = self.tvSortedContent[indexPath.row];
    self.selectedChainTemplate = chainTemplate;
    
    // add blue border to selected cell
    
    TJBRealizedChainCell *selectedCell = [tableView cellForRowAtIndexPath: indexPath];
    
    selectedCell.backgroundColor = [UIColor clearColor];
    
    selectedCell.layer.borderWidth = 4.0;
    
    // controls state
    
    [self configureToolbarButtonsAccordingToActiveState];
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [self.view layoutSubviews];
    
    NSInteger chainCount = self.tvSortedContent.count;
    
    if (chainCount == 0){
        
        return self.mainContainer.frame.size.height - [self breatherRoomForChainTemplateScrollView];
        
    } else{
        
        TJBChainTemplate *chainTemplate = self.tvSortedContent[indexPath.row];
        
        return [TJBRealizedChainCell suggestedCellHeightForChainTemplate: chainTemplate];
        
    }
    
    
}

#pragma mark - View History


- (IBAction)didPressHistoryButton:(id)sender{
    
    // only attempt to present the VC if a chain template has been selected
    
    if (_viewingChainHistory == NO){
        
        
        [self showActivityIndicator];
        [self giveControlsDisabledConfiguration];
        [self configureTitleLabelsAccordingToRoutineHistory];
        
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, contentLoadingSmoothingDelay * NSEC_PER_SEC),  dispatch_get_main_queue(),  ^{
            
            
            [self clearAllTableViewsAndDirectlyAssociatedObjects];
            [self showChainHistoryForSelectedChain];
            
            [self.activeActivityIndicator stopAnimating];
            [self hideAllBottomControls];
            [self showViewHistoryReturnButton];
            
            _viewingChainHistory = YES;
            
            
        });
        
    }
    
}

- (void)didPressHistoryReturnButton{


    [self showActivityIndicator];
    
    self.routinesByLabel.text = @"My Routines";
    [self updateTitleLabelCorrespondingToActiveTVDate];
    self.numberOfRecordsLabel.text = @"";
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, contentLoadingSmoothingDelay * NSEC_PER_SEC),  dispatch_get_main_queue(),  ^{
        
        [self clearAllTableViewsAndDirectlyAssociatedObjects];
        
        [self addEmbeddedTableViewToViewHierarchy];
        
        [self updateNumberOfRecordsTitleLabel];
        
        // visual state
        
        [self configureSelectionAsNil];
        
        [self giveControlsEnabledConfiguration];
        [self configureToolbarButtonsAccordingToActiveState];
        
        [self.activeActivityIndicator stopAnimating];
        [self unhideAllBottomControls];
        
        [self hideViewHistoryReturnButton];
        [self unhideAllBottomControls];
        [self.activeActivityIndicator stopAnimating];
        
        _viewingChainHistory = NO;
    
        
    });
    

    
}



- (void)showChainHistoryForSelectedChain{
    
    // history table view
    
    TJBCompleteChainHistoryVC *chainHistoryVC = [[TJBCompleteChainHistoryVC alloc] initWithChainTemplate: self.selectedChainTemplate];
    self.chainHistoryVC = chainHistoryVC;
    
    CGFloat breatherRoom = historyReturnButtonBottomSpacing + historyReturnButtonHeight + 8;
    CGFloat contentHeight = [chainHistoryVC contentHeight]; // gets the total height of cells based on provided chain template
    CGFloat svHeight;
    
    if (contentHeight < self.mainContainer.frame.size.height - breatherRoom){
        
        svHeight = self.mainContainer.frame.size.width;

    } else{
        
        svHeight = contentHeight + breatherRoom;
        
    }
    
    // scroll view
    
    UIScrollView *sv = [[UIScrollView alloc] initWithFrame: self.mainContainer.bounds];
    self.chainHistoryScrollView = sv;
    
    CGRect rect = CGRectMake(0, 0, self.mainContainer.frame.size.width, contentHeight);
    chainHistoryVC.view.frame = rect;
    
    CGSize contentSize = CGSizeMake(self.mainContainer.frame.size.width, svHeight);
    sv.contentSize = contentSize;
    sv.bounces = YES;
    
    [sv addSubview: chainHistoryVC.view];
    
    // give the new vc's view the same rect as the current table view
    // must go through the necessary steps to add the chain history vc as a child view controller
    
    [self addChildViewController: chainHistoryVC];
    
    [self.mainContainer insertSubview: sv
                              atIndex: 0];
    
    [chainHistoryVC didMoveToParentViewController: self];
    
}

#pragma mark - View History Helper Methods

- (void)configureTitleLabelsAccordingToRoutineHistory{
    
    self.routinesByLabel.text = @"Routine History";
    self.monthYearTitleLabel.text = @"";
    
    NSNumber *numberOfRoutines = @(self.selectedChainTemplate.realizedChains.count);
    NSString *recordsWord = [numberOfRoutines intValue] == 1 ? @"Record" : @"Records";
    self.numberOfRecordsLabel.text = [NSString stringWithFormat: @"%@ %@",
                                      [numberOfRoutines stringValue],
                                      recordsWord];
    
}

- (void)showViewHistoryReturnButton{
    
    if (!self.viewHistoryReturnButton){
        
        UIButton *vhrButton = [[UIButton alloc] init];
        self.viewHistoryReturnButton = vhrButton;
        
        [self configureViewHistoryReturnButtonAppearanceAndFunctionality];
        
        NSMutableDictionary *constraintMapping = [[NSMutableDictionary alloc] init];
        NSString *vhrButtonKey = @"viewHistoryReturnButton";
        [constraintMapping setObject: vhrButton
                              forKey: vhrButtonKey];
        
        [self.mainContainer insertSubview: vhrButton
                             aboveSubview: self.chainHistoryScrollView];
        
        vhrButton.translatesAutoresizingMaskIntoConstraints = NO;
    
        NSString *horzLayoutVFL = [NSString stringWithFormat: @"H:|-16-[%@]-16-|", vhrButtonKey];
        [self.mainContainer addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: horzLayoutVFL
                                                                                    options: 0
                                                                                    metrics: nil
                                                                                      views: constraintMapping]];
        
        NSString *vertLayoutVFL = [NSString stringWithFormat: @"V:[%@(==%f)]-%f-|",
                                   vhrButtonKey,
                                   historyReturnButtonHeight,
                                   historyReturnButtonBottomSpacing];
        [self.mainContainer addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: vertLayoutVFL
                                                                                    options: 0
                                                                                    metrics: nil
                                                                                      views: constraintMapping]];
        
        [vhrButton addTarget: self
                      action: @selector(didPressHistoryReturnButton)
            forControlEvents: UIControlEventTouchUpInside];
        
        
    }
    
    self.viewHistoryReturnButton.hidden = NO;
    
}

- (void)configureViewHistoryReturnButtonAppearanceAndFunctionality{
    
    self.viewHistoryReturnButton.backgroundColor = [UIColor grayColor];
    [self.viewHistoryReturnButton setTitleColor: [[TJBAestheticsController singleton] paleLightBlueColor]
                                       forState: UIControlStateNormal];
    self.viewHistoryReturnButton.titleLabel.font = [UIFont boldSystemFontOfSize: 20];
    [self.viewHistoryReturnButton setTitle: @"Back to List"
                                  forState: UIControlStateNormal];
    
    CALayer *vhrbLayer = self.viewHistoryReturnButton.layer;
    vhrbLayer.masksToBounds = YES;
    vhrbLayer.cornerRadius = 22;
    vhrbLayer.borderColor = [[TJBAestheticsController singleton] paleLightBlueColor].CGColor;
    vhrbLayer.borderWidth = 1.0;
    
    
}

- (void)hideViewHistoryReturnButton{
    
    self.viewHistoryReturnButton.hidden = YES;
    
}

- (void)clearAllTableViewsAndDirectlyAssociatedObjects{
    
    // chain template tv
    
    if (self.activeTableView){
        
        [self.activeTableView removeFromSuperview];
        self.activeTableView = nil;
        
    }
    
    if (self.activeScrollView){
        
        [self.activeScrollView removeFromSuperview];
        self.activeScrollView = nil;
        
    }
    
    // chain history tv
    
    if (self.chainHistoryScrollView){
        
        [self.chainHistoryScrollView removeFromSuperview];
        self.chainHistoryScrollView = nil;
        
    }
    
    if (self.chainHistoryVC){
        
        // remove the child view controller as dictated in apple's programming guide
        
        [self.chainHistoryVC willMoveToParentViewController: nil];
        
        [self.chainHistoryVC.view removeFromSuperview];
        
        [self.chainHistoryVC removeFromParentViewController];
        
        self.chainHistoryVC = nil;
        
    }
    
}


#pragma mark - Button Actions





- (IBAction)didPressBackButton:(id)sender{
    
    [self dismissViewControllerAnimated: NO
                             completion: nil];
    
}


- (IBAction)didPressLeftArrow:(id)sender{
    
    [self incrementDCACtiveYearWithIncrementDirectionForward: NO];
    
}

- (IBAction)didPressRightArrow:(id)sender{
    
    [self incrementDCACtiveYearWithIncrementDirectionForward: YES];
    
}

#pragma mark - Selections

- (void)configureSelectionAsNil{
    
    // get rid of the border on the last selected cell and change state variables for selection
    
    self.selectedChainTemplate = nil;
    
    if (self.lastSelectedIndexPath){
        
        TJBRealizedChainCell *cell = [self.activeTableView cellForRowAtIndexPath: self.lastSelectedIndexPath];
        cell.layer.borderWidth = 0.0;
        cell.backgroundColor = [UIColor clearColor];
        self.lastSelectedIndexPath = nil;
        
    }
    
}





#pragma mark - Controls Appearance / State

- (void)giveControlsDisabledConfiguration{
    
    self.backButton.enabled = NO;
    self.backButton.layer.opacity = .4;
    
    NSArray *arrows = @[self.leftArrowButton, self.rightArrowButton];
    for (UIButton *b in arrows){
        
        b.enabled = NO;
        b.layer.opacity = .4;
        
    }

    for (TJBSchemeSelectionDateComp *comp in self.dateControlObjects){
        
        [comp configureAsDisabled];
        
    }
    
}

- (void)giveControlsEnabledConfiguration{
    
    self.backButton.enabled = YES;
    self.backButton.layer.opacity = 1.0;
    
    NSArray *arrows = @[self.leftArrowButton, self.rightArrowButton];
    for (UIButton *b in arrows){
        
        b.enabled = YES;
        b.layer.opacity = 1.0;
        
    }
    
    for (TJBSchemeSelectionDateComp *comp in self.dateControlObjects){
        
        [comp configureAsEnabled];
        
    }
    
}

- (void)configureToolbarButtonsAccordingToActiveState{
    
    NSArray *buttons = @[self.launchButton, self.deleteButton];
    
    for (UIBarButtonItem *bbi in buttons){
        
        if (self.lastSelectedIndexPath){
            
            [self giveToolbarButtonEnabledAppearance: bbi];
            
        } else{
            
            [self giveToolbarButtonDisabledAppearance: bbi];
            
        }
        
    }
    
    // must check whether the selected cell has any realized chains before showing the history button
    
    if (self.lastSelectedIndexPath){
        
        BOOL realizationsExist = self.selectedChainTemplate.realizedChains.count > 0;
        
        if (realizationsExist){
            
            [self giveToolbarButtonEnabledAppearance: self.historyButton];
            
        } else{
            
            [self giveToolbarButtonDisabledAppearance: self.historyButton];
            
        }
        
    } else{
        
        [self giveToolbarButtonDisabledAppearance: self.historyButton];
        
    }
    

    
}

- (void)giveToolbarButtonDisabledAppearance:(UIBarButtonItem *)bbi{
    
    bbi.enabled = NO;
    
}


- (void)giveToolbarButtonEnabledAppearance:(UIBarButtonItem *)bbi{
    
    bbi.enabled = YES;
    
}

- (void)hideAllBottomControls{
    
    NSArray *views = @[self.toolbar, self.sortBySegmentedControl, self.sortByBottomLabel, self.arrowControlButton];
    for (UIView *v in views){
        
        v.hidden = YES;
        
    }
    
}

- (void)unhideAllBottomControls{
    
    NSArray *views = @[self.toolbar, self.sortBySegmentedControl, self.sortByBottomLabel, self.arrowControlButton];
    for (UIView *v in views){
        
        v.hidden = NO;
        
    }
    
}

#pragma mark - Toolbar Animation


- (IBAction)didPressArrowControlButton:(id)sender{
    
    if (_toolbarState == TJBToolbarHidden){
        
        [self animateToolbarOnscreen];
      
        [self.arrowControlButton setImage: [UIImage imageNamed: @"downArrowBlue30PDF"]
                                 forState: UIControlStateNormal];
        
        _toolbarState = TJBToolBarNotHidden;
        
    } else if (_toolbarState == TJBToolBarNotHidden){
        
        [self animateToolbarOffscreen];
        
        [self.arrowControlButton setImage: [UIImage imageNamed: @"upArrowBlue30PDF"]
                                 forState: UIControlStateNormal];
        
        _toolbarState = TJBToolbarHidden;
        
    }
    
    
}

- (void)animateToolbarOffscreen{
    

    [UIView animateWithDuration: toolbarSlidingAnimationTime
                     animations: ^{
                         
                         self.arrowControlButton.enabled = NO;
    
                         CGFloat vertAnimationDist = self.mainContainer.frame.size.height - self.toolbar.frame.origin.y;
                         
                         NSArray *viewsToTranslate = @[self.arrowControlButton, self.toolbar, self.sortByBottomLabel, self.sortBySegmentedControl];
                         for (UIView *v in viewsToTranslate){
                             
                             v.frame = [self rectByTranslatingRect: v.frame
                                                           originX: 0
                                                           originY: vertAnimationDist];
                             
                         }
                        
                         
                     }
                     completion: ^(BOOL finished){
                         
                         self.arrowControlButton.enabled = YES;
    
                         CGFloat controlsHeight = self.sortBySegmentedControl.frame.origin.y + self.sortBySegmentedControl.frame.size.height - self.toolbar.frame.origin.y;
                         self.segmentedControlBottomSpaceConstr.constant = -1 * controlsHeight;
                         
                         self.activeScrollView.contentSize = [self scrollViewContentSize];
    
                     }];
    
}


- (void)animateToolbarOnscreen{
    
    [UIView animateWithDuration: toolbarSlidingAnimationTime
                     animations: ^{
                         
                         self.arrowControlButton.enabled = NO;
                         
                         CGFloat vertAnimationDist = -1 * self.segmentedControlBottomSpaceConstr.constant + 8;
                         
                         NSArray *viewsToTranslate = @[self.arrowControlButton, self.toolbar, self.sortByBottomLabel, self.sortBySegmentedControl];
                         for (UIView *v in viewsToTranslate){
                             
                             v.frame = [self rectByTranslatingRect: v.frame
                                                           originX: 0
                                                           originY: -1 * vertAnimationDist];
                             
                         }
                         
                         self.sortByBottomLabel.hidden = NO;
                         
                     }
                     completion: ^(BOOL finished){
                         
                         self.arrowControlButton.enabled = YES;
                         
                         self.segmentedControlBottomSpaceConstr.constant = 8;
                         
                         self.activeScrollView.contentSize = [self scrollViewContentSize];
                         
                     }];
    

    
    
}


- (CGRect)rectByTranslatingRect:(CGRect)initialRect originX:(CGFloat)originX originY:(CGFloat)originY{
    
    return CGRectMake(initialRect.origin.x + originX, initialRect.origin.y + originY, initialRect.size.width, initialRect.size.height);
    
}


#pragma mark - Toolbar Actions





- (IBAction)didPressLaunchButton:(id)sender {
        
    if (self.selectedChainTemplate){
        
        TJBActiveGuidanceTBC *activeGuidanceTBC = [[TJBActiveGuidanceTBC alloc] initWithChainTemplate: self.selectedChainTemplate];
        
        [self presentViewController: activeGuidanceTBC
                           animated: YES
                         completion: nil];
        
    } else{
        
        NSLog(@"no chain template selected");
        
    }
    
}



- (IBAction)didPressNewRoutine:(id)sender{
    
    __weak NewOrExistinigCircuitVC *weakSelf = self;
    
    TJBVoidCallback callback = ^{
        
        weakSelf.sortBySegmentedControl.selectedSegmentIndex = 0;
        
        _fetchedObjectsNeedUpdating = YES;
        _displayedContentNeedsUpdating = YES;
        
        [weakSelf dismissViewControllerAnimated: YES
                                     completion: nil];
        
    };
    
    TJBCircuitTemplateContainerVC *ctcVC = [[TJBCircuitTemplateContainerVC alloc] initWithCallback: callback];
    
    [self presentViewController: ctcVC
                       animated: YES
                     completion: nil];
    
}


#pragma mark - Delete Actions

- (IBAction)didPressDeleteButton:(id)sender{
    
    // alert controller
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"Proceed with Delete?"
                                                                   message: @"This action is permanent. Submissions cannot be ressurected following deletion"
                                                            preferredStyle: UIAlertControllerStyleAlert];
    
    __weak NewOrExistinigCircuitVC *weakSelf = self;
    
    // confirm action
    
    void (^confirmAction)(UIAlertAction *) = ^(UIAlertAction *action){
        
        [weakSelf deleteCurrentlySelectedCell];
        
    };
    
    UIAlertAction *confirm = [UIAlertAction actionWithTitle: @"Delete"
                                                      style: UIAlertActionStyleDestructive
                                                    handler: confirmAction];
    
    // cancel action
    
    void (^cancelAction)(UIAlertAction *) = ^(UIAlertAction *action){
        
        return;
        
    };
    
    UIAlertAction *cancel = [UIAlertAction actionWithTitle: @"Cancel"
                                                     style: UIAlertActionStyleCancel
                                                   handler: cancelAction];
    
    [alert addAction: cancel];
    [alert addAction: confirm];
    
    [self presentViewController: alert
                       animated: YES
                     completion: nil];
    
    
    
    
}

- (void)deleteCurrentlySelectedCell{
    
    // table view animation
    
    [self.activeTableView beginUpdates];
    
    [self.activeTableView deleteRowsAtIndexPaths: @[self.lastSelectedIndexPath]
                          withRowAnimation: UITableViewRowAnimationLeft];
    
    [self.tvSortedContent removeObject: self.selectedChainTemplate];
    [self.dcSortedContent removeObject: self.selectedChainTemplate];
    [[CoreDataController singleton] deleteChainTemplate: self.selectedChainTemplate];
    
    if (self.tvSortedContent.count == 0){
        
        [self.activeTableView insertRowsAtIndexPaths: @[self.lastSelectedIndexPath]
                                    withRowAnimation: UITableViewRowAnimationRight];
        
        [self.dateControlObjects[[self.selectedDateObjectIndex intValue]] deleteCircle];
        
    }
    
    self.selectedChainTemplate = nil;
    
    [self.activeTableView endUpdates];
    
    // content update
    
    [self showActivityIndicator];
    [self giveControlsDisabledConfiguration];
    
    self.routinesByLabel.text = @"My Routines";
    self.numberOfRecordsLabel.text = @"";
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, contentLoadingSmoothingDelay * NSEC_PER_SEC),  dispatch_get_main_queue(),  ^{
        
        [self clearAllTableViewsAndDirectlyAssociatedObjects];
        
        [self addEmbeddedTableViewToViewHierarchy];
        
        [self updateNumberOfRecordsTitleLabel];
        
        // visual state
        
        [self configureSelectionAsNil];
        
        [self giveControlsEnabledConfiguration];
        [self configureToolbarButtonsAccordingToActiveState];
        
        [self.activeActivityIndicator stopAnimating];
        [self unhideAllBottomControls];
        
    });
    
    
}





#pragma mark - Segmented Control 

- (void)segmentedControlValueDidChange{
    
    [self showActivityIndicator];
    self.numberOfRecordsLabel.text = @"";
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, contentLoadingSmoothingDelay * NSEC_PER_SEC),  dispatch_get_main_queue(),  ^{
        
        // derive all model objects anew
        
        self.dcSortedContent = [self allChainTemplatesFetchedAndSortedAccordingToSortingState];
        self.tvSortedContent = [self chainTemplatesForTVActiveDate];
        
        // create the date controls
        
        [self configureDateControlsBasedOnDCActiveDate];
        
        // configure the correct selection appearance for the date controls
        
        int selectedDateControlIndex = [self dateControlObjectIndexForDate: self.tvActiveDate];
        
        if (self.selectedDateObjectIndex){
            
            [self.dateControlObjects[[self.selectedDateObjectIndex intValue]] configureAsNotSelected];
            
        }
        
        [self.dateControlObjects[selectedDateControlIndex] configureAsSelected];
        self.selectedDateObjectIndex = @(selectedDateControlIndex);
        
        // content generation
        
        [self clearAllTableViewsAndDirectlyAssociatedObjects];
        
        [self addEmbeddedTableViewToViewHierarchy];
        
        [self updateAllTitleLabelsForNewContent];
        
        // visual state
        
        [self giveControlsEnabledConfiguration];
        [self configureToolbarButtonsAccordingToActiveState];
        
        [self.activeActivityIndicator stopAnimating];
        
        
        
        
    });
    
    
}



@end






























