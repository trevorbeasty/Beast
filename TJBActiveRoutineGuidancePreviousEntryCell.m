//
//  TJBActiveRoutineGuidancePreviousEntryCell.m
//  Beast
//
//  Created by Trevor Beasty on 2/10/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBActiveRoutineGuidancePreviousEntryCell.h"

@interface TJBActiveRoutineGuidancePreviousEntryCell ()

// IBOutlet

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *weightLabel;
@property (weak, nonatomic) IBOutlet UILabel *repsLabel;

@end

@implementation TJBActiveRoutineGuidancePreviousEntryCell

- (void)configureWithDate:(NSDate *)date weight:(NSNumber *)weight reps:(NSNumber *)reps{
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"MM / dd / yy";
    self.dateLabel.text = [df stringFromDate: date];
    
    self.weightLabel.text = [NSString stringWithFormat: @"%@", [weight stringValue]];
    
    self.repsLabel.text = [NSString stringWithFormat: @"%@", [reps stringValue]];
    
}



@end
