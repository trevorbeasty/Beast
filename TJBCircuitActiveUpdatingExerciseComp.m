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

#import "CoreDataController.h"

// aesthetics

#import "TJBAestheticsController.h"

// utility

#import "TJBAssortedUtilities.h"

@interface TJBCircuitActiveUpdatingExerciseComp ()

// core

@property (nonatomic, strong) NSNumber *numberOfExercises;
@property (nonatomic, strong) NSNumber *numberOfRounds;
@property (nonatomic, strong) NSNumber *chainNumber;
@property (nonatomic, strong) TJBExercise *exercise;
@property (nonatomic, strong) NSNumber *firstIncompleteExerciseIndex;
@property (nonatomic, strong) NSNumber *firstIncompleteRoundIndex;
@property (nonatomic, strong) NSOrderedSet <TJBNumberTypeArrayComp *> *weightData;
@property (nonatomic, strong) NSOrderedSet <TJBNumberTypeArrayComp *> *repsData;
@property (nonatomic, strong) NSOrderedSet <TJBBeginDateComp *> *setBeginDatesData;
@property (nonatomic, strong) NSOrderedSet <TJBEndDateComp *> *setEndDatesData;
@property (nonatomic, strong) NSOrderedSet <TJBEndDateComp *> *previousExerciseSetEndDatesData;

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

- (instancetype)initWithNumberOfRounds:(NSNumber *)numberOfRounds chainNumber:(NSNumber *)chainNumber exercise:(TJBExercise *)exercise firstIncompleteExerciseIndex:(NSNumber *)firstIncompleteExerciseIndex firstIncompleteRoundIndex:(NSNumber *)firstIncompleteRoundIndex weightData:(NSOrderedSet<TJBNumberTypeArrayComp *> *)weightData repsData:(NSOrderedSet<TJBNumberTypeArrayComp *> *)repsData setBeginDatesData:(NSOrderedSet<TJBBeginDateComp *> *)setBeginDatesData setEndDatesData:(NSOrderedSet<TJBEndDateComp *> *)setEndDatesData previousExerciseSetEndDatesData:(NSOrderedSet<TJBEndDateComp *> *)previousExerciseSetEndDatesData numberOfExercises:(NSNumber *)numberOfExercises{

    self = [super init];
    
    self.numberOfRounds = numberOfRounds;
    self.chainNumber = chainNumber;
    self.exercise = exercise;
    self.weightData = weightData;
    self.repsData = repsData;
    self.setBeginDatesData = setBeginDatesData;
    self.setEndDatesData = setEndDatesData;
    self.firstIncompleteExerciseIndex = firstIncompleteExerciseIndex;
    self.firstIncompleteRoundIndex = firstIncompleteRoundIndex;
    self.numberOfExercises = numberOfExercises;
    self.previousExerciseSetEndDatesData = previousExerciseSetEndDatesData;
    
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

- (void)viewDidLoad{
    
    [self configureViewAesthetics];
    
    [self configureViewDataAndFunctionality];
    
    //// major functionality including row child VC's and layout constraints
    
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
    
    // used in determining data to pass to row controllers
    
    int currentExerciseIndex = [self.chainNumber intValue] - 1;
    
    for (int i = 0 ; i < [self.numberOfRounds intValue] ; i ++){
        
        //// derive the inputs for creating the row component controller
        
        NSNumber *roundNumber = [NSNumber numberWithInt: i + 1];
        NSNumber *chainNumber = self.chainNumber;
        
        // determine if the set has been realized. If so, give parameters appropriate values.  If not, give parameters nil value
        
        NSNumber *weightData;
        NSNumber *repsData;
        NSNumber *restData;
        NSNumber *setLengthData;
        NSNumber *setHasBeenRealized;
        NSNumber *isFirstExerciseInFirstRound = [NSNumber numberWithBool: i == 0 && ([self.chainNumber intValue] - 1 == 0)];
        
        int firstIncompleteExerciseIndex = [self.firstIncompleteExerciseIndex intValue];
        int firstIncompleteRoundIndex = [self.firstIncompleteRoundIndex intValue];
        
        BOOL roundIndexIsLessThanFirstIncompleteRoundIndex = i < firstIncompleteRoundIndex;
        BOOL atFirstIncompleteRound = i == firstIncompleteRoundIndex;
        BOOL atExerciseIndexLessThanFirstIncompleteExerciseIndex = currentExerciseIndex < firstIncompleteExerciseIndex;
        
        BOOL roundHasBeenRealized = (roundIndexIsLessThanFirstIncompleteRoundIndex || (atFirstIncompleteRound && atExerciseIndexLessThanFirstIncompleteExerciseIndex));
        
        if (roundHasBeenRealized){
            
            // the round has been realized, so derive appropriate data values
            
            setHasBeenRealized = [NSNumber numberWithBool: YES];
            
            weightData = [NSNumber numberWithFloat: self.weightData[i].value];
            repsData = [NSNumber numberWithFloat: self.repsData[i].value];
            
            NSDate *setBeginDate = self.setBeginDatesData[i].value;
            NSDate *setEndDate = self.setEndDatesData[i].value;
            
            int setLengthAsInt = [setEndDate timeIntervalSinceDate: setBeginDate];
            setLengthData = [NSNumber numberWithInt: setLengthAsInt];
            
            NSNumber *previousRoundIndex = nil;
            NSNumber *previousExerciseIndex = nil;
            BOOL previousIndicesExist = [TJBAssortedUtilities previousExerciseAndRoundIndicesForCurrentExerciseIndex: [self.chainNumber intValue] - 1
                                                                                                   currentRoundIndex: i
                                                                                                   numberOfExercises: [self.numberOfExercises intValue]
                                                                                                      numberOfRounds: [self.numberOfRounds intValue]
                                                                                                 roundIndexReference: &previousRoundIndex
                                                                                              exerciseIndexReference: &previousExerciseIndex];
            
            if (previousIndicesExist){
                
                int previousRoundIndexAsInt = [previousRoundIndex intValue];
                
                NSDate *previousSetEndDate = self.previousExerciseSetEndDatesData[previousRoundIndexAsInt].value;
                
                int restDataAsInt = [setBeginDate timeIntervalSinceDate: previousSetEndDate];
                restData = [NSNumber numberWithInt: restDataAsInt];
                
            } else{
                
                restData = nil;
                
            }
            
        } else{
            
            // assign nil values
            
            weightData = nil;
            repsData = nil;
            setLengthData = nil;
            setHasBeenRealized = [NSNumber numberWithBool: NO];
            
        }
    
        //// create the row component controller
        
        TJBCircuitActiveUpdatingRowComp *rowVC = [[TJBCircuitActiveUpdatingRowComp alloc] initWithRoundNumber: roundNumber
                                                                                                  chainNumber: chainNumber
                                                                                                   weightData: weightData
                                                                                                     repsData: repsData
                                                                                                     restData: restData
                                                                                                setLengthData: setLengthData
                                                                                           setHasBeenRealized: setHasBeenRealized
                                                                                  isFirstExerciseInFirstRound: isFirstExerciseInFirstRound];
        
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
    
    for (TJBCircuitActiveUpdatingRowComp *child in self.childViewControllers)
    {
        [child didMoveToParentViewController: self];
    }
}

@end




































