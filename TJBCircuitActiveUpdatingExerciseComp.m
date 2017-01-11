//
//  TJBCircuitActiveUpdatingExerciseComp.m
//  Beast
//
//  Created by Trevor Beasty on 1/11/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBCircuitActiveUpdatingExerciseComp.h"

// child VC

#import "TJBCircuitActiveUpdatingRowComp.h"

// core data

#import "TJBNumberTypeArrayComp+CoreDataProperties.h"
#import "TJBExercise+CoreDataProperties.h"
#import "TJBBeginDateComp+CoreDataProperties.h"
#import "TJBEndDateComp+CoreDataProperties.h"

// aesthetics

#import "TJBAestheticsController.h"

@interface TJBCircuitActiveUpdatingExerciseComp ()


// core

@property (nonatomic, strong) NSNumber *numberOfRounds;
@property (nonatomic, strong) NSNumber *numberOfExercises;
@property (nonatomic, strong) NSNumber *targetsVaryByRound;
@property (nonatomic, strong) NSNumber *chainNumber;
@property (nonatomic, strong) TJBExercise *exercise;
@property (nonatomic, strong) NSNumber *maxExerciseIndexToFill;
@property (nonatomic, strong) NSNumber *maxRoundIndexToFill;
@property (nonatomic, strong) NSOrderedSet <TJBNumberTypeArrayComp *> *weightData;
@property (nonatomic, strong) NSOrderedSet <TJBNumberTypeArrayComp *> *repsData;
@property (nonatomic, strong) NSOrderedSet <TJBBeginDateComp *> *setBeginDates;
@property (nonatomic, strong) NSOrderedSet <TJBEndDateComp *> *setEndDates;

// IBOutlets

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *roundColumnLabel;
@property (weak, nonatomic) IBOutlet UILabel *weightColumnLabel;
@property (weak, nonatomic) IBOutlet UILabel *repsColumnLabel;
@property (weak, nonatomic) IBOutlet UILabel *thinLineLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectedExerciseButton;
@property (weak, nonatomic) IBOutlet UILabel *setLengthColumnLabel;
@property (weak, nonatomic) IBOutlet UILabel *restColumnLabel;

// for programmatic auto layout constraints

@property (nonatomic, strong) NSMutableDictionary *constraintMapping;

@end

@implementation TJBCircuitActiveUpdatingExerciseComp

- (instancetype)initWithNumberOfRounds:(NSNumber *)numberOfRounds targetsVaryByRound:(NSNumber *)targetsVaryByRound chainNumber:(NSNumber *)chainNumber exercise:(TJBExercise *)exercise weightData:(NSOrderedSet<TJBNumberTypeArrayComp *> *)weightData repsData:(NSOrderedSet<TJBNumberTypeArrayComp *> *)repsData setBeginDates:(NSOrderedSet<TJBBeginDateComp *> *)setBeginDates setEndDates:(NSOrderedSet<TJBEndDateComp *> *)setEndDates maxExerciseIndexToFill:(NSNumber *)maxExerciseIndexToFill maxRoundIndexToFill:(NSNumber *)maxRoundIndexToFill numberOfExercises:(NSNumber *)numberOfExercises{
    
    self = [super init];
    
    self.numberOfExercises = numberOfExercises;
    self.numberOfRounds = numberOfRounds;
    self.targetsVaryByRound = targetsVaryByRound;
    self.chainNumber = chainNumber;
    self.exercise = exercise;
    self.weightData = weightData;
    self.repsData = repsData;
    self.setBeginDates = setBeginDates;
    self.setEndDates = setEndDates;
    self.maxExerciseIndexToFill = maxExerciseIndexToFill;
    self.maxRoundIndexToFill = maxRoundIndexToFill;
    
    
    return self;
}

#pragma mark - View Life Cycle

- (void)configureViewAesthetics{
    
    // container view
    
    CALayer *viewLayer = self.view.layer;
    viewLayer.masksToBounds = YES;
    viewLayer.cornerRadius = 8.0;
    viewLayer.opacity = .85;
    
    // column label views
    
    NSArray *labelViews = @[self.roundColumnLabel,
                            self.weightColumnLabel,
                            self.repsColumnLabel,
                            self.restColumnLabel,
                            self.setLengthColumnLabel];
    
    for (UIView *view in labelViews){
        
        view.backgroundColor = [[TJBAestheticsController singleton] labelType1Color];
        view.layer.opacity = .85;
        
    }
    
    // title label view
    
    self.titleLabel.backgroundColor = [UIColor darkGrayColor];
    [self.titleLabel setTextColor: [UIColor whiteColor]];
    
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
    
    NSString *titleString = [NSString stringWithFormat: @"Exercise #%d",
                             [self.chainNumber intValue]];
    
    self.titleLabel.text = titleString;
}

- (void)viewDidLoad
{
    [self configureViewAesthetics];
    
    [self configureViewDataAndFunctionality];
    
    //// major functionality includeing row child VC's and layout constraints
    
    self.constraintMapping = [[NSMutableDictionary alloc] init];
    
    // labels
    
    self.titleLabel.text = [NSString stringWithFormat: @"Exercise #%d",
                            [self.chainNumber intValue]];
    
    // row components
    
    NSString *thinLineLabel = @"thinLineLabel";
    [self.constraintMapping setObject: self.thinLineLabel
                               forKey: thinLineLabel];
    
    NSString *roundColumnLabel = @"roundColumnLabel";
    [self.constraintMapping setObject:self.roundColumnLabel
                               forKey: roundColumnLabel];
    
    
    
    NSMutableString *verticalLayoutConstraintsString = [NSMutableString stringWithCapacity: 1000];
    [verticalLayoutConstraintsString setString: [NSString stringWithFormat: @"V:[%@]-2-", thinLineLabel]];
    
    for (int i = 0 ; i < [self.numberOfRounds intValue] ; i ++){
        
        
        // need to check to the completeness of the realized set (via passed in variables) when assigning following NSNumbers
        
        NSNumber *setHasBeeRealized;
        NSNumber *weight;
        NSNumber *reps;
        NSNumber *rest = nil;
        NSNumber *setLength;
        
//        BOOL pastMaxRoundIndex = i > [self.maxRoundIndexToFill intValue];
        BOOL atMaxRoundIndex = i = [self.maxRoundIndexToFill intValue];
        BOOL atLessThanMaxRoundIndex = i < [self.maxRoundIndexToFill intValue];
        BOOL pastMaxExeriseIndex = [self.chainNumber intValue] - 1 > [self.maxExerciseIndexToFill intValue];
        
        // need to derive the appropriate rest and set length values if the set has been realized
        
        if (atLessThanMaxRoundIndex || (atMaxRoundIndex && !pastMaxExeriseIndex) ){
            
            // derive the value for rest.  This involves two separate indexes and requires some logic to grab the appropriate previous index
            
//            BOOL isFirstExercise = [self.chainNumber intValue] - 1 == 0;
//            
//            if (isFirstExercise){
//                
//            }
            
 
            
            
            // derive the value for set length
            
            NSDate *earlierSetLengthDate = self.setBeginDates[i].value;
            NSDate *laterSetLengthDate = self.setEndDates[i].value;
            int setLengthAsInt = [laterSetLengthDate timeIntervalSinceDate: earlierSetLengthDate];
            setLength = [NSNumber numberWithInt: setLengthAsInt];
            
            // other NSNumbers, whose values can be directly grabbed
            
            setHasBeeRealized = [NSNumber numberWithBool: YES];
            weight = [NSNumber numberWithFloat: self.weightData[i].value];
            reps = [NSNumber numberWithFloat: self.repsData[i].value];

        } else{
            
            setHasBeeRealized = [NSNumber numberWithBool: NO];
            weight = nil;
            reps = nil;
            rest = nil;
            setLength = nil;
            
        }
        
        TJBCircuitActiveUpdatingRowComp *rowVC = [[TJBCircuitActiveUpdatingRowComp alloc] initWithTargetsVaryByRound: self.targetsVaryByRound
                                                                                                         roundNumber: [NSNumber numberWithInt: i + 1]
                                                                                                          weightData: weight
                                                                                                            repsData: reps
                                                                                                            restData: rest
                                                                                                       setLengthData: setLength
                                                                                                  setHasBeenRealized: setHasBeeRealized];
        
        rowVC.view.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addChildViewController: rowVC];
        
        [self.view addSubview: rowVC.view];
        
        NSString *dynamicRowName = [NSString stringWithFormat: @"rowComponent%d",
                                    i];
        
        [self.constraintMapping setObject: rowVC.view
                                   forKey: dynamicRowName];
        
        // vertical constraints
        
        NSString *verticalAppendString;
        
        if ([self.targetsVaryByRound intValue] == 0)
        {
            i = [self.numberOfRounds intValue] - 1;
        }
        
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
    
    for (TJBCircuitActiveUpdatingRowComp *child in self.childViewControllers)
    {
        [child didMoveToParentViewController: self];
    }
}

@end




































