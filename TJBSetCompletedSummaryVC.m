//
//  TJBSetCompletedSummaryVC.m
//  Beast
//
//  Created by Trevor Beasty on 2/28/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBSetCompletedSummaryVC.h"

// aesthetics

#import "TJBAestheticsController.h"

@interface TJBSetCompletedSummaryVC ()

// IBOutlet

@property (weak, nonatomic) IBOutlet UIView *contentContainerView;
@property (weak, nonatomic) IBOutlet UILabel *exerciseLabel;
@property (weak, nonatomic) IBOutlet UILabel *weightLabel;
@property (weak, nonatomic) IBOutlet UILabel *repsLabel;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIButton *editButton;
@property (weak, nonatomic) IBOutlet UIButton *confirmButton;

// IBAction

- (IBAction)didPressCancel:(id)sender;
- (IBAction)didPressEdit:(id)sender;
- (IBAction)didPressConfirm:(id)sender;


// core

@property (strong) NSString *exerciseName;
@property (strong) NSNumber *weight;
@property (strong) NSNumber *reps;
@property (strong) TJBVoidCallback cancelCallback;
@property (strong) TJBVoidCallback editCallback;
@property (strong) TJBVoidCallback confirmCallback;

@end

@implementation TJBSetCompletedSummaryVC

#pragma mark - Instantiation

- (instancetype)initWithExerciseName:(NSString *)exerciseName weight:(NSNumber *)weight reps:(NSNumber *)reps cancelCallback:(TJBVoidCallback)cancelCallback editCallback:(TJBVoidCallback)editCallback confirmCallback:(TJBVoidCallback)confirmCallback{
    
    self = [super init];
    
    self.exerciseName = exerciseName;
    self.weight = weight;
    self.reps = reps;
    self.cancelCallback = cancelCallback;
    self.editCallback = editCallback;
    self.confirmCallback = confirmCallback;
    
    return self;
    
}

#pragma mark - View Life Cycle

- (void)viewDidLoad{
    
    [self configureViewAesthetics];
    
    [self configureDisplay];
    
}

- (void)viewWillAppear:(BOOL)animated{
    
    [self configureVisualEffectView];
    
}

- (void)configureVisualEffectView{
    
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle: UIBlurEffectStyleDark];
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect: blur];
    
    visualEffectView.frame = self.view.bounds;
    
    [self.view addSubview: visualEffectView];
    
    [visualEffectView.contentView addSubview: self.contentContainerView];
    NSArray *buttons = @[self.cancelButton, self.editButton, self.confirmButton];
    for (UIButton *butt in buttons){
        
        [visualEffectView.contentView addSubview: butt];
        
    }
    
}

- (void)configureDisplay{
    
    self.exerciseLabel.text = self.exerciseName;
    
    NSString *weightText = [NSString stringWithFormat: @"%@ lbs", [self.weight stringValue]];
    NSString *repsText = [NSString stringWithFormat: @"%@ reps", [self.reps stringValue]];
    
    self.weightLabel.text = weightText;
    self.repsLabel.text = repsText;
    
}

- (void)configureViewAesthetics{
    
    self.view.backgroundColor = [UIColor clearColor];
    
    self.contentContainerView.backgroundColor = [UIColor blackColor];
    self.contentContainerView.layer.masksToBounds = YES;
    self.contentContainerView.layer.cornerRadius = 4;
    
    // detail labels
    
    NSArray *detailLabels = @[self.exerciseLabel, self.weightLabel, self.repsLabel];
    for (UILabel *lab in detailLabels){
        
        lab.backgroundColor = [[TJBAestheticsController singleton] yellowNotebookColor];
        lab.textColor = [UIColor blackColor];
        lab.font = [UIFont boldSystemFontOfSize: 20];
        
    }
    
    // buttons
    
    NSArray *buttons = @[self.cancelButton, self.editButton, self.confirmButton];
    for (UIButton *b in buttons){
        
        b.backgroundColor = [UIColor clearColor];
        [b setTitleColor: [[TJBAestheticsController singleton] paleLightBlueColor]
                forState: UIControlStateNormal];
        b.titleLabel.font = [UIFont systemFontOfSize: 20];
        
        CALayer *buttLayer = b.layer;
        buttLayer.borderWidth = 2.0;
        buttLayer.borderColor = [[TJBAestheticsController singleton] paleLightBlueColor].CGColor;
        buttLayer.masksToBounds = YES;
        buttLayer.cornerRadius = 25;
        
    }
    
}

#pragma mark - Button Actions

- (IBAction)didPressCancel:(id)sender{
    
    self.cancelCallback();
    
}

- (IBAction)didPressEdit:(id)sender{
    
    self.editCallback();
    
}

- (IBAction)didPressConfirm:(id)sender{
    
    self.confirmCallback();
    
}

@end




































