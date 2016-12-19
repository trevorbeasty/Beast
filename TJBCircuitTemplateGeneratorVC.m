//
//  TJBCircuitTemplateGeneratorVC.m
//  Beast
//
//  Created by Trevor Beasty on 12/16/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import "TJBCircuitTemplateGeneratorVC.h"

#import "TJBNumberSelectionVC.h"

#import "TJBExerciseSelectionScene.h"




@interface TJBCircuitTemplateGeneratorVC () <TJBNumberSelectionDelegate>

@property (nonatomic, strong) NSMutableDictionary *constraintMapping;

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (nonatomic, strong) UINavigationItem *navItem;

// should consider blocks for this instead

@property (nonatomic, strong) NSNumber *activeRoundNumber;
@property (nonatomic, strong) NSNumber *activeChainNumber;
@property (nonatomic, strong) UIButton *activeButton;

// data structure

@property (nonatomic, strong) NSMutableArray *weightData;
@property (nonatomic, strong) NSMutableArray *repsData;
@property (nonatomic, strong) NSMutableArray *restData;

@end






static NSString * const defaultValue = @"unselected";







@implementation TJBCircuitTemplateGeneratorVC

#pragma mark - Instantiation

- (NSMutableArray *)createDataStructureObject
{
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

- (void)createDataStructure
{
    self.weightData = [self createDataStructureObject];
    self.repsData = [self createDataStructureObject];
    self.restData = [self createDataStructureObject];
}

- (void)createSubviewsAndLayoutConstraints
{
    // scroll view
    
    CGRect screenBounds = [[UIScreen mainScreen] bounds];
    CGFloat screenWidth = screenBounds.size.width;
    
    CGFloat rowHeight = 30;
    CGFloat componentToComponentSpacing = 20;
    CGFloat initialSpacing = 8;
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
        CircuitDesignExerciseComponent *vc = [[CircuitDesignExerciseComponent alloc] initWithNumberOfRounds: self.numberOfRounds
                                                                                            targetingWeight: self.targetingWeight
                                                                                              targetingReps: self.targetingReps
                                                                                              targetingRest: self.targetingRest
                                                                                         targetsVaryByRound: self.targetsVaryByRound
                                                                                                chainNumber: [NSNumber numberWithInt: i + 1]
                                                                                               exerciseName: @"placeholder"
                                                                                           masterController: self];
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

- (void)createNavigationItem
{
    UINavigationItem *navItem = [[UINavigationItem alloc] init];
    
    UIBarButtonItem *xBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemStop
                                                                                target: self
                                                                                action: @selector(didPressStop)];
    [navItem setLeftBarButtonItem: xBarButton];
    
    UIBarButtonItem *goBarButton = [[UIBarButtonItem alloc] initWithTitle: @"Go"
                                                                    style: UIBarButtonItemStyleDone
                                                                   target: self
                                                                   action: @selector(didPressGoButton)];
    [navItem setRightBarButtonItem: goBarButton];
    
    [self.navBar setItems: @[navItem]];
}

- (void)viewDidLoad
{
    // data structure
    
    [self createDataStructure];
    
    // subviews and layout constraints
    
    [self createSubviewsAndLayoutConstraints];
    
    // navigation item
    
    [self createNavigationItem];
}



- (instancetype)initWithTargetingWeight:(NSNumber *)targetingWeight targetingReps:(NSNumber *)targetingReps targetingRest:(NSNumber *)targetingRest targetsVaryByRound:(NSNumber *)targetsVaryByRound numberOfExercises:(NSNumber *)numberOfExercises numberOfRounds:(NSNumber *)numberOfRounds
{
    self = [super init];
    
    self.targetingWeight = targetingWeight;
    self.targetingReps = targetingReps;
    self.targetingRest = targetingRest;
    self.targetsVaryByRound = targetsVaryByRound;
    self.numberOfExercises = numberOfExercises;
    self.numberOfRounds = numberOfRounds;
    
    return self;
}

#pragma mark - Button Actions

- (void)didPressStop
{
    [self dismissViewControllerAnimated: NO
                             completion: nil];
}

- (void)didPressGoButton
{
    NSLog(@"all selections made?: %d",
          [self allSelectionsMade]);
}

- (BOOL)allSelectionsMade
{
    BOOL allWeightSelectionsMade;
    BOOL allRepsSelectionsMade;
    BOOL allRestSelectionsMade;
    
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
    
    NSLog(@"weight: %d\nreps: %d\nrest: %d",
          allWeightSelectionsMade,
          allRepsSelectionsMade,
          allRestSelectionsMade);
        
    return allWeightSelectionsMade && allRepsSelectionsMade && allRestSelectionsMade;
}

- (BOOL)dataStructureContainsDefaultValue:(NSArray *)dataStructure
{
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

- (void)presentNumberSelectionSceneWithNumberTypeIdentifier:(NumberType)identifier numberMultiple:(NSNumber *)numberMultiple title:(NSString *)title animated:(BOOL)animated
{
    UIStoryboard *numberSelectionStoryboard = [UIStoryboard storyboardWithName: @"TJBNumberSelection"
                                                                        bundle: nil];
    UINavigationController *numberSelectionNav = (UINavigationController *)[numberSelectionStoryboard instantiateInitialViewController];
    TJBNumberSelectionVC *numberSelectionVC = (TJBNumberSelectionVC *)[numberSelectionNav viewControllers][0];
    
    [numberSelectionVC setNumberTypeIdentifier: identifier];
    numberSelectionVC.numberMultiple = numberMultiple;
    numberSelectionVC.associatedVC = self;
    numberSelectionVC.title = title;
    
    [self presentViewController: numberSelectionNav
                       animated: animated
                     completion: nil];
}

- (void)didPressUserInputButtonWithType:(NumberType)type chainNumber:(NSNumber *)chainNumber roundNumber:(NSNumber *)roundNumber button:(UIButton *)button
{
    self.activeChainNumber = chainNumber;
    self.activeRoundNumber = roundNumber;
    self.activeButton = button;
    
    if (type == WeightType)
    {
        [self presentNumberSelectionSceneWithNumberTypeIdentifier: type
                                                   numberMultiple: [NSNumber numberWithDouble: 2.5]
                                                            title: @"Select Target Weight"
                                                         animated: NO];
    }
    else if (type == RepsType)
    {
        [self presentNumberSelectionSceneWithNumberTypeIdentifier: type
                                                   numberMultiple: [NSNumber numberWithDouble: 1.0]
                                                            title: @"Select Target Reps"
                                                         animated: NO];
    }
    else if (type == RestType)
    {
        [self presentNumberSelectionSceneWithNumberTypeIdentifier: type
                                                   numberMultiple: [NSNumber numberWithDouble: 5.0]
                                                            title: @"Select Target Rest (in seconds)"
                                                         animated: NO];
    }
    
}

- (void)didPressExerciseButton:(UIButton *)button inChain:(NSNumber *)chainNumber
{
    TJBExerciseSelectionScene *vc = [[TJBExerciseSelectionScene alloc] init];
    
    [self presentViewController: vc
                       animated: NO
                     completion: nil];
}

#pragma mark - <TJBNumberSelectionDelegate>

- (void)didSelectNumber:(NSNumber *)number numberTypeIdentifier:(NumberType)identifier
{
    [self.activeButton setTitle: [number stringValue]
                       forState: UIControlStateNormal];
    
    int indexOne = [self.activeChainNumber intValue] - 1;
    int indexTwo = [self.activeRoundNumber intValue] - 1;
    
    if (identifier == WeightType)
    {
        self.weightData[indexOne][indexTwo] = number;
        NSLog(@"%@", self.weightData);
    }
    else if (identifier == RepsType)
    {
        self.repsData[indexOne][indexTwo] = number;
        NSLog(@"%@", self.repsData);
    }
    else if (identifier == RestType)
    {
        self.restData[indexOne][indexTwo] = number;
        NSLog(@"%@", self.restData);
    }
    
    [self dismissViewControllerAnimated: NO
                             completion: nil];
}

- (void)didCancelNumberSelection
{
    [self dismissViewControllerAnimated: NO
                             completion: nil];
}


@end

















