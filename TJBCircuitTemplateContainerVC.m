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

// presented VC's

#import "TJBWorkoutNavigationHub.h"
#import "TJBActiveRoutineGuidanceVC.h"
#import "TJBCircuitReferenceContainerVC.h"

// aesthetics

#import "TJBAestheticsController.h"

// core data

#import "CoreDataController.h"

@interface TJBCircuitTemplateContainerVC () <UIViewControllerRestoration>

// IBOutlet

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIButton *launchCircuitButton;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *roundsLabel;
@property (weak, nonatomic) IBOutlet UIButton *backButton;
@property (weak, nonatomic) IBOutlet UILabel *mainTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *rightTitleButton;

// IBAction

- (IBAction)didPressLaunchCircuit:(id)sender;
- (IBAction)didPressBack:(id)sender;

// core

@property (nonatomic, strong) TJBCircuitTemplateVC <TJBCircuitTemplateVCProtocol> *circuitTemplateVC;

// pertinent chainTemplate

@property (nonatomic, strong) TJBChainTemplate *chainTemplate;

@end

@implementation TJBCircuitTemplateContainerVC

#pragma mark - Instantiation

- (instancetype)initWithChainTemplate:(TJBChainTemplate *)chainTemplate{
    
    self = [super init];
    
    self.chainTemplate = chainTemplate;
    
    return self;
    
}

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

    return self;
    
}

- (void)setRestorationProperties{
    
    //// set the properties necessary for state restoration
    
    self.restorationClass = [TJBCircuitTemplateContainerVC class];
    self.restorationIdentifier = @"TJBCircuitTemplateContainerVC";
    
}



#pragma mark - View Life Cycle

- (void)viewDidLoad{
    
    [self setRestorationProperties];
    
    [self configureViewAesthetics];

}

- (void)viewDidAppear:(BOOL)animated{
    
    if (!self.circuitTemplateVC){
        
        [self configureContainerView];
        
    }
    
}


- (void)configureViewAesthetics{
    
    // title bar
    
    NSArray *titleButtons = @[self.backButton, self.rightTitleButton];
    for (UIButton *button in titleButtons){
        
        button.backgroundColor = [UIColor darkGrayColor];
        button.titleLabel.font = [UIFont boldSystemFontOfSize: 15.0];
        [button setTitleColor: [[TJBAestheticsController singleton] blueButtonColor]
                     forState: UIControlStateNormal];
        
    }
    
    NSArray *titleLabels = @[self.mainTitleLabel, self.roundsLabel, self.titleLabel];
    for (UILabel *label in titleLabels){
        
        label.backgroundColor = [UIColor darkGrayColor];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont boldSystemFontOfSize: 20.0];
        
    }
    
    self.roundsLabel.font = [UIFont systemFontOfSize:15.0];
    
    // launch button
    
    self.launchCircuitButton.backgroundColor = [[TJBAestheticsController singleton] blueButtonColor];
    [self.launchCircuitButton setTitleColor: [UIColor whiteColor]
                                   forState: UIControlStateNormal];
    self.launchCircuitButton.titleLabel.font = [UIFont boldSystemFontOfSize: 20.0];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    // title labels text
    
    self.titleLabel.text = self.chainTemplate.name;
    
    NSString *word;
    int number = self.chainTemplate.numberOfRounds;
    if (number == 1){
    
        word = @"round";
    
    } else{
    
        word = @"rounds";
            
    }
    
    NSString *exerciseWord;
    int exerciseNumber = self.chainTemplate.numberOfExercises;
    if (exerciseNumber == 1){
        exerciseWord = @"exercise";
    } else{
        exerciseWord = @"exercises";
    }
    
    NSString *roundsText = [NSString stringWithFormat: @"%d %@, %d %@",
                            self.chainTemplate.numberOfExercises,
                            exerciseWord,
                            self.chainTemplate.numberOfRounds,
                            word];
    
    self.roundsLabel.text = roundsText;
    
}

- (void)configureContainerView{
    
    //// create the TJBCircuitTemplateVC
    
    TJBCircuitTemplateVC *vc = [[TJBCircuitTemplateVC alloc] initWithSkeletonChainTemplate: self.chainTemplate
                                                                                  viewSize: self.containerView.frame.size];
    
    self.circuitTemplateVC = vc;
    
    [self addChildViewController: vc];
    
    [self.containerView addSubview: vc.view];
    
    [vc didMoveToParentViewController: self];
    
}



#pragma mark - Button Actions

- (void)alertUserInputIncomplete{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"All Selections Not Made"
                                                                   message: @"Please make all selections"
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
    
    // this VC and the circuit template VC share the same chain template.  Only the circuit template VC has the user-selected exercises, thus, it must be asked if all user input has been collected.  If it has all been collected, the circuit template VC will add the user-selected exercises to the chain template.
    
    BOOL requisiteUserInputCollected = [self.circuitTemplateVC allUserInputCollected];
    
    if (requisiteUserInputCollected){
        
        // it has been determined that the chain template is complete, so update its corresponding property and save the context
        
        self.chainTemplate.isIncomplete = NO;
        [[CoreDataController singleton] saveContext];
        
        // alert
        
        NSString *message = [NSString stringWithFormat: @"'%@' has been successfully saved",
                             self.chainTemplate.name];
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"Circuit Saved"
                                                                       message: message
                                                                preferredStyle: UIAlertControllerStyleAlert];
        
        void (^alertBlock)(UIAlertAction *) = ^(UIAlertAction *action){
            
            TJBActiveRoutineGuidanceVC *vc1 = [[TJBActiveRoutineGuidanceVC alloc] initFreshRoutineWithChainTemplate: self.chainTemplate];
            vc1.tabBarItem.title = @"Active";
            
            TJBWorkoutNavigationHub *vc3 = [[TJBWorkoutNavigationHub alloc] initWithHomeButton: NO];
            vc3.tabBarItem.title = @"Workout Log";
            
            TJBCircuitReferenceContainerVC *vc2 = [[TJBCircuitReferenceContainerVC alloc] initWithRealizedChain: vc1.realizedChain];
            vc2.tabBarItem.title = @"Progress";
            
            // tab bar
            
            UITabBarController *tbc = [[UITabBarController alloc] init];
            [tbc setViewControllers: @[vc1, vc2, vc3]];
            tbc.tabBar.translucent = NO;
            
            
            [self presentViewController: tbc
                               animated: NO
                             completion: nil];
            
//            TJBActiveRoutineGuidanceVC *vc1 = [[TJBActiveRoutineGuidanceVC alloc] initFreshRoutineWithChainTemplate: self.chainTemplate];
//            vc1.tabBarItem.title = @"Active";
//            
//            TJBWorkoutNavigationHub *vc2 = [[TJBWorkoutNavigationHub alloc] init];
//            vc2.tabBarItem.title = @"Workout Log";
//            
//            // tab bar
//            
//            UITabBarController *tbc = [[UITabBarController alloc] init];
//            [tbc setViewControllers: @[vc1, vc2]];
//            tbc.tabBar.translucent = NO;
//            tbc.navigationItem.title = @"Lift Routine";
//            
//            UIBarButtonItem *backButton = [[UIBarButtonItem alloc] initWithTitle: @"Back"
//                                                                           style: UIBarButtonItemStyleDone
//                                                                          target: vc1
//                                                                          action: @selector(didPressBack)];
//            [tbc.navigationItem setLeftBarButtonItem: backButton];
//            
//            // navigation controller
//            
//            UINavigationController *navC = [[UINavigationController alloc] initWithRootViewController: tbc];
//            navC.navigationBar.translucent = NO;
//            
//            [self presentViewController: navC
//                               animated: NO
//                             completion: nil];
            
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

- (IBAction)didPressBack:(id)sender{
    
    [self dismissViewControllerAnimated: NO
                             completion: nil];
    
}
    

- (void)didPressX{
    
    // delete the chain template from the persistent store if it is incomplete
    
    // must check for completeness of chain template.  If all user selections have been been made but the 'launch circuit' or '+' buttons have not been pressed, its 'isIncomplete' property will not be updated
    
    BOOL isComplete = [[CoreDataController singleton] chainTemplateHasCollectedAllRequisiteUserInput: self.chainTemplate];
    self.chainTemplate.isIncomplete = !isComplete;
    
    if (self.chainTemplate.isIncomplete){
        
        [[CoreDataController singleton] deleteChainWithChainType: ChainTemplateType
                                                           chain: self.chainTemplate];
    
    }
    
    [self dismissViewControllerAnimated: NO
                             completion: nil];
    
}

- (void)didPressAdd{
    
    //// this VC and the circuit template VC share the same chain template.  Only the circuit template VC has the user-selected exercises, thus, it must be asked if all user input has been collected.  If it has all been collected, the circuit template VC will add the user-selected exercises to the chain template.
    
    BOOL requisiteUserInputCollected = [self.circuitTemplateVC allUserInputCollected];
    
    if (requisiteUserInputCollected){
        
        // it has been determined that the chain template is complete, so update its corresponding property and save the context
        
        self.chainTemplate.isIncomplete = NO;
        [[CoreDataController singleton] saveContext];
        
        // alert
        
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

#pragma mark - <UIViewControllerRestoration>

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder{
    
    //// the only thing that needs to be done here is to restore the chain template that was being used and call the normal init method.  The decoder will be responsible for kicking off the process that updates all the views to their previous state
    
    NSString *chainTemplateUniqueID = [coder decodeObjectForKey: @"chainTemplateUniqueID"];
    
    // have CoreDataController retrieve the appropriate chain template
    
    TJBChainTemplate *chainTemplate = [[CoreDataController singleton] chainTemplateWithUniqueID: chainTemplateUniqueID];
    
    // create the TJBCircuitTemplateContainerVC and return it
    
    TJBCircuitTemplateContainerVC *vc = [[TJBCircuitTemplateContainerVC alloc] initWithChainTemplate: chainTemplate];
    
    return vc;
    
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder{
    
    [super decodeRestorableStateWithCoder: coder];
    
    // tell the child VC to populate its views with all user selected input
    
    [self.circuitTemplateVC populateChildVCViewsWithUserSelectedValues];
    
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder{
    
    //// all that needs to be done here is to record the unique ID of the chain template so that the CoreDataConroller can reload the correct chain template
    
    [super encodeRestorableStateWithCoder: coder];
    
    NSString *chainTemplateUniqueID = self.chainTemplate.uniqueID;
    
    [coder encodeObject: chainTemplateUniqueID
                 forKey: @"chainTemplateUniqueID"];
    
}



@end




















































