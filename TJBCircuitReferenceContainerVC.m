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
@property (weak, nonatomic) IBOutlet UISegmentedControl *comparisonTypeSegmentedControl;
@property (weak, nonatomic) IBOutlet UIButton *doneButton;

// IBAction

- (IBAction)didPressEdit:(id)sender;
- (IBAction)didPressDoneButton:(id)sender;

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
    
    [self configureDisplayData];
    
}

- (void)configureDisplayData{
    
    self.titleLabel2.text = self.realizedChain.chainTemplate.name;
    
    // initial state (editing not active)
    
    self.doneButton.enabled = NO;
    
}

- (void)configureViewAesthetics{
    
    NSArray *titleLabels = @[self.titleLabel1, self.titleLabel2];
    for (UILabel *label in titleLabels){
        
        label.backgroundColor = [UIColor darkGrayColor];
        label.font = [UIFont boldSystemFontOfSize: 20.0];
        label.textColor = [UIColor whiteColor];
        
    }
    
    NSArray *buttons = @[self.editButton, self.doneButton];
    
    for (UIButton *button in buttons){
        
        button.backgroundColor = [[TJBAestheticsController singleton] blueButtonColor];
        button.titleLabel.font = [UIFont boldSystemFontOfSize: 20.0];
        [button setTitleColor: [UIColor whiteColor]
                              forState: UIControlStateNormal];
        
    }
    
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




- (IBAction)didPressEdit:(id)sender{
    
    [self.childRoutineVC activateMode: EditingMode];
    
    // button state
    
    self.doneButton.enabled = YES;
    self.editButton.enabled = NO;
    
}

- (IBAction)didPressDoneButton:(id)sender{
    
    [self toggleToComparisonMode];
    
    // button state
    
    self.doneButton.enabled = NO;
    self.editButton.enabled = YES;
    
}

- (void)toggleToComparisonMode{
    
    // switch to comparison mode designated by the segmented control
    
    NSInteger scInd = self.comparisonTypeSegmentedControl.selectedSegmentIndex;
    
    switch (scInd) {
        case 0:
            [self.childRoutineVC activateMode: AbsoluteComparisonMode];
            break;
            
        case 1:
            [self.childRoutineVC activateMode: RelativeComparisonMode];
            break;
            
        default:
            break;
    }
    
}




@end




































































