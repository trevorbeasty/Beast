//
//  TJBCircuitActiveUpdatingVCProtocol.h
//  Beast
//
//  Created by Trevor Beasty on 1/15/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <Foundation/Foundation.h>

// child VC

@class TJBCircuitActiveUpdatingRowComp;

#import "TJBCircuitActiveUpdatingRowCompProtocol.h"

@protocol TJBCircuitActiveUpdatingVCProtocol <NSObject>

// for keeping track of child VC's

- (void)addChildRowController:(TJBCircuitActiveUpdatingRowComp<TJBCircuitActiveUpdatingRowCompProtocol> *)rowController forExerciseIndex:(int)exerciseIndex;

@end
