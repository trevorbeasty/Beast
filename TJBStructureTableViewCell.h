//
//  TJBStructureTableViewCell.h
//  Beast
//
//  Created by Trevor Beasty on 1/25/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

// core data

@class TJBChainTemplate;

@interface TJBStructureTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *chainNameLabel;

- (void)configureWithChainTemplate:(TJBChainTemplate *)chainTemplate;

@end
