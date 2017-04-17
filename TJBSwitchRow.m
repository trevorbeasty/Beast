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

// master controller

#import "TJBCircuitTemplateVC.h"

@interface TJBSwitchRow ()

// IBOutlet

@property (weak, nonatomic) IBOutlet UILabel *targetsTitleLabel;

@property (weak, nonatomic) IBOutlet UIView *weightSwitchContainer;
@property (weak, nonatomic) IBOutlet UIView *repsSwitchContainer;
@property (weak, nonatomic) IBOutlet UIView *trailingRestSwitchContainer;

@property (weak, nonatomic) IBOutlet UISwitch *weightSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *repsSwitch;
@property (weak, nonatomic) IBOutlet UISwitch *trailingRestSwitch;

// core

@property (weak) TJBCircuitTemplateVC <TJBCircuitTemplateVCProtocol> *masterController;
@property (strong) NSNumber *exerciseIndex;

@end

@implementation TJBSwitchRow

#pragma mark - Instantiation

- (instancetype)initWithExerciseIndex:(int)exerciseIndex masterController:(TJBCircuitTemplateVC<TJBCircuitTemplateVCProtocol> *)masterController{
    
    self = [super init];
    
    self.masterController = masterController;
    self.exerciseIndex = @(exerciseIndex);
    
    return self;
    
}

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
    self.targetsTitleLabel.textColor = [UIColor blackColor];
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
    
    [self.masterController configureRowsForExerciseIndex: [self.exerciseIndex intValue]
                                              switchType: WeightSwitch
                                               activated: self.weightSwitch.on];
    
}

- (void)repsSwitchValueDidChange{
    
    [self.masterController configureRowsForExerciseIndex: [self.exerciseIndex intValue]
                                              switchType: RepsSwitch
                                               activated: self.repsSwitch.on];
    
}

- (void)trailingRestSwitchValueDidChange{
    
    [self.masterController configureRowsForExerciseIndex: [self.exerciseIndex intValue]
                                              switchType: TrailingRestSwitch
                                               activated: self.trailingRestSwitch.on];
    
}

@end





















