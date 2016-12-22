//
//  TJBNumberSelectionVC.h
//  Beast
//
//  Created by Trevor Beasty on 12/7/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TJBGlobalParameters.h"

@interface TJBNumberSelectionVC : UICollectionViewController

{
    NumberType _numberTypeIdentifier;
}

@property (nonatomic, strong) NSNumber *numberMultiple;
@property (nonatomic, strong) NSNumber *numberLimit;

@property (copy) void(^callbackBlock)(NumberType, NSNumber *);

- (void)setNumberTypeIdentifier:(NumberType)numberType numberMultiple:(NSNumber *)numberMultiple associatedVC:(UIViewController *)associatedVC title:(NSString *)title;

- (void)setNumberTypeIdentifier:(NumberType)type;

@end
