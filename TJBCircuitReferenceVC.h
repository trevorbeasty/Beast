//
//  TJBCircuitReferenceVC.h
//  Beast
//
//  Created by Trevor Beasty on 1/11/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TJBChainTemplate;

@interface TJBCircuitReferenceVC : UIViewController

- (instancetype)initWithChainTemplate:(TJBChainTemplate *)chainTemplate viewHeight:(NSNumber *)viewHeight viewWidth:(NSNumber *)viewWidth;

@end
