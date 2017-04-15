//
//  TJBAssortedUtilities.h
//  Beast
//
//  Created by Trevor Beasty on 1/11/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

// core data

@class TJBBeginDateComp;
@class TJBEndDateComp;
@class TJBRealizedChain;

@interface TJBAssortedUtilities : NSObject

+ (BOOL)nextIndiceValuesForCurrentExerciseIndex:(int)currentExerciseIndex currentRoundIndex:(int)currentRoundIndex maxExerciseIndex:(int)maxExerciseIndex maxRoundIndex:(int)maxRoundIndex exerciseIndexReference:(NSNumber **)exerciseIndexReference roundIndexReference:(NSNumber **)roundIndexReference;

+ (BOOL)previousExerciseAndRoundIndicesForCurrentExerciseIndex:(int)currentExerciseIndex currentRoundIndex:(int)currentRoundIndex numberOfExercises:(int)numberOfExercises numberOfRounds:(int)numberOfRounds roundIndexReference:(NSNumber **)roundIndexReference exerciseIndexReference:(NSNumber **)exerciseIndexReference;


+ (BOOL)indiceWithExerciseIndex:(int)currentExerciseIndex roundIndex:(int)currentRoundIndex isPriorToReferenceExerciseIndex:(int)referenceExerciseIndex referenceRoundIndex:(int)referenceRoundIndex;

#pragma mark - Detailed Drawing

+ (void)addVerticalBorderToRight:(UILabel *)label thickness:(CGFloat)thickness metaView:(UIView *)metaView;

+ (void)addHorizontalBorderBeneath:(UILabel *)label thickness:(CGFloat)thickness metaView:(UIView *)metaView;

+ (void)drawHookLineUnderLabel1:(UILabel *)label1 label2:(UILabel *)label2 verticalOffset:(CGFloat)vertOff thickness:(CGFloat)thickness hookLength:(CGFloat)hookLength metaView:(UIView *)metaView;

+ (void)drawVerticalDividerToRightOfLabel:(UILabel *)label horizontalOffset:(CGFloat)horOff thickness:(CGFloat)thickness verticalOffset:(CGFloat)vertOff metaView:(UIView *)metaView;

+ (void)drawVerticalDividerToLeftOfLabel:(UILabel *)label horizontalOffset:(CGFloat)horOff thickness:(CGFloat)thickness verticalOffset:(CGFloat)vertOff metaView:(UIView *)metaView;





@end
