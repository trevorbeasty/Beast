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

// master controller

#import "TJBCircuitTemplateVC.h"

@interface TJBRoutineNameVC () <UITextFieldDelegate>

// IBOutlet

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UITextField *nameTextField;

// core

@property (weak) TJBCircuitTemplateVC <TJBCircuitTemplateVCProtocol> *masterController;


@end

@implementation TJBRoutineNameVC

#pragma mark - Instantiation

- (instancetype)initWithMasterController:(TJBCircuitTemplateVC<TJBCircuitTemplateVCProtocol> *)masterController{

    self = [super init];
    
    self.masterController = masterController;
    
    return self;

}

#pragma mark - View Life Cycle

- (void)viewDidLoad{
    
    [self configureViewAesthetics];
    
    [self configureTextFieldFunctionality];
    
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
    ntfLayer.borderColor = [UIColor whiteColor].CGColor;
    ntfLayer.borderWidth = 2.0;
    ntfLayer.cornerRadius = 8;
    
}

- (void)configureTextFieldFunctionality{
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(routineNameDidChange)
                                                 name:UITextFieldTextDidChangeNotification
                                               object: self.nameTextField];
    
    self.nameTextField.delegate = self;
    
}

#pragma mark - Actions

- (void)routineNameDidChange{
    
    [self.masterController routineNameDidUpdate: self.nameTextField.text];
    
}

- (void)dismissKeyboard{
    
    [self.nameTextField resignFirstResponder];
    
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [self dismissKeyboard];
    
    return YES;
    
}

- (BOOL)textFieldShouldClear:(UITextField *)textField{
    
    return YES;
    
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField{
    
    return YES;
    
}

#pragma mark - Deallocation

- (void)dealloc{
    
    // not sure it this is completely necessary but likely isn't the worst practice
    
    [[NSNotificationCenter defaultCenter] removeObserver: self
                                                    name: UITextFieldTextDidChangeNotification
                                                  object: self.nameTextField];
    
}

@end
















