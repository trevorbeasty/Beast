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

// IBOutlet

@property (weak, nonatomic) IBOutlet UILabel *restTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;

// core

@property (nonatomic, strong) NSNumber *number;
@property (nonatomic, strong) NSString *contentText;

@end

@implementation TJBActiveRoutineRestItem

#pragma mark - Instantiation

- (instancetype)initWithTitleNumber:(NSNumber *)titleNumber contentText:(NSString *)contentText{
    
    self = [super init];
    
    self.number = titleNumber;
    self.contentText = contentText;
    
    return self;
    
}

#pragma mark - View Life Cycle

- (void)viewDidLoad{
    
    self.view.backgroundColor = [UIColor clearColor];
    
    self.restTitleLabel.backgroundColor = [[TJBAestheticsController singleton] yellowNotebookColor];
    self.restTitleLabel.font = [UIFont systemFontOfSize: 20.0];
    self.restTitleLabel.textColor = [UIColor blackColor];
    
    self.numberLabel.backgroundColor = [[TJBAestheticsController singleton] yellowNotebookColor];
    self.numberLabel.font = [UIFont systemFontOfSize: 35];
    self.numberLabel.textColor = [UIColor blackColor];
    
    self.numberLabel.text = [self.number stringValue];
    
    self.restTitleLabel.text = self.contentText;
    
}



@end
