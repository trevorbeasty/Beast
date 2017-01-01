//
//  TJBCircuitTemplateGeneratorVC.m
//  Beast
//
//  Created by Trevor Beasty on 12/16/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import "TJBCircuitTemplateGeneratorVC.h"

// supporting VC's
#import "TJBNumberSelectionVC.h"
#import "TJBExerciseSelectionScene.h"

// core data
#import "CoreDataController.h"

// chain template
#import "TJBChainTemplate+CoreDataProperties.h"

#import "TJBNumberArray+CoreDataProperties.h"

#import "TJBWeightArray+CoreDataProperties.h"
#import "TJBRepsArray+CoreDataProperties.h"
#import "TJBTargetRestTimeArray+CoreDataClass.h"
#import "TJBExercise+CoreDataProperties.h"

#import "TJBNumberTypeArrayComp+CoreDataProperties.h"

#import "TJBStopwatch.h"

#import "TJBActiveCircuitGuidance.h"

#import "TJBAestheticsController.h"

//#import "TJBWeightArray+CoreDataProperties.h"

@interface TJBCircuitTemplateGeneratorVC ()
{
    // core
    BOOL _supportsUserInput;
}
// core
@property (nonatomic, strong) NSNumber *targetingWeight;
@property (nonatomic, strong) NSNumber *targetingReps;
@property (nonatomic, strong) NSNumber *targetingRest;
@property (nonatomic, strong) NSNumber *targetsVaryByRound;
@property (nonatomic, strong) NSNumber *numberOfExercises;
@property (nonatomic, strong) NSNumber *numberOfRounds;
@property (nonatomic, strong) NSString *name;

// view
@property (nonatomic, strong) NSMutableDictionary *constraintMapping;

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (nonatomic, strong) UINavigationItem *navItem;

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

// IBAction
- (IBAction)didPressLaunchCircuit:(id)sender;
@property (weak, nonatomic) IBOutlet UIButton *launchCircuitButton;

// data structure
@property (nonatomic, strong) NSMutableArray *weightData;
@property (nonatomic, strong) NSMutableArray *repsData;
@property (nonatomic, strong) NSMutableArray *restData;
@property (nonatomic, strong) NSMutableArray *exerciseData;

@property (nonatomic, strong) TJBChainTemplate *chainTemplate;

@end

// constants
static NSString * const defaultValue = @"unselected";

@implementation TJBCircuitTemplateGeneratorVC

#pragma mark - Instantiation

- (instancetype)initWithTargetingWeight:(NSNumber *)targetingWeight targetingReps:(NSNumber *)targetingReps targetingRest:(NSNumber *)targetingRest targetsVaryByRound:(NSNumber *)targetsVaryByRound numberOfExercises:(NSNumber *)numberOfExercises numberOfRounds:(NSNumber *)numberOfRounds name:(NSString *)name supportsUserInput:(BOOL)supportsUserInput{
    self = [super init];
    
    self.targetingWeight = targetingWeight;
    self.targetingReps = targetingReps;
    self.targetingRest = targetingRest;
    self.targetsVaryByRound = targetsVaryByRound;
    self.numberOfExercises = numberOfExercises;
    self.numberOfRounds = numberOfRounds;
    self.name = name;
    
    _supportsUserInput = supportsUserInput;
    
    return self;
}

- (instancetype)initWithChainTemplate:(TJBChainTemplate *)chainTemplate supportsUserInput:(BOOL)supportsUserInput{
    self = [super init];
    
    self.targetingWeight = [NSNumber numberWithBool: chainTemplate.targetingWeight];
    self.targetingReps = [NSNumber numberWithBool: chainTemplate.targetingReps];
    self.targetingRest = [NSNumber numberWithBool: chainTemplate.targetingRestTime];
    self.targetsVaryByRound = [NSNumber numberWithBool: chainTemplate.targetsVaryByRound];
    self.numberOfExercises = [NSNumber numberWithUnsignedLong: chainTemplate.exercises.count];
    
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
    
    self.name = chainTemplate.name;
    self.chainTemplate = chainTemplate;
    _supportsUserInput = supportsUserInput;
    
    return self;
}

#pragma mark - View Life Cycle

- (void)viewDidLoad{
    [self createDataStructure];
    [self createSubviewsAndLayoutConstraints];
    [self createNavigationItem];
    [self viewAesthetics];
    [self addBackgroundView];
}

- (void)addBackgroundView{
    [[TJBAestheticsController singleton] addFullScreenBackgroundViewWithImage: [UIImage imageNamed: @"weightRack"]
                                                                   toRootView: self.view
                                                                 imageOpacity: .35];
}

- (void)viewAesthetics{
    [[TJBAestheticsController singleton] configureButtonsInArray: @[self.launchCircuitButton]
                                                     withOpacity: .85];
}

- (void)createDataStructure{
    self.weightData = [self createDataStructureObject];
    self.repsData = [self createDataStructureObject];
    self.restData = [self createDataStructureObject];
    
    NSMutableArray *exerciseData = [[NSMutableArray alloc] init];
    for (int i = 0; i < [self.numberOfExercises intValue]; i++)
    {
        [exerciseData addObject: defaultValue];
    }
    self.exerciseData = exerciseData;
}

- (NSMutableArray *)createDataStructureObject{
    NSMutableArray *arrayToReturn = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [self.numberOfExercises intValue]; i++)
    {
        NSMutableArray *subArray = [[NSMutableArray alloc] init];
        [arrayToReturn addObject: subArray];
        
        for (int j = 0; j < [self.numberOfRounds intValue]; j++)
            [subArray addObject: defaultValue];
    }
    
    return arrayToReturn;
}

- (void)createSubviewsAndLayoutConstraints{
    // scroll view
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenBounds.size.width - 16.0;
    
    CGFloat rowHeight = 30;
    CGFloat componentToComponentSpacing = 16;
    CGFloat initialSpacing = 0;
    CGFloat componentStyleSpacing = 8;
    CGFloat componentHeight;
    
    if ([self.targetsVaryByRound intValue])
    {
        componentHeight = rowHeight * ([self.numberOfRounds intValue] + 2) + componentStyleSpacing;
    }
    else
    {
        componentHeight = rowHeight * 3 + componentStyleSpacing;
    }
    
    int numberOfComponents = [self.numberOfExercises intValue];
    CGFloat scrollSubviewHeight = componentHeight * numberOfComponents + componentToComponentSpacing * (numberOfComponents - 1) + initialSpacing;
    
    UIView *scrollSubview = [[UIView alloc] initWithFrame: CGRectMake(0, 0, screenWidth, scrollSubviewHeight)];
    [self.scrollView addSubview: scrollSubview];
    self.scrollView.contentSize = scrollSubview.frame.size;
    
    // constraint mapping
    self.constraintMapping = [[NSMutableDictionary alloc] init];
    
    // row components
    NSMutableString *verticalLayoutConstraintsString = [NSMutableString stringWithCapacity: 1000];
    [verticalLayoutConstraintsString setString: [NSString stringWithFormat: @"V:|-%d-",
                                                 (int)initialSpacing]];
    
    for (int i = 0 ; i < [self.numberOfExercises intValue] ; i ++)
    {
        NSString *exerciseName = @"placeholder";
        if (_supportsUserInput == NO){
            exerciseName = self.chainTemplate.exercises[i].name;
        }
        CircuitDesignExerciseComponent *vc = [[CircuitDesignExerciseComponent alloc] initWithNumberOfRounds: self.numberOfRounds
                                                                                            targetingWeight: self.targetingWeight
                                                                                              targetingReps: self.targetingReps
                                                                                              targetingRest: self.targetingRest
                                                                                         targetsVaryByRound: self.targetsVaryByRound
                                                                                                chainNumber: [NSNumber numberWithInt: i + 1]
                                                                                               exerciseName: exerciseName
                                                                                           masterController: self
                                                                                          supportsUserInput: _supportsUserInput
                                                                                              chainTemplate: self.chainTemplate];
        ;
        
        vc.view.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addChildViewController: vc];
        
        [scrollSubview addSubview: vc.view];
        
        NSString *dynamicComponentName = [NSString stringWithFormat: @"exerciseComponent%d",
                                          i];
        
        [self.constraintMapping setObject: vc.view
                                   forKey: dynamicComponentName];
        
        // vertical constraints
        NSString *verticalAppendString;
        
        if (i == [self.numberOfExercises intValue] - 1)
        {
            verticalAppendString = [NSString stringWithFormat: @"[%@(==%d)]",
                                    dynamicComponentName,
                                    (int)componentHeight];
        }
        else
        {
            verticalAppendString = [NSString stringWithFormat: @"[%@(==%d)]-%d-",
                                    dynamicComponentName,
                                    (int)componentHeight,
                                    (int)componentToComponentSpacing];
        }
        
        [verticalLayoutConstraintsString appendString: verticalAppendString];
        
        // horizontal constraints
        NSString *horizontalLayoutConstraintsString = [NSString stringWithFormat: @"H:|-0-[%@]-0-|",
                                                       dynamicComponentName];
        
        NSArray *horizontalLayoutConstraints = [NSLayoutConstraint constraintsWithVisualFormat: horizontalLayoutConstraintsString
                                                                                       options: 0
                                                                                       metrics: nil
                                                                                         views: self.constraintMapping];
        
        [scrollSubview addConstraints: horizontalLayoutConstraints];
    }
    
    NSArray *verticalLayoutConstraints = [NSLayoutConstraint constraintsWithVisualFormat: verticalLayoutConstraintsString
                                                                                 options: 0
                                                                                 metrics: nil
                                                                                   views: self.constraintMapping];
    
    [scrollSubview addConstraints: verticalLayoutConstraints];
    
    for (CircuitDesignExerciseComponent *child in self.childViewControllers)
    {
        [child didMoveToParentViewController: self];
    }
}

- (void)createNavigationItem{
    UINavigationItem *navItem = [[UINavigationItem alloc] init];
    
    NSString *word;
    int number = [self.numberOfRounds intValue];
    if (number == 1)
    {
        word = @"round";
    }
    else
    {
        word = @"rounds";
    }
    NSString *title = [NSString stringWithFormat: @"%@ (%d %@)",
                       self.name,
                       [self.numberOfRounds intValue],
                       word];
    [navItem setTitle: title];
    
    if (_supportsUserInput == YES){
    UIBarButtonItem *xBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemStop
                                                                                target: self
                                                                                action: @selector(didPressX)];
    [navItem setLeftBarButtonItem: xBarButton];
    UIBarButtonItem *goBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemAdd
                                                                                 target: self
                                                                                 action: @selector(didPressAdd)];
    [navItem setRightBarButtonItem: goBarButton];
    }
    
    [self.navBar setItems: @[navItem]];
}





#pragma mark - Core Data

- (void)createAndSaveChainTemplate{
    NSManagedObjectContext *moc = [[CoreDataController singleton] moc];
    
    // create the chain template and NSMutableOrderedSets to capture information that will eventually be stored as relationships of the chain template
    TJBChainTemplate *chainTemplate = [NSEntityDescription insertNewObjectForEntityForName: @"ChainTemplate"
                                                                        inManagedObjectContext: moc];
    
    // assign the chain template's attributes
    chainTemplate.identifier = @"placeholder identifier";
    
    chainTemplate.name = self.name;
    chainTemplate.targetingWeight = [self.targetingWeight intValue];
    chainTemplate.targetingReps = [self.targetingReps intValue];
    chainTemplate.targetingRestTime = [self.targetingRest intValue];
    chainTemplate.targetsVaryByRound = [self.targetsVaryByRound intValue];
    
    // chain template relationships
    int exerciseLimit = [self.numberOfExercises intValue];
    
    NSMutableOrderedSet *exercises = [[NSMutableOrderedSet alloc] init];
    
    for (int i = 0; i < [self.numberOfExercises intValue]; i++)
    {
        // add the current exercise to the mutable ordered set
        TJBExercise *exercise = self.exerciseData[i];
        [exercises addObject: exercise];
    }
    
    chainTemplate.exercises = exercises;
    
    if ([self.targetingWeight intValue] == 1)
    {
        NSMutableArray *weightArrays = [[NSMutableArray alloc] init];
        for (int i = 0; i < exerciseLimit; i++)
        {
            TJBWeightArray *weightArray = [NSEntityDescription insertNewObjectForEntityForName: @"WeightArray"
                                                                        inManagedObjectContext: moc];
            [weightArrays addObject: weightArray];
        }
        
        chainTemplate.weightArrays = [self copyCollectionOfArraysFromData: self.weightData
                                                             numberArrays: weightArrays];
    }
    
    if ([self.targetingReps intValue] == 1)
    {
        NSMutableArray *repsArrays = [[NSMutableArray alloc] init];
        for (int i = 0; i < exerciseLimit; i++)
        {
            TJBWeightArray *repsArray = [NSEntityDescription insertNewObjectForEntityForName: @"RepsArray"
                                                                      inManagedObjectContext: moc];
            [repsArrays addObject: repsArray];
        }
        
        chainTemplate.repsArrays = [self copyCollectionOfArraysFromData: self.repsData
                                                           numberArrays: repsArrays];
    }
    
    if ([self.targetingRest intValue] == 1)
    {
        NSMutableArray *restArrays = [[NSMutableArray alloc] init];
        for (int i = 0; i < exerciseLimit; i++)
        {
            TJBWeightArray *restArray = [NSEntityDescription insertNewObjectForEntityForName: @"TargetRestTimeArray"
                                                                      inManagedObjectContext: moc];
            [restArrays addObject: restArray];
        }
        
        chainTemplate.targetRestTimeArrays = [self copyCollectionOfArraysFromData: self.restData
                                                                     numberArrays: restArrays];
    }
    
    [[CoreDataController singleton] saveContext];
    
    self.chainTemplate = chainTemplate;
}

- (NSMutableOrderedSet *)copyCollectionOfArraysFromData:(NSArray<NSArray *> *)data numberArrays:(NSArray<TJBNumberArray *> *)numberArrays{
    NSMutableOrderedSet *collector = [[NSMutableOrderedSet alloc] init];
    
    int exerciseLimit = [self.numberOfExercises intValue];
    
    for (int i = 0; i < exerciseLimit; i++)
    {
        numberArrays[i].numbers = [self copySingleArrayFromData: data[i]];
        [collector addObject: numberArrays[i]];
    }
    
    return collector;
}

- (NSMutableOrderedSet *)copySingleArrayFromData:(NSArray *)dataArray;{
    NSManagedObjectContext *moc = [[CoreDataController singleton] moc];
    
    // create NumberTypeArrayComponents and give them to the appropriate ordered mutable set
    int roundsLimit = [self.numberOfRounds intValue];
    
    NSMutableOrderedSet *collector = [[NSMutableOrderedSet alloc] init];
    
    for (int i = 0; i < roundsLimit ; i++)
    {
        
        
        TJBNumberTypeArrayComp *numberComponent = [NSEntityDescription insertNewObjectForEntityForName: @"NumberTypeArrayComponent"
                                                                                inManagedObjectContext: moc];
        
        numberComponent.value = [dataArray[i] floatValue];
        numberComponent.isDefaultObject = NO;
        
        [collector addObject: numberComponent];
    }
    
    return collector;
}

#pragma mark - Button Actions

- (void)didPressX{
    [self dismissViewControllerAnimated: NO
                             completion: nil];
}

- (void)didPressLaunchCircuit:(id)sender{
    if ([self.targetsVaryByRound intValue] == 0)
    {
        [self duplicateEntries];
    }
    BOOL allUserInputCollected = [self allSelectionsMade];
    if (allUserInputCollected)
    {
        [self createAndSaveChainTemplate];
        
        TJBChainTemplate *chainTemplate = self.chainTemplate;
        
        TJBActiveCircuitGuidance *vc1 = [[TJBActiveCircuitGuidance alloc] initWithChainTemplate: chainTemplate];
        TJBCircuitTemplateGeneratorVC *vc2 = [[TJBCircuitTemplateGeneratorVC alloc] initWithChainTemplate: chainTemplate
                                                                                        supportsUserInput: NO];
        
        [vc1.tabBarItem setTitle: @"Active"];
        [vc2.tabBarItem setTitle: @"Targets"];
        
        UITabBarController *tabBarController = [[UITabBarController alloc] init];
        tabBarController.tabBar.translucent = NO;
        [tabBarController setViewControllers: @[vc1,
                                                vc2]];
        
        [self presentViewController: tabBarController
                           animated: YES
                         completion: nil];
    } else{
        [self alertUserInputIncomplete];
    }
}

- (void)didPressAdd{
    if ([self.targetsVaryByRound intValue] == 0)
    {
        [self duplicateEntries];
    }
    BOOL allUserInputCollected = [self allSelectionsMade];
    if (allUserInputCollected)
    {
        [self createAndSaveChainTemplate];
        [self dismissViewControllerAnimated: NO
                                 completion: nil];
    } else{
        [self alertUserInputIncomplete];
    }
}

- (void)alertUserInputIncomplete{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"User Input Error"
                                                                   message: @"Please make selections for all active fields"
                                                            preferredStyle: UIAlertControllerStyleAlert];
    UIAlertAction *action = [UIAlertAction actionWithTitle: @"Continue"
                                                     style: UIAlertActionStyleDefault
                                                   handler: nil];
    [alert addAction: action];
    [self presentViewController: alert
                       animated: YES
                     completion: nil];
}

- (void)duplicateEntries{
    NSArray *dataArrays = @[
                        self.weightData,
                        self.repsData,
                        self.restData];
    
    for (int i = 0; i < [dataArrays count]; i++)
    {
        for (int j = 0; j < [self.numberOfExercises intValue]; j++)
        {
            if ([dataArrays[i][j][0] class] == [NSString class])
            {
                continue;
            }
            else
            {
                NSNumber *numberToDuplicate = dataArrays[i][j][0];
                
                for (int k = 1; k < [self.numberOfRounds intValue]; k++)
                {
                    dataArrays[i][j][k] = numberToDuplicate;
                    
                  
                }
            }
        }
    }
}

- (BOOL)allSelectionsMade{
    BOOL allWeightSelectionsMade;
    BOOL allRepsSelectionsMade;
    BOOL allRestSelectionsMade;
    BOOL allExerciseSelectionsMade;
    
    // if it's not being targeted, set its value to true
    if ([self.targetingWeight intValue] == 1)
    {
        allWeightSelectionsMade = ![self dataStructureContainsDefaultValue: self.weightData];
    }
    else
    {
        allWeightSelectionsMade = YES;
    }
    
    if ([self.targetingReps intValue] == 1)
    {
        allRepsSelectionsMade = ![self dataStructureContainsDefaultValue: self.repsData];
    }
    else
    {
        allRepsSelectionsMade = YES;
    }
    
    if ([self.targetingRest intValue] == 1)
    {
        allRestSelectionsMade = ![self dataStructureContainsDefaultValue: self.restData];
    }
    else
    {
        allRestSelectionsMade = YES;
    }
    
    allExerciseSelectionsMade = ![self.exerciseData containsObject: defaultValue];
        
    return allWeightSelectionsMade && allRepsSelectionsMade && allRestSelectionsMade && allExerciseSelectionsMade;
}

- (BOOL)dataStructureContainsDefaultValue:(NSArray *)dataStructure{
    int iterationLimit = [self.numberOfExercises intValue];
    
    for (int i = 0; i < iterationLimit; i++)
    {
        if ([dataStructure[i] containsObject: defaultValue])
        {
            return YES;
        }
    }
    
    return NO;
}

#pragma mark - <TJBCircuitTemplateUserInputDelegate>

- (void)presentNumberSelectionSceneWithNumberType:(NumberType)numberType numberMultiple:(NSNumber *)numberMultiple numberLimit:(NSNumber *)numberLimit title:(NSString *)title cancelBlock:(void(^)(void))cancelBlock numberSelectedBlock:(void(^)(NSNumber *))numberSelectedBlock animated:(BOOL)animated modalTransitionStyle:(UIModalTransitionStyle)transitionStyle{
    
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

- (void)didPressUserInputButtonWithType:(NumberType)type chainNumber:(NSNumber *)chainNumber roundNumber:(NSNumber *)roundNumber button:(UIButton *)button{
    __weak TJBCircuitTemplateGeneratorVC *weakSelf = self;
    
    CancelBlock cancelBlock = ^{
        [weakSelf dismissViewControllerAnimated: NO
                                 completion: nil];
    };
    
    void (^buttonAlterationBlock)(void) = ^{
        button.backgroundColor = [UIColor whiteColor];
        [button setTitleColor: [UIColor blackColor]
                     forState: UIControlStateNormal];
    };
    
    int indexOne = [chainNumber intValue] - 1;
    int indexTwo = [roundNumber intValue] - 1;
    
    if (type == WeightType)
    {
        
        NumberSelectedBlock block = ^(NSNumber *number){
            [button setTitle: [number stringValue]
                    forState: UIControlStateNormal];
            buttonAlterationBlock();
            self.weightData[indexOne][indexTwo] = number;
            [self dismissViewControllerAnimated: NO
                                     completion: nil];
        };
        
        [self presentNumberSelectionSceneWithNumberType: WeightType
                                         numberMultiple: [NSNumber numberWithDouble: 2.5]
                                            numberLimit: nil
                                                  title: @"Select Weight"
                                            cancelBlock: cancelBlock
                                    numberSelectedBlock: block
                                               animated: YES
                                   modalTransitionStyle: UIModalTransitionStyleCoverVertical];
    }
    else if (type == RepsType)
    {
        NumberSelectedBlock block = ^(NSNumber *number){
            [button setTitle: [number stringValue]
                    forState: UIControlStateNormal];
            buttonAlterationBlock();
            self.repsData[indexOne][indexTwo] = number;
            [self dismissViewControllerAnimated: NO
                                     completion: nil];
        };
        
        [self presentNumberSelectionSceneWithNumberType: RepsType
                                         numberMultiple: [NSNumber numberWithDouble: 1.0]
                                            numberLimit: nil
                                                  title: @"Select Reps"
                                            cancelBlock: cancelBlock
                                    numberSelectedBlock: block
                                               animated: YES
                                   modalTransitionStyle: UIModalTransitionStyleCoverVertical];
    }
    else if (type == RestType)
    {
        
        NumberSelectedBlock block = ^(NSNumber *number){
            NSString *title = [[TJBStopwatch singleton] minutesAndSecondsStringFromNumberOfSeconds: [number intValue]];
            [button setTitle: title
                    forState: UIControlStateNormal];
            buttonAlterationBlock();
            self.restData[indexOne][indexTwo] = number;
            [self dismissViewControllerAnimated: NO
                                     completion: nil];
        };
        
        [self presentNumberSelectionSceneWithNumberType: RestType
                                         numberMultiple: [NSNumber numberWithDouble: 5.0]
                                            numberLimit: nil
                                                  title: @"Select Rest"
                                            cancelBlock: cancelBlock
                                    numberSelectedBlock: block
                                               animated: YES
                                   modalTransitionStyle: UIModalTransitionStyleCoverVertical];
    }
}

- (void)didPressExerciseButton:(UIButton *)button inChain:(NSNumber *)chainNumber{
    NSString *title = [NSString stringWithFormat: @"Chain Element #%d",
                       [chainNumber intValue]];
    
    TJBCircuitTemplateGeneratorVC * __weak weakSelf = self;
    
    void (^callback)(TJBExercise *) = ^(TJBExercise *exercise)
    {
        [button setTitle: exercise.name
                forState: UIControlStateNormal];
        button.backgroundColor = [UIColor whiteColor];
        [button setTitleColor: [UIColor blackColor]
                     forState: UIControlStateNormal];
        
        [weakSelf didSelectExercise: exercise
                     forChainNumber: chainNumber];
        
        [weakSelf dismissViewControllerAnimated: NO
                                     completion: nil];
    };
    
    TJBExerciseSelectionScene *vc = [[TJBExerciseSelectionScene alloc] initWithTitle: title
                                                                       callbackBlock: callback];
    
    [self presentViewController: vc
                       animated: NO
                     completion: nil];
}
                                     
- (void)didSelectExercise:(TJBExercise *)exercise forChainNumber:(NSNumber *)chainNumber{
    int index = [chainNumber intValue] - 1;
    self.exerciseData[index] = exercise;
}



@end








































