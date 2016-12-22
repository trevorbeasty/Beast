//
//  TJBStopwatch.h
//  Beast
//
//  Created by Trevor Beasty on 12/9/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TJBStopwatch : NSObject

@property (nonatomic, strong, readonly) NSNumber *timeElapsedInSeconds;
@property (nonatomic, strong, readonly) NSNumber *isRunning;
- (NSString *)elapsedTimeAsFormattedString;

+ (instancetype)singleton;

- (void)addStopwatchObserver:(UILabel *)timerLabel;
- (void)removeStopwatchObserver:(UILabel *)timerLabel;

- (void)resetStopwatch;
- (void)pauseStopwatch;
- (void)playStopwatch;

- (NSString *)minutesAndSecondsStringFromNumberOfSeconds:(int)numberOfSeconds;

@end
