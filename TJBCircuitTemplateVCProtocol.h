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

//- (void)didPressExerciseButton:(UIButton *)button inChain:(NSNumber *)chainNumber;
//
//- (void)didPressUserInputButtonWithType:(NumberType)type chainNumber:(NSNumber *)chainNumber roundNumber:(NSNumber *)roundNumber button:(UIButton *)button;
//
// for keeping track of child VC's

- (void)addChildRowController:(TJBCircuitTemplateRowComponent<TJBCircuitTemplateRowComponentProtocol> *)rowController forExerciseIndex:(int)exerciseIndex;

- (BOOL)allUserInputCollected;
//
//// for restoration / incomplete chain templates
//
//- (void)populateChildVCViewsWithUserSelectedValues;

// advanced user input



@end
