//
//  TJBCircuitTemplateContainerVC.h
//  Beast
//
//  Created by Trevor Beasty on 1/10/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

// core data

@class TJBChainTemplate;

typedef void(^TJBVoidCallback)(void);

@interface TJBCircuitTemplateContainerVC : UIViewController

- initWithCallback:(TJBVoidCallback)callback;

#pragma mark - Core Data Management

- (void)deleteActiveChainTemplate;

@end
