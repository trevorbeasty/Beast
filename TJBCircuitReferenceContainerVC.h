//
//  TJBCircuitReferenceContainerVC.h
//  Beast
//
//  Created by Trevor Beasty on 1/11/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TJBRealizedChain;

@interface TJBCircuitReferenceContainerVC : UIViewController

#pragma mark - Instantiation

- (instancetype)initWithDataObject:(id)dataObject;

#pragma mark - View Math

- (CGFloat)returnButtonBufferHeight;

@end
