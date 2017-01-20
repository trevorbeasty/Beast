//
//  TJBRepsWeightRecordPair.h
//  Beast
//
//  Created by Trevor Beasty on 1/19/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <Foundation/Foundation.h>



@interface TJBRepsWeightRecordPair : NSObject

@property (nonatomic, strong) NSNumber *reps;
@property (nonatomic, strong) NSNumber *weight;
@property (nonatomic, strong) NSDate *date;
@property (nonatomic, strong) NSNumber *isDefaultObject;

- (instancetype)initDefaultObjectWithReps:(int)reps;

@end
