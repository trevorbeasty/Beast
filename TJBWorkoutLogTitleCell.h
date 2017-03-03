//
//  TJBWorkoutLogTitleCell.h
//  Beast
//
//  Created by Trevor Beasty on 1/31/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TJBMasterCell.h"

@interface TJBWorkoutLogTitleCell : TJBMasterCell

@property (weak, nonatomic) IBOutlet UILabel *secondaryLabel;
@property (weak, nonatomic) IBOutlet UILabel *primaryLabel;

@end
