//
//  RealizedSetHistoryCell.m
//  Beast
//
//  Created by Trevor Beasty on 12/10/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import "RealizedSetHistoryCell.h"

// time conversion

#import "TJBStopwatch.h"

@implementation RealizedSetHistoryCell

- (void)configureCellWithExerciseName:(NSString *)exerciseName weight:(NSNumber *)weight reps:(NSNumber *)reps rest:(NSNumber *)rest date:(NSString *)date{
    
    self.exerciseLabel.text = exerciseName;
    
    NSString *weightString = [NSString stringWithFormat: @"%@ lbs", [weight stringValue]];
    NSString *repsString = [NSString stringWithFormat: @"%@ reps", [reps stringValue]];
    NSString *formattedRest = [[TJBStopwatch singleton] minutesAndSecondsStringFromNumberOfSeconds: [rest intValue]];
    NSString *restString = [NSString stringWithFormat: @"%@ rest", formattedRest];
    
    self.weightLabel.text = weightString;
    self.repsLabel.text = repsString;
    self.restLabel.text = restString;
    self.dateLabel.text = date;
    
}

@end
