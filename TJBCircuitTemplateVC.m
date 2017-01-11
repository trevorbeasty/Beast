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

//#import "TJBCircuitTemplateUserInputDelegate.h"
#import "TJBCircuitTemplateVCProtocol.h"

#import "TJBNumberSelectionVC.h"

#import "TJBStopwatch.h"

#import "CoreDataController.h"

#import "TJBExerciseSelectionScene.h"

@interface TJBCircuitTemplateVC () <TJBCircuitTemplateVCProtocol>

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

// view
@property (nonatomic, strong) NSMutableDictionary *constraintMapping;

@end

static NSString * const defaultValue = @"unselected";

@implementation TJBCircuitTemplateVC

#pragma mark - Instantiation

- (instancetype)initWithTargetingWeight:(NSNumber *)targetingWeight targetingReps:(NSNumber *)targetingReps targetingRest:(NSNumber *)targetingRest targetsVaryByRound:(NSNumber *)targetsVaryByRound numberOfExercises:(NSNumber *)numberOfExercises numberOfRounds:(NSNumber *)numberOfRounds name:(NSString *)name viewHeight:(NSNumber *)viewHeight viewWidth:(NSNumber *)viewWidth{
    
    // call to super
    
    self = [super init];
    
    // core
    
    self.targetingWeight = targetingWeight;
    self.targetingReps = targetingReps;
    self.targetingRest = targetingRest;
    self.targetsVaryByRound = targetsVaryByRound;
    self.numberOfExercises = numberOfExercises;
    self.numberOfRounds = numberOfRounds;
    self.name = name;
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
    view.backgroundColor = [UIColor whiteColor];
    self.view = view;
    
}

- (void)viewDidLoad{

    [self createSkeletonChainTemplate];
    
    [self createSkeletonArrayForChildRowControllers];
    
//    [self addBackgroundView];
    
    [self createChildViewControllersAndLayoutViews];
}

- (void)addBackgroundView{
    
    // will need to change TJBAestheticsController to account for varying view heights
    
    [[TJBAestheticsController singleton] addFullScreenBackgroundViewWithImage: [UIImage imageNamed: @"weightRack"]
                                                                       toRootView: self.view
                                                                     imageOpacity: .35];
}

- (void)createSkeletonArrayForChildRowControllers{
    
    self.childRowControllers = [[NSMutableArray alloc] init];
    
    int exerciseLimit = [self.numberOfExercises intValue];
    
    for (int i = 0; i < exerciseLimit; i++){
        
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [self.childRowControllers addObject: array];
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
    
    BOOL targetsVaryByRound = [self.targetsVaryByRound boolValue] == YES;
    
    if (targetsVaryByRound){
        
        componentHeight = rowHeight * ([self.numberOfRounds intValue] + 2) + componentStyleSpacing;
        
    } else{
        
        componentHeight = rowHeight * 3 + componentStyleSpacing;
    }
    
    int numberOfComponents = [self.numberOfExercises intValue];
    CGFloat scrollContentHeight = componentHeight * numberOfComponents + componentToComponentSpacing * (numberOfComponents - 1);
    
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










@end



























