//
//  TJBNumberSelectionVC.h
//  Beast
//
//  Created by Trevor Beasty on 12/7/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "TJBGlobalParameters.h"

typedef void(^CancelBlock)(void);
typedef void(^NumberSelectedBlock)(NSNumber *);

@interface TJBNumberSelectionVC : UICollectionViewController

{
    NumberType _numberTypeIdentifier;
}

@property (nonatomic, strong) NSNumber *numberMultiple;
@property (nonatomic, strong) NSNumber *numberLimit;
@property (copy) void (^cancelBlock)(void);
@property (copy) void (^numberSelectedBlock)(NSNumber *);

- (void)setNumberTypeIdentifier:(NumberType)numberType numberMultiple:(NSNumber *)numberMultiple numberLimit:(NSNumber *)numberLimit title:(NSString *)title cancelBlock:(void(^)(void))cancelBlock numberSelectedBlock:(void(^)(NSNumber *))numberSelectedBlock;

- (void)setNumberTypeIdentifier:(NumberType)type;

@end
