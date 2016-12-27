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

#import "TJBAestheticsController.h"

@interface TJBNewExerciseCreationVC () <UITextFieldDelegate>

// exercise text field and segmented control
//@property (nonatomic, strong) TJBExerciseCategory *exerciseCategory;
@property (weak, nonatomic) IBOutlet UITextField *exerciseTextField;

@property (weak, nonatomic) IBOutlet UISegmentedControl *categorySegmentedControl;

// navigation bar
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

// labels
@property (weak, nonatomic) IBOutlet UILabel *exerciseLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;

@end

@implementation TJBNewExerciseCreationVC

#pragma mark - Instantiation

- (void)viewDidLoad{    
    [self configureNavigationBar];
    [self viewAesthetics];
    [self configureBackgroundImage];
}

- (void)configureNavigationBar{
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle: @"Add New Exercise"];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemDone
                                                                                  target: self
                                                                                  action: @selector(didPressDone)];
    [navItem setLeftBarButtonItem: cancelButton];
    UIBarButtonItem *addButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemAdd
                                                                               target: self
                                                                               action: @selector(didPressAdd)];
    [navItem setRightBarButtonItem: addButton];
    [self.navigationBar setItems: @[navItem]];
}

- (void)viewAesthetics{
    // exercise text field and category SC
    CALayer *exerciseTextFieldLayer = self.exerciseTextField.layer;
    CALayer *categorySC = self.categorySegmentedControl.layer;
    NSArray *layers = @[exerciseTextFieldLayer,
                        categorySC];
    
    for (CALayer *layer in layers){
        layer.masksToBounds = YES;
        layer.cornerRadius = 10;
        layer.borderWidth = 1;
        layer.borderColor = [[UIColor blackColor] CGColor];
    }

    // labels
    NSArray *labeLayers = @[self.exerciseLabel.layer,
                        self.categoryLabel.layer];
    for (CALayer *layer in labeLayers){
        layer.masksToBounds = YES;
        layer.cornerRadius = 10;
        
    }
}

- (void)configureBackgroundImage{
    UIImage *image = [UIImage imageNamed: @"chinaCleanAndJerk"];
    [[TJBAestheticsController singleton] addFullScreenBackgroundViewWithImage: image
                                                                   toRootView: self.view];
}

#pragma mark - Button Actions

- (void)didPressAdd{
    NSString *exerciseString = self.exerciseTextField.text;
    UIAlertAction *continueAction = [UIAlertAction actionWithTitle: @"Continue"
                                                             style: UIAlertActionStyleDefault
                                                           handler: nil];
    
    BOOL exerciseExists = [[CoreDataController singleton] realizedSetExerciseExistsForName: exerciseString];
    if (exerciseExists){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"Invalid Entry"
                                                                       message: @"This exercise already exists"
                                                                preferredStyle: UIAlertControllerStyleAlert];
        [alert addAction: continueAction];
        [self presentViewController: alert
                           animated: YES
                         completion: nil];
    } else if([exerciseString isEqualToString: @""]){
        UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"Invalid Entry"
                                                                       message: @"Exercise entry is blank"
                                                                preferredStyle: UIAlertControllerStyleAlert];
        [alert addAction: continueAction];
        [self presentViewController: alert
                           animated: YES
                         completion: nil];
    } else{
        NSString *alertMessage = [NSString stringWithFormat: @"Add exercise '%@' for '%@' category?",
                                  exerciseString,
                                  [self selectedCategory]];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"New Exercise Confirmation"
                                                                       message: alertMessage
                                                                preferredStyle: UIAlertControllerStyleAlert];
        
        void (^yesBlock)(UIAlertAction *) = ^(UIAlertAction *action){
            __weak TJBNewExerciseCreationVC *weakSelf = self;
            [weakSelf addNewExerciseAndClearExerciseTextField];
        };
        
        UIAlertAction *yesAction = [UIAlertAction actionWithTitle: @"Yes"
                                                            style: UIAlertActionStyleDefault
                                                          handler: yesBlock];
        UIAlertAction *noAction = [UIAlertAction actionWithTitle: @"No"
                                                           style: UIAlertActionStyleDefault
                                                         handler: nil];
        
        [alert addAction: noAction];
        [alert addAction: yesAction];
        
        [self presentViewController: alert
                           animated: YES
                         completion: nil];
    }
}

- (void)addNewExerciseAndClearExerciseTextField{
    CoreDataController *coreDataController = [CoreDataController singleton];
    TJBExercise *newExercise = [coreDataController exerciseForName: self.exerciseTextField.text];
    newExercise.category = [[CoreDataController singleton] exerciseCategoryForName: [self selectedCategory]];
    
    [[CoreDataController singleton] saveContext];
    
    self.exerciseTextField.text = @"";
}

- (void)didPressDone{
    [self dismissViewControllerAnimated: YES
                             completion: nil];
}

#pragma  mark - Convenience

- (NSString *)selectedCategory{
    NSString *selectedCategory;
    NSInteger categoryIndex = self.categorySegmentedControl.selectedSegmentIndex;
    switch (categoryIndex){
        case 0:
            selectedCategory = @"Push";
            break;
        case 1:
            selectedCategory = @"Pull";
            break;
        case 2:
            selectedCategory = @"Legs";
            break;
        case 3:
            selectedCategory = @"Other";
            break;
        default:
            break;
    }
    return selectedCategory;
}

@end


















