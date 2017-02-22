//
//  TJBCircuitTemplateVCProtocol.h
//  Beast
//
//  Created by Trevor Beasty on 1/10/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TJBNumberSelectionVC.h"

@class TJBCircuitTemplateRowComponent;
@class TJBChainTemplate;
@class TJBCircuitTemplateExerciseComp;

// protocols

#import "TJBCircuitTemplateExerciseComponentProtocol.h"
#import "TJBCircuitTemplateRowComponentProtocol.h"

@protocol TJBCircuitTemplateVCProtocol <NSObject>

- (void)didSelectExercise:(TJBExercise *)exercise forExerciseIndex:(int)exerciseIndex;

// for keeping track of child VC's

- (void)addChildRowController:(TJBCircuitTemplateRowComponent<TJBCircuitTemplateRowComponentProtocol> *)rowController;

// input validation

- (BOOL)allUserInputCollected;

// advanced user input

- (void)activateCopyingStateForNumber:(float)number;
- (void)deactivateCopyingState;
- (void)didDragAcrossPointInView:(CGPoint)dragPoint;

@end
