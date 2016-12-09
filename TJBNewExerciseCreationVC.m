//
//  TJBNewExerciseCreationVC.m
//  Beast
//
//  Created by Trevor Beasty on 12/9/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import "TJBNewExerciseCreationVC.h"

#import "CoreDataController.h"

#import "TJBStopwatch.h"

@interface TJBNewExerciseCreationVC () <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

// core IV's

@property (nonatomic, strong) TJBExerciseCategory *exerciseCategory;

@property (weak, nonatomic) IBOutlet UITextField *exerciseTextField;

- (IBAction)addNewExercise:(id)sender;

// timer

@property (weak, nonatomic) IBOutlet UILabel *timerLabel;

@end

@implementation TJBNewExerciseCreationVC

- (void)viewDidLoad
{
    self.exerciseCategory = [[CoreDataController singleton] exerciseCategoryForName: @"Push"];
    
    // timer
    
    self.timerLabel.text = [[[TJBStopwatch singleton] timeElapsedInSeconds] stringValue];
    
    [[TJBStopwatch singleton] addStopwatchObserver: self.timerLabel];
}

#pragma mark - <UITextFieldDelegate>



#pragma mark - <UIPickerViewDelegate>

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if (component == 0)
    {
        if (row == 0)
            return @"Push";
        if (row == 1)
            return @"Pull";
        if (row == 2)
            return @"Legs";
        if (row == 3)
            return @"Other";
    }
    
    NSLog(@"picker view not behaving as expected");
    return @"";
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSString *categoryString = nil;
    
    if (component == 0)
    {
        if (row == 0)
            categoryString = @"Push";
        if (row == 1)
            categoryString = @"Pull";
        if (row == 2)
            categoryString = @"Legs";
        if (row == 3)
            categoryString = @"Other";
    }
    
    if (!categoryString)
        abort();
    
    NSLog(@"categoryString: %@", categoryString);
    
    TJBExerciseCategory *category = [[CoreDataController singleton] exerciseCategoryForName: categoryString];
    
    self.exerciseCategory = category;
}

- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return 50.0;
}

#pragma mark - <UIPickerViewDataSource>

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 4;
}

#pragma mark - Button Actions

- (IBAction)addNewExercise:(id)sender
{
    NSString *exerciseString = self.exerciseTextField.text;
    
    BOOL exerciseExists = [[CoreDataController singleton] exerciseExistsForName: exerciseString];
    
    if ([exerciseString isEqualToString: @""])
    {
        NSLog(@"\nPlease enter a new exercise\n");
        return;
    }
    else
    {
        if (exerciseExists)
        {
            NSLog(@"\nThis exercise already exists\n");
            return;
        }
        else
        {
            TJBExercise *newExercise = [[CoreDataController singleton] exerciseForName: exerciseString];
            
            if (self.exerciseCategory)
            {
                newExercise.category = self.exerciseCategory;
                
                [[CoreDataController singleton] saveContext];
                
                [self.associateVC didCreateNewExercise: newExercise];
            }
            else
            {
                NSLog(@"Please select a category");
                return;
            }
        }
    }
}
@end


















