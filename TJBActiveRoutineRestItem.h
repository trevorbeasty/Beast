//
//  TJBActiveRoutineRestItem.h
//  Beast
//
//  Created by Trevor Beasty on 2/11/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TJBActiveRoutineRestItem : UIViewController

- (instancetype)initWithTitleNumber:(NSNumber *)titleNumber contentText:(NSString *)contentText isCompletionButton:(BOOL)isCompletionButton callback:(void (^)(void))callback;

@end
