//
//  TJBNumberSelectionVC.h
//  Beast
//
//  Created by Trevor Beasty on 12/7/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TJBNumberSelectionDelegate.h"

@interface TJBNumberSelectionVC : UICollectionViewController

// number specifications

@property (nonatomic, strong) NSNumber *numberMultiple;
@property (nonatomic, strong) NSNumber *numberLimit;

// delegate view controller

@property (nonatomic, weak) UIViewController <TJBNumberSelectionDelegate> *associatedVC;
@property (nonatomic, strong) NSString *numberTypeIdentifier;

// view specifications

@property (nonatomic, strong) NSString *titleString;

@end
