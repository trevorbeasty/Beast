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
@property (weak, nonatomic) IBOutlet UIView *titleContainer;


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
    
    [super viewDidLoad];
    
    [self.view layoutIfNeeded];
    
    [self configureViewAesthetics];
    
}




#pragma mark - View Life Cycle Helper Methods

- (void)configureViewAesthetics{
    
    self.titleContainer.backgroundColor = [UIColor blackColor];
    
    self.view.backgroundColor = [[TJBAestheticsController singleton] yellowNotebookColor];
    
    // buttons
    
    NSArray *buttons = @[self.freeformButton,
                         self.designedButton,
                         self.viewWorkoutLogButton];
    
    for (UIButton *button in buttons){
        
        button.backgroundColor = [UIColor grayColor];
        [button setTitleColor: [[TJBAestheticsController singleton] paleLightBlueColor]
                     forState: UIControlStateNormal];
        button.titleLabel.font = [UIFont boldSystemFontOfSize: 20.0];
        
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = button.layer.frame.size.height / 2.0;
        button.layer.borderColor = [[TJBAestheticsController singleton] paleLightBlueColor].CGColor;
        button.layer.borderWidth = 1.0;
        
    }
    
    // labels
    
    self.titleLabel1.backgroundColor = [UIColor darkGrayColor];
    self.titleLabel1.textColor = [UIColor whiteColor];
    self.titleLabel1.font = [UIFont boldSystemFontOfSize: 40.0];
    
    self.titleLabel2.backgroundColor = [UIColor darkGrayColor];
    self.titleLabel2.textColor = [UIColor whiteColor];
    self.titleLabel2.font = [UIFont boldSystemFontOfSize: 20.0];
    
    NSArray *actionTitleLabels = @[self.analysisOptionsLabel, self.liftOptionsLabel];
    for (UILabel *label in actionTitleLabels){
        
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor blackColor];
        label.font = [UIFont boldSystemFontOfSize: 25];
        
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






@end

















