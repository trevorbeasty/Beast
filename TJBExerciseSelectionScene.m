//
//  TJBExerciseSelectionScene.m
//  Beast
//
//  Created by Trevor Beasty on 12/19/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import "TJBExerciseSelectionScene.h"

#import "CoreDataController.h"

#import "TJBNewExerciseCreationVC.h"

#import "TJBAestheticsController.h"

@interface TJBExerciseSelectionScene () <UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate>

{
    
    // state
    
    BOOL _exerciseAdditionActive;
    
}

//// core

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;
@property (strong) NSMutableArray *filteredExercises;

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
@property (weak, nonatomic) IBOutlet UITextField *exerciseSeachTextField;
@property (weak, nonatomic) IBOutlet UILabel *searchLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *searchFieldTopSpaceConstr;

// IBAction

- (IBAction)didPressAddNewExercise:(id)sender;
- (IBAction)didPressLeftBarButton:(id)sender;
- (IBAction)didPressAddButton:(id)sender;
- (IBAction)didPressAddAndSelect:(id)sender;


@end

static NSString * const cellReuseIdentifier = @"basicCell";

@implementation TJBExerciseSelectionScene

#pragma mark - Instantiation

- (instancetype)initWithCallbackBlock:(void (^)(TJBExercise *))block{
    
    self = [super init];
    
    self.callbackBlock = block;
    
    _exerciseAdditionActive = NO;
    
    return self;
    
}

#pragma mark - View Life Cycle

- (void)viewDidLoad{
    
    self.exerciseAdditionContainer.hidden = YES;
    
    [self configureTableView];
    
    [self createFetchedResultsController];
    
    [self viewAesthetics];
    
    [self configureInitialControlPosition];
    
    [self addTapGestureRecognizerToViewForKeyboardNotification];
    
    [self registerForCoreDataNotifications];
    
    [self configureExerciseFilterTextField];
    
}

- (void)configureExerciseFilterTextField{
    
    self.exerciseSeachTextField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.exerciseSeachTextField.autocorrectionType = UITextAutocorrectionTypeNo;
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(updateFetchedResultsController)
                                                 name: UITextFieldTextDidChangeNotification
                                               object: self.exerciseSeachTextField];
    
}

- (void)addTapGestureRecognizerToViewForKeyboardNotification{
    
    //// add gesture recognizer to the view.  It will be used to dismiss the keyboard if the touch is not in the keyboard or text field
    //// also register for the UIKeyboardDidShowNotification so that the frame of the keyboard can be stored for later use in analyzing touches
    
    // tap GR
    
    UITapGestureRecognizer *singleTapGR = [[UITapGestureRecognizer alloc] initWithTarget: self
                                                                                  action: @selector(didSingleTap:)];
    
    singleTapGR.numberOfTapsRequired = 1;
    singleTapGR.cancelsTouchesInView = NO;
    singleTapGR.delaysTouchesBegan = NO;
    singleTapGR.delaysTouchesEnded = NO;
    
    [self.view addGestureRecognizer: singleTapGR];
    
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
    
    if ([self.exerciseSeachTextField.text isEqualToString: @""]){
        
        request.predicate = noPlaceholderExercisesPredicate;
        
    } else{
        
        NSPredicate *searchFilterPredicate = [NSPredicate predicateWithFormat: @"name CONTAINS[cd] %@",
                                              self.exerciseSeachTextField.text];
        
        NSCompoundPredicate *compPred = [NSCompoundPredicate andPredicateWithSubpredicates: @[noPlaceholderExercisesPredicate,
                                                                                              searchFilterPredicate]];
        
        request.predicate = compPred;
        
    }
    
    NSSortDescriptor *nameSort = [NSSortDescriptor sortDescriptorWithKey: @"name"
                                                               ascending: YES];
    
    NSSortDescriptor *categorySort = [NSSortDescriptor sortDescriptorWithKey: @"category.name"
                                                                   ascending: YES];
    [request setSortDescriptors: @[categorySort, nameSort]];
    
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
    
    // add buttons
    
    NSArray *addButtons = @[self.addButton, self.addAndSelectButton];
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
    
    CALayer *estfLayer = self.exerciseSeachTextField.layer;
    estfLayer.borderWidth = 2.0;
    estfLayer.borderColor = [UIColor lightGrayColor].CGColor;
    
    self.exerciseSeachTextField.font = [UIFont systemFontOfSize: 20];
    self.exerciseSeachTextField.textColor = [UIColor blackColor];
    
    self.searchLabel.backgroundColor = [UIColor lightGrayColor];
    self.searchLabel.font = [UIFont boldSystemFontOfSize: 20.0];
    self.searchLabel.textColor = [UIColor whiteColor];
    
}

- (void)configureTableView
{
    [self.exerciseTableView registerClass: [UITableViewCell class]
                   forCellReuseIdentifier: cellReuseIdentifier];
    
    NSArray *titleButtons = @[self.leftBarButton, self.rightBarButton];
    for (UIButton *button in titleButtons){
        
        button.backgroundColor = [UIColor darkGrayColor];
        button.titleLabel.font = [UIFont boldSystemFontOfSize: 15.0];
        [button setTitleColor: [[TJBAestheticsController singleton] blueButtonColor]
                     forState: UIControlStateNormal];
        
    }
    
    self.mainTitleLabel.backgroundColor = [UIColor darkGrayColor];
    self.mainTitleLabel.font = [UIFont boldSystemFontOfSize: 20.0];
    self.mainTitleLabel.textColor = [UIColor whiteColor];
    
}



#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSUInteger sectionCount = [[[self fetchedResultsController] sections] count];
    return sectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    id<NSFetchedResultsSectionInfo> sectionInfo = [[self fetchedResultsController] sections][section];
    NSUInteger numberOfObjects = [sectionInfo numberOfObjects];
    return numberOfObjects;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [self.exerciseTableView dequeueReusableCellWithIdentifier: cellReuseIdentifier];
    
    TJBExercise *exercise = [self.fetchedResultsController objectAtIndexPath: indexPath];
    
    cell.textLabel.text = exercise.name;
    cell.textLabel.font = [UIFont systemFontOfSize: 15.0];
    cell.backgroundColor = [UIColor clearColor];
    cell.textLabel.textColor = [UIColor blackColor];
    
    
    return cell;
}

#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    TJBExercise *exercise = [self.fetchedResultsController objectAtIndexPath: indexPath];
    
    self.callbackBlock(exercise);
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    
    UILabel *label = [[UILabel alloc] init];
    label.backgroundColor = [UIColor lightGrayColor];
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont boldSystemFontOfSize: 20.0];
    label.textAlignment = NSTextAlignmentCenter;
    
    id<NSFetchedResultsSectionInfo> sectionInfo = [[self fetchedResultsController] sections][section];
    label.text = [sectionInfo name];
    
    return label;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 50;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 50;
    
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

#pragma mark - Animation

static CGFloat const totalAniDist = 246.0;
static float const totalAniDur = .3;

- (void)toggleButtonControlsToAdvancedDisplay{
    
    // the animation is completed in two parts.  First, the exercise addition container slides down over the search bar.  Next, the container and table view slide down together.  The search text field should be hidden / disabled after it is covered
    
    self.exerciseAdditionContainer.hidden = NO;
    
    // stack view appropriately - sibling views must be configured appropriately so that the correct view is displayed as views slide over one another
    
    [self.view insertSubview: self.titleBarContainer
                aboveSubview: self.exerciseAdditionContainer];
    [self.view sendSubviewToBack: self.searchLabel];
    [self.view sendSubviewToBack: self.exerciseSeachTextField];
    
    // the second animation is defined here. It is executed upon completion of the first animation.  It slides down the table view and addition container to their final, advanced positions
    
    __weak TJBExerciseSelectionScene *weakSelf = self;
    
    // need to define this here so that I can make the two animations appear to run at the same speed
    
    CGFloat partialAniDist = 14 + self.exerciseSeachTextField.frame.size.height;
    
    void (^secondAnimation)(BOOL) = ^(BOOL firstAnimationCompleted){
        
        // hide the exercise search objects
        
        self.exerciseSeachTextField.hidden = YES;
        self.searchLabel.hidden = YES;
        
        [UIView animateWithDuration: totalAniDur * (totalAniDist - partialAniDist) / totalAniDist
                         animations: ^{
                             
                             // give the container view its final position, where it is fully showing
                             // must grab the current value of the constraint so that I can make the views slide down the difference
                             // the old constant formula is grabbed from the first animation.  It cannot be accessed via the frame property because this block captures
                             
                             weakSelf.exerciseAdditionConstraint.constant = 0;
                             CGFloat animationConst = totalAniDist - partialAniDist;
                             
                             // float the addition container down and slide the table view down (while shrinking its height)
                             
                             // exercise table view
                             
                             CGRect currentTVFrame = weakSelf.exerciseTableView.frame;
                             CGRect newTVFrame = CGRectMake(currentTVFrame.origin.x, currentTVFrame.origin.y + animationConst, currentTVFrame.size.width, currentTVFrame.size.height - animationConst);
                             weakSelf.exerciseTableView.frame = newTVFrame;
                             
                             // addition container
                             
                             CGRect currentAddContFrame = weakSelf.exerciseAdditionContainer.frame;
                             CGRect newAddContFrame = CGRectMake(currentAddContFrame.origin.x, currentAddContFrame.origin.y + animationConst, currentAddContFrame.size.width, currentAddContFrame.size.height);
                             weakSelf.exerciseAdditionContainer.frame = newAddContFrame;
                             
                         }];
    };
    
    // the inititial animation
    
    [UIView animateWithDuration: ( partialAniDist / totalAniDist) * totalAniDur
                     animations: ^{
                         
                         // first the exercise addition container slides down over the search text field.  Then the table view shifts down with it.  Layout constraints define ending positions for each animation and the specified animation describes how the object travels to that end position
                         
                         // this gives the exercise search field the correct position relative to the exercise addition container. Given the containers final position, this places the seach field such that its final location is the same as its initial location

                         CGFloat constraintConst = -1 * (6 + self.exerciseSeachTextField.frame.size.height);
                         self.searchFieldTopSpaceConstr.constant = constraintConst;
                         
                         // this constraint describes the exercise addition container's position relative to the title container.  This addition container is initially behind the title container
                         
                         self.exerciseAdditionConstraint.constant = -1 * (self.exerciseAdditionContainer.frame.size.height - partialAniDist);
                         
                         // this shows an animation of the addition container sliding down to its final position
                         
                         NSArray *views = @[self.exerciseAdditionContainer];
                         
                         for (UIView *view in views){
                             
                             CGRect currentFrame = view.frame;
                             CGRect newFrame = CGRectMake(currentFrame.origin.x, currentFrame.origin.y + partialAniDist, currentFrame.size.width, currentFrame.size.height);
                             view.frame = newFrame;
  
                         }
                         
                     }
                     completion: secondAnimation];
    
    _exerciseAdditionActive = YES;
    
    [self.addNewExerciseButton setTitle: @"Done"
                               forState: UIControlStateNormal];
    
}

- (void)toggleButtonControlsToDefaultDisplay{
    
    // unhide the exercise search controls
    
    self.exerciseSeachTextField.hidden = NO;
    self.searchLabel.hidden = NO;
    
    CGFloat partialAniDist = 14 + self.exerciseSeachTextField.frame.size.height;
    
    // second animation
    
    __weak TJBExerciseSelectionScene *weakSelf = self;
    
    void (^secondAnimation)(BOOL) = ^(BOOL firstAnimationCompleted){
        
        [UIView animateWithDuration: ( partialAniDist / totalAniDist) * totalAniDur
                         animations: ^{
                             
                             weakSelf.searchFieldTopSpaceConstr.constant = 8;
                             weakSelf.exerciseAdditionConstraint.constant = -1 * totalAniDist;
                             
                             CGFloat viewTranslation = partialAniDist;
                             
                             CGRect currentFrame = weakSelf.exerciseAdditionContainer.frame;
                             CGRect newFrame = CGRectMake(currentFrame.origin.x, currentFrame.origin.y - viewTranslation, currentFrame.size.width, currentFrame.size.height);
                             weakSelf.exerciseAdditionContainer.frame = newFrame;
                             
                         }];
        
    };
    
    // first animation
    
    [UIView animateWithDuration: totalAniDur * (totalAniDist - partialAniDist) / totalAniDist
                     animations: ^{
                         
                         self.exerciseAdditionConstraint.constant = -1 * (self.exerciseAdditionContainer.frame.size.height - partialAniDist);
                         
                         CGFloat viewVertTranslation = self.exerciseAdditionContainer.frame.size.height - partialAniDist;
                         
                         NSArray *views = @[self.exerciseAdditionContainer];
                         
                         for (UIView *view in views){
                             
                             CGRect currentFrame = view.frame;
                             CGRect newFrame = CGRectMake(currentFrame.origin.x, currentFrame.origin.y - viewVertTranslation, currentFrame.size.width, currentFrame.size.height);
                             view.frame = newFrame;
                             
                         }
                         
                         CGRect currentTVFrame = self.exerciseTableView.frame;
                         CGRect newTVFrame = CGRectMake(currentTVFrame.origin.x, currentTVFrame.origin.y - viewVertTranslation, currentTVFrame.size.width, currentTVFrame.size.height + viewVertTranslation);
                         self.exerciseTableView.frame = newTVFrame;
                         
                     }
                     completion: secondAnimation];
    
    _exerciseAdditionActive = NO;
    [self.addNewExerciseButton setTitle: @"Add New Exercise"
                                forState: UIControlStateNormal];
    
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

- (void)didSingleTap:(UIGestureRecognizer *)gr{
    
    //// because this gesture does not register if the touch is in the keyboard or text field, simply have to check if the keyboard is showing, and dismiss it if so
    
    if ([self.exerciseTextField isFirstResponder]){
        
        [self.exerciseTextField resignFirstResponder];
        
    }
    
    if ([self.exerciseSeachTextField isFirstResponder]){
        
        [self.exerciseSeachTextField resignFirstResponder];
        
    }
}

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





































