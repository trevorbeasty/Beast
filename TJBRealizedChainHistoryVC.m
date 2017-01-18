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

//#import "TJBRealizedChain+CoreDataProperties.h"

@interface TJBRealizedChainHistoryVC ()

// IBOutlet

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UIView *containerView;

// core

@property (nonatomic, strong) TJBCircuitActiveUpdatingContainerVC *childVC;


@end

@implementation TJBRealizedChainHistoryVC

#pragma mark - Instantiation

- (instancetype)initWithRealizedChain:(TJBRealizedChain *)realizedChain{
    
    //// create the child VC and assign it to its IV.  View configuration is handled in viewDidLoad
    
    self = [super init];
    
    TJBCircuitActiveUpdatingContainerVC *childVC = [[TJBCircuitActiveUpdatingContainerVC alloc] initWithRealizedChain: realizedChain];
    
    self.childVC = childVC;
    
    return self;
    
}

#pragma mark - View Life Cycle

- (void)viewDidLoad{
    
//    //// configure the childVC
//    
//    CGSize mainscreenSize = [UIScreen mainScreen].bounds.size;
//    
//    // due to scroll view's issues with auto layout and the fact that accessing containerView's bounds literally takes the dimensions in the xib, no matter what size the xib view is, I have to do this little bit of math
//    // to properly do this, I will have to create IBOutlets for the auto layout constraints set in the xib file
//    
//    NSNumber *viewHeight = [NSNumber numberWithFloat: mainscreenSize.height - 28];
//    NSNumber *viewWidth = [NSNumber numberWithFloat: mainscreenSize.width - 16];
//    
//    TJBCircuitActiveUpdatingVC *vc = [[TJBCircuitActiveUpdatingVC alloc] initWithRealizedChain: self.realizedChain
//                                                                                    viewHeight: viewHeight
//                                                                                     viewWidth: viewWidth];
    
    // assign vc to appropriate property to facillitate delegation of circuit tab bar controller VC's
    
//    self.circuitActiveUpdatingVC = vc;
    
    TJBCircuitActiveUpdatingContainerVC *vc = self.childVC;
    
    // layout views
    
    [self addChildViewController: vc];
    
    [self.containerView addSubview: vc.view];
    
    [vc didMoveToParentViewController: self];
    
}












@end
