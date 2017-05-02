//
//  TJBActiveGuidanceRoutineHistory.m
//  Beast
//
//  Created by Trevor Beasty on 4/19/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBActiveGuidanceRoutineHistory.h"

#import "CoreDataController.h" // core data
#import "TJBAestheticsController.h" // aesthetics

#import "TJBCompleteChainHistoryVC.h" // child VC

@interface TJBActiveGuidanceRoutineHistory () <UIViewControllerRestoration>

{
    
    BOOL _shouldFetchDataAndCreateDisplay;
    
}

// IBOutlet

@property (weak, nonatomic) IBOutlet UIView *titleAreaContainer;
@property (weak, nonatomic) IBOutlet UIView *topTitleBar;
@property (weak, nonatomic) IBOutlet UIView *bottomTitleBar;
@property (weak, nonatomic) IBOutlet UIView *tableViewContainer;

@property (weak, nonatomic) IBOutlet UILabel *activeRoutineLabel;
@property (weak, nonatomic) IBOutlet UILabel *completeHistoryLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberOfRecordsLabel;

// core

@property (strong) TJBChainTemplate *chainTemplate;
@property (strong) UIScrollView *contentScrollView;
@property (strong) TJBCompleteChainHistoryVC *activeChainHistoryVC;

@property (strong) UIActivityIndicatorView *activeAIView;

@end



#pragma mark - Constants

static NSString * const chainTemplateIDKey = @"ChainTemplateID";
static NSString * const restorationID = @"TJBActiveGuidanceRoutineHistory";





@implementation TJBActiveGuidanceRoutineHistory


#pragma mark - Instantiation

- (instancetype)initWithChainTemplate:(TJBChainTemplate *)ct{
    
    self = [super init];
    
    if (self){
        
        self.chainTemplate = ct;
        
        [self configureCoreDataUpdateNotification];
        
        _shouldFetchDataAndCreateDisplay = YES;
        
        [self configureTabBarAttributes];
        
        [self configureRestorationProperties];
        
    }
    
    
    return self;
    
}


#pragma mark - Init Helper Methods

- (void)configureRestorationProperties{
    
    self.restorationIdentifier = restorationID;
    self.restorationClass = [TJBActiveGuidanceRoutineHistory class];
    
}


- (void)configureTabBarAttributes{
    
    self.tabBarItem.title = @"History";
    self.tabBarItem.image = [UIImage imageNamed: @"historyBlue25PDF"];
    
}


#pragma mark - View Life Cycle

- (void)viewDidLoad{
    
    [self configureViewAesthetics];
    
    [self configureLabelText];
    
    
    
}


- (void)viewWillAppear:(BOOL)animated{
    
    if (_shouldFetchDataAndCreateDisplay){
        
        [self removeExistingChildVC];
        
        [self showActivityIndicator];
        
    }
    
}


- (void)viewDidAppear:(BOOL)animated{
    
    if (_shouldFetchDataAndCreateDisplay){
        
        [self configureChildVC];
        
        [self removeActivityIndicator];
        
        _shouldFetchDataAndCreateDisplay = NO;
        
    }
    
}

#pragma mark - View Helper Methods



- (void)configureLabelText{
    
    NSNumber *numberOfRecords = @(self.chainTemplate.realizedChains.count);
    
    NSString *recordsWord = [numberOfRecords intValue] == 1 ? @"Record" : @"Records";
    
    self.numberOfRecordsLabel.text = [NSString stringWithFormat: @"%@ %@",
                                           [numberOfRecords stringValue],
                                           recordsWord];
    
}

- (void)configureViewAesthetics{
    
    self.view.backgroundColor = [[TJBAestheticsController singleton] yellowNotebookColor];
    self.titleAreaContainer.backgroundColor = [UIColor blackColor];
    self.topTitleBar.backgroundColor = [UIColor darkGrayColor];
    self.bottomTitleBar.backgroundColor = [UIColor darkGrayColor];
    self.tableViewContainer.backgroundColor = [UIColor clearColor];
    
    NSArray *titleLabels = @[self.activeRoutineLabel, self.completeHistoryLabel];
    for (UILabel *lab in titleLabels){
        
        lab.font = [UIFont boldSystemFontOfSize: 20];
        lab.backgroundColor = [UIColor clearColor];
        lab.textColor = [UIColor whiteColor];
        
    }
    
    self.numberOfRecordsLabel.font = [UIFont boldSystemFontOfSize: 15];
    self.numberOfRecordsLabel.backgroundColor = [UIColor grayColor];
    self.numberOfRecordsLabel.textColor = [UIColor whiteColor];
    
    
    
}

#pragma mark - Child VC Content

- (void)removeExistingChildVC{
    
    if (self.contentScrollView){
        
        [self.activeChainHistoryVC willMoveToParentViewController: nil];
        
        [self.contentScrollView removeFromSuperview];
        self.contentScrollView = nil;
        
        [self.activeChainHistoryVC removeFromParentViewController];
        
        self.activeChainHistoryVC = nil;
        
    }
    
}

- (void)configureChildVC{
    
    TJBCompleteChainHistoryVC *childVC = [[TJBCompleteChainHistoryVC alloc] initWithChainTemplate: self.chainTemplate];
    self.activeChainHistoryVC = childVC;
    
    childVC.view.backgroundColor = [UIColor clearColor];
    
    [self.view layoutIfNeeded];
    
    UIScrollView *sv = [[UIScrollView alloc] initWithFrame: self.tableViewContainer.bounds];
    self.contentScrollView = sv;
    sv.backgroundColor = [UIColor clearColor];
    
    CGFloat containerHeight = self.tableViewContainer.frame.size.height;
    CGFloat svContentHeight = [childVC contentHeight];
    if (svContentHeight < containerHeight){
        svContentHeight = containerHeight;
    }
    
    CGSize svContentSize = CGSizeMake(self.tableViewContainer.frame.size.width, svContentHeight);
    sv.contentSize = svContentSize;
    
    [self.tableViewContainer addSubview: sv];
    
    [self addChildViewController: childVC];
    
    CGRect childVCRect = CGRectMake(0, 0, svContentSize.width, svContentSize.height);
    childVC.view.frame = childVCRect;
    [sv addSubview: childVC.view];
    
    [childVC didMoveToParentViewController: self];
    
    
}

#pragma mark - Core Data Updates

- (void)configureCoreDataUpdateNotification{
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(coreDataDidSave)
                                                 name: NSManagedObjectContextDidSaveNotification
                                               object: [[CoreDataController singleton] moc]];
    
    
}


- (void)coreDataDidSave{
    
    _shouldFetchDataAndCreateDisplay = YES;
    
}

#pragma mark - Activity Indicator

- (void)showActivityIndicator{
    
    if (!self.activeAIView){
        
        [self createActivityIndicator];
        
    }
    
    [self.activeAIView startAnimating];
    
}

- (void)createActivityIndicator{
    
    UIActivityIndicatorView *aiView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle: UIActivityIndicatorViewStyleGray];
    self.activeAIView = aiView;
    
    [self.view layoutIfNeeded];
    aiView.frame = self.tableViewContainer.bounds;
    
    [self.tableViewContainer addSubview: aiView];
    
}

- (void)removeActivityIndicator{
    
    [self.activeAIView stopAnimating];
    
}


#pragma mark - Restoration

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder{
    
    [coder encodeObject: self.chainTemplate.uniqueID
                 forKey: chainTemplateIDKey];

    
}


+(UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder{
    
    NSString *chainTemplateUniqueID = [coder decodeObjectForKey: chainTemplateIDKey];
    TJBChainTemplate *ct = [[CoreDataController singleton] chainTemplateWithUniqueID: chainTemplateUniqueID];
    
    return [[TJBActiveGuidanceRoutineHistory alloc] initWithChainTemplate: ct];
    
}



@end











































