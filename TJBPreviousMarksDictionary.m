//
//  TJBPreviousMarksDictionary.m
//  Beast
//
//  Created by Trevor Beasty on 4/19/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBPreviousMarksDictionary.h"

@interface TJBPreviousMarksDictionary ()

@property (strong) NSMutableDictionary *proxy;

@end

#pragma mark - Keys

static NSString * const weightKey = @"weight";
static NSString * const repsKey = @"reps";
static NSString * const dateKey = @"date";

@implementation TJBPreviousMarksDictionary


#pragma mark - Writing

- (instancetype)initWithDate:(NSDate *)date weight:(NSNumber *)weight reps:(NSNumber *)reps{
    
    self = [super init];
    
    self.proxy = [[NSMutableDictionary alloc] initWithObjects: @[date, weight, reps]
                                                      forKeys: @[dateKey, weightKey, repsKey]];
    
    return self;

}



#pragma mark - Reading


- (NSDate *)date{
    
    return [self.proxy objectForKey: dateKey];
    
}

- (NSNumber *)weight{
    
    return [self.proxy objectForKey: weightKey];
    
}


- (NSNumber *)reps{
    
    return  [self.proxy objectForKey: repsKey];
    
}


@end
