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

// core data

@class  TJBRealizedChain;

@interface TJBCircuitReferenceExerciseComp : UIViewController

- (instancetype)initWithRealizedChain:(TJBRealizedChain *)realizedChain exerciseIndex:(int)exerciseIndex;

//- (void)activateMode:(TJBRoutineReferenceMode)mode;

@end
