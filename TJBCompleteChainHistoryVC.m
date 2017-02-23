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
    
    return self.chainTemplate.realizedChains.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // the first cell will be the title cell.  All subsequent content cells will need to have the index path row adjusted
    
    if (indexPath.row == 0){
        
        // title cell
        
        TJBWorkoutLogTitleCell *titleCell = [self.chainHistoryTV dequeueReusableCellWithIdentifier: titleCellID];
        
        titleCell.primaryLabel.text = self.chainTemplate.name;
        titleCell.secondaryLabel.text = @"Routine History";
        
        return titleCell;
        
    } else{
        
        // content cell
        
        // adjust the index
        
        NSInteger adjIndex = indexPath.row - 1;
        
        // dequeue the cell
        
        TJBRealizedChainCell *chainCell = [self.chainHistoryTV dequeueReusableCellWithIdentifier: realizedChainCellID];
        
        // grab the appropriate realized chain
        
        TJBRealizedChain *chain = self.chainTemplate.realizedChains[adjIndex];
        
        // configure the cell
        
        [chainCell configureWithRealizedChain: chain
                                       number: [NSNumber numberWithInteger: adjIndex + 1]];
        
        return chainCell;
        
    }
    
}








#pragma mark - <UITableViewDelegate>



@end

































