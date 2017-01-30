//
//  TJBPersonalRecordCell.h
//  Beast
//
//  Created by Trevor Beasty on 1/30/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TJBPersonalRecordCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *repsLabel;
@property (weak, nonatomic) IBOutlet UILabel *weightLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

- (void)configureWithReps:(NSNumber *)reps weight:(NSNumber *)weight date:(NSDate *)date;


@end
