//
//  TJBInSetVC.m
//  Beast
//
//  Created by Trevor Beasty on 12/22/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import "TJBInSetVC.h"

#import "TJBStopwatch.h"

@interface TJBInSetVC ()

{
    int _timeDelay;
}

@property (weak, nonatomic) IBOutlet UILabel *timerLabel;

- (IBAction)didPressSetCompleted:(id)sender;

@property (copy) void(^didPressSetCompletedBlock)(int);

@end



@implementation TJBInSetVC

#pragma mark - Instantiation

- (id)initWithTimeDelay:(int)timeDelay DidPressSetCompletedBlock:(void (^)(int))block
{
    self = [super init];
    
    _timeDelay = timeDelay * -1;
    self.didPressSetCompletedBlock = block;
    
    return self;
}

-(void)viewDidLoad
{
    // stopwatch
    
    TJBStopwatch *stopwatch = [TJBStopwatch singleton];
    [stopwatch setSecondaryStopWatchToTimeInSeconds: _timeDelay];
    [stopwatch addSecondaryStopwatchObserver: self.timerLabel];
    
    // timer label
    
    self.timerLabel.text = [[TJBStopwatch singleton] minutesAndSecondsStringFromNumberOfSeconds: _timeDelay];
}

#pragma mark - Button Actions

- (IBAction)didPressSetCompleted:(id)sender
{
    self.didPressSetCompletedBlock([[[TJBStopwatch singleton] secondaryTimeElapsedInSeconds] intValue]);
}


@end
