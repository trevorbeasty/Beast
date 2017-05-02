//
//  TJBActiveGuidanceTargetsScene.m
//  Beast
//
//  Created by Trevor Beasty on 4/19/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBActiveGuidanceTargetsScene.h"

#import "CoreDataController.h" // core data
#import "TJBAestheticsController.h"  // aesthetics
#import "TJBRealizedChainCell.h" // tableview cell

@interface TJBActiveGuidanceTargetsScene () <UITableViewDelegate, UITableViewDataSource, UIViewControllerRestoration>

// IBOutlet

@property (weak, nonatomic) IBOutlet UIView *titleAreaContainer;
@property (weak, nonatomic) IBOutlet UILabel *activeRoutineLabel;
@property (weak, nonatomic) IBOutlet UIView *topTitleBar;
@property (weak, nonatomic) IBOutlet UIView *bottomTitleBar;
@property (weak, nonatomic) IBOutlet UILabel *targetsLabel;
@property (weak, nonatomic) IBOutlet UITableView *routineTargetTableView;

// core

@property (strong) TJBChainTemplate *chainTemplate;
@property (strong) TJBRealizedChainCell *cell;


@end



#pragma mark - Constants

static NSString * const cellReuseID = @"TJBRealizedChainCell";

// restoration

static NSString * const restorationID = @"TJBActiveGuidanceTargetsScene";
static NSString * const chainTemplateIDStringKey = @"chainTemplateIDString";





@implementation TJBActiveGuidanceTargetsScene


#pragma mark - Instantiation


- (instancetype)initWithChainTemplate:(TJBChainTemplate *)ct{
    
    self = [super init];
    
    if (self){
        
        self.chainTemplate = ct;
        
        [self configureTabBarAttributes];
        
        [self configureRestorationProperties];
        
    }
   
    return self;
    
}


#pragma mark - Init Helper Methods


- (void)configureRestorationProperties{
    
    self.restorationIdentifier = restorationID;
    self.restorationClass = [TJBActiveGuidanceTargetsScene class];
    
}

- (void)configureTabBarAttributes{
    
    self.tabBarItem.title = @"Targets";
    self.tabBarItem.image = [UIImage imageNamed: @"targetBlue25PDF"];
    
}



#pragma mark - View Life Cycle


- (void)viewDidLoad{
    
    [self configureViewAesthetics];

    [self configureTableView];
    
}

- (void)viewDidAppear:(BOOL)animated{
    
    
    [self deriveCell];
    [self.routineTargetTableView reloadData];
    
}





#pragma mark - View Helper Methods





- (void)configureViewAesthetics{
    
    // views
    
    self.view.backgroundColor = [[TJBAestheticsController singleton] yellowNotebookColor];
    self.titleAreaContainer.backgroundColor = [UIColor blackColor];
    self.topTitleBar.backgroundColor = [UIColor darkGrayColor];
    self.bottomTitleBar.backgroundColor = [UIColor darkGrayColor];
    
    // title Labels
    
    NSArray *titleLabels = @[self.activeRoutineLabel, self.targetsLabel];
    for (UILabel *lab in titleLabels){
        
        lab.backgroundColor = [UIColor clearColor];
        lab.font = [UIFont boldSystemFontOfSize: 20];
        lab.textColor = [UIColor whiteColor];
        
    }
    
    // table view
    
    self.routineTargetTableView.backgroundColor = [UIColor clearColor];
    
    
    
    
}

- (void)configureTableView{
    
    UINib *cellNib = [UINib nibWithNibName: @"TJBRealizedChainCell"
                                    bundle: nil];
    [self.routineTargetTableView registerNib: cellNib
                      forCellReuseIdentifier: cellReuseID];
    
}


- (void)deriveCell{
    
    TJBRealizedChainCell *cell = [self.routineTargetTableView dequeueReusableCellWithIdentifier: cellReuseID];
    
    [self layoutCellToEnsureCorrectWidth: cell
                               indexPath: [NSIndexPath indexPathForRow: 0
                                                             inSection: 0]];
    
    [cell configureChainTemplateCellWithChainTemplate: self.chainTemplate
                                         dateTimeType: TJBDayInYear
                                          titleNumber: @(1)
                                          sortingType: TJBChainTemplateByDateCreated];
    
    cell.backgroundColor = [UIColor clearColor];
    
    self.cell = cell;
    
}

#pragma mark - <UITableViewDataSource>


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    if (self.cell){
        
        return 1;
        
    } else{
        
        return 0;
        
    }
    

    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 1;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return self.cell;
    
}


- (void)layoutCellToEnsureCorrectWidth:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath{
    
    [self.view layoutIfNeeded];
    
    CGFloat cellHeight = [self tableView: self.routineTargetTableView
                 heightForRowAtIndexPath: indexPath];
    
    CGFloat cellWidth = self.routineTargetTableView.frame.size.width;
    
    
    cell.contentView.bounds = CGRectMake(0, 0, cellWidth, cellHeight);
    [cell.contentView layoutIfNeeded];
    
}



#pragma mark - <UITableViewDelegate>


- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return NO;
    
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return [TJBRealizedChainCell suggestedCellHeightForChainTemplate: self.chainTemplate];
    
}



#pragma mark - Restoration


- (void)encodeRestorableStateWithCoder:(NSCoder *)coder{
    
    [coder encodeObject: self.chainTemplate.uniqueID
                 forKey: chainTemplateIDStringKey];
    
}

+(UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder{
    
    
    NSString *ctID = [coder decodeObjectForKey: chainTemplateIDStringKey];
    TJBChainTemplate *ct = [[CoreDataController singleton] chainTemplateWithUniqueID: ctID];
    
    return [[TJBActiveGuidanceTargetsScene alloc] initWithChainTemplate: ct];
    
    
}




@end

















