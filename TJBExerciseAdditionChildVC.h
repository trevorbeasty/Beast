//
//  TJBExerciseAdditionChildVC.h
//  Beast
//
//  Created by Trevor Beasty on 3/24/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TJBExerciseAdditionChildVC : UIViewController

- (instancetype)initWithExerciseAdditionCallback:(void (^)(NSString *, NSNumber *, BOOL))eaCallback listCallback:(void (^)(void))lCallback;

- (void)makeExerciseTFFirstResponder;
- (void)makeExerciseTFResignFirstResponder;

@end
