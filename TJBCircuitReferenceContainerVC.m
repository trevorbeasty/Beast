//
//  TJBCircuitReferenceContainerVC.m
//  Beast
//
//  Created by Trevor Beasty on 1/11/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBCircuitReferenceContainerVC.h"

// core data

#import "CoreDataController.h"

// child VC

#import "TJBCircuitReferenceVC.h"

// aesthetics

#import "TJBAestheticsController.h"

@interface TJBCircuitReferenceContainerVC () <UIViewControllerRestoration>

// IBOutlet

@property (weak, nonatomic) IBOutlet UIView *circuitReferenceView;

// core

@property (nonatomic, strong) TJBChainTemplate *chainTemplate;

@end

@implementation TJBCircuitReferenceContainerVC

#pragma mark - Instantiation

- (instancetype)initWithChainTemplate:(TJBChainTemplate *)chainTemplate{
    
    self = [super init];
    
    self.chainTemplate = chainTemplate;
    
    // for restoration
    
    [self setRestorationProperties];
    
    return self;
}

- (void)setRestorationProperties{
    
    //// set restoration class and identifier
    
    self.restorationClass = [TJBCircuitReferenceContainerVC class];
    self.restorationIdentifier = @"TJBCircuitReferenceContainerVC";
    
}

#pragma  mark - View Life Cycle

- (void)viewDidLoad{
    
    // create a TJBCircuitReferenceVC with the dimensions of the containerView
    
    CGSize mainscreenSize = [UIScreen mainScreen].bounds.size;
    
    // due to scroll view's issues with auto layout and the fact that accessing containerView's bounds literally takes the dimensions in the xib, no matter what size the xib view is, I have to do this little bit of math
    // to properly do this, I will have to create IBOutlets for the auto layout constraints set in the xib file
    
    NSNumber *viewHeight = [NSNumber numberWithFloat: mainscreenSize.height - 28];
    NSNumber *viewWidth = [NSNumber numberWithFloat: mainscreenSize.width - 16];
    
    TJBCircuitReferenceVC *vc = [[TJBCircuitReferenceVC alloc] initWithChainTemplate: self.chainTemplate
                                                                   contentViewHeight: viewHeight
                                                                    contentViewWidth: viewWidth];
    
    [self addChildViewController: vc];
    
    [self.circuitReferenceView addSubview: vc.view];
    
    [vc didMoveToParentViewController: self];
    
}


#pragma mark - <UIViewControllerRestoration>

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder{
    
    //// this class only requires a chain template as input to populate a thereafter static view.  Thus, this method must simply instantiate the VC with the appropriate chain template
    
    NSString *chainTemplateUniqueID = [coder decodeObjectForKey: @"chainTemplateUniqueID"];
    
    TJBChainTemplate *chainTemplate = [[CoreDataController singleton] chainTemplateWithUniqueID: chainTemplateUniqueID];
    
    TJBCircuitReferenceContainerVC *vc = [[TJBCircuitReferenceContainerVC alloc] initWithChainTemplate: chainTemplate];
    
    return vc;
    
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder{
    
    //// encode the string of the chain template so that it can be retrieved later
    
    [super encodeRestorableStateWithCoder: coder];
    
    [coder encodeObject: self.chainTemplate.uniqueID
                 forKey: @"chainTemplateUniqueID"];
    
}


@end




































































