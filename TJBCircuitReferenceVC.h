//
//  TJBCircuitReferenceVC.h
//  Beast
//
//  Created by Trevor Beasty on 1/11/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TJBRealizedChain;

@interface TJBCircuitReferenceVC : UIViewController

//- (instancetype)initWithChainTemplate:(TJBChainTemplate *)chainTemplate contentViewHeight:(NSNumber *)viewHeight contentViewWidth:(NSNumber *)viewWidth;

- (instancetype)initWithRealizedChain:(TJBRealizedChain *)realizedChain viewSize:(CGSize)size;

@end
