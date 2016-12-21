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

@interface TJBWorkoutNavigationHub ()

@property (weak, nonatomic) IBOutlet UIButton *standaloneSetFreeformButton;
@property (weak, nonatomic) IBOutlet UIButton *circuitOrSupersetButton;

- (IBAction)didPressStandaloneSetFreeformButton:(id)sender;
- (IBAction)didPressCircuitOrSupersetButton:(id)sender;

- (IBAction)test:(id)sender;


@end

@implementation TJBWorkoutNavigationHub

#pragma mark - Instantiation

- (void)viewDidLoad
{
    // view aesthetics
    
    self.standaloneSetFreeformButton.backgroundColor = [UIColor blueColor];
    [self.standaloneSetFreeformButton setTitleColor: [UIColor whiteColor]
                                           forState: UIControlStateNormal];
    
    self.circuitOrSupersetButton.backgroundColor = [UIColor blueColor];
    [self.circuitOrSupersetButton setTitleColor: [UIColor whiteColor]
                                       forState: UIControlStateNormal];
}

#pragma mark - Button Actions

- (IBAction)didPressStandaloneSetFreeformButton:(id)sender
{
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

- (IBAction)didPressCircuitOrSupersetButton:(id)sender
{
    TJBCircuitDesignVC *vc = [[TJBCircuitDesignVC alloc] init];
    
    [self presentViewController: vc
                       animated: NO
                     completion: nil];
}

- (IBAction)test:(id)sender
{

}

@end




























