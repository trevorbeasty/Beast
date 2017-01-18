//
//  TJBStopwatch.h
//  Beast
//
//  Created by Trevor Beasty on 12/9/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// protocol

#import "TJBStopwatchObserver.h"

@interface TJBStopwatch : NSObject

@property (nonatomic, strong, readonly) NSNumber *primaryTimeElapsedInSeconds;
@property (nonatomic, strong, readonly) NSNumber *secondaryTimeElapsedInSeconds;

+ (instancetype)singleton;

//- (void)addPrimaryStopwatchObserver:(UILabel *)timerLabel;
- (void)removePrimaryStopwatchObserver:(UILabel *)timerLabel;

- (void)addPrimaryStopwatchObserver:(UIViewController<TJBStopwatchObserver> *)viewController withTimerLabel:(UILabel *)timerLabel;

- (void)addSecondaryStopwatchObserver:(UILabel *)timerLabel;

//- (void)resetPrimaryStopwatchWithForwardIncrementing:(BOOL)forwardIncrementing;
//- (void)resetSecondaryStopwatchWithForwardIncrementing:(BOOL)forwardIncrementing;

//- (void)setPrimaryStopWatchToTimeInSeconds:(int)timeInSeconds withForwardIncrementing:(BOOL)forwardIncrementing;

- (void)setPrimaryStopWatchToTimeInSeconds:(int)timeInSeconds withForwardIncrementing:(BOOL)forwardIncrementing lastUpdateDate:(NSDate *)lastUpdateDate;

- (void)setSecondaryStopWatchToTimeInSeconds:(int)timeInSeconds withForwardIncrementing:(BOOL)forwardIncrementing;

- (NSString *)minutesAndSecondsStringFromNumberOfSeconds:(int)numberOfSeconds;

- (NSString *)primaryTimeElapsedAsString;
- (NSString *)secondaryTimeElapsedAsString;

@end
