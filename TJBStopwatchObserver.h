//
//  TJBStopwatchObserver.h
//  Beast
//
//  Created by Trevor Beasty on 1/18/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TJBStopwatchObserver <NSObject>

- (void)primaryTimerDidUpdateWithUpdateDate:(NSDate *)date timerValue:(float)timerValue;

- (void)secondaryTimerDidUpdateWithUpdateDate:(NSDate *)date;

@end
