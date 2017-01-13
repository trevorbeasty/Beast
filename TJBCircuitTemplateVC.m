//
//  TJBCircuitTemplateVC.m
//  Beast
//
//  Created by Trevor Beasty on 1/10/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

//// for now, I am saving the context every time a selection is made

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
@property (nonatomic, strong) NSMutableOrderedSet *selectedExercises;

//// core

// these are largely for convenience as most are derived from the chain template itself

@property (nonatomic, strong) NSNumber *targetingWeight;
@property (nonatomic, strong) NSNumber *targetingReps;
@property (nonatomic, strong) NSNumber *targetingRest;
@property (nonatomic, strong) NSNumber *targetsVaryByRound;
@property (nonatomic, strong) NSNumber *numberOfExercises;
@property (nonatomic, strong) NSNumber *numberOfRounds;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, strong) NSNumber *viewHeight;
@property (nonatomic, strong) NSNumber *viewWidth;

// keeps track of its children rows and exercise components to facillitate delegate functionality

@property (nonatomic, strong) NSMutableArray <TJBCircuitTemplateExerciseComp *> *childExerciseComponentControllers;
@property (nonatomic, strong) NSMutableArray<NSMutableArray <TJBCircuitTemplateRowComponent<TJBCircuitTemplateRowComponentProtocol> *> *> *childRowControllers;

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
    
    self.chainTemplate = skeletonChainTemplate;
    
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
    
    // for core data
    
    [self prepareSelectedExercisesSetForUserInput];
    
    //
    
    [self createSkeletonArrayForChildExeriseAndRowControllers];
    
    return self;
}

- (void)prepareSelectedExercisesSetForUserInput{
    
    //// this set will collect the exercises the user chooses and will eventually be assigned to the chain template after all user selections have been made when allUserInputCollected is calledr
    
    NSMutableOrderedSet *set = [[NSMutableOrderedSet alloc] init];
    self.selectedExercises = set;
    
    int exerciseLimit = [self.numberOfExercises intValue];
    
    NSNumber *wasNewlyCreated = nil;
    TJBExercise *exercise = [[CoreDataController singleton] exerciseForName: placeholderExerciseName
                                                            wasNewlyCreated: &wasNewlyCreated];
    
    NSLog(@"%@ was newly created: %d",
          exercise.name,
          [wasNewlyCreated boolValue]);
    
    for (int i = 0; i < exerciseLimit ; i++){
        
        [set addObject: exercise];
        
    }
    
    return;
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
    
    [self createChildViewControllersAndLayoutViews];
    
}



- (void)createSkeletonArrayForChildExeriseAndRowControllers{
    
    // child row controllers
    
    self.childRowControllers = [[NSMutableArray alloc] init];
    
    int exerciseLimit = [self.numberOfExercises intValue];
    
    for (int i = 0; i < exerciseLimit; i++){
        
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [self.childRowControllers addObject: array];
    }
    
    // child exercise controllers
    
    self.childExerciseComponentControllers = [[NSMutableArray alloc] init];
    
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
        
        // add the exercise component to the child view controller array
        
        [self.childExerciseComponentControllers addObject: vc];
        
        
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



- (void)didPressUserInputButtonWithType:(NumberType)type chainNumber:(NSNumber *)chainNumber roundNumber:(NSNumber *)roundNumber button:(UIButton *)button{
    
    //// this method handles selection of weight, reps, and rest.  Context should be saved immediately after updating the chain template
    
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
    
    if (type == WeightType){
        
        NumberSelectedBlock block = ^(NSNumber *number){
            
            [button setTitle: [number stringValue]
                    forState: UIControlStateNormal];
            
            buttonAlterationBlock();
            
            TJBNumberTypeArrayComp *arrayComp = self.chainTemplate.weightArrays[indexOne].numbers[indexTwo];
            arrayComp.isDefaultObject = NO;
            arrayComp.value = [number floatValue];
            
            // clone the selection if targets do not vary by round
            
            if ([self.targetsVaryByRound boolValue] == NO){
                
                [[CoreDataController singleton] cloneFirstNumberForWeight: self.chainTemplate];
            }
            
            [[CoreDataController singleton] saveContext];
            
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
    else if (type == RepsType){
        
        NumberSelectedBlock block = ^(NSNumber *number){
            
            [button setTitle: [number stringValue]
                    forState: UIControlStateNormal];
            
            buttonAlterationBlock();
            
            TJBNumberTypeArrayComp *arrayComp = self.chainTemplate.repsArrays[indexOne].numbers[indexTwo];
            arrayComp.isDefaultObject = NO;
            arrayComp.value = [number floatValue];
            
            // clone the selection if targets do not vary by round
            
            if ([self.targetsVaryByRound boolValue] == NO){
                
                [[CoreDataController singleton] cloneFirstNumberForReps: self.chainTemplate];
            }
            
            [[CoreDataController singleton] saveContext];
            
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
            
            TJBNumberTypeArrayComp *arrayComp = self.chainTemplate.targetRestTimeArrays[indexOne].numbers[indexTwo];
            arrayComp.isDefaultObject = NO;
            arrayComp.value = [number floatValue];
            
            // clone the selection if targets do not vary by round
            
            if ([self.targetsVaryByRound boolValue] == NO){
                
                [[CoreDataController singleton] cloneFirstNumberForRest: self.chainTemplate];
            }
            
            [[CoreDataController singleton] saveContext];
            
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
    
    void (^callback)(TJBExercise *) = ^(TJBExercise *exercise){
        
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
    self.selectedExercises[index] = exercise;
    
    // for now, I am saving every time a selection is made
    
    self.chainTemplate.exercises = self.selectedExercises;
    
    [[CoreDataController singleton] saveContext];
    
}

- (void)addChildRowController:(TJBCircuitTemplateRowComponent<TJBCircuitTemplateRowComponentProtocol> *)rowController forExerciseIndex:(int)exerciseIndex{
    
    NSMutableArray *array = self.childRowControllers[exerciseIndex];
    [array addObject: rowController];
    
}



- (BOOL)allUserInputCollected{
    
    // assign the user-selected exercises to the chain template and then use the CoreDataController to evaluate if all user input has been collected
    
    // I do not assign the exercises property of chain template here because it is assigned every time a selection is made, and the core data controller method also checks for existence of the exercises property
    
    return [[CoreDataController singleton] chainTemplateHasCollectedAllRequisiteUserInput: self.chainTemplate];
    
}

- (void)populateChildVCViewsWithUserSelectedValues{
    
    //// for all non-default exercise, weight, reps, and rest objects, populate child VC's with the stored values.  The class is only responsible for sending each child view it corresponding data objects.  It is the job of the child views to evaluate the passed in data objects and determine whether or not their views should be updated (based on whether the object is a default object or not)
    
    int exerciseLimit = [self.numberOfExercises intValue];
    int roundLimit = [self.numberOfRounds intValue];
    
    TJBCircuitTemplateExerciseComp *currentExerciseComp;
    TJBCircuitTemplateRowComponent *currentRowComp;
    
    TJBChainTemplate *chain = self.chainTemplate;
    
    TJBExercise *currentExercise;
    TJBNumberTypeArrayComp *currentWeight;
    TJBNumberTypeArrayComp *currentReps;
    TJBNumberTypeArrayComp *currentRest;
    
    for (int i = 0; i < exerciseLimit; i++){
        
        // exercise child controllers
        
        currentExerciseComp = self.childExerciseComponentControllers[i];
        currentExercise = chain.exercises[i];
        
        [currentExerciseComp updateViewsWithUserSelectedExercise: currentExercise];
        
        for (int j = 0; j < roundLimit; j++){
            
            // row child controllers
            
            // must evaluate if category is being targeted before sending message
            
            currentRowComp = self.childRowControllers[i][j];
            
            // weight
            
            if (chain.targetingWeight){
                
                currentWeight = chain.weightArrays[i].numbers[j];
                
                [currentRowComp updateWeightViewWithUserSelection: currentWeight];
                
            }
            
            // reps
            
            if (chain.targetingReps){
                
                currentReps = chain.repsArrays[i].numbers[j];
                
                [currentRowComp updateRepsViewWithUserSelection: currentReps];
                
            }
            
            // rest
            
            if (chain.targetingRestTime){
                
                currentRest = chain.targetRestTimeArrays[i].numbers[j];
                
                [currentRowComp updateRestViewWithUserSelection: currentRest];
                
            }
        }
    }
}


@end



























