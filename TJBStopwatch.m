//
//  TJBStopwatch.m
//  Beast
//
//  Created by Trevor Beasty on 12/9/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import "TJBStopwatch.h"

@interface TJBStopwatch ()

{
    int _primaryElapsedTimeInSeconds;
    int _secondaryElapsedTimeInSeconds;
    
    BOOL _incrementPrimaryElapsedTimeForwards;
    BOOL _incrementSecondaryElapsedTimeForwards;
}

@property (nonatomic, strong) NSTimer *stopwatch;
@property (nonatomic, strong) NSMutableSet *primaryTimeObservers;
@property (nonatomic, strong) NSMutableSet *secondaryTimeObservers;

@end

@implementation TJBStopwatch

#pragma mark - Singleton

+ (instancetype)singleton
{
    static TJBStopwatch *singleton = nil;
    
    if (!singleton)
    {
        singleton = [[self alloc] initPrivate];
    }
    return singleton;
}

- (instancetype)initPrivate
{
    self = [super init];
    
    _primaryElapsedTimeInSeconds = 0;
    _secondaryElapsedTimeInSeconds = 0;
    
    self.primaryTimeObservers = [[NSMutableSet alloc] init];
    self.secondaryTimeObservers = [[NSMutableSet alloc] init];
    
    self.stopwatch = [NSTimer scheduledTimerWithTimeInterval: 1.0
                                                        target: self
                                                    selector: @selector(updateTimerLabels)
                                                    userInfo: nil
                                                     repeats: YES];
    
    return self;
}

- (instancetype)init
{
    @throw [NSException exceptionWithName: @"Singleton"
                                   reason: @"Use +[TJBStopwatch singleton]"
                                 userInfo: nil];
}

#pragma mark - Internal Methods

- (void)updateTimerLabels{
    [self incrementPrimaryElapsedTime];
    [self incrementSecondaryElapsedTime];
    
    for (UILabel *timerLabel in self.primaryTimeObservers)
    {
        timerLabel.text = [self minutesAndSecondsStringFromNumberOfSeconds: _primaryElapsedTimeInSeconds];
    }
    
    for (UILabel *timerLable in self.secondaryTimeObservers)
    {
        timerLable.text = [self minutesAndSecondsStringFromNumberOfSeconds: _secondaryElapsedTimeInSeconds];
    }
}

- (void)incrementPrimaryElapsedTime{
    if (_incrementPrimaryElapsedTimeForwards == YES){
        _primaryElapsedTimeInSeconds++;
    }
    else{
        _primaryElapsedTimeInSeconds--;
    }
}

- (void)incrementSecondaryElapsedTime{
    if (_incrementSecondaryElapsedTimeForwards == YES){
        _secondaryElapsedTimeInSeconds++;
    }
    else{
        _secondaryElapsedTimeInSeconds--;
    }
}

#pragma mark - Observers

- (void)addPrimaryStopwatchObserver:(UILabel *)timerLabel
{
    [self.primaryTimeObservers addObject: timerLabel];
}

- (void)addSecondaryStopwatchObserver:(UILabel *)timerLabel
{
    [self.secondaryTimeObservers addObject: timerLabel];
}

#pragma mark - Stopwatch Manipulation

- (void)resetPrimaryStopwatchWithForwardIncrementing:(BOOL)forwardIncrementing
{
    _primaryElapsedTimeInSeconds = 0;
    _incrementPrimaryElapsedTimeForwards = forwardIncrementing;
}

- (void)resetSecondaryStopwatchWithForwardIncrementing:(BOOL)forwardIncrementing
{
    _secondaryElapsedTimeInSeconds = 0;
    _incrementSecondaryElapsedTimeForwards = forwardIncrementing;
}

- (void)setPrimaryStopWatchToTimeInSeconds:(int)timeInSeconds withForwardIncrementing:(BOOL)forwardIncrementing{
    _primaryElapsedTimeInSeconds = timeInSeconds;
    _incrementPrimaryElapsedTimeForwards = forwardIncrementing;
}

- (void)setSecondaryStopWatchToTimeInSeconds:(int)timeInSeconds withForwardIncrementing:(BOOL)forwardIncrementing{
    _secondaryElapsedTimeInSeconds = timeInSeconds;
    _incrementSecondaryElapsedTimeForwards = forwardIncrementing;
}

#pragma mark - Getters

- (NSNumber *)primaryTimeElapsedInSeconds
{
    return [NSNumber numberWithInt: _primaryElapsedTimeInSeconds];
}

- (NSNumber *)secondaryTimeElapsedInSeconds
{
    return [NSNumber numberWithInt: _secondaryElapsedTimeInSeconds];
}

- (NSString *)primaryTimeElapsedAsString
{
    return [self minutesAndSecondsStringFromNumberOfSeconds: _primaryElapsedTimeInSeconds];
}

- (NSString *)secondaryTimeElapsedAsString
{
    return [self minutesAndSecondsStringFromNumberOfSeconds: _secondaryElapsedTimeInSeconds];
}

#pragma mark - Conversion

- (NSString *)minutesAndSecondsStringFromNumberOfSeconds:(int)numberOfSeconds
{
    if (numberOfSeconds < 0)
    {
        numberOfSeconds *= -1;
        
        int minutes = numberOfSeconds / 60;
        int seconds = numberOfSeconds % 60;
        
        return [NSString stringWithFormat: @"-%02d:%02d", minutes, seconds];
    }
    else
    {
        int minutes = numberOfSeconds / 60;
        int seconds = numberOfSeconds % 60;
        
        return [NSString stringWithFormat: @"%02d:%02d", minutes, seconds];
    }
}

@end






























