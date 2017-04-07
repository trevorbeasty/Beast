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

- (instancetype)initWithSkeletonChainTemplate:(TJBChainTemplate *)skeletonChainTemplate viewSize:(CGSize)viewSize;

- (instancetype)initWithSkeletonChainTemplate:(TJBChainTemplate *)skeletonChainTemplate startingNumberOfExercises:(NSNumber *)startingNumberOfExercises startingNumberOfRounds:(NSNumber *)startingNumberOfRounds;

@property (strong, readonly) NSNumber *numberOfRounds;

@end
