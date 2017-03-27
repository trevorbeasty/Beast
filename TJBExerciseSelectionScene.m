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
#import "TJBExerciseSelectionTitleCell.h"

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

@property (weak, nonatomic) IBOutlet UIButton *addNewExerciseButton;
@property (weak, nonatomic) IBOutlet UITableView *exerciseTableView;
@property (weak, nonatomic) IBOutlet UIButton *leftBarButton;
//@property (weak, nonatomic) IBOutlet UIButton *rightBarButton;
@property (weak, nonatomic) IBOutlet UILabel *mainTitleLabel;
//@property (weak, nonatomic) IBOutlet UILabel *exerciseLabel;
//@property (weak, nonatomic) IBOutlet UITextField *exerciseTextField;
//@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
//@property (weak, nonatomic) IBOutlet UISegmentedControl *categorySegmentedControl;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *exerciseAdditionConstraint;
//@property (weak, nonatomic) IBOutlet UIButton *addButton;
//@property (weak, nonatomic) IBOutlet UIView *exerciseAdditionContainer;
//@property (weak, nonatomic) IBOutlet UIView *titleBarContainer;
//@property (weak, nonatomic) IBOutlet UIButton *addAndSelectButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *normalBrowsingExerciseSC;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
//@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
//@property (weak, nonatomic) IBOutlet UILabel *searchingAllExercisesLabel;
//@property (weak, nonatomic) IBOutlet UILabel *secondBarLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scToTVVertDist;
//@property (weak, nonatomic) IBOutlet UIButton *exerciseAdditionBackButton;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewToTitleBarConstr;



// IBAction

- (IBAction)didPressAddNewExercise:(id)sender;
- (IBAction)didPressLeftBarButton:(id)sender;
//- (IBAction)didPressAddButton:(id)sender;
//- (IBAction)didPressAddAndSelect:(id)sender;
- (IBAction)didPressSearchButton:(id)sender;
//- (IBAction)didPressExerciseAdditionBackButton:(id)sender;



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


//- (void)addTapGestureRecognizerToViewForKeyboardNotification{
//    
//    //// add gesture recognizer to the view.  It will be used to dismiss the keyboard if the touch is not in the keyboard or text field
//    //// also register for the UIKeyboardDidShowNotification so that the frame of the keyboard can be stored for later use in analyzing touches
//    
//    // tap GR
//    
//    UITapGestureRecognizer *singleTapGR = [[UITapGestureRecognizer alloc] initWithTarget: self
//                                                                                  action: @selector(didSingleTap:)];
//    
//    singleTapGR.numberOfTapsRequired = 1;
//    singleTapGR.cancelsTouchesInView = NO;
//    singleTapGR.delaysTouchesBegan = NO;
//    singleTapGR.delaysTouchesEnded = NO;
//    
//    [self.view addGestureRecognizer: singleTapGR];
//    
//}

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
    
    NSSortDescriptor *nameSort = [NSSortDescriptor sortDescriptorWithKey: @"name"
                                                               ascending: YES];
    
    [request setSortDescriptors: @[nameSort]];
    
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
    
    self.view.backgroundColor = [[TJBAestheticsController singleton] yellowNotebookColor];
    
    // table view
    
    self.exerciseTableView.backgroundColor = [UIColor clearColor];
    
    // browsing segmented control
    
    self.normalBrowsingExerciseSC.tintColor = [UIColor blackColor];
    
    // title bar buttons
    
    NSArray *buttons = @[self.leftBarButton, self.addNewExerciseButton];
    for (UIButton *b in buttons){
        
        b.backgroundColor = [UIColor darkGrayColor];

        
    }
    
    self.leftBarButton.backgroundColor = [UIColor darkGrayColor];
    
    // main title label
    
    self.mainTitleLabel.font = [UIFont boldSystemFontOfSize: 25];
    
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
    
    UINib *titleNib = [UINib nibWithNibName: @"TJBExerciseSelectionTitleCell"
                                     bundle: nil];
    
    [self.exerciseTableView registerNib: titleNib
                 forCellReuseIdentifier: @"TJBExerciseSelectionTitleCell"];
    
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
    
    NSInteger isSearchingCorrection; // when searching, there is not title cell. Must adjust table view count with respect to this
    
    if (_searchIsActive){
        isSearchingCorrection = -1;
    } else{
        isSearchingCorrection = 0;
    }
    
    if (contentCellCount == 0){
        
        return 2 + isSearchingCorrection;
        
    } else{
        
        return contentCellCount + 1 + isSearchingCorrection;
        
    }
 
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger contentCellCount = self.contentExercisesArray.count;
    
    NSInteger adjustedIndex; // used to reference the content array. It adjust the row of the index path according to vc state
    
    if (_searchIsActive == NO){
        
        adjustedIndex = indexPath.row - 1;
        
    } else{
        
        adjustedIndex = indexPath.row;
        
    }
    
    if (indexPath.row == 0 && _searchIsActive == NO){
        
        NSString *filterString;
        
        if (_searchIsActive){
            
            filterString = @"Searching All";
            
        } else{
            
            switch (self.normalBrowsingExerciseSC.selectedSegmentIndex) {
                case 0:
                    filterString = @"Push";
                    break;
                    
                case 1:
                    filterString = @"Pull";
                    break;
                    
                case 2:
                    filterString = @"Leg";
                    break;
                    
                case 3:
                    filterString = @"Other";
                    
                default:
                    break;
            }
            
        }
    
        TJBExerciseSelectionTitleCell *cell = [self.exerciseTableView dequeueReusableCellWithIdentifier: @"TJBExerciseSelectionTitleCell"];
        
        cell.backgroundColor = [[TJBAestheticsController singleton] yellowNotebookColor];
        
        cell.titleLabel.text = [NSString stringWithFormat: @"%@ Exercises", filterString];
        cell.subTitleLabel.text = @"select an exercise";
        
        cell.detail1Label.text = @"Name";
        cell.detail2Label.text = @"Date Last Executed";
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
        
    } else{
        
        if (contentCellCount == 0){
            
            TJBNoDataCell *cell = [self.exerciseTableView dequeueReusableCellWithIdentifier: @"TJBNoDataCell"];
            
            cell.mainLabel.text = @"No Exercises";
            cell.selectionStyle = UITableViewCellSelectionStyleNone;
            cell.backgroundColor = [UIColor clearColor];
            
            return cell;
            
        } else{
            
            TJBExerciseSelectionCell *cell = [self.exerciseTableView dequeueReusableCellWithIdentifier: @"TJBExerciseSelectionCell"];
            
            TJBExercise *exercise = self.contentExercisesArray[adjustedIndex];
            
            cell.exerciseNameLabel.text = exercise.name;
            
            NSDate *dateLastExecuted = [self dateLastExecutedForExercise: exercise];
            
            // nil may be returned for the date. If so, give the date label an X
            
            if (dateLastExecuted){
                
                NSDateFormatter *df = [[NSDateFormatter alloc] init];
                df.dateFormat = @"MM / dd / yy";
                cell.dateLabel.text = [df stringFromDate: dateLastExecuted];
                
            } else{
                
                cell.dateLabel.text = @"X";
                
            }
            
            cell.backgroundColor = [UIColor clearColor];
            
            return cell;
        
        }
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
        realizedSetDate = [[realizedSets lastObject] endDate];
        
    }
    
    // realized chain
    
    NSDate *realizedChainDate = nil;
    NSInteger chainCount = exercise.chains.count;
    
    if (chainCount > 0){
        
        // find the realized chain at the largest index
        // the chains property holds a mix of chain templates and realized chains, so I have to check for type
        // no check is done to see if an exercise was actually performed - this function will return the date created for a realized chain even if no exercises were actually performed
        
        for (int i = (int)chainCount - 1; i >= 0; i--){
            
            TJBChain *chain = exercise.chains[i];
            
            if ([chain isKindOfClass: [TJBRealizedChain class]]){
                
                realizedChainDate = chain.dateCreated;
                
                break;
                
            }
        }
    }
    
    // if both dates are nonnull, return the larger one.  If only one date is nonnull, return that date.  Otherwise, return nil
    
    if (!realizedSetDate && !realizedChainDate){
        
        return nil;
        
    } else if (realizedSetDate && !realizedChainDate){
        
        return realizedSetDate;
        
    } else if (!realizedSetDate && realizedChainDate){
        
        return realizedChainDate;
        
    } else{
        
        float timeDiff = [realizedSetDate timeIntervalSinceDate: realizedChainDate];
        
        if (timeDiff > 0){
            return realizedSetDate;
        } else{
            return realizedChainDate;
        }
        
    }
    
}

#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    if (self.contentExercisesArray.count != 0){
        
        if (_searchIsActive){
            
            TJBExercise *selectedExercise = self.contentExercisesArray[indexPath.row];
            
            self.callbackBlock(selectedExercise);
            
        } else{
            
            if (indexPath.row != 0){
                
                TJBExercise *selectedExercise = self.contentExercisesArray[indexPath.row - 1];
                
                self.callbackBlock(selectedExercise);
                
            }
            
        }
        
    }
 
}



- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat titleCellHeight = 90;
    CGFloat contentCellHeight = 60;
    
    CGFloat fillHeight;
    
    if (_searchIsActive == NO){
        
        fillHeight = self.exerciseTableView.frame.size.height - titleCellHeight;
        
    } else{
        
        fillHeight = self.exerciseTableView.frame.size.height;
        
    }
    
    
    NSInteger contentCellCount = self.contentExercisesArray.count;
    BOOL atLeastOneContentCell = contentCellCount >= 1;
    
    // the returned height will vary according to several conditions
    // 1 - whether or not the table view is in search mode, in which case there is no title cell
    // 2 - whether or not there is content to be displayed - which dictates whether the contentCellHeight or the fillHeight is returned
    
    if (_searchIsActive == NO){
        
        if (indexPath.row == 0){
            
            return titleCellHeight;
            
        } else{
            
            if (atLeastOneContentCell){
                
                return  contentCellHeight;
                
            } else{
                
                return  fillHeight;
                
            }
            
        }
        
    } else{ // this is the condition for which search IS active
        
        if (atLeastOneContentCell){
            
            return  contentCellHeight;
            
        } else{
            
            return  fillHeight;
            
        }
        
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
            
            self.tableViewToTitleBarConstr.constant = 0; // need to change this here in case jumping from SearchState to AdditionState because table view is shifted downward for SearchState
            [self.view layoutIfNeeded];
            
            eaChildVC.view.frame = self.exerciseTableView.frame;
            [self.view addSubview: eaChildVC.view];
            
            [eaChildVC didMoveToParentViewController: self];
            
        }
        
        [self configureControllerForState: AdditionState];
        
    }
}

//- (void)hideExerciseAdditionChildVCAndShowTableView{
//    
//    self.exerciseAdditionChildVC.view.hidden = YES;
//    self.exerciseTableView.hidden = NO;
//    _exerciseAdditionActive = NO;
//    [self.addNewExerciseButton setImage: [UIImage imageNamed: @"new"]
//                               forState: UIControlStateNormal];
//    self.searchButton.hidden = NO;
//    self.normalBrowsingExerciseSC.hidden = NO;
//    
//    [self.exerciseAdditionChildVC makeExerciseTFResignFirstResponder];
//    
//}



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
            
            CGFloat searchTitleHeight = 90;
            
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
    
    NSLog(@"search string: %@", searchString);

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

        CGFloat currentConstrConstant = self.scToTVVertDist.constant;
        CGFloat newConstrConstant = currentConstrConstant + reductionInTVHeight + 8;
        self.scToTVVertDist.constant = newConstrConstant;

        // hide views

        [self.view layoutIfNeeded];

    }




}

- (void)keyboardWillDisappear:(NSNotification *)notification{

    // these actions should not be taken if exercise addition is active

    if (_exerciseAdditionActive == NO){

        self.scToTVVertDist.constant = 8;

        [self.view layoutIfNeeded];

    }

}


//#pragma  mark - Convenience
//
//- (NSString *)selectedCategory{
//    
//    NSString *selectedCategory;
//    
//    NSInteger categoryIndex = self.categorySegmentedControl.selectedSegmentIndex;
//    
//    switch (categoryIndex){
//        case 0:
//            selectedCategory = @"Push";
//            break;
//            
//        case 1:
//            selectedCategory = @"Pull";
//            break;
//            
//        case 2:
//            selectedCategory = @"Legs";
//            break;
//            
//        case 3:
//            selectedCategory = @"Other";
//            break;
//            
//        default:
//            break;
//            
//    }
//    
//    return selectedCategory;
//    
//}
//
//#pragma mark - Gesture Recognizer
//
//- (void)didSingleTap:(UIGestureRecognizer *)gr{
//    
//    //// because this gesture does not register if the touch is in the keyboard or text field, simply have to check if the keyboard is showing, and dismiss it if so
//    
//    if ([self.exerciseTextField isFirstResponder]){
//        
//        [self.exerciseTextField resignFirstResponder];
//        
//    }
//    
//    if ([self.searchTextField isFirstResponder]){
//        
//        [self.searchTextField resignFirstResponder];
//        
//    }
//}
//
//#pragma mark - <UITextFieldDelegate>
//
//- (BOOL)textFieldShouldReturn:(UITextField *)textField{
//    
//    [textField resignFirstResponder];
//    
//    return YES;
//    
//}
//
//
//
//#pragma mark - Core Data
//
//- (void)updateFetchedResultsController{
//    
//    //// refresh fetched managed objects and all trickle-down
//    
//    [self createFetchedResultsController];
//    
//    [self.exerciseTableView reloadData];
//    
//}
//
//#pragma mark - Keyboard View Adjustments
//

//
//

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
        
        self.tableViewToTitleBarConstr.constant = 0;
        
        if (self.seChildVC){
            
            self.seChildVC.view.hidden = YES;
            [self.seChildVC makeSearchTextFieldResignFirstResponder];
            
        }
        
    } else{
        
        self.tableViewToTitleBarConstr.constant = self.seChildVC.view.frame.size.height;
        
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
            self.addNewExerciseButton.enabled = YES;
            [self.addNewExerciseButton setImage: [UIImage imageNamed: @"new"]
                                       forState: UIControlStateNormal];
            
        }
        
    } else{
        
        if (self.exerciseAdditionChildVC){
            
            self.exerciseAdditionChildVC.view.hidden = NO;
            [self.exerciseAdditionChildVC makeExerciseTFFirstResponder];
            self.exerciseTableView.hidden = YES;
            self.addNewExerciseButton.enabled = NO;
            [self.addNewExerciseButton setImage: nil
                                       forState: UIControlStateNormal];
            
        }
        
    }
    
    if (state != DefaultState){
        
        self.normalBrowsingExerciseSC.hidden = YES;
        self.searchButton.hidden = YES;
        
    } else{
        
        self.normalBrowsingExerciseSC.hidden = NO;
        self.searchButton.hidden = NO;
        
        [self browsingSCValueDidChange]; // forces table view content to be derived
        
    }
    
    [self.exerciseTableView reloadData];
    [self.view layoutIfNeeded];
  
}

@end




























