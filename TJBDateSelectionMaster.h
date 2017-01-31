//
//  TJBDateSelectionMaster.h
//  Beast
//
//  Created by Trevor Beasty on 1/31/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TJBDateSelectionMaster <NSObject>

- (void)didSelectObjectWithIndex:(NSNumber *)index representedDate:(NSDate *)representedDate;

@end
