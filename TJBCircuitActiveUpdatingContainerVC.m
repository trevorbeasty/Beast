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

#import "CoreDataController.h"

// aesthetics

#import "TJBAestheticsController.h"

typedef enum{
    
    MakingCorrectionsActive,
    MakingCorrectionsInactive
    
}MakingCorrectionsState;

@interface TJBCircuitActiveUpdatingContainerVC () <UIViewControllerRestoration>

{
    // for making corrections
    
    MakingCorrectionsState _makingCorrectionsState;
    
}

// core

@property (nonatomic, strong) TJBRealizedChain *realizedChain;

// IBAction

- (IBAction)didPressMakeCorrectionsButton:(id)sender;


// IBOutlet

@property (weak, nonatomic) IBOutlet UIView *circuitView;
@property (weak, nonatomic) IBOutlet UIButton *makeCorrectionsButton;

@end



@implementation TJBCircuitActiveUpdatingContainerVC

#pragma mark - Instantiation

- (instancetype)initWithRealizedChain:(TJBRealizedChain *)realizedChain{
    
    self = [super init];
    
    self.realizedChain = realizedChain;
    
    // for making corrections.  This VC is created in the MakingCorrectionsInactive state
    
    _makingCorrectionsState = MakingCorrectionsInactive;
    
    // for restoration
    
    [self setRestorationProperties];
    
    return self;
}

- (void)setRestorationProperties{
    
    //// set the restoration identifier and class
    
    self.restorationClass = [TJBCircuitActiveUpdatingContainerVC class];
    self.restorationIdentifier = @"TJBCircuitActiveUpdatingContainerVC";
    
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
    
    // assign vc to appropriate property to facillitate delegation of circuit tab bar controller VC's
    
    self.circuitActiveUpdatingVC = vc;
    
    // layout views
    
    [self addChildViewController: vc];
    
    [self.circuitView addSubview: vc.view];
    
    [self addBackgroundImage];
    
    [self configureViewAesthetics];
    
    [vc didMoveToParentViewController: self];
}

- (void)addBackgroundImage{
    
    [[TJBAestheticsController singleton] addFullScreenBackgroundViewWithImage: [UIImage imageNamed: @"FinlandBackSquat"]
                                                                   toRootView: self.view
                                                                 imageOpacity: .45];
    
}

- (void)configureViewAesthetics{
    
    //// give the button the correct appearance
    
    [[TJBAestheticsController singleton] configureButtonsInArray: @[self.makeCorrectionsButton]
                                                     withOpacity: .85];
    
}


#pragma mark - IBAction

- (IBAction)didPressMakeCorrectionsButton:(id)sender{
    
    //// Execution is state dependent.  If MakingCorrectionsInactive, enable the weight and reps button buttons and change their appearance.  Change the text of the button to 'Done'.  Else, reconfigure normal state and set state variable appropriately
    
    if (_makingCorrectionsState == MakingCorrectionsInactive){
        
        // call the protocol method of child VC
        
        [self.circuitActiveUpdatingVC enableWeightAndRepsButtonsAndGiveEnabledAppearance];
        
        // change button appearance and reset state
        
        [self.makeCorrectionsButton setTitle: @"Done"
                                    forState: UIControlStateNormal];
        
        _makingCorrectionsState = MakingCorrectionsActive;
        
    } else if (_makingCorrectionsState == MakingCorrectionsActive){
        
        [self.circuitActiveUpdatingVC disableWeightAndRepsButtonsAndGiveDisabledAppearance];
        
        [self.makeCorrectionsButton setTitle: @"Make Corrections"
                                    forState: UIControlStateNormal];
        
        _makingCorrectionsState = MakingCorrectionsInactive;
        
    }

}

#pragma mark - <UIViewControllerRestoration>

//// I should consider leveraging the first incomplete exercise and round properties of the realized chain.  This way the views will be layed out correctly the first time and restoration will only require that I provide the appropriate realized chain

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder{
    
    //// this method will just create the class with the appropriate realized chain just as in normal, initial instantiation
    
    NSString *realizedChainUniqueID = [coder decodeObjectForKey: @"realizedChainUniqueID"];
    
    TJBRealizedChain *realizedChain = [[CoreDataController singleton] realizedChainWithUniqueID: realizedChainUniqueID];
    
    TJBCircuitActiveUpdatingContainerVC *vc = [[TJBCircuitActiveUpdatingContainerVC alloc] initWithRealizedChain: realizedChain];
    
    return vc;
    
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder{
    
    //// just encode the realized chain unique ID
    
    [super encodeRestorableStateWithCoder: coder];
    
    [coder encodeObject: self.realizedChain.uniqueID
                 forKey: @"realizedChainUniqueID"];
    
}


@end














































