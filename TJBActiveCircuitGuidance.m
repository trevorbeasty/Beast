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
#import "TJBDateArray+CoreDataProperties.h"
#import "TJBTargetRestTimeArray+CoreDataProperties.h"
#import "TJBNumberArray+CoreDataProperties.h"
#import "TJBNumberTypeArrayComp+CoreDataProperties.h"

#import "TJBStopwatch.h"

#import "TJBInSetVC.h"

#import "TJBNumberSelectionVC.h"

#import "TJBAestheticsController.h"

@interface TJBActiveCircuitGuidance ()

{
    // active IV's
    
    int _activeExerciseIndex;
    int _activeRoundIndex;
    int _previousExerciseIndex;
    int _previousRoundIndex;
    
    float _activeTargetWeight;
    float _activeTargetReps;
    float _activeTargetRestTime;
    
    // user selection progression
    
    BOOL _setCompletedButtonPressed;
    BOOL _restLabelAddedAsStopwatchObserver;
}

- (IBAction)didPressBeginSet;

// UI
@property (weak, nonatomic) IBOutlet UILabel *weightColumnLabel;
@property (weak, nonatomic) IBOutlet UILabel *repsColumnLabel;
@property (weak, nonatomic) IBOutlet UILabel *restColumnLabel;

@property (weak, nonatomic) IBOutlet UILabel *nextUpExerciseLabel;
@property (weak, nonatomic) IBOutlet UILabel *weightLabel;
@property (weak, nonatomic) IBOutlet UILabel *repsLabel;
@property (weak, nonatomic) IBOutlet UILabel *remainingRestLabel;

@property (weak, nonatomic) IBOutlet UIButton *beginSetButton;

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;

// data
@property (nonatomic, strong) TJBChainTemplate *chainTemplate;

// derived IV's
@property (nonatomic, strong) NSNumber *numberOfExercises;
@property (nonatomic, strong) NSNumber *numberOfRounds;

// user selections
@property (nonatomic, strong) NSNumber *selectedTimeDelay;
@property (nonatomic, strong) NSNumber *selectedTimeLag;
@property (nonatomic, strong) NSNumber *selectedWeight;
@property (nonatomic, strong) NSNumber *selectedReps;

// realized chain
@property (nonatomic, strong) TJBRealizedChain *realizedChain;

@end

static NSString * const defaultValue = @"default value";

@implementation TJBActiveCircuitGuidance

#pragma mark - View Cycle

- (void)viewDidLoad{
    [self configureViewData];
    [self createSkeletonForRealizedChainObject];
    [self addBackgroundImage];
    [self viewAesthetics];
}

- (void)addBackgroundImage{
    [[TJBAestheticsController singleton] addFullScreenBackgroundViewWithImage: [UIImage imageNamed: @"FinlandBackSquat"]
                                                                   toRootView: self.view
                                                                 imageOpacity: .45];
}

- (void)viewAesthetics{
    NSArray *labels = @[self.nextUpExerciseLabel,
                        self.weightColumnLabel,
                        self.repsColumnLabel,
                        self.restColumnLabel];
    [TJBAestheticsController configureViewsWithType1Format: labels
                                               withOpacity: .85];
    
    [[TJBAestheticsController singleton] configureButtonsInArray: @[self.beginSetButton]
                                                     withOpacity: .85];
    
}

- (void)configureViewData{
    // nav bar
    UINavigationItem *navItem = [[UINavigationItem alloc] init];
    NSString *title = [NSString stringWithFormat: @"%@",
                       self.chainTemplate.name];
    [navItem setTitle: title];
    UIBarButtonItem *cancelBarButton = [[UIBarButtonItem alloc] initWithTitle: @"Quit"
                                                                        style: UIBarButtonItemStyleDone
                                                                       target: self
                                                                       action: @selector(quit)];
    [navItem setLeftBarButtonItem: cancelBarButton];
    [self.navBar setItems: @[navItem]];
    
    // dynamic views
    if (self.chainTemplate.targetingWeight == YES)
        self.weightLabel.text = [[NSNumber numberWithDouble: _activeTargetWeight] stringValue];
    if (self.chainTemplate.targetingReps == YES)
        self.repsLabel.text = [[NSNumber numberWithDouble: _activeTargetReps] stringValue];
    
    self.remainingRestLabel.text = @"";

    TJBExercise *exercise = self.chainTemplate.exercises[0];
    NSString *activeExerciseTitle = [NSString stringWithFormat: @"First exercise: %@",
                                     exercise.name];
    self.nextUpExerciseLabel.text = activeExerciseTitle;
}

#pragma mark - Init

- (instancetype)initWithChainTemplate:(TJBChainTemplate *)chainTemplate{
    self = [super init];
    
    // IV's
    
    self.chainTemplate = chainTemplate;
    
    [self setDerivedInstanceVariables];
    
    [self initializeActiveInstanceVariables];
    
    return self;
}

- (void)createSkeletonForRealizedChainObject{
    // create managed object
    NSManagedObjectContext *moc = [[CoreDataController singleton] moc];
    TJBRealizedChain *realizedChain = [NSEntityDescription insertNewObjectForEntityForName: @"RealizedChain"
                                                                    inManagedObjectContext: moc];
    self.realizedChain = realizedChain;
    
    // fill managed object with default values for weight, reps, dates
    // exercises are known
    // post-mortem is known
    realizedChain.postMortem = NO;
    realizedChain.chainTemplate = self.chainTemplate;
    realizedChain.exercises = self.chainTemplate.exercises;
    
    int exerciseLimit = [self.numberOfExercises intValue];
    int roundLimit = [self.numberOfRounds intValue];
    
    // weight
    NSMutableOrderedSet *weightArrays = [[NSMutableOrderedSet alloc] init];
    realizedChain.weightArrays = weightArrays;
    
    // reps
    NSMutableOrderedSet *repsArrays = [[NSMutableOrderedSet alloc] init];
    realizedChain.repsArrays = repsArrays;
    
    // date
    NSMutableOrderedSet *dateArrays = [[NSMutableOrderedSet alloc] init];
    realizedChain.dateArrays = dateArrays;
    
    for (int i = 0; i < exerciseLimit; i++){
        // weight
        TJBWeightArray *weightArray = [NSEntityDescription insertNewObjectForEntityForName: @"WeightArray"
                                                                    inManagedObjectContext: moc];
        weightArray.chain = realizedChain;
        
        [weightArrays addObject: weightArray];
        NSMutableOrderedSet *weightArrayNumbers = [[NSMutableOrderedSet alloc] init];
        weightArray.numbers = weightArrayNumbers;
        
        // reps
        TJBRepsArray *repsArray = [NSEntityDescription insertNewObjectForEntityForName: @"RepsArray"
                                                                    inManagedObjectContext: moc];
        repsArray.chain = realizedChain;
        
        [repsArrays addObject: repsArray];
        NSMutableOrderedSet *repsArrayNumbers = [[NSMutableOrderedSet alloc] init];
        repsArray.numbers = repsArrayNumbers;
        
        // date
        TJBDateArray *dateArray = [NSEntityDescription insertNewObjectForEntityForName: @"DateArray"
                                                                inManagedObjectContext: moc];
        dateArray.realizedChain = realizedChain;
        
        [dateArrays addObject: dateArray];
        NSMutableOrderedSet *dateArrayDates = [[NSMutableOrderedSet alloc] init];
        dateArray.dates = dateArrayDates;
        
        for (int j = 0; j < roundLimit; j++){
            // weight
            TJBNumberTypeArrayComp *weightNumberTypeArrayComponent = [NSEntityDescription insertNewObjectForEntityForName: @"NumberTypeArrayComponent"
                                                                                    inManagedObjectContext: moc];
            [weightArrayNumbers addObject: weightNumberTypeArrayComponent];
            weightNumberTypeArrayComponent.isDefaultObject = YES;
            weightNumberTypeArrayComponent.owningArray = weightArray;
            
            // reps
            TJBNumberTypeArrayComp *repsNumberTypeArrayComponent = [NSEntityDescription insertNewObjectForEntityForName: @"NumberTypeArrayComponent"
                                                                                                   inManagedObjectContext: moc];
            [repsArrayNumbers addObject: repsNumberTypeArrayComponent];
            repsNumberTypeArrayComponent.isDefaultObject = YES;
            repsNumberTypeArrayComponent.owningArray = repsArray;
            
            // date
            TJBDateTypeArrayComp *dateTypeArrayComponent = [NSEntityDescription insertNewObjectForEntityForName: @"DateTypeArrayComponent"
                                                                                                   inManagedObjectContext: moc];
            [dateArrayDates addObject: dateTypeArrayComponent];
            dateTypeArrayComponent.isDefaultObject = YES;
            dateTypeArrayComponent.owningArray = dateArray;
        }
    }
    
    [[CoreDataController singleton] saveContext];
}

- (void)initializeActiveInstanceVariables{
    _activeExerciseIndex = 0;
    _activeRoundIndex = 0;
    
    TJBChainTemplate *chainTemplate = self.chainTemplate;
    
    if (chainTemplate.targetingWeight == YES)
        _activeTargetWeight = chainTemplate.weightArrays[0].numbers[0].value;
    if (chainTemplate.targetingReps == YES)
        _activeTargetReps = chainTemplate.repsArrays[0].numbers[0].value;
    
    _setCompletedButtonPressed = NO;
}



- (void)setDerivedInstanceVariables{
    TJBChainTemplate *chainTemplate = self.chainTemplate;
    
    NSNumber *numberOfExercises = [NSNumber numberWithUnsignedLong: [chainTemplate.exercises count]];
    self.numberOfExercises = numberOfExercises;
    
    NSNumber *numberOfRounds;
    
    if (chainTemplate.targetingWeight == YES){
        TJBWeightArray *weightArray = chainTemplate.weightArrays[0];
        numberOfRounds = [NSNumber numberWithUnsignedLong: [weightArray.numbers count]];
    } else if (chainTemplate.targetingReps == YES){
        TJBRepsArray *repsArray = chainTemplate.repsArrays[0];
        numberOfRounds = [NSNumber numberWithUnsignedLong: [repsArray.numbers count]];
    } else if (chainTemplate.targetingRestTime == YES){
        TJBTargetRestTimeArray *restArray = chainTemplate.targetRestTimeArrays[0];
        numberOfRounds = [NSNumber numberWithUnsignedLong: [restArray.numbers count]];
    }

    self.numberOfRounds = numberOfRounds;
}

#pragma mark - Button Actions

-(void)didPressBeginSet{
    CancelBlock cancelBlock = ^{
        [self setUserSelectedValuesToNil];
        [self dismissViewControllerAnimated: NO
                                 completion: nil];
    };
    
    if(!self.selectedTimeDelay)
    {
        NumberSelectedBlock numberSelectedBlock = ^(NSNumber *number){
            self.selectedTimeDelay = number;
            [self dismissViewControllerAnimated: NO
                                     completion: nil];
            [self didPressBeginSet];
        };
        
        
        [self presentNumberSelectionSceneWithNumberType: RestType
                                         numberMultiple: [NSNumber numberWithInt: 5]
                                            numberLimit: nil
                                                  title: @"Select Delay"
                                            cancelBlock: cancelBlock
                                    numberSelectedBlock: numberSelectedBlock
                                               animated: YES
                                   modalTransitionStyle: UIModalTransitionStyleCoverVertical];
    }
    else if (_setCompletedButtonPressed == NO)
    {
        void(^block)(int) = ^(int timeInSeconds){
            _setCompletedButtonPressed = YES;
            [self dismissViewControllerAnimated: NO
                                     completion: nil];
            [self didPressBeginSet];
        };
        
        TJBInSetVC *vc = [[TJBInSetVC alloc] initWithTimeDelay: [self.selectedTimeDelay intValue]
                                     DidPressSetCompletedBlock: block
                          exerciseName: self.chainTemplate.exercises[_activeExerciseIndex].name];
        
        [self presentViewController: vc
                           animated: NO
                         completion: nil];
    }
    else if (!self.selectedTimeLag)
    {
        NumberSelectedBlock numberSelectedBlock = ^(NSNumber *number){
            self.selectedTimeLag = number;
            [self dismissViewControllerAnimated: NO
                                     completion: nil];
            
            // stopwatch
            _activeTargetRestTime = self.chainTemplate.targetRestTimeArrays[_activeExerciseIndex].numbers[_activeRoundIndex].value;
            TJBStopwatch *stopwatch = [TJBStopwatch singleton];
            int restTimeAccountingForLag = _activeTargetRestTime - [number intValue];
            self.remainingRestLabel.text = [stopwatch minutesAndSecondsStringFromNumberOfSeconds: restTimeAccountingForLag];
            [stopwatch setPrimaryStopWatchToTimeInSeconds: restTimeAccountingForLag
                                  withForwardIncrementing: NO];
            if (_restLabelAddedAsStopwatchObserver == NO){
                [[TJBStopwatch singleton] addPrimaryStopwatchObserver: self.remainingRestLabel];
            }
            
            // core data
            NSDate *date = [NSDate dateWithTimeIntervalSinceNow: [number intValue] * -1];
            
            TJBDateTypeArrayComp *arrayComp = self.realizedChain.dateArrays[_activeExerciseIndex].dates[_activeRoundIndex];
            arrayComp.value = date;
            arrayComp.isDefaultObject = NO;
            
            // recursive
            [self didPressBeginSet];
        };
        
        [self presentNumberSelectionSceneWithNumberType: RestType
                                         numberMultiple: [NSNumber numberWithInt: 5]
                                            numberLimit: nil
                                                  title: @"Select Lag"
                                            cancelBlock: cancelBlock
                                    numberSelectedBlock: numberSelectedBlock
                                               animated: YES
                                   modalTransitionStyle: UIModalTransitionStyleCoverVertical];
    }
    else if (!self.selectedWeight)
    {
        NumberSelectedBlock numberSelectedBlock = ^(NSNumber *number){
            self.selectedWeight = number;
            [self dismissViewControllerAnimated: NO
                                     completion: nil];
            
            // core data
            TJBNumberTypeArrayComp *arrayComp = self.realizedChain.weightArrays[_activeExerciseIndex].numbers[_activeRoundIndex];
            arrayComp.value = [number floatValue];
            arrayComp.isDefaultObject = NO;
            
            [self didPressBeginSet];
        };
        
        
        [self presentNumberSelectionSceneWithNumberType: WeightType
                                         numberMultiple: [NSNumber numberWithFloat: 2.5]
                                            numberLimit: nil
                                                  title: @"Select Weight"
                                            cancelBlock: cancelBlock
                                    numberSelectedBlock: numberSelectedBlock
                                               animated: YES
                                   modalTransitionStyle: UIModalTransitionStyleCoverVertical];
    }
    else if (!self.selectedReps)
    {
        NumberSelectedBlock numberSelectedBlock = ^(NSNumber *number){
            self.selectedReps = number;
            [self dismissViewControllerAnimated: NO
                                     completion: nil];
            
            // core data
            TJBNumberTypeArrayComp *arrayComp = self.realizedChain.repsArrays[_activeExerciseIndex].numbers[_activeRoundIndex];
            arrayComp.value = [number floatValue];
            arrayComp.isDefaultObject = NO;
            
            [self didPressBeginSet];
        };
        
        
        [self presentNumberSelectionSceneWithNumberType: RepsType
                                         numberMultiple: [NSNumber numberWithInt: 1]
                                            numberLimit: nil
                                                  title: @"Select Reps"
                                            cancelBlock: cancelBlock
                                    numberSelectedBlock: numberSelectedBlock
                                               animated: YES
                                   modalTransitionStyle: UIModalTransitionStyleCoverVertical];
    }
    else
    {
        [self incrementControllerAndUpdateViews];
        
        [self addSelectedValuesToRealizedChainObject];
        
        [self setUserSelectedValuesToNil];
    }
    
}

- (void)addSelectedValuesToRealizedChainObject{
    
}

- (void)incrementControllerAndUpdateViews{
    _previousExerciseIndex = _activeExerciseIndex;
    _previousRoundIndex = _activeRoundIndex;
    
    BOOL atMaxRoundIndex = _activeRoundIndex == [self.numberOfRounds intValue] - 1;
    BOOL atMaxExerciseIndex = _activeExerciseIndex == [self.numberOfExercises intValue] - 1;
    
    if (atMaxExerciseIndex){
        if (atMaxRoundIndex){
            abort();
        } else{
            _activeRoundIndex++;
            _activeExerciseIndex = 0;
        }
    } else{
        _activeExerciseIndex++;
    }
    
    _activeTargetWeight = self.chainTemplate.weightArrays[_activeExerciseIndex].numbers[_activeRoundIndex].value;
    self.weightLabel.text = [[NSNumber numberWithFloat: _activeTargetWeight] stringValue];
    
    _activeTargetReps = self.chainTemplate.repsArrays[_activeExerciseIndex].numbers[_activeRoundIndex].value;
    self.repsLabel.text = [[NSNumber numberWithFloat: _activeTargetReps] stringValue];
    
    TJBExercise *exercise = self.chainTemplate.exercises[_activeExerciseIndex];
    self.nextUpExerciseLabel.text = [NSString stringWithFormat: @"Round %d - Next up: %@",
                                     _activeRoundIndex + 1,
                                     exercise.name];
}

- (void)quit{
    [self dismissViewControllerAnimated: NO
                             completion: nil];
}

- (void)presentNumberSelectionSceneWithNumberType:(NumberType)numberType numberMultiple:(NSNumber *)numberMultiple numberLimit:(NSNumber *)numberLimit title:(NSString *)title cancelBlock:(void(^)(void))cancelBlock numberSelectedBlock:(void(^)(NSNumber *))numberSelectedBlock animated:(BOOL)animated modalTransitionStyle:(UIModalTransitionStyle)transitionStyle;
{
    
    UIStoryboard *numberSelectionStoryboard = [UIStoryboard storyboardWithName: @"TJBNumberSelection"
                                                                        bundle: nil];
    UINavigationController *numberSelectionNav = (UINavigationController *)[numberSelectionStoryboard instantiateInitialViewController];
    TJBNumberSelectionVC *numberSelectionVC = (TJBNumberSelectionVC *)[numberSelectionNav viewControllers][0];
    
    [numberSelectionVC setNumberTypeIdentifier: numberType
                                numberMultiple: numberMultiple
                                   numberLimit: numberLimit
                                         title: title
                                   cancelBlock: cancelBlock
                           numberSelectedBlock: numberSelectedBlock];
    
    numberSelectionNav.modalTransitionStyle = transitionStyle;
    
    [self presentViewController: numberSelectionNav
                       animated: animated
                     completion: nil];
}

- (void)setUserSelectedValuesToNil{
    self.selectedTimeDelay = nil;
    self.selectedTimeLag = nil;
    _setCompletedButtonPressed = NO;
    self.selectedWeight = nil;
    self.selectedReps = nil;
}

@end
































