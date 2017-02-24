//
//  TJBRealizedSetCollectionCell.h
//  Beast
//
//  Created by Trevor Beasty on 2/23/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TJBRealizedSet;

@interface TJBRealizedSetCollectionCell : UITableViewCell

- (void)clearExistingEntries;

- (void)configureWithRealizedSetCollection:(NSArray<TJBRealizedSet *> *)realizedSetColleection number:(NSNumber *)number finalRest:(NSNumber *)finalRest;

+ (float)suggestedCellHeightForRealizedSetCollection:(NSArray<TJBRealizedSet *> *)realizedSetCollection;

@end
