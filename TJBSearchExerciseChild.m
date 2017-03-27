//
//  TJBSearchExerciseChild.m
//  Beast
//
//  Created by Trevor Beasty on 3/26/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBSearchExerciseChild.h"

@interface TJBSearchExerciseChild ()

// IBOutlet

@property (weak, nonatomic) IBOutlet UIButton *listButton;
@property (weak, nonatomic) IBOutlet UITextField *searchTextField;

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
    
}

- (void)configureSearchTextField{
    
    [self.searchTextField addTarget: self
                             action: @selector(searchTextFieldValueDidChange)
                   forControlEvents: UIControlEventValueChanged];
    
}

#pragma mark - Button Actions

- (IBAction)didPressListButton:(id)sender{
    
    self.listButtonCallback();
    
}

#pragma mark - Search Text Field

- (void)searchTextFieldValueDidChange{
    
    self.searchTFCallback(self.searchTextField.text);
    
}





@end
















