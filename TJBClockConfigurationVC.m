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

- (void)viewDidLoad{
    
    [super viewDidLoad];
    
    [self configureViewAesthetics];
    
}



#pragma mark - View Helper Methods


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
        lab.font = [UIFont systemFontOfSize: 30];
        lab.textColor = [[TJBAestheticsController singleton] paleLightBlueColor];
        
    }
    
    // buttons
    
    NSArray *iconButtons = @[self.cancelButtonTitleBar, self.soundButtonTitleBar, self.restartButton, self.pauseButton, self.playButton];
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
    
}



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
































