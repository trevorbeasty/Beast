//
//  TJBSwitchRow.m
//  Beast
//
//  Created by Trevor Beasty on 4/8/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBSwitchRow.h"

// aesthetics

#import "TJBAestheticsController.h"

@interface TJBSwitchRow ()

// IBOutlet

@property (weak, nonatomic) IBOutlet UILabel *targetsTitleLabel;

@property (weak, nonatomic) IBOutlet UIView *weightSwitchContainer;
@property (weak, nonatomic) IBOutlet UIView *repsSwitchContainer;
@property (weak, nonatomic) IBOutlet UIView *trailingRestSwitchContainer;

@property (weak, nonatomic) IBOutlet UISwitch *weightSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *repsSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *trailingRestSwitch;



@end

@implementation TJBSwitchRow

#pragma mark - View Life Cycle

- (void)viewDidLoad{
    
    [super viewDidLoad];
    
    [self configureViewAesthetics];
    
    [self configureSwitchActions];
    
}

#pragma mark - View Helper Methods

- (void)configureViewAesthetics{
    
    // meta view
    
    self.view.backgroundColor = [UIColor clearColor];
    
    // container views
    
    NSArray *containerViews = @[self.weightSwitchContainer, self.repsSwitchContainer, self.trailingRestSwitchContainer];
    for (UIView *view in containerViews){
        
        view.backgroundColor = [UIColor clearColor];
        
    }
    
    // switches
    
    NSArray *switches = @[self.weightSwitch, self.repsSwitch, self.trailingRestSwitch];
    for (UISwitch *swi in switches){
        
        swi.onTintColor = [[TJBAestheticsController singleton] paleLightBlueColor];
        swi.tintColor = [UIColor lightGrayColor];
        
    }
    
    // targets title label
    
    self.targetsTitleLabel.font = [UIFont boldSystemFontOfSize: 15];
    self.targetsTitleLabel.textColor = [UIColor whiteColor];
    self.targetsTitleLabel.backgroundColor = [UIColor clearColor];
    
}

- (void)configureSwitchActions{
    
    [self.weightSwitch addTarget: self
                          action: @selector(weightSwitchValueDidChange)
                forControlEvents: UIControlEventValueChanged];
    
    [self.repsSwitch addTarget: self
                        action: @selector(repsSwitchValueDidChange)
            forControlEvents: UIControlEventValueChanged];
    
    [self.trailingRestSwitch addTarget: self
                                action: @selector(trailingRestSwitchValueDidChange)
                      forControlEvents: UIControlEventValueChanged];
    
}

#pragma mark - Switch Actions

- (void)weightSwitchValueDidChange{
    
    
    
}

- (void)repsSwitchValueDidChange{
    
    
    
}

- (void)trailingRestSwitchValueDidChange{
    
    
    
}

@end





















