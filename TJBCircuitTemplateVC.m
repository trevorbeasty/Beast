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

{
    
    // core
    
    CGSize _viewSize;
    
}

// core data

@property (nonatomic, strong) TJBChainTemplate *chainTemplate;
@property (nonatomic, strong) NSMutableOrderedSet *selectedExercises;

//// core
// keeps track of its children rows and exercise components to facillitate delegate functionality

@property (nonatomic, strong) NSMutableArray <TJBCircuitTemplateExerciseComp *> *childExerciseComponentControllers;
@property (nonatomic, strong) NSMutableArray <TJBCircuitTemplateRowComponent<TJBCircuitTemplateRowComponentProtocol> *> *childRowControllers;

// for views

@property (nonatomic, strong) NSMutableDictionary *constraintMapping;

@end

static NSString * const defaultValue = @"unselected";

@implementation TJBCircuitTemplateVC

#pragma mark - Instantiation

- (instancetype)initWithSkeletonChainTemplate:(TJBChainTemplate *)skeletonChainTemplate viewSize:(CGSize)viewSize{
    
    // call to super
    
    self = [super init];
    
    // core
    
    self.chainTemplate = skeletonChainTemplate;
    
    _viewSize = viewSize;
    
    // for restoration
    
    [self setRestorationProperties];
    
    //// for core data
    
    [self prepareSelectedExercisesSetForUserInput];
    
    //
    
    [self createSkeletonArrayForChildExeriseAndRowControllers];
    
    return self;
}

- (void)prepareSelectedExercisesSetForUserInput{
    
    //// this set will collect the exercises the user chooses and will eventually be assigned to the chain template after all user selections have been made when allUserInputCollected is calledr
    
    NSArray *placeholderExercisesArray = [[CoreDataController singleton] placeholderExerciseArrayWithLenght: self.chainTemplate.numberOfExercises];
    
    NSMutableOrderedSet *placeholderExerisesSet = [[NSMutableOrderedSet alloc] initWithArray: placeholderExercisesArray];
    
    self.selectedExercises = placeholderExerisesSet;
    
}

- (void)setRestorationProperties{
    
    self.restorationIdentifier = @"TJBCircuitTemplateVC";
    self.restorationClass = [TJBCircuitTemplateVC class];
    
}

#pragma mark - View Life Cycle

- (void)loadView{
    
    // this must be called when creating the view programatically
    
    float viewWidth = _viewSize.width;
    float viewHeight = _viewSize.height;
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
    
    // child exercise controllers
    
    self.childExerciseComponentControllers = [[NSMutableArray alloc] init];
    
}

- (void)createChildViewControllersAndLayoutViews{
    
    // for constraint mapping
    
    self.constraintMapping = [[NSMutableDictionary alloc] init];
    
    // scroll view
    
    CGRect scrollViewFrame = CGRectMake(0, 0, _viewSize.width, _viewSize.height);
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame: scrollViewFrame];
    
    // determine height of scroll view content size
    
    CGFloat titleBarHeight = 50;
    CGFloat roundRowHeight = 50;
    CGFloat componentToComponentSpacing = 16;
    CGFloat componentStyleSpacing = 0;
    CGFloat componentHeight;
    
    // the extra height allows the user to drag the bottom-most exercise further up on the screen
    
    CGFloat extraHeight = [UIScreen mainScreen].bounds.size.height / 2.0;
    
    BOOL targetsVaryByRound = self.chainTemplate.targetsVaryByRound == YES;
    
    if (targetsVaryByRound){
        
        componentHeight = roundRowHeight * (self.chainTemplate.numberOfRounds + 1) + titleBarHeight + componentStyleSpacing;
        
    } else{
        
        componentHeight = roundRowHeight * 2 + titleBarHeight + componentStyleSpacing;
    }
    
    int numberOfComponents = self.chainTemplate.numberOfExercises;
    CGFloat scrollContentHeight = componentHeight * numberOfComponents + componentToComponentSpacing * (numberOfComponents - 1) + extraHeight;
    
    scrollView.contentSize = CGSizeMake(_viewSize.width, scrollContentHeight);
    [self.view addSubview: scrollView];
    
    CGRect scrollViewSubviewFrame = CGRectMake(0, 0, _viewSize.width, scrollContentHeight);
    UIView *scrollViewSubview = [[UIView alloc] initWithFrame: scrollViewSubviewFrame];
    [scrollView addSubview: scrollViewSubview];
    

    
    // row components
    
    NSMutableString *verticalLayoutConstraintsString = [NSMutableString stringWithCapacity: 1000];
    [verticalLayoutConstraintsString setString: @"V:|-16-"];
    
    for (int i = 0 ; i < self.chainTemplate.numberOfExercises ; i ++){
        
        TJBCircuitTemplateExerciseComp *vc = [[TJBCircuitTemplateExerciseComp alloc] initWithChainTemplate: self.chainTemplate
                                                                                             exerciseIndex: i
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
        
        if (i == self.chainTemplate.numberOfExercises - 1){
            
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

- (void)didDragAcrossPointInView:(CGPoint)dragPoint{
    
    // hit-test the point.  If that point is within the weight button of a child row comp, tell that row comp to update its value
    
    UIView *hitTestView = [self.view hitTest: dragPoint
                                   withEvent: nil];
    
    for (TJBCircuitTemplateRowComponent *rowComp in self.childRowControllers){
        
        if ([rowComp.weightButton isEqual: hitTestView]){
            
            [rowComp copyValueForWeightButton];
            
        }
        
    }
    
}

- (void)activateCopyingStateForNumber:(float)number{
    
    // activate the copying state in all row components for the given number
    
    for (TJBCircuitTemplateRowComponent *rowComp in self.childRowControllers){
        
        [rowComp activeCopyingStateForNumber: number];
        
    }
    
}

- (void)deactivateCopyingState{
    
    // deactivate the copying state in all row components
    
    for (TJBCircuitTemplateRowComponent *rowComp in self.childRowControllers){
        
        [rowComp deactivateCopyingState];
        
    }
    
}

- (void)didSelectExercise:(TJBExercise *)exercise forExerciseIndex:(int)exerciseIndex{
    
    self.selectedExercises[exerciseIndex] = exercise;
    
    // save every time a selection is made
    
    self.chainTemplate.exercises = self.selectedExercises;
    
    [[CoreDataController singleton] saveContext];
    
}

- (void)addChildRowController:(TJBCircuitTemplateRowComponent<TJBCircuitTemplateRowComponentProtocol> *)rowController{
    
    [self.childRowControllers addObject: rowController];
    
}



- (BOOL)allUserInputCollected{
    
    // assign the user-selected exercises to the chain template and then use the CoreDataController to evaluate if all user input has been collected
    
    // I do not assign the exercises property of chain template here because it is assigned every time a selection is made, and the core data controller method also checks for existence of the exercises property
    
    return [[CoreDataController singleton] chainTemplateHasCollectedAllRequisiteUserInput: self.chainTemplate];
    
}




@end



























