//
//  TJBLiftOptionsVC.m
//  Beast
//
//  Created by Trevor Beasty on 1/28/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBLiftOptionsVC.h"

// presented VC's

#import "TJBRealizedSetActiveEntryVC.h"
#import "TJBCircuitModeTBC.h"

@interface TJBLiftOptionsVC ()

// IBOutlet

@property (weak, nonatomic) IBOutlet UIButton *freeformButton;
@property (weak, nonatomic) IBOutlet UIButton *designedButton;
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;

// IBAction

- (IBAction)didPressFreeformButton:(id)sender;
- (IBAction)didPressDesignedButton:(id)sender;


@end

@implementation TJBLiftOptionsVC

#pragma mark - View Life Cycle

- (void)viewDidLoad{
    
    [self configureNavBar];
    
}

- (void)configureNavBar{
    
    UINavigationItem *navItem = [[UINavigationItem alloc] init];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle: @"Home"
                                                                     style: UIBarButtonItemStyleDone
                                                                    target: self
                                                                    action: @selector(didPressHome)];
    [navItem setLeftBarButtonItem: cancelButton];
    
    [self.navBar setItems: @[navItem]];
    
}

#pragma mark - IBAction

- (IBAction)didPressFreeformButton:(id)sender{
    
    TJBRealizedSetActiveEntryVC *vc = [[TJBRealizedSetActiveEntryVC alloc] init];
    
    [self presentViewController: vc
                       animated: NO
                     completion: nil];
    
}

- (IBAction)didPressDesignedButton:(id)sender{
    
    TJBCircuitModeTBC *tbc = [[TJBCircuitModeTBC alloc] init];
    
    [self presentViewController: tbc
                       animated: NO
                     completion: nil];  
    
}

- (void)didPressHome{
    
    [self dismissViewControllerAnimated: NO
                             completion: nil];
    
}






@end
