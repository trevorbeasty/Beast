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

@property (nonatomic, strong) NSFetchedResultsController *fetchedResultsController;

@property (weak, nonatomic) IBOutlet UITableView *exerciseTableView;

// navigation bar

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (nonatomic, strong) UINavigationItem *navItem;
@property (nonatomic, strong) NSString *navBarTitle;

// callback

@property (copy) void(^callbackBlock)(TJBExercise *);

@property (weak, nonatomic) IBOutlet UIButton *addNewExerciseButton;
- (IBAction)didPressAddNewExercise:(id)sender;


@end

static NSString * const cellReuseIdentifier = @"basicCell";

@implementation TJBExerciseSelectionScene

#pragma mark - Instantiation

- (instancetype)initWithTitle:(NSString *)title callbackBlock:(void (^)(TJBExercise *))block{
    self = [super init];
    
    self.navBarTitle = title;
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

- (void)configureNavigationBar
{
    UINavigationItem *navItem = [[UINavigationItem alloc] init];
    
    [navItem setTitle: self.navBarTitle];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCancel
                                                                                  target: self
                                                                                  action: @selector(didPressCancelButton)];
    [navItem setLeftBarButtonItem: cancelButton];
    
    [self.navBar setItems: @[navItem]];
}

- (void)createFetchedResultsController
{
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
    [[TJBAestheticsController singleton] configureButtonsInArray: @[self.addNewExerciseButton]
                                                     withOpacity: 1.0];
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
    
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    id<NSFetchedResultsSectionInfo> sectionInfo = [[self fetchedResultsController] sections][section];
    return [sectionInfo name];
}

#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    TJBExercise *exercise = [self.fetchedResultsController objectAtIndexPath: indexPath];
    
    self.callbackBlock(exercise);
}

#pragma mark - Button Actions

- (void)didPressCancelButton
{
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


















