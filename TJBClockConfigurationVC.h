//
//  TJBClockConfigurationVC.h
//  Beast
//
//  Created by Trevor Beasty on 4/1/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef  void(^VoidBlock)(void);
typedef  void(^AlertParametersBlock)(NSNumber *, NSNumber *);

@interface TJBClockConfigurationVC : UIViewController

// instantiation

- (instancetype)initWithApplyAlertParametersCallback:(AlertParametersBlock)applyAlertParamBlock cancelCallback:(VoidBlock)cancelBlock;
- (instancetype)initWithApplyAlertParametersCallback:(AlertParametersBlock)applyAlertParamBlock cancelCallback:(VoidBlock)cancelBlock restTargetIsStatic:(BOOL)restTargetIsStatic;

@end
