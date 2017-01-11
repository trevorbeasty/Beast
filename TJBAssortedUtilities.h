//
//  TJBAssortedUtilities.h
//  Beast
//
//  Created by Trevor Beasty on 1/11/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TJBAssortedUtilities : NSObject

+ (void)nextIndiceValuesForCurrentExerciseIndex:(NSNumber *)currentExerciseIndex currentRoundIndex:(NSNumber *)currentRoundIndex maxExerciseIndex:(NSNumber *)maxExerciseIndex maxRoundIndex:(NSNumber *)maxRoundIndex exerciseIndexReference:(NSNumber **)exerciseIndexReference roundIndexReference:(NSNumber **)roundIndexReference;

@end
