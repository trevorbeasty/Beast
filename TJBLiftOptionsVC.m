//
//  TJBLiftOptionsVC.m
//  Beast
//
//  Created by Trevor Beasty on 1/28/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBLiftOptionsVC.h"

// presented VC's

#import "TJBWorkoutNavigationHub.h"
#import "TJBRealizedSetActiveEntryVC.h"
#import "NewOrExistinigCircuitVC.h"
#import "TJBPersonalRecordVC.h"
#import "TJBPersonalRecordsVCProtocol.h"
#import "TJBExerciseHistoryVC.h"
#import "TJBExerciseHistoryProtocol.h"

// aesthetics

#import "TJBAestheticsController.h"

// test

#import "TJBCompleteChainHistoryVC.h"


@interface TJBLiftOptionsVC ()

// IBOutlet

@property (weak, nonatomic) IBOutlet UIButton *freeformButton;
@property (weak, nonatomic) IBOutlet UIButton *designedButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel1;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel2;
@property (weak, nonatomic) IBOutlet UILabel *analysisOptionsLabel;
@property (weak, nonatomic) IBOutlet UILabel *liftOptionsLabel;
@property (weak, nonatomic) IBOutlet UIButton *viewWorkoutLogButton;
@property (weak, nonatomic) IBOutlet UIView *contentContainerView;


// IBAction

- (IBAction)didPressFreeformButton:(id)sender;
- (IBAction)didPressDesignedButton:(id)sender;
- (IBAction)didPressViewWorkoutLog:(id)sender;


@end

@implementation TJBLiftOptionsVC

#pragma mark - View Life Cycle

- (void)viewDidLoad{
    
    [self configureViewAesthetics];
    
    [self.view layoutIfNeeded];
    
    [self configureScene];
    
}

- (void)configureScene{
    
    // visual effect
    
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle: UIBlurEffectStyleDark];
    
    UIVisualEffectView *veView = [[UIVisualEffectView alloc] initWithEffect: blur];
    
    veView.frame = self.contentContainerView.frame;
    [self.view addSubview: veView];
    [veView.contentView addSubview: self.contentContainerView];
 
}

- (void)configureViewAesthetics{
    
    // buttons
    
    NSArray *buttons = @[self.freeformButton,
                         self.designedButton,
                         self.viewWorkoutLogButton];
    
    for (UIButton *button in buttons){
        
        button.backgroundColor = [UIColor clearColor];
        [button setTitleColor: [[TJBAestheticsController singleton] blueButtonColor]
                     forState: UIControlStateNormal];
        button.titleLabel.font = [UIFont boldSystemFontOfSize: 20.0];
        
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = 16.0;
        button.layer.borderColor = [[TJBAestheticsController singleton] blueButtonColor].CGColor;
        button.layer.borderWidth = 1.0;
        
    }
    
    // labels
    
    self.titleLabel1.backgroundColor = [UIColor clearColor];
    self.titleLabel1.textColor = [UIColor whiteColor];
    self.titleLabel1.font = [UIFont boldSystemFontOfSize: 40.0];
    
    self.titleLabel2.backgroundColor = [UIColor clearColor];
    self.titleLabel2.textColor = [UIColor whiteColor];
    self.titleLabel2.font = [UIFont boldSystemFontOfSize: 20.0];
    
    NSArray *grayLabels = @[self.analysisOptionsLabel, self.liftOptionsLabel];
    for (UILabel *label in grayLabels){
        
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont boldSystemFontOfSize: 25];
        
        label.layer.masksToBounds = YES;
        label.layer.cornerRadius = 4.0;
        
    }
    
}



#pragma mark - IBAction

- (IBAction)didPressFreeformButton:(id)sender{
    
    // tab bar vc's
    
    TJBRealizedSetActiveEntryVC *vc1 = [[TJBRealizedSetActiveEntryVC alloc] init];
    vc1.tabBarItem.title = @"Active";
    vc1.tabBarItem.image = [UIImage imageNamed: @"activeLift"];
    
    TJBPersonalRecordVC <TJBPersonalRecordsVCProtocol> *vc2 = [[TJBPersonalRecordVC alloc] init];
    vc2.tabBarItem.title = @"PR's";
    vc2.tabBarItem.image = [UIImage imageNamed: @"trophyBlue25"];
    [vc1 configureSiblingPersonalRecordsVC: vc2];
    
    TJBExerciseHistoryVC <TJBExerciseHistoryProtocol> *vc3 = [[TJBExerciseHistoryVC alloc] init];
    vc3.tabBarItem.title = @"History";
    vc3.tabBarItem.image = [UIImage imageNamed: @"colosseumBlue25"];
    [vc1 configureSiblingExerciseHistoryVC: vc3];
    
    TJBWorkoutNavigationHub *vc4 = [[TJBWorkoutNavigationHub alloc] initWithHomeButton: NO
                                                                advancedControlsActive: NO];
    vc4.tabBarItem.title = @"Workout Log";
    vc4.tabBarItem.image = [UIImage imageNamed: @"workoutLog"];
    
    // tab bar controller
    
    UITabBarController *tbc = [[UITabBarController alloc] init];
    [tbc setViewControllers: @[vc1, vc2, vc3, vc4]];
    tbc.tabBar.translucent = NO;
    
    // tab bar aesthetics
    
    UITabBar *tabBar = tbc.tabBar;
    
    tabBar.barTintColor = [UIColor darkGrayColor];
    tabBar.tintColor = [[TJBAestheticsController singleton] paleLightBlueColor];
    
    [self presentViewController: tbc
                       animated: YES
                     completion: nil];
    
}

- (IBAction)didPressDesignedButton:(id)sender{
    
    NewOrExistinigCircuitVC *vc = [[NewOrExistinigCircuitVC alloc] init];
    
    [self presentViewController: vc
                       animated: YES
                     completion: nil];

    
}






- (void)didPressBack{
    
    [self dismissViewControllerAnimated: NO
                             completion: nil];
    
}






- (IBAction)didPressViewWorkoutLog:(id)sender{
    
    TJBWorkoutNavigationHub *navHub = [[TJBWorkoutNavigationHub alloc] initWithHomeButton: YES];

    [self presentViewController: navHub
                       animated: YES
                     completion: nil];
    
    
}









@end
