//
//  TJBActiveCircuitGuidance.h
//  Beast
//
//  Created by Trevor Beasty on 12/24/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

//#import "TJBCircuitTemplateUserInputDelegate.h"

@class TJBChainTemplate;
@class TJBRealizedChain;

// associated VC

#import "TJBCircuitActiveUpdatingVCProtocol.h"
@class TJBCircuitActiveUpdatingVC;



@interface TJBActiveCircuitGuidance : UIViewController

- (instancetype)initWithChainTemplate:(TJBChainTemplate *)chainTemplate realizedChainCorrespondingToChainTemplate:(TJBRealizedChain *)realizedChain circuitActiveUpdatingVC:(TJBCircuitActiveUpdatingVC<TJBCircuitActiveUpdatingVCProtocol> *)circuitActiveUpdatingVC wasRestored:(BOOL)wasRestored;

@end
