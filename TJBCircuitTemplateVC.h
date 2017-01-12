//
//  TJBCircuitTemplateVC.h
//  Beast
//
//  Created by Trevor Beasty on 1/10/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TJBCircuitTemplateVCProtocol.h"

@interface TJBCircuitTemplateVC : UIViewController <TJBCircuitTemplateVCProtocol>

- (instancetype)initWithSkeletonChainTemplate:(TJBChainTemplate *)skeletonChainTemplate viewHeight:(NSNumber *)viewHeight viewWidth:(NSNumber *)viewWidth;

@end
