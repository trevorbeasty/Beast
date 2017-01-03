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

#import "TJBAestheticsController.h"


@interface CircuitDesignExerciseComponent ()
{
    // core
    BOOL _supportsUserInput;
    BOOL _valuesPopulatedDuringWorkout;
}

// core
@property (nonatomic, strong) NSNumber *numberOfRounds;
@property (nonatomic, strong) NSNumber *targetingWeight;
@property (nonatomic, strong) NSNumber *targetingReps;
@property (nonatomic, strong) NSNumber *targetingRest;
@property (nonatomic, strong) NSNumber *targetsVaryByRound;

@property (nonatomic, strong) NSNumber *chainNumber;
@property (nonatomic, strong) NSString *exerciseName;

@property (nonatomic, strong) TJBChainTemplate *chainTemplate;

@property (nonatomic, strong) NSMutableDictionary *constraintMapping;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *roundColumnLabel;
@property (weak, nonatomic) IBOutlet UILabel *weightColumnLabel;
@property (weak, nonatomic) IBOutlet UILabel *repsColumnLabel;
@property (weak, nonatomic) IBOutlet UILabel *restColumnLabel;
@property (weak, nonatomic) IBOutlet UILabel *thinLineLabel;


@property (weak, nonatomic) IBOutlet UIButton *selectedExerciseButton;
- (IBAction)didPressSelectExercise:(id)sender;

@property (nonatomic, strong) TJBCircuitTemplateGeneratorVC <TJBCircuitTemplateUserInputDelegate> *masterController;

@end

@implementation CircuitDesignExerciseComponent

#pragma mark - Instantiation

- (instancetype)initWithNumberOfRounds:(NSNumber *)numberOfRounds targetingWeight:(NSNumber *)targetingWeight targetingReps:(NSNumber *)targetingReps targetingRest:(NSNumber *)targetingRest targetsVaryByRound:(NSNumber *)targetsVaryByRound chainNumber:(NSNumber *)chainNumber exerciseName:(NSString *)exerciseName masterController:(TJBCircuitTemplateGeneratorVC<TJBCircuitTemplateUserInputDelegate> *)masterController supportsUserInput:(BOOL)supportsUserInput chainTemplate:(id)chainTemplate valuesPopulatedDuringWorkout:(BOOL)valuesPopulatedDuringWorkout{
    self = [super init];
    
    self.numberOfRounds = numberOfRounds;
    self.targetingWeight = targetingWeight;
    self.targetingReps = targetingReps;
    self.targetingRest = targetingRest;
    self.targetsVaryByRound = targetsVaryByRound;
    self.chainNumber = chainNumber;
    self.exerciseName = exerciseName;
    self.masterController = masterController;
    _supportsUserInput = supportsUserInput;
    self.chainTemplate = chainTemplate;
    
    _valuesPopulatedDuringWorkout = valuesPopulatedDuringWorkout;
    
    return self;
}



#pragma mark - Views

- (void)viewAesthetics{
    CALayer *viewLayer = self.view.layer;
    viewLayer.masksToBounds = YES;
    viewLayer.cornerRadius = 8.0;
    viewLayer.opacity = .85;
    
    NSArray *labelViews = @[self.roundColumnLabel,
                            self.weightColumnLabel,
                            self.repsColumnLabel,
                            self.restColumnLabel];
    for (UIView *view in labelViews){
        view.backgroundColor = [[TJBAestheticsController singleton] labelType1Color];
        view.layer.opacity = .85;
    }
    
    self.titleLabel.backgroundColor = [UIColor darkGrayColor];
    [self.titleLabel setTextColor: [UIColor whiteColor]];
    
    self.selectedExerciseButton.backgroundColor = [[TJBAestheticsController singleton] buttonBackgroundColor];
    UIColor *color = [[TJBAestheticsController singleton] buttonTextColor];
    [self.selectedExerciseButton setTitleColor: color
                                      forState: UIControlStateNormal];
    CALayer *layer = self.selectedExerciseButton .layer;
    layer.masksToBounds = YES;
    layer.cornerRadius = 8;
    layer.opacity = .85;
}

- (void)viewDidLoad
{
    [self viewAesthetics];
    
    if (_supportsUserInput == NO){
        [self.selectedExerciseButton setTitle: self.exerciseName
                                     forState: UIControlStateNormal];
        self.selectedExerciseButton.backgroundColor = [UIColor whiteColor];
        [self.selectedExerciseButton setTitleColor: [UIColor blackColor]
                                          forState: UIControlStateNormal];
    }
    
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
    
    for (int i = 0 ; i < [self.numberOfRounds intValue] ; i ++)
    {
        CircuitDesignRowComponent *rowVC = [[CircuitDesignRowComponent alloc] initWithTargetingWeight: self.targetingWeight
                                                                                        targetingReps: self.targetingReps
                                                                                        targetingRest: self.targetingRest
                                                                                   targetsVaryByRound: self.targetsVaryByRound
                                                                                          roundNumber: [NSNumber numberWithInt: i + 1]
                                                                                     masterController: self.masterController
                                                                                          chainNumber: self.chainNumber
                                                                                    supportsUserInput: _supportsUserInput
                                                                                        chainTemplate: self.chainTemplate
                                                                         valuesPopulatedDuringWorkout: _valuesPopulatedDuringWorkout];
        // add the newly created row component to the master controller's child collection
        [self.masterController addChildRowController: rowVC
                                    forExerciseIndex: [self.chainNumber intValue]
                                          roundIndex: i];
        
        rowVC.view.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addChildViewController: rowVC];
        
        [self.view addSubview: rowVC.view];
        
        NSString *dynamicRowName = [NSString stringWithFormat: @"rowComponent%d",
                                    i];
        
        [self.constraintMapping setObject: rowVC.view
                                   forKey: dynamicRowName];
        
        // vertical constraints
        
        NSString *verticalAppendString;
        
        if ([self.targetsVaryByRound intValue] == 0 && _supportsUserInput == YES)
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
    if (_supportsUserInput == YES){
        [self.masterController didPressExerciseButton: self.selectedExerciseButton
                                          inChain: self.chainNumber];
    }
}

@end





















