//
//  TJBExerciseSelectionScene.m
//  Beast
//
//  Created by Trevor Beasty on 12/19/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import "TJBExerciseSelectionScene.h"



#import "CoreDataController.h" // core data
#import "TJBNoDataCell.h" // table view cell - no data
#import "TJBExerciseSelectionCell.h"  // table view cell - no data
#import "TJBAestheticsController.h" // aesthetics
#import "TJBAssortedUtilities.h" // utilities

@interface TJBExerciseSelectionScene () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

{
    
    BOOL _searchIsActive; // state
    
}



//@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController; // core
@property (nonatomic, strong) NSMutableArray *contentExercisesArray; // core - managed objects supplied to table view as data source
@property (strong) NSIndexPath *selectedCellIndexPath; // state - table view selection
@property (copy) NSString *exerciseSearchString;


// callback

@property (copy) void(^callbackBlock)(TJBExercise *);

// IBOutlet

@property (weak, nonatomic) IBOutlet UITableView *exerciseTableView;
@property (weak, nonatomic) IBOutlet UIButton *leftBarButton;
@property (weak, nonatomic) IBOutlet UILabel *mainTitleLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *normalBrowsingExerciseSC;
@property (weak, nonatomic) IBOutlet UIToolbar *actionsToolbar;
@property (weak, nonatomic) IBOutlet UIView *columnTitleLabelsContainer;
@property (weak, nonatomic) IBOutlet UILabel *exerciseColumnLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLastExecutedColumbLabel;
@property (weak, nonatomic) IBOutlet UIView *titleBarContainier;

// constraints

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *exerciseSegmentedControlBottomSpaceConstr;

// toolbar buttons

@property (weak, nonatomic) IBOutlet UIBarButtonItem *launchToolbarButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *searchToolbarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addNewToolbarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;

// programmatically created views

@property (strong) UIBarButtonItem *listToolbarButton;


@property (strong) UIView *exerciseSearchFieldContainer; // programmatically created view with embedded text field; used as search bar


// IBAction

- (IBAction)didPressLeftBarButton:(id)sender;
- (IBAction)didPressLaunch:(id)sender;
- (IBAction)didPressSearch:(id)sender;
- (IBAction)didPressAddNewButton:(id)sender;
- (IBAction)didPressDeleteButton:(id)sender;
- (IBAction)didPressEditButton:(id)sender;




@end



#pragma mark - Constants



static NSString * const cellReuseIdentifier = @"basicCell";


static NSTimeInterval const toolbarToBottomPositionAnimationTime = .15;


// search bar

static CGFloat const searchBarHorizontalInset = 8;
static CGFloat const searchBarVerticalInset = 4;

// bottom controls layour

static CGFloat categorySearchStateSCBottomSpacing = 8;

@implementation TJBExerciseSelectionScene

#pragma mark - Instantiation

- (instancetype)initWithCallbackBlock:(void (^)(TJBExercise *))block{
    
    self = [super init];
    
    self.callbackBlock = block;

    _searchIsActive = NO;
    
    return self;
    
}

#pragma mark - View Life Cycle




- (void)viewDidLoad{
    
    [self.view layoutSubviews];
    
    [self updateToolbarAppearanceAccordingToSelectionState]; // no cell is selected upon instantiation, so certain toolbar buttons are disabled
    
    [self configureTableView];
    
    [self createSearchBar];
    self.exerciseSearchFieldContainer.hidden = YES;
    
    [self deriveExerciseContentGivenState];
    
    [self viewAesthetics];
    
    [self registerForCoreDataNotifications];
    
    [self configureNormalBrowsingExerciseSC];
    
}


#pragma mark - View Helper Methods

- (void)configureNormalBrowsingExerciseSC{
    
    [self.normalBrowsingExerciseSC addTarget: self
                                      action: @selector(browsingSCValueDidChange)
                            forControlEvents: UIControlEventValueChanged];
    
}







- (void)viewAesthetics{

    // meta view
    
    self.view.backgroundColor = [UIColor blackColor];
    
    // table view
    
    self.exerciseTableView.backgroundColor = [UIColor clearColor];
    
    // browsing segmented control
    
    self.normalBrowsingExerciseSC.tintColor = [[TJBAestheticsController singleton] paleLightBlueColor];
    self.normalBrowsingExerciseSC.backgroundColor = [UIColor grayColor];
    
    UIFont *font = [UIFont boldSystemFontOfSize: 15];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject: font
                                                           forKey: NSFontAttributeName];
    [self.normalBrowsingExerciseSC setTitleTextAttributes: attributes
                                                 forState: UIControlStateNormal];
    
    CALayer *scLayer = self.normalBrowsingExerciseSC.layer;
    scLayer.masksToBounds = YES;
    scLayer.cornerRadius = 25;
    scLayer.borderWidth = 1.0;
    scLayer.borderColor = [[TJBAestheticsController singleton] paleLightBlueColor].CGColor;
    
    // title bar
    
    self.titleBarContainier.backgroundColor = [UIColor darkGrayColor];

    
    self.mainTitleLabel.font = [UIFont boldSystemFontOfSize: 20];
    self.mainTitleLabel.textColor = [UIColor whiteColor];
    self.mainTitleLabel.backgroundColor = [UIColor clearColor];
    
    self.leftBarButton.backgroundColor = [UIColor clearColor];
    
    // table view
    
    self.exerciseTableView.backgroundColor = [[TJBAestheticsController singleton] yellowNotebookColor];
    

    
    // actions toolbar
    
    self.actionsToolbar.barTintColor = [UIColor grayColor];
    self.actionsToolbar.tintColor = [[TJBAestheticsController singleton] paleLightBlueColor];
    CALayer *tbLayer = self.actionsToolbar.layer;
    tbLayer.cornerRadius = self.actionsToolbar.frame.size.height / 2.0;
    tbLayer.masksToBounds = YES;
    tbLayer.borderColor = [[TJBAestheticsController singleton] paleLightBlueColor].CGColor;
    tbLayer.borderWidth = 1.0;
    
    // column labels area
    
    self.columnTitleLabelsContainer.backgroundColor = [[TJBAestheticsController singleton] yellowNotebookColor];
    NSArray *columnHeaderLabels = @[self.exerciseColumnLabel, self.dateLastExecutedColumbLabel];
    for (UILabel *label in columnHeaderLabels){
        
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize: 15];
        label.textColor = [UIColor blackColor];
        
    }
    
    // detailed line
    
    [self drawDetailedLines];
    
}

- (void)drawDetailedLines{
    
    [self.view layoutSubviews];
    [self.titleBarContainier layoutSubviews];
    
    [TJBAssortedUtilities drawVerticalDividerToRightOfLabel: self.exerciseColumnLabel
                                           horizontalOffset: 0
                                                  thickness: 2
                                             verticalOffset: self.exerciseColumnLabel.frame.size.height / 3.0
                                                   metaView: self.columnTitleLabelsContainer];
    
}

- (void)configureTableView{
    
    self.exerciseTableView.bounces = YES;
    
    self.mainTitleLabel.backgroundColor = [UIColor darkGrayColor];
    self.mainTitleLabel.font = [UIFont boldSystemFontOfSize: 20.0];
    self.mainTitleLabel.textColor = [UIColor whiteColor];
    
    // register cells
    
    UINib *noDataCell = [UINib nibWithNibName: @"TJBNoDataCell"
                                       bundle: nil];
    
    [self.exerciseTableView registerNib: noDataCell
                 forCellReuseIdentifier: @"TJBNoDataCell"];
    
    UINib *exerciseSelectionCell = [UINib nibWithNibName: @"TJBExerciseSelectionCell"
                                                  bundle: nil];
    
    [self.exerciseTableView registerNib: exerciseSelectionCell
                 forCellReuseIdentifier: @"TJBExerciseSelectionCell"];
}


#pragma mark - Exercise Browsing Segmented Control

- (TJBExerciseCategoryType)categoryForSCIndex:(NSNumber *)scIndex{
    
    NSInteger reference = [scIndex integerValue];
    TJBExerciseCategoryType categoryEnum;
    
    switch (reference) {
        case 0:
            categoryEnum = PushType;
            break;
            
        case 1:
            categoryEnum = PullType;
            break;
            
        case 2:
            categoryEnum = LegsType;
            break;
            
        case 3:
            categoryEnum = OtherType;
            break;
            
        default:
            break;
    }
    
    return categoryEnum;
    
}

- (NSString *)exerciseCategoryNameForSelectedExerciseCategorySegmentedControlIndex{
    
    TJBExerciseCategoryType categoryType = [self categoryForSCIndex: @(self.normalBrowsingExerciseSC.selectedSegmentIndex)];
    
    TJBExerciseCategory *ecManagedObject = [[CoreDataController singleton] exerciseCategory: categoryType];
    
    return  ecManagedObject.name;
    
}



- (void)browsingSCValueDidChange{
    
//    TJBExerciseCategoryType catType = [self categoryForSCIndex: @(self.normalBrowsingExerciseSC.selectedSegmentIndex)];
//    NSString *filterString = [[CoreDataController singleton] categoryStingFromEnum: catType];
//    
//    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
//    
//    NSPredicate *categoryFilter = [NSPredicate predicateWithFormat: @"category.name == %@",
//                                   filterString];
//    
//    returnArray = [self.fetchedResultsController.fetchedObjects mutableCopy];
//    
//    [returnArray filterUsingPredicate: categoryFilter];
//    
//    self.contentExercisesArray = returnArray;
//    
//    [self.exerciseTableView reloadData];
    
    [self deriveExerciseContentGivenState]; // content is fetched according to state
    [self.exerciseTableView reloadData];
    
    [self deselectCellIfSelectionExists]; // deselect the existing selection, if one exists
    
    
    
}





#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSInteger contentCellCount = self.contentExercisesArray.count;
    
    if (contentCellCount == 0){
        
        return 1;
        
    } else{
        
        return contentCellCount;
        
    }
 
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger contentCellCount = self.contentExercisesArray.count;

    if (contentCellCount == 0){
        
        TJBNoDataCell *cell = [self.exerciseTableView dequeueReusableCellWithIdentifier: @"TJBNoDataCell"];
        
        cell.mainLabel.text = @"No Exercises";
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        
        return cell;
        
    } else{
        
        TJBExerciseSelectionCell *cell = [self.exerciseTableView dequeueReusableCellWithIdentifier: @"TJBExerciseSelectionCell"];
        
        TJBExercise *exercise = self.contentExercisesArray[indexPath.row];
        NSDate *dateLastExecuted = [self dateLastExecutedForExercise: exercise];
        
        [cell configureCellWithExerciseName: exercise.name
                                       date: dateLastExecuted];
        
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
        
    }

}

- (NSDate *)dateLastExecutedForExercise:(TJBExercise *)exercise{
    
    // returns the date last executed for a given exercise
    // must find the greatest date for realized sets and realized chains separately, then return the larger one
    
    // realized set
    
    NSDate *realizedSetDate = nil;
    NSInteger realizedSetCount = exercise.realizedSets.count;
    
    if (realizedSetCount > 0){
        
        NSOrderedSet *realizedSets = exercise.realizedSets;
        realizedSetDate = [[realizedSets lastObject] submissionTime];
        
    }
    
    if (!realizedSetDate){
        
        return nil;
        
    } else{
        
        return realizedSetDate;
        
    }
    
}

#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if (self.contentExercisesArray.count > 0){ // only selects the cell if there is any content to begin with
        
        // first deal with the previously selected cell
        
        if (self.selectedCellIndexPath){
            
            UITableViewCell *previouslySelectedCell = [self.exerciseTableView cellForRowAtIndexPath: self.selectedCellIndexPath];
            [self giveCellUnselectedAppearance: previouslySelectedCell];
            
        }
        
        // then deal with the newly selected cell
        
        UITableViewCell *newlySelectedCell = [self.exerciseTableView cellForRowAtIndexPath: indexPath];
        [self giveCellSelectedAppearance: newlySelectedCell];
        
        self.selectedCellIndexPath = indexPath;
        
    }
    
    [self updateToolbarAppearanceAccordingToSelectionState];

 
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if (self.contentExercisesArray.count > 0){
        
        return YES;
        
    } else{
        
        return NO;
        
    }
        

    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger contentCount = self.contentExercisesArray.count;
    
    if (contentCount == 0){
        
        return  self.exerciseTableView.frame.size.height;
        
    } else{
        
        return  80;
        
    }
    

    
}

#pragma mark - Cell Selection



- (void)giveCellSelectedAppearance:(UITableViewCell *)cell{
    
    cell.layer.borderWidth = 4.0;
    cell.layer.borderColor = [[TJBAestheticsController singleton] paleLightBlueColor].CGColor;
    
}


- (void)giveCellUnselectedAppearance:(UITableViewCell *)cell{
    
    cell.layer.borderWidth = 0.0;
    
}

- (void)deselectCellIfSelectionExists{
    
    if (self.selectedCellIndexPath){
        
        [self giveCellUnselectedAppearance: [self.exerciseTableView cellForRowAtIndexPath: self.selectedCellIndexPath]];
        self.selectedCellIndexPath = nil;
        
    }
    
}


- (void)updateToolbarAppearanceAccordingToSelectionState{
    
    NSArray *dynamicAppearanceItems = @[self.launchToolbarButton,
                                        self.deleteButton,
                                        self.editButton];
    
    for (UIBarButtonItem *bbi in dynamicAppearanceItems){
        
        if (self.selectedCellIndexPath){
            
            bbi.enabled = YES;
            
        } else{
            
            bbi.enabled = NO;
            
        }
        
    }
    
}


#pragma mark - Button Actions

- (IBAction)didPressLeftBarButton:(id)sender{
    
    
    [self dismissViewControllerAnimated: YES
                             completion: nil];
    
}



#pragma mark - Exercise Addition and Related Methods





- (TJBExercise *)processUserRequestAndReturnExerciseWithName:(NSString *)exerciseName category:(TJBExerciseCategoryType)category{
    
    //// action is dependent upon several factors.  Depends on whether user it trying to create an existing exercise, has left the exercise text field blank, or has entered a valid new exercise name
    
    // conditional actions
    
    NSString *exerciseString = exerciseName;
    
    UIAlertAction *continueAction = [UIAlertAction actionWithTitle: @"Continue"
                                                             style: UIAlertActionStyleDefault
                                                           handler: nil];
    
    BOOL exerciseExists = [[CoreDataController singleton] exerciseExistsForName: exerciseName];
    
    if (exerciseExists){
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"Invalid Entry"
                                                                       message: @"This exercise already exists"
                                                                preferredStyle: UIAlertControllerStyleAlert];
        
        [alert addAction: continueAction];
        
        [self presentViewController: alert
                           animated: YES
                         completion: nil];
        
        return nil;
        
    } else if([exerciseString isEqualToString: @""]){
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"Invalid Entry"
                                                                       message: @"Exercise entry is blank"
                                                                preferredStyle: UIAlertControllerStyleAlert];
        
        [alert addAction: continueAction];
        
        [self presentViewController: alert
                           animated: YES
                         completion: nil];
        
        return nil;
        
    } else{
        
        TJBExercise *newExercise = [self addAndReturnNewExerciseWithName: exerciseName
                                                                category: category];
        
        return newExercise;
        
    }
    
}

- (TJBExercise *)addAndReturnNewExerciseWithName:(NSString *)name category:(TJBExerciseCategoryType)category{
    
    //// add the new exercise leverage CoreDataController methods.  Save the context when done
    
    CoreDataController *coreDataController = [CoreDataController singleton];
    
    NSString *newExerciseName = name;
    
    NSNumber *wasNewlyCreated = nil;
    TJBExercise *newExercise = [coreDataController exerciseForName: newExerciseName
                                                   wasNewlyCreated: &wasNewlyCreated
                                       createAsPlaceholderExercise: [NSNumber numberWithBool: NO]];
    
    newExercise.category = [[CoreDataController singleton] exerciseCategory: category];
    
    [[CoreDataController singleton] saveContext];
    
    // need to use notification center so all affected fetched results controllers can perform fetch and update table views
    
    [[NSNotificationCenter defaultCenter] postNotificationName: ExerciseDataChanged
                                                        object: nil];
    
    return newExercise;
    
}

#pragma mark - Search / List Functionality


- (IBAction)didPressSearch:(id)sender{
    
    // this button toggles between a list and search appearance, so must check state
    // this method is called by both the seach and list toolbar buttons
    
    [self deselectCellIfSelectionExists]; // deselect current selection if exists
    [self updateToolbarAppearanceAccordingToSelectionState];
    
    if (_searchIsActive == NO){
        
        [self animateToSearchBarState];

    } else if (_searchIsActive == YES){
        
        [self animateToCategoryBasedBrowseState];
        
    }
    
    
}

- (void)updateToolbarBarButtonItemsAccordingGivenState{
    
    if (_searchIsActive == YES){
        
        if (!self.listToolbarButton){
            
            UIBarButtonItem *listBBI = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed: @"listBlue32"]
                                                                        style: UIBarButtonItemStylePlain
                                                                       target: self
                                                                       action: @selector(didPressSearch:)];
            self.listToolbarButton = listBBI;
            
        }
        
        NSMutableArray *toolbarItems = [[self.actionsToolbar items] mutableCopy];
        
        NSUInteger currentSearchButtonIndex = [toolbarItems indexOfObject: self.searchToolbarButton];
        [toolbarItems replaceObjectAtIndex: currentSearchButtonIndex
                                withObject: self.listToolbarButton];
        
        [self.actionsToolbar setItems: toolbarItems];
        
        
    } else{
        
        
        
        NSMutableArray *toolbarItems = [[self.actionsToolbar items] mutableCopy];
        
        NSUInteger currentListButtonIndex = [toolbarItems indexOfObject: self.listToolbarButton];
        [toolbarItems replaceObjectAtIndex: currentListButtonIndex
                                withObject: self.searchToolbarButton];
        
        [self.actionsToolbar setItems: toolbarItems];
        
        
        
        
        
        
    }
    
}

- (void)createSearchBar{
    
    [self.view layoutSubviews];
    
    UIView *searchContainer = [[UIView alloc] initWithFrame: self.columnTitleLabelsContainer.frame];
    self.exerciseSearchFieldContainer = searchContainer;
    [self.view addSubview: searchContainer];
    
    searchContainer.backgroundColor = [[TJBAestheticsController singleton] yellowNotebookColor];
    
    UITextField *searchBar = [[UITextField alloc] init];
    
    // search bar aesthetics
    
    searchBar.backgroundColor = [UIColor clearColor];
    searchBar.textAlignment = NSTextAlignmentCenter;
    searchBar.font = [UIFont systemFontOfSize: 15];
    
    CALayer *searchBarLayer = searchBar.layer;
    searchBarLayer.masksToBounds = YES;
    searchBarLayer.cornerRadius = 8.0;
    searchBarLayer.borderWidth = 1.0;
    searchBarLayer.borderColor = [UIColor blackColor].CGColor;
    
    
    
    
    // search bar layout
    
    NSString *searchBarKey = @"searchBar";
    
    NSDictionary *constraintMapping = [NSDictionary dictionaryWithObject: searchBar
                                                                  forKey: searchBarKey];
    
    [searchContainer addSubview: searchBar];
    searchBar.translatesAutoresizingMaskIntoConstraints = NO;
    
    
    NSString *horzConstrVFL = [NSString stringWithFormat: @"H:|-%f-[%@]-%f-|",
                               searchBarHorizontalInset,
                               searchBarKey,
                               searchBarHorizontalInset];
    [searchContainer addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: horzConstrVFL
                                                                             options: 0
                                                                             metrics: nil
                                                                               views: constraintMapping]];
    
    NSString *vertConstrVFL = [NSString stringWithFormat: @"V:|-%f-[%@]-%f-|",
                               searchBarVerticalInset,
                               searchBarKey,
                               searchBarVerticalInset];
    [searchContainer addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: vertConstrVFL
                                                                             options: 0
                                                                             metrics: nil
                                                                               views: constraintMapping]];
    
    // notification
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(searchTextFieldValueDidChange:)
                                                 name: UITextFieldTextDidChangeNotification
                                               object: searchBar];
    
    
    // delegate
    
    searchBar.delegate = self;
    

    

    
}

- (void)searchTextFieldValueDidChange:(NSNotification *)notification{
    
    UITextField *tf = notification.object;
    self.exerciseSearchString = tf.text;
    
    [self deriveExerciseContentGivenState];
    [self.exerciseTableView reloadData];
    
}






#pragma mark - State Control






#pragma mark - Core Data

- (NSFetchRequest *)fetchRequestGivenState{
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName: @"Exercise"];
    
    NSSortDescriptor *nameSort = [NSSortDescriptor sortDescriptorWithKey: @"name"
                                                               ascending: YES];
    [request setSortDescriptors: @[nameSort]];
    
    if (_searchIsActive == NO){
        
        // only apply the compount predicate if the exercise search text field has a non blank entry
        
        NSString *selectedCategoryName = [self exerciseCategoryNameForSelectedExerciseCategorySegmentedControlIndex];
        
        NSPredicate *exercisesForCategory = [NSPredicate predicateWithFormat: @"category.name = %@",
                                             selectedCategoryName];
        
        request.predicate = exercisesForCategory;
        
    } else if (_searchIsActive == YES){
        
        NSString *placeholderNameRoot = [[CoreDataController singleton] categoryStingFromEnum: PlaceholderType];
        NSPredicate *noPlaceholderExercises = [NSPredicate predicateWithFormat: @"category.name != %@",
                                               placeholderNameRoot];
        
        if (self.exerciseSearchString){
            
            NSPredicate *nameContainsString = [NSPredicate predicateWithFormat: @"name CONTAINS[cd] %@", self.exerciseSearchString];
            
            NSCompoundPredicate *compPred = [NSCompoundPredicate andPredicateWithSubpredicates: @[noPlaceholderExercises, nameContainsString]];
            request.predicate = compPred;
            
        } else{
            
            request.predicate = noPlaceholderExercises;
            
        }
        
    }
    
    return request;
    
}

- (void)deriveExerciseContentGivenState{
    
    NSError *error;
    NSArray *fetchedObjects = [[[CoreDataController singleton] moc] executeFetchRequest: [self fetchRequestGivenState]
                                                                                       error: &error];
    self.contentExercisesArray = [fetchedObjects mutableCopy];
    
    
}


- (void)registerForCoreDataNotifications{
    
        //// configure managed context notification for updating
    
        NSManagedObjectContext *moc = [[CoreDataController singleton] moc];
    
        [[NSNotificationCenter defaultCenter] addObserver: self
                                                 selector: @selector(reloadContent)
                                                     name: NSManagedObjectContextDidSaveNotification
                                                   object: moc];
    
}

- (void)reloadContent{
    
    [self deriveExerciseContentGivenState];
    [self.exerciseTableView reloadData];
    
    [self deselectCellIfSelectionExists];
    
}


#pragma mark - Toolbar Actions



- (IBAction)didPressLaunch:(id)sender{
    
    // if a cell is selected, return the exercise for that cell
    
    if (self.selectedCellIndexPath){
        
        TJBExercise *exercise = self.contentExercisesArray[self.selectedCellIndexPath.row];
        self.callbackBlock(exercise);
        
    } else{
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"No Exercise Selected"
                                                                       message: nil
                                                                preferredStyle: UIAlertControllerStyleAlert];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle: @"Continue"
                                                         style: UIAlertActionStyleDefault
                                                       handler: nil];
        
        [alert addAction: action];
        
        [self presentViewController: alert
                           animated: YES
                         completion: nil];
        
    }
    
}


- (IBAction)didPressAddNewButton:(id)sender{
}





- (IBAction)didPressDeleteButton:(id)sender{
    
    
    
    
    
    
    
    
}







- (IBAction)didPressEditButton:(id)sender{
}









#pragma mark - Bottom Controls Animations

- (void)animateToSearchBarState{
    
    // bottom controls
    
    CGFloat verticalTranslation = self.normalBrowsingExerciseSC.frame.origin.y - self.actionsToolbar.frame.origin.y;

    // search bar
    
    CGRect searchContainerStartingFrame = [TJBAssortedUtilities rectByTranslatingRect: self.columnTitleLabelsContainer.frame
                                                                              originX: self.columnTitleLabelsContainer.frame.size.width
                                                                              originY: 0];
    self.exerciseSearchFieldContainer.frame = searchContainerStartingFrame;
    
    self.exerciseSearchFieldContainer.hidden = NO;
    
    [UIView animateWithDuration: toolbarToBottomPositionAnimationTime
                          delay: 0
                        options: UIViewAnimationOptionCurveLinear
                     animations: ^{
                         
                         // bottom controls
                         
                         NSArray *verticallySlidingViews = @[self.actionsToolbar, self.normalBrowsingExerciseSC];
                         for (UIView *view in verticallySlidingViews){
                             
                             view.frame = [TJBAssortedUtilities rectByTranslatingRect: view.frame
                                                                              originX: 0
                                                                              originY: verticalTranslation];
                             
                         }
                         
                         // search bar
                         
                         self.exerciseSearchFieldContainer.frame = self.columnTitleLabelsContainer.frame;
                         
                     }
                     completion: ^(BOOL finished){
                         
                         CGFloat bottomSpaceConstr = self.exerciseSegmentedControlBottomSpaceConstr.constant;
                         bottomSpaceConstr -= verticalTranslation;
                         
                         self.exerciseSegmentedControlBottomSpaceConstr.constant = bottomSpaceConstr;
                         
                         _searchIsActive = YES;
                         
                         [self deriveExerciseContentGivenState];
                         [self.exerciseTableView reloadData];
                         
                         [self updateToolbarBarButtonItemsAccordingGivenState];
                         
  
                         
                     }];

}

- (void)animateToCategoryBasedBrowseState{
    
    // bottom controls
    
    CGFloat verticalTranslation = self.normalBrowsingExerciseSC.frame.origin.y - self.actionsToolbar.frame.origin.y;
    
    [UIView animateWithDuration: toolbarToBottomPositionAnimationTime
                          delay: 0
                        options: UIViewAnimationOptionCurveLinear
                     animations: ^{
                         
                         // bottom controls
                         
                         NSArray *verticallySlidingViews = @[self.actionsToolbar, self.normalBrowsingExerciseSC];
                         for (UIView *view in verticallySlidingViews){
                             
                             view.frame = [TJBAssortedUtilities rectByTranslatingRect: view.frame
                                                                              originX: 0
                                                                              originY: -1 * verticalTranslation];
                             
                         }
                         
                         // search bar
                         
                         self.exerciseSearchFieldContainer.frame = [TJBAssortedUtilities rectByTranslatingRect: self.exerciseSearchFieldContainer.frame
                                                                                                       originX: self.exerciseSearchFieldContainer.frame.size.width
                                                                                                       originY: 0];
                         
                     }
                     completion: ^(BOOL finished){
                         
                         self.exerciseSegmentedControlBottomSpaceConstr.constant = categorySearchStateSCBottomSpacing;
                         
                         self.exerciseSearchFieldContainer.hidden = YES;
                         
                         _searchIsActive = NO;
                         
                         [self deriveExerciseContentGivenState];
                         [self.exerciseTableView reloadData];
                         
                         [self updateToolbarBarButtonItemsAccordingGivenState];
                         
                         
                         
                     }];
    
}


#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    
    return YES;
    
}


@end




























