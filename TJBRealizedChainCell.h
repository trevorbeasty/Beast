//
//  TJBRealizedChainCell.h
//  Beast
//
//  Created by Trevor Beasty on 1/27/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

// core data

@class TJBRealizedChain;

@interface TJBRealizedChainCell : UITableViewCell

- (void)clearExistingEntries;

- (void)configureWithRealizedChain:(TJBRealizedChain *)realizedChain number:(NSNumber *)number;

@end
