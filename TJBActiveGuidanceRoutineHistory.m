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

@interface TJBActiveGuidanceRoutineHistory ()

// IBOutlet

@property (weak, nonatomic) IBOutlet UIView *titleAreaContainer;
@property (weak, nonatomic) IBOutlet UIView *topTitleBar;
@property (weak, nonatomic) IBOutlet UIView *bottomTitleBar;
@property (weak, nonatomic) IBOutlet UIView *tableViewContainer;

@property (weak, nonatomic) IBOutlet UILabel *activeRoutineLabel;
@property (weak, nonatomic) IBOutlet UILabel *completeHistoryLabel;

// core

@property (strong) TJBChainTemplate *chainTemplate;

@end

@implementation TJBActiveGuidanceRoutineHistory


#pragma mark - Instantiation

- (instancetype)initWithChainTemplate:(TJBChainTemplate *)ct{
    
    self = [super init];
    
    if (self){
        
        self.chainTemplate = ct;
        
    }
    
    
    return self;
    
}

#pragma mark - View Life Cycle

- (void)viewDidLoad{
    
    [self configureViewAesthetics];
    
    [self configureChildVC];
    
    
    
}




#pragma mark - View Helper Methods

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
    
    
    
}

#pragma mark - Child VC Content

- (void)configureChildVC{
    
    TJBCompleteChainHistoryVC *childVC = [[TJBCompleteChainHistoryVC alloc] initWithChainTemplate: self.chainTemplate];
    childVC.view.backgroundColor = [UIColor clearColor];
    
    [self.view layoutSubviews];
    
    UIScrollView *sv = [[UIScrollView alloc] initWithFrame: self.tableViewContainer.bounds];
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



@end











































