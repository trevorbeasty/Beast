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

@interface TJBActiveGuidanceTargetsScene () <UITableViewDelegate, UITableViewDataSource>

// IBOutlet

@property (weak, nonatomic) IBOutlet UIView *titleAreaContainer;
@property (weak, nonatomic) IBOutlet UILabel *activeRoutineLabel;
@property (weak, nonatomic) IBOutlet UIView *topTitleBar;
@property (weak, nonatomic) IBOutlet UIView *bottomTitleBar;
@property (weak, nonatomic) IBOutlet UILabel *targetsLabel;
@property (weak, nonatomic) IBOutlet UITableView *routineTargetTableView;

// core

@property (strong) TJBChainTemplate *chainTemplate;


@end



#pragma mark - Constants

static NSString * const cellReuseID = @"TJBRealizedChainCell";







@implementation TJBActiveGuidanceTargetsScene


#pragma mark - Instantiation


- (instancetype)initWithChainTemplate:(TJBChainTemplate *)ct{
    
    self = [super init];
    
    if (self){
        
        self.chainTemplate = ct;
        
        
    }
   
    return self;
    
}


#pragma mark - Init Helper Methods






#pragma mark - View Life Cycle


- (void)viewDidLoad{
    
    [self configureViewAesthetics];
    
    
    [self configureTableView];
    
    
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

#pragma mark - <UITableViewDataSource>


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return 1;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    TJBRealizedChainCell *cell = [self.routineTargetTableView dequeueReusableCellWithIdentifier: cellReuseID];
    
    [cell configureWithContentObject: self.chainTemplate
                            cellType: ChainTemplateAdvCell
                        dateTimeType: TJBDayInYear
                         titleNumber: @(1)];
    
    return cell;
    
}






#pragma mark - <UITableViewDelegate>


- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return NO;
    
}










@end

















