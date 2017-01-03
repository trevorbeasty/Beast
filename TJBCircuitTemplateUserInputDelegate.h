//
//  TJBCircuitTemplateUserInputDelegate.h
//  Beast
//
//  Created by Trevor Beasty on 12/18/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TJBGlobalParameters.h"

#import "RowComponentActiveUpdatingProtocol.h"

@class CircuitDesignRowComponent;


@protocol TJBCircuitTemplateUserInputDelegate <NSObject>

- (void)didPressUserInputButtonWithType:(NumberType)type chainNumber:(NSNumber *)chainNumber roundNumber:(NSNumber *)roundNumber button:(UIButton *)button;

- (void)didPressExerciseButton:(UIButton *)button inChain:(NSNumber *)chainNumber;

// child row controller collection
- (void)addChildRowController:(CircuitDesignRowComponent <RowComponentActiveUpdatingProtocol> *)rowController forExerciseIndex:(int)exerciseIndex roundIndex:(int)roundIndex;
- (void)userDidSelectNumber:(double)number withNumberType:(NumberType)numberType forExerciseIndex:(int)exerciseIndex forRoundIndex:(int)roundIndex;

@end
