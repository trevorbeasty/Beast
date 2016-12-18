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

{
    NumberType _numberTypeIdentifier;
}

// number specifications

@property (nonatomic, strong) NSNumber *numberMultiple;
@property (nonatomic, strong) NSNumber *numberLimit;

// delegate view controller

@property (nonatomic, weak) UIViewController <TJBNumberSelectionDelegate> *associatedVC;

// view specifications

@property (nonatomic, strong) NSString *titleString;

- (void)setNumberTypeIdentifier:(NumberType)type;

@end
