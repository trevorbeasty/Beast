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
    
    self.restTitleLabel.backgroundColor = [UIColor clearColor];
    self.restTitleLabel.font = [UIFont boldSystemFontOfSize: 20.0];
    self.restTitleLabel.textColor = [UIColor darkGrayColor];
    
    if (_marksEndOfRoutine){
        
        self.restTitleLabel.text = @"Routine Completed";
        
    } else{
        
        if (_isTargetingRest){
            
            self.restTitleLabel.text = [NSString stringWithFormat: @"%d. Rest for %@",
                                        [self.number intValue],
                                        [[TJBStopwatch singleton] minutesAndSecondsStringFromNumberOfSeconds: [self.rest intValue]]];
            
        } else{
        
            self.restTitleLabel.text = [NSString stringWithFormat: @"%d. Rest", [self.number intValue]];
            
        }
        

        
    }
    

    
}



@end
