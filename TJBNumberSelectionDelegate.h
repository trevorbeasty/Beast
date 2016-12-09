//
//  NumberSelectionDelegate.h
//  Beast
//
//  Created by Trevor Beasty on 12/7/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TJBNumberSelectionDelegate <NSObject>

- (void)didSelectNumber:(NSNumber *)number numberTypeIdentifier:(NSString *)identifier;

@end
