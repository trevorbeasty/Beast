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

@property (nonatomic, strong, readonly) NSNumber *primaryTimeElapsedInSeconds;
@property (nonatomic, strong, readonly) NSNumber *secondaryTimeElapsedInSeconds;

+ (instancetype)singleton;

- (void)addPrimaryStopwatchObserver:(UILabel *)timerLabel;
- (void)addSecondaryStopwatchObserver:(UILabel *)timerLabel;

- (void)resetPrimaryStopwatch;
- (void)resetSecondaryStopwatch;

- (void)setSecondaryStopWatchToTimeInSeconds:(int)timeInSeconds;

- (NSString *)minutesAndSecondsStringFromNumberOfSeconds:(int)numberOfSeconds;

- (NSString *)primaryTimeElapsedAsString;
- (NSString *)secondaryTimeElapsedAsString;

@end
