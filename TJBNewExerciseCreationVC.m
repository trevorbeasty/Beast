//
//  TJBNewExerciseCreationVC.m
//  Beast
//
//  Created by Trevor Beasty on 12/9/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import "TJBNewExerciseCreationVC.h"



@interface TJBNewExerciseCreationVC () <UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource>

// core IV's



@end

@implementation TJBNewExerciseCreationVC

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

@end


















