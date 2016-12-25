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

// navigation bar

@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (nonatomic, strong) UINavigationItem *navItem;

//

@end

@implementation TJBNewExerciseCreationVC

#pragma mark - Instantiation

- (void)viewDidLoad{
    // navigation bar
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle: @"New Exercise"];

    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCancel
                                                                                  target: self
                                                                                  action: @selector(cancel)];
    [navItem setLeftBarButtonItem: cancelButton];
    
    [self.navigationBar setItems: @[navItem]];
    self.navItem = navItem;
    
    // idiosyncratic initialization
    
    self.exerciseCategory = [[CoreDataController singleton] exerciseCategoryForName: @"Push"];
    
    // timer
    
    self.timerLabel.text = [[TJBStopwatch singleton] primaryTimeElapsedAsString];
    
    [[TJBStopwatch singleton] addPrimaryStopwatchObserver: self.timerLabel];
    
    [self viewAesthetics];
}

- (void)viewAesthetics{
    CALayer *layer = self.exerciseTextField.layer;
    layer.masksToBounds = YES;
    layer.cornerRadius = 8;
    layer.borderWidth = 1;
    layer.borderColor = [[UIColor blueColor] CGColor];
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

    BOOL exerciseExists = [[CoreDataController singleton] realizedSetExerciseExistsForName: exerciseString];
    
    if ([exerciseString isEqualToString: @""] || exerciseExists || !self.exerciseCategory)
    {
        return;
    }
    else
    {
        TJBExercise *newExercise = [[CoreDataController singleton] exerciseForName: exerciseString];
    
        newExercise.category = self.exerciseCategory;
                
        [[CoreDataController singleton] saveContext];
                
        [self.associateVC didCreateNewExercise: newExercise];
    }
}

- (void)cancel
{
    [self.associateVC dismissViewControllerAnimated: YES
                                         completion: nil];
}



@end


















