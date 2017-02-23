//
//  TJBCircuitTemplateRowComponentProtocol.h
//  Beast
//
//  Created by Trevor Beasty on 1/10/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <Foundation/Foundation.h>

// import global parameters for typedef of TJBCopyInputValue

#import "TJBGlobalParameters.h"

@class TJBNumberTypeArrayComp;

@protocol TJBCircuitTemplateRowComponentProtocol <NSObject>

- (void)activeCopyingStateForNumber:(float)number copyInputType:(TJBCopyInputType)copyInputType;
- (void)deactivateCopyingState;

- (void)copyValueForWeightButton;
- (void)copyValueForRepsButton;
- (void)copyValueForRestButton;

@end
