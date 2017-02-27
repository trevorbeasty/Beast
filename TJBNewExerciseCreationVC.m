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

// IBOutlets

@property (weak, nonatomic) IBOutlet UITextField *exerciseTextField;
@property (weak, nonatomic) IBOutlet UISegmentedControl *categorySegmentedControl;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;
@property (weak, nonatomic) IBOutlet UILabel *exerciseLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryLabel;

@end

@implementation TJBNewExerciseCreationVC

#pragma mark - Instantiation

- (void)viewDidLoad{
    
    [self configureNavigationBar];
    
    [self viewAesthetics];
    
    [self configureBackgroundImage];
    
    [self addTapGestureRecognizerToViewAndRegisterForKeyboardNotification];
    
}

- (void)addTapGestureRecognizerToViewAndRegisterForKeyboardNotification{
    
    //// add gesture recognizer to the view.  It will be used to dismiss the keyboard if the touch is not in the keyboard or text field
    //// also register for the UIKeyboardDidShowNotification so that the frame of the keyboard can be stored for later use in analyzing touches
    
    // tap GR
    
    UITapGestureRecognizer *singleTapGR = [[UITapGestureRecognizer alloc] initWithTarget: self
                                                                                  action: @selector(didSingleTap:)];
    
    singleTapGR.numberOfTapsRequired = 1;
    singleTapGR.cancelsTouchesInView = NO;
    singleTapGR.delaysTouchesBegan = NO;
    singleTapGR.delaysTouchesEnded = NO;
    
    [self.view addGestureRecognizer: singleTapGR];

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
    
    [self.navigationBar setTitleTextAttributes: @{NSFontAttributeName: [UIFont boldSystemFontOfSize: 20.0]}];
    
}

- (void)viewAesthetics{
    
    // exercise text field and category SC
    
    CALayer *exerciseTextFieldLayer = self.exerciseTextField.layer;
    
    self.categorySegmentedControl.tintColor = [[TJBAestheticsController singleton] blueButtonColor];
    
    NSArray *layers = @[exerciseTextFieldLayer];
    
    for (CALayer *layer in layers){
        
        layer.masksToBounds = YES;
        layer.cornerRadius = 10;
        layer.borderWidth = 1;
        layer.borderColor = [[UIColor darkGrayColor] CGColor];
        
    }
    
    UIFont *categorySelectionFont = [UIFont systemFontOfSize: 20.0];
    
    NSDictionary *info = [NSDictionary dictionaryWithObject: categorySelectionFont
                                                     forKey: NSFontAttributeName];
    
    [self.categorySegmentedControl setTitleTextAttributes: info
                                                 forState: UIControlStateNormal];
    
    // text field
    
    self.exerciseTextField.autocapitalizationType = UITextAutocapitalizationTypeWords;
    
}

- (void)configureBackgroundImage{
    
    UIImage *image = [UIImage imageNamed: @"chinaCleanAndJerk"];
    
    [[TJBAestheticsController singleton] addFullScreenBackgroundViewWithImage: image
                                                                   toRootView: self.view];
    
}

#pragma mark - Button Actions

- (void)didPressAdd{
    
    //// action is dependent upon several factors.  Depends on whether user it trying to create an existing exercise, has left the exercise text field blank, or has entered a valid new exercise name
    
    // conditional actions
    
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
    
    //// add the new exercise leverage CoreDataController methods.  Save the context when done
    
    CoreDataController *coreDataController = [CoreDataController singleton];
    
    NSString *newExerciseName = self.exerciseTextField.text;
    
    NSNumber *wasNewlyCreated = nil;
    TJBExercise *newExercise = [coreDataController exerciseForName: newExerciseName
                                                   wasNewlyCreated: &wasNewlyCreated
                                       createAsPlaceholderExercise: [NSNumber numberWithBool: NO]];
    
    newExercise.category = [[CoreDataController singleton] exerciseCategoryForName: [self selectedCategory]];
    
    [[CoreDataController singleton] saveContext];
    
    // need to use notification center so all affected fetched results controllers can perform fetch and update table views
    
    [[NSNotificationCenter defaultCenter] postNotificationName: ExerciseDataChanged
                                                        object: nil];
    
    // clear the exercise text field
    
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

#pragma mark - Gesture Recognizer

- (void)didSingleTap:(UIGestureRecognizer *)gr{

    //// because this gesture does not register if the touch is in the keyboard or text field, simply have to check if the keyboard is showing, and dismiss it if so

    if ([self.exerciseTextField isFirstResponder]){
        
        [self.exerciseTextField resignFirstResponder];
        
    }
    

}

#pragma mark - <UITextFieldDelegate>

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    
    [self.exerciseTextField resignFirstResponder];
    
    return YES;
    
}

@end




































