//
//  TJBClockConfigurationVC.m
//  Beast
//
//  Created by Trevor Beasty on 4/1/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBClockConfigurationVC.h"

@interface TJBClockConfigurationVC ()

// IBOutlet

@property (weak, nonatomic) IBOutlet UILabel *myTimerLabel;
@property (weak, nonatomic) IBOutlet UILabel *timerValueLabel;

@property (weak, nonatomic) IBOutlet UILabel *targetRestTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *targetRestValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *alertTimingTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *alertTiimingValueLabel;

@property (weak, nonatomic) IBOutlet UIButton *editButtonTargetRest;
@property (weak, nonatomic) IBOutlet UIButton *editButtonAlertTiming;

@property (weak, nonatomic) IBOutlet UIButton *cancelButtonTitleBar;
@property (weak, nonatomic) IBOutlet UIButton *soundButtonTitleBar;

@property (weak, nonatomic) IBOutlet UIView *topTitleBar;
@property (weak, nonatomic) IBOutlet UIView *bottomTitleBar;
@property (weak, nonatomic) IBOutlet UIView *titleBarContainer;

@property (weak, nonatomic) IBOutlet UILabel *thinDividerLabel;

@property (weak, nonatomic) IBOutlet UIButton *restartButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;

@property (weak, nonatomic) IBOutlet UIButton *returnButton;



// IBAction

- (IBAction)didPressCancel:(id)sender;
- (IBAction)didPressSound:(id)sender;

- (IBAction)didPressEditTargetRest:(id)sender;
- (IBAction)didPressEditAlertTiming:(id)sender;

- (IBAction)didPressRestart:(id)sender;
- (IBAction)didPressPause:(id)sender;
- (IBAction)didPressPlay:(id)sender;

- (IBAction)didPressReturn:(id)sender;



@end

@implementation TJBClockConfigurationVC

#pragma mark - Instantiation





#pragma mark - View Life Cycle





#pragma mark - View Helper Methods






#pragma mark - IBAction

- (IBAction)didPressCancel:(id)sender {
}

- (IBAction)didPressSound:(id)sender {
}

- (IBAction)didPressEditTargetRest:(id)sender {
}

- (IBAction)didPressEditAlertTiming:(id)sender {
}

- (IBAction)didPressRestart:(id)sender {
}

- (IBAction)didPressPause:(id)sender {
}

- (IBAction)didPressPlay:(id)sender {
}

- (IBAction)didPressReturn:(id)sender {
}



@end
































