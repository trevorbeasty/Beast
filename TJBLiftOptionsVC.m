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

// aesthetics

#import "TJBAestheticsController.h"


@interface TJBLiftOptionsVC ()

// IBOutlet

@property (weak, nonatomic) IBOutlet UIButton *freeformButton;
@property (weak, nonatomic) IBOutlet UIButton *designedButton;
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;

// IBAction

- (IBAction)didPressFreeformButton:(id)sender;
- (IBAction)didPressDesignedButton:(id)sender;


@end

@implementation TJBLiftOptionsVC

#pragma mark - View Life Cycle

- (void)viewDidLoad{
    
    [self configureNavBar];
    
    [self configureViewAesthetics];
    
}

- (void)configureViewAesthetics{
    
    NSArray *buttons = @[self.freeformButton,
                         self.designedButton];
    
    for (UIButton *button in buttons){
        
        button.backgroundColor = [[TJBAestheticsController singleton] blueButtonColor];
        [button setTitleColor: [UIColor whiteColor]
                     forState: UIControlStateNormal];
        button.titleLabel.font = [UIFont boldSystemFontOfSize: 20.0];
        
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = 4.0;
        
    }
    
}

- (void)configureNavBar{
    
    UINavigationItem *navItem = [[UINavigationItem alloc] init];
    
    navItem.title = @"Lift Options";
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle: @"Home"
                                                                     style: UIBarButtonItemStyleDone
                                                                    target: self
                                                                    action: @selector(didPressBack)];
    cancelButton.enabled = NO;
    [navItem setLeftBarButtonItem: cancelButton];
    
    [self.navBar setItems: @[navItem]];
    
    [self.navBar setTitleTextAttributes: @{NSFontAttributeName: [UIFont boldSystemFontOfSize: 20.0]}];
    
}

#pragma mark - IBAction

- (IBAction)didPressFreeformButton:(id)sender{
    
    // tab bar vc's
    
    TJBRealizedSetActiveEntryVC *vc1 = [[TJBRealizedSetActiveEntryVC alloc] init];
    vc1.tabBarItem.title = @"Active";
    
    TJBWorkoutNavigationHub *vc2 = [[TJBWorkoutNavigationHub alloc] init];
    vc2.tabBarItem.title = @"Workout Log";
    
    // tab bar controller
    
    UITabBarController *tbc = [[UITabBarController alloc] init];
    [tbc setViewControllers: @[vc1, vc2]];
    tbc.tabBar.translucent = NO;
    tbc.navigationItem.title = @"Freeform Lift";
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle: @"Back"
                                                                   style: UIBarButtonItemStyleDone
                                                                  target: self
                                                                  action: @selector(didPressBack)];
    [tbc.navigationItem setLeftBarButtonItem: backButton];
    
    // navigation controller
    
    UINavigationController *navC = [[UINavigationController alloc] initWithRootViewController: tbc];
    navC.navigationBar.translucent = NO;
    
    [self presentViewController: navC
                       animated: NO
                     completion: nil];
    
}

- (IBAction)didPressDesignedButton:(id)sender{
    
    // tab bar vc's
    
    NewOrExistinigCircuitVC *vc1 = [[NewOrExistinigCircuitVC alloc] init];
    vc1.tabBarItem.title = @"Selection";
    
    TJBWorkoutNavigationHub *vc2 = [[TJBWorkoutNavigationHub alloc] init];
    vc2.tabBarItem.title = @"Workout Log";
    
    // tab bar
    
    UITabBarController *tbc = [[UITabBarController alloc] init];
    [tbc setViewControllers: @[vc1, vc2]];
    tbc.tabBar.translucent = NO;
    tbc.navigationItem.title = @"My Routines";
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle: @"Back"
                                                                   style: UIBarButtonItemStyleDone
                                                                  target: self
                                                                  action: @selector(didPressBack)];
    [tbc.navigationItem setLeftBarButtonItem: backButton];
    
    UIBarButtonItem *newButton = [[UIBarButtonItem alloc] initWithTitle: @"New"
                                                                  style: UIBarButtonItemStyleDone
                                                                 target: vc1
                                                                 action: @selector(didPressNew)];
    [tbc.navigationItem setRightBarButtonItem: newButton];
    
    // navigation controller
    
    UINavigationController *navC = [[UINavigationController alloc] initWithRootViewController: tbc];
    navC.navigationBar.translucent = NO;
    
    [self presentViewController: navC
                       animated: NO
                     completion: nil];
    
}

//- (IBAction)didPressTestButton:(id)sender{
//    
//    TJBNumberSelectionVC *vc = [[TJBNumberSelectionVC alloc] initWithNumberTypeIdentifier: WeightType
//                                                                                    title: @"Bench"
//                                                                              cancelBlock: nil
//                                                                      numberSelectedBlock: nil];
//    
//    [self presentViewController:vc
//                       animated: YES
//                     completion: nil];
//    
//}

- (void)didPressBack{
    
    [self dismissViewControllerAnimated: NO
                             completion: nil];
    
}






@end
