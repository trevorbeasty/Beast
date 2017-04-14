//
//  TJBRealizedChainCell.m
//  Beast
//
//  Created by Trevor Beasty on 1/27/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBRealizedChainCell.h"



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
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIView *columnHeaderContainer;
@property (weak, nonatomic) IBOutlet UILabel *columnHeader1Label;
@property (weak, nonatomic) IBOutlet UILabel *columnHeader2Label;
@property (weak, nonatomic) IBOutlet UILabel *columnHeader3Label;
@property (weak, nonatomic) IBOutlet UILabel *columnHeader4Label;
@property (weak, nonatomic) IBOutlet UILabel *firstExerciseLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;

// core

@property (strong) id contentObject;
@property (strong) NSNumber *titleNumber;

// layout

@property (strong) NSMutableDictionary *constraintMapping;




@end

// layout constants

static CGFloat const rowHeight = 30;
static CGFloat const topSpacing = 8;
static CGFloat const bottomSpacing = 16;
static CGFloat const leadingSpace = 36;
static CGFloat const trailingSpace = 8;
static CGFloat const interimVertRowSpacing = 0;
static CGFloat const interimHorzRowSpacing = 0;
static CGFloat const exerciseLeadingSpace = 8;


typedef enum{
    TJBRoundType,
    TJBWeightType,
    TJBRepsType,
    TJBRestType
}TJBDynamicLabelType;


@implementation TJBRealizedChainCell

#pragma mark - Main Method

- (void)configureWithContentObject:(id)contentObject cellType:(TJBAdvancedCellType)cellType dateTimeType:(TJBDateTimeType)dateTimeType titleNumber:(NSNumber *)titleNumber{
    
    self.contentObject = contentObject;
    self.titleNumber = titleNumber;
    _cellType = cellType;
    _dateTimeType = dateTimeType;
    
    [self configureBasicLabelText];
    [self configureViewAesthetics];
    [self createAndLayoutDynamicContent];
    
    return;
    
}


#pragma mark - Dynamic Content

- (void)createAndLayoutDynamicContent{
    
    // views are stacked from top to bottom.  It is thus necessary that new views know which view they should position themselves beneath.  This communication is achieved via the currentTopView
    
    self.constraintMapping = [[NSMutableDictionary alloc] init];
    [self.constraintMapping setObject: self.firstExerciseLabel
                               forKey: @"initialTopView"];
    UIView *currentTopView = self.firstExerciseLabel;
    
    if (_cellType == RealizedChainCell){
        
        TJBRealizedChain *rc = self.contentObject;
        
        for (int i = 0; i < rc.chainTemplate.numberOfExercises; i++){
            
            for (int j = 0; j < rc.chainTemplate.numberOfRounds; j++){
                
                currentTopView = [self addContentRowCorrespondingToExerciseIndex: i
                                                                      roundIndex: j
                                                                  currentTopView: currentTopView
                                                                   maxRoundIndex: rc.chainTemplate.numberOfRounds - 1];
                
            }
            
            // an entire row section has just been added (corresponding to an exercise)
            // now an exercise label must be created before creating the next row section
            // do not create an exercise label if at the max exercise index
            
            BOOL atMaxExerciseIndex = i == rc.chainTemplate.numberOfExercises - 1;
            
            if (atMaxExerciseIndex == NO){
                
                currentTopView = [self addContentExerciseLabelCorrespondingToExerciseIndex: i + 1
                                                                            currentTopView: currentTopView];
                
            }
        }
        
    } else if (_cellType == ChainTemplateAdvCell){
        
        TJBChainTemplate *ct = self.contentObject;
        
        for (int i = 0; i < ct.numberOfExercises; i++){
            
            for (int j = 0; j < ct.numberOfRounds; j++){
                
                currentTopView = [self addContentRowCorrespondingToExerciseIndex: i
                                                                      roundIndex: j
                                                                  currentTopView: currentTopView
                                                                   maxRoundIndex: ct.numberOfRounds - 1];
                
            }
            
            // an entire row section has just been added (corresponding to an exercise)
            // now an exercise label must be created before creating the next row section
            // do not create an exercise label if at the max exercise index
            
            BOOL atMaxExerciseIndex = i == ct.numberOfExercises - 1;
            
            if (atMaxExerciseIndex == NO){
                
                currentTopView = [self addContentExerciseLabelCorrespondingToExerciseIndex: i + 1
                                                                            currentTopView: currentTopView];
                
            }
        }

    } else{
        
        // this class accepts both TJBRealizedSetGrouping and TJBRealizedSet; must check for type
        
        if ([self.contentObject isKindOfClass: [NSArray class]]){
            
            TJBRealizedSetGrouping rsg = self.contentObject;
            
            for (int i = 0; i < rsg.count; i++){
             
               currentTopView = [self addContentRowCorrespondingToExerciseIndex: 0
                                                                     roundIndex: i
                                                                 currentTopView: currentTopView
                                                                  maxRoundIndex: (int)rsg.count - 1];
                
            }
            
        } else{
            
            [self addContentRowCorrespondingToExerciseIndex: 0
                                                 roundIndex: 0
                                             currentTopView: currentTopView
                                              maxRoundIndex: 0];
            
        }
        
    }
    
    
    
}

- (UIView *)addContentExerciseLabelCorrespondingToExerciseIndex:(int)exerciseIndex currentTopView:(UIView *)currentTopView{
    
    NSString *topViewKey = [self.constraintMapping allKeysForObject: currentTopView][0];
    
    UILabel *exerciseLabel = [[UILabel alloc] init];
    NSString *exerciseUniqueID = [NSString stringWithFormat: @"exercise%d", exerciseIndex];
    [self.constraintMapping setObject: exerciseLabel
                               forKey: exerciseUniqueID];
    [self.contentView addSubview: exerciseLabel];
    
    exerciseLabel.translatesAutoresizingMaskIntoConstraints = NO;
    NSString *exerciseVertVFL = [NSString stringWithFormat: @"V:[%@]-%f-[%@]",
                                 topViewKey,
                                 bottomSpacing,
                                 exerciseUniqueID];
    
    [self.contentView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: exerciseVertVFL
                                                                              options: 0
                                                                              metrics: nil
                                                                                views: self.constraintMapping]];
    NSString *exerciseHorzVFL = [NSString stringWithFormat: @"H:|-%f-[%@]",
                              exerciseLeadingSpace,
                              exerciseUniqueID];
    
    [self.contentView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: exerciseHorzVFL
                                                                              options: 0
                                                                              metrics: nil
                                                                                views: self.constraintMapping]];
    
    TJBExercise *exercise = [self exerciseForExerciseIndex: exerciseIndex];
    NSString *exerciseLabelText = [NSString stringWithFormat: @"Exercise #%d: %@",
                                   exerciseIndex + 1,
                                   exercise.name];
    exerciseLabel.text = exerciseLabelText;
    
    [self configureExerciseLabel: exerciseLabel];
    
    return exerciseLabel;
    
}


- (UIView *)addContentRowCorrespondingToExerciseIndex:(int)exerciseIndex roundIndex:(int)roundIndex currentTopView:(UIView *)currentTopView maxRoundIndex:(int)maxRoundIndex{
    
    BOOL isTopRow = roundIndex == 0;
    BOOL isBottomRow = roundIndex == maxRoundIndex;
    
    NSString *topViewKey = [self.constraintMapping allKeysForObject: currentTopView][0];
    
    // round / set #
    
    UILabel *roundLabel = [[UILabel alloc] init];
    NSString *roundUniqueID = [NSString stringWithFormat: @"roundLabel%d%d", exerciseIndex, roundIndex];
    [self.constraintMapping setObject: roundLabel
                          forKey: roundUniqueID];
    [self.contentView addSubview: roundLabel];
    
    roundLabel.translatesAutoresizingMaskIntoConstraints = NO;
    NSString *roundVertVFL = [self verticalConstraintVFLForTopViewKey: topViewKey
                                                     bottomViewKey: roundUniqueID
                                               isFirstRowInSection: isTopRow];
    [self.contentView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: roundVertVFL
                                                                              options: 0
                                                                              metrics: nil
                                                                                views: self.constraintMapping]];
    NSString *roundHorzVFL = [self horizontalConstraintVFLForLeftViewKey: nil
                                                         rightViewKey: roundUniqueID
                                                        isLeadingView: YES
                                                       isTrailingView: NO];
    [self.contentView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: roundHorzVFL
                                                                              options: 0
                                                                              metrics: nil
                                                                                views: self.constraintMapping]];
    
    // weight
    
    UILabel *weightLabel = [[UILabel alloc] init];
    NSString *weightUniqueID = [NSString stringWithFormat: @"weightLabel%d%d", exerciseIndex, roundIndex];
    [self.constraintMapping setObject: weightLabel
                               forKey: weightUniqueID];
    [self.contentView addSubview: weightLabel];
    
    weightLabel.translatesAutoresizingMaskIntoConstraints = NO;
    NSString *weightVertVFL = [self verticalConstraintVFLForTopViewKey: topViewKey
                                                     bottomViewKey: weightUniqueID
                                               isFirstRowInSection: isTopRow];
    [self.contentView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: weightVertVFL
                                                                              options: 0
                                                                              metrics: nil
                                                                                views: self.constraintMapping]];
    NSString *weightHorzVFL = [self horizontalConstraintVFLForLeftViewKey: roundUniqueID
                                                         rightViewKey: weightUniqueID
                                                        isLeadingView: NO
                                                       isTrailingView: NO];
    [self.contentView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: weightHorzVFL
                                                                              options: 0
                                                                              metrics: nil
                                                                                views: self.constraintMapping]];

    // reps
    
    UILabel *repsLabel = [[UILabel alloc] init];
    NSString *repsUniqueID = [NSString stringWithFormat: @"repsLabel%d%d", exerciseIndex, roundIndex];
    [self.constraintMapping setObject: repsLabel
                               forKey: repsUniqueID];
    [self.contentView addSubview: repsLabel];
    
    repsLabel.translatesAutoresizingMaskIntoConstraints = NO;
    NSString *repsVertVFL = [self verticalConstraintVFLForTopViewKey: topViewKey
                                                         bottomViewKey: repsUniqueID
                                                   isFirstRowInSection: isTopRow];
    [self.contentView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: repsVertVFL
                                                                              options: 0
                                                                              metrics: nil
                                                                                views: self.constraintMapping]];
    NSString *repsHorzVFL = [self horizontalConstraintVFLForLeftViewKey: weightUniqueID
                                                             rightViewKey: repsUniqueID
                                                            isLeadingView: NO
                                                           isTrailingView: NO];
    [self.contentView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: repsHorzVFL
                                                                              options: 0
                                                                              metrics: nil
                                                                                views: self.constraintMapping]];

    // rest
    
    UILabel *restLabel = [[UILabel alloc] init];
    NSString *restUniqueID = [NSString stringWithFormat: @"restLabel%d%d", exerciseIndex, roundIndex];
    [self.constraintMapping setObject: restLabel
                               forKey: restUniqueID];
    [self.contentView addSubview: restLabel];
    
    restLabel.translatesAutoresizingMaskIntoConstraints = NO;
    NSString *restVertVFL = [self verticalConstraintVFLForTopViewKey: topViewKey
                                                       bottomViewKey: restUniqueID
                                                 isFirstRowInSection: isTopRow];
    [self.contentView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: restVertVFL
                                                                              options: 0
                                                                              metrics: nil
                                                                                views: self.constraintMapping]];
    NSString *restHorzVFL = [self horizontalConstraintVFLForLeftViewKey: repsUniqueID
                                                           rightViewKey: restUniqueID
                                                          isLeadingView: NO
                                                         isTrailingView: YES];
    [self.contentView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: restHorzVFL
                                                                              options: 0
                                                                              metrics: nil
                                                                                views: self.constraintMapping]];
    
    // must forcibly layout views before attempting to add borders
    
    [self.contentView layoutSubviews];
    
    [self configureLabelAestheticsAndContent: roundLabel
                    isLeadingLabel: YES
                   isTrailingLabel: NO
                          isTopRow: isTopRow
                       isBottomRow: isBottomRow
                     exerciseIndex: exerciseIndex
                        roundIndex: roundIndex
                  dynamicLabelType: TJBRoundType];
    
    [self configureLabelAestheticsAndContent: weightLabel
                    isLeadingLabel: NO
                   isTrailingLabel: NO
                          isTopRow: isTopRow
                       isBottomRow: isBottomRow
                     exerciseIndex: exerciseIndex
                        roundIndex: roundIndex
                  dynamicLabelType: TJBWeightType];
    
    [self configureLabelAestheticsAndContent: repsLabel
                    isLeadingLabel: NO
                   isTrailingLabel: NO
                          isTopRow: isTopRow
                       isBottomRow: isBottomRow
                     exerciseIndex: exerciseIndex
                        roundIndex: roundIndex
                  dynamicLabelType: TJBRepsType];
    
    [self configureLabelAestheticsAndContent: restLabel
                    isLeadingLabel: NO
                   isTrailingLabel: YES
                          isTopRow: isTopRow
                       isBottomRow: isBottomRow
                     exerciseIndex: exerciseIndex
                        roundIndex: roundIndex
                  dynamicLabelType: TJBRestType];
    
    return  roundLabel;
    
}

- (NSString *)horizontalConstraintVFLForLeftViewKey:(NSString *)leftViewKey rightViewKey:(NSString *)rightViewKey isLeadingView:(BOOL)isLeadingView isTrailingView:(BOOL)isTrailingView{
    
    float horzSpacing = isLeadingView ? leadingSpace : interimHorzRowSpacing;
    
    NSString *horzVFLStr;
    
    if (isLeadingView){
        
        horzVFLStr = [NSString stringWithFormat: @"H:|-%f-[%@]",
                      horzSpacing,
                      rightViewKey];
        
    } else if (isTrailingView){
        
        horzVFLStr = [NSString stringWithFormat: @"H:[%@]-%f-[%@(==%@)]-%f-|",
                      leftViewKey,
                      horzSpacing,
                      rightViewKey,
                      leftViewKey,
                      trailingSpace];
        
    } else{
        
        horzVFLStr = [NSString stringWithFormat: @"H:[%@]-%f-[%@(==%@)]",
                      leftViewKey,
                      horzSpacing,
                      rightViewKey,
                      leftViewKey];
        
    }

    return horzVFLStr;
    
}

- (NSString *)verticalConstraintVFLForTopViewKey:(NSString *)topViewKey bottomViewKey:(NSString *)bottomViewKey isFirstRowInSection:(BOOL)isFirstRowInSection{
    
    float vertSpacing = isFirstRowInSection ? topSpacing : interimVertRowSpacing;
    
    NSString *vertVFLStr = [NSString stringWithFormat: @"V:[%@]-%f-[%@(==%f)]",
                            topViewKey,
                            vertSpacing,
                            bottomViewKey,
                            rowHeight];
    
    return vertVFLStr;
    
}

#pragma mark - Dynamic Content Aesthetics

- (void)configureLabelAestheticsAndContent:(UILabel *)label isLeadingLabel:(BOOL)isLeadingLabel isTrailingLabel:(BOOL)isTrailingLabel isTopRow:(BOOL)isTopRow isBottomRow:(BOOL)isBottomRow exerciseIndex:(int)exerciseIndex roundIndex:(int)roundIndex dynamicLabelType:(TJBDynamicLabelType)dynamicLabelType{
    
    // common aesthetics
    
    label.font = [UIFont systemFontOfSize: 15];
    label.backgroundColor = [UIColor clearColor];
    label.textColor = [UIColor blackColor];
    label.textAlignment = NSTextAlignmentCenter;
    
    // borders
    
    if (isTrailingLabel == NO){
        
        [self addVerticalBorderToRight: label
                             thickness: .5];
        
    }
    
    if (isBottomRow == NO){
        
        [self addHorizontalBorderBeneath: label
                               thickness: .5];
        
    }

    
    // for realized sets and realized set grouping, the rest label is blank
    
    if (dynamicLabelType == RealizedSetCollectionCell && dynamicLabelType == TJBRestType){
        
        label.text = @"";
        
        return;
        
    }
    
    NSNumber *number = [self numberForExerciseIndex: exerciseIndex
                                         roundIndex: roundIndex
                                   dynamicLabelType: dynamicLabelType];
    NSString *text;
    
    if ([number intValue] == -1){
        
        text = @"-";
        
    } else if (number == nil){
        
        text = @"X";
        
    } else{
        
        if (dynamicLabelType == TJBRestType){
            
            text = [[TJBStopwatch singleton] minutesAndSecondsStringFromNumberOfSeconds: [number intValue]];
            
        } else{
            
            text = [number stringValue];
            
        }
        
    }

    label.text = text;
    
    
}


#pragma mark - View Helper Methods

- (void)configureViewAesthetics{
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // basic formatting
    
    self.dateTimeLabel.backgroundColor = [UIColor clearColor];
    self.dateTimeLabel.font = [UIFont systemFontOfSize: 15];
    self.dateTimeLabel.textColor = [UIColor blackColor];
    
    self.titleNumberLabel.font = [UIFont systemFontOfSize: 40];
    self.titleNumberLabel.backgroundColor = [UIColor clearColor];
    self.titleNumberLabel.textColor = [UIColor blackColor];
    
    NSArray *titleLabels = @[self.typeLabel, self.nameLabel];
    for (UILabel *label in titleLabels){
        
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize: 20];
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
        label.textAlignment = NSTextAlignmentCenter;
        
    }
    
    [self configureExerciseLabel: self.firstExerciseLabel];
    
    // detail drawing
    
    [self.contentView layoutSubviews]; // must be called, otherwise the dimensions of the xib file and not the 'dimensions with layout applied' will be used
    
    NSArray *verticalDividerLabels = @[self.columnHeader1Label,
                                       self.columnHeader2Label,
                                       self.columnHeader3Label];
    for (UILabel *lab in verticalDividerLabels){
        
        [self drawVerticalDividerToRightOfLabel: lab
                               horizontalOffset: 0
                                      thickness: 1
                                 verticalOffset: 7.5];
        
    }
    
    [self drawHookLineUnderLabel1: self.titleNumberLabel
                           label2: self.nameLabel
                   verticalOffset: 2
                        thickness: 1
                       hookLength: 16];
    [self drawHookLineUnderLabel1: self.titleNumberLabel
                           label2: self.nameLabel
                   verticalOffset: 5
                        thickness: 1
                       hookLength: 16];
    
}

- (void)configureExerciseLabel:(UILabel *)label{
    
    label.backgroundColor = [UIColor clearColor];
    label.font = [UIFont boldSystemFontOfSize: 15];
    label.textColor = [UIColor blackColor];
    
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
        case ChainTemplateAdvCell:
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
    
    self.titleNumberLabel.text = [self.titleNumber stringValue];
    self.typeLabel.text = type;
    
    // name title label
    
    NSString *nameTitleText = [self titleNameForContentObject];
//    self.nameLabel.text = @"This is a test... I like to type really long things just cause and let's see what happens";
    self.nameLabel.text = nameTitleText;
    
    // headers
    
    self.columnHeader2Label.text = @"weight \n(lbs)";
    self.columnHeader3Label.text = @"reps";
    
    if (_cellType == ChainTemplateAdvCell || _cellType == RealizedChainCell){
        
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

- (NSNumber *)numberForExerciseIndex:(int)exerciseIndex roundIndex:(int)roundIndex dynamicLabelType:(TJBDynamicLabelType)dynamicLabelType{
    
    // return -1 if the element is part of an incomplete realized set (will show '-')
    // return nil if the element is not being targeted (will show 'X')

    if (dynamicLabelType == TJBRoundType){ // no advanced logic is needed for the round number, which is simply always the round number
        
        return  @(roundIndex + 1);
        
    }
    
    NSNumber *number;
    
    if (_cellType == RealizedChainCell){
        
        TJBRealizedChain *rc = self.contentObject;
       
        number = [self numberForRealizedChain: rc
                             dynamicLabelType: dynamicLabelType
                                exerciseIndex: exerciseIndex
                                   roundIndex: roundIndex];
        
    } else if (_cellType == ChainTemplateAdvCell){
        
        TJBChainTemplate *ct = self.contentObject;
        TJBTargetUnit *tu = ct.targetUnitCollections[exerciseIndex].targetUnits[roundIndex];
        
        switch (dynamicLabelType){
            case TJBWeightType:
                if (tu.isTargetingWeight == YES){
                    number = @(tu.weightTarget);
                }
                break;
                
            case TJBRepsType:
                if (tu.isTargetingReps == YES){
                    number = @(tu.repsTarget);
                }
                break;
                
            case TJBRestType:
                if (tu.isTargetingTrailingRest == YES){
                    number = @(tu.trailingRestTarget);
                }
                
            default:
                break;
        }
        
    } else{
        
        // this class accepts both TJBRealizedSetGrouping and TJBRealizedSet; must check for type
        
        if ([self.contentObject isKindOfClass: [NSArray class]]){
            
            TJBRealizedSetGrouping rsg = self.contentObject;
            TJBRealizedSet *rs = rsg[roundIndex];

            number = [self numberForRealizedSet: rs
                               dynamicLabelType: dynamicLabelType];
            
        } else{
            
            TJBRealizedSet *rs = self.contentObject;
            
            number = [self numberForRealizedSet: rs
                               dynamicLabelType: dynamicLabelType];
            
        }
        
    }
    
    return number;
    
}

- (NSNumber *)numberForRealizedSet:(TJBRealizedSet *)rs dynamicLabelType:(TJBDynamicLabelType)dlt{
    
    NSNumber *number;
    
    if (rs.holdsNullValues == YES){
        
        number = @(-1);
        
    } else{
        
        // the switch does not account for TJBRestType because realized sets have @"" as their text
        // the preceeding logic is structured such that this method should never be called for a realized set's rest label
        
        switch (dlt){
            case TJBWeightType:
                number = @(rs.submittedWeight);
                break;
                
            case TJBRepsType:
                number = @(rs.submittedReps);
                break;
                
            default:
                break;
        }
    }
    
    return number;
    
}

- (NSNumber *)numberForRealizedChain:(TJBRealizedChain *)rc dynamicLabelType:(TJBDynamicLabelType)dlt exerciseIndex:(int)exerciseIndex roundIndex:(int)roundIndex{
    
    NSNumber *number;
    
    TJBRealizedSet *rs = rc.realizedSetCollections[exerciseIndex].realizedSets[roundIndex];
    TJBTargetUnit *tu = rc.chainTemplate.targetUnitCollections[exerciseIndex].targetUnits[roundIndex];
    
    if (rs.holdsNullValues == YES){
        
        number = @(-1);
        
    } else{
        
        switch (dlt){
            case TJBWeightType:
                number = @(rs.submittedWeight);
                break;
                
            case TJBRepsType:
                number = @(rs.submittedReps);
                break;
                
            case TJBRestType:
                number = @(tu.trailingRestTarget);
                break;
                
            default:
                break;
        }
    }
    
    return number;
    
}

- (TJBExercise *)firstExercise{
    
    return [self exerciseForExerciseIndex: 0];
    
}

- (TJBExercise *)exerciseForExerciseIndex:(int)exerciseIndex{
    
    TJBExercise *exercise;
    
    if (_cellType == RealizedChainCell){
        
        TJBRealizedChain *rc = self.contentObject;
        exercise = rc.chainTemplate.exercises[exerciseIndex];
        
    } else if (_cellType == ChainTemplateAdvCell){
        
        TJBChainTemplate *ct = self.contentObject;
        exercise = ct.exercises[exerciseIndex];
        
    } else{
        
        if ([self.contentObject isKindOfClass: [NSArray class]]){
            
            TJBRealizedSetGrouping rsg = self.contentObject;
            TJBRealizedSet *rs = rsg[0];
            exercise = rs.exercise;
            
        } else{
            
            TJBRealizedSet *rs = self.contentObject;
            exercise = rs.exercise;
            
        }
        

        
    }
    
    return exercise;
    
}

- (NSString *)titleNameForContentObject{
    
    NSString *name;
    
    if (_cellType == RealizedChainCell){
        
        TJBRealizedChain *rc = self.contentObject;
        name = rc.chainTemplate.name;
        
    } else if (_cellType == ChainTemplateAdvCell){
        
        TJBChainTemplate *ct = self.contentObject;
        name = ct.name;
        
    } else{
        
        if ([self.contentObject isKindOfClass: [NSArray class]]){
            
            TJBRealizedSetGrouping rsg = self.contentObject;
            TJBRealizedSet *rs = rsg[0];
            name = rs.exercise.name;
            
        } else{
            
            TJBRealizedSet *rs = self.contentObject;
            name = rs.exercise.name;
            
        }
        
    }
    
    return name;
    
}

- (NSDate *)dateForContentObject{
    
    NSDate *date = nil;
    
    if (_cellType == RealizedChainCell){
        
        TJBRealizedChain *rc = self.contentObject;
        date = rc.dateCreated;
        
    } else if (_cellType == ChainTemplateAdvCell){
        
        TJBChainTemplate *ct = self.contentObject;
        date = ct.dateCreated;
        
    } else{
        
        if ([self.contentObject isKindOfClass: [NSArray class]]){
            
            TJBRealizedSetGrouping rsg = self.contentObject;
            date = rsg[0].submissionTime;
            
        } else{
            
            TJBRealizedSet *rs = self.contentObject;
            date = rs.submissionTime;
            
        }
        
    }
    
    return date;
    
}

#pragma mark - Detailed Drawing

- (void)addVerticalBorderToRight:(UILabel *)label thickness:(CGFloat)thickness{
    
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
    
    [self.contentView.layer addSublayer: sl];
    
}

- (void)addHorizontalBorderBeneath:(UILabel *)label thickness:(CGFloat)thickness{
    
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
    
    [self.contentView.layer addSublayer: sl];
    
}

- (void)drawHookLineUnderLabel1:(UILabel *)label1 label2:(UILabel *)label2 verticalOffset:(CGFloat)vertOff thickness:(CGFloat)thickness hookLength:(CGFloat)hookLength{
    
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
    
    CGPoint startPoint = CGPointMake(label1.frame.origin.x, label2.frame.origin.y + label2.frame.size.height + vertOff);
    CGPoint interimPoint = CGPointMake(label2.frame.origin.x + label2.frame.size.width, startPoint.y);
    CGPoint endPoint = CGPointMake(interimPoint.x + hookLength,  interimPoint.y - hookLength);
    
    UIBezierPath *bp = [[UIBezierPath alloc] init];
    [bp moveToPoint: startPoint];
    [bp addLineToPoint: interimPoint];
    [bp addLineToPoint: endPoint];
    
    sl.path = bp.CGPath;
    
    // label layer
    
    [self.contentView.layer addSublayer: sl];
    
}

- (void)drawVerticalDividerToRightOfLabel:(UILabel *)label horizontalOffset:(CGFloat)horOff thickness:(CGFloat)thickness verticalOffset:(CGFloat)vertOff{
    
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
    
    CGPoint topRightCorner = CGPointMake(labelOrigin.x + labelSize.width, labelOrigin.y);
    CGPoint bottomRightCorner = CGPointMake(topRightCorner.x, topRightCorner.y + labelSize.height);
    
    CGPoint startPoint = CGPointMake(topRightCorner.x + horOff, topRightCorner.y + vertOff);
    CGPoint endPoint = CGPointMake(bottomRightCorner.x + horOff,  bottomRightCorner.y - vertOff);
    
    UIBezierPath *bp = [[UIBezierPath alloc] init];
    [bp moveToPoint: startPoint];
    [bp addLineToPoint: endPoint];
    
    sl.path = bp.CGPath;
    
    // label layer
    
    [self.columnHeaderContainer.layer addSublayer: sl];
    
}

- (void)drawVerticalDividerToLeftOfLabel:(UILabel *)label horizontalOffset:(CGFloat)horOff thickness:(CGFloat)thickness verticalOffset:(CGFloat)vertOff{
    
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
    
    [self.columnHeaderContainer.layer addSublayer: sl];
    
}


#pragma mark - Prescribed Cell Height

+ (float)suggestedHeightForRealizedSet{
    
    CGFloat remainingHeight = rowHeight + topSpacing;
    
    return  [self estimatedHeaderHeightPlusBreatherRoom] + remainingHeight;
    
}

+ (float)suggestedHeightForRealizedSetGrouping:(TJBRealizedSetGrouping)rsg{
    
    CGFloat remainingHeight =  (rsg.count - 1) * interimVertRowSpacing + rsg.count * rowHeight + topSpacing;
    
    return remainingHeight + [self estimatedHeaderHeightPlusBreatherRoom];
    
}

+ (float)suggestedCellHeightForRealizedChain:(TJBRealizedChain *)realizedChain{
    
    TJBChainTemplate *ct = realizedChain.chainTemplate;
    
    return  [self heightForChainTemplate: ct];
    

    
}

+ (float)suggestedCellHeightForChainTemplate:(TJBChainTemplate *)chainTemplate{
    
    return [self heightForChainTemplate: chainTemplate];
    
}

+ (float)heightForChainTemplate:(TJBChainTemplate *)ct{
    
    CGFloat remainingHeight = ct.numberOfExercises * (((ct.numberOfRounds - 1) * interimVertRowSpacing) + ct.numberOfRounds * rowHeight + topSpacing) + (ct.numberOfExercises - 1) * (25 + bottomSpacing);
    
    return remainingHeight + [self estimatedHeaderHeightPlusBreatherRoom];
    
}

+ (float)estimatedHeaderHeightPlusBreatherRoom{
    
    // I assume labels with intrinsic content sizes determining heights are 25 tall
    
    CGFloat estimatedHeaderAreaHeight = 137;
    CGFloat breatherRoom = 32;
    
    return  estimatedHeaderAreaHeight + breatherRoom;
    
}

#pragma mark - Clear Content

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


























