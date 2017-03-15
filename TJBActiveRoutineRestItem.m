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

@interface TJBActiveRoutineRestItem ()

{
    
    // core
    
    BOOL _marksEndOfRoutine;
    BOOL _isTargetingRest;
    
}

// IBOutlet

@property (weak, nonatomic) IBOutlet UILabel *restTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;

// core

@property (nonatomic, strong) NSNumber *number;
@property (nonatomic, strong) NSNumber *rest;

@end

@implementation TJBActiveRoutineRestItem

#pragma mark - Instantiation

- (instancetype)initWithTitleNumber:(NSNumber *)titleNumber restNumber:(NSNumber *)restNumber marksEndOfRoutine:(BOOL)marksEndOfRoutine isTargetingRest:(BOOL)isTargetingRest{
    
    self = [super init];
    
    self.number = titleNumber;
    self.rest = restNumber;
    _marksEndOfRoutine = marksEndOfRoutine;
    _isTargetingRest = isTargetingRest;
    
    return self;
    
}

#pragma mark - View Life Cycle

- (void)viewDidLoad{
    
    self.view.backgroundColor = [UIColor clearColor];
    
    self.restTitleLabel.backgroundColor = [UIColor lightGrayColor];
    self.restTitleLabel.font = [UIFont boldSystemFontOfSize: 20.0];
    self.restTitleLabel.textColor = [UIColor whiteColor];
    
    self.numberLabel.backgroundColor = [UIColor lightGrayColor];
    self.numberLabel.font = [UIFont systemFontOfSize: 35];
    self.numberLabel.textColor = [UIColor whiteColor];
    
    self.numberLabel.text = [self.number stringValue];
    
    if (_marksEndOfRoutine){
        
        self.restTitleLabel.text = @"Routine Completed";
        
    } else{
        
        if (_isTargetingRest){
            
            self.restTitleLabel.text = [NSString stringWithFormat: @"Rest for %@",
                                        [[TJBStopwatch singleton] minutesAndSecondsStringFromNumberOfSeconds: [self.rest intValue]]];
            
        } else{
        
            self.restTitleLabel.text = @"Rest";
            
        }
        

        
    }
    

    
}



@end
