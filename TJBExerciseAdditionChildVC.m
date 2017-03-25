//
//  TJBExerciseAdditionChildVC.m
//  Beast
//
//  Created by Trevor Beasty on 3/24/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBExerciseAdditionChildVC.h"

// aesthetics

#import "TJBAestheticsController.h"

@interface TJBExerciseAdditionChildVC ()

// IBOutlets

@property (weak, nonatomic) IBOutlet UILabel *exerciseNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *exerciseCategoryLabel;
@property (weak, nonatomic) IBOutlet UITextField *exerciseNameTF;
@property (weak, nonatomic) IBOutlet UISegmentedControl *exerciseCategorySC;

@property (weak, nonatomic) IBOutlet UIButton *addButton;
@property (weak, nonatomic) IBOutlet UIButton *addAndSelectButton;
@property (weak, nonatomic) IBOutlet UIButton *listButton;


// IBAction

- (IBAction)didPressAdd:(id)sender;
- (IBAction)didPressAddAndSelect:(id)sender;
- (IBAction)didPressList:(id)sender;



// core

@property (copy) void (^eaCallback)(NSString *, NSNumber *, BOOL);
@property (copy) void (^lCallback)(void);

@end

@implementation TJBExerciseAdditionChildVC

#pragma mark Instantiation

- (instancetype)initWithExerciseAdditionCallback:(void (^)(NSString *, NSNumber *, BOOL))eaCallback listCallback:(void (^)(void))lCallback{
    
    self = [super init];
    
    self.eaCallback = eaCallback;
    self.lCallback = lCallback;
    
    return self;
    
}

#pragma mark - View Life Cycle

- (void)viewDidLoad{
    
    [self configureViewAesthetics];
    
//    [self configureSegmentedControl];
    
}

#pragma mark - Supp View Methods

//- (void)configureSegmentedControl{
//    
//    
//    
//}

- (void)configureViewAesthetics{
    
    // meta view
    
    self.view.backgroundColor = [UIColor clearColor];
    
    // labels
    
    NSArray *labels = @[self.exerciseNameLabel, self.exerciseCategoryLabel];
    for (UILabel *lab in labels){
        
        lab.backgroundColor = [UIColor clearColor];
        lab.font = [UIFont boldSystemFontOfSize: 20];
        
        
    }
    
    // buttons
    
    NSArray *buttons = @[self.addButton, self.addAndSelectButton];
    for (UIButton *butt in buttons){
        
        butt.backgroundColor = [UIColor clearColor];
        butt.titleLabel.font = [UIFont systemFontOfSize: 20];
        [butt setTitleColor: [UIColor blackColor]
                   forState: UIControlStateNormal];
        
        CALayer *bLayer = butt.layer;
        bLayer.masksToBounds = YES;
        bLayer.cornerRadius = 15;
        bLayer.borderColor = [UIColor blackColor].CGColor;
        bLayer.borderWidth = 1.0;
        
    }
    
    self.listButton.backgroundColor = [UIColor clearColor];
    
    // sc
    
    self.exerciseCategorySC.tintColor = [UIColor blackColor];
    self.exerciseCategorySC.backgroundColor = [UIColor clearColor];
    
    // text field
    
    self.exerciseNameTF.backgroundColor = [UIColor clearColor];
    CALayer *tfLayer = self.exerciseNameTF.layer;
    tfLayer.borderColor = [UIColor blackColor].CGColor;
    tfLayer.borderWidth = 1.0;
    tfLayer.cornerRadius = 4.0;
    tfLayer.masksToBounds = YES;
    
}

#pragma mark - Segmented Control


#pragma mark - Button Actions

- (IBAction)didPressAdd:(id)sender{
    
    self.eaCallback(self.exerciseNameTF.text, @(self.exerciseCategorySC.selectedSegmentIndex), NO);
    
}

- (IBAction)didPressAddAndSelect:(id)sender{
    
    self.eaCallback(self.exerciseNameTF.text, @(self.exerciseCategorySC.selectedSegmentIndex), NO);
    
}

- (IBAction)didPressList:(id)sender{
    
    self.lCallback();
    
}

#pragma mark - API

- (void)makeExerciseTFFirstResponder{
    
    [self.exerciseNameTF becomeFirstResponder];
    
}

- (void)makeExerciseTFResignFirstResponder{
    
    [self.exerciseNameTF resignFirstResponder];
    
}



@end






