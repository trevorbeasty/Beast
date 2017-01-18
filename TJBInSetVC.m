//
//  TJBInSetVC.m
//  Beast
//
//  Created by Trevor Beasty on 12/22/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import "TJBInSetVC.h"

#import "TJBStopwatch.h"

#import "TJBAestheticsController.h"

@interface TJBInSetVC ()

{
    int _timeDelay;
}

@property (weak, nonatomic) IBOutlet UILabel *timerLabel;

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
- (IBAction)didPressSetCompleted:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *setCompletedButton;

@property (copy) void(^didPressSetCompletedBlock)(int);
@property (nonatomic, strong) NSString *exerciseName;

@end

@implementation TJBInSetVC

#pragma mark - View Life Cycle

-(void)viewDidLoad{
    
    // stopwatch
    
    TJBStopwatch *stopwatch = [TJBStopwatch singleton];
    
    [stopwatch setSecondaryStopWatchToTimeInSeconds: _timeDelay
                            withForwardIncrementing: YES
                                     lastUpdateDate: nil];
    
    [stopwatch addSecondaryStopwatchObserver: nil
                              withTimerLabel: self.timerLabel];
    
    self.timerLabel.text = [[TJBStopwatch singleton] minutesAndSecondsStringFromNumberOfSeconds: _timeDelay];
    
    // background
    
    UIImage *image = [UIImage imageNamed: @"barbell"];
    [[TJBAestheticsController singleton] addFullScreenBackgroundViewWithImage: image
                                                                   toRootView: self.view];
    
    [self viewAesthetics];
    
    [self configureNavBar];
}

- (void)viewAesthetics{
    self.timerLabel.layer.masksToBounds = YES;
    self.timerLabel.layer.cornerRadius = 4;
    self.timerLabel.layer.opacity = .85;
    
    [[TJBAestheticsController singleton] configureButtonsInArray: @[self.setCompletedButton]
                                                     withOpacity: 85];
}

#pragma mark - Instantiation

- (id)initWithTimeDelay:(int)timeDelay DidPressSetCompletedBlock:(void (^)(int))block exerciseName:(NSString *)exerciseName{
    self = [super init];
    
    _timeDelay = timeDelay * -1;
    
    self.didPressSetCompletedBlock = block;
    
    self.exerciseName = exerciseName;
    
    return self;
}

- (void)configureNavBar{
    NSString *title = [NSString stringWithFormat: @"In Set: %@",
                       self.exerciseName];
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle: title];
    [self.navBar setItems: @[navItem]];
}

#pragma mark - Button Actions

- (IBAction)didPressSetCompleted:(id)sender
{
    self.didPressSetCompletedBlock([[[TJBStopwatch singleton] secondaryTimeElapsedInSeconds] intValue]);
}


@end



















