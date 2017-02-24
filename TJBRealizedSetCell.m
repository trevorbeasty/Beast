//
//  TJBRealizedSetCell.m
//  Beast
//
//  Created by Trevor Beasty on 1/27/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBRealizedSetCell.h"

// stopwatch

#import "TJBStopwatch.h"

@implementation TJBRealizedSetCell

- (void)configureCellWithExercise:(NSString *)exercise weight:(NSNumber *)weight reps:(NSNumber *)reps rest:(NSNumber *)rest date:(NSString *)date number:(NSNumber *)number{
    
    [self configureViewAesthetics];
    
    NSString *exerciseText = [NSString stringWithFormat: @"Exercise: %@", exercise];
    self.exerciseLabel.text = exerciseText;
    
    NSString *weightString = [NSString stringWithFormat: @"%@ lbs", [weight stringValue]];
    NSString *repsString = [NSString stringWithFormat: @"%@ reps", [reps stringValue]];
    NSString *formattedRest = [[TJBStopwatch singleton] minutesAndSecondsStringFromNumberOfSeconds: [rest intValue]];
    NSString *restString = [NSString stringWithFormat: @"+%@ rest", formattedRest];
    NSString *numberString = [NSString stringWithFormat: @"%@.", [number stringValue]];
    
    self.weightLabel.text = weightString;
    self.repsLabel.text = repsString;
    self.restLabel.text = restString;
    self.dateLabel.text = date;
    self.numberLabel.text = numberString;
    
    self.numberLabel.font = [UIFont boldSystemFontOfSize: 15.0];
    
}

- (void)configureViewAesthetics{
    
    // main labels
    
    NSArray *mainLabels = @[self.numberLabel, self.exerciseLabel];
    for (UILabel *label in mainLabels){
        
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor blackColor];
        label.font = [UIFont boldSystemFontOfSize: 15.0];
        
    }
    
    // date label
    
    self.dateLabel.font = [UIFont systemFontOfSize: 10.0];
    self.dateLabel.textColor = [UIColor blackColor];
    self.dateLabel.backgroundColor = [UIColor clearColor];
    
    // weight, reps, rest
    
    NSArray *valueLabels = @[self.weightLabel, self.repsLabel, self.restLabel];
    for (UILabel *label in valueLabels){
        
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor blackColor];
        label.font = [UIFont systemFontOfSize: 15.0];
        
    }
    
}

+(float)suggestedCellHeight{
    
    return 48;
    
}

@end
