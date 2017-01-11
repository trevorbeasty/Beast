//
//  TJBWorkoutNavigationHub.m
//  Beast
//
//  Created by Trevor Beasty on 12/12/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import "TJBWorkoutNavigationHub.h"


#import "TJBCircuitDesignVC.h"

#import "TJBAestheticsController.h"

#import "NewOrExistinigCircuitVC.h"

#import "TJBRealizedSetActiveEntryTBC.h"

#import "TJBNumberSelectionVC.h"

//#import "TJBCircuitTemplateContainerVC.h"

#import "TJBCircuitTemplateVC.h"



@interface TJBWorkoutNavigationHub () 

@property (weak, nonatomic) IBOutlet UIButton *standaloneSetButton;
@property (weak, nonatomic) IBOutlet UIButton *circuitSlashSupersetButton;
@property (weak, nonatomic) IBOutlet UIButton *testButton;

- (IBAction)didPressStandaloneSetButton:(id)sender;
- (IBAction)didPressCircuitSlashSupersetButton:(id)sender;
- (IBAction)didPressTest:(id)sender;



@end

@implementation TJBWorkoutNavigationHub

#pragma mark - Instantiation

- (instancetype)init{
    self = [super init];
    
    // for restoration
    self.restorationClass = [TJBWorkoutNavigationHub class];
    self.restorationIdentifier = @"TJBWorkoutNavigationHub";
    
    return self;
}

#pragma mark - View Life Cycle

- (void)viewDidLoad{
    [self configureBackgroundView];
    [self viewAesthetics];
}

- (void)viewAesthetics{
    [[TJBAestheticsController singleton] configureButtonsInArray: @[self.standaloneSetButton,
                                                                    self.circuitSlashSupersetButton]
                                                     withOpacity: .9];
}

- (void)configureBackgroundView{
    UIImage *image = [UIImage imageNamed: @"girlOverheadKettlebell"];
    [[TJBAestheticsController singleton] addFullScreenBackgroundViewWithImage: image
                                                                   toRootView: self.view];
}

#pragma mark - Button Actions

- (void)didPressStandaloneSetButton:(id)sender{
    TJBRealizedSetActiveEntryTBC *tbc = [[TJBRealizedSetActiveEntryTBC alloc] initWithChildViewControllers];
    [self presentViewController: tbc
                       animated: YES
                     completion: nil];
}

- (void)didPressCircuitSlashSupersetButton:(id)sender{
    NewOrExistinigCircuitVC *vc = [[NewOrExistinigCircuitVC alloc]  init];
    
    [self presentViewController: vc
                       animated: NO
                     completion: nil];
}

- (IBAction)didPressTest:(id)sender{
    
    CGSize size = [UIScreen mainScreen].bounds.size;
    
    TJBCircuitTemplateVC *vc = [[TJBCircuitTemplateVC alloc] initWithTargetingWeight: [NSNumber numberWithBool: YES]
                                                                       targetingReps: [NSNumber numberWithBool: YES]
                                                                       targetingRest: [NSNumber numberWithBool: YES]
                                                                  targetsVaryByRound: [NSNumber numberWithBool: YES]
                                                                   numberOfExercises: [NSNumber numberWithInt: 6]
                                                                      numberOfRounds: [NSNumber numberWithInt: 5]
                                                                                name: @"test template"
                                                                          viewHeight: [NSNumber numberWithFloat: size.height]
                                                                           viewWidth: [NSNumber numberWithFloat: size.width]];
    
    [self presentViewController: vc
                       animated: YES
                     completion: nil];
}



@end




























