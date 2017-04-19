//
//  TJBActiveRoutineExerciseItemVC.m
//  Beast
//
//  Created by Trevor Beasty on 2/10/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBActiveRoutineExerciseItemVC.h"

#import "TJBAestheticsController.h" // aesthetics
#import "TJBPreviousMarksDictionary.h" // previous marks

@interface TJBActiveRoutineExerciseItemVC () 

// IBOutlet

@property (weak, nonatomic) IBOutlet UILabel *titleExerciseLabel;
@property (weak, nonatomic) IBOutlet UILabel *targetWeightLabel;
@property (weak, nonatomic) IBOutlet UILabel *targetRepsLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UILabel *previousEntriesLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *weightLabel;
@property (weak, nonatomic) IBOutlet UILabel *repsLabel;
@property (weak, nonatomic) IBOutlet UIStackView *contentStackView;

@property (weak, nonatomic) IBOutlet UIView *headerAreaContainer;
@property (weak, nonatomic) IBOutlet UIView *metaContainer;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *stackViewHeight;


// core

@property (nonatomic, strong) NSString *titleNumber;
@property (nonatomic, strong) NSString *targetExerciseName;
@property (nonatomic, strong) NSString *targetWeight;
@property (nonatomic, strong) NSString *targetReps;
@property (nonatomic, strong) NSArray<TJBPreviousMarksDictionary *> *previousEntries;


@end


#pragma mark - Constants

static CGFloat const rowHeight = 30;
static CGFloat const rowSpacing = .5;






@implementation TJBActiveRoutineExerciseItemVC

#pragma mark - Instantiation

- (instancetype)initWithTitleNumber:(NSString *)titleNumber targetExerciseName:(NSString *)targetExerciseName targetWeight:(NSString *)targetWeight targetReps:(NSString *)targetReps previousEntries:(NSArray<TJBPreviousMarksDictionary *> *)previousEntries{
    
    self = [super init];
    
    self.titleNumber = titleNumber;
    self.targetExerciseName = targetExerciseName;
    self.targetWeight = targetWeight;
    self.targetReps = targetReps;
    self.previousEntries = previousEntries;
    
    return self;
    
}

#pragma mark - View Life Cycle

- (void)viewDidLoad{
    
    [self configureViewData];
    
    [self configureStackView];
    
    [self configureViewAesthetics];
    
    [self createStackViewContent];
    
}

#pragma mark - View Helper Methods

- (void)configureStackView{
    
    self.contentStackView.distribution = UIStackViewDistributionFillEqually;
    self.contentStackView.backgroundColor = [UIColor clearColor];
    self.contentStackView.spacing = rowSpacing;
    
    float numberOfRows = (float)self.previousEntries.count;
    self.stackViewHeight.constant = numberOfRows * rowHeight + (numberOfRows - 1.0) * rowSpacing;
    
}


- (void)configureViewAesthetics{
    
    [self.view layoutSubviews];
    
    // meta view
    
    self.view.backgroundColor = [UIColor clearColor];
    self.headerAreaContainer.backgroundColor = [UIColor blackColor];
    self.metaContainer.backgroundColor = [UIColor clearColor];
    
    CALayer *metaContainerLayer = self.metaContainer.layer;
    metaContainerLayer.masksToBounds = YES;
    metaContainerLayer.cornerRadius = 4;
    
    // title labels
    
    NSArray *titleLabels = @[self.titleExerciseLabel, self.targetWeightLabel, self.targetRepsLabel];
    for (UILabel *lab in titleLabels){
        
        lab.backgroundColor = [UIColor grayColor];
        lab.textColor = [UIColor whiteColor];
        lab.font = [UIFont boldSystemFontOfSize: 20];
        
    }
    
    self.titleExerciseLabel.font = [UIFont boldSystemFontOfSize: 25];

    
    self.numberLabel.font = [UIFont boldSystemFontOfSize: 25];
    self.numberLabel.backgroundColor = [UIColor grayColor];
    self.numberLabel.textColor = [UIColor whiteColor];
    
    NSArray *subLabels = @[self.dateLabel, self.weightLabel, self.repsLabel];
    for (UILabel *label in subLabels){
        
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor blackColor];
        label.font = [UIFont boldSystemFontOfSize: 12];
        
    }
    
    self.previousEntriesLabel.backgroundColor = [UIColor lightGrayColor];
    self.previousEntriesLabel.font = [UIFont boldSystemFontOfSize: 15];
    self.previousEntriesLabel.textColor = [UIColor whiteColor];

    
}

- (void)configureViewData{
    
    // target labels and exercise title
    
    NSString *targetWeightText = [NSString stringWithFormat: @"%@ lbs", self.targetWeight];
    NSString *targetRepsText = [NSString stringWithFormat: @"%@ reps", self.targetReps];
    
    self.targetWeightLabel.text = targetWeightText;
    self.targetRepsLabel.text = targetRepsText;
    
    self.titleExerciseLabel.text = self.targetExerciseName;
    self.numberLabel.text = self.titleNumber;
                                     
 
    
}


#pragma mark - Line Drawing


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
    
    [self.view.layer addSublayer: sl];
    
}

- (void)drawRightBorderForLabel:(UILabel *)label thickness:(CGFloat)thickness{
    
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
    
    CGPoint startPoint = topRightCorner;
    CGPoint endPoint = bottomRightCorner;
    
    UIBezierPath *bp = [[UIBezierPath alloc] init];
    [bp moveToPoint: startPoint];
    [bp addLineToPoint: endPoint];
    
    sl.path = bp.CGPath;
    
    // label layer
    
    label.layer.masksToBounds = NO;
    [label.layer addSublayer: sl];
    
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
    
    [self.view.layer addSublayer: sl];
    
}

#pragma mark - Content

- (void)createStackViewContent{
    
    int limit = (int)self.previousEntries.count;
    
    for (int i = 0; i < limit; i++){
        
        UIView *contentRow = [self contentRowCorrespondingToIndex: i
                                                         maxIndex: limit];
        
        [self.contentStackView addArrangedSubview: contentRow];
        
    }
    
}

- (UIView *)contentRowCorrespondingToIndex:(int)index maxIndex:(int)maxIndex{
    
//    BOOL isTopRow = index == 0;
//    BOOL isBottomRow = index == maxIndex;

    // container view
    
    UIView *containerView = [[UIView alloc] init];
    containerView.backgroundColor = [UIColor blackColor];
    
    NSMutableDictionary *constraintMapping = [[NSMutableDictionary alloc] init];
    
    TJBPreviousMarksDictionary *pmDict = self.previousEntries[index];
    
    // date label
    

    UILabel *dateLabel = [[UILabel alloc] init];
    [containerView addSubview: dateLabel];
    [self configurePreviousMarkLabelAesthetics: dateLabel];
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"MMM d, yyyy";
    dateLabel.text = [df stringFromDate: [pmDict date]];
    
    NSString *dateLabelKey = @"dateLabel";
    [constraintMapping setObject: dateLabel
                          forKey: dateLabelKey];

    dateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    NSString *dateVertVFL = [self vertVFLForLabelWithKey: dateLabelKey];
    [containerView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: dateVertVFL
                                                                           options: 0
                                                                           metrics: nil
                                                                             views: constraintMapping]];
    

    
    // weight
    
    UILabel *weightLabel = [[UILabel alloc] init];
    [containerView addSubview: weightLabel];
    [self configurePreviousMarkLabelAesthetics: weightLabel];
    
    weightLabel.text = [[pmDict weight] stringValue];
    
    NSString *weightLabelKey = @"weightLabel";
    [constraintMapping setObject: weightLabel
                          forKey: weightLabelKey];
    
    weightLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSString *weightVertVFL = [self vertVFLForLabelWithKey: weightLabelKey];
    [containerView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: weightVertVFL
                                                                           options: 0
                                                                           metrics: nil
                                                                             views: constraintMapping]];
    
    
    // reps
    
    UILabel *repsLabel = [[UILabel alloc] init];
    [containerView addSubview: repsLabel];
    [self configurePreviousMarkLabelAesthetics: repsLabel];
    
    repsLabel.text = [[pmDict reps] stringValue];
    
    NSString *repsLabelKey = @"repsLabel";
    [constraintMapping setObject: repsLabel
                          forKey: repsLabelKey];
    
    repsLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    NSString *repsVertVFL = [self vertVFLForLabelWithKey: repsLabelKey];
    [containerView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: repsVertVFL
                                                                           options: 0
                                                                           metrics: nil
                                                                             views: constraintMapping]];
    
    
    // horisontal constraints for all
    
    NSString *horzVFL = [NSString stringWithFormat: @"H:|-0-[%@(==%@)]-%f-[%@(==%@)]-%f-[%@]-0-|",
                         dateLabelKey,
                         weightLabelKey,
                         rowSpacing,
                         weightLabelKey,
                         repsLabelKey,
                         rowSpacing,
                         repsLabelKey];
    [containerView addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: horzVFL
                                                                           options: 0
                                                                           metrics: nil
                                                                             views: constraintMapping]];
    
    [containerView layoutSubviews];

    return containerView;
    
}


- (NSString *)vertVFLForLabelWithKey:(NSString *)key{
    
    return [NSString stringWithFormat: @"V:|-0-[%@]-0-|", key];
    
}

- (void)configurePreviousMarkLabelAesthetics:(UILabel *)label{
    
    label.textAlignment = NSTextAlignmentCenter;
    label.backgroundColor = [[TJBAestheticsController singleton] yellowNotebookColor];
    label.textColor = [UIColor blackColor];
    label.font = [UIFont systemFontOfSize: 15];
    
}



@end


















































