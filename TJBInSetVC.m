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
    float _timeDelay;
}

@property (weak, nonatomic) IBOutlet UILabel *timerLabel;

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
- (IBAction)didPressSetCompleted:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *setCompletedButton;

@property (copy) void(^didPressSetCompletedBlock)(int);
@property (nonatomic, strong) NSString *exerciseName;

@property (nonatomic, weak) UIViewController<TJBStopwatchObserver> *masterController;

@end

@implementation TJBInSetVC

#pragma mark - View Life Cycle

-(void)viewDidLoad{
    
    // stopwatch
    
    TJBStopwatch *stopwatch = [TJBStopwatch singleton];
    
    [stopwatch addSecondaryStopwatchObserver: self.masterController
                              withTimerLabel: self.timerLabel];
    
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

- (id)initWithTimeDelay:(float)timeDelay DidPressSetCompletedBlock:(void (^)(int))block exerciseName:(NSString *)exerciseName lastTimerUpdateDate:(NSDate *)lastUpdateDate masterController:(UIViewController<TJBStopwatchObserver> *)masterController{
    
    self = [super init];
    
    _timeDelay = timeDelay * -1;
    
    self.didPressSetCompletedBlock = block;
    
    self.exerciseName = exerciseName;
    
    self.masterController = masterController;
    
    [[TJBStopwatch singleton] setSecondaryStopWatchToTimeInSeconds: _timeDelay
                                           withForwardIncrementing: YES
                                                    lastUpdateDate: lastUpdateDate];
    
    return self;
    
}


- (void)configureNavBar{
    
    NSString *title = [NSString stringWithFormat: @"%@",
                       self.exerciseName];
    
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle: title];
    
    [self.navBar setItems: @[navItem]];
    
    // nav bar text appearance
    
    [self.navBar setTitleTextAttributes: @{NSFontAttributeName: [UIFont boldSystemFontOfSize: 25.0]}];
    
}

#pragma mark - Button Actions

- (IBAction)didPressSetCompleted:(id)sender
{
    self.didPressSetCompletedBlock([[[TJBStopwatch singleton] secondaryTimeElapsedInSeconds] intValue]);
}


@end



















