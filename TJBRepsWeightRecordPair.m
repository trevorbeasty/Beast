//
//  TJBRepsWeightRecordPair.m
//  Beast
//
//  Created by Trevor Beasty on 1/19/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBRepsWeightRecordPair.h"




@implementation TJBRepsWeightRecordPair

#pragma mark - Instantiation

- (instancetype)initDefaultObjectWithReps:(int)reps{
    
    //// assign the passed-in reps value and assign YES to the isDefaultObject property
    
    self = [super init];
    
    self.reps = [NSNumber numberWithInt: reps];
    
    self.weight = nil;
    
    self.isDefaultObject = [NSNumber numberWithBool: YES];
    
    return self;
    
}

@end
