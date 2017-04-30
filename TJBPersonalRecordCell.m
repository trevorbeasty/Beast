//
//  TJBPersonalRecordCell.m
//  Beast
//
//  Created by Trevor Beasty on 1/30/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBPersonalRecordCell.h"

#import "TJBAssortedUtilities.h"

@implementation TJBPersonalRecordCell

- (void)configureWithReps:(NSNumber *)reps weight:(NSNumber *)weight date:(NSDate *)date{
    
    [self.contentView layoutSubviews];
    
    // view data

    self.repsLabel.text = [NSString stringWithFormat: @"%@ reps", [reps stringValue]];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"M / d / yy";
    self.dateLabel.text = [df stringFromDate: date];
    
    self.weightLabel.text = [NSString stringWithFormat: @"%@ lbs",
                             [weight stringValue]];
    

    
    // aesthetics
    
    [self configureViewAesthetics];
    
}

- (void)configureViewAesthetics{
    
    self.contentView.backgroundColor = [UIColor clearColor];
    
    self.repsLabel.font = [UIFont boldSystemFontOfSize: 20];
    self.repsLabel.textColor = [UIColor whiteColor];
    self.repsLabel.backgroundColor = [UIColor grayColor];
    CALayer *repsLayer = self.repsLabel.layer;
    repsLayer.masksToBounds = YES;
    repsLayer.cornerRadius = 4;
    
    NSArray *otherLabels = @[self.weightLabel, self.dateLabel];
    for (UILabel *lab in otherLabels){
        
        lab.font = [UIFont systemFontOfSize: 15];
        lab.backgroundColor = [UIColor clearColor];
        lab.textColor = [UIColor blackColor];
        
    }
    
//    self.indentationWidth = 0;
//    self.separatorInset = UIEdgeInsetsZero;
//    self.indentationLevel = 0;
    
    
}



@end
