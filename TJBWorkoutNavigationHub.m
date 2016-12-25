//
//  TJBWorkoutNavigationHub.m
//  Beast
//
//  Created by Trevor Beasty on 12/12/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import "TJBWorkoutNavigationHub.h"

#import "TJBRealizedSetActiveEntryVC.h"
#import "TJBRealizedSetHistoryByDay.h"
#import "RealizedSetPersonalRecordVC.h"
#import "TJBCircuitDesignVC.h"

#import "TJBCircuitTemplateGeneratorVC.h"

#import "TJBAestheticsController.h"

@interface TJBWorkoutNavigationHub ()

@property (weak, nonatomic) IBOutlet UIButton *standaloneSetButton;
@property (weak, nonatomic) IBOutlet UIButton *circuitSlashSupersetButton;
@property (weak, nonatomic) IBOutlet UIButton *testButton;

- (IBAction)didPressStandaloneSetButton:(id)sender;
- (IBAction)didPressCircuitSlashSupersetButton:(id)sender;

@end

@implementation TJBWorkoutNavigationHub

#pragma mark - Instantiation

- (void)viewDidLoad{
    [self configureViewAesthetics];
    
    // background view
    UIImage *image = [UIImage imageNamed: @"weightStack"];
    [[TJBAestheticsController singleton] addFullScreenBackgroundViewWithImage: image
                                                                   toRootView: self.view];
    
    [self viewAesthetics];
}

- (void)viewAesthetics{
    NSArray *views = @[self.standaloneSetButton,
                       self.circuitSlashSupersetButton];
    for (UIView *view in views){
        view.layer.masksToBounds = YES;
        view.layer.cornerRadius = 25;
    }
}

- (void)configureViewAesthetics{
    double opacityValue = .9;
    
    NSArray *viewsToConfigure = @[self.standaloneSetButton,
                                 self.circuitSlashSupersetButton];
    
    for (UIView *view in viewsToConfigure)
    {
        view.layer.opacity = opacityValue;
        view.layer.masksToBounds = YES;
        view.layer.cornerRadius = 4.0;
    }
}

#pragma mark - Button Actions

- (void)didPressStandaloneSetButton:(id)sender{
    TJBRealizedSetActiveEntryVC *vc1 = [[TJBRealizedSetActiveEntryVC alloc] init];
    [vc1.tabBarItem setTitle: @"Active Entry"];
    
    TJBRealizedSetHistoryByDay *vc2 = [[TJBRealizedSetHistoryByDay alloc] init];
    [vc2.tabBarItem setTitle: @"Today's Log"];
    
    RealizedSetPersonalRecordVC *vc3 = [[RealizedSetPersonalRecordVC alloc] init];
    [vc3.tabBarItem setTitle: @"Personal Records"];
    
    vc1.personalRecordVC = vc3;
    
    UITabBarController *tbc = [[UITabBarController alloc] init];
    
    [tbc setViewControllers: @[vc1, vc2, vc3]];
    tbc.tabBar.translucent = NO;
    
    [self presentViewController: tbc
                       animated: NO
                     completion: nil];
}

- (void)didPressCircuitSlashSupersetButton:(id)sender{
    TJBCircuitDesignVC *vc = [[TJBCircuitDesignVC alloc] init];
    
    [self presentViewController: vc
                       animated: NO
                     completion: nil];
}

@end




























