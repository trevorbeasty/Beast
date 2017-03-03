//
//  TJBRealizedChainCell.h
//  Beast
//
//  Created by Trevor Beasty on 1/27/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TJBMasterCell.h"

// core data

@class TJBRealizedChain;

@interface TJBRealizedChainCell : TJBMasterCell

- (void)clearExistingEntries;

- (void)configureWithRealizedChain:(TJBRealizedChain *)realizedChain number:(NSNumber *)number finalRest:(NSNumber *)finalRest referenceIndexPath:(NSIndexPath *)path;

+ (float)suggestedCellHeightForRealizedChain:(TJBRealizedChain *)realizedChain;

@end
