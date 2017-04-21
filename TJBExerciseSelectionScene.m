//
//  TJBExerciseSelectionScene.m
//  Beast
//
//  Created by Trevor Beasty on 12/19/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import "TJBExerciseSelectionScene.h"

// core data

#import "CoreDataController.h"

// child VC's

#import "TJBExerciseAdditionChildVC.h"
#import "TJBSearchExerciseChild.h"

// cells

#import "TJBNoDataCell.h"
#import "TJBExerciseSelectionCell.h"

#import "TJBAestheticsController.h"

@interface TJBExerciseSelectionScene () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

{
    
    // state
    
    BOOL _exerciseAdditionActive;
    BOOL _searchIsActive;
    
}

// core

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSMutableArray *contentExercisesArray;
@property (strong) TJBExerciseAdditionChildVC *exerciseAdditionChildVC;
@property (strong) TJBSearchExerciseChild *seChildVC;


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



// IBAction

- (IBAction)didPressLeftBarButton:(id)sender;



@end

static NSString * const cellReuseIdentifier = @"basicCell";

typedef enum{
    SearchState,
    DefaultState,
    AdditionState
}TJBExerciseSceneState;

@implementation TJBExerciseSelectionScene

#pragma mark - Instantiation

- (instancetype)initWithCallbackBlock:(void (^)(TJBExercise *))block{
    
    self = [super init];
    
    self.callbackBlock = block;
    
    _exerciseAdditionActive = NO;
    _searchIsActive = NO;
    
    return self;
    
}

#pragma mark - View Life Cycle

// view will appear and disappear are leveraged to have the view adjust itself when the keyboard is shown

- (void)viewWillAppear:(BOOL)animated{
    
    [super viewWillAppear: animated];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(keyboardWillAppear:)
                                                 name: UIKeyboardWillShowNotification
                                               object: nil];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(keyboardWillDisappear:)
                                                 name: UIKeyboardWillHideNotification
                                               object: nil];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear: animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: UIKeyboardWillShowNotification
                                                  object: nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: UIKeyboardWillHideNotification
                                                  object: nil];
    
    
    
}

- (void)viewDidLoad{
    
    [self.view layoutSubviews];
    
    [self configureTableView];
    
    [self fetchAllExercises];
    
    [self browsingSCValueDidChange]; // called to force the controller to create the array the table view needs
    
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


- (void)registerForCoreDataNotifications{
    
    //// configure managed context notification for updating
    
    NSManagedObjectContext *moc = [[CoreDataController singleton] moc];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(fetchAllExercises)
                                                 name: NSManagedObjectContextDidSaveNotification
                                               object: moc];
    
}




- (void)fetchAllExercises{
    
    if (self.fetchedResultsController){
        
        self.fetchedResultsController = nil;
        
    }
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName: @"Exercise"];
    
    // only apply the compount predicate if the exercise search text field has a non blank entry
    
    NSPredicate *noPlaceholderExercisesPredicate = [NSPredicate predicateWithFormat: @"category.name != %@",
                                                    @"Placeholder"];
    
    request.predicate = noPlaceholderExercisesPredicate;
    
    NSSortDescriptor *categoryNameSort = [NSSortDescriptor sortDescriptorWithKey: @"category.name"
                                                                       ascending: YES];
    
    NSSortDescriptor *nameSort = [NSSortDescriptor sortDescriptorWithKey: @"name"
                                                               ascending: YES];
    
    [request setSortDescriptors: @[categoryNameSort, nameSort]];
    
    NSManagedObjectContext *moc = [[CoreDataController singleton] moc];
    
    NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest: request
                                                                          managedObjectContext: moc
                                                                            sectionNameKeyPath: @"category.name"
                                                                                     cacheName: nil];
    
    self.fetchedResultsController = frc;
    
    NSError *error = nil;
    if (![self.fetchedResultsController performFetch: &error])
    {
        NSLog(@"Failed to initialize fetchedResultsController: %@\n%@", [error localizedDescription], [error userInfo]);
        abort();
    }
    
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
    
//    UINib *titleNib = [UINib nibWithNibName: @"TJBExerciseSelectionTitleCell"
//                                     bundle: nil];
//    
//    [self.exerciseTableView registerNib: titleNib
//                 forCellReuseIdentifier: @"TJBExerciseSelectionTitleCell"];
    
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

- (void)browsingSCValueDidChange{
    
    TJBExerciseCategoryType catType = [self categoryForSCIndex: @(self.normalBrowsingExerciseSC.selectedSegmentIndex)];
    NSString *filterString = [[CoreDataController singleton] categoryStingFromEnum: catType];
    
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    
    NSPredicate *categoryFilter = [NSPredicate predicateWithFormat: @"category.name == %@",
                                   filterString];
    
    returnArray = [self.fetchedResultsController.fetchedObjects mutableCopy];
    
    [returnArray filterUsingPredicate: categoryFilter];
    
    self.contentExercisesArray = returnArray;
    
    [self.exerciseTableView reloadData];
    
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
    
    
    if (self.contentExercisesArray.count > 0){
        
        TJBExercise *selectedExercise = self.contentExercisesArray[indexPath.row ];
        
        self.callbackBlock(selectedExercise);
        
    }



 
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


#pragma mark - Button Actions

- (IBAction)didPressLeftBarButton:(id)sender{
    
    if (_exerciseAdditionActive == YES){
        
        [self.exerciseAdditionChildVC makeExerciseTFResignFirstResponder];
        
    }
    
    if (_searchIsActive == YES){
        
        [self.seChildVC makeSearchTextFieldResignFirstResponder];
        
    }
    
    [self dismissViewControllerAnimated: YES
                             completion: nil];
    
}

#pragma mark - Exercise Addition and Related Methods

- (IBAction)didPressAddNewExercise:(id)sender {
    
    if (_exerciseAdditionActive == NO){
        
        if (!self.exerciseAdditionChildVC){
            
            __weak TJBExerciseSelectionScene *weakSelf = self;
            
            void (^listCallback)(void) = ^{
                
                [self configureControllerForState: DefaultState];
                
            };
            
            void (^eaCallback)(NSString *, NSNumber *, BOOL) = ^(NSString *exerciseName, NSNumber *categoryIndex, BOOL shouldSelect){
                
                TJBExerciseCategoryType catType = [self categoryForSCIndex: categoryIndex];
        
                TJBExercise *newExercise = [weakSelf processUserRequestAndReturnExerciseWithName: exerciseName
                                                                                        category: catType];
                
                if (newExercise && shouldSelect){
                    
                    NSLog(@"add exercise and select");
                    
                    [self.exerciseAdditionChildVC makeExerciseTFResignFirstResponder];
                    
                    self.callbackBlock(newExercise);
                    
                } else{
                    
                    NSLog(@"just add exercise");
                    
                    [self.exerciseAdditionChildVC clearTextField];
                    
                }
                
            };
            
            TJBExerciseAdditionChildVC *eaChildVC = [[TJBExerciseAdditionChildVC alloc] initWithExerciseAdditionCallback: eaCallback
                                                                                                            listCallback: listCallback];
            self.exerciseAdditionChildVC = eaChildVC;
            
            [self addChildViewController: eaChildVC];
            
//            self.tableViewToTitleBarConstr.constant = 0; // need to change this here in case jumping from SearchState to AdditionState because table view is shifted downward for SearchState
            [self.view layoutIfNeeded];
            
            eaChildVC.view.frame = self.exerciseTableView.frame;
            [self.view addSubview: eaChildVC.view];
            
            [eaChildVC didMoveToParentViewController: self];
            
        }
        
        [self configureControllerForState: AdditionState];
        
    }
}



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

#pragma mark - Search Functionality

- (IBAction)didPressSearchButton:(id)sender{
    
    if (_searchIsActive == NO){
        
        if (!self.seChildVC){
            
            __weak TJBExerciseSelectionScene *weakSelf = self;
            
            void (^listButtonCallback)(void) = ^{
                
                [weakSelf configureControllerForState: DefaultState];
                
            };
            
            void (^searchTextFieldCallback)(NSString *) = ^(NSString *string){
                
                [weakSelf deriveExerciseContentBasedOnSearchString: string];
                
            };
            
            TJBSearchExerciseChild *seChildVC = [[TJBSearchExerciseChild alloc] initWithListButtonCallback: listButtonCallback
                                                                                   searchTextFieldCallback: searchTextFieldCallback];
            self.seChildVC = seChildVC;
            
            // add as child VC and give proper frame
            // will have this child's view overlay the first cell in the table view
            
            [self addChildViewController: seChildVC];
            
            CGFloat searchTitleHeight = 100;
            
            CGRect childViewFrame = self.exerciseTableView.frame;
            childViewFrame.size.height = searchTitleHeight;
            
            seChildVC.view.frame = childViewFrame;
            [self.view addSubview: seChildVC.view];
            
            [seChildVC didMoveToParentViewController: self];
            
        }
        
        [self configureControllerForState: SearchState];
        
    }
    
}


- (void)deriveExerciseContentBasedOnSearchString:(NSString *)searchString{

    NSMutableArray *allExercises = [self.fetchedResultsController.fetchedObjects mutableCopy];

    if ([searchString isEqualToString: @""]){ // if the search text field is blank, show all options

        self.contentExercisesArray = allExercises;

    } else{

        NSPredicate *searchFilterPredicate = [NSPredicate predicateWithFormat: @"name CONTAINS[cd] %@", searchString];
        NSPredicate *noPlaceholderExercisesPredicate = [NSPredicate predicateWithFormat: @"category.name != %@", @"Placeholder"];

        NSCompoundPredicate *compPred = [NSCompoundPredicate andPredicateWithSubpredicates: @[noPlaceholderExercisesPredicate,
                                                                                              searchFilterPredicate]];

        NSArray *filteredExercises = [allExercises filteredArrayUsingPredicate: compPred];
        self.contentExercisesArray = [filteredExercises mutableCopy];

    }

    [self.exerciseTableView reloadData];

}

- (void)keyboardWillAppear:(NSNotification *)notification{

    // these actions should not be taken if exercise addition is active

    if (_exerciseAdditionActive == NO){

        CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;

        CGRect tableviewFrame = self.exerciseTableView.frame;
        CGFloat tvBottomEdge = tableviewFrame.origin.y + tableviewFrame.size.height;
        CGFloat bottomTVEdgeToScreenBounds = [UIScreen mainScreen].bounds.size.height - tvBottomEdge;
        CGFloat reductionInTVHeight = keyboardSize.height - bottomTVEdgeToScreenBounds;

        // update the constraint that controls the vertical distance between the table view and segmented control
        // will do so by increasing its constant by the reductionInTVHeight

//        CGFloat currentConstrConstant = self.scToTVVertDist.constant;
//        CGFloat newConstrConstant = currentConstrConstant + reductionInTVHeight + 8;
//        self.scToTVVertDist.constant = newConstrConstant;

        // hide views

        [self.view layoutIfNeeded];

    }




}

- (void)keyboardWillDisappear:(NSNotification *)notification{

    // these actions should not be taken if exercise addition is active

    if (_exerciseAdditionActive == NO){

//        self.scToTVVertDist.constant = 8;

        [self.view layoutIfNeeded];

    }

}




#pragma mark - State Control

- (void)configureControllerForState:(TJBExerciseSceneState)state{
    
        switch (state) {
            case DefaultState:
                _searchIsActive = NO;
                _exerciseAdditionActive = NO;
                break;
    
            case AdditionState:
                _searchIsActive = NO;
                _exerciseAdditionActive = YES;
                break;
    
            case SearchState:
                _searchIsActive = YES;
                _exerciseAdditionActive = NO;
                break;
                
            default:
                break;
        }
    
    if (state != SearchState){
        
//        self.tableViewToTitleBarConstr.constant = 0;
        
        if (self.seChildVC){
            
            self.seChildVC.view.hidden = YES;
            [self.seChildVC makeSearchTextFieldResignFirstResponder];
            
        }
        
    } else{
        
//        self.tableViewToTitleBarConstr.constant = self.seChildVC.view.frame.size.height;
        
        [self deriveExerciseContentBasedOnSearchString: [self.seChildVC searchTextFieldText]];
        
        if (self.seChildVC){
            
            self.seChildVC.view.hidden = NO;
            [self.seChildVC makeSearchTextFieldFirstResponder];
            
        }
        
    }
    
    if (state != AdditionState){
        
        if (self.exerciseAdditionChildVC){
            
            self.exerciseAdditionChildVC.view.hidden = YES;
            [self.exerciseAdditionChildVC makeExerciseTFResignFirstResponder];
            self.exerciseTableView.hidden = NO;
//            self.addNewExerciseButton.enabled = YES;
//            [self.addNewExerciseButton setImage: [UIImage imageNamed: @"addCircledBlue32"]
//                                       forState: UIControlStateNormal];
            
        }
        
    } else{
        
        if (self.exerciseAdditionChildVC){
            
            self.exerciseAdditionChildVC.view.hidden = NO;
            [self.exerciseAdditionChildVC makeExerciseTFFirstResponder];
            self.exerciseTableView.hidden = YES;
//            self.addNewExerciseButton.enabled = NO;
//            [self.addNewExerciseButton setImage: nil
//                                       forState: UIControlStateNormal];
            
        }
        
    }
    
    if (state != DefaultState){
        
        self.normalBrowsingExerciseSC.hidden = YES;
//        self.searchButton.hidden = YES;
        
    } else{
        
        self.normalBrowsingExerciseSC.hidden = NO;
//        self.searchButton.hidden = NO;
        
        [self browsingSCValueDidChange]; // forces table view content to be derived
        
    }
    
    [self.exerciseTableView reloadData];
    [self.view layoutIfNeeded];
  
}

@end




























