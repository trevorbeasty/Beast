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
#import "ExerciseAdditionChildVC.h" // exercise addition

@interface TJBExerciseSelectionScene () <UITableViewDelegate, UITableViewDataSource, UISearchBarDelegate>

{
    
    BOOL _searchIsActive; // state
    
}



@property (nonatomic, strong) NSMutableArray<TJBExercise *> *contentExercisesArray; // core - managed objects supplied to table view as data source
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
@property (weak, nonatomic) IBOutlet UIView *metaTitleAreaContainer;

// constraints

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *exerciseSegmentedControlBottomSpaceConstr;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *columnsContainerHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *headerAreaContainerHeight;

// toolbar buttons

@property (weak, nonatomic) IBOutlet UIBarButtonItem *launchToolbarButton;
@property (strong, nonatomic) IBOutlet UIBarButtonItem *searchToolbarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *addNewToolbarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *deleteButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *editButton;

// programmatically created views

@property (strong) UIBarButtonItem *listToolbarButton;
@property (strong) UIVisualEffectView *exerciseAdditionVEV;


@property (strong) UISearchBar *searchBar; // programmatically created search bar


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

// animation

static CGFloat const searchBarHeightDelta = 30;




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
    
    [self updateToolbarAppearanceAccordingToSelectionState]; // no cell is selected upon instantiation, so certain toolbar buttons are disabled
    
    [self configureTableView];
    
    [self deriveExerciseContentGivenState];
    
    [self viewAesthetics];
    
    [self registerForCoreDataNotifications];
    
    [self configureNormalBrowsingExerciseSC];
    
    [self configureStartingDisplayValues];
    
}


#pragma mark - View Helper Methods

- (void)configureNormalBrowsingExerciseSC{
    
    [self.normalBrowsingExerciseSC addTarget: self
                                      action: @selector(browsingSCValueDidChange)
                            forControlEvents: UIControlEventValueChanged];
    
}



- (void)configureStartingDisplayValues{
    
    self.dateLastExecutedColumbLabel.text = @"date last\nexecuted";
    
}



- (void)viewAesthetics{

    // meta view
    
    self.view.backgroundColor = [[TJBAestheticsController singleton] yellowNotebookColor];
    self.metaTitleAreaContainer.backgroundColor = [UIColor blackColor];
    
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
        
        label.backgroundColor = [UIColor grayColor];
        label.font = [UIFont boldSystemFontOfSize: 12];
        label.textColor = [UIColor whiteColor];
        
    }
    
    // detailed line
    
    [self drawDetailedLines];
    
}

- (void)drawDetailedLines{
    
    [self.view layoutIfNeeded];
    [self.titleBarContainier layoutSubviews];
    
    [TJBAssortedUtilities drawVerticalDividerToRightOfLabel: self.exerciseColumnLabel
                                           horizontalOffset: 0
                                                  thickness: .5
                                             verticalOffset: 0
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

- (NSInteger)selectedIndexCorrespondingToCategory:(TJBExerciseCategoryType)catType{
    
    NSInteger index;
    
    switch (catType) {
        case PushType:
            index = 0;
            break;
            
        case PullType:
            index = 1;
            break;
            
        case LegsType:
            index = 2;
            break;
            
        case OtherType:
            index = 3;
            break;
            
        default:
            break;
    }
    

    
    return index;
    
}

- (NSString *)exerciseCategoryNameForSelectedExerciseCategorySegmentedControlIndex{
    
    TJBExerciseCategoryType categoryType = [self categoryForSCIndex: @(self.normalBrowsingExerciseSC.selectedSegmentIndex)];
    
    TJBExerciseCategory *ecManagedObject = [[CoreDataController singleton] exerciseCategory: categoryType];
    
    return  ecManagedObject.name;
    
}



- (void)browsingSCValueDidChange{
    
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
    
    NSOrderedSet<TJBRealizedSet *> *realizedSets = exercise.realizedSets;
    
    if (realizedSets.count > 0){
        
        return [self dateForRealizedSetCollection: realizedSets
                                            index: (int)realizedSets.count - 1];
        
    } else{
        
        return nil;
        
    }
    
    
}

- (NSDate *)dateForRealizedSetCollection:(NSOrderedSet<TJBRealizedSet *> *)rsCollection index:(int)index{
    
    // recursively finds the largest submission time in the collection
    // objects are held in chronological order, and thus, the greatest index is evaluated first
    
    NSDate *date = rsCollection[index].submissionTime;
    
    if (date){
        
        return date;
        
    } else{
        
        if (index == 0){
            
            return nil;
            
        } else{
            
            return [self dateForRealizedSetCollection: rsCollection
                                                index: index - 1];
            
        }
        
        
    }
    
    
    
}

#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    if (self.contentExercisesArray.count > 0){ // only selects the cell if there is any content to begin with
        
        if (_searchIsActive && self.searchBar){
            
            [self.searchBar resignFirstResponder];
            
        }
        
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
    
    if (_searchIsActive == YES && self.searchBar){
        
        [self.searchBar resignFirstResponder];
        
    }
    
    
    [self dismissViewControllerAnimated: YES
                             completion: nil];
    
}


//
//#pragma mark - Exercise Addition and Related Methods
//
//
//
//
//
//- (TJBExercise *)processUserRequestAndReturnExerciseWithName:(NSString *)exerciseName category:(TJBExerciseCategoryType)category{
//    
//    //// action is dependent upon several factors.  Depends on whether user it trying to create an existing exercise, has left the exercise text field blank, or has entered a valid new exercise name
//    
//    // conditional actions
//    
//    NSString *exerciseString = exerciseName;
//    
//    UIAlertAction *continueAction = [UIAlertAction actionWithTitle: @"Continue"
//                                                             style: UIAlertActionStyleDefault
//                                                           handler: nil];
//    
//    BOOL exerciseExists = [[CoreDataController singleton] exerciseExistsForName: exerciseName];
//    
//    if (exerciseExists){
//        
//        UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"Invalid Entry"
//                                                                       message: @"This exercise already exists"
//                                                                preferredStyle: UIAlertControllerStyleAlert];
//        
//        [alert addAction: continueAction];
//        
//        [self presentViewController: alert
//                           animated: YES
//                         completion: nil];
//        
//        return nil;
//        
//    } else if([exerciseString isEqualToString: @""]){
//        
//        UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"Invalid Entry"
//                                                                       message: @"Exercise entry is blank"
//                                                                preferredStyle: UIAlertControllerStyleAlert];
//        
//        [alert addAction: continueAction];
//        
//        [self presentViewController: alert
//                           animated: YES
//                         completion: nil];
//        
//        return nil;
//        
//    } else{
//        
//        TJBExercise *newExercise = [self addAndReturnNewExerciseWithName: exerciseName
//                                                                category: category];
//        
//        return newExercise;
//        
//    }
//    
//}
//
//- (TJBExercise *)addAndReturnNewExerciseWithName:(NSString *)name category:(TJBExerciseCategoryType)category{
//    
//    //// add the new exercise leverage CoreDataController methods.  Save the context when done
//    
//    CoreDataController *coreDataController = [CoreDataController singleton];
//    
//    NSString *newExerciseName = name;
//    
//    NSNumber *wasNewlyCreated = nil;
//    TJBExercise *newExercise = [coreDataController exerciseForName: newExerciseName
//                                                   wasNewlyCreated: &wasNewlyCreated
//                                       createAsPlaceholderExercise: [NSNumber numberWithBool: NO]];
//    
//    newExercise.category = [[CoreDataController singleton] exerciseCategory: category];
//    
//    [[CoreDataController singleton] saveContext];
//    
//    // need to use notification center so all affected fetched results controllers can perform fetch and update table views
//    
//    [[NSNotificationCenter defaultCenter] postNotificationName: ExerciseDataChanged
//                                                        object: nil];
//    
//    return newExercise;
//    
//}

#pragma mark - Search / List Functionality


- (IBAction)didPressSearch:(id)sender{
    
    if (!self.searchBar){
        
        [self createSearchBar];
        
    }
    
    // this button toggles between a list and search appearance, so must check state
    // this method is called by both the seach and list toolbar buttons
    
    [self deselectCellIfSelectionExists]; // deselect current selection if exists
    [self updateToolbarAppearanceAccordingToSelectionState];
    
    [self.view layoutIfNeeded];
    
    if (_searchIsActive == NO){
        
        // constraints and frames
        
        CGFloat verticalTranslation = self.normalBrowsingExerciseSC.frame.origin.y - self.actionsToolbar.frame.origin.y;
        self.exerciseSegmentedControlBottomSpaceConstr.constant -= verticalTranslation;
        
        NSArray *titleAreaHeightConstraints = @[self.columnsContainerHeight, self.headerAreaContainerHeight];
        for (NSLayoutConstraint *lc in titleAreaHeightConstraints){
            
            lc.constant = lc.constant + searchBarHeightDelta;
            
        }
        
        [self.view layoutIfNeeded];
        
        self.searchBar.frame = self.columnTitleLabelsContainer.frame;
        
        // state
        
        _searchIsActive = YES;
        
        [self deriveExerciseContentGivenState];
        [self.exerciseTableView reloadData];
        
        [self updateToolbarBarButtonItemsAccordingGivenState];
        
        [self.searchBar becomeFirstResponder];
        
        self.columnTitleLabelsContainer.hidden = YES;
        self.searchBar.hidden = NO;

    } else if (_searchIsActive == YES){
        
        // constraints and frames
        
        CGFloat verticalTranslation = self.normalBrowsingExerciseSC.frame.origin.y - self.actionsToolbar.frame.origin.y;
        self.exerciseSegmentedControlBottomSpaceConstr.constant += verticalTranslation;
        
        NSArray *titleAreaHeightConstraints = @[self.columnsContainerHeight, self.headerAreaContainerHeight];
        for (NSLayoutConstraint *lc in titleAreaHeightConstraints){
            
            lc.constant = lc.constant - searchBarHeightDelta;
            
        }
        
        [self.view layoutIfNeeded];
        
        self.searchBar.frame = self.titleBarContainier.frame;
        
        // state
        
        self.searchBar.hidden = YES;
        self.columnTitleLabelsContainer.hidden = NO;
        
        _searchIsActive = NO;
        
        [self deriveExerciseContentGivenState];
        [self.exerciseTableView reloadData];
        
        [self updateToolbarBarButtonItemsAccordingGivenState];
        
    }
    
    
}

- (void)updateToolbarBarButtonItemsAccordingGivenState{
    
    if (_searchIsActive == YES){
        
        if (!self.listToolbarButton){
            
            UIBarButtonItem *listBBI = [[UIBarButtonItem alloc] initWithImage: [UIImage imageNamed: @"listBlue30PDF"]
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
    
    UISearchBar *searchBar = [[UISearchBar alloc] initWithFrame: self.titleBarContainier.frame];
    self.searchBar = searchBar;
    
    [self.metaTitleAreaContainer insertSubview: searchBar
                aboveSubview: self.columnTitleLabelsContainer];
    
    [self.metaTitleAreaContainer insertSubview: self.titleBarContainier
                aboveSubview: searchBar];
    
    searchBar.delegate = self;
    
    searchBar.placeholder = @"Search exercises";
    searchBar.barStyle = UISearchBarStyleDefault;
    searchBar.barTintColor = [UIColor grayColor];
    searchBar.searchBarStyle = UISearchBarStyleDefault;
    searchBar.tintColor = [UIColor whiteColor];
    searchBar.showsCancelButton = YES;
    searchBar.translucent = NO;
    searchBar.opaque = YES;
    
}



#pragma mark - UISearchBarDelegate

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar{
    
    self.exerciseSearchString = searchBar.text;
    
    [self deriveExerciseContentGivenState];
    [self.exerciseTableView reloadData];
    
    [self.searchBar resignFirstResponder];
    
}

- (void)searchBarCancelButtonClicked:(UISearchBar *)searchBar{
    
    // execute same actions as would be executed if the list button were pressed
    
    [self didPressSearch: nil];
    
    [self.searchBar resignFirstResponder];
    
    
}





#pragma mark - Core Data

- (NSFetchRequest *)fetchRequestGivenState{
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName: @"Exercise"];
    
    NSSortDescriptor *nameSort = [NSSortDescriptor sortDescriptorWithKey: @"name"
                                                               ascending: YES];
    [request setSortDescriptors: @[nameSort]];
    
    NSCompoundPredicate *compoundPredicate;
    
    NSPredicate *showInExerciseListPredicate = [NSPredicate predicateWithFormat: @"showInExerciseList = YES"];
    
    if (_searchIsActive == NO){
        
        // only apply the compount predicate if the exercise search text field has a non blank entry
        
        NSString *selectedCategoryName = [self exerciseCategoryNameForSelectedExerciseCategorySegmentedControlIndex];
        
        NSPredicate *exercisesForCategory = [NSPredicate predicateWithFormat: @"category.name = %@",
                                             selectedCategoryName];
        
        compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates: @[exercisesForCategory, showInExerciseListPredicate]];
        
    } else if (_searchIsActive == YES){
        
        NSString *placeholderNameRoot = [[CoreDataController singleton] categoryStingFromEnum: PlaceholderType];
        NSPredicate *noPlaceholderExercises = [NSPredicate predicateWithFormat: @"category.name != %@",
                                               placeholderNameRoot];
        
        if (self.exerciseSearchString){
            
            NSPredicate *nameContainsString = [NSPredicate predicateWithFormat: @"name CONTAINS[cd] %@", self.exerciseSearchString];
            
            compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates: @[noPlaceholderExercises, nameContainsString, showInExerciseListPredicate]];
            
        } else{
            
            compoundPredicate = [NSCompoundPredicate andPredicateWithSubpredicates: @[noPlaceholderExercises, showInExerciseListPredicate]];
            
        }
        
    }
    
    request.predicate = compoundPredicate;
    
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
    
    return;
    
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





- (IBAction)didPressDeleteButton:(id)sender{
    
    [self.exerciseTableView beginUpdates];
    
    [self.exerciseTableView deleteRowsAtIndexPaths: @[self.selectedCellIndexPath]
                                  withRowAnimation: UITableViewRowAnimationLeft];
    
    TJBExercise *deletedExercise = self.contentExercisesArray[self.selectedCellIndexPath.row];
    
    [self.contentExercisesArray removeObject: deletedExercise];
    [[CoreDataController singleton] deleteExercise: deletedExercise];
    
    [self.exerciseTableView endUpdates];
    
    
    
    
}

#pragma mark - Add New Exercise Actions

- (IBAction)didPressAddNewButton:(id)sender{
    
    [self showExerciseAdditionView];
    
    
}

- (void)showExerciseAdditionView{
    
    if (!self.exerciseAdditionVEV){
        
        UIBlurEffect *blur = [UIBlurEffect effectWithStyle: UIBlurEffectStyleDark];
        UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect: blur];
        self.exerciseAdditionVEV = visualEffectView;
        visualEffectView.frame = self.view.bounds;
        
        [self.view addSubview: visualEffectView];
        
        __weak TJBExerciseSelectionScene *weakSelf = self;
        
        NewExerciseCallback neCallback = ^(TJBExercise *newExercise){
            
            [weakSelf newExerciseWasAdded: newExercise];
            
        };
        
        CancelCallback cCallback = ^{
            
            [weakSelf exerciseCreationWasCancelled];
            
        };
        
        NSNumber *selectedIndex = @(self.normalBrowsingExerciseSC.selectedSegmentIndex);
        TJBExerciseCategoryType currentlySelectedCategory = [self categoryForSCIndex: selectedIndex];
        
        ExerciseAdditionChildVC *eaVC = [[ExerciseAdditionChildVC alloc] initWithSelectedCategory: currentlySelectedCategory
                                                                            exerciseAddedCallback: neCallback
                                                                                   cancelCallback: cCallback];
        
        [self addChildViewController: eaVC];
        
        [visualEffectView.contentView addSubview: eaVC.view];
        
        [eaVC didMoveToParentViewController: self];
        
    }
    
    self.exerciseAdditionVEV.hidden = NO;
    
}

- (void)newExerciseWasAdded:(TJBExercise *)exercise{
    
    TJBExerciseCategoryType catType = [[CoreDataController singleton] typeForExerciseCategory: exercise.category];
    self.normalBrowsingExerciseSC.selectedSegmentIndex = [self selectedIndexCorrespondingToCategory: catType];
    
    NSIndexPath *newExerciseIndexPath = [NSIndexPath indexPathForRow: [self.contentExercisesArray indexOfObject: exercise]
                                                           inSection: 0];
    
    [self dismissViewControllerAnimated: YES
                             completion: ^{
                                 
                                 [self.exerciseTableView scrollToRowAtIndexPath: newExerciseIndexPath
                                                               atScrollPosition: UITableViewScrollPositionTop
                                                                       animated: YES];
                                 
                             }];
    

    
    
    
}


- (void)exerciseCreationWasCancelled{
    
    
    [self dismissViewControllerAnimated: YES
                             completion: nil];
    
    
}

//- (void)addNewExerciseInitialAlert_attemptedDuplicateExerciseName:(NSString *)duplicateExerciseName{
//    
//    NSString *alertMessage;
//    if (duplicateExerciseName){
//        
//        alertMessage = [NSString stringWithFormat: @"The exercise '%@' already exists. Please enter a different name", duplicateExerciseName];
//        
//    } else{
//        
//        alertMessage = @"Enter new exercise name";
//        
//    }
//    
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"New Exercise"
//                                                                   message: alertMessage
//                                                            preferredStyle: UIAlertControllerStyleAlert];
//    
//    [alert addTextFieldWithConfigurationHandler: ^(UITextField *tf){
//        
//        tf.textAlignment = NSTextAlignmentCenter;
//        tf.autocapitalizationType = UITextAutocapitalizationTypeWords;
//        
//    }];
//    
//    UIAlertAction *submitAction = [UIAlertAction actionWithTitle: @"Submit"
//                                                           style: UIAlertActionStyleDefault
//                                                         handler: ^(UIAlertAction *action){
//                                                             
//                                                             UITextField *nameTF = alert.textFields[0];
//                                                             
//                                                             [self createNewExerciseWithName: nameTF.text];
//                                                             
//                                                         }];
//    [alert addAction: submitAction];
//    
//    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle: @"Cancel"
//                                                           style: UIAlertActionStyleCancel
//                                                         handler: nil];
//    [alert addAction: cancelAction];
//    
//    [self presentViewController: alert
//                       animated: YES
//                     completion: nil];
//    
//}
//
//- (void)createNewExerciseWithName:(NSString *)name{
//    
//    BOOL exerciseNameAlreadyExists = [[CoreDataController singleton] exerciseExistsForName: name];
//    
//    if (exerciseNameAlreadyExists){
//        
//        [self addNewExerciseInitialAlert_attemptedDuplicateExerciseName: name];
//        
//    } else{
//        
//        [self categorySelectionAlertSequenceForExerciseWithName: name];
//    }
//    
//}
//
//- (void)categorySelectionAlertSequenceForExerciseWithName:(NSString *)name{
//    
//    // categories
//    
//    CoreDataController *cdc = [CoreDataController singleton];
//    
//    TJBExerciseCategory *pushCat = [cdc exerciseCategory: PushType];
//    TJBExerciseCategory *pullCat = [cdc exerciseCategory: PullType];
//    TJBExerciseCategory *legsCat = [cdc exerciseCategory: LegsType];
//    TJBExerciseCategory *otherCat = [cdc exerciseCategory: OtherType];
//    
//    NSArray *categories = @[pushCat,
//                            pullCat,
//                            legsCat,
//                            otherCat];
//    
//    // alert
//    
//    UIAlertController *alert = [UIAlertController alertControllerWithTitle: name
//                                                                   message: @"Select the new exercise's category"
//                                                            preferredStyle: UIAlertControllerStyleAlert];
//    
//    for (TJBExerciseCategory *cat in categories){
//        
//        UIAlertAction *action = [UIAlertAction actionWithTitle: cat.name
//                                                         style: UIAlertActionStyleDefault
//                                                       handler: ^(UIAlertAction *action){
//                                                           
//                                                           [self addNewExerciseForName: name
//                                                                              category: cat];
//                                                           
//                                                       }];
//        [alert addAction: action];
//        
//    }
//    
//    [self presentViewController: alert
//                       animated: YES
//                     completion: nil]; // coreDataDidUpdateNotification already established so no need to direcly relaod table data
//    
//    return;
//    
//}
//
//- (void)addNewExerciseForName:(NSString *)name category:(TJBExerciseCategory *)category{
//    
//    NSManagedObjectContext *moc = [[CoreDataController singleton] moc];
//    TJBExercise *newExercise = [NSEntityDescription insertNewObjectForEntityForName: @"Exercise"
//                                                             inManagedObjectContext: moc];
//    
//    newExercise.isPlaceholderExercise = NO;
//    newExercise.name = name;
//    newExercise.showInExerciseList = YES;
//    newExercise.category = category;
//    
//    [[CoreDataController singleton] saveContext];
//    
//}



#pragma mark - Edit Actions


- (IBAction)didPressEditButton:(id)sender{
    
    // present an alert controller giving the user to change the selected exercise category or name
    
    TJBExercise *selectedExercise = self.contentExercisesArray[self.selectedCellIndexPath.row];
    NSString *alertTitle = [NSString stringWithFormat: @"%@", selectedExercise.name];
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle: alertTitle
                                                                   message: @"Would you like to edit the exercise name or category?"
                                                            preferredStyle: UIAlertControllerStyleAlert];
    
    // cancel action
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle: @"Cancel"
                                                           style: UIAlertActionStyleCancel
                                                         handler: nil];
    [alert addAction: cancelAction];
    
    // edit name
    
    UIAlertAction *nameAction = [UIAlertAction actionWithTitle: @"Edit name"
                                                         style: UIAlertActionStyleDefault
                                                       handler: ^(UIAlertAction *action){
                                                           
                                                           [self editExerciseNameAlertSequenceForExercise: selectedExercise
                                                                                   attemptedDuplicateName: nil];
                                                           
                                                       }];
    [alert addAction: nameAction];
    
    // edit category
    
    UIAlertAction *categoryAction = [UIAlertAction actionWithTitle: @"Edit category"
                                                         style: UIAlertActionStyleDefault
                                                       handler: ^(UIAlertAction *action){
                                                          
                                                           [self editExerciseCategoryAlertSequenceForExercise: selectedExercise];
                                                           
                                                       }];
    [alert addAction: categoryAction];
    
    // present alert
    
    [self presentViewController: alert
                       animated: YES
                     completion: nil];
    
}



- (void)editExerciseNameAlertSequenceForExercise:(TJBExercise *)exercise attemptedDuplicateName:(NSString *)attemptedDuplicateName{
    
    NSString *alertMessage;
    if (attemptedDuplicateName){
        
        alertMessage = [NSString stringWithFormat: @"The exercise '%@' already exists. Please enter a different name", attemptedDuplicateName];
        
    } else{
        
        alertMessage = @"Enter new name";
        
    }
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle: exercise.name
                                                                   message: alertMessage
                                                            preferredStyle: UIAlertControllerStyleAlert];
    
    [alert addTextFieldWithConfigurationHandler: ^(UITextField *tf){
        
        tf.textAlignment = NSTextAlignmentCenter;
        tf.autocapitalizationType = UITextAutocapitalizationTypeWords;
        
    }];
    
    UIAlertAction *submitAction = [UIAlertAction actionWithTitle: @"Submit"
                                                           style: UIAlertActionStyleDefault
                                                         handler: ^(UIAlertAction *action){
                                                             
                                                             UITextField *nameTF = alert.textFields[0];
                                                             
                                                             [self changeNameForExercise: exercise
                                                                                 newName: nameTF.text];
                                                             
                                                         }];
    [alert addAction: submitAction];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle: @"Cancel"
                                                           style: UIAlertActionStyleCancel
                                                         handler: nil];
    [alert addAction: cancelAction];
    
    [self presentViewController: alert
                       animated: YES
                     completion: nil];
    
}

- (void)changeNameForExercise:(TJBExercise *)exercise newName:(NSString *)newName{
    
    BOOL exerciseNameAlreadyExists = [[CoreDataController singleton] exerciseExistsForName: newName];
    
    if (exerciseNameAlreadyExists){
        
        [self editExerciseNameAlertSequenceForExercise: exercise
                                attemptedDuplicateName: newName];
        
    } else{
        
        exercise.name = newName;
        [[CoreDataController singleton] saveContext];
        
    }

}


- (void)editExerciseCategoryAlertSequenceForExercise:(TJBExercise *)exercise{
    
    // categories
    
    CoreDataController *cdc = [CoreDataController singleton];
    
    TJBExerciseCategory *pushCat = [cdc exerciseCategory: PushType];
    TJBExerciseCategory *pullCat = [cdc exerciseCategory: PullType];
    TJBExerciseCategory *legsCat = [cdc exerciseCategory: LegsType];
    TJBExerciseCategory *otherCat = [cdc exerciseCategory: OtherType];
    
    NSArray *categories = @[pushCat,
                            pullCat,
                            legsCat,
                            otherCat];
    
    // alert
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle: exercise.name
                                                                   message: @"Select new category"
                                                            preferredStyle: UIAlertControllerStyleAlert];
    
    for (TJBExerciseCategory *cat in categories){
        
        UIAlertAction *action = [UIAlertAction actionWithTitle: cat.name
                                                         style: UIAlertActionStyleDefault
                                                       handler: ^(UIAlertAction *action){
                                                           
                                                           [self setCategory: cat
                                                                 forExercise: exercise];
                                                           
                                                       }];
        [alert addAction: action];
        
    }
    
    [self presentViewController: alert
                       animated: YES
                     completion: nil]; // coreDataDidUpdateNotification already established so no need to direcly relaod table data
    
    return;
    
}

- (void)setCategory:(TJBExerciseCategory *)category forExercise:(TJBExercise *)exercise{
    
    exercise.category = category;
    
    [[CoreDataController singleton] saveContext];
    
}



@end




























