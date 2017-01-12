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

@property (nonatomic, strong) NSNumber *childViewHeight;
@property (nonatomic, strong) NSNumber *childViewWidth;

// circuit template

@property (nonatomic, strong) TJBCircuitTemplateVC <TJBCircuitTemplateVCProtocol> *circuitTemplateVC;

// pertinent chainTemplate

@property (nonatomic, weak) TJBChainTemplate *chainTemplate;

@end

@implementation TJBCircuitTemplateContainerVC

#pragma mark - Instantiation

- (instancetype)initWithTargetingWeight:(NSNumber *)targetingWeight targetingReps:(NSNumber *)targetingReps targetingRest:(NSNumber *)targetingRest targetsVaryByRound:(NSNumber *)targetsVaryByRound numberOfExercises:(NSNumber *)numberOfExercises numberOfRounds:(NSNumber *)numberOfRounds name:(NSString *)name{
    
    self = [super init];
    
    // chain template
    
    TJBChainTemplate *skeletonChainTemplate = [[CoreDataController singleton] createAndSaveSkeletonChainTemplateWithNumberOfExercises: numberOfExercises
                                                                                                                       numberOfRounds: numberOfRounds
                                                                                                                                 name: name
                                                                                                                      targetingWeight: targetingWeight
                                                                                                                        targetingReps: targetingReps
                                                                                                                        targetingRest: targetingRest
                                                                                                                   targetsVaryByRound: targetsVaryByRound];
    self.chainTemplate = skeletonChainTemplate;
    
    // prep for adding child VC
    
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
    
    //// create the TJBCircuitTemplateVC
    
    TJBCircuitTemplateVC *vc = [[TJBCircuitTemplateVC alloc] initWithSkeletonChainTemplate: self.chainTemplate
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
    int number = self.chainTemplate.numberOfRounds;
    
    if (number == 1){
        
        word = @"round";
        
    } else{
        
        word = @"rounds";
        
    }
    
    NSString *title = [NSString stringWithFormat: @"%@ (%d %@)",
                       self.chainTemplate.name,
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
    
    CoreDataController *coreDataC = [CoreDataController singleton];
    
    // this VC and the circuit template VC share the same chain template.  Only the circuit template VC has the user-selected exercises, thus, it must be asked if all user input has been collected.  If it has all been collected, the circuit template VC will add the user-selected exercises to the chain template.
    
    BOOL requisiteUserInputCollected = [self.circuitTemplateVC allUserInputCollected];
    
    if (requisiteUserInputCollected){
        
        NSManagedObjectContext *moc = [coreDataC moc];
        
        if ([moc hasChanges]){
            
            NSError *error = nil;
            [moc save: &error];
            
        }
        
        // alert
        
        NSString *message = [NSString stringWithFormat: @"'%@' has been successfully saved",
                             self.chainTemplate.name];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"Circuit Saved"
                                                                       message: message
                                                                preferredStyle: UIAlertControllerStyleAlert];
        
        void (^alertBlock)(UIAlertAction *) = ^(UIAlertAction *action){
            
            TJBCircuitModeTBC *tbc = [[TJBCircuitModeTBC alloc] initWithChainTemplate: self.chainTemplate];
            
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
    
    CoreDataController *coreDataC = [CoreDataController singleton];
    
    // this VC and the circuit template VC share the same chain template.  Only the circuit template VC has the user-selected exercises, thus, it must be asked if all user input has been collected.  If it has all been collected, the circuit template VC will add the user-selected exercises to the chain template.
    
    BOOL requisiteUserInputCollected = [self.circuitTemplateVC allUserInputCollected];
    
    if (requisiteUserInputCollected){
        
        NSManagedObjectContext *moc = [coreDataC moc];
        
        if ([moc hasChanges]){
            
            NSError *error = nil;
            [moc save: &error];
            
        }
        
        NSString *message = [NSString stringWithFormat: @"'%@' has been successfully saved",
                             self.chainTemplate.name];
        
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
























