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

// FRC

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

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

static CGFloat const controlHeight = 236.0;

- (void)viewDidLoad{
    
    self.exerciseAdditionContainer.hidden = YES;
    
    [self configureTableView];
    
//    [self configureNavigationBar];
    
    [self createFetchedResultsController];
    
    [self viewAesthetics];
    
    [self configureInitialControlPosition];
    
    [self addTapGestureRecognizerToViewForKeyboardNotification];
    
    [self registerForCoreDataNotifications];
    
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
    
    self.exerciseAdditionConstraint.constant = -1 * controlHeight;
    
}

- (void)registerForCoreDataNotifications{
    
    //// configure managed context notification for updating
    
    NSManagedObjectContext *moc = [[CoreDataController singleton] moc];
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(mocDidSave)
                                                 name: NSManagedObjectContextDidSaveNotification
                                               object: moc];
    
}

- (void)viewDidAppear:(BOOL)animated{
    
    self.exerciseAdditionContainer.hidden = NO;
    
}

//- (void)configureNavigationBar{
//    
//    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle: @"Select Exercise"];
//    
//    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCancel
//                                                                                  target: self
//                                                                                  action: @selector(didPressCancelButton)];
//    [navItem setLeftBarButtonItem: cancelButton];
//    
//    [self.navBar setItems: @[navItem]];
//    
//}

- (void)createFetchedResultsController{
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName: @"Exercise"];
    
    NSPredicate *noPlaceholderExercisesPredicate = [NSPredicate predicateWithFormat: @"category.name != %@",
                                                    @"Placeholder"];
    
    request.predicate = noPlaceholderExercisesPredicate;
    
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
    
    // exercise text field
    
    self.exerciseTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    
    CALayer *layer = self.exerciseTextField.layer;
    layer.masksToBounds = YES;
    layer.cornerRadius = 8.0;
    layer.borderWidth = 1;
    layer.borderColor = [[UIColor darkGrayColor] CGColor];
    
    self.exerciseTextField.font = [UIFont systemFontOfSize: 20.0];
    
}

- (void)configureTableView
{
    [self.exerciseTableView registerClass: [UITableViewCell class]
                   forCellReuseIdentifier: cellReuseIdentifier];
    
    NSArray *titleButtons = @[self.leftBarButton, self.rightBarButton];
    for (UIButton *button in titleButtons){
        
        button.backgroundColor = [UIColor darkGrayColor];
        button.titleLabel.font = [UIFont boldSystemFontOfSize: 20.0];
        [button setTitleColor: [UIColor whiteColor]
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
    
//    self.exerciseAdditionContainer.hidden = YES;
    
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

//- (void)didPressCancelButton{
//    
//    [self dismissViewControllerAnimated: NO
//                             completion: nil];
//    
//}

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

- (void)toggleButtonControlsToAdvancedDisplay{
    
    self.exerciseAdditionContainer.hidden = NO;
    
    [UIView animateWithDuration: .4
                     animations: ^{
                         
                         self.exerciseAdditionConstraint.constant = 0;
                         
                         NSArray *views = @[self.exerciseAdditionContainer];
                         
                         for (UIView *view in views){
                             
                             CGRect currentFrame = view.frame;
                             CGRect newFrame = CGRectMake(currentFrame.origin.x, currentFrame.origin.y + controlHeight, currentFrame.size.width, currentFrame.size.height);
                             view.frame = newFrame;
                             
                         }
                         
                         CGRect currentTVFrame = self.exerciseTableView.frame;
                         CGRect newTVFrame = CGRectMake(currentTVFrame.origin.x, currentTVFrame.origin.y + controlHeight, currentTVFrame.size.width, currentTVFrame.size.height - controlHeight);
                         self.exerciseTableView.frame = newTVFrame;
                         
                     }];
    
    _exerciseAdditionActive = YES;
    [self.addNewExerciseButton setTitle: @"Done"
                               forState: UIControlStateNormal];
    
}

- (void)toggleButtonControlsToDefaultDisplay{
    
    [UIView animateWithDuration: .4
                     animations: ^{
                         
                         self.exerciseAdditionConstraint.constant = -1 * controlHeight;
                         
                         
                         NSArray *views = @[self.exerciseAdditionContainer];
                         
                         for (UIView *view in views){
                             
                             CGRect currentFrame = view.frame;
                             CGRect newFrame = CGRectMake(currentFrame.origin.x, currentFrame.origin.y - controlHeight, currentFrame.size.width, currentFrame.size.height);
                             view.frame = newFrame;
                             
                         }
                         
                         CGRect currentTVFrame = self.exerciseTableView.frame;
                         CGRect newTVFrame = CGRectMake(currentTVFrame.origin.x, currentTVFrame.origin.y - controlHeight, currentTVFrame.size.width, currentTVFrame.size.height + controlHeight);
                         self.exerciseTableView.frame = newTVFrame;
                         
                     }];
    
    _exerciseAdditionActive = NO;
    [self.addNewExerciseButton setTitle: @"Add New Exercise"
                                forState: UIControlStateNormal];
    
//    self.exerciseAdditionContainer.hidden = YES;
    
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
    
    BOOL keyboardIsShowing = [self.exerciseTextField isFirstResponder];
    
    if (keyboardIsShowing){
        
        [self.exerciseTextField resignFirstResponder];
        
    }
}

#pragma mark - <UITextFieldDelegate>

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [self.exerciseTextField resignFirstResponder];
    
    return YES;
    
}

- (void)mocDidSave{
    
    //// refresh fetched managed objects and all trickle-down
    
    NSError *error = nil;
    [self.fetchedResultsController performFetch: &error];
    [self.exerciseTableView reloadData];
    
}

@end





































