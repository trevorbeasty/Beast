//
//  TJBStopwatch.m
//  Beast
//
//  Created by Trevor Beasty on 12/9/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

//// only the primary stopwatch observer keeps track of the update dates.  The primary stopwatch should always be used first and the secondary stopwatch should only be used if the primary stopwatch is already in immediate use.

#import "TJBStopwatch.h"

@interface TJBStopwatch ()

{
    float _primaryElapsedTimeInSeconds;
    float _secondaryElapsedTimeInSeconds;
    
    BOOL _incrementPrimaryElapsedTimeForwards;
    BOOL _incrementSecondaryElapsedTimeForwards;
    
    BOOL _primaryStopwatchIsOn;
    BOOL _secondaryStopwatchIsOn;
    
}

@property (nonatomic, strong) NSTimer *stopwatch;

@property (nonatomic, strong) NSMutableSet *primaryTimeObservers;
@property (nonatomic, strong) NSMutableSet *secondaryTimeObservers;

@property (nonatomic, strong) NSMutableArray <UIViewController<TJBStopwatchObserver> *> *primaryStopwatchObserverVCs;
@property (nonatomic, strong) NSMutableArray <UIViewController<TJBStopwatchObserver> *> *secondaryStopwatchObserverVCs;

@property (nonatomic, strong) NSDate *dateAtLastPrimaryUpdate;
@property (nonatomic, strong) NSDate *dateAtLastSecondaryUpdate;

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
    self.secondaryStopwatchObserverVCs = [[NSMutableArray alloc] init];
    
    _primaryStopwatchIsOn = NO;
    _secondaryStopwatchIsOn = NO;
    
    self.stopwatch = [NSTimer scheduledTimerWithTimeInterval: .1
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
    
    if (_primaryStopwatchIsOn){
        
        [self incrementPrimaryTimer];
        
        for (UILabel *timerLabel in self.primaryTimeObservers){
            
            timerLabel.text = [self minutesAndSecondsStringFromNumberOfSeconds: _primaryElapsedTimeInSeconds];
            
        }
        
    }
    
    if (_secondaryStopwatchIsOn){
        
        [self incrementSecondaryTimer];
        
        for (UILabel *timerLabel in self.secondaryTimeObservers){
            
            timerLabel.text = [self minutesAndSecondsStringFromNumberOfSeconds: _secondaryElapsedTimeInSeconds];
            
        }
        
    }
    
}

- (void)incrementPrimaryTimer{
    
    // elapsed time
    
    NSDate *currentDate = [NSDate date];
    float elapsedTime;
    
    if (!self.dateAtLastPrimaryUpdate){
        
        elapsedTime = .1;
        
    } else{
        
        elapsedTime = [currentDate timeIntervalSinceDate: self.dateAtLastPrimaryUpdate];
        
    }
    
    //  timer
    
    if (_incrementPrimaryElapsedTimeForwards == YES){
        
        _primaryElapsedTimeInSeconds += elapsedTime;
        
    } else{
        
        _primaryElapsedTimeInSeconds -= elapsedTime;
        
    }
    
    self.dateAtLastPrimaryUpdate = currentDate;
    
    for (UIViewController<TJBStopwatchObserver> *vc in self.primaryStopwatchObserverVCs){
        
        [vc primaryTimerDidUpdateWithUpdateDate: currentDate
                                     timerValue: _primaryElapsedTimeInSeconds];
        
    }
    
}

- (void)incrementSecondaryTimer{
    
    // elapsed time
    
    NSDate *currentDate = [NSDate date];
    float elapsedTime;
    
    if (!self.dateAtLastSecondaryUpdate){
        
        elapsedTime = .1;
        
    } else{
        
        elapsedTime = [currentDate timeIntervalSinceDate: self.dateAtLastSecondaryUpdate];
        
    }
    
    //  timer
    
    if (_incrementSecondaryElapsedTimeForwards == YES){
        
        _secondaryElapsedTimeInSeconds += elapsedTime;
        
    } else{
        
        _secondaryElapsedTimeInSeconds -= elapsedTime;
        
    }
    
    self.dateAtLastSecondaryUpdate = currentDate;
    
    for (UIViewController<TJBStopwatchObserver> *vc in self.secondaryStopwatchObserverVCs){
        
        [vc secondaryTimerDidUpdateWithUpdateDate: currentDate];
        
    }
    
}



#pragma mark - Observers

- (void)addPrimaryStopwatchObserver:(UIViewController<TJBStopwatchObserver> *)viewController withTimerLabel:(UILabel *)timerLabel{
    
    //// add both the observing VC and timer label to their respective IVs
    
    [self.primaryStopwatchObserverVCs addObject: viewController];
    
    [self.primaryTimeObservers addObject: timerLabel];
    
}

- (void)addSecondaryStopwatchObserver:(UIViewController<TJBStopwatchObserver> *)viewController withTimerLabel:(UILabel *)timerLabel{
    
    [self.secondaryStopwatchObserverVCs addObject: viewController];
    
    [self.secondaryTimeObservers addObject: timerLabel];
    
}



- (void)removePrimaryStopwatchObserver:(UILabel *)timerLabel{
    
    [self.primaryTimeObservers removeObject: timerLabel];
    
    return;
    
}

- (void)removeAllPrimaryStopwatchObservers{
    
    self.primaryTimeObservers = [[NSMutableSet alloc] init];
    
}



#pragma mark - Stopwatch Manipulation



- (void)setSecondaryStopWatchToTimeInSeconds:(int)timeInSeconds withForwardIncrementing:(BOOL)forwardIncrementing lastUpdateDate:(NSDate *)lastUpdateDate{
    
    _secondaryStopwatchIsOn = YES;
    
    _secondaryElapsedTimeInSeconds = timeInSeconds;
    
    _incrementSecondaryElapsedTimeForwards = forwardIncrementing;
    
    if (lastUpdateDate){
        
        self.dateAtLastSecondaryUpdate = lastUpdateDate;
        
    }
    
}

- (void)setPrimaryStopWatchToTimeInSeconds:(int)timeInSeconds withForwardIncrementing:(BOOL)forwardIncrementing lastUpdateDate:(NSDate *)lastUpdateDate{
    
    _primaryStopwatchIsOn = YES;
    
    if (lastUpdateDate){
        
        NSDate *now = [NSDate date];
        int elapsedTimeSinceLastUpdate = [now timeIntervalSinceDate: lastUpdateDate];
        
        self.dateAtLastPrimaryUpdate = now;
        
        _primaryElapsedTimeInSeconds = timeInSeconds + elapsedTimeSinceLastUpdate;
        
    } else{
        
        _primaryElapsedTimeInSeconds = timeInSeconds;
        self.dateAtLastPrimaryUpdate = [NSDate date];
        
    }
    
    _incrementPrimaryElapsedTimeForwards = forwardIncrementing;
    
}


#pragma mark - Getters

- (NSNumber *)primaryTimeElapsedInSeconds
{
    return [NSNumber numberWithInt: _primaryElapsedTimeInSeconds];
}

- (NSNumber *)secondaryTimeElapsedInSeconds{
    
    return [NSNumber numberWithFloat: _secondaryElapsedTimeInSeconds];
    
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

#pragma mark - Direct Timer Manipulation

- (void)resetAndPausePrimaryTimer{
    
    _primaryStopwatchIsOn = NO;
    _primaryElapsedTimeInSeconds = 0;
    
}

@end






























