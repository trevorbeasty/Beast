//
//  TJBCircuitReferenceExerciseComp.h
//  Beast
//
//  Created by Trevor Beasty on 1/11/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

// parent VC

#import "TJBCircuitReferenceVC.h"



@interface TJBCircuitReferenceExerciseComp : UIViewController

- (instancetype)initWithRealizedChain:(TJBRealizedChain *)realizedChain realizedSetGrouping:(TJBRealizedSetGrouping)rsg editingDataType:(TJBEditingDataType)editingDataType exerciseIndex:(int)exerciseIndex;


@end
