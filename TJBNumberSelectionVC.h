//
//  TJBNumberSelectionVC.h
//  Beast
//
//  Created by Trevor Beasty on 12/7/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    WeightType,
    RepsType,
    TargetRestType,
    TimeIntervalSelection
} NumberType;

typedef void(^CancelBlock)(void);
typedef void(^NumberSelectedBlockSingle)(NSNumber *);

@interface TJBNumberSelectionVC: UIViewController

- (instancetype)initWithNumberTypeIdentifier:(NumberType)numberType title:(NSString *)title cancelBlock:(CancelBlock)cancelBlock numberSelectedBlock:(NumberSelectedBlockSingle)numberSelectedBlock;

@end
