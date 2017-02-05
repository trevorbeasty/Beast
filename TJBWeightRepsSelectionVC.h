//
//  TJBWeightRepsSelectionVC.h
//  Beast
//
//  Created by Trevor Beasty on 2/4/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CancelBlock)(void);
typedef void(^NumberSelectedBlockDouble)(NSNumber *, NSNumber *);

@interface TJBWeightRepsSelectionVC : UIViewController

- (instancetype)initWithTitle:(NSString *)title cancelBlock:(CancelBlock)cancelBlock numberSelectedBlock:(NumberSelectedBlockDouble)numberSelectedBlock;

@end
