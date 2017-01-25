//
//  TJBCircuitReferenceExerciseComp.m
//  Beast
//
//  Created by Trevor Beasty on 1/11/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBCircuitReferenceExerciseComp.h"

// core data

#import "TJBExercise+CoreDataProperties.h"

// aesthetics

#import "TJBAestheticsController.h"

// child VC

#import "TJBCircuitReferenceRowComp.h"

@interface TJBCircuitReferenceExerciseComp ()

// core

@property (nonatomic, strong) NSNumber *numberOfRounds;
@property (nonatomic, strong) NSNumber *targetingWeight;
@property (nonatomic, strong) NSNumber *targetingReps;
@property (nonatomic, strong) NSNumber *targetingRest;
@property (nonatomic, strong) NSNumber *targetsVaryByRound;
@property (nonatomic, strong) NSNumber *chainNumber;
@property (nonatomic, strong) TJBExercise *exercise;
@property (nonatomic, strong) NSOrderedSet <TJBNumberTypeArrayComp *> *weightData;
@property (nonatomic, strong) NSOrderedSet <TJBNumberTypeArrayComp *> *repsData;
@property (nonatomic, strong) NSOrderedSet <TJBNumberTypeArrayComp *> *restData;

// IBOutlets

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *roundColumnLabel;
@property (weak, nonatomic) IBOutlet UILabel *weightColumnLabel;
@property (weak, nonatomic) IBOutlet UILabel *repsColumnLabel;
@property (weak, nonatomic) IBOutlet UILabel *restColumnLabel;
@property (weak, nonatomic) IBOutlet UILabel *thinLineLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectedExerciseButton;

// for programmatic auto layout constraints

@property (nonatomic, strong) NSMutableDictionary *constraintMapping;


@end

@implementation TJBCircuitReferenceExerciseComp

- (instancetype)initWithNumberOfRounds:(NSNumber *)numberOfRounds targetingWeight:(NSNumber *)targetingWeight targetingReps:(NSNumber *)targetingReps targetingRest:(NSNumber *)targetingRest targetsVaryByRound:(NSNumber *)targetsVaryByRound chainNumber:(NSNumber *)chainNumber exercise:(TJBExercise *)exercise weightData:(NSOrderedSet<TJBNumberTypeArrayComp *> *)weightData repsData:(NSOrderedSet<TJBNumberTypeArrayComp *> *)repsData restData:(NSOrderedSet<TJBNumberTypeArrayComp *> *)restData{
    
    self = [super init];
    
    self.numberOfRounds = numberOfRounds;
    self.targetingWeight = targetingWeight;
    self.targetingReps = targetingReps;
    self.targetingRest = targetingRest;
    self.targetsVaryByRound = targetsVaryByRound;
    self.chainNumber = chainNumber;
    self.exercise = exercise;
    self.weightData = weightData;
    self.repsData = repsData;
    self.restData = restData;

    
    return self;
}

#pragma mark - View Life Cycle

- (void)configureViewAesthetics{
    
    // container view
    
    CALayer *viewLayer = self.view.layer;
    viewLayer.masksToBounds = YES;
    viewLayer.cornerRadius = 8.0;
    viewLayer.opacity = 1;
    viewLayer.borderWidth = 1.0;
    viewLayer.borderColor = [[UIColor darkGrayColor] CGColor];
    
    //  labels
    
    self.roundColumnLabel.layer.opacity = 1;
    self.roundColumnLabel.backgroundColor = [UIColor darkGrayColor];
    self.roundColumnLabel.text = @"";
    
    NSArray *labels = @[self.weightColumnLabel,
                        self.repsColumnLabel,
                        self.restColumnLabel];
    
    for (UILabel *label in labels){
        
        label.backgroundColor = [UIColor darkGrayColor];
        label.textColor = [UIColor whiteColor];
        label.layer.opacity = 1;
        
    }
    
    // title label
    
    self.titleLabel.backgroundColor = [[TJBAestheticsController singleton] color1];
    self.titleLabel.textColor = [UIColor whiteColor];
    
    // selected exercise button
    
    UIButton *button = self.selectedExerciseButton;
    
    button.backgroundColor = [UIColor whiteColor];
    [button setTitleColor: [UIColor blackColor]
                 forState: UIControlStateNormal];
    
    // selected exercise button layer
    
    CALayer *layer = button.layer;
    layer.masksToBounds = YES;
    layer.cornerRadius = 8;
    layer.opacity = .85;
}

- (void)configureViewDataAndFunctionality{
    
    // exercise
    
    [self.selectedExerciseButton setTitle: self.exercise.name
                                 forState: UIControlStateNormal];
    self.selectedExerciseButton.enabled = NO;
    
    // title label
    
    self.titleLabel.text = [self.chainNumber stringValue];
}

- (void)viewDidLoad
{
    [self configureViewAesthetics];
    
    [self configureViewDataAndFunctionality];
    
    //// major functionality includeing row child VC's and layout constraints
    
    self.constraintMapping = [[NSMutableDictionary alloc] init];
    
    // row components
    
    NSString *weightColumnLabel = @"weightColumnLabel";
    [self.constraintMapping setObject: self.weightColumnLabel
                               forKey: weightColumnLabel];
    
    NSString *roundColumnLabel = @"roundColumnLabel";
    [self.constraintMapping setObject:self.roundColumnLabel
                               forKey: roundColumnLabel];
    
    
    
    NSMutableString *verticalLayoutConstraintsString = [NSMutableString stringWithCapacity: 1000];
    [verticalLayoutConstraintsString setString: [NSString stringWithFormat: @"V:[%@]-0-", weightColumnLabel]];
    
    for (int i = 0 ; i < [self.numberOfRounds intValue] ; i ++){
        
        // need to test if data is being targeted before passing it to the child VC
        
        NSNumber *weight;
        NSNumber *reps;
        NSNumber *rest;
        
        if ([self.targetingWeight boolValue] == YES){
            weight = [NSNumber numberWithInt: self.weightData[i].value];
        } else{
            weight = nil;
        }
        
        if ([self.targetingReps boolValue] == YES){
            reps = [NSNumber numberWithInt: self.repsData[i].value];
        } else{
            reps = nil;
        }
        
        if ([self.targetingRest boolValue] == YES){
            rest = [NSNumber numberWithInt: self.restData[i].value];
        } else{
            rest = nil;
        }
        
        TJBCircuitReferenceRowComp *rowVC = [[TJBCircuitReferenceRowComp alloc] initWithTargetingWeight: self.targetingWeight
                                                                                          targetingReps: self.targetingReps
                                                                                          targetingRest: self.targetingRest
                                                                                     targetsVaryByRound: self.targetsVaryByRound
                                                                                            roundNumber: [NSNumber numberWithInt: i + 1]
                                                                                             weightData: [NSNumber numberWithFloat: self.weightData[i].value]
                                                                                               repsData: [NSNumber numberWithFloat: self.repsData[i].value]
                                                                                               restData: [NSNumber numberWithFloat: self.restData[i].value]];
        
        rowVC.view.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addChildViewController: rowVC];
        
        [self.view addSubview: rowVC.view];
        
        NSString *dynamicRowName = [NSString stringWithFormat: @"rowComponent%d",
                                    i];
        
        [self.constraintMapping setObject: rowVC.view
                                   forKey: dynamicRowName];
        
        // vertical constraints
        
        NSString *verticalAppendString;
        
        if (i == [self.numberOfRounds intValue] - 1)
        {
            verticalAppendString = [NSString stringWithFormat: @"[%@(==%@)]-0-|",
                                    dynamicRowName,
                                    roundColumnLabel];
        }
        else
        {
            verticalAppendString = [NSString stringWithFormat: @"[%@(==%@)]-0-",
                                    dynamicRowName,
                                    roundColumnLabel];
        }
        
        [verticalLayoutConstraintsString appendString: verticalAppendString];
        
        // horizontal constraints
        
        NSString *horizontalLayoutConstraintsString = [NSString stringWithFormat: @"H:|-0-[%@]-0-|",
                                                       dynamicRowName];
        
        NSArray *horizontalLayoutConstraints = [NSLayoutConstraint constraintsWithVisualFormat: horizontalLayoutConstraintsString
                                                                                       options: 0
                                                                                       metrics: nil
                                                                                         views: self.constraintMapping];
        
        [self.view addConstraints: horizontalLayoutConstraints];
    }
    
    NSArray *verticalLayoutConstraints = [NSLayoutConstraint constraintsWithVisualFormat: verticalLayoutConstraintsString
                                                                                 options: 0
                                                                                 metrics: nil
                                                                                   views: self.constraintMapping];
    
    [self.view addConstraints: verticalLayoutConstraints];
    
    for (TJBCircuitReferenceRowComp *child in self.childViewControllers)
    {
        [child didMoveToParentViewController: self];
    }
}








@end
