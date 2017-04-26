//
//  TJBLiftOptionsVC.m
//  Beast
//
//  Created by Trevor Beasty on 1/28/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBLiftOptionsVC.h"

#import "TJBWorkoutNavigationHub.h" // workoout log - presented VC
#import "NewOrExistinigCircuitVC.h" // routine selection - presented VC
#import "TJBFreeformModeTabBarController.h" // freeform tbc - presented VC


// aesthetics

#import "TJBAestheticsController.h"

// test

#import "TJBCompleteChainHistoryVC.h"


@interface TJBLiftOptionsVC ()

{
    
    BOOL _shouldConfigureSceneAfterViewAppears;
    
}

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



#pragma mark - Constants

static NSString * const restorationID = @"TJBLiftOptionsVC";




@implementation TJBLiftOptionsVC


#pragma mark - Instantiation

- (instancetype)init{
    
    self = [super init];
    
    
    [self configureStateRestorationProperties];
    
    _shouldConfigureSceneAfterViewAppears = YES;
    
    
    return self;
}





#pragma mark - Instantiation Helper Methods




- (void)configureStateRestorationProperties{
    
    self.restorationIdentifier = restorationID;
    self.restorationClass = [TJBLiftOptionsVC class];
    
    
}



#pragma mark - View Life Cycle

- (void)viewDidLoad{
    
    [self.view layoutIfNeeded];
    
    [self configureViewAesthetics];
    
}

- (void)viewWillAppear:(BOOL)animated{
    
    
    
}

- (void)viewDidAppear:(BOOL)animated{
    
    if (_shouldConfigureSceneAfterViewAppears == YES){
        
        [self configureScene];
        
        _shouldConfigureSceneAfterViewAppears = NO;
        
    }
    
    
    
}



#pragma mark - View Life Cycle Helper Methods

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
    
    TJBFreeformModeTabBarController *freeformTBC = [[TJBFreeformModeTabBarController alloc] init];
    
    [self presentViewController: freeformTBC
                       animated: YES
                     completion: nil];
    
}

- (IBAction)didPressDesignedButton:(id)sender{
    
    NewOrExistinigCircuitVC *vc = [[NewOrExistinigCircuitVC alloc] init];
    
    [self presentViewController: vc
                       animated: YES
                     completion: nil];

    
}






- (IBAction)didPressViewWorkoutLog:(id)sender{
    
    TJBWorkoutNavigationHub *navHub = [[TJBWorkoutNavigationHub alloc] initWithHomeButton: YES
                                                                   advancedControlsActive: YES];

    [self presentViewController: navHub
                       animated: YES
                     completion: nil];
    
    
}


#pragma mark - Restoration


- (NSString *)restorationID{
    
    return restorationID;
    
}




@end

















