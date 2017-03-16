//
//  TJBExerciseSelectionTitleCell.m
//  Beast
//
//  Created by Trevor Beasty on 3/16/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBExerciseSelectionTitleCell.h"

@implementation TJBExerciseSelectionTitleCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    
    self.searchTextField.hidden = YES;
    self.searchTitle.hidden = YES;
    
    // aesthetics
    
    self.searchTextField.layer.borderColor = [UIColor blackColor].CGColor;
    self.searchTextField.layer.borderWidth = 1.0;
    self.searchTextField.layer.cornerRadius = 8.0;
    self.searchTextField.layer.masksToBounds = YES;
    
    
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

#pragma mark - API

- (void)toggleToSearchState{
    
    self.searchTitle.hidden = NO;
    self.titleLabel.hidden = YES;
    
    self.searchTextField.hidden = NO;
    self.subTitleLabel.hidden = YES;
    
//    [self.searchTextField becomeFirstResponder];
    
}

- (void)toggleToDefaultState{
    
    self.searchTitle.hidden = YES;
    self.titleLabel.hidden = NO;
    
    self.searchTextField.hidden = YES;
    self.subTitleLabel.hidden = NO;
    
//    [self.searchTextField resignFirstResponder];
    
}

@end
