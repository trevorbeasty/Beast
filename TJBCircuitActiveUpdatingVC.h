//
//  TJBCircuitActiveUpdatingVC.h
//  Beast
//
//  Created by Trevor Beasty on 1/11/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

// protocol

#import "TJBCircuitActiveUpdatingVCProtocol.h"

// core data

@class TJBRealizedChain;

@interface TJBCircuitActiveUpdatingVC : UIViewController <TJBCircuitActiveUpdatingVCProtocol>

- (instancetype)initWithRealizedChain:(TJBRealizedChain *)realizedChain viewHeight:(NSNumber *)viewHeight viewWidth:(NSNumber *)viewWidth;

@end
