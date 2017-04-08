//
//  TJBSwitchRow.h
//  Beast
//
//  Created by Trevor Beasty on 4/8/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

// master controller

@class TJBCircuitTemplateVC;
#import "TJBCircuitTemplateVCProtocol.h"

@interface TJBSwitchRow : UIViewController

- (instancetype)initWithExerciseIndex:(int)exerciseIndex masterController:(TJBCircuitTemplateVC <TJBCircuitTemplateVCProtocol> *)masterController;

@end
