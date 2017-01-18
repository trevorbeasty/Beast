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

#import "CoreDataController.h"

@interface TJBRealizedChainHistoryVC () <UIViewControllerRestoration>

// IBOutlet

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UIView *containerView;

// core

@property (nonatomic, strong) TJBCircuitActiveUpdatingContainerVC *childVC;
@property (nonatomic, strong) TJBRealizedChain *realizedChain;


@end

@implementation TJBRealizedChainHistoryVC

#pragma mark - Instantiation

- (instancetype)initWithRealizedChain:(TJBRealizedChain *)realizedChain{
    
    //// create the child VC and assign it to its IV.  View configuration is handled in viewDidLoad
    
    self = [super init];
    
    // child VC
    
    TJBCircuitActiveUpdatingContainerVC *childVC = [[TJBCircuitActiveUpdatingContainerVC alloc] initWithRealizedChain: realizedChain];
    
    self.childVC = childVC;
    
    // realized chain
    
    self.realizedChain = realizedChain;
    
    // for restoration
    
    [self setRestorationProperties];
    
    // return self
    
    return self;
    
}

- (void)setRestorationProperties{
    
    //// for restoration
    
    self.restorationClass = [TJBRealizedChainHistoryVC class];
    self.restorationIdentifier = @"TJBRealizedChainHistoryVC";
    
}

#pragma mark - View Life Cycle

- (void)viewDidLoad{
    
    [self configureChildVC];
    
    [self configureNavigationBar];
    
}

- (void)configureNavigationBar{
    
    //// configure the navigation bar
    
    NSDate *realizedChainDate = self.realizedChain.dateCreated;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.timeStyle = NSDateFormatterNoStyle;
    dateFormatter.dateStyle = NSDateFormatterMediumStyle;
    
    NSString *navigationBarTitle = [NSString stringWithFormat: @"%@: %@",
                                    [dateFormatter stringFromDate: realizedChainDate],
                                    self.realizedChain.chainTemplate.name];
    
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle: navigationBarTitle];
    
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


#pragma mark - <UIViewControllerRestoration>

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder{
    
    //// simply use the core data controller to get the realized chain and instantiate the VC normally
    
    NSString *realizedChainUniqueID = [coder decodeObjectForKey: @"realizedChainUniqueID"];
    
    TJBRealizedChain *realizedChain = [[CoreDataController singleton] realizedChainWithUniqueID: realizedChainUniqueID];
    
    TJBRealizedChainHistoryVC *vc = [[TJBRealizedChainHistoryVC alloc] initWithRealizedChain: realizedChain];
    
    return vc;
    
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder{
    
    [super encodeRestorableStateWithCoder: coder];
    
    //// must encode the realized chain unique ID so the realized chain can be found upon restoration
    
    [coder encodeObject: self.realizedChain.uniqueID
                 forKey: @"realizedChainUniqueID"];
    
}





@end






























