//
//  TJBExerciseSelectionTitleCell.h
//  Beast
//
//  Created by Trevor Beasty on 3/16/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TJBTextField.h"

@interface TJBExerciseSelectionTitleCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *subTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *detail1Label;
@property (weak, nonatomic) IBOutlet UILabel *detail2Label;

@property (weak, nonatomic) IBOutlet TJBTextField *searchTextField;
@property (weak, nonatomic) IBOutlet UILabel *searchTitle;

- (void)toggleToSearchState;
- (void)toggleToDefaultState;


@end
