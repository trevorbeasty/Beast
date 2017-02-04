//
//  TJBSchemeSelectionDateCompDelegate.h
//  Beast
//
//  Created by Trevor Beasty on 2/2/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TJBSchemeSelectionDateCompDelegate <NSObject>

- (void)didSelectObjectWithIndex:(NSNumber *)index;

@end
