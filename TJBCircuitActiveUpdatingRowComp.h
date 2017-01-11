//
//  TJBCircuitActiveUpdatingRowComp.h
//  Beast
//
//  Created by Trevor Beasty on 1/11/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TJBCircuitActiveUpdatingRowComp : UIViewController

- (instancetype)initWithTargetsVaryByRound:(NSNumber *)targetsVaryByRound roundNumber:(NSNumber *)roundNumber weightData:(NSNumber *)weightData repsData:(NSNumber *)repsData restData:(NSNumber *)restData setLengthData:(NSNumber *)setLengthData setHasBeenRealized:(NSNumber *)setHasBeenRealized;

@end
