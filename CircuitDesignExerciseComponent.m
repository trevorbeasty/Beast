//
//  CircuitDesignExerciseComponent.m
//  Beast
//
//  Created by Trevor Beasty on 12/13/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import "CircuitDesignExerciseComponent.h"

#import "CircuitDesignRowComponent.h"

#import "TJBExerciseSelectionScene.h"

#import "TJBCircuitTemplateGeneratorVC.h"



@interface CircuitDesignExerciseComponent ()

@property (nonatomic, strong) NSMutableDictionary *constraintMapping;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *roundColumnLabel;
@property (weak, nonatomic) IBOutlet UILabel *weightColumnLabel;
@property (weak, nonatomic) IBOutlet UILabel *repsColumnLabel;
@property (weak, nonatomic) IBOutlet UILabel *restColumnLabel;
@property (weak, nonatomic) IBOutlet UILabel *thinLineLabel;


@property (weak, nonatomic) IBOutlet UIButton *selectedExerciseButton;
- (IBAction)didPressSelectExercise:(id)sender;


@end






@implementation CircuitDesignExerciseComponent

#pragma mark - Instantiation

- (instancetype)initWithNumberOfRounds:(NSNumber *)numberOfRounds targetingWeight:(NSNumber *)targetingWeight targetingReps:(NSNumber *)targetingReps targetingRest:(NSNumber *)targetingRest targetsVaryByRound:(NSNumber *)targetsVaryByRound chainNumber:(NSNumber *)chainNumber exerciseName:(NSString *)exerciseName masterController:(TJBCircuitTemplateGeneratorVC<TJBNumberSelectionDelegate, TJBCircuitTemplateUserInputDelegate> *)masterController
{
    self = [super init];
    
    self.numberOfRounds = numberOfRounds;
    self.targetingWeight = targetingWeight;
    self.targetingReps = targetingReps;
    self.targetingRest = targetingRest;
    self.targetsVaryByRound = targetsVaryByRound;
    self.chainNumber = chainNumber;
    self.exerciseName = exerciseName;
    self.masterController = masterController;
    
    return self;
}



#pragma mark - Views

- (void)viewDidLoad
{
    self.constraintMapping = [[NSMutableDictionary alloc] init];
    
    // labels
    
    self.titleLabel.text = [NSString stringWithFormat: @"Chain Element %d: %@",
                            [self.chainNumber intValue],
                            self.exerciseName];
    
    // row components
    
    NSString *thinLineLabel = @"thinLineLabel";
    [self.constraintMapping setObject: self.thinLineLabel
                                   forKey: thinLineLabel];
    
    NSString *roundColumnLabel = @"roundColumnLabel";
    [self.constraintMapping setObject:self.roundColumnLabel
                               forKey: roundColumnLabel];
    
    
    
    NSMutableString *verticalLayoutConstraintsString = [NSMutableString stringWithCapacity: 1000];
    [verticalLayoutConstraintsString setString: [NSString stringWithFormat: @"V:[%@]-2-", thinLineLabel]];
    
    for (int i = 0 ; i < [self.numberOfRounds intValue] ; i ++)
    {
        CircuitDesignRowComponent *rowVC = [[CircuitDesignRowComponent alloc] initWithTargetingWeight: self.targetingWeight
                                                                                        targetingReps: self.targetingReps
                                                                                        targetingRest: self.targetingRest
                                                                                   targetsVaryByRound: self.targetsVaryByRound
                                                                                          roundNumber: [NSNumber numberWithInt: i + 1]
                                                                                     masterController: self.masterController
                                                                                          chainNumber: self.chainNumber];
        
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
    
    for (CircuitDesignRowComponent *child in self.childViewControllers)
    {
        [child didMoveToParentViewController: self];
    }
}

#pragma mark - Button Actions

- (IBAction)didPressSelectExercise:(id)sender
{
    [self.masterController didPressExerciseButton: self.selectedExerciseButton
                                          inChain: self.chainNumber];
}

@end




















