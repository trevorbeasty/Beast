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

@interface TJBActiveRoutineGuidanceVC : UIViewController

- (instancetype)initFreshRoutineWithChainTemplate:(TJBChainTemplate *)chainTemplate;

- (void)didPressBack;

@end
