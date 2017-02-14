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
#import "TJBCircuitDesignVC.h"

// aesthetics

#import "TJBAestheticsController.h"


@interface TJBLiftOptionsVC ()

// IBOutlet

@property (weak, nonatomic) IBOutlet UIButton *freeformButton;
@property (weak, nonatomic) IBOutlet UIButton *designedButton;
@property (weak, nonatomic) IBOutlet UIButton *createNewRoutineButton;


// IBAction

- (IBAction)didPressFreeformButton:(id)sender;
- (IBAction)didPressDesignedButton:(id)sender;
- (IBAction)didPressCreateNewRoutine:(id)sender;


@end

@implementation TJBLiftOptionsVC

#pragma mark - View Life Cycle

- (void)viewDidLoad{
    
    
    [self configureViewAesthetics];
    
}

- (void)configureViewAesthetics{
    
    NSArray *buttons = @[self.freeformButton,
                         self.designedButton,
                         self.createNewRoutineButton];
    
    for (UIButton *button in buttons){
        
        button.backgroundColor = [[TJBAestheticsController singleton] blueButtonColor];
        [button setTitleColor: [UIColor whiteColor]
                     forState: UIControlStateNormal];
        button.titleLabel.font = [UIFont boldSystemFontOfSize: 20.0];
        
//        button.layer.masksToBounds = YES;
//        button.layer.cornerRadius = 4.0;
        
    }
    
    // shadows
//    
//    [self.view layoutIfNeeded];
//    
//    UIView *freeformShadow = [[UIView alloc] initWithFrame: self.freeformButton.frame];
//    freeformShadow.backgroundColor = [UIColor whiteColor];
//    freeformShadow.clipsToBounds = NO;
//    
//    CALayer *freeformShadowLayer = freeformShadow.layer;
//    freeformShadowLayer.masksToBounds = NO;
//    freeformShadowLayer.shadowColor = [UIColor darkGrayColor].CGColor;
//    freeformShadowLayer.shadowOffset = CGSizeMake(0.0, 0.0);
//    freeformShadowLayer.shadowOpacity = 1.0;
//    freeformShadowLayer.shadowRadius = 5.0;
//    
//    [self.view insertSubview: freeformShadow
//                belowSubview: self.freeformButton];
//    
//    UIView *routineShadow = [[UIView alloc] initWithFrame: self.designedButton.frame];
//    routineShadow.backgroundColor = [UIColor whiteColor];
//    routineShadow.clipsToBounds = NO;
//    
//    CALayer *routineShadowLayer = routineShadow.layer;
//    routineShadowLayer.masksToBounds = NO;
//    routineShadowLayer.shadowColor = [UIColor darkGrayColor].CGColor;
//    routineShadowLayer.shadowOffset = CGSizeMake(0.0, 0.0);
//    routineShadowLayer.shadowOpacity = 1.0;
//    routineShadowLayer.shadowRadius = 5.0;
//    
//    [self.view insertSubview: routineShadow
//                belowSubview: self.designedButton];
    
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
//    tbc.navigationItem.title = @"Freeform Lift";
//    
//    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle: @"Back"
//                                                                   style: UIBarButtonItemStyleDone
//                                                                  target: self
//                                                                  action: @selector(didPressBack)];
//    [tbc.navigationItem setLeftBarButtonItem: backButton];
//    
//    // navigation controller
//    
//    UINavigationController *navC = [[UINavigationController alloc] initWithRootViewController: tbc];
//    navC.navigationBar.translucent = NO;
    
    [self presentViewController: tbc
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
//    tbc.navigationItem.title = @"My Routines";
    
//    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle: @"Back"
//                                                                   style: UIBarButtonItemStyleDone
//                                                                  target: self
//                                                                  action: @selector(didPressBack)];
//    [tbc.navigationItem setLeftBarButtonItem: backButton];
    
//    UIBarButtonItem *newButton = [[UIBarButtonItem alloc] initWithTitle: @"New"
//                                                                  style: UIBarButtonItemStyleDone
//                                                                 target: vc1
//                                                                 action: @selector(didPressNew)];
//    [tbc.navigationItem setRightBarButtonItem: newButton];
//    
//    // navigation controller
//    
//    UINavigationController *navC = [[UINavigationController alloc] initWithRootViewController: tbc];
//    navC.navigationBar.translucent = NO;
//    
    [self presentViewController: tbc
                       animated: NO
                     completion: nil];
    
}

- (IBAction)didPressCreateNewRoutine:(id)sender{
    
    TJBCircuitDesignVC *vc = [[TJBCircuitDesignVC alloc] init];
    
    [self presentViewController: vc
                       animated: YES
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
