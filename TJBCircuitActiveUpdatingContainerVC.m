//
//  TJBCircuitActiveUpdatingContainerVC.m
//  Beast
//
//  Created by Trevor Beasty on 1/11/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBCircuitActiveUpdatingContainerVC.h"

// child VC

#import "TJBCircuitActiveUpdatingVC.h"

// core data

#import "TJBRealizedChain+CoreDataProperties.h"

@interface TJBCircuitActiveUpdatingContainerVC ()

// core

@property (nonatomic, strong) TJBRealizedChain *realizedChain;

// IBOutlet

@property (weak, nonatomic) IBOutlet UIView *circuitView;


@end

@implementation TJBCircuitActiveUpdatingContainerVC

#pragma mark - Instantiation

- (instancetype)initWithRealizedChain:(TJBRealizedChain *)realizedChain{
    
    self = [super init];
    
    self.realizedChain = realizedChain;
    
    return self;
}

#pragma  mark - View Life Cycle

- (void)viewDidLoad{
    
    // create a TJBCircuitReferenceVC with the dimensions of the containerView
    
    CGSize mainscreenSize = [UIScreen mainScreen].bounds.size;
    
    // due to scroll view's issues with auto layout and the fact that accessing containerView's bounds literally takes the dimensions in the xib, no matter what size the xib view is, I have to do this little bit of math
    // to properly do this, I will have to create IBOutlets for the auto layout constraints set in the xib file
    
    NSNumber *viewHeight = [NSNumber numberWithFloat: mainscreenSize.height - 28];
    NSNumber *viewWidth = [NSNumber numberWithFloat: mainscreenSize.width - 16];
    
    TJBCircuitActiveUpdatingVC *vc = [[TJBCircuitActiveUpdatingVC alloc] initWithRealizedChain: self.realizedChain
                                                                                    viewHeight: viewHeight
                                                                                     viewWidth: viewWidth];
    
    [self addChildViewController: vc];
    
    [self.circuitView addSubview: vc.view];
    
    [vc didMoveToParentViewController: self];
}



@end























