//
//  NewOrExistinigCircuitVC.m
//  Beast
//
//  Created by Trevor Beasty on 12/26/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import "NewOrExistinigCircuitVC.h"

#import "CoreDataController.h"

#import "TJBCircuitDesignVC.h"
#import "TJBActiveCircuitGuidance.h"
#import "TJBCircuitTemplateGeneratorVC.h"

#import "TJBCircuitModeTBC.h"

#import "TJBAestheticsController.h"

#import "TJBCircuitReferenceContainerVC.h"

@interface NewOrExistinigCircuitVC () <NSFetchedResultsControllerDelegate, UITableViewDelegate, UITableViewDataSource, UIViewControllerRestoration>

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UIButton *createNewChainButton;

// for restoration

@property (copy) void (^restorationBlock)(void);

- (IBAction)didPressCreateNewChain:(id)sender;

// core data
@property (nonatomic, strong) NSFetchedResultsController *frc;

@end

@implementation NewOrExistinigCircuitVC

#pragma mark - Instantiation

- (instancetype)init{
    self = [super init];
    
    // for restoration
    self.restorationIdentifier = @"TJBNewOrExistingCircuit";
    self.restorationClass = [NewOrExistinigCircuitVC class];
    
    return self;
}

#pragma mark - View Cycle

- (void)viewDidLoad{
    [self configureNavigationBar];
    [self fetchCoreDataAndConfigureTableView];
    [self addBackground];
    [self viewAesthetics];
}

//- (void)viewDidAppear:(BOOL)animated{
//    
//    if (self.restorationBlock){
//        
//        self.restorationBlock();
//        self.restorationBlock = nil;
//    }
//}

- (void)viewAesthetics{
    [[TJBAestheticsController singleton] configureButtonsInArray: @[self.createNewChainButton]
                                                     withOpacity: .85];
    
    self.tableView.layer.opacity = .85;
}

- (void)addBackground{
    [[TJBAestheticsController singleton] addFullScreenBackgroundViewWithImage: [UIImage imageNamed: @"girlOverheadKettlebell"]
                                                                   toRootView: self.view
                                                                 imageOpacity: .35];
}

- (void)viewWillAppear:(BOOL)animated{
    NSError *error = nil;
    [self.frc performFetch: &error];
    [self.tableView reloadData];

}

- (void)configureNavigationBar{
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle: @"Circuit Selection"];
    UIBarButtonItem *homeButton = [[UIBarButtonItem alloc] initWithTitle: @"Home"
                                                                   style: UIBarButtonItemStyleDone
                                                                  target: self
                                                                  action: @selector(didPressHomeButton)];
    [navItem setLeftBarButtonItem: homeButton];
    [self.navBar setItems: @[navItem]];
}

- (void)fetchCoreDataAndConfigureTableView{
    // table view configuration
    [self.tableView registerClass: [UITableViewCell class]
           forCellReuseIdentifier: @"basicCell"];
    
    // NSFetchedResultsController
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName: @"ChainTemplate"];
    NSSortDescriptor *nameSort = [NSSortDescriptor sortDescriptorWithKey: @"name"
                                                               ascending: YES];
    [request setSortDescriptors: @[nameSort]];
    NSManagedObjectContext *moc = [[CoreDataController singleton] moc];
    NSFetchedResultsController *frc = [[NSFetchedResultsController alloc] initWithFetchRequest: request
                                                                          managedObjectContext: moc
                                                                            sectionNameKeyPath: @"name"
                                                                                     cacheName: nil];
    frc.delegate = self;
    self.frc = frc;
    NSError *error = nil;
    if (![self.frc performFetch: &error])
    {
        NSLog(@"Failed to initialize fetchedResultsController: %@\n%@", [error localizedDescription], [error userInfo]);
        abort();
    }
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    NSUInteger sectionCount = [[[self frc] sections] count];
    return sectionCount;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    id<NSFetchedResultsSectionInfo> sectionInfo = [[self frc] sections][section];
    NSUInteger numberOfObjects = [sectionInfo numberOfObjects];
    return numberOfObjects;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier: @"basicCell"];
    TJBChainTemplate *chainTemplate = [self.frc objectAtIndexPath: indexPath];
    cell.textLabel.text = chainTemplate.name;
    return cell;
}

#pragma mark - <UITableViewDelegate>

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    TJBChainTemplate *chainTemplate = [self.frc objectAtIndexPath: indexPath];
    
//    TJBCircuitReferenceContainerVC *vc = [[TJBCircuitReferenceContainerVC alloc] initWithChainTemplate: chainTemplate];
//    
//    [self presentViewController: vc
//                       animated: YES
//                     completion: nil];
    
    TJBCircuitModeTBC *tbc = [[TJBCircuitModeTBC alloc] initWithChainTemplate: chainTemplate];
    
    [self presentViewController: tbc
                       animated: YES
                     completion: nil];
}

#pragma mark - Button Actions

- (IBAction)didPressCreateNewChain:(id)sender {
    TJBCircuitDesignVC *vc = [[TJBCircuitDesignVC alloc] init];
    [self presentViewController: vc
                       animated: YES
                     completion: nil];
}

- (void)didPressHomeButton{
    [self dismissViewControllerAnimated: NO
                             completion: nil];
}

#pragma mark - <UIViewControllerRestoration>

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder{
    NewOrExistinigCircuitVC *vc = [[NewOrExistinigCircuitVC alloc] init];
    return vc;
}

@end






















