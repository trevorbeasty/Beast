//
//  TJBActiveCircuitGuidance.h
//  Beast
//
//  Created by Trevor Beasty on 12/24/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TJBCircuitTemplateUserInputDelegate.h"

@class TJBChainTemplate;
@class TJBCircuitTemplateGeneratorVC;

@interface TJBActiveCircuitGuidance : UIViewController

- (instancetype)initWithChainTemplate:(TJBChainTemplate *)chainTemplate circuitTemplateGenerator:(TJBCircuitTemplateGeneratorVC<TJBCircuitTemplateUserInputDelegate> *)circuitTemplateGenerator;

@end
