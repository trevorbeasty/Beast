//
//  TJBCircuitModeTBC.h
//  Beast
//
//  Created by Trevor Beasty on 1/8/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TJBChainTemplate;
@class TJBRealizedChain;

@interface TJBCircuitModeTBC : UITabBarController

- (instancetype)initWithNewRealizedChainAndChainTemplateFromChainTemplate:(TJBChainTemplate *)chainTemplate;

//- (instancetype)initWithPartiallyCompletedRealizedChain:(TJBRealizedChain *)realizedChain andChainTemplate:(TJBChainTemplate *)chainTemplate;

@end
