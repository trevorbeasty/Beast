//
//  TJBNumberJumpVC.h
//  Beast
//
//  Created by Trevor Beasty on 3/22/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TJBNumberJumpVC : UIViewController

- (instancetype)initWithLowerLimit:(NSNumber *)lowerLimit numberOfLabels:(NSNumber *)numberOfLabels intervalSize:(NSNumber *)intervalSize delegateCallback:(void (^)(NSNumber *))delegateCallback;

@end
