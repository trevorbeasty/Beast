//
//  TJBExerciseSelectionScene.h
//  Beast
//
//  Created by Trevor Beasty on 12/19/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

@class TJBExercise;

@interface TJBExerciseSelectionScene : UIViewController

- (instancetype)initWithTitle:(NSString *)title callbackBlock:(void(^)(TJBExercise *))block;

@end
