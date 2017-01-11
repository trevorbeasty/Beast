//
//  RowComponentActiveUpdatingProtocol.h
//  Beast
//
//  Created by Trevor Beasty on 1/3/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TJBNumberSelectionVC.h"

@protocol RowComponentActiveUpdatingProtocol <NSObject>

- (void)updateLabelWithNumberType:(NumberType)numberType value:(double)value;

@end
