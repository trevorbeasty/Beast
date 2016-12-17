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
    int _elapsedTimeInSeconds;
    BOOL _isRunning;
}

@property (nonatomic, strong) NSTimer *stopwatch;
@property (nonatomic, strong) NSMutableSet *observers;

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
    
    _elapsedTimeInSeconds = 0;
    self.observers = [[NSMutableSet alloc] init];
    
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

- (void)updateTimerLabels
{
    _elapsedTimeInSeconds++;
    
    NSString *elapsedTimeAsString = [self elapsedTimeAsFormattedString];
    
    for (UILabel *timerLabel in self.observers)
    {
        timerLabel.text = elapsedTimeAsString;
    }
}

- (NSString *)elapsedTimeAsFormattedString
{
    int minutes = _elapsedTimeInSeconds / 60;
    int seconds = _elapsedTimeInSeconds % 60;
    
    return [NSString stringWithFormat: @"%02d:%02d", minutes, seconds];
}

#pragma mark - Observers

- (void)addStopwatchObserver:(UILabel *)timerLabel
{
    [self.observers addObject: timerLabel];
}

- (void)removeStopwatchObserver:(UILabel *)timerLabel
{
    
}

#pragma mark - Stopwatch Manipulation

- (void)resetStopwatch
{
    _elapsedTimeInSeconds = 0;
}

- (void)playStopwatch
{
    
}

- (void)pauseStopwatch
{
    
}

#pragma mark - Getters

- (NSNumber *)timeElapsedInSeconds
{
    return [NSNumber numberWithFloat: _elapsedTimeInSeconds];
}

- (NSNumber *)isRunning
{
    return [NSNumber numberWithBool: _isRunning];
}


@end






























