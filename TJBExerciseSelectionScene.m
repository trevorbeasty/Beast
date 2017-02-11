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

// FRC

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

// callback

@property (copy) void(^callbackBlock)(TJBExercise *);

// IBOutlet

@property (weak, nonatomic) IBOutlet UIButton *addNewExerciseButton;
@property (weak, nonatomic) IBOutlet UITableView *exerciseTableView;
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;

// IBAction

- (IBAction)didPressAddNewExercise:(id)sender;


@end

static NSString * const cellReuseIdentifier = @"basicCell";

@implementation TJBExerciseSelectionScene

#pragma mark - Instantiation

- (instancetype)initWithCallbackBlock:(void (^)(TJBExercise *))block{
    
    self = [super init];
    
    self.callbackBlock = block;
    
    return self;
    
}

#pragma mark - View Life Cycle

- (void)viewDidLoad{
    
    [self configureTableView];
    
    [self configureNavigationBar];
    
    [self createFetchedResultsController];
    
    [self viewAesthetics];
    
}

- (void)viewWillAppear:(BOOL)animated{
    NSError *error = nil;
    [self.fetchedResultsController performFetch: &error];
    [self.exerciseTableView reloadData];
}

- (void)configureNavigationBar{
    
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle: @"Select Exercise"];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCancel
                                                                                  target: self
                                                                                  action: @selector(didPressCancelButton)];
    [navItem setLeftBarButtonItem: cancelButton];
    
    [self.navBar setItems: @[navItem]];
    
}

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
    
}

- (void)configureTableView
{
    [self.exerciseTableView registerClass: [UITableViewCell class]
                   forCellReuseIdentifier: cellReuseIdentifier];
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
    label.font = [UIFont boldSystemFontOfSize: 25.0];
    label.textAlignment = NSTextAlignmentCenter;
    
    id<NSFetchedResultsSectionInfo> sectionInfo = [[self fetchedResultsController] sections][section];
    label.text = [sectionInfo name];
    
    return label;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 50;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 40;
    
}

#pragma mark - Button Actions

- (void)didPressCancelButton{
    
    [self dismissViewControllerAnimated: NO
                             completion: nil];
    
}

- (IBAction)didPressAddNewExercise:(id)sender {
    TJBNewExerciseCreationVC *vc = [[TJBNewExerciseCreationVC alloc] init];
    [self presentViewController: vc
                       animated: YES
                     completion: nil];
}

@end





































