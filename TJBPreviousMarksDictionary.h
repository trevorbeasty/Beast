//
//  TJBPreviousMarksDictionary.h
//  Beast
//
//  Created by Trevor Beasty on 4/19/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TJBPreviousMarksDictionary : NSObject

#pragma mark - Writing

- (instancetype)initWithDate:(NSDate *)date weight:(NSNumber *)weight reps:(NSNumber *)reps;

#pragma mark - Reading

- (NSDate *)date;
- (NSNumber *)weight;
- (NSNumber *)reps;

@end
