//
//  TJBCircuitActiveUpdatingRowCompProtocol.h
//  Beast
//
//  Created by Trevor Beasty on 1/15/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol TJBCircuitActiveUpdatingRowCompProtocol <NSObject>

- (void)updateViewsWithWeight:(NSNumber *)weight reps:(NSNumber *)reps rest:(NSNumber *)rest setLength:(NSNumber *)setLength;

@end
