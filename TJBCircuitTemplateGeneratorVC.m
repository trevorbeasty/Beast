//
//  TJBCircuitTemplateGeneratorVC.m
//  Beast
//
//  Created by Trevor Beasty on 12/16/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import "TJBCircuitTemplateGeneratorVC.h"

#import "CircuitDesignExerciseComponent.h"

#import "TJBNumberSelectionVC.h"

@interface TJBCircuitTemplateGeneratorVC () <TJBNumberSelectionDelegate>

@property (nonatomic, strong) NSMutableDictionary *constraintMapping;

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (nonatomic, strong) UINavigationItem *navItem;

// should consider blocks for this instead

@property (nonatomic, strong) NSNumber *activeRoundNumber;
@property (nonatomic, strong) NSNumber *activeChainNumber;
@property (nonatomic, strong) UIButton *activeButton;

@end

@implementation TJBCircuitTemplateGeneratorVC

#pragma mark - Instantiation

- (void)viewDidLoad
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
    
    // navigation item
    
    UINavigationItem *navItem = [[UINavigationItem alloc] init];
    
    UIBarButtonItem *xBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemStop
                                                                                target: self
                                                                                action: @selector(didPressStop)];
    
    [navItem setLeftBarButtonItem: xBarButton];
    
    [self.navBar setItems: @[navItem]];
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

#pragma mark - Soon to be Delegate Methods

- (void)presentNumberSelectionSceneWithNumberTypeIdentifier:(NSString *)identifier numberMultiple:(NSNumber *)numberMultiple title:(NSString *)title animated:(BOOL)animated
{
    UIStoryboard *numberSelectionStoryboard = [UIStoryboard storyboardWithName: @"TJBNumberSelection"
                                                                        bundle: nil];
    UINavigationController *numberSelectionNav = (UINavigationController *)[numberSelectionStoryboard instantiateInitialViewController];
    TJBNumberSelectionVC *numberSelectionVC = (TJBNumberSelectionVC *)[numberSelectionNav viewControllers][0];
    
    numberSelectionVC.numberTypeIdentifier = identifier;
    numberSelectionVC.numberMultiple = numberMultiple;
    numberSelectionVC.associatedVC = self;
    numberSelectionVC.title = title;
    
    [self presentViewController: numberSelectionNav
                       animated: animated
                     completion: nil];
}

- (void)didPressUserInputButtonWithType:(NSString *)type chainNumber:(NSNumber *)chainNumber roundNumber:(NSNumber *)roundNumber button:(UIButton *)button
{
    self.activeChainNumber = chainNumber;
    self.activeRoundNumber = roundNumber;
    self.activeButton = button;
    
    if ([type isEqualToString: @"weight"])
    {
        [self presentNumberSelectionSceneWithNumberTypeIdentifier: type
                                                   numberMultiple: [NSNumber numberWithDouble: 2.5]
                                                            title: @"Select Target Weight"
                                                         animated: NO];
    }
    else if ([type isEqualToString: @"reps"])
    {
        [self presentNumberSelectionSceneWithNumberTypeIdentifier: type
                                                   numberMultiple: [NSNumber numberWithDouble: 1.0]
                                                            title: @"Select Target Reps"
                                                         animated: NO];
    }
    else if ([type isEqualToString: @"rest"])
    {
        [self presentNumberSelectionSceneWithNumberTypeIdentifier: type
                                                   numberMultiple: [NSNumber numberWithDouble: 5.0]
                                                            title: @"Select Target Rest (in seconds)"
                                                         animated: NO];
    }
}

#pragma mark - <TJBNumberSelectionDelegate>

- (void)didSelectNumber:(NSNumber *)number numberTypeIdentifier:(NSString *)identifier
{
    [self.activeButton setTitle: [number stringValue]
                       forState: UIControlStateNormal];
    
    [self dismissViewControllerAnimated: NO
                             completion: nil];
}

- (void)didCancelNumberSelection
{
    [self dismissViewControllerAnimated: NO
                             completion: nil];
}


@end

















