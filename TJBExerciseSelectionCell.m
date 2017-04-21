//
//  TJBExerciseSelectionCell.m
//  Beast
//
//  Created by Trevor Beasty on 3/1/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBExerciseSelectionCell.h"

@interface TJBExerciseSelectionCell ()

// IBOutlet

@property (weak, nonatomic) IBOutlet UILabel *exerciseNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;


@end

@implementation TJBExerciseSelectionCell

- (void)configureCellWithExerciseName:(NSString *)exerciseName date:(NSDate *)date{
    
    self.exerciseNameLabel.text = exerciseName;
    
    if (date){
        
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        df.dateFormat = @"M / d / yy";
        self.dateLabel.text = [df stringFromDate: date];
        
    } else{
        
        self.dateLabel.text = @"X";
        
    }
    
    [self viewAesthetics];

    
}

- (void)viewAesthetics{
    
    self.exerciseNameLabel.backgroundColor = [UIColor grayColor];
    self.exerciseNameLabel.textColor = [UIColor whiteColor];
    self.exerciseNameLabel.font = [UIFont boldSystemFontOfSize: 20];
    CALayer *enLayer = self.exerciseNameLabel.layer;
    enLayer.masksToBounds = YES;
    enLayer.cornerRadius = 8;
    
    self.dateLabel.font = [UIFont systemFontOfSize: 15];
    self.dateLabel.textColor = [UIColor blackColor];
    
}

@end
