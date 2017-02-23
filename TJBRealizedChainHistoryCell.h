//
//  TJBRealizedChainHistoryCell.h
//  Beast
//
//  Created by Trevor Beasty on 2/23/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TJBRealizedChain;

@interface TJBRealizedChainHistoryCell : UITableViewCell

- (void)clearExistingEntries;

- (void)configureWithRealizedChain:(TJBRealizedChain *)realizedChain number:(NSNumber *)number;

+ (float)suggestedCellHeightForRealizedChain:(TJBRealizedChain *)realizedChain;

@end
