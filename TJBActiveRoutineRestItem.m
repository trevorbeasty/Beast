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

// IBOutlet

@property (weak, nonatomic) IBOutlet UILabel *numberTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *restTitleLabel;

// core

@property (nonatomic, strong) NSNumber *number;
@property (nonatomic, strong) NSNumber *rest;

@end

@implementation TJBActiveRoutineRestItem

#pragma mark - Instantiation

- (instancetype)initWithTitleNumber:(NSNumber *)titleNumber restNumber:(NSNumber *)restNumber{
    
    self = [super init];
    
    self.number = titleNumber;
    self.rest = restNumber;
    
    return self;
    
}

#pragma mark - View Life Cycle

- (void)viewDidLoad{
    
    self.numberTitleLabel.text = [NSString stringWithFormat: @"%@.", [self.number stringValue]];
    self.restTitleLabel.text = [NSString stringWithFormat: @"Rest for %@",
                                [[TJBStopwatch singleton] minutesAndSecondsStringFromNumberOfSeconds: [self.rest intValue]]];
    
}



@end
