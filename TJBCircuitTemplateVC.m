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
#import "TJBRoutineNameVC.h"

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
@property (nonatomic, strong) NSMutableArray <NSMutableArray <TJBCircuitTemplateRowComponent<TJBCircuitTemplateRowComponentProtocol> *> *> * childRowControllers;

// views

@property (strong) UIView *scrollViewContentContainer;
@property (nonatomic, strong) NSMutableDictionary *constraintMapping;
@property (strong) NSMutableArray *currentVerticalConstraints; // constraints are tracked here so they can be removed when the number of exercises or rounds changes

@end


// private constants



static NSString * const defaultValue = @"unselected";

// layout

static CGFloat const roundRowHeight = 44.0;
static CGFloat const exerciseRowHeight = 50.0;
static CGFloat const topExerciseComponentSpacing = 24.0;
static CGFloat const topNameVCSpacing = 8.0;
static CGFloat const nameVCHeight = 50;
static CGFloat const interimExerciseComponentSpacing = 24.0;
static CGFloat const exerciseComponentStyleSpacing = 7.0;

static NSString * const nameVCKey = @"TJBRoutineNameVC";




@implementation TJBCircuitTemplateVC

#pragma mark - Instantiation

- (instancetype)initWithSkeletonChainTemplate:(TJBChainTemplate *)skeletonChainTemplate viewSize:(CGSize)viewSize{
    
    // call to super
    
    self = [super init];
    
    return self;
}

- (instancetype)initWithSkeletonChainTemplate:(TJBChainTemplate *)skeletonChainTemplate startingNumberOfExercises:(NSNumber *)startingNumberOfExercises startingNumberOfRounds:(NSNumber *)startingNumberOfRounds{
    
    self = [super init];
    
    // IVs
    
    self.chainTemplate = skeletonChainTemplate;
    _activeNumberOfExercises = [startingNumberOfExercises floatValue];
    _activeNumberOfRounds = [startingNumberOfRounds floatValue];
    
    // instantiation helper methods
    
    [self initializeCollectors];
    
    return self;
    
}










#pragma mark - Init Helper Methods

- (void)createPlaceholderArrayForSelectedExercises{
    
    // this set will collect the exercises the user chooses and will eventually be assigned to the chain template after all user selections have been made when allUserInputCollected is calledr
    
    NSMutableOrderedSet *placeholderExerisesSet = [[CoreDataController singleton] placeholderExerciseSetWithLength: (int)_activeNumberOfExercises];
    
    self.selectedExercises = placeholderExerisesSet;
    
}


- (void)initializeCollectors{
    
    // child row controllers
    
    self.childRowControllers = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < (int)_activeNumberOfExercises; i++){
        
        NSMutableArray *iterativeArray = [[NSMutableArray alloc] init];
        
        [self.childRowControllers addObject: iterativeArray];
        
    }
    
    // child exercise controllers
    
    self.childExerciseComponentControllers = [[NSMutableArray alloc] init];
    
    // constraint mapping
    
    self.constraintMapping = [[NSMutableDictionary alloc] init];
    
    // vertical constraints
    
    self.currentVerticalConstraints = [[NSMutableArray alloc] init];
    
    // exercises
    
    [self createPlaceholderArrayForSelectedExercises];
    
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
    
    scrollView.backgroundColor = [UIColor clearColor];
    svContentContainer.backgroundColor = [UIColor clearColor];
    
}

- (void)viewDidLoad{
    
    [self createStartingViewControllerHierarchy];
    
}














#pragma mark - Content Generation

- (void)createStartingViewControllerHierarchy{
    
    [self appendRoutineNameVCToExistingStructure];
    
    for (int i = 0; i < (int)_activeNumberOfExercises; i++){
            
        [self appendNewExerciseComponentToExistingStructureWithExerciseIndex: i];
        
    }
    
}

- (void)appendRoutineNameVCToExistingStructure{
    
    TJBRoutineNameVC *nameVC = [[TJBRoutineNameVC alloc] init];
    
    // vc & view hierarchies
    
    [self addChildViewController: nameVC];
    
    [self.scrollViewContentContainer addSubview: nameVC.view];
    
    // layout constraints
    
    [self.constraintMapping setObject: nameVC.view
                               forKey: nameVCKey];
    
    nameVC.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    // horizontal
    
    NSString *horVFL = [NSString stringWithFormat: @"H:|-0-[%@]-0-|", nameVCKey];
    
    NSArray *horizontalLayoutConstraints = [NSLayoutConstraint constraintsWithVisualFormat: horVFL
                                                                                   options: 0
                                                                                   metrics: nil
                                                                                     views: self.constraintMapping];
    
    [self.scrollViewContentContainer addConstraints: horizontalLayoutConstraints];
    
    // vertical
    
    NSString *verVFL = [NSString stringWithFormat: @"V:|-%f-[%@(==%f)]",
                        topNameVCSpacing,
                        nameVCKey,
                        nameVCHeight];
    
    NSArray *verticalLayoutConstraints = [NSLayoutConstraint constraintsWithVisualFormat: verVFL
                                                                                 options: 0
                                                                                 metrics: nil
                                                                                   views: self.constraintMapping];
    
    [self.scrollViewContentContainer addConstraints: verticalLayoutConstraints];
    
    // vc hierachy
    
    [nameVC didMoveToParentViewController: self];
    
}


- (void)appendNewExerciseComponentToExistingStructureWithExerciseIndex:(int)exerciseIndex{
    
    TJBCircuitTemplateExerciseComp *exComp = [[TJBCircuitTemplateExerciseComp alloc] initWithChainTemplate: self.chainTemplate
                                                                                             exerciseIndex: exerciseIndex
                                                                                          masterController: self];
    
    // vc & view hierarchies
    
    [self.childExerciseComponentControllers addObject: exComp];
    
    [self addChildViewController: exComp];
    
    [self.scrollViewContentContainer addSubview: exComp.view];
    
    // layout constraints
    
    NSString *dynamicComponentName = [self dynamicComponentNameForExerciseIndex: exerciseIndex];
    [self.constraintMapping setObject: exComp.view
                               forKey: dynamicComponentName];
    
    exComp.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    // horizontal
    
    NSString *horVFL = [self horVFLForExerciseIndex: exerciseIndex];
    
    NSArray *horizontalLayoutConstraints = [NSLayoutConstraint constraintsWithVisualFormat: horVFL
                                                                                   options: 0
                                                                                   metrics: nil
                                                                                     views: self.constraintMapping];
    
    [self.scrollViewContentContainer addConstraints: horizontalLayoutConstraints];
    
    // vertical
    
    NSString *verVFL = [self verVFLForExerciseIndex: exerciseIndex];
    
    NSArray *verticalLayoutConstraints = [NSLayoutConstraint constraintsWithVisualFormat: verVFL
                                                                                 options: 0
                                                                                 metrics: nil
                                                                                   views: self.constraintMapping];
    
    [self.currentVerticalConstraints addObjectsFromArray: verticalLayoutConstraints];
    
    [self.scrollViewContentContainer addConstraints: verticalLayoutConstraints];
    
    // vc hierachy
    
    [exComp didMoveToParentViewController: self];
    
}


- (NSString *)horVFLForExerciseIndex:(int)exerciseIndex{
    
    NSString *dynamicComponentName = [self dynamicComponentNameForExerciseIndex: exerciseIndex];
        
    return [NSString stringWithFormat: @"H:|-0-[%@]-0-|", dynamicComponentName];

}

- (NSString *)verVFLForExerciseIndex:(int)exerciseIndex{
    
    NSString *dynamicComponentName = [self dynamicComponentNameForExerciseIndex: exerciseIndex];
    float exCompHeight = [self exerciseComponentHeight];
    
    if (exerciseIndex == 0){
        
        return [NSString stringWithFormat: @"V:[%@]-%f-[%@(==%f)]",
                nameVCKey,
                topExerciseComponentSpacing,
                dynamicComponentName,
                exCompHeight];
        
    } else{
        
        NSString *previousDynamicComponentName = [self dynamicComponentNameForExerciseIndex: exerciseIndex - 1];
        
        return [NSString stringWithFormat:  @"V:[%@]-%f-[%@(==%f)]",
                previousDynamicComponentName,
                interimExerciseComponentSpacing,
                dynamicComponentName,
                exCompHeight];
        
    }
    
    
    
}


- (NSString *)dynamicComponentNameForExerciseIndex:(int)exerciseIndex{
    
    return [NSString stringWithFormat: @"exerciseComponent%d",
            exerciseIndex];
    
}

#pragma mark - Row & Exercise Addition / Deletion

- (void)addRowToExistingStructure{
    
    _activeNumberOfRounds += 1;
    
    [self configureVerticalConstraintsForNewSpecifications];
    [self resetContentSize];
    
    for (TJBCircuitTemplateExerciseComp *exComp in self.childExerciseComponentControllers){
        
        int newRoundRowIndex = (int)(_activeNumberOfRounds - 1);
        
        [exComp addRoundRowForExerciseIndex: newRoundRowIndex];
        
    }

    
    return;
    
}

- (void)removeLastRowFromExistingStructure{
    
    int previousNumberRounds = _activeNumberOfRounds;
    _activeNumberOfRounds -= 1;
    
    [self configureVerticalConstraintsForNewSpecifications];
    [self resetContentSize];
    
    int rowToDeleteIndex = previousNumberRounds - 1;
    
    for (int i = 0; i < (int)_activeNumberOfExercises; i++){
        
        TJBCircuitTemplateRowComponent *rowComp = self.childRowControllers[i][rowToDeleteIndex];
        [self.childRowControllers[i] removeObject: rowComp];
        
        TJBCircuitTemplateExerciseComp *exComp = self.childExerciseComponentControllers[i];
        
        [exComp deleteRowCorrespondingToRowComponent: rowComp];
        
    }
 
}

- (void)addExerciseToExistingStructure{
    
    int previousNumberOfExercises = _activeNumberOfExercises;
    _activeNumberOfExercises += 1;
    
    NSMutableArray *muteArray = [[NSMutableArray alloc] init];
    [self.childRowControllers addObject: muteArray]; // b/c child row controllers are tracked with array of 2-dimensions, must add a mutable array to account for new exercise
    
    [[CoreDataController singleton] appendPlaceholderExerciseToSelectedExercisesSet: self.selectedExercises];
    
    [self appendNewExerciseComponentToExistingStructureWithExerciseIndex: previousNumberOfExercises];
    [self resetContentSize];
    
    return;
    
}


-  (void)removeLastExerciseFromExistingStructure{
    
    int previousNumberOfExercises = _activeNumberOfExercises;
    _activeNumberOfExercises -= 1;
    
    [self.childRowControllers removeLastObject]; // b/c child row controllers are tracked with array of 2-dimensions, must delete a mutable array to account for exercise removal
    
    [self.selectedExercises removeObjectAtIndex: previousNumberOfExercises - 1];
    
    [self removeExerciseFromVCHierarchyCorrespondingToExerciseIndex: previousNumberOfExercises - 1];
    [self configureVerticalConstraintsForNewSpecifications];
    [self resetContentSize];
    
    return;
    
}

#pragma mark - Row & Exercise Addition / Deletion Helper Methods

- (void)removeExerciseFromVCHierarchyCorrespondingToExerciseIndex:(int)exerciseIndex{
    
    TJBCircuitTemplateExerciseComp *exCompToDelete = self.childExerciseComponentControllers[exerciseIndex];
    
    // constraint mapping
    
    NSString *dynamicComponentName = [self dynamicComponentNameForExerciseIndex: exerciseIndex];
    [self.constraintMapping removeObjectForKey: dynamicComponentName];
    
    // VC & view
    
    [exCompToDelete willMoveToParentViewController: nil];
    
    [exCompToDelete.view removeFromSuperview];
    
    [exCompToDelete removeFromParentViewController];
    
    // tracking array
    
    [self.childExerciseComponentControllers removeObject: exCompToDelete];
    
}

- (void)configureVerticalConstraintsForNewSpecifications{
    
    [NSLayoutConstraint deactivateConstraints: self.currentVerticalConstraints];
    self.currentVerticalConstraints = [[NSMutableArray alloc] init];
    
    for (TJBCircuitTemplateExerciseComp *exComp in self.childExerciseComponentControllers){
        
        int i = (int)[self.childExerciseComponentControllers indexOfObject: exComp];
        
        NSString *vertVFL = [self verVFLForExerciseIndex: i];
        
        NSArray *verConstrs = [NSLayoutConstraint constraintsWithVisualFormat: vertVFL
                                                                      options: 0
                                                                      metrics: nil
                                                                        views: self.constraintMapping];
        
        [self.currentVerticalConstraints addObjectsFromArray: verConstrs];
        
        [self.scrollViewContentContainer addConstraints: verConstrs];
        
    }
    
}

- (void)resetContentSize{
    
    CGFloat width = [self scrollViewContentWidth];
    CGFloat height = [self scrollViewContentHeight];
    
    UIScrollView *sv = (UIScrollView *)self.view;
    sv.contentSize = CGSizeMake(width, height);
    
    self.scrollViewContentContainer.frame = CGRectMake(0, 0, width, height);
    
}






#pragma mark - Layout Math

- (CGFloat)scrollViewContentHeight{
    
    return _activeNumberOfExercises * [self exerciseComponentHeight] + (_activeNumberOfExercises - 1) * interimExerciseComponentSpacing + topExerciseComponentSpacing + nameVCHeight + topNameVCSpacing + [UIScreen mainScreen].bounds.size.height / 2.0;
    
}

- (CGFloat)scrollViewContentWidth{
    
    return [UIScreen mainScreen].bounds.size.width;
    
}

- (CGFloat)exerciseComponentHeight{
    
    CGFloat height = exerciseComponentStyleSpacing + exerciseRowHeight + roundRowHeight * (_activeNumberOfRounds + 1); // the switch row is given the same height as the rounds rows and is responsible for the '+ 1'
    
    return height;
    
}







#pragma mark - Old

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
    for (NSMutableArray *muteArray in self.childRowControllers){
        
        for (TJBCircuitTemplateRowComponent *rowComp in muteArray){
            
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
    
}

- (void)activateCopyingStateForNumber:(float)number copyInputType:(TJBCopyInputType)copyInputType{
    
    // activate the copying state in all row components for the given number
    
    for (NSMutableArray *muteArray in self.childRowControllers){
        
        for (TJBCircuitTemplateRowComponent *rowComp in muteArray){
            

            [rowComp activeCopyingStateForNumber: number
                                   copyInputType: copyInputType];
            
        }
        
    }
    
}

- (void)deactivateCopyingState{
    
    // deactivate the copying state in all row components
    
    for (NSMutableArray *muteArray in self.childRowControllers){
        
        for (TJBCircuitTemplateRowComponent *rowComp in muteArray){
            
            
            [rowComp deactivateCopyingState];
            
        }
        
    }
    
}

- (void)didSelectExercise:(TJBExercise *)exercise forExerciseIndex:(int)exerciseIndex{
    
    self.selectedExercises[exerciseIndex] = exercise;
    
    // save every time a selection is made
    
    self.chainTemplate.exercises = self.selectedExercises;
    
    [[CoreDataController singleton] saveContext];
    
}

- (void)addChildRowController:(TJBCircuitTemplateRowComponent<TJBCircuitTemplateRowComponentProtocol> *)rowController correspondingToExerciseIndex:(int)exerciseIndex{
    
    [self.childRowControllers[exerciseIndex] addObject: rowController];
    
}



- (BOOL)allUserInputCollected{
    
    // assign the user-selected exercises to the chain template and then use the CoreDataController to evaluate if all user input has been collected
    
    // I do not assign the exercises property of chain template here because it is assigned every time a selection is made, and the core data controller method also checks for existence of the exercises property
    
    return [[CoreDataController singleton] chainTemplateHasCollectedAllRequisiteUserInput: self.chainTemplate];
    
}


- (void)didIncrementNumberOfExercisesInUpDirection:(BOOL)upDirection{
    
    if (upDirection == YES){
        
        [self addExerciseToExistingStructure];
        
    } else{
        
        [self removeLastExerciseFromExistingStructure];
    }
    
}

- (void)didIncrementNumberOfRoundsInUpDirection:(BOOL)upDirection{
    
    if (upDirection == YES){
        
        [self addRowToExistingStructure];
        
    } else{
        
        [self removeLastRowFromExistingStructure];
    }
    
}

- (void)configureRowsForExerciseIndex:(int)exerciseIndex switchType:(TJBSwitchType)switchType activated:(BOOL)activated{
    
    NSArray *relevantRowControllers = self.childRowControllers[exerciseIndex];
    
    for (TJBCircuitTemplateRowComponent *rowComp in relevantRowControllers){
        
        switch (switchType) {
            case WeightSwitch:
                [rowComp toggleWeightTargetingStateToActive: activated];
                break;
                
            case RepsSwitch:
                [rowComp toggleRepsTargetingStateToActive: activated];
                break;
                
            case TrailingRestSwitch:
                [rowComp toggleTrailingRestTargetingStateToActive: activated];
                break;
                
            default:
                break;
        }
        
    }
    

    
}

#pragma mark - API

- (NSNumber *)numberOfRounds{
    
    return  @(_activeNumberOfRounds);
    
}

@end



























