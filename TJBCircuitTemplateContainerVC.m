//
//  TJBCircuitTemplateContainerVC.m
//  Beast
//
//  Created by Trevor Beasty on 1/10/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBCircuitTemplateContainerVC.h"

#import "TJBCircuitTemplateVC.h"

#import "TJBCircuitTemplateVCProtocol.h"

#import "TJBChainTemplate+CoreDataProperties.h"

// active guidance tbc

#import "TJBCircuitModeTBC.h"

// aesthetics

#import "TJBAestheticsController.h"

// core data

#import "CoreDataController.h"

@interface TJBCircuitTemplateContainerVC ()

// IBOutlet

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIButton *launchCircuitButton;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

// IBAction

- (IBAction)didPressLaunchCircuit:(id)sender;

// core

@property (nonatomic, strong) NSNumber *targetingWeight;
@property (nonatomic, strong) NSNumber *targetingReps;
@property (nonatomic, strong) NSNumber *targetingRest;
@property (nonatomic, strong) NSNumber *targetsVaryByRound;
@property (nonatomic, strong) NSNumber *numberOfExercises;
@property (nonatomic, strong) NSNumber *numberOfRounds;
@property (nonatomic, strong) NSString *chainTemplateName;
@property (nonatomic, strong) NSNumber *childViewHeight;
@property (nonatomic, strong) NSNumber *childViewWidth;

//// delegate

// so that this VC can deal with events requirinig evaluation of the chain template
// alternatively, I could hold onto the chain template and make sure my version stays up to date (I think it is always up to date by nature of pointers and objects) using notifications
// may want to keep the VC property around anyways to deal with any events not directly involving the chain template

@property (nonatomic, strong) TJBCircuitTemplateVC <TJBCircuitTemplateVCProtocol> *circuitTemplateVC;

// this should not create a strong reference cycle because there are no strong references traveling back up hill
@property (nonatomic, weak) TJBChainTemplate *chainTemplate;

@end

@implementation TJBCircuitTemplateContainerVC

#pragma mark - Instantiation

- (instancetype)initWithTargetingWeight:(NSNumber *)targetingWeight targetingReps:(NSNumber *)targetingReps targetingRest:(NSNumber *)targetingRest targetsVaryByRound:(NSNumber *)targetsVaryByRound numberOfExercises:(NSNumber *)numberOfExercises numberOfRounds:(NSNumber *)numberOfRounds name:(NSString *)name{
    
    self = [super init];
    
    // core
    
    self.targetingWeight = targetingWeight;
    self.targetingReps = targetingReps;
    self.targetingRest = targetingRest;
    self.targetsVaryByRound = targetsVaryByRound;
    self.numberOfExercises = numberOfExercises;
    self.numberOfRounds = numberOfRounds;
    self.chainTemplateName = name;
    
    [self setViewDimensionPropertiesForUseByChildVC];

    return self;
    
}

- (void)setViewDimensionPropertiesForUseByChildVC{
    
    // due to scroll view's issues with auto layout and the fact that accessing containerView's bounds literally takes the dimensions in the xib, no matter what size the xib view is, I have to do this little bit of math
    // to properly do this, I will have to create IBOutlets for the auto layout constraints set in the xib file
    
    CGSize mainscreenSize = [UIScreen mainScreen].bounds.size;
    
    self.childViewHeight = [NSNumber numberWithFloat: mainscreenSize.height - 124];
    self.childViewWidth = [NSNumber numberWithFloat: mainscreenSize.width - 16];
    
}

#pragma mark - View Life Cycle

- (void)viewDidLoad{
    
    [self configureContainerView];
    
    [self configureNavigationBar];
    
    [self addBackgroundView];
    
    [self configureViewAesthetics];

}

- (void)configureViewAesthetics{
    
    [[TJBAestheticsController singleton] configureButtonsInArray: @[self.launchCircuitButton]
                                                     withOpacity: .85];
    
}

- (void)addBackgroundView{
    
    [[TJBAestheticsController singleton] addFullScreenBackgroundViewWithImage: [UIImage imageNamed: @"weightRack"]
                                                                   toRootView: self.view
                                                                 imageOpacity: .35];
}

- (void)configureContainerView{
    
    TJBChainTemplate *skeletonChainTemplate = [[CoreDataController singleton] createAndSaveSkeletonChainTemplateWithNumberOfExercises: self.numberOfExercises
                                                                                                                       numberOfRounds: self.numberOfRounds
                                                                                                                                 name: self.chainTemplateName
                                                                                                                      targetingWeight: self.targetingWeight
                                                                                                                        targetingReps: self.targetingReps
                                                                                                                        targetingRest: self.targetingRest
                                                                                                                   targetsVaryByRound: self.targetsVaryByRound];
    self.chainTemplate = skeletonChainTemplate;
    
    TJBCircuitTemplateVC *vc = [[TJBCircuitTemplateVC alloc] initWithSkeletonChainTemplate: skeletonChainTemplate
                                                                                viewHeight: self.childViewHeight
                                                                                 viewWidth: self.childViewWidth];
    
    self.circuitTemplateVC = vc;
    
    [self addChildViewController: vc];
    
    [self.containerView addSubview: vc.view];
    
    [vc didMoveToParentViewController: self];
    
}

- (void)configureNavigationBar{
    
    // create the navigation item
    
    UINavigationItem *navItem = [[UINavigationItem alloc] init];
    
    // must evaluate IV's to determine appropriate title for navItem
    
    NSString *word;
    int number = [self.numberOfRounds intValue];
    
    if (number == 1){
        
        word = @"round";
        
    } else{
        
        word = @"rounds";
        
    }
    
    NSString *title = [NSString stringWithFormat: @"%@ (%d %@)",
                       self.chainTemplateName,
                       number,
                       word];
    
    [navItem setTitle: title];
    
    // add a navigation bar button as well
    
        
    UIBarButtonItem *xBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemStop
                                                                                target: self
                                                                                action: @selector(didPressX)];
    [navItem setLeftBarButtonItem: xBarButton];
    
    UIBarButtonItem *goBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemAdd
                                                                                 target: self
                                                                                 action: @selector(didPressAdd)];
    [navItem setRightBarButtonItem: goBarButton];
    
    // set the items of the navigation bar
    
    [self.navigationBar setItems: @[navItem]];
}

#pragma mark - Button Actions

- (void)alertUserInputIncomplete{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"User Input Error"
                                                                   message: @"Please make selections for all active fields"
                                                            preferredStyle: UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle: @"Continue"
                                                     style: UIAlertActionStyleDefault
                                                   handler: nil];
    [alert addAction: action];
    [self presentViewController: alert
                       animated: YES
                     completion: nil];
    
}

- (IBAction)didPressLaunchCircuit:(id)sender{
    
    BOOL requisiteUserInputCollected = [self.circuitTemplateVC allUserSelectionsMade];
    
    if (requisiteUserInputCollected){
        
        TJBChainTemplate *savedChainTemplate = [self.circuitTemplateVC createAndSaveChainTemplate];
        
        // alert
        
        NSString *message = [NSString stringWithFormat: @"'%@' has been successfully saved",
                             savedChainTemplate.name];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"Circuit Saved"
                                                                       message: message
                                                                preferredStyle: UIAlertControllerStyleAlert];
        
        void (^alertBlock)(UIAlertAction *) = ^(UIAlertAction *action){
            
            TJBCircuitModeTBC *tbc = [[TJBCircuitModeTBC alloc] initWithChainTemplate: savedChainTemplate];
            
            [self presentViewController: tbc
                               animated: YES
                             completion: nil];
            
        };
        
        UIAlertAction *action = [UIAlertAction actionWithTitle: @"Continue"
                                                         style: UIAlertActionStyleDefault
                                                       handler: alertBlock];
        [alert addAction: action];
        
        [self presentViewController: alert
                           animated: YES
                         completion: nil];
    } else{
        
    [self alertUserInputIncomplete];
        
    }
    
}
    

- (void)didPressX{
    
    // delete the chain template from the persistent store
    
    [[CoreDataController singleton] deleteChainWithChainType: ChainTemplateType
                                                       chain: self.chainTemplate];
    
    [self dismissViewControllerAnimated: NO
                             completion: nil];
    
}

- (void)didPressAdd{
    
    BOOL requisiteUserInputCollected = [self.circuitTemplateVC allUserSelectionsMade];
    
    if (requisiteUserInputCollected){
        
        TJBChainTemplate *savedChainTemplate = [self.circuitTemplateVC createAndSaveChainTemplate];
        
        NSString *message = [NSString stringWithFormat: @"'%@' has been successfully saved",
                             savedChainTemplate.name];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"Circuit Saved"
                                                                       message: message
                                                                preferredStyle: UIAlertControllerStyleAlert];
        
        void (^alertBlock)(UIAlertAction *) = ^(UIAlertAction *action){
            
            [self dismissViewControllerAnimated: NO
                                     completion: nil];
            
        };
        
        UIAlertAction *action = [UIAlertAction actionWithTitle: @"Continue"
                                                         style: UIAlertActionStyleDefault
                                                       handler: alertBlock];
        [alert addAction: action];
        
        [self presentViewController: alert
                           animated: YES
                         completion: nil];
    } else{
        
        [self alertUserInputIncomplete];
        
    }
}

@end
























