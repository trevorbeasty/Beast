//
//  TJBRealizedChainCell.m
//  Beast
//
//  Created by Trevor Beasty on 1/27/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBRealizedChainCell.h"

// core data

#import "CoreDataController.h"

// aesthetics

#import "TJBAestheticsController.h"

// utilites

#import "TJBAssortedUtilities.h"

// stopwatch

#import "TJBStopwatch.h"

@interface TJBRealizedChainCell ()

{
    
    // core
    
    TJBAdvancedCellType _cellType;
    TJBDateTimeType _dateTimeType;
    
}

// IBOutlet

@property (weak, nonatomic) IBOutlet UILabel *dateTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIView *columnHeaderContainer;
@property (weak, nonatomic) IBOutlet UILabel *columnHeader1Label;
@property (weak, nonatomic) IBOutlet UILabel *columnHeader2Label;
@property (weak, nonatomic) IBOutlet UILabel *columnHeader3Label;
@property (weak, nonatomic) IBOutlet UILabel *columnHeader4Label;
@property (weak, nonatomic) IBOutlet UILabel *firstExerciseLabel;

// core

@property (strong) id contentObject;
@property (strong) NSNumber *titleNumber;





@end

@implementation TJBRealizedChainCell

#pragma mark - Instantiation

- (void)configureWithContentObject:(id)contentObject cellType:(TJBAdvancedCellType)cellType dateTimeType:(TJBDateTimeType)dateTimeType titleNumber:(NSNumber *)titleNumber{
    
    self.contentObject = contentObject;
    self.titleNumber = titleNumber;
    _cellType = cellType;
    _dateTimeType = dateTimeType;
    
    [self configureBasicLabelText];
    [self configureViewAesthetics];
    
    
}

#pragma mark - View Helper Methods

- (void)configureViewAesthetics{
    
    // basic formatting
    
    self.dateTimeLabel.backgroundColor = [UIColor clearColor];
    self.dateTimeLabel.font = [UIFont systemFontOfSize: 12];
    self.dateTimeLabel.textColor = [UIColor blackColor];
    
    NSArray *titleLabels = @[self.numberTypeLabel, self.nameLabel];
    for (UILabel *label in titleLabels){
        
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize: 15];
        label.textColor = [UIColor blackColor];
        
    }
    
    self.columnHeaderContainer.backgroundColor = [UIColor clearColor];
    NSArray *columnHeaderLabels = @[self.columnHeader1Label,
                                    self.columnHeader2Label,
                                    self.columnHeader3Label,
                                    self.columnHeader4Label];
    for (UILabel *label in columnHeaderLabels){
        
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont systemFontOfSize: 12];
        label.textColor = [UIColor blackColor];
        
    }
    
    self.firstExerciseLabel.backgroundColor = [UIColor clearColor];
    self.firstExerciseLabel.textColor = [UIColor blackColor];
    self.firstExerciseLabel.font = [UIFont systemFontOfSize: 15];
    
}

- (void)configureBasicLabelText{
    
    // date time label
    
    NSDate *date = [self dateForContentObject];
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    
    switch (_dateTimeType) {
        case TJBDayInYear:
            df.dateFormat = @"MMM d, yyyy";
            break;
            
        case TJBTimeOfDay:
            df.dateFormat = @"HH:mm";
            break;
            
        default:
            break;
    }
    
    self.dateTimeLabel.text = [df stringFromDate: date];
    
    // number type label
    
    NSString *type = nil;
    
    switch (_cellType) {
        case ChainTemplateCell:
            type = @"Routine Template";
            break;
            
        case RealizedChainCell:
            type = @"Completed Routine";
            break;
            
        case RealizedSetCollectionCell:
            type = @"Freeform Lift";
            break;
            
        default:
            break;
    }
    
    NSString *ntString = [NSString stringWithFormat: @"%@ - %@",
                          [self.titleNumber stringValue],
                          type];
    self.numberTypeLabel.text = ntString;
    
    // name title label
    
    NSString *nameTitleText = [self titleNameForContentObject];
//    self.nameLabel.text = @"This is a test... I like to type really long things just cause and let's see what happens";
    self.nameLabel.text = nameTitleText;
    
    // headers
    
    self.columnHeader2Label.text = @"weight \n(lbs)";
    self.columnHeader3Label.text = @"reps";
    
    if (_cellType == ChainTemplateCell || _cellType == RealizedChainCell){
        
        self.columnHeader1Label.text = @"round #";
        self.columnHeader4Label.text = @"rest";
        
    } else{
        
        self.columnHeader1Label.text = @"set #";
        self.columnHeader4Label.hidden = YES;
        
    }
    
    // exercise #1 label
    
    TJBExercise *exercise = [self firstExercise];
    NSString *e1Text = [NSString stringWithFormat: @"Exercise #1: %@", exercise.name];
    self.firstExerciseLabel.text = e1Text;
    
}

#pragma mark - Content Object Access

- (TJBExercise *)firstExercise{
    
    return [self exerciseForExerciseIndex: 0];
    
}

- (TJBExercise *)exerciseForExerciseIndex:(int)exerciseIndex{
    
    TJBExercise *exercise;
    
    if (_cellType == RealizedChainCell){
        
        TJBRealizedChain *rc = self.contentObject;
        exercise = rc.chainTemplate.exercises[exerciseIndex];
        
    } else if (_cellType == ChainTemplateCell){
        
        TJBChainTemplate *ct = self.contentObject;
        exercise = ct.exercises[exerciseIndex];
        
    } else{
        
        TJBRealizedSetGrouping rsg = self.contentObject;
        TJBRealizedSet *rs = rsg[0];
        exercise = rs.exercise;
        
    }
    
    return exercise;
    
}

- (NSString *)titleNameForContentObject{
    
    NSString *name;
    
    if (_cellType == RealizedChainCell){
        
        TJBRealizedChain *rc = self.contentObject;
        name = rc.chainTemplate.name;
        
    } else if (_cellType == ChainTemplateCell){
        
        TJBChainTemplate *ct = self.contentObject;
        name = ct.name;
        
    } else{
        
        TJBRealizedSetGrouping rsg = self.contentObject;
        TJBRealizedSet *rs = rsg[0];
        name = rs.exercise.name;
        
    }
    
    return name;
    
}

- (NSDate *)dateForContentObject{
    
    NSDate *date = nil;
    
    if (_cellType == RealizedChainCell){
        
        TJBRealizedChain *rc = self.contentObject;
        date = rc.dateCreated;
        
    }
    
    return date;
    
}


#pragma mark - API

+ (float)suggestedCellHeightForRealizedChain:(TJBRealizedChain *)realizedChain{
    

    
    return 300;
 
}


- (void)clearExistingEntries{
    
    
    
    
}

@end














//- (void)configureWithRealizedChain:(TJBRealizedChain *)realizedChain number:(NSNumber *)number finalRest:(NSNumber *)finalRest referenceIndexPath:(NSIndexPath *)path{
//
//    //// this cell will be dynamically sized, showing the chain name in the main label and stacking another label for every exercise in the chain
//
//    self.realizedChain = realizedChain;
//    self.finalRest = finalRest;
//    self.referenceIndexPath = path;
//
//    TJBChainTemplate *chainTemplate = realizedChain.chainTemplate;
//
//    self.selectionStyle = UITableViewCellSelectionStyleNone;
//
//    [self configureViewAesthetics];
//
//    // configure the chain name label
//
//    NSString *numberText = [NSString stringWithFormat: @"%@. %@",
//                            [number stringValue],
//                            chainTemplate.name];
//    self.numberLabel.text = numberText;
//
//    NSDateFormatter *df = [[NSDateFormatter alloc] init];
//    df.dateStyle = NSDateFormatterNoStyle;
//    df.timeStyle = NSDateFormatterShortStyle;
//    self.dateLabel.text = [df stringFromDate: realizedChain.dateCreated];
//
//    //// configure the stack view.  For every exercise, create a UILabel and configure it before adding it to the stack view
//
//    int numExercises = chainTemplate.numberOfExercises;
//
//    for (int i = 0; i < numExercises; i++){
//
//        UIView *iterativeView = [self stackViewForExerciseIndex: i];
//
//        [self.stackView addArrangedSubview: iterativeView];
//
//    }
//
//    return;
//
//
//
//}
//
//- (void)configureViewAesthetics{
//
//    self.contentView.backgroundColor = [UIColor clearColor];
//
//    // labels
//
//    NSArray *mainLabels = @[self.numberLabel];
//    for (UILabel *label in mainLabels){
//
//        label.backgroundColor = [UIColor clearColor];
//        label.textColor = [UIColor blackColor];
//        label.font = [UIFont boldSystemFontOfSize: 15.0];
//
//    }
//
//    self.dateLabel.textColor = [UIColor blackColor];
//    self.dateLabel.backgroundColor = [UIColor clearColor];
//    self.dateLabel.font = [UIFont systemFontOfSize: 10.0];
//
//
//}
//
//- (UIStackView *)stackViewForExerciseIndex:(int)exerciseIndex{
//
//    UIStackView *stackView = [[UIStackView alloc] init];
//    stackView.axis = UILayoutConstraintAxisVertical;
//
//    int roundLimit = self.realizedChain.chainTemplate.numberOfRounds;
//
//    // exercise label
//
//    UILabel *exerciseLabel = [[UILabel alloc] init];
//    exerciseLabel.text = self.realizedChain.chainTemplate.exercises[exerciseIndex].name;
//    exerciseLabel.font = [UIFont systemFontOfSize: 15.0];
//    exerciseLabel.textColor = [UIColor blackColor];
//    exerciseLabel.textAlignment = NSTextAlignmentLeft;
//
//    [stackView addArrangedSubview: exerciseLabel];
//
//    for (int i = 0; i < roundLimit; i++){
//
//        UIView *iterativeView = [self roundSubviewForExerciseIndex: exerciseIndex
//                                                        roundIndex: i];
//
//        [stackView addArrangedSubview: iterativeView];
//
//    }
//
//    return stackView;
//
//}
//
//- (UIView *)roundSubviewForExerciseIndex:(int)exerciseIndex roundIndex:(int)roundIndex{
//
//    //// create the exercise name subview, which will have two labels - one for a number and one for a name
//
//    UIView *view = [[UIView alloc] init];
//
//    UILabel *weightLabel = [[UILabel alloc] init];
//    UILabel *repsLabel = [[UILabel alloc] init];
//    UILabel *restLabel = [[UILabel alloc] init];
//
//    BOOL roundHasBeenExecuted = [TJBAssortedUtilities indiceWithExerciseIndex: exerciseIndex
//                                                                   roundIndex: roundIndex
//                                              isPriorToReferenceExerciseIndex: self.realizedChain.firstIncompleteExerciseIndex
//                                                          referenceRoundIndex: self.realizedChain.firstIncompleteRoundIndex];
//
//    // weight and reps should be filled if this round was executed
//
//    if (roundHasBeenExecuted){
//
//        TJBRealizedSet *rs = self.realizedChain.realizedSetCollections[exerciseIndex].realizedSets[roundIndex];
//
//        float weight = rs.submittedWeight;
//        float reps = rs.submittedReps;
//
//        NSString *weightString = [NSString stringWithFormat: @"%.01f", weight];
//        NSString *repsString = [NSString stringWithFormat: @"%.01f", reps];
//
//        weightLabel.text = weightString;
//        repsLabel.text = repsString;
//
//    } else{
//
//        weightLabel.text = @"-";
//        repsLabel.text = @"";
//        restLabel.text = @"";
//
//    }
//
//    // rest should be filled depending upon if this round and the next were executed
//
//    NSNumber *nextExerciseInd = nil;
//    NSNumber *nextRoundInd = nil;
//    BOOL nextRoundWithinIndiceRange = [TJBAssortedUtilities nextIndiceValuesForCurrentExerciseIndex: exerciseIndex
//                                                                                   currentRoundIndex: roundIndex
//                                                                                    maxExerciseIndex: self.realizedChain.chainTemplate.numberOfExercises - 1
//                                                                                       maxRoundIndex: self.realizedChain.chainTemplate.numberOfRounds - 1
//                                                                              exerciseIndexReference: &nextExerciseInd
//                                                                                 roundIndexReference: &nextRoundInd];
//
//    if (nextRoundWithinIndiceRange){
//
//        BOOL nextRoundHasBeenExecuted = [TJBAssortedUtilities indiceWithExerciseIndex: [nextExerciseInd intValue]
//                                                                           roundIndex: [nextRoundInd intValue]
//                                                      isPriorToReferenceExerciseIndex: self.realizedChain.firstIncompleteExerciseIndex
//                                                                  referenceRoundIndex: self.realizedChain.firstIncompleteRoundIndex];
//
//        if (nextRoundHasBeenExecuted){
//
//            TJBTargetUnit *tu = self.realizedChain.chainTemplate.targetUnitCollections[exerciseIndex].targetUnits[roundIndex];
//
//            if (tu.isTargetingTrailingRest == YES){
//
//                NSString *restText = [[TJBStopwatch singleton] minutesAndSecondsStringFromNumberOfSeconds: (int)tu.trailingRestTarget];
//                restLabel.text = restText;
//
//            } else{
//
//                restLabel.text = @"";
//
//            }
//
//        } else{
//
//            restLabel.text = @"";
//
//        }
//
//    } else{
//
//        restLabel.text = @"";
//
//    }
//
//
//    NSArray *labels = @[weightLabel,
//                        repsLabel,
//                        restLabel];
//
//    for (UILabel *label in labels){
//
//        label.translatesAutoresizingMaskIntoConstraints = NO;
//        label.backgroundColor = [UIColor clearColor];
//
//        [view addSubview: label];
//
//        [label setTextColor: [UIColor blackColor]];
//        [label setFont: [UIFont systemFontOfSize: 15.0]];
//        label.textAlignment = NSTextAlignmentLeft;
//
//    }
//
//    NSDictionary *constraintMapping = [NSDictionary dictionaryWithObjects: @[weightLabel, repsLabel, restLabel]
//                                                                  forKeys: @[@"weightLabel", @"repsLabel", @"restLabel"]];
//
//    NSString *horizontal1 = @"H:|-32-[weightLabel]-0-[repsLabel(==weightLabel)]-0-[restLabel(==weightLabel)]-0-|";
//
//    NSArray *horizontalConstraints1 = [NSLayoutConstraint constraintsWithVisualFormat: horizontal1
//                                                                              options: 0
//                                                                              metrics: nil
//                                                                                views: constraintMapping];
//
//    NSString *vertical1 = @"V:|-0-[restLabel]-0-|";
//    NSString *vertical2 = @"V:|-0-[weightLabel]-0-|";
//    NSString *vertical3 = @"V:|-0-[repsLabel]-0-|";
//
//
//    NSArray *verticalConstraints1 = [NSLayoutConstraint constraintsWithVisualFormat: vertical1
//                                                                            options: 0
//                                                                            metrics: nil
//                                                                              views: constraintMapping];
//
//    NSArray *verticalConstraints2 = [NSLayoutConstraint constraintsWithVisualFormat: vertical2
//                                                                            options: 0
//                                                                            metrics: nil
//                                                                              views: constraintMapping];
//
//    NSArray *verticalConstraints3 = [NSLayoutConstraint constraintsWithVisualFormat: vertical3
//                                                                            options: 0
//                                                                            metrics: nil
//                                                                              views: constraintMapping];
//
//    [view addConstraints: horizontalConstraints1];
//    [view addConstraints: verticalConstraints1];
//    [view addConstraints: verticalConstraints2];
//    [view addConstraints: verticalConstraints3];
//
//    return view;
//}


























