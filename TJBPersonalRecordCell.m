//
//  TJBPersonalRecordCell.m
//  Beast
//
//  Created by Trevor Beasty on 1/30/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBPersonalRecordCell.h"

@implementation TJBPersonalRecordCell

- (void)configureWithReps:(NSNumber *)reps weight:(NSNumber *)weight date:(NSDate *)date{
    
    NSString *repsWord;
    if ([reps intValue] == 1){
        repsWord = @"rep";
    } else{
        repsWord = @"reps";
    }
    NSString *repsText = [NSString stringWithFormat: @"%@ %@",
                          [reps stringValue],
                          repsWord];
    self.repsLabel.text = repsText;
    
    NSString *weightString = [NSString stringWithFormat: @"%@ lbs", [weight stringValue]];
    self.weightLabel.text = weightString;
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"MMMM d, yyyy";
    self.dateLabel.text = [df stringFromDate: date];
    
    self.backgroundColor = [UIColor clearColor];
    
}


@end
