//
//  TJBExerciseSelectionTutorial.m
//  Beast
//
//  Created by Trevor Beasty on 5/4/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBExerciseSelectionTutorial.h"

#import "TJBAssortedUtilities.h" // utilities

@interface TJBExerciseSelectionTutorial ()

#pragma mark - IBOutlet

#pragma mark - Core IV's

{
    
    TJBTutorialType _tutorialType;
    
}

@property (copy) CancelCallbackBlock cancelCallback;

// images

@property (weak, nonatomic) IBOutlet UIImageView *image1;
@property (weak, nonatomic) IBOutlet UIImageView *image2;
@property (weak, nonatomic) IBOutlet UIImageView *image3;
@property (weak, nonatomic) IBOutlet UIImageView *image4;
@property (weak, nonatomic) IBOutlet UIImageView *image5;

// text labels

@property (weak, nonatomic) IBOutlet UILabel *label1;
@property (weak, nonatomic) IBOutlet UILabel *label2;
@property (weak, nonatomic) IBOutlet UILabel *label3;
@property (weak, nonatomic) IBOutlet UILabel *label4;
@property (weak, nonatomic) IBOutlet UILabel *label5;
@property (weak, nonatomic) IBOutlet UILabel *tutorialTitleLabel;

// exit button

@property (weak, nonatomic) IBOutlet UIButton *exitButton;
- (IBAction)didPressExitButton:(id)sender;







@end

@implementation TJBExerciseSelectionTutorial


#pragma mark - Instantiation

- (instancetype)initWithCancelCallback:(CancelCallbackBlock)cancelCallback tutorialType:(TJBTutorialType)tutorialType{
    
    self = [super init];
    
    if (self){
        
        self.cancelCallback = cancelCallback;
        _tutorialType = tutorialType;
        
    }
    
    return self;
    
}


#pragma mark - View Life Cycle

- (void)viewDidLoad{
    
    [super viewDidLoad];
    
    [self configureViewAesthetics];
    
    [self configureDisplayContentBasedOnType];
    
    [self drawDetailedLines];
    
}


#pragma mark - View Helper Methods

- (void)drawDetailedLines{
    
    [self.view layoutIfNeeded];
    
    [TJBAssortedUtilities addHorizontalBorderBeneath: self.tutorialTitleLabel
                                           thickness: 2
                                     widthAdjustment: 32
                                      verticalOffset: 0
                                            metaView: self.view
                                           lineColor: [UIColor whiteColor]];
    [TJBAssortedUtilities addHorizontalBorderBeneath: self.tutorialTitleLabel
                                           thickness: 2
                                     widthAdjustment: 16
                                      verticalOffset: 4
                                            metaView: self.view
                                           lineColor: [UIColor whiteColor]];
    
    
    
}

- (void)configureDisplayContentBasedOnType{
    
    if (_tutorialType == TJBWorkoutLogTutorial){
        
        [self.image2 setImage: [UIImage imageNamed: @"lastBlue30PDF"]];
        [self.image3 setImage: [UIImage imageNamed: @"todayBlue30PDF"]];
   
        self.label1.text = @"Launch into active lifting mode for the highlighted entry";
        self.label2.text = @"Jump to the previously selected day";
        self.label3.text = @"Jump to today";
        self.label4.text = @"Delete the highlighted entry";
        self.label5.text = @"Make corrections to the highlighted entry";
        
        
    } else if (_tutorialType == TJBRoutineSelectionTutorial){
        
        [self.image2 setImage: [UIImage imageNamed: @"historyBlue30PDF"]];
        [self.image3 setImage: [UIImage imageNamed: @"garbageBlue30PDF"]];
        [self.image4 setImage: [UIImage imageNamed: @"addBlue30PDF"]];
        self.image5.hidden = YES;
        
        self.label1.text = @"Launch the highlighted routine";
        self.label2.text = @"View the entire routine history for the highlighted routine";
        self.label3.text = @"Delete the highlighted routine";
        self.label4.text = @"Create a new routine";
        self.label5.hidden = YES;
        
    }
    
}


- (void)configureViewAesthetics{
    
    // meta view
    
    self.view.backgroundColor = [UIColor clearColor];
    
    
    // detail labels
    
    NSArray *labels = @[self.label1, self.label2, self.label3, self.label4, self.label5];
    for (UILabel *lab in labels){
        
        lab.backgroundColor = [UIColor clearColor];
        lab.textColor = [UIColor whiteColor];
        lab.font = [UIFont boldSystemFontOfSize: 15];
        
    }
    
    // title label
    
    self.tutorialTitleLabel.font = [UIFont boldSystemFontOfSize: 25];
    self.tutorialTitleLabel.backgroundColor = [UIColor clearColor];
    self.tutorialTitleLabel.textColor = [UIColor whiteColor];
    
}

#pragma mark - Exit Button

- (IBAction)didPressExitButton:(id)sender{
    
    self.cancelCallback();
    
}



@end






















