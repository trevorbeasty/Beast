//
//  TJBCircuitActiveUpdatingRowComp.h
//  Beast
//
//  Created by Trevor Beasty on 1/11/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

// protocol

#import "TJBCircuitActiveUpdatingRowCompProtocol.h"

@interface TJBCircuitActiveUpdatingRowComp : UIViewController <TJBCircuitActiveUpdatingRowCompProtocol>

- (instancetype)initWithRoundNumber:(NSNumber *)roundNumber chainNumber:(NSNumber *)chainNumber weightData:(NSNumber *)weightData repsData:(NSNumber *)repsData restData:(NSNumber *)restData setLengthData:(NSNumber *)setLengthData setHasBeenRealized:(NSNumber *)setHasBeenRealized isFirstExerciseInFirstRound:(NSNumber *)isFirstExerciseInFirstRound;

@end
