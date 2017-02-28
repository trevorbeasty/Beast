//
//  TJBSetCompletedSummaryVC.h
//  Beast
//
//  Created by Trevor Beasty on 2/28/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^TJBCompletedSetCallback)(void);

@interface TJBSetCompletedSummaryVC : UIViewController

- (instancetype)initWithExerciseName:(NSString *)exerciseName weight:(NSNumber *)weight reps:(NSNumber *)reps callbackBlock:(TJBCompletedSetCallback)callbackBlock;

@end
