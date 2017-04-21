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
    
    // detailed lines
    
    [self drawDetaiLines];
    
}

- (void)drawDetaiLines{
    
    [self.contentView layoutSubviews];
    
    [TJBAssortedUtilities drawVerticalDividerToRightOfLabel: self.weightLabel
                                           horizontalOffset: 0
                                                  thickness: .5
                                             verticalOffset: self.weightLabel.frame.size.height / 2.0
                                                   metaView: self.contentView];
    
}


@end
