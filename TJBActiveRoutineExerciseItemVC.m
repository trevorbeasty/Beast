//
//  TJBActiveRoutineExerciseItemVC.m
//  Beast
//
//  Created by Trevor Beasty on 2/10/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBActiveRoutineExerciseItemVC.h"

// table view cell

#import "TJBActiveRoutineGuidancePreviousEntryCell.h"

// aesthetics

#import "TJBAestheticsController.h"

@interface TJBActiveRoutineExerciseItemVC () <UITableViewDelegate, UITableViewDataSource>

// IBOutlet

@property (weak, nonatomic) IBOutlet UILabel *titleExerciseLabel;
@property (weak, nonatomic) IBOutlet UILabel *targetWeightLabel;
@property (weak, nonatomic) IBOutlet UILabel *targetRepsLabel;
@property (weak, nonatomic) IBOutlet UITableView *previousEntriesTableView;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UILabel *previousEntriesLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *weightLabel;
@property (weak, nonatomic) IBOutlet UILabel *repsLabel;

@property (weak, nonatomic) IBOutlet UIView *headerAreaContainer;
@property (weak, nonatomic) IBOutlet UIView *metaContainer;



// core

@property (nonatomic, strong) NSString *titleNumber;
@property (nonatomic, strong) NSString *targetExerciseName;
@property (nonatomic, strong) NSString *targetWeight;
@property (nonatomic, strong) NSString *targetReps;
@property (nonatomic, strong) NSArray<NSArray *> *previousEntries;


@end

@implementation TJBActiveRoutineExerciseItemVC

#pragma mark - Instantiation

- (instancetype)initWithTitleNumber:(NSString *)titleNumber targetExerciseName:(NSString *)targetExerciseName targetWeight:(NSString *)targetWeight targetReps:(NSString *)targetReps previousEntries:(NSArray *)previousEntries{
    
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
    
    [self configureTableView];
    
    [self configureViewAesthetics];
    
}

- (void)viewWillAppear:(BOOL)animated{
    
    
    
}

#pragma mark - View Helper Methods


- (void)configureViewAesthetics{
    
    [self.view layoutSubviews];
    
    // meta view
    
    self.view.backgroundColor = [UIColor clearColor];
    self.headerAreaContainer.backgroundColor = [UIColor blackColor];
    self.metaContainer.backgroundColor = [UIColor clearColor];
    
    CALayer *metaContainerLayer = self.metaContainer.layer;
    metaContainerLayer.masksToBounds = YES;
    metaContainerLayer.cornerRadius = 4;
    
//    UIView *shadowView = [[UIView alloc] initWithFrame: self.metaContainer.frame];
//    shadowView.backgroundColor = [[TJBAestheticsController singleton] yellowNotebookColor];
//    CALayer *shadowLayer = shadowView.layer;
//    shadowLayer.masksToBounds = NO;
//    shadowLayer.shadowColor = [UIColor blackColor].CGColor;
//    shadowLayer.shadowOffset = CGSizeMake(1.5, 1.5);
//    shadowLayer.shadowRadius = 1.5;
//    shadowLayer.shadowOpacity = .8;
//    [self.view insertSubview: shadowView
//                belowSubview: self.metaContainer];
//    metaContainerLayer.shadowColor = [UIColor lightGrayColor].CGColor;
//    metaContainerLayer.shadowOffset = CGSizeMake(3, 3);
//    metaContainerLayer.shadowOpacity = 1.0;
//    metaContainerLayer.shadowRadius = 1;
    
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
        label.font = [UIFont systemFontOfSize: 12];
        
    }
    
    self.previousEntriesLabel.backgroundColor = [UIColor lightGrayColor];
    self.previousEntriesLabel.font = [UIFont boldSystemFontOfSize: 15];
    self.previousEntriesLabel.textColor = [UIColor whiteColor];
    
    // line drawing
    
    [self addVerticalBorderToRight: YES
                           topView: self.dateLabel
                        bottomView: self.dateLabel
                         thickness: 1
                         superView: self.view];

    
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

static NSString * previousEntryCellID = @"previousEntryCell";

- (void)configureTableView{
    
    // functionality
    
    UINib *previousEntryCell = [UINib nibWithNibName: @"TJBActiveRoutineGuidancePreviousEntryCell"
                                              bundle: nil];
    
    [self.previousEntriesTableView registerNib: previousEntryCell
                        forCellReuseIdentifier: previousEntryCellID];
    
    self.previousEntriesTableView.scrollEnabled = NO;
    
    // aesthetics
    
    self.previousEntriesTableView.backgroundColor = [[TJBAestheticsController singleton] yellowNotebookColor];
    
}

#pragma mark - Line Drawing


- (void)addVerticalBorderToRight:(BOOL)toRight topView:(UIView *)topView bottomView:(UIView *)bottomView thickness:(CGFloat)thickness superView:(UIView *)superView{
    
    CAShapeLayer *sl = [CAShapeLayer layer];
    
    // attributes
    
    sl.strokeColor = [[UIColor blackColor] CGColor];
    sl.lineWidth = thickness;
    sl.fillColor = nil;
    sl.opacity = 1.0;
    
    
    
    CGPoint startPoint;
    CGPoint endPoint;
    
    if (toRight == YES){
        
        startPoint = CGPointMake(topView.frame.origin.x + topView.frame.size.width, topView.frame.origin.y);
        endPoint = CGPointMake(bottomView.frame.origin.x + bottomView.frame.size.width, bottomView.frame.origin.y + bottomView.frame.size.height);
        
    } else{
        
        startPoint = CGPointMake(topView.frame.origin.x, topView.frame.origin.y);
        endPoint = CGPointMake(bottomView.frame.origin.x, bottomView.frame.origin.y + bottomView.frame.size.height);
        
    }
    
    UIBezierPath *bp = [[UIBezierPath alloc] init];
    [bp moveToPoint: startPoint];
    [bp addLineToPoint: endPoint];
    
    sl.path = bp.CGPath;
    
    // label layer
    
    [superView.layer addSublayer: sl];
    
}

- (void)addHorizontalBorderBeneath:(UILabel *)label thickness:(CGFloat)thickness superView:(UIView *)superView{
    
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
    
//    [self.contentView.layer addSublayer: sl];
    
}

#pragma mark - <UITableViewDelegate>

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    return 40;
    
    
}




#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    
    return self.previousEntries.count;
        

    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    // in the array, the order of objects is as follows: weight, reps, date created
    
    TJBActiveRoutineGuidancePreviousEntryCell *cell = [self.previousEntriesTableView dequeueReusableCellWithIdentifier: previousEntryCellID];
    
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    // give the cell the correct data
    
    NSArray *data = self.previousEntries[indexPath.row];
    
    [cell configureWithDate: data[2]
                     weight: data[0]
                       reps: data[1]];
    
    return cell;

    
}




@end


















































