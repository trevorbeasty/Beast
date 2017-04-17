//
//  TJBCompleteChainHistoryVC.m
//  Beast
//
//  Created by Trevor Beasty on 2/23/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBCompleteChainHistoryVC.h"

// core data

#import "CoreDataController.h"

// table view cells

//#import "TJBRealizedChainHistoryCell.h"
#import "TJBRealizedChainCell.h"
#import "TJBWorkoutLogTitleCell.h"

// aesthetics

#import "TJBAestheticsController.h"

@interface TJBCompleteChainHistoryVC () <UITableViewDelegate, UITableViewDataSource>

// IBOutlet

@property (weak, nonatomic) IBOutlet UITableView *chainHistoryTV;


// core

@property (strong) TJBChainTemplate *chainTemplate;

@end

@implementation TJBCompleteChainHistoryVC

#pragma mark - Instantiation

- (instancetype)initWithChainTemplate:(TJBChainTemplate *)chainTemplate{
    
    self = [super init];
    
    self.chainTemplate = chainTemplate;
    
    return self;
    
}

#pragma mark - View Life Cycle

- (void)viewDidLoad{
    
    [self configureTableView];
    
    [self configureViewAesthetics];
    
}

- (void)configureViewAesthetics{
    
    self.chainHistoryTV.backgroundColor = [[TJBAestheticsController singleton] yellowNotebookColor];
    
}

static NSString *realizedChainCellID = @"TJBRealizedChainCell";
static NSString *titleCellID = @"TJBWorkoutLogTitleCell";

- (void)configureTableView{
    
    UINib *realizedChainNib = [UINib nibWithNibName: @"TJBRealizedChainCell"
                                             bundle: nil];
    
    [self.chainHistoryTV registerNib: realizedChainNib
              forCellReuseIdentifier: realizedChainCellID];
    
    UINib *titleCellNib = [UINib nibWithNibName: @"TJBWorkoutLogTitleCell"
                                         bundle: nil];
    
    [self.chainHistoryTV registerNib: titleCellNib
              forCellReuseIdentifier: titleCellID];
    
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.chainTemplate.realizedChains.count + 1;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // the first cell will be the title cell.  All subsequent content cells will need to have the index path row adjusted
    
    if (indexPath.row == 0){
        
        // title cell
        
        TJBWorkoutLogTitleCell *titleCell = [self.chainHistoryTV dequeueReusableCellWithIdentifier: titleCellID];
        
        titleCell.primaryLabel.text = self.chainTemplate.name;
        titleCell.secondaryLabel.text = @"Routine History";
        
        titleCell.backgroundColor = [UIColor clearColor];
        
        return titleCell;
        
    } else{
        
        // content cell
        
        // adjust the index.  This accounts for the 1 title cell and also reverses the index so that it grabs the last entry first
        
        NSInteger adjIndex = indexPath.row - 1;
        NSInteger reversedIndex = (self.chainTemplate.realizedChains.count - 1) - adjIndex;
        
        // dequeue the cell
        
        TJBRealizedChainCell *chainCell = [self.chainHistoryTV dequeueReusableCellWithIdentifier: realizedChainCellID];
        
        // grab the appropriate realized chain
        
        TJBRealizedChain *chain = self.chainTemplate.realizedChains[reversedIndex];
        
        // configure the cell
        
        [chainCell configureWithContentObject: chain
                                     cellType: RealizedChainCell
                                 dateTimeType: TJBDayInYear
                                  titleNumber: @(indexPath.row)];
        
        chainCell.backgroundColor = [UIColor clearColor];
        
        return chainCell;
        
    }
    
}








#pragma mark - <UITableViewDelegate>

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CGFloat titleHeight = 80.0;
    
    if (indexPath.row == 0){
        
        return titleHeight;
        
    } else{
        
        NSInteger adjIndex = indexPath.row - 1;
        
        TJBRealizedChain *realizedChain = self.chainTemplate.realizedChains[adjIndex];
        
        return [TJBRealizedChainCell suggestedCellHeightForRealizedChain: realizedChain];
        
    }
    
}

#pragma mark - API

- (CGFloat)contentHeight{
    
    // returns the total height for cells containing content
    
    NSInteger realizedChainCount = self.chainTemplate.realizedChains.count;
    
    NSInteger iterationLimit;
    if (realizedChainCount == 0){
        iterationLimit = 2;
    } else{
        iterationLimit = realizedChainCount + 1;
    }
    
    CGFloat sum = 0;
    for (int i = 0; i < iterationLimit; i++){
        
        NSIndexPath *path = [NSIndexPath indexPathForRow: i
                                               inSection: 0];
        
        CGFloat height = [self tableView: self.chainHistoryTV
                 heightForRowAtIndexPath: path];
        
        sum += height;
        
    }
    
    return sum;
    
}



@end

































