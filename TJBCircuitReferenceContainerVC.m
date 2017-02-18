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

@interface TJBCircuitReferenceContainerVC () 

// IBOutlet

@property (weak, nonatomic) IBOutlet UIView *circuitReferenceView;
@property (weak, nonatomic) IBOutlet UIView *titleContainerView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel1;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel2;
@property (weak, nonatomic) IBOutlet UIButton *editButton;

// IBAction

- (IBAction)didPressEdit:(id)sender;

// core

@property (nonatomic, strong) TJBRealizedChain *realizedChain;
@property (nonatomic, strong) UIView *childContentView;

@end

@implementation TJBCircuitReferenceContainerVC

#pragma mark - Instantiation

- (instancetype)initWithRealizedChain:(TJBRealizedChain *)realizedChain{
    
    self = [super init];
    
    self.realizedChain = realizedChain;
    
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
    
    [self configureViewAesthetics];
    
    [self configureDisplayData];
    
}

- (void)configureDisplayData{
    
    self.titleLabel2.text = self.realizedChain.chainTemplate.name;
    
}

- (void)configureViewAesthetics{
    
    NSArray *titleLabels = @[self.titleLabel1, self.titleLabel2];
    for (UILabel *label in titleLabels){
        
        label.backgroundColor = [UIColor darkGrayColor];
        label.font = [UIFont boldSystemFontOfSize: 20.0];
        label.textColor = [UIColor whiteColor];
        
    }
    
    self.editButton.backgroundColor = [UIColor darkGrayColor];
    self.editButton.titleLabel.font = [UIFont boldSystemFontOfSize: 20.0];
    [self.editButton setTitleColor: [UIColor whiteColor]
                          forState: UIControlStateNormal];
    
}

- (void)viewWillAppear:(BOOL)animated{
    
    // create a TJBCircuitReferenceVC with the dimensions of the containerView    
    // due to scroll view's issues with auto layout and the fact that accessing containerView's bounds literally takes the dimensions in the xib, no matter what size the xib view is, I have to do this little bit of math
    // to properly do this, I will have to create IBOutlets for the auto layout constraints set in the xib file
    // must layout the view first to ensure the passed size is correct
    
    if (!self.childContentView){
        
        [self.view layoutIfNeeded];
        
        TJBCircuitReferenceVC *vc = [[TJBCircuitReferenceVC alloc] initWithRealizedChain: self.realizedChain
                                                                                viewSize: self.circuitReferenceView.frame.size];
        
        [self addChildViewController: vc];
        
        [self.circuitReferenceView addSubview: vc.view];
        
        [vc didMoveToParentViewController: self];
        
        self.childContentView = vc.view;
        
    }
    

    
}


#pragma mark - <UIViewControllerRestoration>

//+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder{
//    
//    //// this class only requires a chain template as input to populate a thereafter static view.  Thus, this method must simply instantiate the VC with the appropriate chain template
//    
//    NSString *chainTemplateUniqueID = [coder decodeObjectForKey: @"chainTemplateUniqueID"];
//    
//    TJBChainTemplate *chainTemplate = [[CoreDataController singleton] chainTemplateWithUniqueID: chainTemplateUniqueID];
//    
//    TJBCircuitReferenceContainerVC *vc = [[TJBCircuitReferenceContainerVC alloc] initWithChainTemplate: chainTemplate];
//    
//    return vc;
//    
//}
//
//- (void)encodeRestorableStateWithCoder:(NSCoder *)coder{
//    
//    //// encode the string of the chain template so that it can be retrieved later
//    
//    [super encodeRestorableStateWithCoder: coder];
//    
//    [coder encodeObject: self.chainTemplate.uniqueID
//                 forKey: @"chainTemplateUniqueID"];
//    
//}


- (IBAction)didPressEdit:(id)sender {
}
@end




































































