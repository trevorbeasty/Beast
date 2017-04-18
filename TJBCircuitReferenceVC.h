//
//  TJBCircuitReferenceVC.h
//  Beast
//
//  Created by Trevor Beasty on 1/11/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    TJBRealizedsetGroupingEditingData,
    TJBRealizedChainEditingData
} TJBEditingDataType;

@class TJBRealizedChain;

@interface TJBCircuitReferenceVC : UIViewController

- (instancetype)initWithRealizedChain:(TJBRealizedChain *)realizedChain viewSize:(CGSize)size;

//- (void)activateMode:(TJBRoutineReferenceMode)mode;

@end
