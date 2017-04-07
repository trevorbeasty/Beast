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
    
    // state
    
    float _activeNumberOfExercises; // defined as floats to facillitate view math (which involves CGFloats)
    float _activeNumberOfRounds;
    

    
    
}

// instantiation

// core data

@property (nonatomic, strong) TJBChainTemplate *chainTemplate;
@property (nonatomic, strong) NSMutableOrderedSet *selectedExercises;


// object tracking

@property (nonatomic, strong) NSMutableArray <TJBCircuitTemplateExerciseComp *> *childExerciseComponentControllers;
@property (nonatomic, strong) NSMutableArray <TJBCircuitTemplateRowComponent<TJBCircuitTemplateRowComponentProtocol> *> *childRowControllers;

// views

@property (strong) UIView *scrollViewContentContainer;
@property (nonatomic, strong) NSMutableDictionary *constraintMapping;

@end


// private constants



static NSString * const defaultValue = @"unselected";

// layout

static CGFloat const roundRowHeight = 44.0;
static CGFloat const exerciseRowHeight = 50.0;
static CGFloat const switchRowHeight = 44.0;
static CGFloat const topExerciseComponentSpacing = 8.0;
static CGFloat const interimExerciseComponentSpacing = 24.0;
static CGFloat const exerciseComponentStyleSpacing = 7.0;






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
    
    [self createPlaceholderArrayForSelectedExercises];
    
    //
    
    [self createSkeletonArrayForChildExeriseAndRowControllers];
    
    return self;
}

- (instancetype)initWithSkeletonChainTemplate:(TJBChainTemplate *)skeletonChainTemplate startingNumberOfExercises:(NSNumber *)startingNumberOfExercises startingNumberOfRounds:(NSNumber *)startingNumberOfRounds{
    
    self = [super init];
    
    // IVs
    
    self.chainTemplate = skeletonChainTemplate;
    _activeNumberOfExercises = [startingNumberOfExercises floatValue];
    _activeNumberOfRounds = [startingNumberOfRounds floatValue];
    
    // instantiation helper methods
    
    [self createPlaceholderArrayForSelectedExercises];
    
    [self createSkeletonArrayForChildExeriseAndRowControllers];
    
    return self;
    
}

#pragma mark - Init Helper Methods

- (void)createPlaceholderArrayForSelectedExercises{
    
    //// this set will collect the exercises the user chooses and will eventually be assigned to the chain template after all user selections have been made when allUserInputCollected is calledr
    
    NSArray *placeholderExercisesArray = [[CoreDataController singleton] placeholderExerciseArrayWithLength: self.chainTemplate.numberOfExercises];
    
    NSMutableOrderedSet *placeholderExerisesSet = [[NSMutableOrderedSet alloc] initWithArray: placeholderExercisesArray];
    
    self.selectedExercises = placeholderExerisesSet;
    
}

- (void)setRestorationProperties{
    
    self.restorationIdentifier = @"TJBCircuitTemplateVC";
    self.restorationClass = [TJBCircuitTemplateVC class];
    
}

- (void)createSkeletonArrayForChildExeriseAndRowControllers{
    
    // child row controllers
    
    self.childRowControllers = [[NSMutableArray alloc] init];
    
    // child exercise controllers
    
    self.childExerciseComponentControllers = [[NSMutableArray alloc] init];
    
}

- (void)initializeStateVariables{
    
    _activeNumberOfExercises = 0;
    
}







#pragma mark - View Life Cycle

- (void)loadView{
    
    CGFloat contentWidth = [self scrollViewContentWidth];
    CGFloat contentHeight = [self scrollViewContentHeight];
    
    // scroll view
    
    UIScrollView *scrollView = [[UIScrollView alloc] init];
    self.view = scrollView;
    scrollView.contentSize = CGSizeMake(contentWidth, contentHeight);
    
    // scroll view content container
    
    UIView *svContentContainer = [[UIView alloc] initWithFrame: CGRectMake(0, 0, contentWidth, contentHeight)];
    self.scrollViewContentContainer = svContentContainer;
    [scrollView addSubview: svContentContainer];
    
    svContentContainer.backgroundColor = [UIColor redColor];
    
}

- (void)viewDidLoad{
    
//    [self createChildViewControllersAndLayoutViews];
    
}










#pragma mark - Exercise Component

- (void)creatingStartingComponents{
    
    for (NSInteger i = 0; i < (int)_activeNumberOfExercises; i++){
        
        [self appendNewExerciseComponentToExistingStructure];
        
    }
    
    
    
}

- (void)appendNewExerciseComponentToExistingStructure{
    
    // if no exercise components yet exist, must treat autolayout differently
    
    NSInteger exerciseIndex = _activeNumberOfExercises + 1;
    
    TJBCircuitTemplateExerciseComp *exComp = [[TJBCircuitTemplateExerciseComp alloc] initWithChainTemplate: self.chainTemplate
                                                                                             exerciseIndex: (int)exerciseIndex
                                                                                          masterController: self];
    [self.childExerciseComponentControllers addObject: exComp];
    
    
    
}



#pragma mark - Layout Math

- (CGFloat)scrollViewContentHeight{
    
    return _activeNumberOfExercises * [self exerciseComponentHeight] + (_activeNumberOfExercises - 1) * interimExerciseComponentSpacing + topExerciseComponentSpacing + switchRowHeight;
    
}

- (CGFloat)scrollViewContentWidth{
    
    return [UIScreen mainScreen].bounds.size.width;
    
}

- (CGFloat)exerciseComponentHeight{
    
    CGFloat height = exerciseComponentStyleSpacing + exerciseRowHeight + roundRowHeight * _activeNumberOfRounds;
    
    return height;
    
}


- (void)createChildViewControllersAndLayoutViews{
    
    // for constraint mapping
    
    self.constraintMapping = [[NSMutableDictionary alloc] init];
    
    // scroll view
    
    CGRect scrollViewFrame = CGRectMake(0, 0, _viewSize.width, _viewSize.height);
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame: scrollViewFrame];
    
    // determine height of scroll view content size
    
    CGFloat titleBarHeight = 50;
    CGFloat contentRowHeight = 44;
    CGFloat componentToComponentSpacing = 24;
    CGFloat componentStyleSpacing = 9;
    CGFloat componentHeight;
    
    // the extra height allows the user to drag the bottom-most exercise further up on the screen
    
    CGFloat extraHeight = [UIScreen mainScreen].bounds.size.height / 4.0;
    
    componentHeight = titleBarHeight + contentRowHeight * (self.chainTemplate.numberOfRounds) + componentStyleSpacing;
    
    int numberOfComponents = self.chainTemplate.numberOfExercises;
    CGFloat scrollContentHeight = componentHeight * numberOfComponents + componentToComponentSpacing * (numberOfComponents - 1) + extraHeight;
    
    scrollView.contentSize = CGSizeMake(_viewSize.width, scrollContentHeight);
    [self.view addSubview: scrollView];
    
    CGRect scrollViewSubviewFrame = CGRectMake(0, 0, _viewSize.width, scrollContentHeight);
    UIView *scrollViewSubview = [[UIView alloc] initWithFrame: scrollViewSubviewFrame];
    [scrollView addSubview: scrollViewSubview];
    

    
    // row components
    
    NSMutableString *verticalLayoutConstraintsString = [NSMutableString stringWithCapacity: 1000];
    [verticalLayoutConstraintsString setString: @"V:|-2-"];
    
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

- (void)didDragAcrossPointInView:(CGPoint)dragPoint copyInputType:(TJBCopyInputType)copyInputType{
    
    // hit-test the point.  If that point is within the weight button of a child row comp, tell that row comp to update its value
    
    UIView *hitTestView = [self.view hitTest: dragPoint
                                   withEvent: nil];
    
    for (TJBCircuitTemplateRowComponent *rowComp in self.childRowControllers){
        
        switch (copyInputType) {
            case CopyWeightType:
                
                if ([rowComp.weightButton isEqual: hitTestView]){
                    
                    [rowComp copyValueForWeightButton];
                    
                }
                
                break;
                
            case CopyRepsType:
                
                if ([rowComp.repsButton isEqual: hitTestView]){
                    
                    [rowComp copyValueForRepsButton];
                    
                }
                
                break;
                
            case CopyRestType:
                
                if ([rowComp.restButton isEqual: hitTestView]){
                    
                    [rowComp copyValueForRestButton];
                    
                }
                
                break;
                
            default:
                break;
        }
        

        
    }
    
}

- (void)activateCopyingStateForNumber:(float)number copyInputType:(TJBCopyInputType)copyInputType{
    
    // activate the copying state in all row components for the given number
    
    for (TJBCircuitTemplateRowComponent *rowComp in self.childRowControllers){
        
        [rowComp activeCopyingStateForNumber: number
                               copyInputType: copyInputType];
        
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



























