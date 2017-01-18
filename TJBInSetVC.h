//
//  TJBInSetVC.h
//  Beast
//
//  Created by Trevor Beasty on 12/22/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

// protocol

#import "TJBStopwatchObserver.h"

@interface TJBInSetVC : UIViewController 

- initWithTimeDelay:(float)timeDelay DidPressSetCompletedBlock:(void(^)(int))block exerciseName:(NSString *)exerciseName lastTimerUpdateDate:(NSDate *)lastUpdateDate masterController:(UIViewController<TJBStopwatchObserver> *)masterController;

@end
