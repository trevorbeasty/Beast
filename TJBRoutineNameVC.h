//
//  TJBRoutineNameVC.h
//  Beast
//
//  Created by Trevor Beasty on 4/10/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TJBCircuitTemplateVCProtocol.h"
@class TJBCircuitTemplateVC;


@interface TJBRoutineNameVC : UIViewController

- (instancetype)initWithMasterController:(TJBCircuitTemplateVC <TJBCircuitTemplateVCProtocol> *)masterController;

// text field / keyboard

- (void)dismissKeyboard;

@end
