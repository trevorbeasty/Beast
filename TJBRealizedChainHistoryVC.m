//
//  TJBRealizedChainHistoryVC.m
//  Beast
//
//  Created by Trevor Beasty on 1/18/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBRealizedChainHistoryVC.h"

// circuit active updating (realized chain)

#import "TJBCircuitActiveUpdatingContainerVC.h"

// core data

#import "TJBRealizedChain+CoreDataProperties.h"
#import "TJBChainTemplate+CoreDataProperties.h"

@interface TJBRealizedChainHistoryVC ()

// IBOutlet

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UIView *containerView;

// core

@property (nonatomic, strong) TJBCircuitActiveUpdatingContainerVC *childVC;
@property (nonatomic, copy) NSString *navigationBarTitle;


@end

@implementation TJBRealizedChainHistoryVC

#pragma mark - Instantiation

- (instancetype)initWithRealizedChain:(TJBRealizedChain *)realizedChain{
    
    //// create the child VC and assign it to its IV.  View configuration is handled in viewDidLoad
    
    self = [super init];
    
    // child VC
    
    TJBCircuitActiveUpdatingContainerVC *childVC = [[TJBCircuitActiveUpdatingContainerVC alloc] initWithRealizedChain: realizedChain];
    
    self.childVC = childVC;
    
    // navigation bar
    
    NSDate *realizedChainDate = realizedChain.dateCreated;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    
    self.navigationBarTitle = [NSString stringWithFormat: @"%@: %@",
                               [dateFormatter stringFromDate: realizedChainDate],
                               realizedChain.chainTemplate.name];
    
    // return self
    
    return self;
    
}

#pragma mark - View Life Cycle

- (void)viewDidLoad{
    
    [self configureChildVC];
    
    [self configureNavigationBar];
    
}

- (void)configureNavigationBar{
    
    //// configure the navigation bar
    
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle: self.navigationBarTitle];
    
    UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle: @"Back"
                                                                   style: UIBarButtonItemStyleDone
                                                                  target: self
                                                                  action: @selector(didPressBack)];
    
    [navItem setLeftBarButtonItem: backButton];
    
    [self.navBar setItems: @[navItem]];
    
}

- (void)configureChildVC{
    
    //// configure the childVC
    
    TJBCircuitActiveUpdatingContainerVC *vc = self.childVC;
    
    // layout views
    
    [self addChildViewController: vc];
    
    [self.containerView addSubview: vc.view];
    
    [vc didMoveToParentViewController: self];
    
}

#pragma mark - Button Actions

- (void)didPressBack{
    
    //// simply dismiss the VC
    
    [self dismissViewControllerAnimated: NO
                             completion: nil];
    
}










@end






























