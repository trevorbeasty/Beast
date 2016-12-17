//
//  TJBCircuitTemplateInputDelegate.h
//  Beast
//
//  Created by Trevor Beasty on 12/16/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TJBCircuitTemplateInputDelegate <NSObject>

- (void)didPressInputButtonWithType:(NSString *)buttonType;

@end
