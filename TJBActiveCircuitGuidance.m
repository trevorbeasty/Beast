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

#import "TJBCircuitTemplateGeneratorVC.h"

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
@property (weak, nonatomic) IBOutlet UIView *containerView;

@property (weak, nonatomic) IBOutlet UILabel *weightColumnLabel;
@property (weak, nonatomic) IBOutlet UILabel *repsColumnLabel;
@property (weak, nonatomic) IBOutlet UILabel *exerciseColumnLabel;
@property (weak, nonatomic) IBOutlet UILabel *roundColumnLabel;

@property (weak, nonatomic) IBOutlet UILabel *exerciseLabel;
@property (weak, nonatomic) IBOutlet UILabel *weightLabel;
@property (weak, nonatomic) IBOutlet UILabel *repsLabel;
@property (weak, nonatomic) IBOutlet UILabel *restLabel;

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

@property (nonatomic, weak) TJBCircuitTemplateGeneratorVC<TJBCircuitTemplateUserInputDelegate> *circuitTemplateGenerator;

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
    // container view
    UIView *container = self.containerView;
    container.backgroundColor = [UIColor whiteColor];
    CALayer *containerLayer = container.layer;
    containerLayer.masksToBounds = YES;
    containerLayer.cornerRadius = 8.0;
    containerLayer.opacity = .75;
    
    // labels
    NSArray *labels = @[self.exerciseColumnLabel,
                        self.weightColumnLabel,
                        self.repsColumnLabel];
    for (UILabel *label in labels){
        label.backgroundColor = [[TJBAestheticsController singleton] labelType1Color];
    }
    
    // buttons
    [[TJBAestheticsController singleton] configureButtonsInArray: @[self.beginSetButton]
                                                     withOpacity: 1];
    
    // dynamic labels
    
    
    // round and timer labels
    NSArray *otherLabels = @[self.roundColumnLabel,
                             self.restLabel];
    for (UILabel *label in otherLabels){
        label.backgroundColor = [UIColor darkGrayColor];
        [label setTextColor: [UIColor whiteColor]];
    }
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
    NSString *notTargetedString = @"not targeted";
    if (self.chainTemplate.targetingWeight == YES){
        self.weightLabel.text = [[NSNumber numberWithDouble: _activeTargetWeight] stringValue];
    } else{
        self.weightLabel.text = notTargetedString;
    }
 
    if (self.chainTemplate.targetingReps == YES){
        self.repsLabel.text = [[NSNumber numberWithDouble: _activeTargetReps] stringValue];
    } else{
        self.repsLabel.text = notTargetedString;
    }

    self.restLabel.text = @"";

    TJBExercise *exercise = self.chainTemplate.exercises[0];
    self.exerciseLabel.text = exercise.name;
    
    NSString *roundText = [NSString stringWithFormat: @"Round 1/%d",
                           [self.numberOfRounds intValue]];
    self.roundColumnLabel.text = roundText;
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

#pragma mark - Init

- (instancetype)initWithChainTemplate:(TJBChainTemplate *)chainTemplate circuitTemplateGenerator:(TJBCircuitTemplateGeneratorVC<TJBCircuitTemplateUserInputDelegate> *)circuitTemplateGenerator{
    self = [super init];
    
    // IV's
    
    self.chainTemplate = chainTemplate;
    self.circuitTemplateGenerator = circuitTemplateGenerator;
    
    [self setDerivedInstanceVariables];
    
    [self initializeActiveInstanceVariables];
    
    return self;
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
    
    if(!self.selectedTimeDelay){
        NumberSelectedBlock numberSelectedBlock = ^(NSNumber *number){
            self.selectedTimeDelay = number;
            [self dismissViewControllerAnimated: NO
                                     completion: nil];
            [self didPressBeginSet];
            
            // circuit template generator
            NSDate *date = [NSDate dateWithTimeIntervalSinceNow: [number intValue]];
            
            if ([self.circuitTemplateGenerator doesNotSupportUserInputAndIsPopulatingValuesDuringWorkout] == YES){
                [self.circuitTemplateGenerator userDidSelectNumber: 0
                                                    withNumberType: RestType
                                                  forExerciseIndex: _activeExerciseIndex
                                                     forRoundIndex: _activeRoundIndex
                                                              date: date
                                                       setDateType: SetBeginDate];
            }
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
    else if (_setCompletedButtonPressed == NO){
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
    else if (!self.selectedTimeLag){
        NumberSelectedBlock numberSelectedBlock = ^(NSNumber *number){
            self.selectedTimeLag = number;
            [self dismissViewControllerAnimated: NO
                                     completion: nil];
            
            // stopwatch
            _activeTargetRestTime = self.chainTemplate.targetRestTimeArrays[_activeExerciseIndex].numbers[_activeRoundIndex].value;
            TJBStopwatch *stopwatch = [TJBStopwatch singleton];
            int restTimeAccountingForLag = _activeTargetRestTime - [number intValue];
            self.restLabel.text = [stopwatch minutesAndSecondsStringFromNumberOfSeconds: restTimeAccountingForLag];
            [stopwatch setPrimaryStopWatchToTimeInSeconds: restTimeAccountingForLag
                                  withForwardIncrementing: NO];
            if (_restLabelAddedAsStopwatchObserver == NO){
                [[TJBStopwatch singleton] addPrimaryStopwatchObserver: self.restLabel];
            }
            
            // core data
            NSDate *date = [NSDate dateWithTimeIntervalSinceNow: [number intValue] * -1];
            
            TJBDateTypeArrayComp *arrayComp = self.realizedChain.dateArrays[_activeExerciseIndex].dates[_activeRoundIndex];
            arrayComp.value = date;
            arrayComp.isDefaultObject = NO;
            
            // circuit template generator
            if ([self.circuitTemplateGenerator doesNotSupportUserInputAndIsPopulatingValuesDuringWorkout] == YES){
                [self.circuitTemplateGenerator userDidSelectNumber: 0
                                                    withNumberType: RestType
                                                  forExerciseIndex: _activeExerciseIndex
                                                     forRoundIndex: _activeRoundIndex
                                                              date: date
                                                       setDateType: SetEndDate];
            }
            
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
    else if (!self.selectedWeight){
        NumberSelectedBlock numberSelectedBlock = ^(NSNumber *number){
            self.selectedWeight = number;
            [self dismissViewControllerAnimated: NO
                                     completion: nil];
            
            // core data
            TJBNumberTypeArrayComp *arrayComp = self.realizedChain.weightArrays[_activeExerciseIndex].numbers[_activeRoundIndex];
            arrayComp.value = [number floatValue];
            arrayComp.isDefaultObject = NO;
            
            // circuit template generator
            if ([self.circuitTemplateGenerator doesNotSupportUserInputAndIsPopulatingValuesDuringWorkout] == YES){
                [self.circuitTemplateGenerator userDidSelectNumber: [number doubleValue]
                                                    withNumberType: WeightType
                                                  forExerciseIndex: _activeExerciseIndex
                                                     forRoundIndex: _activeRoundIndex
                                                              date: nil
                                                       setDateType: SetDateNullType];
            }
            
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
    else if (!self.selectedReps){
        NumberSelectedBlock numberSelectedBlock = ^(NSNumber *number){
            self.selectedReps = number;
            [self dismissViewControllerAnimated: NO
                                     completion: nil];
            
            // core data
            TJBNumberTypeArrayComp *arrayComp = self.realizedChain.repsArrays[_activeExerciseIndex].numbers[_activeRoundIndex];
            arrayComp.value = [number floatValue];
            arrayComp.isDefaultObject = NO;
            
            // circuit template generator
            if ([self.circuitTemplateGenerator doesNotSupportUserInputAndIsPopulatingValuesDuringWorkout] == YES){
                [self.circuitTemplateGenerator userDidSelectNumber: [number doubleValue]
                                                    withNumberType: RepsType
                                                  forExerciseIndex: _activeExerciseIndex
                                                     forRoundIndex: _activeRoundIndex
                                                              date: nil
                                                       setDateType: SetDateNullType];
            }
            
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
    else{
        // order dependent - addSelectedValues... must be called before incrementController...
        [self addSelectedValuesToRealizedChainObject];
        [self incrementControllerAndUpdateViews];
        [self setUserSelectedValuesToNil];
    }
}

- (void)addSelectedValuesToRealizedChainObject{
    // need to ammend core data model to include start date as well as end date
    TJBRealizedChain *chain = self.realizedChain;
    
    TJBNumberTypeArrayComp *weight = chain.weightArrays[_activeExerciseIndex].numbers[_activeRoundIndex];
    weight.value = [self.selectedWeight floatValue];
    weight.isDefaultObject = NO;
    
    TJBNumberTypeArrayComp *reps = chain.repsArrays[_activeExerciseIndex].numbers[_activeRoundIndex];
    reps.value = [self.selectedReps floatValue];
    reps.isDefaultObject = NO;
}

- (void)incrementControllerAndUpdateViews{
    _previousExerciseIndex = _activeExerciseIndex;
    _previousRoundIndex = _activeRoundIndex;
    
    BOOL atMaxRoundIndex = _activeRoundIndex == [self.numberOfRounds intValue] - 1;
    BOOL atMaxExerciseIndex = _activeExerciseIndex == [self.numberOfExercises intValue] - 1;
    
    if (atMaxExerciseIndex){
        if (atMaxRoundIndex){
            NSLog(@"reached end of circuit");
            abort();
        } else{
            _activeRoundIndex++;
            _activeExerciseIndex = 0;
            
            NSString *roundText = [NSString stringWithFormat: @"Round %d/%d",
                                   _activeRoundIndex + 1,
                                   [self.numberOfRounds intValue]];
            self.roundColumnLabel.text = roundText;
        }
    } else{
        _activeExerciseIndex++;
    }
    
    TJBChainTemplate *chainTemplate = self.chainTemplate;
    
    if (chainTemplate.targetingWeight == YES){
        _activeTargetWeight = self.chainTemplate.weightArrays[_activeExerciseIndex].numbers[_activeRoundIndex].value;
        self.weightLabel.text = [[NSNumber numberWithFloat: _activeTargetWeight] stringValue];
    }

    if (chainTemplate.targetingReps == YES){
        _activeTargetReps = self.chainTemplate.repsArrays[_activeExerciseIndex].numbers[_activeRoundIndex].value;
        self.repsLabel.text = [[NSNumber numberWithFloat: _activeTargetReps] stringValue];
    }
    
    TJBExercise *exercise = self.chainTemplate.exercises[_activeExerciseIndex];
    self.exerciseLabel.text = exercise.name;
    

}

- (void)quit{
    [self dismissViewControllerAnimated: NO
                             completion: nil];
}

- (void)presentNumberSelectionSceneWithNumberType:(NumberType)numberType numberMultiple:(NSNumber *)numberMultiple numberLimit:(NSNumber *)numberLimit title:(NSString *)title cancelBlock:(void(^)(void))cancelBlock numberSelectedBlock:(void(^)(NSNumber *))numberSelectedBlock animated:(BOOL)animated modalTransitionStyle:(UIModalTransitionStyle)transitionStyle{
    
    TJBNumberSelectionVC *numberSelectionVC = [[TJBNumberSelectionVC alloc] initWithNumberTypeIdentifier: numberType
                                                                                          numberMultiple: numberMultiple
                                                                                             numberLimit: numberLimit
                                                                                                   title: title
                                                                                             cancelBlock: cancelBlock
                                                                                     numberSelectedBlock: numberSelectedBlock];
    
    numberSelectionVC.modalTransitionStyle = transitionStyle;
    
    [self presentViewController: numberSelectionVC
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
































