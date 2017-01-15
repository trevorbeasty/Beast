//
//  TJBCircuitActiveUpdatingContainerVC.h
//  Beast
//
//  Created by Trevor Beasty on 1/11/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

// child VC

@class TJBCircuitActiveUpdatingVC;
#import "TJBCircuitActiveUpdatingVCProtocol.h"

// core data

@class TJBRealizedChain;

@interface TJBCircuitActiveUpdatingContainerVC : UIViewController

// this property is necessary in order to facillitate delegate methods between 'active updating' and 'active guidance'

@property (nonatomic, strong) TJBCircuitActiveUpdatingVC <TJBCircuitActiveUpdatingVCProtocol> *circuitActiveUpdatingVC;

- (instancetype)initWithRealizedChain:(TJBRealizedChain *)realizedChain;

@end
