//
//  TJBActiveRoutineGuidancePreviousEntryCell.h
//  Beast
//
//  Created by Trevor Beasty on 2/10/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TJBActiveRoutineGuidancePreviousEntryCell : UITableViewCell

- (void)configureWithDate:(NSDate *)date weight:(NSNumber *)weight reps:(NSNumber *)reps;

@end
