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
    float _primaryElapsedTimeInSeconds;
    float _secondaryElapsedTimeInSeconds;
    
    BOOL _incrementPrimaryElapsedTimeForwards;
    BOOL _incrementSecondaryElapsedTimeForwards;
}

@property (nonatomic, strong) NSTimer *stopwatch;
@property (nonatomic, strong) NSMutableSet *primaryTimeObservers;
@property (nonatomic, strong) NSMutableSet *secondaryTimeObservers;

@property (nonatomic, strong) NSMutableArray <UIViewController<TJBStopwatchObserver> *> *primaryStopwatchObserverVCs;

@property (nonatomic, strong) NSDate *dateAtLastUpdate;

@end

@implementation TJBStopwatch

#pragma mark - Singleton

+ (instancetype)singleton{
    
    static TJBStopwatch *singleton = nil;
    
    if (!singleton){
        
        singleton = [[self alloc] initPrivate];
        
    }
    
    return singleton;
    
}

- (instancetype)initPrivate{
    
    self = [super init];
    
    _primaryElapsedTimeInSeconds = 0;
    _secondaryElapsedTimeInSeconds = 0;
    
    self.primaryTimeObservers = [[NSMutableSet alloc] init];
    self.secondaryTimeObservers = [[NSMutableSet alloc] init];
    self.primaryStopwatchObserverVCs = [[NSMutableArray alloc] init];
    
    self.stopwatch = [NSTimer scheduledTimerWithTimeInterval: 1.0
                                                    target: self
                                                    selector: @selector(updateTimerLabels)
                                                    userInfo: nil
                                                     repeats: YES];
    
    return self;
    
}


- (instancetype)init{
    
    @throw [NSException exceptionWithName: @"Singleton"
                                   reason: @"Use +[TJBStopwatch singleton]"
                                 userInfo: nil];
    
}

#pragma mark - Internal Methods

- (void)updateTimerLabels{
    
    [self incrementTimers];
    
    for (UILabel *timerLabel in self.primaryTimeObservers){
        
        timerLabel.text = [self minutesAndSecondsStringFromNumberOfSeconds: _primaryElapsedTimeInSeconds];
        
    }
    
    for (UILabel *timerLabel in self.secondaryTimeObservers){
        
        timerLabel.text = [self minutesAndSecondsStringFromNumberOfSeconds: _secondaryElapsedTimeInSeconds];
        
    }
    
}

- (void)incrementTimers{
    
    // elapsed time
    
    NSDate *currentDate = [NSDate date];
    float elapsedTime;
    
    if (!self.dateAtLastUpdate){
        
        elapsedTime = 1.0;
        
    } else{
        
        elapsedTime = [currentDate timeIntervalSinceDate: self.dateAtLastUpdate];
        
    }
    
    // primary timer
    
    if (_incrementPrimaryElapsedTimeForwards == YES){
        
        _primaryElapsedTimeInSeconds += elapsedTime;
        
    } else{
        
        _primaryElapsedTimeInSeconds -= elapsedTime;
        
    }
    
    // secondary timer
    
    if (_incrementSecondaryElapsedTimeForwards == YES){
        
        _secondaryElapsedTimeInSeconds += elapsedTime;
        
    } else{
        
        _secondaryElapsedTimeInSeconds -= elapsedTime;
        
    }
    
    self.dateAtLastUpdate = currentDate;
    
    for (UIViewController<TJBStopwatchObserver> *vc in self.primaryStopwatchObserverVCs){
        
        [vc timerDidUpdateWithUpdateDate: currentDate];
        
    }
    
}



#pragma mark - Observers

- (void)addPrimaryStopwatchObserver:(UIViewController<TJBStopwatchObserver> *)viewController withTimerLabel:(UILabel *)timerLabel{
    
    //// add both the observing VC and timer label to their respective IVs
    
    [self.primaryStopwatchObserverVCs addObject: viewController];
    
    [self.primaryTimeObservers addObject: timerLabel];
    
}

- (void)addPrimaryStopwatchObserver:(UILabel *)timerLabel{
    
    [self.primaryTimeObservers addObject: timerLabel];
    
}

- (void)removePrimaryStopwatchObserver:(UILabel *)timerLabel{
    
    [self.primaryTimeObservers removeObject: timerLabel];
    
    return;
    
}

- (void)addSecondaryStopwatchObserver:(UILabel *)timerLabel
{
    [self.secondaryTimeObservers addObject: timerLabel];
}

#pragma mark - Stopwatch Manipulation

- (void)resetPrimaryStopwatchWithForwardIncrementing:(BOOL)forwardIncrementing{
    
    _primaryElapsedTimeInSeconds = 0;
    
    _incrementPrimaryElapsedTimeForwards = forwardIncrementing;
    
    self.dateAtLastUpdate = nil;
    
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

- (void)setPrimaryStopWatchToTimeInSeconds:(int)timeInSeconds withForwardIncrementing:(BOOL)forwardIncrementing lastUpdateDate:(NSDate *)lastUpdateDate{
    
    _primaryElapsedTimeInSeconds = timeInSeconds;
    
    _incrementPrimaryElapsedTimeForwards = forwardIncrementing;
    
    self.dateAtLastUpdate = lastUpdateDate;
    
}

//- (void)incrementSecondaryStopwatchForwardByNumberOfSeconds:(int)seconds

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

- (NSString *)minutesAndSecondsStringFromNumberOfSeconds:(int)numberOfSeconds{
    
    if (numberOfSeconds < 0)
        
    {
        numberOfSeconds *= -1;
        
        int minutes = numberOfSeconds / 60;
        int seconds = numberOfSeconds % 60;
        
        return [NSString stringWithFormat: @"-%02d:%02d", minutes, seconds];
        
    } else{
        
        int minutes = numberOfSeconds / 60;
        int seconds = numberOfSeconds % 60;
        
        return [NSString stringWithFormat: @"%02d:%02d", minutes, seconds];
        
    }
    
}

@end






























