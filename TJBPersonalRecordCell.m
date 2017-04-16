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
    
    // view data

    self.repsLabel.text = [reps stringValue];
    
    self.weightLabel.text = [weight stringValue];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"MMM d, yyyy";
    self.dateLabel.text = [df stringFromDate: date];
    
    // aesthetics
    
    [self configureViewAesthetics];
    
}

- (void)configureViewAesthetics{
    
    self.contentView.backgroundColor = [UIColor clearColor];
    
    self.repsLabel.font = [UIFont systemFontOfSize: 30];
    self.repsLabel.textColor = [UIColor blackColor];
    self.repsLabel.backgroundColor = [UIColor clearColor];
    
    NSArray *otherLabels = @[self.weightLabel, self.dateLabel];
    for (UILabel *lab in otherLabels){
        
        lab.font = [UIFont systemFontOfSize: 20];
        lab.backgroundColor = [UIColor clearColor];
        lab.textColor = [UIColor blackColor];
        
    }
    
    // detailed lines
    
    [self drawDetaiLines];
    
}

- (void)drawDetaiLines{
    
//    [self.contentView layoutSubviews];
//    
//    [TJBAssortedUtilities drawHookLineUnderLabel1: self.weightLabel
//                                           label2: self.dateLabel
//                                   verticalOffset: 2.0
//                                        thickness: 1.0
//                                       hookLength: 16
//                                         metaView: self.contentView];
//    
//    self.repsLabel
    
}


@end
