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

// for typedef

#import "TJBGlobalParameters.h"

typedef enum {
    WeightSwitch,
    RepsSwitch,
    TrailingRestSwitch
} TJBSwitchType;

@protocol TJBCircuitTemplateVCProtocol <NSObject>

- (void)didSelectExercise:(TJBExercise *)exercise forExerciseIndex:(int)exerciseIndex;

// for keeping track of child VC's

- (void)addChildRowController:(TJBCircuitTemplateRowComponent<TJBCircuitTemplateRowComponentProtocol> *)rowController correspondingToExerciseIndex:(int)exerciseIndex;

// input validation

- (BOOL)allUserInputCollected;
- (BOOL)nameIsBlank;

// advanced user input

- (void)activateCopyingStateForNumber:(float)number copyInputType:(TJBCopyInputType)copyInputType;
- (void)deactivateCopyingState;
- (void)didDragAcrossPointInView:(CGPoint)dragPoint copyInputType:(TJBCopyInputType)copyInputType;

// incrementing # exercises / rounds

- (void)didIncrementNumberOfExercisesInUpDirection:(BOOL)upDirection;
- (void)didIncrementNumberOfRoundsInUpDirection:(BOOL)upDirection;

// layout math

// switches

- (void)configureRowsForExerciseIndex:(int)exerciseIndex switchType:(TJBSwitchType)switchType activated:(BOOL)activated;

// routine name

- (void)routineNameDidUpdate:(NSString *)routineName;

// keyboard

- (void)dismissKeyboard;

@end






















