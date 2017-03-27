//
//  TJBSearchExerciseChild.h
//  Beast
//
//  Created by Trevor Beasty on 3/26/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TJBSearchExerciseChild : UIViewController

- (instancetype)initWithListButtonCallback:(void (^)(void))lbCallback searchTextFieldCallback:(void (^)(NSString *))stfCallback;

- (void)makeSearchTextFieldFirstResponder;
- (void)makeSearchTextFieldResignFirstResponder;


@end
