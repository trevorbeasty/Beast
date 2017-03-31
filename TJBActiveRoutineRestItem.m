//
//  TJBActiveRoutineRestItem.m
//  Beast
//
//  Created by Trevor Beasty on 2/11/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBActiveRoutineRestItem.h"

// stopwatch

#import "TJBStopwatch.h"

// aesthetics

#import "TJBAestheticsController.h"

@interface TJBActiveRoutineRestItem ()

{
    
    BOOL _isCompletionButton;
    
}

// IBOutlet

@property (weak, nonatomic) IBOutlet UIButton *mainButton;

// IBAction

- (IBAction)didPressMainButton:(id)sender;



// core

@property (nonatomic, strong) NSNumber *number;
@property (nonatomic, strong) NSString *contentText;
@property (copy) void (^callback)(void);

@end

@implementation TJBActiveRoutineRestItem

#pragma mark - Instantiation

- (instancetype)initWithTitleNumber:(NSNumber *)titleNumber contentText:(NSString *)contentText isCompletionButton:(BOOL)isCompletionButton callback:(void (^)(void))callback{
    
    self = [super init];
    
    self.number = titleNumber;
    self.contentText = contentText;
    self.callback = callback;
    
    return self;
    
}

#pragma mark - View Life Cycle

- (void)viewDidLoad{
    
    self.view.backgroundColor = [UIColor clearColor];
    
    [self.mainButton setTitle: self.contentText
                     forState: UIControlStateNormal];
    self.mainButton.backgroundColor = [UIColor clearColor];
    self.mainButton.titleLabel.font = [UIFont boldSystemFontOfSize: 20];
    
    if (_isCompletionButton == YES){
        
        CALayer *mainLayer = self.mainButton.layer;
        mainLayer.masksToBounds = YES;
        mainLayer.cornerRadius = 25;
        mainLayer.borderWidth = 1.0;
        mainLayer.borderColor = [UIColor blackColor].CGColor;
        
    } else{
        
        self.mainButton.enabled = NO;
        
    }
    
}

#pragma mark - IBAction

- (IBAction)didPressMainButton:(id)sender{
    
    self.callback();
    
}
@end












