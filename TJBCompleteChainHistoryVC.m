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

// aesthetics

#import "TJBAestheticsController.h"

@interface TJBCompleteChainHistoryVC () <UITableViewDelegate, UITableViewDataSource>

// IBOutlet

@property (weak, nonatomic) IBOutlet UITableView *chainHistoryTV;


// core

@property (strong) TJBChainTemplate *chainTemplate;

@end

@implementation TJBCompleteChainHistoryVC

{
    
    CGFloat _tableViewBreatherRoom;
    
}

#pragma mark - Instantiation

- (instancetype)initWithChainTemplate:(TJBChainTemplate *)chainTemplate{
    
    return  [self initWithChainTemplate: chainTemplate
                  tableViewBreatherRoom: 0];
    
}

- (instancetype)initWithChainTemplate:(TJBChainTemplate *)chainTemplate tableViewBreatherRoom:(CGFloat)tableViewBreatherRoom{
    
    self = [super init];
    
    self.chainTemplate = chainTemplate;
    _tableViewBreatherRoom = tableViewBreatherRoom;
    
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

- (void)configureTableView{
    
    UINib *realizedChainNib = [UINib nibWithNibName: @"TJBRealizedChainCell"
                                             bundle: nil];
    
    [self.chainHistoryTV registerNib: realizedChainNib
              forCellReuseIdentifier: realizedChainCellID];
    
}

#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.chainTemplate.realizedChains.count;
    
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // content cell
    
    NSInteger adjIndex = indexPath.row;
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








#pragma mark - <UITableViewDelegate>

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSInteger adjIndex = indexPath.row;
    
    TJBRealizedChain *realizedChain = self.chainTemplate.realizedChains[adjIndex];
    
    return [TJBRealizedChainCell suggestedCellHeightForRealizedChain: realizedChain];
    
    
}

#pragma mark - API

- (CGFloat)contentHeight{
    
    // returns the total height for cells containing content
    
    NSInteger realizedChainCount = self.chainTemplate.realizedChains.count;
    
    CGFloat sum = 0;
    for (int i = 0; i < realizedChainCount; i++){
        
        NSIndexPath *path = [NSIndexPath indexPathForRow: i
                                               inSection: 0];
        
        CGFloat height = [self tableView: self.chainHistoryTV
                 heightForRowAtIndexPath: path];
        
        sum += height;
        
    }
    
    return sum;
    
}



@end

































