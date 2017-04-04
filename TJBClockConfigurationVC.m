//
//  TJBClockConfigurationVC.m
//  Beast
//
//  Created by Trevor Beasty on 4/1/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBClockConfigurationVC.h"

// aesthetics

#import "TJBAestheticsController.h"

// stopwatch

#import "TJBStopwatch.h"

// number selection

#import "TJBNumberSelectionVC.h"

@interface TJBClockConfigurationVC () <TJBStopwatchObserver>

// IBOutlet

@property (weak, nonatomic) IBOutlet UILabel *myTimerLabel;
@property (weak, nonatomic) IBOutlet UILabel *timerValueLabel;

@property (weak, nonatomic) IBOutlet UILabel *targetRestTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *targetRestValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *alertTimingTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *alertTiimingValueLabel;

@property (weak, nonatomic) IBOutlet UIButton *editButtonTargetRest;
@property (weak, nonatomic) IBOutlet UIButton *editButtonAlertTiming;

@property (weak, nonatomic) IBOutlet UIButton *soundButtonTitleBar;

@property (weak, nonatomic) IBOutlet UIView *topTitleBar;
@property (weak, nonatomic) IBOutlet UIView *bottomTitleBar;
@property (weak, nonatomic) IBOutlet UIView *titleBarContainer;

@property (weak, nonatomic) IBOutlet UILabel *thinDividerLabel;

@property (weak, nonatomic) IBOutlet UIButton *restartButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
@property (weak, nonatomic) IBOutlet UIView *timerControlsContainer;
@property (weak, nonatomic) IBOutlet UILabel *timerControlsTitleLabel;

@property (weak, nonatomic) IBOutlet UIButton *returnButton;



// IBAction

- (IBAction)didPressSound:(id)sender;
- (IBAction)didPressExit:(id)sender;

- (IBAction)didPressEditTargetRest:(id)sender;
- (IBAction)didPressEditAlertTiming:(id)sender;

- (IBAction)didPressRestart:(id)sender;
- (IBAction)didPressPause:(id)sender;
- (IBAction)didPressPlay:(id)sender;

- (IBAction)didPressReturn:(id)sender;


// callback

@property (copy) VoidBlock cancelBlock;
@property (copy) AlertParametersBlock applyAlertParamBlock;

// core

@property (strong) NSNumber *selectedTargetRest;
@property (strong) NSNumber *selectedAlertTiming;



@end

@implementation TJBClockConfigurationVC

#pragma mark - Instantiation


- (instancetype)initWithApplyAlertParametersCallback:(AlertParametersBlock)applyAlertParamBlock cancelCallback:(VoidBlock)cancelBlock{
    
    self = [super init];
    
    self.cancelBlock = cancelBlock;
    self.applyAlertParamBlock = applyAlertParamBlock;
    
    return self;
    
}

#pragma mark - Instantiation Helper Methods


#pragma mark - View Life Cycle

- (void)viewDidLoad{
    
    [super viewDidLoad];
    
    [self configureViewAesthetics];
    
    [self copyStopwatchTargetsIfExist];
    
    [self registerTimerValueLabelWithStopwatch];
    [[TJBStopwatch singleton]  updatePrimaryTimerLabels];
    
    
}



#pragma mark - View Helper Methods

- (void)copyStopwatchTargetsIfExist{
    
    // have this controller start with the targets in the stopwatch, if they exist
    
    TJBStopwatch *stopwatch = [TJBStopwatch singleton];
    NSNumber *stopwatchRestTarget = stopwatch.targetRest;
    NSNumber *stopwatchAlertTiming = stopwatch.alertTiming;
    
    if (stopwatchRestTarget){
        
        self.selectedAlertTiming = stopwatchRestTarget;
        
        NSString *formattedRest = [stopwatch minutesAndSecondsStringFromNumberOfSeconds: [stopwatchRestTarget intValue]];
        self.targetRestValueLabel.text = formattedRest;
        
    }
    
    if (stopwatchAlertTiming){
        
        self.selectedTargetRest = stopwatchAlertTiming;
        
        NSString *formattedAlert = [stopwatch minutesAndSecondsStringFromNumberOfSeconds: [stopwatchAlertTiming intValue]];
        self.alertTiimingValueLabel.text = formattedAlert;
        
    }
    
    
        
}


- (void)configureViewAesthetics{
    
    // title bars and container
    
    self.topTitleBar.backgroundColor = [UIColor darkGrayColor];
    self.bottomTitleBar.backgroundColor = [UIColor darkGrayColor];
    self.titleBarContainer.backgroundColor = [UIColor blackColor];
    
    // meta view
    
    self.view.backgroundColor = [UIColor blackColor];
    
    // divider label
    
    self.thinDividerLabel.backgroundColor = [UIColor darkGrayColor];
    
    // time labels
    
    self.timerValueLabel.backgroundColor = [UIColor clearColor];
    self.timerValueLabel.font = [UIFont systemFontOfSize: 35];
    self.timerValueLabel.textColor = [UIColor whiteColor];
    
    NSArray *restTitleLabels = @[self.targetRestTitleLabel, self.alertTimingTitleLabel];
    for (UILabel *lab in restTitleLabels){
        
        lab.backgroundColor = [UIColor clearColor];
        lab.font = [UIFont boldSystemFontOfSize: 20];
        lab.textColor = [[TJBAestheticsController singleton] paleLightBlueColor];
        
    }
    
    NSArray *restValueLabels = @[self.targetRestValueLabel, self.alertTiimingValueLabel];
    for (UILabel *lab in restValueLabels){
        
        lab.backgroundColor = [UIColor clearColor];
        lab.font = [UIFont systemFontOfSize: 35];
        lab.textColor = [[TJBAestheticsController singleton] paleLightBlueColor];
        
    }
    
    // buttons
    
    NSArray *iconButtons = @[self.soundButtonTitleBar, self.restartButton, self.pauseButton, self.playButton];
    for (UIButton *butt in iconButtons){
        
        butt.backgroundColor = [UIColor clearColor];
        
    }
    
    NSArray *editButtons = @[self.editButtonTargetRest, self.editButtonAlertTiming];
    for (UIButton *butt in editButtons){
        
        butt.backgroundColor = [[TJBAestheticsController singleton] paleLightBlueColor];
        [butt setTitleColor: [UIColor darkGrayColor] forState: UIControlStateNormal];
        butt.titleLabel.font = [UIFont boldSystemFontOfSize: 20];
        
        CALayer *buttLayer = butt.layer;
        buttLayer.masksToBounds = YES;
        buttLayer.cornerRadius = 25;
        buttLayer.borderWidth = 1.0;
        buttLayer.borderColor = [UIColor darkGrayColor].CGColor;
        
    }
    
    self.returnButton.backgroundColor = [[TJBAestheticsController singleton] paleLightBlueColor];
    [self.returnButton setTitleColor: [UIColor darkGrayColor] forState: UIControlStateNormal];
    self.returnButton.titleLabel.font = [UIFont boldSystemFontOfSize: 20];
    
    // timer control buttons container and title label
    
    self.timerControlsContainer.backgroundColor = [UIColor clearColor];
    CALayer *tcLayer = self.timerControlsContainer.layer;
    tcLayer.borderWidth = 1.0;
    tcLayer.borderColor = [[TJBAestheticsController singleton] paleLightBlueColor].CGColor;
    tcLayer.masksToBounds = YES;
    tcLayer.cornerRadius = 35;
    
    self.timerControlsTitleLabel.font = [UIFont systemFontOfSize: 15];
    self.timerControlsTitleLabel.textColor = [[TJBAestheticsController singleton] paleLightBlueColor];
    self.timerControlsTitleLabel.backgroundColor = [UIColor clearColor];
    
    
}




#pragma mark - IBAction

- (IBAction)didPressSound:(id)sender {
}

- (IBAction)didPressEditTargetRest:(id)sender{
    
    NSString *nsTitle = @"Target Rest";
    
    __weak TJBClockConfigurationVC *weakSelf = self;
    
    CancelBlock cancelBlock = ^{
        
        [weakSelf dismissViewControllerAnimated: YES
                                 completion: nil];
        
    };
    
    NumberSelectedBlockSingle nsBlock = ^(NSNumber *selectedNumber){
        
        NSString *formattedNumber = [[TJBStopwatch singleton] minutesAndSecondsStringFromNumberOfSeconds: [selectedNumber intValue]];
        weakSelf.targetRestValueLabel.text = formattedNumber;
        weakSelf.selectedTargetRest = selectedNumber;
        
        [TJBStopwatch singleton].targetRest = selectedNumber;
        
        // also need to notify the stopwatch of changes
        
        [weakSelf dismissViewControllerAnimated: YES
                                 completion: nil];
        
    };
    
    TJBNumberSelectionVC *nsVC = [[TJBNumberSelectionVC alloc] initWithNumberTypeIdentifier: TargetRestType
                                                                                      title: nsTitle
                                                                                cancelBlock: cancelBlock
                                                                        numberSelectedBlock: nsBlock];
    
    [self presentViewController: nsVC
                       animated: YES
                     completion: nil];
    
}

- (IBAction)didPressEditAlertTiming:(id)sender{
    
    NSString *nsTitle = @"Alert Timing";
    
    __weak TJBClockConfigurationVC *weakSelf = self;
    
    CancelBlock cancelBlock = ^{
        
        [weakSelf dismissViewControllerAnimated: YES
                                 completion: nil];
        
    };
    
    NumberSelectedBlockSingle nsBlock = ^(NSNumber *selectedNumber){
        
        NSString *formattedNumber = [[TJBStopwatch singleton] minutesAndSecondsStringFromNumberOfSeconds: [selectedNumber intValue]];
        weakSelf.alertTiimingValueLabel.text = formattedNumber;
        weakSelf.selectedAlertTiming = selectedNumber;
        
        [TJBStopwatch singleton].alertTiming = selectedNumber;
        
        // also need to notify the stopwatch of changes
        
        [weakSelf dismissViewControllerAnimated: YES
                                 completion: nil];
        
    };
    
    TJBNumberSelectionVC *nsVC = [[TJBNumberSelectionVC alloc] initWithNumberTypeIdentifier: TimeIntervalSelection
                                                                                      title: nsTitle
                                                                                cancelBlock: cancelBlock
                                                                        numberSelectedBlock: nsBlock];
    
    [self presentViewController: nsVC
                       animated: YES
                     completion: nil];

    
}

- (IBAction)didPressRestart:(id)sender{
    
    [[TJBStopwatch singleton] resetPrimaryTimer];
    
}

- (IBAction)didPressPause:(id)sender{
    
    [[TJBStopwatch singleton] pausePrimaryTimer];
    
}

- (IBAction)didPressPlay:(id)sender{
    
    [[TJBStopwatch singleton] playPrimaryTimer];
    
}

- (IBAction)didPressReturn:(id)sender{
    
    if (self.selectedTargetRest && self.selectedAlertTiming){
        
        [self deregisterTimerValueLabelWithStopwatch];
        
        self.applyAlertParamBlock(self.selectedTargetRest, self.selectedAlertTiming);
        
    }
    
    
    
    
    
}

- (IBAction)didPressExit:(id)sender{
    
    self.cancelBlock();
    
}



#pragma mark - Stopwatch Interaction

- (void)registerTimerValueLabelWithStopwatch{
    
    [[TJBStopwatch singleton] addPrimaryStopwatchObserver: self
                                           withTimerLabel: self.timerValueLabel];
    
}

- (void)deregisterTimerValueLabelWithStopwatch{
 
    [[TJBStopwatch singleton] removePrimaryStopwatchObserver: self.timerValueLabel];
    
}

#pragma mark - TJBStopwatchObserver Protocol

- (void)primaryTimerDidUpdateWithUpdateDate:(NSDate *)date timerValue:(float)timerValue{
    
    
    
}

- (void)secondaryTimerDidUpdateWithUpdateDate:(NSDate *)date{
    
    
    
}



@end
































