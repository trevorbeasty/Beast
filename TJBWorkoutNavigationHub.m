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

@property (weak, nonatomic) IBOutlet UIButton *freeformButton;
@property (weak, nonatomic) IBOutlet UIButton *designedButton;


// IBAction

- (IBAction)didPressFreeformButton:(id)sender;
- (IBAction)didPressDesignedButton:(id)sender;

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
    
    [self configureViewAesthetics];
    
    
}

- (void)configureViewAesthetics{
    
    NSArray *buttons = @[self.freeformButton,
                         self.designedButton];
    
    for (UIButton *button in buttons){
        
        button.backgroundColor = [[TJBAestheticsController singleton] color2];
        [button setTitleColor: [UIColor whiteColor]
                     forState: UIControlStateNormal];
        
    }
    
}


#pragma mark - Button Actions


- (IBAction)didPressFreeformButton:(id)sender {
    
    TJBRealizedSetActiveEntryTBC *tbc = [[TJBRealizedSetActiveEntryTBC alloc] initWithChildViewControllers];
    
    [self presentViewController: tbc
                       animated: YES
                     completion: nil];
    
}




- (void)didPressDesignedButton:(id)sender{
    
    NewOrExistinigCircuitVC *vc = [[NewOrExistinigCircuitVC alloc] init];
    
    [self presentViewController: vc
                       animated: YES
                     completion: nil];
    
}


@end




























