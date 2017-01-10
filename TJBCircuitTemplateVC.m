//
//  TJBCircuitTemplateVC.m
//  Beast
//
//  Created by Trevor Beasty on 1/10/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBCircuitTemplateVC.h"

#import "CircuitDesignRowComponent.h"
#import "CircuitDesignExerciseComponent.h"

#import "TJBAestheticsController.h"

@interface TJBCircuitTemplateVC ()

// core

@property (nonatomic, strong) NSNumber *targetingWeight;
@property (nonatomic, strong) NSNumber *targetingReps;
@property (nonatomic, strong) NSNumber *targetingRest;
@property (nonatomic, strong) NSNumber *targetsVaryByRound;
@property (nonatomic, strong) NSNumber *numberOfExercises;
@property (nonatomic, strong) NSNumber *numberOfRounds;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *viewHeight;

// keeps track of its children rows so that it can updated their values during workouts to show active progress
@property (nonatomic, strong) NSMutableArray<NSMutableArray <CircuitDesignRowComponent<RowComponentActiveUpdatingProtocol> *> *> *childRowControllers;

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

- (instancetype)initTemplateTypeWithTargetingWeight:(NSNumber *)targetingWeight targetingReps:(NSNumber *)targetingReps targetingRest:(NSNumber *)targetingRest targetsVaryByRound:(NSNumber *)targetsVaryByRound numberOfExercises:(NSNumber *)numberOfExercises numberOfRounds:(NSNumber *)numberOfRounds name:(NSString *)name viewHeight:(NSNumber *)viewHeight{
    
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
    
    float viewWidth = [[UIScreen mainScreen] bounds].size.width;
    float viewHeight = [self.viewHeight floatValue];
    UIView *containerView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, viewWidth, viewHeight)];
    self.view = containerView;
}

- (void)viewDidLoad{

    [self createSkeletonChainTemplate];
    
    [self createSkeletonArrayForChildRowControllers];
    
    [self addBackgroundView];
    
    [self createScrollView];
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

- (void)createScrollView{
    
    // scroll view
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenBounds.size.width;
    
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
    CGFloat scrollContentViewHeight = componentHeight * numberOfComponents + componentToComponentSpacing * (numberOfComponents - 1);
    
    UIView *scrollContentView = [[UIView alloc] initWithFrame: CGRectMake(0, 0, screenWidth, scrollContentViewHeight)];
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame: self.view.bounds];
    [scrollView addSubview: scrollContentView];
    scrollView.contentSize = scrollContentView.frame.size;
    
    // constraint mapping
    
    self.constraintMapping = [[NSMutableDictionary alloc] init];
    
    // row components
    
    NSMutableString *verticalLayoutConstraintsString = [NSMutableString stringWithCapacity: 1000];
    [verticalLayoutConstraintsString setString: @"V:|-"];
    
    for (int i = 0 ; i < [self.numberOfExercises intValue] ; i ++){
        
//        NSString *exerciseName = @"placeholder";
//            
//            exerciseName = self.chainTemplate.exercises[i].name;
        
        CircuitDesignExerciseComponent *vc = [[CircuitDesignExerciseComponent alloc] initWithNumberOfRounds: self.numberOfRounds
                                                                                            targetingWeight: self.targetingWeight
                                                                                              targetingReps: self.targetingReps
                                                                                              targetingRest: self.targetingRest
                                                                                         targetsVaryByRound: self.targetsVaryByRound
                                                                                                chainNumber: [NSNumber numberWithInt: i + 1]
                                                                                               exerciseName: nil
                                                                                           masterController: nil
                                                                                          supportsUserInput: YES
                                                                                              chainTemplate: nil
                                                                               valuesPopulatedDuringWorkout: NO];
        
        
        vc.view.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addChildViewController: vc];
        
        [scrollContentView addSubview: vc.view];
        
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






@end



























