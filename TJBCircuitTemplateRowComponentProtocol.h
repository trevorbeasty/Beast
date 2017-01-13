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

- (void)updateViewsWithUserSelectedWeight:(TJBNumberTypeArrayComp *)weight reps:(TJBNumberTypeArrayComp *)reps rest:(TJBNumberTypeArrayComp *)rest;

@end
