//
//  TJBAssortedUtilities.m
//  Beast
//
//  Created by Trevor Beasty on 1/11/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBAssortedUtilities.h"


// core data

#import "CoreDataController.h"

@implementation TJBAssortedUtilities

+ (BOOL)indiceWithExerciseIndex:(int)currentExerciseIndex roundIndex:(int)currentRoundIndex isPriorToReferenceExerciseIndex:(int)referenceExerciseIndex referenceRoundIndex:(int)referenceRoundIndex{
    
    // return a BOOL indicating if the queried round comes before the reference round
    
    if (currentRoundIndex < referenceRoundIndex){
        
        return YES;
        
    } else if (currentRoundIndex > referenceRoundIndex){
        
        return NO;
        
    } else{
        
        if (currentExerciseIndex < referenceExerciseIndex){
            
            return YES;
            
        } else{
            
            return NO;
            
        }
        
    }
    
}

+ (BOOL)nextIndiceValuesForCurrentExerciseIndex:(int)currentExerciseIndex currentRoundIndex:(int)currentRoundIndex maxExerciseIndex:(int)maxExerciseIndex maxRoundIndex:(int)maxRoundIndex exerciseIndexReference:(NSNumber *__autoreleasing *)exerciseIndexReference roundIndexReference:(NSNumber *__autoreleasing *)roundIndexReference{
    
    //// returns YES if the next round indices exist and NO otherwise.  Also passes back next round indices if they exist via pass by reference
    
    BOOL atMaxRoundIndex = currentRoundIndex == maxRoundIndex;
    BOOL atMaxExerciseIndex = currentExerciseIndex == maxExerciseIndex;
    
    NSNumber *exerciseReturnValue;
    NSNumber *roundReturnValue;
    

    if(atMaxExerciseIndex){
        
        if (atMaxRoundIndex){
            
            exerciseReturnValue = [NSNumber numberWithInt: 0];
            
            roundReturnValue = [NSNumber numberWithInt: currentRoundIndex + 1];
            
            *exerciseIndexReference = exerciseReturnValue;
            *roundIndexReference = roundReturnValue;
            
            return NO;
            
        } else{
            
            exerciseReturnValue = [NSNumber numberWithInt: 0];
            
            roundReturnValue = [NSNumber numberWithInt: currentRoundIndex + 1];
            
        }
        
    } else{
            
        exerciseReturnValue = [NSNumber numberWithInt: currentExerciseIndex + 1];
        
        roundReturnValue = [NSNumber numberWithInt: currentRoundIndex];
            
    }
    
    *exerciseIndexReference = exerciseReturnValue;
    *roundIndexReference = roundReturnValue;

    return YES;
    
}

+ (BOOL)previousExerciseAndRoundIndicesForCurrentExerciseIndex:(int)currentExerciseIndex currentRoundIndex:(int)currentRoundIndex numberOfExercises:(int)numberOfExercises numberOfRounds:(int)numberOfRounds roundIndexReference:(NSNumber *__autoreleasing *)roundIndexReference exerciseIndexReference:(NSNumber *__autoreleasing *)exerciseIndexReference{
    
    //// give the previous exercise and round index based on the given parameters.  Returns NO if there is no previous exercise/round index, YES otherwise
    
    BOOL atFirstRound = currentRoundIndex == 0;
    BOOL atFirstExercise = currentExerciseIndex == 0;
    
    if (atFirstRound && atFirstExercise){
        
        return NO;
        
    } else if (!atFirstExercise){
        
        *roundIndexReference = [NSNumber numberWithInt: currentRoundIndex];
        *exerciseIndexReference = [NSNumber numberWithInt: currentExerciseIndex - 1];
        return YES;
        
    } else if (atFirstExercise){
        
        *roundIndexReference = [NSNumber numberWithInt: currentRoundIndex - 1];
        *exerciseIndexReference = [NSNumber numberWithInt: numberOfExercises - 1];
        return YES;
        
    } else{
        
        abort();
        
    }
    
}



#pragma mark - Detailed Drawing

+ (void)addVerticalBorderToRight:(UILabel *)label thickness:(CGFloat)thickness metaView:(UIView *)metaView{
    
    CAShapeLayer *sl = [CAShapeLayer layer];
    
    // attributes
    
    sl.strokeColor = [[UIColor blackColor] CGColor];
    sl.lineWidth = thickness;
    sl.fillColor = nil;
    sl.opacity = 1.0;
    
    
    // path
    // vertical offset describes the amount by which the line is inset from the labels top and bottom edges
    // horizontal offset describes the distance to the right from the labels right edge that the line is drawn
    
    CGPoint labelOrigin = label.frame.origin;
    CGSize labelSize = label.frame.size;
    
    CGPoint startPoint = CGPointMake(labelOrigin.x + labelSize.width, labelOrigin.y);
    CGPoint endPoint = CGPointMake(startPoint.x, startPoint.y + labelSize.height);
    
    UIBezierPath *bp = [[UIBezierPath alloc] init];
    [bp moveToPoint: startPoint];
    [bp addLineToPoint: endPoint];
    
    sl.path = bp.CGPath;
    
    // label layer
    
    [metaView.layer addSublayer: sl];
    
}

+ (void)addHorizontalBorderBeneath:(UILabel *)label thickness:(CGFloat)thickness metaView:(UIView *)metaView{
    
    CAShapeLayer *sl = [CAShapeLayer layer];
    
    // attributes
    
    sl.strokeColor = [[UIColor blackColor] CGColor];
    sl.lineWidth = thickness;
    sl.fillColor = nil;
    sl.opacity = 1.0;
    
    
    // path
    // vertical offset describes the amount by which the line is inset from the labels top and bottom edges
    // horizontal offset describes the distance to the right from the labels right edge that the line is drawn
    
    CGPoint labelOrigin = label.frame.origin;
    CGSize labelSize = label.frame.size;
    
    CGPoint startPoint = CGPointMake(labelOrigin.x, labelOrigin.y + labelSize.height);
    CGPoint endPoint = CGPointMake(startPoint.x + labelSize.width,  startPoint.y);
    
    UIBezierPath *bp = [[UIBezierPath alloc] init];
    [bp moveToPoint: startPoint];
    [bp addLineToPoint: endPoint];
    
    sl.path = bp.CGPath;
    
    // label layer
    
    [metaView.layer addSublayer: sl];
    
}

+ (void)drawHookLineUnderLabel1:(UILabel *)label1 label2:(UILabel *)label2 verticalOffset:(CGFloat)vertOff thickness:(CGFloat)thickness hookLength:(CGFloat)hookLength metaView:(UIView *)metaView{
    
    // vertical offset describes the distance under the label's bottom edge that the hook line is drawn
    
    CAShapeLayer *sl = [CAShapeLayer layer];
    
    // attributes
    
    sl.strokeColor = [[UIColor blackColor] CGColor];
    sl.lineWidth = thickness;
    sl.fillColor = nil;
    sl.opacity = 1.0;
    
    
    // path
    // vertical offset describes the amount by which the line is inset from the labels top and bottom edges
    // horizontal offset describes the distance to the right from the labels right edge that the line is drawn

    
        CGPoint startPoint = CGPointMake(0, label1.frame.size.height + vertOff);
        CGPoint interimPoint = CGPointMake(label2.frame.origin.x + label2.frame.size.width - label1.frame.origin.x, startPoint.y);
        CGPoint endPoint = CGPointMake(interimPoint.x + hookLength,  interimPoint.y - hookLength);
    
    
    UIBezierPath *bp = [[UIBezierPath alloc] init];
    [bp moveToPoint: startPoint];
    [bp addLineToPoint: interimPoint];
    [bp addLineToPoint: endPoint];
    
    sl.path = bp.CGPath;
    
    // label layer
    
    label1.layer.masksToBounds = NO;
    
    [label1.layer addSublayer: sl];
    
}

+ (void)drawVerticalDividerToRightOfLabel:(UILabel *)label horizontalOffset:(CGFloat)horOff thickness:(CGFloat)thickness verticalOffset:(CGFloat)vertOff metaView:(UIView *)metaView{
    
    CAShapeLayer *sl = [CAShapeLayer layer];
    
    // attributes
    
    sl.strokeColor = [[UIColor blackColor] CGColor];
    sl.lineWidth = thickness;
    sl.fillColor = nil;
    sl.opacity = 1.0;
    
    
    // path
    // vertical offset describes the amount by which the line is inset from the labels top and bottom edges
    // horizontal offset describes the distance to the right from the labels right edge that the line is drawn
    
    CGPoint labelOrigin = label.frame.origin;
    CGSize labelSize = label.frame.size;
    
    CGPoint topRightCorner = CGPointMake(labelOrigin.x + labelSize.width - thickness / 2.0, labelOrigin.y);
    CGPoint bottomRightCorner = CGPointMake(topRightCorner.x, topRightCorner.y + labelSize.height);
    
    CGPoint startPoint = CGPointMake(topRightCorner.x + horOff, topRightCorner.y + vertOff);
    CGPoint endPoint = CGPointMake(bottomRightCorner.x + horOff,  bottomRightCorner.y - vertOff);
    
    UIBezierPath *bp = [[UIBezierPath alloc] init];
    [bp moveToPoint: startPoint];
    [bp addLineToPoint: endPoint];
    
    sl.path = bp.CGPath;
    
    // label layer
    
    [metaView.layer addSublayer: sl];
    
}

+ (void)drawVerticalDividerToLeftOfLabel:(UILabel *)label horizontalOffset:(CGFloat)horOff thickness:(CGFloat)thickness verticalOffset:(CGFloat)vertOff metaView:(UIView *)metaView{
    
    CAShapeLayer *sl = [CAShapeLayer layer];
    
    // attributes
    
    sl.strokeColor = [[UIColor blackColor] CGColor];
    sl.lineWidth = thickness;
    sl.fillColor = nil;
    sl.opacity = 1.0;
    
    
    // path
    // vertical offset describes the amount by which the line is inset from the labels top and bottom edges
    // horizontal offset describes the distance to the right from the labels right edge that the line is drawn
    
    CGPoint labelOrigin = label.frame.origin;
    CGSize labelSize = label.frame.size;
    
    CGPoint topLeftCorner = labelOrigin;
    CGPoint bottomLeftCorner = CGPointMake(topLeftCorner.x, topLeftCorner.y + labelSize.height);
    
    CGPoint startPoint = CGPointMake(topLeftCorner.x - horOff, topLeftCorner.y + vertOff);
    CGPoint endPoint = CGPointMake(bottomLeftCorner.x - horOff,  bottomLeftCorner.y - vertOff);
    
    UIBezierPath *bp = [[UIBezierPath alloc] init];
    [bp moveToPoint: startPoint];
    [bp addLineToPoint: endPoint];
    
    sl.path = bp.CGPath;
    
    // label layer
    
    [metaView.layer addSublayer: sl];
    
}


#pragma mark - View Math


+ (CGRect)rectByTranslatingRect:(CGRect)initialRect originX:(CGFloat)originX originY:(CGFloat)originY{
    
    return CGRectMake(initialRect.origin.x + originX, initialRect.origin.y + originY, initialRect.size.width, initialRect.size.height);
    
}



@end







































