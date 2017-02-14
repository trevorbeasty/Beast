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
//@property (weak, nonatomic) IBOutlet UILabel *titleNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleExerciseLabel;
@property (weak, nonatomic) IBOutlet UILabel *targetWeightLabel;
@property (weak, nonatomic) IBOutlet UILabel *targetRepsLabel;
@property (weak, nonatomic) IBOutlet UITableView *previousEntriesTableView;
//@property (weak, nonatomic) IBOutlet UILabel *roundCornerLabel;
//@property (weak, nonatomic) IBOutlet UILabel *thenLabel;
@property (weak, nonatomic) IBOutlet UILabel *targetsLabel;
@property (weak, nonatomic) IBOutlet UILabel *previousEntriesLabel;
@property (weak, nonatomic) IBOutlet UILabel *thinLineLabel;
@property (weak, nonatomic) IBOutlet UIView *containerView;

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

- (void)viewWillAppear:(BOOL)animated{
    
    [self curveCorners];
    
}

- (void)viewDidLoad{
    
    [self configureViewData];
    
    [self configureTableView];
    
    [self configureViewAesthetics];
    
}

- (void)curveCorners{
    
//    [self.view layoutIfNeeded];
    
    // title label
    
//    CAShapeLayer *shapeLayer = [[CAShapeLayer alloc] init];
//    
//    UIBezierPath *path = [UIBezierPath bezierPathWithRoundedRect: self.titleExerciseLabel.bounds
//                                               byRoundingCorners: (UIRectCornerBottomRight)
//                                                     cornerRadii: CGSizeMake(8.0, 8.0)];
//    
//    shapeLayer.path = path.CGPath;
//    shapeLayer.frame = self.titleExerciseLabel.bounds;
//    shapeLayer.fillRule = kCAFillRuleNonZero;
//    shapeLayer.fillColor = [UIColor redColor].CGColor;
//    
//    self.titleExerciseLabel.layer.mask = shapeLayer;
//    
//    // next... label
//    
//    CAShapeLayer *thenLabelShapeLayer = [[CAShapeLayer alloc] init];
//    
//    UIBezierPath *thenLabelPath = [UIBezierPath bezierPathWithRoundedRect: self.thenLabel.bounds
//                                                        byRoundingCorners: (UIRectCornerTopRight)
//                                                              cornerRadii: CGSizeMake(8.0, 8.0)];
//    
//    thenLabelShapeLayer.path = thenLabelPath.CGPath;
//    thenLabelShapeLayer.frame = self.thenLabel.bounds;
//    thenLabelShapeLayer.fillRule = kCAFillRuleNonZero;
//    thenLabelShapeLayer.fillColor = [UIColor redColor].CGColor;
//    
//    self.thenLabel.layer.mask = thenLabelShapeLayer;
    
}

- (void)configureViewAesthetics{
    
//    [self curveCorners];
    
    // colors
    
    self.titleExerciseLabel.backgroundColor = [UIColor clearColor];
    self.titleExerciseLabel.textColor = [UIColor darkGrayColor];
    self.titleExerciseLabel.font = [UIFont boldSystemFontOfSize: 20.0];
    
    NSArray *minorLabels = @[self.targetsLabel, self.targetWeightLabel, self.targetRepsLabel, self.previousEntriesLabel];
    for (UILabel *label in minorLabels){
        
        label.backgroundColor = [UIColor lightGrayColor];
        label.font = [UIFont boldSystemFontOfSize: 15.0];
        label.textColor = [UIColor whiteColor];
        
    }
    
    // curved corners of container view
    
    self.containerView.layer.masksToBounds = YES;
    self.containerView.layer.cornerRadius = 8.0;
    
    
    
//    self.titleExerciseLabel.layer.masksToBounds = YES;
//    self.titleExerciseLabel.layer.cornerRadius = 4.0;
    
  
    
//    self.titleExerciseLabel.backgroundColor = [UIColor darkGrayColor];
//    self.titleExerciseLabel.font = [UIFont boldSystemFontOfSize: 20.0];
    
//    NSArray *labels = @[self.targetsLabel,
//                        self.targetWeightLabel,
//                        self.targetRepsLabel,
//                        self.thinLineLabel,
//                        self.previousEntriesLabel];

    
}

- (void)configureViewData{
    
    // target labels and exercise title
    
    NSString *titleText = [NSString stringWithFormat: @"%d. %@",
                       [self.titleNumber intValue],
                       self.targetExerciseName];
    NSString *targetWeightText = [NSString stringWithFormat: @"%@ lbs", self.targetWeight];
    NSString *targetRepsText = [NSString stringWithFormat: @"%@ reps", self.targetReps];
    
//    self.titleNumberLabel.text = titleNumberText;
    self.titleExerciseLabel.text = titleText;
    self.targetWeightLabel.text = targetWeightText;
    self.targetRepsLabel.text = targetRepsText;
    
}

static NSString * previousEntryCellID = @"previousEntryCell";

- (void)configureTableView{
    
    // functionality
    
    UINib *previousEntryCell = [UINib nibWithNibName: @"TJBActiveRoutineGuidancePreviousEntryCell"
                                              bundle: nil];
    
    [self.previousEntriesTableView registerNib: previousEntryCell
                        forCellReuseIdentifier: previousEntryCellID];
    
    // aesthetics
    
    self.previousEntriesTableView.backgroundColor = [[TJBAestheticsController singleton] yellowNotebookColor];
    
}

#pragma mark - <UITableViewDelegate>






#pragma mark - <UITableViewDataSource>

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    
    return 1;
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return self.previousEntries.count;
    
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    TJBActiveRoutineGuidancePreviousEntryCell *cell = [self.previousEntriesTableView dequeueReusableCellWithIdentifier: previousEntryCellID];
    
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
    
}


@end


















































