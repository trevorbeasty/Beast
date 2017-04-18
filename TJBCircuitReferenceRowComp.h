//
//  TJBCircuitReferenceRowComp.h
//  Beast
//
//  Created by Trevor Beasty on 1/11/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

// parent VC

#import "TJBCircuitReferenceVC.h"

@class TJBRealizedChain;

@interface TJBCircuitReferenceRowComp : UIViewController

- (instancetype)initWithRealizedChain:(TJBRealizedChain *)realizedChain realizedSet:(TJBRealizedSet *)rs editingDataType:(TJBEditingDataType)editingDataType exerciseIndex:(int)exerciseIndex roundIndex:(int)roundIndex;


@end
