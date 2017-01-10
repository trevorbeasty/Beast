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

#import "TJBInSetVC.h"

#import "TJBNumberSelectionVC.h"

#import "TJBAestheticsController.h"

#import "TJBCircuitTemplateGeneratorVC.h"

@interface TJBActiveCircuitGuidance () <UIViewControllerRestoration>

// active IV's
@property NSNumber *activeExerciseIndex;
@property NSNumber *activeRoundIndex;
@property NSNumber *previousExerciseIndex;
@property NSNumber *previousRoundIndex;
    
@property NSNumber *activeTargetWeight;
@property NSNumber *activeTargetReps;
@property NSNumber *activeTargetRestTime;
    
// user selection progression
@property NSNumber *setCompletedButtonPressed;
@property NSNumber *restLabelAddedAsStopwatchObserver;


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
@property (nonatomic, strong) NSDate *impliedBeginDate;
@property (nonatomic, strong) NSNumber *selectedTimeLag;
@property (nonatomic, strong) NSDate *impliedEndDate;
@property (nonatomic, strong) NSNumber *selectedWeight;
@property (nonatomic, strong) NSNumber *selectedReps;

// realized chain
@property (nonatomic, strong) TJBRealizedChain *realizedChain;

@property (nonatomic, weak) TJBCircuitTemplateGeneratorVC<TJBCircuitTemplateUserInputDelegate> *circuitTemplateGenerator;

// state restoration

@property (copy) void (^restorationBlock)(void);

@end

static NSString * const defaultValue = @"default value";

@implementation TJBActiveCircuitGuidance

#pragma mark - View Cycle

- (void)viewDidLoad{
    [self configureViewData];
    [self addBackgroundImage];
    [self viewAesthetics];
}

- (void)viewDidAppear:(BOOL)animated{
    
    if (self.restorationBlock){
        
        self.restorationBlock();
        self.restorationBlock = nil;
    }
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
        self.weightLabel.text = [self.activeTargetWeight stringValue];
    } else{
        self.weightLabel.text = notTargetedString;
    }
 
    if (self.chainTemplate.targetingReps == YES){
        self.repsLabel.text = [self.activeTargetReps stringValue];
    } else{
        self.repsLabel.text = notTargetedString;
    }

    // the NSNumber activeTargetRestTimie is only created upon state restoration;  it is set to nil during normal instantiation
    
    if (self.activeTargetRestTime){
        
        NSString *restString = [[TJBStopwatch singleton] minutesAndSecondsStringFromNumberOfSeconds: [self.activeTargetRestTime intValue]];
        self.restLabel.text = restString;
    } else{
        
        self.restLabel.text = @"";
    }
    

    TJBExercise *exercise = self.chainTemplate.exercises[0];
    self.exerciseLabel.text = exercise.name;
    
    NSString *roundText = [NSString stringWithFormat: @"Round %d/%d",
                           [self.activeRoundIndex intValue] + 1,
                           [self.numberOfRounds intValue]];
    self.roundColumnLabel.text = roundText;
}



#pragma mark - Init

- (instancetype)initWithChainTemplate:(TJBChainTemplate *)chainTemplate circuitTemplateGenerator:(TJBCircuitTemplateGeneratorVC<TJBCircuitTemplateUserInputDelegate> *)circuitTemplateGenerator{
    self = [super init];
    
    // IV's
    
    self.chainTemplate = chainTemplate;
    self.circuitTemplateGenerator = circuitTemplateGenerator;
    
    [self setDerivedInstanceVariables];
    
    [self setRestorationProperties];
    
    [self initializeActiveInstanceVariables];
    
    [self createSkeletonForRealizedChainObject];
    
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
    
    realizedChain.uniqueID = [[NSUUID UUID] UUIDString];
    realizedChain.dateCreated = [NSDate date];
    realizedChain.postMortem = NO;
    realizedChain.isIncomplete = YES;
    realizedChain.firstIncompleteRoundIndex = 0;
    realizedChain.firstIncompleteExerciseIndex = 0;
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
    
    // 'set' begin and end dates
    
    NSMutableOrderedSet *setBeginDateArrays = [[NSMutableOrderedSet alloc] init];
    realizedChain.setBegindateArrays = setBeginDateArrays;
    
    NSMutableOrderedSet *setEndDateArrays = [[NSMutableOrderedSet alloc] init];
    realizedChain.setEndDateArrays = setEndDateArrays;
    
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
        
        // set begin dates
        
        SetBeginDateArray *setBeginDateArray = [NSEntityDescription insertNewObjectForEntityForName: @"SetBeginDateArray"
                                                                inManagedObjectContext: moc];
        setBeginDateArray.realizedChain = realizedChain;
        
        [setBeginDateArrays addObject: setBeginDateArray];
        NSMutableOrderedSet *setBeginDateArrayDates = [[NSMutableOrderedSet alloc] init];
        setBeginDateArray.dates = setBeginDateArrayDates;
        
        // set end dates
        
        SetEndDateArray *setEndDateArray = [NSEntityDescription insertNewObjectForEntityForName: @"SetEndDateArray"
                                                                         inManagedObjectContext: moc];
        setEndDateArray.realizedChain = realizedChain;
        
        [setEndDateArrays addObject: setEndDateArray];
        NSMutableOrderedSet *setEndDateArrayDates = [[NSMutableOrderedSet alloc] init];
        setEndDateArray.dates = setEndDateArrayDates;

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
            
            // set begin dates
            
            TJBBeginDateComp *beginDateComp = [NSEntityDescription insertNewObjectForEntityForName: @"BeginDateComp"
                                                                                         inManagedObjectContext: moc];
            
            [setBeginDateArrayDates addObject: beginDateComp];
            
            beginDateComp.isDefaultObject = YES;
            beginDateComp.owningArray = setBeginDateArray;
            
            // set end dates
            
            TJBEndDateComp *endDateComp = [NSEntityDescription insertNewObjectForEntityForName: @"EndDateComp"
                                                                        inManagedObjectContext: moc];
            
            [setEndDateArrayDates addObject: beginDateComp];
            
            endDateComp.isDefaultObject = YES;
            endDateComp.owningArray = setEndDateArray;
        }
    }
    
    [[CoreDataController singleton] saveContext];
}

- (void)initializeActiveInstanceVariables{
    self.activeRoundIndex = [NSNumber numberWithInt: 0];
    self.activeExerciseIndex = [NSNumber numberWithInt: 0];
    self.activeTargetRestTime = nil;
    
    TJBChainTemplate *chainTemplate = self.chainTemplate;
    
    if (chainTemplate.targetingWeight == YES)
        self.activeTargetWeight = [NSNumber numberWithDouble: chainTemplate.weightArrays[0].numbers[0].value];
    if (chainTemplate.targetingReps == YES)
        self.activeTargetReps = [NSNumber numberWithDouble: chainTemplate.repsArrays[0].numbers[0].value];
    
    self.setCompletedButtonPressed = [NSNumber numberWithBool: NO];
}

- (void)setRestorationProperties{
    self.restorationIdentifier = @"TJBActiveCircuitGuidance";
    self.restorationClass = [TJBActiveCircuitGuidance class];
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
    
    // used in following statements
    
    int exerciseIndex = [self.activeExerciseIndex intValue];
    int roundIndex = [self.activeRoundIndex intValue];
    
    BOOL buttonWasNotPressed = [self.setCompletedButtonPressed boolValue] == NO;
    
    // recursive if tree
    
    if(!self.selectedTimeDelay){
        NumberSelectedBlock numberSelectedBlock = ^(NSNumber *number){
            self.selectedTimeDelay = number;
            
            // calculate the implied begin date and add store it
            
            self.impliedBeginDate = [NSDate dateWithTimeIntervalSinceNow: [number intValue]];
            
            [self dismissViewControllerAnimated: NO
                                     completion: nil];
            [self didPressBeginSet];
            
            // circuit template generator
            
            NSDate *date = [NSDate dateWithTimeIntervalSinceNow: [number intValue]];
            
            if ([self.circuitTemplateGenerator doesNotSupportUserInputAndIsPopulatingValuesDuringWorkout] == YES){
                [self.circuitTemplateGenerator userDidSelectNumber: 0
                                                    withNumberType: RestType
                                                  forExerciseIndex: exerciseIndex
                                                     forRoundIndex: roundIndex
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
    } else if (buttonWasNotPressed){
        void(^block)(int) = ^(int timeInSeconds){
            self.setCompletedButtonPressed = [NSNumber numberWithBool: YES];
            [self dismissViewControllerAnimated: NO
                                     completion: nil];
            [self didPressBeginSet];
        };
        
        TJBInSetVC *vc = [[TJBInSetVC alloc] initWithTimeDelay: [self.selectedTimeDelay intValue]
                                     DidPressSetCompletedBlock: block
                                                  exerciseName: self.chainTemplate.exercises[exerciseIndex].name];
        
        [self presentViewController: vc
                           animated: NO
                         completion: nil];
    }else if (!self.selectedTimeLag){
        
        NumberSelectedBlock numberSelectedBlock = ^(NSNumber *number){
            self.selectedTimeLag = number;
            [self dismissViewControllerAnimated: NO
                                     completion: nil];
            
            // store the implied end date
            
            self.impliedEndDate = [NSDate dateWithTimeIntervalSinceNow: [number intValue] * -1];
            
            // stopwatch
            
            self.activeTargetRestTime = [NSNumber numberWithDouble: self.chainTemplate.targetRestTimeArrays[exerciseIndex].numbers[roundIndex].value];
            TJBStopwatch *stopwatch = [TJBStopwatch singleton];
            int restTimeAccountingForLag = [self.activeTargetRestTime doubleValue] - [number intValue];
            self.restLabel.text = [stopwatch minutesAndSecondsStringFromNumberOfSeconds: restTimeAccountingForLag];
            [stopwatch setPrimaryStopWatchToTimeInSeconds: restTimeAccountingForLag
                                  withForwardIncrementing: NO];
            
            if (_restLabelAddedAsStopwatchObserver == NO){
                
                [[TJBStopwatch singleton] addPrimaryStopwatchObserver: self.restLabel];
            }
            
            // circuit template generator
            
            if ([self.circuitTemplateGenerator doesNotSupportUserInputAndIsPopulatingValuesDuringWorkout] == YES){
                [self.circuitTemplateGenerator userDidSelectNumber: 0
                                                    withNumberType: RestType
                                                  forExerciseIndex: exerciseIndex
                                                     forRoundIndex: roundIndex
                                                              date: self.impliedEndDate
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
            TJBNumberTypeArrayComp *arrayComp = self.realizedChain.weightArrays[exerciseIndex].numbers[roundIndex];
            arrayComp.value = [number floatValue];
            arrayComp.isDefaultObject = NO;
            
            // circuit template generator
            
            if ([self.circuitTemplateGenerator doesNotSupportUserInputAndIsPopulatingValuesDuringWorkout] == YES){
                [self.circuitTemplateGenerator userDidSelectNumber: [number doubleValue]
                                                    withNumberType: WeightType
                                                  forExerciseIndex: exerciseIndex
                                                     forRoundIndex: roundIndex
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
            TJBNumberTypeArrayComp *arrayComp = self.realizedChain.repsArrays[exerciseIndex].numbers[roundIndex];
            arrayComp.value = [number floatValue];
            arrayComp.isDefaultObject = NO;
            
            // circuit template generator
            if ([self.circuitTemplateGenerator doesNotSupportUserInputAndIsPopulatingValuesDuringWorkout] == YES){
                [self.circuitTemplateGenerator userDidSelectNumber: [number doubleValue]
                                                    withNumberType: RepsType
                                                  forExerciseIndex: exerciseIndex
                                                     forRoundIndex: roundIndex
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
        
        // order dependent - addSelectedValues must be called before incrementController
        
        [self addSelectedValuesToRealizedChainObject];
        [self incrementControllerAndUpdateViews];
        [self setUserSelectedValuesToNil];
    }
}


- (void)addSelectedValuesToRealizedChainObject{
    
    // update TJBRealizedChain to account for just completed set
    
    TJBRealizedChain *chain = self.realizedChain;
    
    int exerciseIndex = [self.activeExerciseIndex intValue];
    int roundIndex = [self.activeRoundIndex intValue];
    
    TJBNumberTypeArrayComp *weight = chain.weightArrays[exerciseIndex].numbers[roundIndex];
    weight.value = [self.selectedWeight floatValue];
    weight.isDefaultObject = NO;
    
    TJBNumberTypeArrayComp *reps = chain.repsArrays[exerciseIndex].numbers[roundIndex];
    reps.value = [self.selectedReps floatValue];
    reps.isDefaultObject = NO;
    
    // begin and end set dates
    
    chain.setBegindateArrays[exerciseIndex].dates[roundIndex].value = self.impliedBeginDate;
    chain.setEndDateArrays[exerciseIndex].dates[roundIndex].value = self.impliedEndDate;
    
    // save the managed object context to persist progress made so far
    [[CoreDataController singleton] saveContext];
}

- (void)incrementControllerAndUpdateViews{
    
    self.previousExerciseIndex = self.activeExerciseIndex;
    self.previousRoundIndex = self.activeRoundIndex;
    
    BOOL atMaxRoundIndex = [self.activeRoundIndex intValue] == [self.numberOfRounds intValue] - 1;
    BOOL atMaxExerciseIndex = [self.activeExerciseIndex intValue] == [self.numberOfExercises intValue] - 1;
    
    if (atMaxExerciseIndex){
        
        if (atMaxRoundIndex){
            
            NSLog(@"reached end of circuit");
            abort();
        } else{
            
            self.activeRoundIndex = [NSNumber numberWithInt: [self.activeRoundIndex intValue] + 1];
            self.activeExerciseIndex = [NSNumber numberWithInt: 0];
            
            NSString *roundText = [NSString stringWithFormat: @"Round %d/%d",
                                   [self.activeRoundIndex intValue] + 1,
                                   [self.numberOfRounds intValue]];
            self.roundColumnLabel.text = roundText;
        }
        
    } else{

        self.activeExerciseIndex = [NSNumber numberWithInt: [self.activeExerciseIndex intValue] + 1];
    }
    
    TJBChainTemplate *chainTemplate = self.chainTemplate;
    
    int exerciseIndex = [self.activeExerciseIndex intValue];
    int roundIndex = [self.activeRoundIndex intValue];
    
    if (chainTemplate.targetingWeight == YES){
        self.activeTargetWeight = [NSNumber numberWithDouble: self.chainTemplate.weightArrays[exerciseIndex].numbers[roundIndex].value];
        self.weightLabel.text = [self.activeTargetWeight stringValue];
    }

    if (chainTemplate.targetingReps == YES){
        self.activeTargetReps = [NSNumber numberWithDouble: self.chainTemplate.repsArrays[exerciseIndex].numbers[roundIndex].value];
        self.repsLabel.text = [self.activeTargetReps stringValue];
    }
    
    TJBExercise *exercise = self.chainTemplate.exercises[exerciseIndex];
    self.exerciseLabel.text = exercise.name;
}


- (void)quit{
    // this will only ever be called before the chain has been completed, so no need to check if the set is completed in method body

    // present alert controller that gives the option to save or discard progress
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"Circuit Not Completed"
                                                                   message: @"Save or discard progress that has been made?"
                                                            preferredStyle: UIAlertControllerStyleAlert];
    
    void (^discardHandler)(UIAlertAction *) = ^(UIAlertAction *action){
        
        // reset the managed object context and nullify the IV referencing the previously inserted TJBRealizedChain
        
        TJBRealizedChain *chain = self.realizedChain;
        
        self.realizedChain = nil;
        [[CoreDataController singleton] deleteChainWithChainType: RealizedChainType
                                                           chain: chain];
//        [[[CoreDataController singleton] moc] reset];
        [self.tabBarController.presentingViewController dismissViewControllerAnimated: NO
                                                                           completion: nil];
    };
    
    void (^saveHandler)(UIAlertAction *) = ^(UIAlertAction *action){
        
        // save the managed object context and update the 'first complete' type core data properties of TJBRealizedCHain
        
        self.realizedChain.firstIncompleteRoundIndex = [self.activeRoundIndex intValue];
        self.realizedChain.firstIncompleteExerciseIndex = [self.activeExerciseIndex intValue];
        
        [[CoreDataController singleton] saveContext];
        
        [self.tabBarController.presentingViewController dismissViewControllerAnimated: NO
                                                                           completion: nil];
    };
    
    UIAlertAction *discardAction = [UIAlertAction actionWithTitle: @"Discard"
                                                            style: UIAlertActionStyleDefault
                                                          handler: discardHandler];
    UIAlertAction *saveAction = [UIAlertAction actionWithTitle: @"Save"
                                                         style: UIAlertActionStyleDefault
                                                       handler: saveHandler];
    
    [alert addAction: discardAction];
    [alert addAction: saveAction];
    
    [self presentViewController: alert
                       animated: YES
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
    self.impliedBeginDate = nil;
    self.impliedEndDate = nil;
    self.setCompletedButtonPressed = nil;
    self.selectedWeight = nil;
    self.selectedReps = nil;
}

#pragma mark - <UIViewControllerRestoration>

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder{
    
    TJBActiveCircuitGuidance * vc = [[TJBActiveCircuitGuidance alloc] init];
    
    vc.activeExerciseIndex = [coder decodeObjectForKey: @"activeExerciseIndex"];
    vc.activeRoundIndex = [coder decodeObjectForKey: @"activeRoundIndex"];
    vc.previousExerciseIndex = [coder decodeObjectForKey: @"previousRoundIndex"];
    vc.previousRoundIndex = [coder decodeObjectForKey: @"previousRoundIndex"];
    vc.activeTargetWeight = [coder decodeObjectForKey: @"activeTargetWeight"];
    vc.activeTargetReps = [coder decodeObjectForKey: @"activeTargetReps"];
    vc.activeTargetRestTime = [coder decodeObjectForKey: @"activeTargetRestTime"];
    
    // derived IV's
    
    vc.numberOfExercises = [coder decodeObjectForKey: @"numberOfExercises"];
    vc.numberOfRounds = [coder decodeObjectForKey: @"numberOfRounds"];
    
    // core
    
    NSString *chainTemplateUniqueID = [coder decodeObjectForKey: @"chainTemplateUniqueID"];
    vc.chainTemplate = [[CoreDataController singleton] chainTemplateWithUniqueID: chainTemplateUniqueID];
    
    NSString *realizedChainUniqueID = [coder decodeObjectForKey: @"realizedChainUniqueID"];
    vc.realizedChain = [[CoreDataController singleton] realizedChainWithUniqueID: realizedChainUniqueID];
    
    // state restoration
    
    [vc setRestorationProperties];
    
    // user selection
    
    vc.selectedTimeDelay = [coder decodeObjectForKey: @"selectedTimeDelay"];
    vc.impliedBeginDate = [coder decodeObjectForKey: @"impliedBeginDate"];
    vc.setCompletedButtonPressed = [coder decodeObjectForKey: @"setCompletedButtonPressed"];
    vc.selectedTimeLag = [coder decodeObjectForKey: @"selectedTimeLag"];
    vc.impliedEndDate = [coder decodeObjectForKey: @"impliedEndDate"];
    vc.selectedWeight = [coder decodeObjectForKey: @"selectedWeight"];
    vc.selectedReps = [coder decodeObjectForKey: @"selectedReps"];
    
    [vc setRestorationProperties];
    
    return vc;
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder{
    
    [super encodeRestorableStateWithCoder: coder];
    
    // active IV's
    
    [coder encodeObject: self.activeExerciseIndex
                 forKey: @"activeExerciseIndex"];
    [coder encodeObject: self.activeRoundIndex
                 forKey: @"activeRoundIndex"];
    [coder encodeObject: self.previousExerciseIndex
                 forKey: @"previousExerciseIndex"];
    [coder encodeObject: self.previousRoundIndex
                 forKey: @"previousRoundIndex"];
    [coder encodeObject: self.activeTargetWeight
                 forKey: @"activeTargetWeight"];
    [coder encodeObject: self.activeTargetReps
                 forKey: @"activeTargetReps"];
    [coder encodeObject: self.activeTargetRestTime
                 forKey: @"activeTargetRestTime"];
    
    // derived IV's
    
    [coder encodeObject: self.numberOfExercises
                 forKey: @"numberOfExercises"];
    [coder encodeObject: self.numberOfRounds
                 forKey: @"numberOfRounds"];
    
    // core
    
    [coder encodeObject: self.chainTemplate.uniqueID
                 forKey: @"chainTemplateUniqueID"];
    
    [coder encodeObject: self.realizedChain.uniqueID
                 forKey: @"realizedChainUniqueID"];
    
    [coder encodeObject: self.circuitTemplateGenerator
                 forKey: @"circuitTemplateGenerator"];
    
    // user selection
    
    if (self.selectedTimeDelay){
        [coder encodeObject: self.selectedTimeDelay
                     forKey: @"selectedTimeDelay"];
        [coder encodeObject: self.impliedBeginDate
                     forKey: @"impliedBeginDate"];
    }
    
    if (self.setCompletedButtonPressed){
        [coder encodeObject: self.setCompletedButtonPressed
                     forKey: @"setCompletedButtonPressed"];
    }
    
    if (self.selectedTimeLag){
        [coder encodeObject: self.selectedTimeLag
                     forKey: @"selectedTimeLag"];
        [coder encodeObject: self.impliedEndDate
                     forKey: @"impliedEndDate"];
    }
    
    if (self.selectedWeight){
        [coder encodeObject: self.selectedWeight
                     forKey: @"selectedWeight"];
    }
    
    if (self.selectedReps){
        [coder encodeObject: self.selectedReps
                     forKey: @"selectedReps"];
    }
    
    // timer
    
    // the primary stopwatch holds the value of the timer for this VC's view
    // not sure if I'll want to hold on to the primary timer value further into the user selection process.  May need to update the conditional encoding below
    
    int primaryTimerValue = [[[TJBStopwatch singleton] primaryTimeElapsedInSeconds] intValue];
    
    if (!self.selectedTimeDelay){
        [coder encodeInt: primaryTimerValue
                  forKey: @"primaryTimerValue"];
    }
    
    // date - used to determine elapsed time in background state
    
    [coder encodeObject: [NSDate date]
                 forKey: @"enteredBackgroundDate"];
    
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder{
    
    [super decodeRestorableStateWithCoder: coder];
    
    self.circuitTemplateGenerator = [coder decodeObjectForKey: @"circuitTemplateGenerator"];
    
    // elapsed time in background state
    
    NSDate *enteredForegroundDate = [NSDate date];
    NSDate *enteredBackgroundDate = [coder decodeObjectForKey: @"enteredBackgroundDate"];
    
    int elapsedTimeInBackgroundState = [enteredForegroundDate timeIntervalSinceDate: enteredBackgroundDate];
    
    // kick off the user selection process if the user is mid-selection
    // if any of the user selection properties exist, the user must be mid-selection
    
    if (self.selectedTimeDelay){
        
        __weak TJBActiveCircuitGuidance *weakSelf = self;
        
        self.restorationBlock = ^{
            [weakSelf didPressBeginSet];
        };
    }
    
    // timer
    
    if (!self.selectedTimeDelay){
        
        int primaryTimerValue = [coder decodeIntForKey: @"primaryTimerValue"];
        primaryTimerValue -= elapsedTimeInBackgroundState;
        
        TJBStopwatch *stopwatch = [TJBStopwatch singleton];
        
        [stopwatch addPrimaryStopwatchObserver: self.restLabel];
        self.restLabelAddedAsStopwatchObserver = [NSNumber numberWithBool: YES];
        
        self.restLabel.text = [stopwatch minutesAndSecondsStringFromNumberOfSeconds: primaryTimerValue];
        [stopwatch setPrimaryStopWatchToTimeInSeconds: primaryTimerValue
                              withForwardIncrementing: NO];
        
    }
}





@end
































