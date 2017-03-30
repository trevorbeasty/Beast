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

- (void)configureCellWithExercise:(NSString *)exercise weight:(NSNumber *)weight reps:(NSNumber *)reps rest:(NSNumber *)rest date:(NSString *)date number:(NSNumber *)number referenceIndexPath:(NSIndexPath *)path{
    
    self.referenceIndexPath = path;
    
    [self configureViewAesthetics];
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    NSString *weightString = [NSString stringWithFormat: @"%.01f", [weight floatValue]];
    NSString *repsString = [NSString stringWithFormat: @"%.01f", [reps floatValue]];
    
    NSString *restString;
    
//    if (rest){
//        
//        NSString *formattedRest = [[TJBStopwatch singleton] minutesAndSecondsStringFromNumberOfSeconds: [rest intValue]];
//        restString = [NSString stringWithFormat: @"+%@ rest", formattedRest];
//        
//    } else{
    
        restString = @"";
        
//    }

    NSString *numberString = [NSString stringWithFormat: @"%@. %@",
                              [number stringValue],
                              exercise];
    
    self.weightLabel.text = weightString;
    self.repsLabel.text = repsString;
    self.restLabel.text = restString;
    self.dateLabel.text = date;
    self.numberLabel.text = numberString;
    
    self.numberLabel.font = [UIFont boldSystemFontOfSize: 15.0];
    
}

- (void)configureViewAesthetics{
    
    // main labels
    
    NSArray *mainLabels = @[self.numberLabel];
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
