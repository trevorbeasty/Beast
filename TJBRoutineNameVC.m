//
//  TJBRoutineNameVC.m
//  Beast
//
//  Created by Trevor Beasty on 4/10/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBRoutineNameVC.h"

// aesthetics

#import "TJBAestheticsController.h"

@interface TJBRoutineNameVC ()

// IBOutlet

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;


@end

@implementation TJBRoutineNameVC

#pragma mark - View Life Cycle

- (void)viewDidLoad{
    
    [self configureViewAesthetics];
    
}



#pragma mark - View Helper Methods

- (void)configureViewAesthetics{
    
    self.nameLabel.font = [UIFont boldSystemFontOfSize: 15];
    self.nameLabel.backgroundColor = [UIColor clearColor];
    self.nameLabel.textColor = [UIColor whiteColor];
    
    self.view.backgroundColor = [UIColor clearColor];
    
    self.nameTextField.font = [UIFont systemFontOfSize: 20];
    self.nameTextField.backgroundColor = [UIColor clearColor];
    self.nameTextField.textColor = [[TJBAestheticsController singleton] paleLightBlueColor];
    CALayer *ntfLayer = self.nameTextField.layer;
    ntfLayer.masksToBounds = YES;
    ntfLayer.borderColor = [[TJBAestheticsController singleton] paleLightBlueColor].CGColor;
    ntfLayer.borderWidth = 2.0;
    ntfLayer.cornerRadius = 8;
    
}

@end
