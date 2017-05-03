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

{
    
    // core
    
    TJBExerciseCategoryType _initialExerciseCategory;
    
}

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

// core

@property (copy) NewExerciseCallback exerciseAddedCallback;
@property (copy) CancelCallback cancelCallback;




@end


@implementation ExerciseAdditionChildVC

#pragma mark - Instantiation

- (instancetype)initWithSelectedCategory:(TJBExerciseCategoryType)categoryType exerciseAddedCallback:(NewExerciseCallback)eaCallback cancelCallback:(CancelCallback)cCallback{
    
    self = [super init];
    
    _initialExerciseCategory = categoryType;
    self.exerciseAddedCallback = eaCallback;
    self.cancelCallback = cCallback;
    
    return self;

    
}




#pragma mark - View Life Cycle

- (void)viewDidLoad{
    
    [super viewDidLoad];
    
    [self.view layoutIfNeeded];
    
    [self configureViewAesthetics];
    
    [self configureViewInitialDisplay];
    
    
    
}


#pragma mark - View Helper Methods

- (void)configureViewInitialDisplay{
    
    self.categorySegmentedControl.selectedSegmentIndex = [self scIndexForCategory: _initialExerciseCategory];
    
}


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
    self.exerciseTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    self.exerciseTextField.clearButtonMode = UITextFieldViewModeAlways;
    
    CALayer *textFieldLayer = self.exerciseTextField.layer;
    textFieldLayer.masksToBounds = YES;
    textFieldLayer.cornerRadius = self.exerciseTextField.frame.size.height / 2.0;
    textFieldLayer.borderWidth = 1.0;
    textFieldLayer.borderColor = [[TJBAestheticsController singleton] paleLightBlueColor].CGColor;
    
    
}



#pragma mark - Button Actions

- (IBAction)didPressCancel:(id)sender{
    
    self.cancelCallback();
    
}

- (IBAction)didPressAdd:(id)sender{
    
    BOOL exerciseNameIsDuplicate = [[CoreDataController singleton] exerciseExistsForName: self.exerciseTextField.text];
    BOOL exerciseTextFieldIsBlank = [self.exerciseTextField.text isEqualToString: @""];
    TJBExercise *delistedExercise = [[CoreDataController singleton] delistedExerciseForName: self.exerciseTextField.text];
    
    if (delistedExercise){
        
        delistedExercise.showInExerciseList = YES;
    
        TJBExerciseCategory *selectedCategory = [[CoreDataController singleton] exerciseCategory: [self exerciseCategoryForSCSelectedIndex]];
        delistedExercise.category = selectedCategory;
        
        [[CoreDataController singleton] saveContext];
        
        self.exerciseAddedCallback(delistedExercise);
        
    } else if (exerciseNameIsDuplicate || exerciseTextFieldIsBlank){
        
        NSString *alertMessage = exerciseNameIsDuplicate ? @"An exercise with this name already exists" : @"Please enter a name for the new exercise";
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"Error"
                                                                       message: alertMessage
                                                                preferredStyle: UIAlertControllerStyleAlert];
        
        UIAlertAction *action = [UIAlertAction actionWithTitle: @"Continue"
                                                         style: UIAlertActionStyleDefault
                                                       handler: nil];
        [alert addAction: action];
        
        [self presentViewController: alert
                           animated: YES
                         completion: nil];
        
    } else{
        
        TJBExercise *newExercise = [NSEntityDescription insertNewObjectForEntityForName: @"Exercise"
                                                                 inManagedObjectContext: [[CoreDataController singleton] moc]];
        
        TJBExerciseCategory *selectedCategory = [[CoreDataController singleton] exerciseCategory: [self exerciseCategoryForSCSelectedIndex]];
        newExercise.category = selectedCategory;
        
        newExercise.isPlaceholderExercise = NO;
        newExercise.showInExerciseList = YES;
        newExercise.name = self.exerciseTextField.text;
        
        [[CoreDataController singleton] saveContext];
        
        self.exerciseAddedCallback(newExercise);
        
    }
    
    
}


#pragma mark - Segmented Control

- (TJBExerciseCategoryType)exerciseCategoryForSCSelectedIndex{
    
    TJBExerciseCategoryType categoryType;
    
    switch (self.categorySegmentedControl.selectedSegmentIndex) {
        case 0:
            categoryType = PushType;
            break;
            
        case 1:
            categoryType = PullType;
            break;
            
        case 2:
            categoryType = LegsType;
            break;
            
        case 3:
            categoryType = OtherType;
            break;
            
        default:
            break;
    }
    
    return categoryType;
    
}

- (NSInteger)scIndexForCategory:(TJBExerciseCategoryType)categoryType{
    
    NSInteger selectedIndex;
    
    switch (categoryType) {
        case PushType:
            selectedIndex = 0;
            break;
            
        case PullType:
            selectedIndex = 1;
            break;
            
        case LegsType:
            selectedIndex = 2;
            break;
            
        case OtherType:
            selectedIndex = 3;
            break;
            
        default:
            break;
    }
    
    return selectedIndex;
    
}

#pragma mark - Refresh

- (void)refreshWithSelectedExerciseCategory:(TJBExerciseCategoryType)ect{
    
    _initialExerciseCategory = ect;
    self.categorySegmentedControl.selectedSegmentIndex = [self scIndexForCategory: ect];
    
    self.exerciseTextField.text = @"";
    
}

#pragma mark - Keyboard

- (void)makeTextFieldBecomeFirstResponder{
    
    [self.exerciseTextField becomeFirstResponder];
    
}

- (void)makeTextFieldResignFirstResponder{
    
    [self.exerciseTextField resignFirstResponder];
    
}


@end

























