//
//  TJBActiveRoutineGuidanceVC.h
//  Beast
//
//  Created by Trevor Beasty on 2/9/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

// core data

@class TJBChainTemplate;
@class TJBRealizedChain;

@interface TJBActiveRoutineGuidanceVC : UIViewController

// this is here because it is created in this class' init method and other tab bar VC's need it

@property (nonatomic, strong) TJBRealizedChain *realizedChain;

#pragma mark - Instantiation

- (instancetype)initFreshRoutineWithChainTemplate:(TJBChainTemplate *)chainTemplate;
//- (instancetype)initWithPartiallyCompletedRealizedChain:(TJBRealizedChain *)rc;

@end
