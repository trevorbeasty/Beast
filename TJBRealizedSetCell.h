//
//  TJBRealizedSetCell.h
//  Beast
//
//  Created by Trevor Beasty on 1/27/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TJBRealizedSetCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *weightLabel;
@property (weak, nonatomic) IBOutlet UILabel *repsLabel;
@property (weak, nonatomic) IBOutlet UILabel *restLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;

+ (float)suggestedCellHeight;

- (void)configureCellWithExercise:(NSString *)exercise weight:(NSNumber *)weight reps:(NSNumber *)reps rest:(NSNumber *)rest date:(NSString *)date number:(NSNumber *)number;



@end
