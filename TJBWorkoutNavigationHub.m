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

#import "TJBCircuitReferenceVC.h"

// history

#import "TJBCompleteHistoryVC.h"




@interface TJBWorkoutNavigationHub ()

// IBOutlet

@property (weak, nonatomic) IBOutlet UIButton *standaloneSetButton;
@property (weak, nonatomic) IBOutlet UIButton *circuitSlashSupersetButton;
@property (weak, nonatomic) IBOutlet UIButton *historyButton;

// IBAction

- (IBAction)didPressStandaloneSetButton:(id)sender;
- (IBAction)didPressCircuitSlashSupersetButton:(id)sender;
- (IBAction)didPressHistoryButton:(id)sender;

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
                                                                    self.circuitSlashSupersetButton,
                                                                    self.historyButton]
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

- (IBAction)didPressHistoryButton:(id)sender {
    
    TJBCompleteHistoryVC *vc = [[TJBCompleteHistoryVC alloc] init];
    
    [self presentViewController: vc
                       animated: YES
                     completion: nil];
    
}


@end




























