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

#import "RowComponentActiveUpdatingProtocol.h"
#import "CircuitDesignRowComponent.h"

#import "TJBCircuitModeTBC.h"

@interface TJBCircuitTemplateGeneratorVC () <UIViewControllerRestoration>
{
    // core
    BOOL _supportsUserInput;
    BOOL _valuesPopulatedDuringWorkout;
    TJBCircuitTemplateType _circuitGeneratorType;
}

// core
@property (nonatomic, strong) NSNumber *targetingWeight;
@property (nonatomic, strong) NSNumber *targetingReps;
@property (nonatomic, strong) NSNumber *targetingRest;
@property (nonatomic, strong) NSNumber *targetsVaryByRound;
@property (nonatomic, strong) NSNumber *numberOfExercises;
@property (nonatomic, strong) NSNumber *numberOfRounds;
@property (nonatomic, strong) NSString *name;

@property (nonatomic, strong) TJBChainTemplate *chainTemplate;

// for ActiveUpdatingType
// keeps track of its children rows so that it can updated their values during workouts to show active progress
@property (nonatomic, strong) NSMutableArray<NSMutableArray <CircuitDesignRowComponent<RowComponentActiveUpdatingProtocol> *> *> *childRowControllers;

// for updating rest times during the workout
@property (nonatomic, strong) NSMutableArray<NSMutableArray <NSDate *> *> *setBeginDates;
@property (nonatomic, strong) NSMutableArray<NSMutableArray <NSDate *> *> *setEndDates;

// view
@property (nonatomic, strong) NSMutableDictionary *constraintMapping;

@property (weak, nonatomic) IBOutlet UIButton *launchCircuitButton;
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

// IBAction
- (IBAction)didPressLaunchCircuit:(id)sender;

// data structure
// used by TemplateType for creating TJBChainTemplate managed object
@property (nonatomic, strong) NSMutableArray *weightData;
@property (nonatomic, strong) NSMutableArray *repsData;
@property (nonatomic, strong) NSMutableArray *restData;
@property (nonatomic, strong) NSMutableArray *exerciseData;

@end

// constants
static NSString * const defaultValue = @"unselected";

@implementation TJBCircuitTemplateGeneratorVC

#pragma mark - Instantiation

- (instancetype)initTemplateTypeWithTargetingWeight:(NSNumber *)targetingWeight targetingReps:(NSNumber *)targetingReps targetingRest:(NSNumber *)targetingRest targetsVaryByRound:(NSNumber *)targetsVaryByRound numberOfExercises:(NSNumber *)numberOfExercises numberOfRounds:(NSNumber *)numberOfRounds name:(NSString *)name{
    self = [super init];
    
    _circuitGeneratorType = TemplateType;
    
    self.targetingWeight = targetingWeight;
    self.targetingReps = targetingReps;
    self.targetingRest = targetingRest;
    self.targetsVaryByRound = targetsVaryByRound;
    self.numberOfExercises = numberOfExercises;
    self.numberOfRounds = numberOfRounds;
    self.name = name;
    
    _supportsUserInput = YES;
    _valuesPopulatedDuringWorkout = NO;
    
    [self setRestorationProperties];
    
    return self;
}

- (void)setRestorationProperties{
    
    NSString *string = @"TJBCircuitTemplateGenerator";
    
    NSString *appendString;
    
    if (_circuitGeneratorType == ReferenceType){
        appendString = @"Reference";
    } else if (_circuitGeneratorType == ActiveUpdatingType){
        appendString = @"ActiveUpdating";
    } else if (_circuitGeneratorType == TemplateType){
        appendString = @"Template";
    }
    
    self.restorationIdentifier = [string stringByAppendingString: appendString];
    self.restorationClass = [TJBCircuitTemplateGeneratorVC class];
}

- (instancetype)initActiveUpdatingTypeWithChainTemplate:(TJBChainTemplate *)chainTemplate{
    _circuitGeneratorType = ActiveUpdatingType;
    
    return [self initWithChainTemplate: chainTemplate
              supportsUserInput: NO
   valuesPopulatedDuringWorkout: YES];
}

- (instancetype)initReferenceTypeWithChainTemplate:(TJBChainTemplate *)chainTemplate{
    _circuitGeneratorType = ReferenceType;
    
    return [self initWithChainTemplate: chainTemplate
              supportsUserInput: NO
   valuesPopulatedDuringWorkout: NO];
}

- (instancetype)initWithChainTemplate:(TJBChainTemplate *)chainTemplate supportsUserInput:(BOOL)supportsUserInput valuesPopulatedDuringWorkout:(BOOL)valuesPopulatedDuringWorkout{
    self = [super init];
    
    [self setRestorationProperties];
    
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
    _valuesPopulatedDuringWorkout = valuesPopulatedDuringWorkout;
    
    return self;
}

#pragma mark - View Life Cycle

- (void)viewDidLoad{
    
    // most of the heavy lifting it terms of view appearance is done by the child classes, CircuitDesignRowComponent and CircuitDesignExerciseComponent
    
    //// for 'user input' type only
    
    // creates a chain template filled with default values
    // *** SHOULD CONSIDER UPDATNG THIS AND ASSOCIATED METHODS TO ACCOUNT FOR CURRENT MODEL. RIGHT NOW, IT USES A DEFAULT STRING AS OPPOSED TO THE DEFAULT PROPERTY OF CHAIN COMPONENTS
    
    if (_circuitGeneratorType == TemplateType){
        
        [self createSkeletonChainTemplate];
    }
    
    //// for the 'active updating' type only
    
    if (_circuitGeneratorType == ActiveUpdatingType){
        
        [self createSkeletonArraysForSetBeginAndEndDates];
    }
    
    //// called for all types
    
    // all modes require some delegate interaction
    
    [self createSkeletonArrayForChildRowControllers];
    
    // adds different background views based on the type of circuit generator
    
    [self addBackgroundView];
    
    // configures the aesthetics of the large button and changes its title according to type
    
    [self configureLargeButton];
    
    // configures the navigation bar
    
    [self configureNavBar];
    
    // creates the view hierarchy, including child VC's
    
    [self createSubviewsAndLayoutConstraints];
}

- (void)createSkeletonArrayForChildRowControllers{
    
    // only row controllers are tracked because only their views change.  TJBExerciseComponent only has the 'exercise' dynamic view and it will remain the same for active updating type
    
    self.childRowControllers = [[NSMutableArray alloc] init];
    
    int exerciseLimit = [self.numberOfExercises intValue];
    
    for (int i = 0; i < exerciseLimit; i++){
        
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [self.childRowControllers addObject: array];
    }
}

- (void)createSkeletonArraysForSetBeginAndEndDates{
    
    self.setBeginDates = [[NSMutableArray alloc] init];
    self.setEndDates = [[NSMutableArray alloc] init];
    
    int exerciseLimit = [self.numberOfExercises intValue];
    
    for (int i = 0; i < exerciseLimit; i++){
        
        NSMutableArray *dateArray1 = [[NSMutableArray alloc] init];
        [self.setBeginDates addObject: dateArray1];
        
        NSMutableArray *dateArray2 = [[NSMutableArray alloc] init];
        [self.setEndDates addObject: dateArray2];
    }
}

- (void)addBackgroundView{
    
    if (_supportsUserInput == YES){
        
        [[TJBAestheticsController singleton] addFullScreenBackgroundViewWithImage: [UIImage imageNamed: @"weightRack"]
                                                                       toRootView: self.view
                                                                     imageOpacity: .35];
    } else{
        
        [[TJBAestheticsController singleton] addFullScreenBackgroundViewWithImage: [UIImage imageNamed: @"FinlandBackSquat"]
                                                                       toRootView: self.view
                                                                     imageOpacity: .45];
    }
}

- (void)configureLargeButton{
    
    [[TJBAestheticsController singleton] configureButtonsInArray: @[self.launchCircuitButton]
                                                     withOpacity: .85];
    
    if (_supportsUserInput == NO){
        [self.launchCircuitButton setTitle: @"Edit"
                                  forState: UIControlStateNormal];
    }
}

- (void)createSkeletonChainTemplate{
    self.weightData = [self createSkeletonDataStructure];
    self.repsData = [self createSkeletonDataStructure];
    self.restData = [self createSkeletonDataStructure];
    
    NSMutableArray *exerciseData = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [self.numberOfExercises intValue]; i++){
        
        [exerciseData addObject: defaultValue];
    }
    
    self.exerciseData = exerciseData;
}

- (NSMutableArray *)createSkeletonDataStructure{
    
    NSMutableArray *arrayToReturn = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [self.numberOfExercises intValue]; i++){
        
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
    
    if ([self.targetsVaryByRound intValue] || _supportsUserInput == NO){
        
        componentHeight = rowHeight * ([self.numberOfRounds intValue] + 2) + componentStyleSpacing;
    } else{
        
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
    
    for (int i = 0 ; i < [self.numberOfExercises intValue] ; i ++){
        
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
                                                                                              chainTemplate: self.chainTemplate
                                                                               valuesPopulatedDuringWorkout: _valuesPopulatedDuringWorkout];
        
        
        vc.view.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addChildViewController: vc];
        
        [scrollSubview addSubview: vc.view];
        
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
        
        [scrollSubview addConstraints: horizontalLayoutConstraints];
    }
    
    NSArray *verticalLayoutConstraints = [NSLayoutConstraint constraintsWithVisualFormat: verticalLayoutConstraintsString
                                                                                 options: 0
                                                                                 metrics: nil
                                                                                   views: self.constraintMapping];
    
    [scrollSubview addConstraints: verticalLayoutConstraints];
    
    for (CircuitDesignExerciseComponent *child in self.childViewControllers){
        
        [child didMoveToParentViewController: self];
    }
}

- (void)configureNavBar{
    
    UINavigationItem *navItem = [[UINavigationItem alloc] init];
    
    NSString *word;
    int number = [self.numberOfRounds intValue];
    
    if (number == 1){
        
        word = @"round";
    } else{
        
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
    if (_supportsUserInput == YES){
        if ([self.targetsVaryByRound intValue] == 0)
        {
            [self duplicateEntries];
        }
        BOOL allUserInputCollected = [self allSelectionsMade];
        if (allUserInputCollected)
        {
            [self createAndSaveChainTemplate];
            
            TJBChainTemplate *chainTemplate = self.chainTemplate;
            
            // alert
            NSString *message = [NSString stringWithFormat: @"'%@' has been successfully saved",
                                 chainTemplate.name];
            UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"Circuit Added"
                                                                           message: message
                                                                    preferredStyle: UIAlertControllerStyleAlert];
            void (^alertBlock)(UIAlertAction *) = ^(UIAlertAction *action){
                
                TJBCircuitModeTBC *tbc = [[TJBCircuitModeTBC alloc] initWithChainTemplate: chainTemplate];
                
                [self presentViewController: tbc
                                   animated: YES
                                 completion: nil];
            };
            UIAlertAction *action = [UIAlertAction actionWithTitle: @"Continue"
                                                             style: UIAlertActionStyleDefault
                                                           handler: alertBlock];
            [alert addAction: action];
            [self presentViewController: alert
                               animated: YES
                             completion: nil];
        } else{
            [self alertUserInputIncomplete];
        }
    } else{
        NSLog(@"edit");
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
        
        NSString *message = [NSString stringWithFormat: @"'%@' has been successfully saved",
                             self.chainTemplate.name];
        UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"Circuit Added"
                                                                       message: message
                                                                preferredStyle: UIAlertControllerStyleAlert];
        void (^alertBlock)(UIAlertAction *) = ^(UIAlertAction *action){
            [self dismissViewControllerAnimated: NO
                                     completion: nil];
        };
        UIAlertAction *action = [UIAlertAction actionWithTitle: @"Continue"
                                                         style: UIAlertActionStyleDefault
                                                       handler: alertBlock];
        [alert addAction: action];
        [self presentViewController: alert
                           animated: YES
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





#pragma mark - <TJBCircuitTemplateUserInputDelegate>

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

- (void)addChildRowController:(CircuitDesignRowComponent<RowComponentActiveUpdatingProtocol> *)rowController forExerciseIndex:(int)exerciseIndex roundIndex:(int)roundIndex{
    NSMutableArray *array = self.childRowControllers[exerciseIndex];
    [array addObject: rowController];
}

- (void)userDidSelectNumber:(double)number withNumberType:(NumberType)numberType forExerciseIndex:(int)exerciseIndex forRoundIndex:(int)roundIndex date:(NSDate *)date setDateType:(SetDateType)setDateType{
    CircuitDesignRowComponent<RowComponentActiveUpdatingProtocol> *rowComponent;
    
    if (numberType == RestType){
        NSMutableArray *array;
        
        if (setDateType == SetBeginDate){
            array = self.setBeginDates[exerciseIndex];
        } else if (setDateType == SetEndDate){
            array = self.setEndDates[exerciseIndex];
        }
        
        [array addObject: date];
        
        BOOL isFirstExerciseInFirstRound = exerciseIndex == 0 && roundIndex == 0;
        if (!isFirstExerciseInFirstRound){
            
            NSDate *laterDate = date;
            NSDate *earlierDate;
            
            if (setDateType == SetBeginDate){
                // should calculate the rest between sets here
                // will need to use multiple indexes because the end of set 1 is held at an index one less than the beginning of set 2
                
                if (exerciseIndex == 0){
                    int maxExerciseIndex = [self.numberOfExercises intValue] - 1;
                    earlierDate = self.setEndDates[maxExerciseIndex][roundIndex - 1];
                    rowComponent = self.childRowControllers[maxExerciseIndex][roundIndex - 1];
                } else{
                    earlierDate = self.setEndDates[exerciseIndex - 1][roundIndex];
                    rowComponent = self.childRowControllers[exerciseIndex - 1][roundIndex];
                }
                
                float timeDifferenceAsFloat = [laterDate timeIntervalSinceDate: earlierDate];
                [rowComponent updateLabelWithNumberType: RestType
                                                  value: timeDifferenceAsFloat];
            }
        }
    } else{
        CircuitDesignRowComponent<RowComponentActiveUpdatingProtocol> *rowComponent = self.childRowControllers[exerciseIndex][roundIndex];
        [rowComponent updateLabelWithNumberType: numberType
                                          value: number];
    }
}

- (BOOL)doesNotSupportUserInputAndIsPopulatingValuesDuringWorkout{
    if (_supportsUserInput == NO && _valuesPopulatedDuringWorkout == YES){
        return YES;
    } else{
        return NO;
    }
}

#pragma mark - <UIViewControllerRestoration>

+ (UIViewController *)viewControllerWithRestorationIdentifierPath:(NSArray *)identifierComponents coder:(NSCoder *)coder{
    
    // *** MUST CREATE THE CHILD ROW CONTROLLER ARRAY BEFORE VIEWDIDLOAD IS CALLED IN CIRCUITDESIGNEXERCISECOMPONENT
    
    TJBCircuitTemplateGeneratorVC *vc;
    
    // type
    
    TJBCircuitTemplateType type = [coder decodeIntForKey: @"circuitGeneratorType"];
    
    NSString *uniqueID = [coder decodeObjectForKey: @"chainTemplateUniqueID"];
    
    if (type == ReferenceType){
        
        TJBChainTemplate *chain = [[CoreDataController singleton] chainTemplateWithUniqueID: uniqueID];
        vc = [[TJBCircuitTemplateGeneratorVC alloc] initReferenceTypeWithChainTemplate: chain];
        
    } else if(type == ActiveUpdatingType){
        
        TJBChainTemplate *chain = [[CoreDataController singleton] chainTemplateWithUniqueID: uniqueID];
        vc = [[TJBCircuitTemplateGeneratorVC alloc] initActiveUpdatingTypeWithChainTemplate: chain];
    }
    
    [vc setRestorationProperties];
    
    return vc;
}

- (void)encodeRestorableStateWithCoder:(NSCoder *)coder{
    
    [super encodeRestorableStateWithCoder: coder];
    
    // type
    
    [coder encodeInt: _circuitGeneratorType
              forKey: @"circuitGeneratorType"];
    
    // encode chain template uniqueID if is reference or active updating type
    // need to encode the begin and end dates for active updating type (and maybe row components array as well?)
    // may need to encode all child row controllers and give all descending view VC's restoration identifiers for active updating type (or create data structure to restore them) 
    
    if (_circuitGeneratorType == ReferenceType || _circuitGeneratorType == ActiveUpdatingType){
        
        [coder encodeObject: self.chainTemplate.uniqueID
                     forKey: @"chainTemplateUniqueID"];
    }
}

- (void)decodeRestorableStateWithCoder:(NSCoder *)coder{
    
    [super decodeRestorableStateWithCoder: coder];
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


@end








































