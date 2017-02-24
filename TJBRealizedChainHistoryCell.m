//
//  TJBRealizedChainHistoryCell.m
//  Beast
//
//  Created by Trevor Beasty on 2/23/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBRealizedChainHistoryCell.h"

// core data

#import "CoreDataController.h"

// utilities

#import "TJBAssortedUtilities.h"

// stopwatch

#import "TJBStopwatch.h"

@interface TJBRealizedChainHistoryCell ()

// IBOutlet

@property (weak, nonatomic) IBOutlet UIStackView *contentStackView;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;

// core

@property (strong) TJBRealizedChain *realizedChain;


@end

@implementation TJBRealizedChainHistoryCell

- (void)clearExistingEntries{
    
    ////  clear the stack view arranged subviews
    
    NSArray *views = self.contentStackView.arrangedSubviews;
    
    for (UIView *view in views){
        
        [self.contentStackView removeArrangedSubview: view];
        [view removeFromSuperview];
        
    }
    
    
}

- (void)configureWithRealizedChain:(TJBRealizedChain *)realizedChain number:(NSNumber *)number{
    
    //// this cell will be dynamically sized, showing the chain name in the main label and stacking another label for every exercise in the chain
    
    self.realizedChain = realizedChain;
    
    TJBChainTemplate *chainTemplate = realizedChain.chainTemplate;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self configureViewAesthetics];
    
    // configure the chain name label
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateStyle = NSDateFormatterLongStyle;
    df.timeStyle = NSDateFormatterNoStyle;
    
    NSString *numberText = [NSString stringWithFormat: @"%@. %@",
                            [number stringValue],
                            [df stringFromDate: self.realizedChain.dateCreated]];
    self.numberLabel.text = numberText;
    
    //// configure the stack view.  For every exercise, create a UILabel and configure it before adding it to the stack view
    
    int numExercises = chainTemplate.numberOfExercises;
    
    for (int i = 0; i < numExercises; i++){
        
        UIView *iterativeView = [self stackViewForExerciseIndex: i];
        
        [self.contentStackView addArrangedSubview: iterativeView];
        
    }
    
}

- (void)configureViewAesthetics{
    
    self.contentView.backgroundColor = [UIColor clearColor];
    
    self.numberLabel.backgroundColor = [UIColor clearColor];
    self.numberLabel.textColor = [UIColor blackColor];
    self.numberLabel.font = [UIFont boldSystemFontOfSize: 15.0];
    
}

- (UIStackView *)stackViewForExerciseIndex:(int)exerciseIndex{
    
    UIStackView *stackView = [[UIStackView alloc] init];
    stackView.axis = UILayoutConstraintAxisVertical;
    
    int roundLimit = self.realizedChain.numberOfRounds;
    
    // exercise label
    
    UILabel *exerciseLabel = [[UILabel alloc] init];
    exerciseLabel.text = self.realizedChain.exercises[exerciseIndex].name;
    exerciseLabel.font = [UIFont systemFontOfSize: 15.0];
    exerciseLabel.textColor = [UIColor blackColor];
    exerciseLabel.textAlignment = NSTextAlignmentLeft;
    
    [stackView addArrangedSubview: exerciseLabel];
    
    for (int i = 0; i < roundLimit; i++){
        
        UIView *iterativeView = [self roundSubviewForExerciseIndex: exerciseIndex
                                                        roundIndex: i];
        
        [stackView addArrangedSubview: iterativeView];
        
    }
    
    return stackView;
    
}

- (UIView *)roundSubviewForExerciseIndex:(int)exerciseIndex roundIndex:(int)roundIndex{
    
    //// create the exercise name subview, which will have two labels - one for a number and one for a name
    
    UIView *view = [[UIView alloc] init];
    
    UILabel *weightLabel = [[UILabel alloc] init];
    UILabel *repsLabel = [[UILabel alloc] init];
    UILabel *restLabel = [[UILabel alloc] init];
    
    BOOL roundHasBeenExecuted = [TJBAssortedUtilities indiceWithExerciseIndex: exerciseIndex
                                                                   roundIndex: roundIndex
                                              isPriorToReferenceExerciseIndex: self.realizedChain.firstIncompleteExerciseIndex
                                                          referenceRoundIndex: self.realizedChain.firstIncompleteRoundIndex];
    
    if (roundHasBeenExecuted){
        
        float weight = self.realizedChain.weightArrays[exerciseIndex].numbers[roundIndex].value;
        int reps = (int)self.realizedChain.repsArrays[exerciseIndex].numbers[roundIndex].value;
        
        NSString *weightString = [NSString stringWithFormat: @"%.01f lbs", weight];
        NSString *repsString = [NSString stringWithFormat: @"%d reps", reps];
        
        
        weightLabel.text = weightString;
        repsLabel.text = repsString;
        
    } else{
        
        weightLabel.text = @"X";
        repsLabel.text = @"";
        
    }
    
    // rest should be filled depending upon if this round and the next were executed
    
    NSString *restText;
    
    NSNumber *nextExerciseInd = nil;
    NSNumber *nextRoundInd = nil;
    BOOL nextRoundWithinIndiceRange = [TJBAssortedUtilities nextIndiceValuesForCurrentExerciseIndex: exerciseIndex
                                                                                  currentRoundIndex: roundIndex
                                                                                   maxExerciseIndex: self.realizedChain.numberOfExercises - 1
                                                                                      maxRoundIndex: self.realizedChain.numberOfRounds - 1
                                                                             exerciseIndexReference: &nextExerciseInd
                                                                                roundIndexReference: &nextRoundInd];
    
    if (nextRoundWithinIndiceRange){
        
        BOOL nextRoundHasBeenExecuted = [TJBAssortedUtilities indiceWithExerciseIndex: [nextExerciseInd intValue]
                                                                           roundIndex: [nextRoundInd intValue]
                                                      isPriorToReferenceExerciseIndex: self.realizedChain.firstIncompleteExerciseIndex
                                                                  referenceRoundIndex: self.realizedChain.firstIncompleteRoundIndex];
        
        if (nextRoundHasBeenExecuted){
            
            NSDate *currentRoundEndDate;
            NSDate *nextRoundBeginDate;
            
            // grab the two dates from the realized chain if they are not default objects
            
            if (self.realizedChain.setEndDateArrays[exerciseIndex].dates[roundIndex].isDefaultObject == NO){
                currentRoundEndDate = self.realizedChain.setEndDateArrays[exerciseIndex].dates[roundIndex].value;
            } else{
                currentRoundEndDate = nil;
            }
            
            if (self.realizedChain.setBeginDateArrays[[nextExerciseInd intValue]].dates[[nextRoundInd intValue]].isDefaultObject == NO){
                nextRoundBeginDate = self.realizedChain.setBeginDateArrays[[nextExerciseInd intValue]].dates[[nextRoundInd intValue]].value;
            } else{
                nextRoundBeginDate = nil;
            }
            
            // if both dates are not nil, then calculate the rest.  Otherwise, rest is X
            
            if (currentRoundEndDate && nextRoundBeginDate){
                
                float restTime = [nextRoundBeginDate timeIntervalSinceDate: currentRoundEndDate];
                restText = [[TJBStopwatch singleton] minutesAndSecondsStringFromNumberOfSeconds: (int)restTime];
                restText = [NSString stringWithFormat: @"%@ rest", restText];
                restLabel.text = restText;
                
            } else{
                
                restLabel.text = @"X rest";
                
            }
            
        } else{
            
            restLabel.text = @"";
            
        }
        
    } else{
        
        // this is the last round for this chain and the passed in 'finalRest' should be used
        
        restLabel.text = @"";  
        
    }
    
    NSArray *labels = @[weightLabel,
                        repsLabel,
                        restLabel];
    
    for (UILabel *label in labels){
        
        label.translatesAutoresizingMaskIntoConstraints = NO;
        
        [view addSubview: label];
        
        [label setTextColor: [UIColor blackColor]];
        [label setFont: [UIFont systemFontOfSize: 15.0]];
        label.textAlignment = NSTextAlignmentLeft;
        
    }
    
    NSDictionary *constraintMapping = [NSDictionary dictionaryWithObjects: @[weightLabel, repsLabel, restLabel]
                                                                  forKeys: @[@"weightLabel", @"repsLabel", @"restLabel"]];
    
    NSString *horizontal1 = @"H:|-32-[weightLabel]-0-[repsLabel(==weightLabel)]-0-[restLabel(==weightLabel)]-0-|";
    
    NSArray *horizontalConstraints1 = [NSLayoutConstraint constraintsWithVisualFormat: horizontal1
                                                                              options: 0
                                                                              metrics: nil
                                                                                views: constraintMapping];
    
    NSString *vertical1 = @"V:|-0-[restLabel]-0-|";
    NSString *vertical2 = @"V:|-0-[weightLabel]-0-|";
    NSString *vertical3 = @"V:|-0-[repsLabel]-0-|";
    
    
    NSArray *verticalConstraints1 = [NSLayoutConstraint constraintsWithVisualFormat: vertical1
                                                                            options: 0
                                                                            metrics: nil
                                                                              views: constraintMapping];
    
    NSArray *verticalConstraints2 = [NSLayoutConstraint constraintsWithVisualFormat: vertical2
                                                                            options: 0
                                                                            metrics: nil
                                                                              views: constraintMapping];
    
    NSArray *verticalConstraints3 = [NSLayoutConstraint constraintsWithVisualFormat: vertical3
                                                                            options: 0
                                                                            metrics: nil
                                                                              views: constraintMapping];
    
    [view addConstraints: horizontalConstraints1];
    [view addConstraints: verticalConstraints1];
    [view addConstraints: verticalConstraints2];
    [view addConstraints: verticalConstraints3];
    
    return view;
}

+ (float)suggestedCellHeightForRealizedChain:(TJBRealizedChain *)realizedChain{
    
    //// must manually configure the inputs as the xib is altered
    
    float numberOfExercises = (float)realizedChain.numberOfExercises;
    float numberOfRounds = (float)realizedChain.numberOfRounds;
    float titleHeight = 20.0;
    float spacing = 8.0;
    float error = 8.0;
    
    return (numberOfExercises * (numberOfRounds + 1.0) + 1.0) * titleHeight + spacing + error;
    
}



@end
