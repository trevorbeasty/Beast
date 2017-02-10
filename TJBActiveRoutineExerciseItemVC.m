//
//  TJBActiveRoutineExerciseItemVC.m
//  Beast
//
//  Created by Trevor Beasty on 2/10/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBActiveRoutineExerciseItemVC.h"

@interface TJBActiveRoutineExerciseItemVC () <UITableViewDelegate, UITableViewDataSource>

// IBOutlet
@property (weak, nonatomic) IBOutlet UILabel *titleNumberLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleExerciseLabel;
@property (weak, nonatomic) IBOutlet UILabel *targetWeightLabel;
@property (weak, nonatomic) IBOutlet UILabel *targetRepsLabel;
@property (weak, nonatomic) IBOutlet UITableView *previousEntriesTableView;

// core

@property (nonatomic, strong) NSNumber *titleNumber;
@property (nonatomic, strong) NSString *targetExerciseName;
@property (nonatomic, strong) NSNumber *targetWeight;
@property (nonatomic, strong) NSNumber *targetReps;
@property (nonatomic, strong) NSArray *previousEntries;


@end

@implementation TJBActiveRoutineExerciseItemVC

#pragma mark - Instantiation

- (instancetype)initWithTitleNumber:(NSNumber *)titleNumber targetExerciseName:(NSString *)targetExerciseName targetWeight:(NSNumber *)targetWeight targetReps:(NSNumber *)targetReps previousEntries:(NSArray *)previousEntries{
    
    self = [super init];
    
    self.titleNumber = titleNumber;
    self.targetExerciseName = targetExerciseName;
    self.targetWeight = targetWeight;
    self.targetReps = targetReps;
    self.previousEntries = previousEntries;
    
    return self;
    
}

- (void)viewDidLoad{
    
    [self configureViewData];
    
}

- (void)configureViewData{
    
    // target labels and exercise title
    
    NSString *titleNumberText = [NSString stringWithFormat: @"%d.", [self.titleNumber intValue]];
    NSString *targetWeightText = [NSString stringWithFormat: @"%@ lbs", [self.targetWeight stringValue]];
    NSString *targetRepsText = [NSString stringWithFormat: @"%@ reps", [self.targetReps stringValue]];
    
    self.titleNumberLabel.text = titleNumberText;
    self.targetWeightLabel.text = targetWeightText;
    self.targetRepsLabel.text = targetRepsText;
    
}

#pragma mark - <UITableViewDelegate>






#pragma mark - <UITableViewDataSource>







@end



























