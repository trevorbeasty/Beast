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
    
    self.exerciseLabel.text = exercise;
    
    NSString *weightString = [NSString stringWithFormat: @"%@ lbs", [weight stringValue]];
    NSString *repsString = [NSString stringWithFormat: @"%@ reps", [reps stringValue]];
    NSString *formattedRest = [[TJBStopwatch singleton] minutesAndSecondsStringFromNumberOfSeconds: [rest intValue]];
    NSString *restString = [NSString stringWithFormat: @"+%@ rest", formattedRest];
    
    self.weightLabel.text = weightString;
    self.repsLabel.text = repsString;
    self.restLabel.text = restString;
    self.dateLabel.text = date;
    self.numberLabel.text = [number stringValue];
    
}

@end
