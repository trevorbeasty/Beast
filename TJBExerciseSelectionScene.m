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

//// core

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, strong) NSMutableArray *contentExercisesArray;
//@property (strong) NSMutableArray *filteredExercises;

// callback

@property (copy) void(^callbackBlock)(TJBExercise *);

// IBOutlet

@property (weak, nonatomic) IBOutlet UIButton *addNewExerciseButton;
@property (weak, nonatomic) IBOutlet UITableView *exerciseTableView;
@property (weak, nonatomic) IBOutlet UIButton *leftBarButton;
@property (weak, nonatomic) IBOutlet UIButton *rightBarButton;
@property (weak, nonatomic) IBOutlet UILabel *mainTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *exerciseLabel;
@property (weak, nonatomic) IBOutlet UITextField *exerciseTextField;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *categorySegmentedControl;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *exerciseAdditionConstraint;
@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UIView *exerciseAdditionContainer;
@property (weak, nonatomic) IBOutlet UIView *titleBarContainer;
@property (weak, nonatomic) IBOutlet UIButton *addAndSelectButton;
//@property (weak, nonatomic) IBOutlet UITextField *exerciseSeachTextField;
//@property (weak, nonatomic) IBOutlet UILabel *searchLabel;
//@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchFieldTopSpaceConstr;
//@property (weak, nonatomic) IBOutlet UILabel *exerciseNameLabel;
//@property (weak, nonatomic) IBOutlet UILabel *dateLastExecutedLabel;
//@property (weak, nonatomic) IBOutlet UILabel *thinDividerLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *normalBrowsingExerciseSC;
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;

//@property (strong) TJBExerciseSelectionTitleCell *titleCell;
@property (weak, nonatomic) IBOutlet UILabel *secondBarLabel;


// IBAction

- (IBAction)didPressAddNewExercise:(id)sender;
- (IBAction)didPressLeftBarButton:(id)sender;
- (IBAction)didPressAddButton:(id)sender;
- (IBAction)didPressAddAndSelect:(id)sender;
- (IBAction)didPressSearchButton:(id)sender;


@end

static NSString * const cellReuseIdentifier = @"basicCell";

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

- (void)viewDidLoad{
    
    self.exerciseAdditionContainer.hidden = YES;
    self.searchTextField.hidden = YES;
    
    [self configureTableView];
    
    [self createFetchedResultsController];
    
    [self browsingSCValueDidChange]; // called to force the controller to create the array the table view needs
    
    [self viewAesthetics];
    
    [self configureInitialControlPosition];
    
    [self addTapGestureRecognizerToViewForKeyboardNotification];
    
    [self registerForCoreDataNotifications];
    
    [self configureNormalBrowsingExerciseSC];
    
    [self configureSearchTextFieldNotification];
    
}

- (void)configureSearchTextFieldNotification{
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(deriveExerciseContentBasedOnSearch)
                                                 name: UITextFieldTextDidChangeNotification
                                               object: self.searchTextField];
    
    self.searchTextField.delegate = self;
    
}

- (void)configureNormalBrowsingExerciseSC{
    
    [self.normalBrowsingExerciseSC addTarget: self
                                      action: @selector(browsingSCValueDidChange)
                            forControlEvents: UIControlEventValueChanged];
    
}


- (void)addTapGestureRecognizerToViewForKeyboardNotification{
    
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
    
}

- (void)configureInitialControlPosition{
    
    [self.view insertSubview: self.exerciseAdditionContainer
                belowSubview: self.titleBarContainer];
    
    self.exerciseAdditionConstraint.constant = -1 * totalAniDist;
    
}

- (void)registerForCoreDataNotifications{
    
    //// configure managed context notification for updating
    
    NSManagedObjectContext *moc = [[CoreDataController singleton] moc];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(updateFetchedResultsController)
                                                 name: NSManagedObjectContextDidSaveNotification
                                               object: moc];
    
}

- (void)viewDidAppear:(BOOL)animated{
    
    self.exerciseAdditionContainer.hidden = NO;
    
}



- (void)createFetchedResultsController{
    
    if (self.fetchedResultsController){
        
        self.fetchedResultsController = nil;
        
    }
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName: @"Exercise"];
    
    // only apply the compount predicate if the exercise search text field has a non blank entry
    
    NSPredicate *noPlaceholderExercisesPredicate = [NSPredicate predicateWithFormat: @"category.name != %@",
                                                    @"Placeholder"];
    
    request.predicate = noPlaceholderExercisesPredicate;
    
//    if ([self.exerciseSeachTextField.text isEqualToString: @""]){
//        
//        
//        
//    } else{
//        
//        NSPredicate *searchFilterPredicate = [NSPredicate predicateWithFormat: @"name CONTAINS[cd] %@",
//                                              self.exerciseSeachTextField.text];
//        
//        NSCompoundPredicate *compPred = [NSCompoundPredicate andPredicateWithSubpredicates: @[noPlaceholderExercisesPredicate,
//                                                                                              searchFilterPredicate]];
//        
//        request.predicate = compPred;
//        
//    }
    
    NSSortDescriptor *nameSort = [NSSortDescriptor sortDescriptorWithKey: @"name"
                                                               ascending: YES];
    
//    NSSortDescriptor *categorySort = [NSSortDescriptor sortDescriptorWithKey: @"category.name"
//                                                                   ascending: YES];
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
    
    self.view.backgroundColor = [[TJBAestheticsController singleton] offWhiteColor];
    
    // table view header labels
    
//    NSArray *columnLabels = @[self.exerciseNameLabel, self.dateLastExecutedLabel];
//    for (UILabel *lab in columnLabels){
//        
//        lab.backgroundColor = [UIColor clearColor];
//        lab.textColor = [UIColor darkGrayColor];
//        lab.font = [UIFont boldSystemFontOfSize: 15];
//        
//    }
//    
//    self.thinDividerLabel.backgroundColor = [UIColor darkGrayColor];
//    self.thinDividerLabel.textColor = [UIColor darkGrayColor];
    
    // table view
    
    self.exerciseTableView.backgroundColor = [[TJBAestheticsController singleton] yellowNotebookColor];
    
    // new exercise buttons
    
    self.addNewExerciseButton.backgroundColor = [[TJBAestheticsController singleton] blueButtonColor];
    
    // labels
    
    NSArray *exerciseAdditionLabels = @[self.exerciseLabel, self.categoryLabel];
    for (UILabel *label in exerciseAdditionLabels){
        
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize: 20.0];
        label.textColor = [UIColor darkGrayColor];
        
    }
    
    // category segmented control
    
    self.categorySegmentedControl.tintColor = [[TJBAestheticsController singleton] blueButtonColor];
    
    UIFont *categorySelectionFont = [UIFont boldSystemFontOfSize: 15.0];
    
    NSDictionary *info = [NSDictionary dictionaryWithObject: categorySelectionFont
                                                     forKey: NSFontAttributeName];
    
    [self.categorySegmentedControl setTitleTextAttributes: info
                                                 forState: UIControlStateNormal];
    
    // browsing segmented control
    
    self.normalBrowsingExerciseSC.tintColor = [[TJBAestheticsController singleton] blueButtonColor];
    
    // add buttons
    
    NSArray *addButtons = @[self.addButton, self.addAndSelectButton, self.addNewExerciseButton];
    for (UIButton *button in addButtons){
        
        button.backgroundColor = [[TJBAestheticsController singleton] blueButtonColor];
        button.titleLabel.font = [UIFont boldSystemFontOfSize: 20.0];
        [button setTitleColor: [UIColor whiteColor]
                             forState: UIControlStateNormal];
        
    }
    
    
    
    // text fields and search label
    
    self.exerciseTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    
    NSArray *textFields = @[self.exerciseTextField];
    for (UITextField *tf in textFields){
        
        CALayer *layer = tf.layer;
        layer.masksToBounds = YES;
        layer.cornerRadius = 8.0;
        layer.borderWidth = 1;
        layer.borderColor = [[UIColor darkGrayColor] CGColor];
        
        tf.font = [UIFont systemFontOfSize: 20.0];
        tf.textColor = [UIColor blackColor];
        
    }
    
    // bar buttons
    
    NSArray *buttons = @[self.leftBarButton, self.searchButton];
    for (UIButton *b in buttons){
        
        b.backgroundColor = [UIColor clearColor];
        b.titleLabel.font = [UIFont boldSystemFontOfSize: 15.0];
        [b setTitleColor: [[TJBAestheticsController singleton] blueButtonColor]
                forState: UIControlStateNormal];
        
    }
    
    self.leftBarButton.backgroundColor = [UIColor darkGrayColor];
    
    // search text field
    
    self.searchTextField.layer.borderColor = [UIColor whiteColor].CGColor;
    self.searchTextField.layer.borderWidth = 1.0;
    self.searchTextField.font = [UIFont systemFontOfSize: 20.0];
    self.searchTextField.textColor = [UIColor whiteColor];
    self.searchTextField.textAlignment = NSTextAlignmentCenter;
    self.searchTextField.layer.cornerRadius = 8.0;
    self.searchTextField.layer.masksToBounds = YES;
    
    // second bar label
    
    self.secondBarLabel.backgroundColor = [UIColor darkGrayColor];
    self.secondBarLabel.text = @"";
    
//    CALayer *estfLayer = self.exerciseSeachTextField.layer;
//    estfLayer.borderWidth = 2.0;
//    estfLayer.borderColor = [UIColor lightGrayColor].CGColor;
//    
//    self.exerciseSeachTextField.font = [UIFont systemFontOfSize: 20];
//    self.exerciseSeachTextField.textColor = [UIColor blackColor];
//    
//    self.searchLabel.backgroundColor = [UIColor lightGrayColor];
//    self.searchLabel.font = [UIFont boldSystemFontOfSize: 20.0];
//    self.searchLabel.textColor = [UIColor whiteColor];
    
}

- (void)configureTableView{
    
    NSArray *titleButtons = @[self.leftBarButton, self.rightBarButton];
    for (UIButton *button in titleButtons){
        
        button.backgroundColor = [UIColor darkGrayColor];
        button.titleLabel.font = [UIFont boldSystemFontOfSize: 15.0];
        [button setTitleColor: [[TJBAestheticsController singleton] blueButtonColor]
                     forState: UIControlStateNormal];
        
    }
    
    self.exerciseTableView.bounces = NO;
    
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


#pragma mark - Exercise Browsing

- (void)browsingSCValueDidChange{
    
    NSString *filterString;
    
    switch (self.normalBrowsingExerciseSC.selectedSegmentIndex) {
        case 0:
            filterString = @"Push";
            break;
            
        case 1:
            filterString = @"Pull";
            break;
            
        case 2:
            filterString = @"Legs";
            break;
            
        case 3:
            filterString = @"Other";
            
        default:
            break;
    }
    
    NSMutableArray *returnArray = [[NSMutableArray alloc] init];
    
    NSPredicate *categoryFilter = [NSPredicate predicateWithFormat: @"category.name == %@",
                                   filterString];
    
    returnArray = [self.fetchedResultsController.fetchedObjects mutableCopy];
    
    [returnArray filterUsingPredicate: categoryFilter];
    
    self.contentExercisesArray = returnArray;
    
    [self.exerciseTableView reloadData];
    
}

- (void)deriveExerciseContentBasedOnSearch{
    
    NSString *searchString = self.searchTextField.text;
    
    NSMutableArray *allExercises = [self.fetchedResultsController.fetchedObjects mutableCopy];
    
    NSPredicate *searchFilterPredicate = [NSPredicate predicateWithFormat: @"name CONTAINS[cd] %@", searchString];
    NSPredicate *noPlaceholderExercisesPredicate = [NSPredicate predicateWithFormat: @"category.name != %@", @"Placeholder"];
    
    NSCompoundPredicate *compPred = [NSCompoundPredicate andPredicateWithSubpredicates: @[noPlaceholderExercisesPredicate,
                                                                                          searchFilterPredicate]];
    
    NSArray *filteredExercises = [allExercises filteredArrayUsingPredicate: compPred];
    self.contentExercisesArray = [filteredExercises mutableCopy];
    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.exerciseTableView reloadData];
//    });
//    
//    dispatch_async(dispatch_get_main_queue(), ^{
//        [self.exerciseTableView reloadData];
//    });
    
    [self.exerciseTableView reloadData];
    
//    [self.titleCell.searchTextField becomeFirstResponder];
    
//    // cannot reload the title cell because doing so causes the text field to be dismissed
//    
//    NSInteger contentCount = filteredExercises.count;
//    NSMutableArray *indexPathCollector = [[NSMutableArray alloc] init];
//    for (int i = 0; i < contentCount; i++){
//        
//        NSIndexPath *iterativePath = [NSIndexPath indexPathForRow: i + 1
//                                                        inSection: 0];
//        
//        [indexPathCollector addObject: iterativePath];
//        
//    }
//    
//    [self.exerciseTableView reloadRowsAtIndexPaths: indexPathCollector
//                                  withRowAnimation: UITableViewRowAnimationAutomatic];

}



#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
//    NSUInteger sectionCount = [[[self fetchedResultsController] sections] count];
//    
//    NSLog(@"%lu", sectionCount);
//    
//    // a no data cell will be shown if there are no exercises in the resulting fetched results controller
//    
//    if (sectionCount == 0){
//        
//        return 1;
//        
//    } else{
//        
//        return sectionCount;
//        
//    }
    
    return 1;

}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    NSInteger contentCellCount = self.contentExercisesArray.count;
    
    if (contentCellCount == 0){
        
        return 2;
        
    } else{
        
        return contentCellCount + 1;
        
    }
 
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger contentCellCount = self.contentExercisesArray.count;
    
    if (indexPath.row == 0){
        
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
            
            NSInteger adjustedIndex = indexPath.row - 1;
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
            
//            NSArray *labels = @[cell.exerciseNameLabel, cell.dateLabel];
//            for (UILabel *label in labels){
//                
//                label.font = [UIFont boldSystemFontOfSize: 15];
//                label.textColor = [UIColor blackColor];
//                label.backgroundColor = [UIColor clearColor];
//            
//            }
            
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
    
    if (indexPath.row != 0){
        
        TJBExercise *selectedExercise = self.contentExercisesArray[indexPath.row - 1];
        
        self.callbackBlock(selectedExercise);
        
    }
 
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
//    
//    NSUInteger sectionCount = [[[self fetchedResultsController] sections] count];
//    
//    if (sectionCount == 0){
//        
//        return nil;
//        
//    } else{
//        
//        UILabel *label = [[UILabel alloc] init];
//        label.backgroundColor = [UIColor lightGrayColor];
//        label.textColor = [UIColor whiteColor];
//        label.font = [UIFont boldSystemFontOfSize: 20.0];
//        label.textAlignment = NSTextAlignmentCenter;
//        
//        id<NSFetchedResultsSectionInfo> sectionInfo = [[self fetchedResultsController] sections][section];
//        label.text = [sectionInfo name];
//        
//        return label;
//        
//    }
//
//}

//- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
//    
//    NSUInteger sectionCount = [[[self fetchedResultsController] sections] count];
//    
//    if (sectionCount == 0){
//        
//        return 0;
//        
//    } else{
//        
//        return 50;
//        
//    }
//    
//
//    
//}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat titleCellHeight = 90;
    
    NSInteger contentCellCount = self.contentExercisesArray.count;
    
    if (indexPath.row == 0){
        
        return titleCellHeight;
        
    } else{
        
        if (contentCellCount == 0){
            
            return self.exerciseTableView.frame.size.height - titleCellHeight;
            
        } else{
            
            
            return 60;
        }
        
    }

    
}

#pragma mark - Button Actions

- (IBAction)didPressAddNewExercise:(id)sender {
    
    if (_exerciseAdditionActive == YES){
        
        [self toggleButtonControlsToDefaultDisplay];
        
    } else{
        
        [self toggleButtonControlsToAdvancedDisplay];
        
    }
    
}

- (IBAction)didPressLeftBarButton:(id)sender{
    
    [self dismissViewControllerAnimated: NO
                             completion: nil];
    
}

- (IBAction)didPressAddButton:(id)sender{
    
    //// action is dependent upon several factors.  Depends on whether user it trying to create an existing exercise, has left the exercise text field blank, or has entered a valid new exercise name
    
    // conditional actions
    
    NSString *exerciseString = self.exerciseTextField.text;
    
    UIAlertAction *continueAction = [UIAlertAction actionWithTitle: @"Continue"
                                                             style: UIAlertActionStyleDefault
                                                           handler: nil];
    
    BOOL exerciseExists = [[CoreDataController singleton] realizedSetExerciseExistsForName: exerciseString];
    
    if (exerciseExists){
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"Invalid Entry"
                                                                       message: @"This exercise already exists"
                                                                preferredStyle: UIAlertControllerStyleAlert];
        
        [alert addAction: continueAction];
        
        [self presentViewController: alert
                           animated: YES
                         completion: nil];
        
    } else if([exerciseString isEqualToString: @""]){
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"Invalid Entry"
                                                                       message: @"Exercise entry is blank"
                                                                preferredStyle: UIAlertControllerStyleAlert];
        
        [alert addAction: continueAction];
        
        [self presentViewController: alert
                           animated: YES
                         completion: nil];
        
    } else{
        
        [self addNewExerciseAndClearExerciseTextField];
        
    }
    
}

- (TJBExercise *)addNewExerciseAndClearExerciseTextField{
    
    //// add the new exercise leverage CoreDataController methods.  Save the context when done
    
    CoreDataController *coreDataController = [CoreDataController singleton];
    
    NSString *newExerciseName = self.exerciseTextField.text;
    
    NSNumber *wasNewlyCreated = nil;
    TJBExercise *newExercise = [coreDataController exerciseForName: newExerciseName
                                                   wasNewlyCreated: &wasNewlyCreated
                                       createAsPlaceholderExercise: [NSNumber numberWithBool: NO]];
    
    newExercise.category = [[CoreDataController singleton] exerciseCategoryForName: [self selectedCategory]];
    
    [[CoreDataController singleton] saveContext];
    
    // need to use notification center so all affected fetched results controllers can perform fetch and update table views
    
    [[NSNotificationCenter defaultCenter] postNotificationName: ExerciseDataChanged
                                                        object: nil];
    
    // clear the exercise text field
    
    self.exerciseTextField.text = @"";
    
    return newExercise;
    
}

- (IBAction)didPressAddAndSelect:(id)sender {
    
    //// action is dependent upon several factors.  Depends on whether user it trying to create an existing exercise, has left the exercise text field blank, or has entered a valid new exercise name
    
    // conditional actions
    
    NSString *exerciseString = self.exerciseTextField.text;
    
    UIAlertAction *continueAction = [UIAlertAction actionWithTitle: @"Continue"
                                                             style: UIAlertActionStyleDefault
                                                           handler: nil];
    
    BOOL exerciseExists = [[CoreDataController singleton] realizedSetExerciseExistsForName: exerciseString];
    
    if (exerciseExists){
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"Invalid Entry"
                                                                       message: @"This exercise already exists"
                                                                preferredStyle: UIAlertControllerStyleAlert];
        
        [alert addAction: continueAction];
        
        [self presentViewController: alert
                           animated: YES
                         completion: nil];
        
    } else if([exerciseString isEqualToString: @""]){
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"Invalid Entry"
                                                                       message: @"Exercise entry is blank"
                                                                preferredStyle: UIAlertControllerStyleAlert];
        
        [alert addAction: continueAction];
        
        [self presentViewController: alert
                           animated: YES
                         completion: nil];
        
    } else{
        
        TJBExercise *exercise = [self addNewExerciseAndClearExerciseTextField];
        
        self.callbackBlock(exercise);
        
    }
}

- (IBAction)didPressSearchButton:(id)sender{
    
    if (_searchIsActive == NO){
        
        [self.searchButton setTitle: @"Back"
                           forState: UIControlStateNormal];
        
        self.normalBrowsingExerciseSC.enabled = NO;

        [self deriveExerciseContentBasedOnSearch];
        
        self.searchTextField.hidden = NO;
        [self.searchTextField becomeFirstResponder];
        
        _searchIsActive = YES;
    
    } else{
        
        [self.searchButton setTitle: @"Search"
                           forState: UIControlStateNormal];
        
        self.normalBrowsingExerciseSC.enabled = YES;
        
        self.searchTextField.hidden = YES;
        [self.searchTextField resignFirstResponder];
        
        _searchIsActive = NO;
        
        [self browsingSCValueDidChange];
        
    }
    
}

#pragma mark - Animation

static CGFloat const totalAniDist = 246.0;
//static float const totalAniDur = .6;

- (void)toggleButtonControlsToAdvancedDisplay{
    
//    // the animation is completed in two parts.  First, the exercise addition container slides down over the search bar.  Next, the container and table view slide down together.  The search text field should be hidden / disabled after it is covered
//    
//    self.exerciseAdditionContainer.hidden = NO;
//    
//    // stack view appropriately - sibling views must be configured appropriately so that the correct view is displayed as views slide over one another
//    
//    [self.view insertSubview: self.titleBarContainer
//                aboveSubview: self.exerciseAdditionContainer];
//    
//    NSArray *coveredViews = @[self.searchLabel,
//                              self.exerciseSeachTextField,
//                              self.dateLastExecutedLabel];
//    for (UIView *cv in coveredViews){
//        
//        [self.view sendSubviewToBack: cv];
//        
//    }
//    
//    // the second animation is defined here. It is executed upon completion of the first animation.  It slides down the table view and addition container to their final, advanced positions
//    
//    __weak TJBExerciseSelectionScene *weakSelf = self;
//    
//    // need to define this here so that I can make the two animations appear to run at the same speed
//    
//    CGFloat partialAniDist = 8 + self.exerciseSeachTextField.frame.size.height + 8 + self.exerciseNameLabel.frame.size.height + 6;
//    
//    void (^secondAnimation)(BOOL) = ^(BOOL firstAnimationCompleted){
//        
//        // hide the exercise search objects
//        
//        for (UIView *cv in coveredViews){
//            
//            cv.hidden = YES;
//            
//        }
//        
//        [UIView animateWithDuration: totalAniDur * (totalAniDist - partialAniDist) / totalAniDist
//                         animations: ^{
//                             
//                             // give the container view its final position, where it is fully showing
//                             // must grab the current value of the constraint so that I can make the views slide down the difference
//                             // the old constant formula is grabbed from the first animation.  It cannot be accessed via the frame property because this block captures
//                             
//                             weakSelf.exerciseAdditionConstraint.constant = 0;
//                             CGFloat animationConst = totalAniDist - partialAniDist;
//                             
//                             // float the addition container down and slide the table view down (while shrinking its height)
//                             
//                             // exercise table view
//                             
//                             CGRect currentTVFrame = weakSelf.exerciseTableView.frame;
//                             CGRect newTVFrame = CGRectMake(currentTVFrame.origin.x, currentTVFrame.origin.y + animationConst, currentTVFrame.size.width, currentTVFrame.size.height - animationConst);
//                             weakSelf.exerciseTableView.frame = newTVFrame;
//                             
//                             // addition container
//                             
//                             CGRect currentAddContFrame = weakSelf.exerciseAdditionContainer.frame;
//                             CGRect newAddContFrame = CGRectMake(currentAddContFrame.origin.x, currentAddContFrame.origin.y + animationConst, currentAddContFrame.size.width, currentAddContFrame.size.height);
//                             weakSelf.exerciseAdditionContainer.frame = newAddContFrame;
//                             
//                         }];
//    };
//    
//    // the inititial animation
//    
//    [UIView animateWithDuration: ( partialAniDist / totalAniDist) * totalAniDur
//                     animations: ^{
//                         
//                         // first the exercise addition container slides down over the search text field.  Then the table view shifts down with it.  Layout constraints define ending positions for each animation and the specified animation describes how the object travels to that end position
//                         
//                         // this gives the exercise search field the correct position relative to the exercise addition container. Given the containers final position, this places the seach field such that its final location is the same as its initial location
//
//                         CGFloat constraintConst = -1 * (partialAniDist - 8);
//                         self.searchFieldTopSpaceConstr.constant = constraintConst;
//                         
//                         // this constraint describes the exercise addition container's position relative to the title container.  This addition container is initially behind the title container
//                         
//                         self.exerciseAdditionConstraint.constant = -1 * (self.exerciseAdditionContainer.frame.size.height - partialAniDist);
//                         
//                         // this shows an animation of the addition container sliding down to its final position
//                         
//                         NSArray *views = @[self.exerciseAdditionContainer];
//                         
//                         for (UIView *view in views){
//                             
//                             CGRect currentFrame = view.frame;
//                             CGRect newFrame = CGRectMake(currentFrame.origin.x, currentFrame.origin.y + partialAniDist, currentFrame.size.width, currentFrame.size.height);
//                             view.frame = newFrame;
//  
//                         }
//                         
//                     }
//                     completion: secondAnimation];
//    
//    _exerciseAdditionActive = YES;
//    
//    [self.addNewExerciseButton setTitle: @"Done"
//                               forState: UIControlStateNormal];
    
}

- (void)toggleButtonControlsToDefaultDisplay{
    
    // unhide the exercise search controls
//    
//    NSArray *coveredViews = @[self.searchLabel,
//                              self.exerciseSeachTextField,
//                              self.exerciseNameLabel,
//                              self.thinDividerLabel,
//                              self.dateLastExecutedLabel];
//    for (UIView *cv in coveredViews){
//        
//        cv.hidden = NO;
//        
//    }
//
//    CGFloat partialAniDist = 8 + self.exerciseSeachTextField.frame.size.height + 8 + self.exerciseNameLabel.frame.size.height + 6;
//    
//    // second animation
//    
//    __weak TJBExerciseSelectionScene *weakSelf = self;
//    
//    void (^secondAnimation)(BOOL) = ^(BOOL firstAnimationCompleted){
//        
//        [UIView animateWithDuration: ( partialAniDist / totalAniDist) * totalAniDur
//                         animations: ^{
//                             
//                             weakSelf.searchFieldTopSpaceConstr.constant = 8;
//                             weakSelf.exerciseAdditionConstraint.constant = -1 * totalAniDist;
//                             
//                             CGFloat viewTranslation = partialAniDist;
//                             
//                             CGRect currentFrame = weakSelf.exerciseAdditionContainer.frame;
//                             CGRect newFrame = CGRectMake(currentFrame.origin.x, currentFrame.origin.y - viewTranslation, currentFrame.size.width, currentFrame.size.height);
//                             weakSelf.exerciseAdditionContainer.frame = newFrame;
//                             
//                         }];
//        
//    };
//    
//    // first animation
//    
//    [UIView animateWithDuration: totalAniDur * (totalAniDist - partialAniDist) / totalAniDist
//                     animations: ^{
//                         
//                         self.exerciseAdditionConstraint.constant = -1 * (self.exerciseAdditionContainer.frame.size.height - partialAniDist);
//                         
//                         CGFloat constraintConst = -1 * (partialAniDist - 8);
//                         self.searchFieldTopSpaceConstr.constant = constraintConst;
//                         
//                         CGFloat viewVertTranslation = totalAniDist - partialAniDist;
//                         
//                         NSArray *views = @[self.exerciseAdditionContainer];
//                         
//                         for (UIView *view in views){
//                             
//                             CGRect currentFrame = view.frame;
//                             CGRect newFrame = CGRectMake(currentFrame.origin.x, currentFrame.origin.y - viewVertTranslation, currentFrame.size.width, currentFrame.size.height);
//                             view.frame = newFrame;
//                             
//                         }
//                         
//                         CGRect currentTVFrame = self.exerciseTableView.frame;
//                         CGRect newTVFrame = CGRectMake(currentTVFrame.origin.x, currentTVFrame.origin.y - viewVertTranslation, currentTVFrame.size.width, currentTVFrame.size.height + viewVertTranslation);
//                         self.exerciseTableView.frame = newTVFrame;
//                         
//                     }
//                     completion: secondAnimation];
//    
//    _exerciseAdditionActive = NO;
//    [self.addNewExerciseButton setTitle: @"Add New Exercise"
//                                forState: UIControlStateNormal];
    
}

#pragma  mark - Convenience

- (NSString *)selectedCategory{
    
    NSString *selectedCategory;
    
    NSInteger categoryIndex = self.categorySegmentedControl.selectedSegmentIndex;
    
    switch (categoryIndex){
        case 0:
            selectedCategory = @"Push";
            break;
            
        case 1:
            selectedCategory = @"Pull";
            break;
            
        case 2:
            selectedCategory = @"Legs";
            break;
            
        case 3:
            selectedCategory = @"Other";
            break;
            
        default:
            break;
            
    }
    
    return selectedCategory;
    
}

#pragma mark - Gesture Recognizer

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
////    if ([self.exerciseSeachTextField isFirstResponder]){
////        
////        [self.exerciseSeachTextField resignFirstResponder];
////        
////    }
//}

#pragma mark - <UITextFieldDelegate>

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [textField resignFirstResponder];
    
    return YES;
    
}



#pragma mark - Core Data

- (void)updateFetchedResultsController{
    
    //// refresh fetched managed objects and all trickle-down
    
    [self createFetchedResultsController];
    
    [self.exerciseTableView reloadData];
    
}



@end





































