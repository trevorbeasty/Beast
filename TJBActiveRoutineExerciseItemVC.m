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
//@property (weak, nonatomic) IBOutlet UILabel *targetsLabel;
@property (weak, nonatomic) IBOutlet UILabel *previousEntriesLabel;
//@property (weak, nonatomic) IBOutlet UILabel *thinLineLabel;
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

- (void)viewDidLoad{
    
    [self configureViewData];
    
    [self configureTableView];
    
    [self configureViewAesthetics];
    
}

- (void)configureViewAesthetics{
    
    NSArray *titleLabels = @[self.titleExerciseLabel, self.targetWeightLabel, self.targetRepsLabel];
    for (UILabel *lab in titleLabels){
        
        lab.backgroundColor = [UIColor clearColor];
        lab.textColor = [UIColor darkGrayColor];
        lab.font = [UIFont boldSystemFontOfSize: 20];
        
    }
    
    
    NSArray *minorLabels = @[self.previousEntriesLabel];
    for (UILabel *label in minorLabels){
        
        label.backgroundColor = [UIColor lightGrayColor];
        label.font = [UIFont boldSystemFontOfSize: 15.0];
        label.textColor = [UIColor whiteColor];
        
    }
    
    // curved corners of container view
    
    self.containerView.layer.masksToBounds = YES;
    self.containerView.layer.cornerRadius = 8.0;
    
}

- (void)configureViewData{
    
    // target labels and exercise title
    
    NSString *titleText = [NSString stringWithFormat: @"%@",
                       self.targetExerciseName];
    NSString *targetWeightText = [NSString stringWithFormat: @"%@ lbs", self.targetWeight];
    NSString *targetRepsText = [NSString stringWithFormat: @"%@ reps", self.targetReps];
    
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
    
    self.previousEntriesTableView.scrollEnabled = NO;
    
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


















































