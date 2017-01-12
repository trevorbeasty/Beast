//
//  TJBCircuitTemplateVC.m
//  Beast
//
//  Created by Trevor Beasty on 1/10/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBCircuitTemplateVC.h"

#import "TJBCircuitTemplateExerciseComp.h"
#import "TJBCircuitTemplateRowComponent.h"

#import "TJBAestheticsController.h"

#import "TJBNumberSelectionVC.h"

#import "TJBStopwatch.h"

#import "CoreDataController.h"

#import "TJBExerciseSelectionScene.h"

@interface TJBCircuitTemplateVC ()

// core data

@property (nonatomic, strong) TJBChainTemplate *chainTemplate;

// core

@property (nonatomic, strong) NSNumber *targetingWeight;
@property (nonatomic, strong) NSNumber *targetingReps;
@property (nonatomic, strong) NSNumber *targetingRest;
@property (nonatomic, strong) NSNumber *targetsVaryByRound;
@property (nonatomic, strong) NSNumber *numberOfExercises;
@property (nonatomic, strong) NSNumber *numberOfRounds;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *viewHeight;
@property (nonatomic, strong) NSNumber *viewWidth;

// keeps track of its children rows so that it can updated their values during workouts to show active progress

@property (nonatomic, strong) NSMutableArray<NSMutableArray <TJBCircuitTemplateRowComponent<TJBCircuitTemplateRowComponentProtocol> *> *> *childRowControllers;

// used by TemplateType for creating TJBChainTemplate managed object

@property (nonatomic, strong) NSMutableArray *weightData;
@property (nonatomic, strong) NSMutableArray *repsData;
@property (nonatomic, strong) NSMutableArray *restData;
@property (nonatomic, strong) NSMutableArray *exerciseData;

// for views

@property (nonatomic, strong) NSMutableDictionary *constraintMapping;

@end

static NSString * const defaultValue = @"unselected";

@implementation TJBCircuitTemplateVC

#pragma mark - Instantiation

- (instancetype)initWithSkeletonChainTemplate:(TJBChainTemplate *)skeletonChainTemplate viewHeight:(NSNumber *)viewHeight viewWidth:(NSNumber *)viewWidth{
    
    // call to super
    
    self = [super init];
    
    // core
    
    self.targetingWeight = [NSNumber numberWithBool: skeletonChainTemplate.targetingWeight];
    self.targetingReps = [NSNumber numberWithBool: skeletonChainTemplate.targetingReps];
    self.targetingRest = [NSNumber numberWithBool: skeletonChainTemplate.targetingRestTime];
    self.targetsVaryByRound = [NSNumber numberWithBool: skeletonChainTemplate.targetsVaryByRound];
    self.numberOfExercises = [NSNumber numberWithInt: skeletonChainTemplate.numberOfExercises];
    self.numberOfRounds = [NSNumber numberWithInt: skeletonChainTemplate.numberOfRounds];
    self.name = skeletonChainTemplate.name;
    self.viewHeight = viewHeight;
    self.viewWidth = viewWidth;
    
    // for restoration
    
    [self setRestorationProperties];
    
    return self;
}

- (void)setRestorationProperties{
    
    self.restorationIdentifier = @"TJBCircuitTemplateVC";
    self.restorationClass = [TJBCircuitTemplateVC class];
}

#pragma mark - View Life Cycle

- (void)loadView{
    
    // this must be called when creating the view programatically
    
    float viewWidth = [self.viewWidth floatValue];
    float viewHeight = [self.viewHeight floatValue];
    UIView *view = [[UIView alloc] initWithFrame: CGRectMake(0, 0, viewWidth,  viewHeight)];
    view.backgroundColor = [UIColor clearColor];
    self.view = view;
    
}

- (void)viewDidLoad{

//    [self createSkeletonChainTemplate];
    
    [self createSkeletonArrayForChildRowControllers];
    
    [self createChildViewControllersAndLayoutViews];
}



- (void)createSkeletonArrayForChildRowControllers{
    
    self.childRowControllers = [[NSMutableArray alloc] init];
    
    int exerciseLimit = [self.numberOfExercises intValue];
    
    for (int i = 0; i < exerciseLimit; i++){
        
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [self.childRowControllers addObject: array];
    }
}

//- (void)createSkeletonChainTemplate{
//    
//    self.weightData = [self createSkeletonDataStructure];
//    self.repsData = [self createSkeletonDataStructure];
//    self.restData = [self createSkeletonDataStructure];
//    
//    NSMutableArray *exerciseData = [[NSMutableArray alloc] init];
//    
//    for (int i = 0; i < [self.numberOfExercises intValue]; i++){
//        
//        [exerciseData addObject: defaultValue];
//    }
//    
//    self.exerciseData = exerciseData;
//}
//
//- (NSMutableArray *)createSkeletonDataStructure{
//    
//    NSMutableArray *arrayToReturn = [[NSMutableArray alloc] init];
//    
//    for (int i = 0; i < [self.numberOfExercises intValue]; i++){
//        
//        NSMutableArray *subArray = [[NSMutableArray alloc] init];
//        [arrayToReturn addObject: subArray];
//        
//        for (int j = 0; j < [self.numberOfRounds intValue]; j++)
//            [subArray addObject: defaultValue];
//    }
//    
//    return arrayToReturn;
//}

- (void)createChildViewControllersAndLayoutViews{
    
    // for constraint mapping
    
    self.constraintMapping = [[NSMutableDictionary alloc] init];
    
    // scroll view
    
    CGRect scrollViewFrame = CGRectMake(0, 0, [self.viewWidth floatValue], [self.viewHeight floatValue]);
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame: scrollViewFrame];
    
    // determine height of scroll view content size
    
    CGFloat rowHeight = 30;
    CGFloat componentToComponentSpacing = 16;
    CGFloat componentStyleSpacing = 8;
    CGFloat componentHeight;
    
    // the extra height allows the user to drag the bottom-most exercise further up on the screen
    
    CGFloat extraHeight = [UIScreen mainScreen].bounds.size.height / 2.0;
    
    BOOL targetsVaryByRound = [self.targetsVaryByRound boolValue] == YES;
    
    if (targetsVaryByRound){
        
        componentHeight = rowHeight * ([self.numberOfRounds intValue] + 2) + componentStyleSpacing;
        
    } else{
        
        componentHeight = rowHeight * 3 + componentStyleSpacing;
    }
    
    int numberOfComponents = [self.numberOfExercises intValue];
    CGFloat scrollContentHeight = componentHeight * numberOfComponents + componentToComponentSpacing * (numberOfComponents - 1) + extraHeight;
    
    scrollView.contentSize = CGSizeMake([self.viewWidth floatValue], scrollContentHeight);
    [self.view addSubview: scrollView];
    
    CGRect scrollViewSubviewFrame = CGRectMake(0, 0, [self.viewWidth floatValue], scrollContentHeight);
    UIView *scrollViewSubview = [[UIView alloc] initWithFrame: scrollViewSubviewFrame];
    [scrollView addSubview: scrollViewSubview];
    

    
    // row components
    
    NSMutableString *verticalLayoutConstraintsString = [NSMutableString stringWithCapacity: 1000];
    [verticalLayoutConstraintsString setString: @"V:|-"];
    
    for (int i = 0 ; i < [self.numberOfExercises intValue] ; i ++){
        
        TJBCircuitTemplateExerciseComp *vc = [[TJBCircuitTemplateExerciseComp alloc] initWithNumberOfRounds: self.numberOfRounds
                                                                                            targetingWeight: self.targetingWeight
                                                                                              targetingReps: self.targetingReps
                                                                                              targetingRest: self.targetingRest
                                                                                         targetsVaryByRound: self.targetsVaryByRound
                                                                                                chainNumber: [NSNumber numberWithInt: i + 1]
                                                                                           masterController: self];
        
        
        vc.view.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addChildViewController: vc];
        
        [scrollViewSubview addSubview: vc.view];
        
        NSString *dynamicComponentName = [NSString stringWithFormat: @"exerciseComponent%d",
                                          i];
        
        [self.constraintMapping setObject: vc.view
                                   forKey: dynamicComponentName];
        
        // vertical constraints
        
        NSString *verticalAppendString;
        
        if (i == [self.numberOfExercises intValue] - 1){
            
            verticalAppendString = [NSString stringWithFormat: @"[%@(==%d)]",
                                    dynamicComponentName,
                                    (int)componentHeight];
        } else{
            
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
        
        [scrollViewSubview addConstraints: horizontalLayoutConstraints];
    }
    
    NSArray *verticalLayoutConstraints = [NSLayoutConstraint constraintsWithVisualFormat: verticalLayoutConstraintsString
                                                                                 options: 0
                                                                                 metrics: nil
                                                                                   views: self.constraintMapping];
    
    [scrollViewSubview addConstraints: verticalLayoutConstraints];
    
    for (TJBCircuitTemplateExerciseComp *child in self.childViewControllers){
        
        [child didMoveToParentViewController: self];
    }
}

#pragma mark - <TJBCircuitTemplateVCProtocol>

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

// this is the delegate method for templates; I will need to separate out the delegate methods

- (void)didPressUserInputButtonWithType:(NumberType)type chainNumber:(NSNumber *)chainNumber roundNumber:(NSNumber *)roundNumber button:(UIButton *)button{
    __weak TJBCircuitTemplateVC *weakSelf = self;
    
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
    TJBCircuitTemplateVC * __weak weakSelf = self;
    
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

- (void)addChildRowController:(TJBCircuitTemplateRowComponent<TJBCircuitTemplateRowComponentProtocol> *)rowController forExerciseIndex:(int)exerciseIndex roundIndex:(int)roundIndex{
    
    NSMutableArray *array = self.childRowControllers[exerciseIndex];
    [array addObject: rowController];
}

- (BOOL)allUserSelectionsMade{
    
    // if targets do not vary by round, the single entry for all rounds must be duplicated in order for the algorithm to work
    
    if ([self.targetsVaryByRound intValue] == 0){
        
        [self duplicateEntries];
        
    }
    
    // evaluates if the inidividual data elements have all selections made, and then evaluates them in aggregate
    
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

#pragma mark - Core Data

- (TJBChainTemplate *)createAndSaveChainTemplate{
    
    NSManagedObjectContext *moc = [[CoreDataController singleton] moc];
    
    // create the chain template and NSMutableOrderedSets to capture information that will eventually be stored as relationships of the chain template
    TJBChainTemplate *chainTemplate = [NSEntityDescription insertNewObjectForEntityForName: @"ChainTemplate"
                                                                    inManagedObjectContext: moc];
    
    // assign the chain template's attributes
    
    chainTemplate.numberOfExercises = [self.numberOfExercises intValue];
    chainTemplate.numberOfRounds = [self.numberOfRounds intValue];
    chainTemplate.dateCreated = [NSDate date];
//    chainTemplate.identifier = @"placeholder identifier";
    chainTemplate.uniqueID = [[NSUUID UUID] UUIDString];
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
    
    return chainTemplate;
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




@end



























