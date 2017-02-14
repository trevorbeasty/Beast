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

@interface TJBExerciseSelectionScene () <UITableViewDelegate, UITableViewDataSource>

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

// IBAction

- (IBAction)didPressAddNewExercise:(id)sender;
- (IBAction)didPressLeftBarButton:(id)sender;
- (IBAction)didPressAddButton:(id)sender;


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

static CGFloat const controlHeight = 250.0;

- (void)viewDidLoad{
    
    self.exerciseAdditionContainer.hidden = YES;
    
    [self configureTableView];
    
//    [self configureNavigationBar];
    
    [self createFetchedResultsController];
    
    [self viewAesthetics];
    
    [self configureInitialControlPosition];
    
}

- (void)configureInitialControlPosition{
    
    [self.view insertSubview: self.exerciseAdditionContainer
                belowSubview: self.titleBarContainer];
    
    self.exerciseAdditionConstraint.constant = -1 * controlHeight;
    
}

- (void)viewWillAppear:(BOOL)animated{
    
    NSError *error = nil;
    [self.fetchedResultsController performFetch: &error];
    [self.exerciseTableView reloadData];
    
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
    
    self.addNewExerciseButton.backgroundColor = [[TJBAestheticsController singleton] blueButtonColor];
    
    NSArray *exerciseAdditionLabels = @[self.exerciseLabel, self.categoryLabel];
    for (UILabel *label in exerciseAdditionLabels){
        
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize: 20.0];
        label.textColor = [UIColor darkGrayColor];
        
    }
    
    self.categorySegmentedControl.tintColor = [[TJBAestheticsController singleton] blueButtonColor];
    
    self.addButton.backgroundColor = [[TJBAestheticsController singleton] blueButtonColor];
    self.addButton.titleLabel.font = [UIFont boldSystemFontOfSize: 20.0];
    [self.addButton setTitleColor: [UIColor whiteColor]
                         forState: UIControlStateNormal];
    self.addButton.layer.masksToBounds = YES;
    self.addButton.layer.cornerRadius = 8.0;
    
    CALayer *layer = self.exerciseTextField.layer;
    layer.masksToBounds = YES;
    layer.cornerRadius = 8.0;
    layer.borderWidth = 1;
    layer.borderColor = [[UIColor darkGrayColor] CGColor];
    
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
    cell.textLabel.font = [UIFont systemFontOfSize: 20.0];
    
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
    label.backgroundColor = [UIColor darkGrayColor];
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
    
    return 60;
    
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

@end





































