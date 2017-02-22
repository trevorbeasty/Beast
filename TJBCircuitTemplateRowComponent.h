//
//  TJBCircuitTemplateRowComponent.h
//  Beast
//
//  Created by Trevor Beasty on 1/10/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TJBCircuitTemplateVC;
@class TJBChainTemplate;

// protocols

#import "TJBCircuitTemplateVCProtocol.h"
#import "TJBCircuitTemplateRowComponentProtocol.h"

@interface TJBCircuitTemplateRowComponent : UIViewController <TJBCircuitTemplateRowComponentProtocol>

- (instancetype)initWithChainTemplate:(TJBChainTemplate *)chainTemplate masterController:(TJBCircuitTemplateVC<TJBCircuitTemplateVCProtocol> *)masterController exerciseIndex:(int)exerciseIndex roundIndex:(int)roundIndex;

@property (weak, nonatomic) IBOutlet UIButton *weightButton;

@end
