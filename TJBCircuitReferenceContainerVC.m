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
@property (weak, nonatomic) IBOutlet UISegmentedControl *comparisonTypeSegmentedControl;

// core

@property (nonatomic, strong) TJBRealizedChain *realizedChain;
@property (nonatomic, strong) TJBCircuitReferenceVC *childRoutineVC;

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
    
    [self configureSegmentedControl];
    
}

- (void)configureSegmentedControl{
    
    // configure the segmented control
    
    [self.comparisonTypeSegmentedControl addTarget: self
                                            action: @selector(scValueDidChange)
                                  forControlEvents: UIControlEventValueChanged];
    
}

- (void)configureViewAesthetics{
    
    // meta view
    
    self.view.backgroundColor = [[TJBAestheticsController singleton] yellowNotebookColor];
    
    // title label

    self.titleLabel1.backgroundColor = [UIColor darkGrayColor];
    self.titleLabel1.textColor = [UIColor whiteColor];
    self.titleLabel1.font = [UIFont boldSystemFontOfSize: 20];
    
    // segmented control
    
    self.comparisonTypeSegmentedControl.tintColor = [[TJBAestheticsController singleton] paleLightBlueColor];
    self.comparisonTypeSegmentedControl.backgroundColor = [UIColor darkGrayColor];
    CALayer *scLayer = self.comparisonTypeSegmentedControl.layer;
    scLayer.masksToBounds = YES;
    scLayer.cornerRadius = 25;
    scLayer.borderWidth = 1.0;
    scLayer.borderColor = [[TJBAestheticsController singleton] paleLightBlueColor].CGColor;
    
    // title bar container
    
    self.titleContainerView.backgroundColor = [UIColor blackColor];
    
}

- (void)viewWillAppear:(BOOL)animated{
    
    // create a TJBCircuitReferenceVC with the dimensions of the containerView    
    // due to scroll view's issues with auto layout and the fact that accessing containerView's bounds literally takes the dimensions in the xib, no matter what size the xib view is, I have to do this little bit of math
    // to properly do this, I will have to create IBOutlets for the auto layout constraints set in the xib file
    // must layout the view first to ensure the passed size is correct
    
    if (!self.childRoutineVC){
        
        [self.view layoutIfNeeded];
        
        TJBCircuitReferenceVC *vc = [[TJBCircuitReferenceVC alloc] initWithRealizedChain: self.realizedChain
                                                                                viewSize: self.circuitReferenceView.frame.size];
        
        [self addChildViewController: vc];
        
        [self.circuitReferenceView addSubview: vc.view];
        
        [vc didMoveToParentViewController: self];
        
        self.childRoutineVC = vc;
        
    }
    

    
}


#pragma mark - <UIViewControllerRestoration>


- (void)toggleComparisonMode{
    
    // switch to comparison mode designated by the segmented control
    
    NSInteger scInd = self.comparisonTypeSegmentedControl.selectedSegmentIndex;
    
    switch (scInd) {
        case 0:
            [self.childRoutineVC activateMode: ProgressMode];
            break;
            
        case 1:
            [self.childRoutineVC activateMode: TargetsMode];
            break;
            
        case 2:
            [self.childRoutineVC activateMode: EditingMode];
            break;
            
        default:
            break;
    }
    
}

#pragma mark - Target Actions

- (void)scValueDidChange{
    
    // switch to the mode designated by the SC
    
    [self toggleComparisonMode];
    
}




@end




































































