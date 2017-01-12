//
//  TJBCircuitTemplateVCProtocol.h
//  Beast
//
//  Created by Trevor Beasty on 1/10/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TJBNumberSelectionVC.h"

@class  TJBCircuitTemplateRowComponent;
@class TJBChainTemplate;

#import "TJBCircuitTemplateRowComponentProtocol.h"

@protocol TJBCircuitTemplateVCProtocol <NSObject>

- (void)didPressExerciseButton:(UIButton *)button inChain:(NSNumber *)chainNumber;

- (void)didPressUserInputButtonWithType:(NumberType)type chainNumber:(NSNumber *)chainNumber roundNumber:(NSNumber *)roundNumber button:(UIButton *)button;

- (void)addChildRowController:(TJBCircuitTemplateRowComponent<TJBCircuitTemplateRowComponentProtocol> *)rowController forExerciseIndex:(int)exerciseIndex roundIndex:(int)roundIndex;

- (BOOL)allInputCollected;

@end
