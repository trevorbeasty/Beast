//
//  TJBExerciseSelectionTutorial.m
//  Beast
//
//  Created by Trevor Beasty on 5/4/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBExerciseSelectionTutorial.h"

@interface TJBExerciseSelectionTutorial ()

#pragma mark - IBOutlet

#pragma mark - Core IV's

{
    
    TJBTutorialType _tutorialType;
    
}

@property (copy) CancelCallbackBlock cancelCallback;

// images

@property (weak, nonatomic) IBOutlet UIImageView *liftImage;
@property (weak, nonatomic) IBOutlet UIImageView *searchImage;
@property (weak, nonatomic) IBOutlet UIImageView *addNewImage;
@property (weak, nonatomic) IBOutlet UIImageView *deleteImage;
@property (weak, nonatomic) IBOutlet UIImageView *editImage;

// text labels

@property (weak, nonatomic) IBOutlet UILabel *liftLabel;
@property (weak, nonatomic) IBOutlet UILabel *searchLabel;
@property (weak, nonatomic) IBOutlet UILabel *addNewLabel;
@property (weak, nonatomic) IBOutlet UILabel *deleteLabel;
@property (weak, nonatomic) IBOutlet UILabel *editLabel;

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
    
}


#pragma mark - View Helper Methods


- (void)configureViewAesthetics{
    
    // meta view
    
    self.view.backgroundColor = [UIColor clearColor];
    
    // images
    
    NSArray *images = @[self.liftImage, self.searchImage, self.addNewImage, self.deleteImage, self.editImage];
    for (UIImage *ima in images){
        
        
        
        
        
    }
    
    
    // labels
    
    NSArray *labels = @[self.liftLabel, self.searchLabel, self.addNewLabel, self.deleteLabel, self.editLabel];
    for (UILabel *lab in labels){
        
        lab.backgroundColor = [UIColor clearColor];
        lab.textColor = [UIColor whiteColor];
        lab.font = [UIFont boldSystemFontOfSize: 15];
        
    }
    
    
    
}

#pragma mark - Exit Button

- (IBAction)didPressExitButton:(id)sender{
    
    self.cancelCallback();
    
}
@end






















