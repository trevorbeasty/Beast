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
#import "NewOrExistinigCircuitVC.h"

// aesthetics

#import "TJBAestheticsController.h"


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
    
    [self configureViewAesthetics];
    
}

- (void)configureViewAesthetics{
    
    NSArray *buttons = @[self.freeformButton,
                         self.designedButton];
    
    for (UIButton *button in buttons){
        
        button.backgroundColor = [[TJBAestheticsController singleton] blueButtonColor];
        [button setTitleColor: [UIColor whiteColor]
                     forState: UIControlStateNormal];
        button.titleLabel.font = [UIFont boldSystemFontOfSize: 20.0];
        
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = 4.0;
        
    }
    
}

- (void)configureNavBar{
    
    UINavigationItem *navItem = [[UINavigationItem alloc] init];
    
    navItem.title = @"Lift Options";
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle: @"Home"
                                                                     style: UIBarButtonItemStyleDone
                                                                    target: self
                                                                    action: @selector(didPressHome)];
    [navItem setLeftBarButtonItem: cancelButton];
    
    [self.navBar setItems: @[navItem]];
    
    [self.navBar setTitleTextAttributes: @{NSFontAttributeName: [UIFont boldSystemFontOfSize: 20.0]}];
    
}

#pragma mark - IBAction

- (IBAction)didPressFreeformButton:(id)sender{
    
    TJBRealizedSetActiveEntryVC *vc = [[TJBRealizedSetActiveEntryVC alloc] init];
    
    [self presentViewController: vc
                       animated: NO
                     completion: nil];
    
}

- (IBAction)didPressDesignedButton:(id)sender{
    
    NewOrExistinigCircuitVC *vc = [[NewOrExistinigCircuitVC alloc] init];
    
    [self presentViewController: vc
                       animated: NO
                     completion: nil];
    
}

//- (IBAction)didPressTestButton:(id)sender{
//    
//    TJBNumberSelectionVC *vc = [[TJBNumberSelectionVC alloc] initWithNumberTypeIdentifier: WeightType
//                                                                                    title: @"Bench"
//                                                                              cancelBlock: nil
//                                                                      numberSelectedBlock: nil];
//    
//    [self presentViewController:vc
//                       animated: YES
//                     completion: nil];
//    
//}

- (void)didPressHome{
    
    [self dismissViewControllerAnimated: NO
                             completion: nil];
    
}






@end
