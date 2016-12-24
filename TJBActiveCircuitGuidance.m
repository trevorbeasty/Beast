//
//  TJBActiveCircuitGuidance.m
//  Beast
//
//  Created by Trevor Beasty on 12/24/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import "TJBActiveCircuitGuidance.h"

#import "CoreDataController.h"

#import "TJBWeightArray+CoreDataProperties.h"
#import "TJBRepsArray+CoreDataProperties.h"
#import "TJBTargetRestTimeArray+CoreDataProperties.h"
#import "TJBNumberArray+CoreDataProperties.h"
#import "TJBNumberTypeArrayComp+CoreDataProperties.h"

#import "TJBStopwatch.h"

@interface TJBActiveCircuitGuidance ()

{
    // active IV's
    
    int _activeExerciseIndex;
    int _activeRoundIndex;
    float _activeTargetWeight;
    float _activeTargetReps;
    float _activeTargetRestTime;
}

- (IBAction)beginNextSet:(id)sender;

// UI

@property (weak, nonatomic) IBOutlet UIView *containerSubview;


@property (weak, nonatomic) IBOutlet UILabel *nextUpExerciseLabel;
@property (weak, nonatomic) IBOutlet UILabel *weightLabel;
@property (weak, nonatomic) IBOutlet UILabel *repsLabel;
@property (weak, nonatomic) IBOutlet UILabel *remainingRestLabel;

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;

// data

@property (nonatomic, strong) TJBChainTemplate *chainTemplate;

// derived IV's

@property (nonatomic, strong) NSNumber *numberOfExercises;
@property (nonatomic, strong) NSNumber *numberOfRounds;




@end

@implementation TJBActiveCircuitGuidance

#pragma mark - Instantiation

- (void)configureViews{
    // nav bar
    
    UINavigationItem *navItem = [[UINavigationItem alloc] init];
    NSString *title = [NSString stringWithFormat: @"%@",
                       self.chainTemplate.name];
    [navItem setTitle: title];
    UIBarButtonItem *cancelBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCancel
                                                                                     target: self
                                                                                     action: @selector(didPressCancel)];
    [navItem setLeftBarButtonItem: cancelBarButton];
    [self.navBar setItems: @[navItem]];
    
    // dynamic views
    
    self.weightLabel.text = [[NSNumber numberWithDouble: _activeTargetWeight] stringValue];
    self.repsLabel.text = [[NSNumber numberWithDouble: _activeTargetReps] stringValue];
    
    TJBStopwatch *stopwatch = [TJBStopwatch singleton];
    self.remainingRestLabel.text = [[NSNumber numberWithFloat: _activeTargetRestTime] stringValue];
    [stopwatch setPrimaryStopWatchToTimeInSeconds: _activeTargetRestTime
                          withForwardIncrementing: NO];
    [[TJBStopwatch singleton] addPrimaryStopwatchObserver: self.remainingRestLabel];
    
    TJBExercise *exercise = self.chainTemplate.exercises[0];
    NSString *activeExerciseTitle = [NSString stringWithFormat: @"Next up: %@",
                                     exercise.name];
    self.nextUpExerciseLabel.text = activeExerciseTitle;
}

- (void)initializeActiveInstanceVariables{
    _activeExerciseIndex = 0;
    _activeRoundIndex = 0;
    
    TJBChainTemplate *chainTemplate = self.chainTemplate;
    
    _activeTargetWeight = chainTemplate.weightArrays[0].numbers[0].value;
    _activeTargetReps = chainTemplate.repsArrays[0].numbers[0].value;
    _activeTargetRestTime = chainTemplate.targetRestTimeArrays[0].numbers[0].value;
}

- (void)viewDidLoad{
    [self configureViews];
}

- (void)setDerivedInstanceVariables{
    TJBChainTemplate *chainTemplate = self.chainTemplate;
    
    NSNumber *numberOfExercises = [NSNumber numberWithUnsignedLong: [chainTemplate.exercises count]];
    self.numberOfExercises = numberOfExercises;
    
    TJBRepsArray *repsArray = chainTemplate.repsArrays[0];
    NSNumber *numberOfRounds = [NSNumber numberWithUnsignedLong: [repsArray.numbers count]];
    self.numberOfRounds = numberOfRounds;
}


- (instancetype)initWithChainTemplate:(TJBChainTemplate *)chainTemplate{
    self = [super init];
    
    // IV's
    
    self.chainTemplate = chainTemplate;
    
    [self setDerivedInstanceVariables];
    [self initializeActiveInstanceVariables];
    
    return self;
}

#pragma mark - Button Actions

- (IBAction)beginNextSet:(id)sender{
    
}

- (void)didPressCancel{
    [self dismissViewControllerAnimated: NO
                             completion: nil];
}





@end
































