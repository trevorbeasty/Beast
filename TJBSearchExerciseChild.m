//
//  TJBSearchExerciseChild.m
//  Beast
//
//  Created by Trevor Beasty on 3/26/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBSearchExerciseChild.h"

// aesthetics

#import "TJBAestheticsController.h"

@interface TJBSearchExerciseChild ()

// IBOutlet

@property (weak, nonatomic) IBOutlet UIButton *listButton;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

// IBAction

- (IBAction)didPressListButton:(id)sender;

// core

@property (copy) void (^searchTFCallback)(NSString *);
@property (copy) void (^listButtonCallback)(void);

@end

@implementation TJBSearchExerciseChild

#pragma mark - Instantiation

- (instancetype)initWithListButtonCallback:(void (^)(void))lbCallback searchTextFieldCallback:(void (^)(NSString *))stfCallback{
    
    self = [super init];
    
    if (self){
        
        self.listButtonCallback = lbCallback;
        self.searchTFCallback = stfCallback;
        
    }
    
    return self;
    
}

#pragma mark - View Life Cycle

- (void)viewDidLoad{
    
    [self configureSearchTextField];
    
    [self configureViewAesthetics];
    
}

#pragma mark - View Helper Methods

- (void)configureSearchTextField{
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(searchTextFieldValueDidChange)
                                                 name: UITextFieldTextDidChangeNotification
                                               object: self.searchTextField];
    
}

- (void)configureViewAesthetics{
    
    // meta view
    
    self.view.backgroundColor = [[TJBAestheticsController singleton] yellowNotebookColor];
    
    // search text field
    
    self.searchTextField.backgroundColor = [UIColor clearColor];
    
    CALayer *stfLayer = self.searchTextField.layer;
    stfLayer.borderColor = [UIColor blackColor].CGColor;
    stfLayer.borderWidth = 1.0;
    stfLayer.masksToBounds = YES;
    stfLayer.cornerRadius = 8;
    
    // 'searching all exercises' label
    
    self.titleLabel.font = [UIFont boldSystemFontOfSize: 20];
    
}

#pragma mark - Button Actions

- (IBAction)didPressListButton:(id)sender{
    
    self.listButtonCallback();
    
}

#pragma mark - Search Text Field

- (void)searchTextFieldValueDidChange{
    
    self.searchTFCallback(self.searchTextField.text);
    
}

#pragma mark - API

- (void)makeSearchTextFieldFirstResponder{
    
    [self.searchTextField becomeFirstResponder];
    
}

- (void)makeSearchTextFieldResignFirstResponder{
    
    [self.searchTextField resignFirstResponder];
    
}

- (NSString *)searchTextFieldText{
    
    return self.searchTextField.text;
    
}



@end
















