//
//  TJBCircuitTemplateRowComponentProtocol.h
//  Beast
//
//  Created by Trevor Beasty on 1/10/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <Foundation/Foundation.h>

@class TJBNumberTypeArrayComp;

@protocol TJBCircuitTemplateRowComponentProtocol <NSObject>

- (void)updateWeightViewWithUserSelection:(TJBNumberTypeArrayComp *)weight;

- (void)updateRepsViewWithUserSelection:(TJBNumberTypeArrayComp *)reps;

- (void)updateRestViewWithUserSelection:(TJBNumberTypeArrayComp *)rest;

@end
