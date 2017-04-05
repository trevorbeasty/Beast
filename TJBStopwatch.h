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

// singleton method

+ (instancetype)singleton;

// getters

@property (nonatomic, strong, readonly) NSNumber *primaryTimeElapsedInSeconds;
@property (nonatomic, strong, readonly) NSNumber *secondaryTimeElapsedInSeconds;

- (NSString *)primaryTimeElapsedAsString;
- (NSString *)secondaryTimeElapsedAsString;

// formatting

- (NSString *)minutesAndSecondsStringFromNumberOfSeconds:(int)numberOfSeconds;

// observer manipulation

- (void)updatePrimaryTimerLabels;

- (void)removePrimaryStopwatchObserver:(UILabel *)timerLabel;

- (void)removeAllPrimaryStopwatchObservers;

- (void)addPrimaryStopwatchObserver:(UIViewController<TJBStopwatchObserver> *)viewController withTimerLabel:(UILabel *)timerLabel;

- (void)addSecondaryStopwatchObserver:(UIViewController<TJBStopwatchObserver> *)viewController withTimerLabel:(UILabel *)timerLabel;

// timer core values manipulation

- (void)setPrimaryStopWatchToTimeInSeconds:(int)timeInSeconds withForwardIncrementing:(BOOL)forwardIncrementing lastUpdateDate:(NSDate *)lastUpdateDate;

- (void)setSecondaryStopWatchToTimeInSeconds:(int)timeInSeconds withForwardIncrementing:(BOOL)forwardIncrementing lastUpdateDate:(NSDate *)lastUpdateDate;

- (void)resetAndPausePrimaryTimer;

- (void)resetPrimaryTimer;
- (void)pausePrimaryTimer;
- (void)playPrimaryTimer;

// local notifications

- (void)setAlertParameters_targetRest:(NSNumber *)targetRest alertTiming:(NSNumber *)alertTiming;

@property (nonatomic, strong) NSNumber *targetRest;
@property (nonatomic, strong) NSNumber *alertTiming;

- (void)scheduleAlertBasedOnUserPermissions;
- (void)deleteActiveLocalAlert;

- (NSString *)alertTextFromTargetValues;

@end
