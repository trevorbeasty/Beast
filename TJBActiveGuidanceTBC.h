//
//  TJBActiveGuidanceTBC.h
//  Beast
//
//  Created by Trevor Beasty on 4/19/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

@class  TJBChainTemplate; // core data

@interface TJBActiveGuidanceTBC : UITabBarController

#pragma mark - Instantiation

- (instancetype)initWithChainTemplate:(TJBChainTemplate *)ct;

@end
