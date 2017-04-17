//
//  TJBCompleteChainHistoryVC.h
//  Beast
//
//  Created by Trevor Beasty on 2/23/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TJBChainTemplate;

@interface TJBCompleteChainHistoryVC : UIViewController



- (instancetype)initWithChainTemplate:(TJBChainTemplate *)chainTemplate;
- (instancetype)initWithChainTemplate:(TJBChainTemplate *)chainTemplate tableViewBreatherRoom:(CGFloat)tableViewBreatherRoom;

- (CGFloat)contentHeight;

@end
