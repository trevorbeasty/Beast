//
//  ExerciseAdditionChildVC.m
//  Beast
//
//  Created by Trevor Beasty on 4/30/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "ExerciseAdditionChildVC.h"

#import "TJBAestheticsController.h" // aesthetics

@interface ExerciseAdditionChildVC ()

// IBOutlet

@property (weak, nonatomic) IBOutlet UIView *contentContainer;
@property (weak, nonatomic) IBOutlet UILabel *exerciseLabel;
@property (weak, nonatomic) IBOutlet UITextField *exerciseTextField;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *categorySegmentedControl;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *addButton;


// IBAction

- (IBAction)didPressCancel:(id)sender;
- (IBAction)didPressAdd:(id)sender;




@end

@implementation ExerciseAdditionChildVC






#pragma mark - View Life Cycle

- (void)viewDidLoad{
    
    [self.view layoutIfNeeded];
    
    [self configureViewAesthetics];
    
}


#pragma mark - View Helper Methods


- (void)configureViewAesthetics{
    
    // meta views
    
    self.view.backgroundColor = [UIColor clearColor];
    self.contentContainer.backgroundColor = [UIColor clearColor];
    
    CALayer *contentContainerLayer = self.contentContainer.layer;
    contentContainerLayer.masksToBounds = YES;
    contentContainerLayer.cornerRadius = 8.0;
    
    // content labels
    
    NSArray *contentLabels = @[self.exerciseLabel, self.categoryLabel];
    for (UILabel *label in contentLabels){
        
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize: 20];
        label.textColor = [UIColor whiteColor];
        
    }
    
    // buttons
    
    NSArray *buttons = @[self.cancelButton, self.addButton];
    for (UIButton *button in buttons){
        
        
        button.backgroundColor = [UIColor clearColor];
        [button setTitleColor: [[TJBAestheticsController singleton] paleLightBlueColor]
                     forState: UIControlStateNormal];
        button.titleLabel.font = [UIFont boldSystemFontOfSize: 20];
        
        CALayer *buttLayer = button.layer;
        buttLayer.masksToBounds = YES;
        buttLayer.cornerRadius = button.frame.size.height / 2.0;
        buttLayer.borderWidth = 1.0;
        buttLayer.borderColor = [[TJBAestheticsController singleton] paleLightBlueColor].CGColor;
        
        
    }
    
    // segmented control
    
    self.categorySegmentedControl.backgroundColor = [UIColor grayColor];
    self.categorySegmentedControl.tintColor = [[TJBAestheticsController singleton] paleLightBlueColor];
    
    UIFont *font = [UIFont boldSystemFontOfSize: 15];
    NSDictionary *attributes = [NSDictionary dictionaryWithObject: font
                                                           forKey: NSFontAttributeName];
    [self.categorySegmentedControl setTitleTextAttributes: attributes
                                                 forState: UIControlStateNormal];
    
    CALayer *scLayer = self.categorySegmentedControl.layer;
    scLayer.masksToBounds = YES;
    scLayer.cornerRadius = self.categorySegmentedControl.frame.size.height / 2.0;
    scLayer.borderWidth = 1.0;
    scLayer.borderColor = [[TJBAestheticsController singleton] paleLightBlueColor].CGColor;
    
    // text field
    
    self.exerciseTextField.backgroundColor = [UIColor grayColor];
    self.exerciseTextField.font = [UIFont systemFontOfSize: 15];
    self.exerciseTextField.textColor = [UIColor whiteColor];
    self.exerciseTextField.textAlignment = NSTextAlignmentCenter;
    
    CALayer *textFieldLayer = self.exerciseTextField.layer;
    textFieldLayer.masksToBounds = YES;
    textFieldLayer.cornerRadius = self.exerciseTextField.frame.size.height / 2.0;
    textFieldLayer.borderWidth = 1.0;
    textFieldLayer.borderColor = [[TJBAestheticsController singleton] paleLightBlueColor].CGColor;
    
    
}



#pragma mark - Button Actions

- (IBAction)didPressCancel:(id)sender {
}

- (IBAction)didPressAdd:(id)sender {
}







@end

























