//
//  TJBCircuitTemplateUserInputDelegate.h
//  Beast
//
//  Created by Trevor Beasty on 12/18/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "TJBGlobalParameters.h"

@protocol TJBCircuitTemplateUserInputDelegate <NSObject>

- (void)didPressUserInputButtonWithType:(NumberType)type chainNumber:(NSNumber *)chainNumber roundNumber:(NSNumber *)roundNumber button:(UIButton *)button;

@end
