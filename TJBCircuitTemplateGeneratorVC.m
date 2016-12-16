//
//  TJBCircuitTemplateGeneratorVC.m
//  Beast
//
//  Created by Trevor Beasty on 12/16/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import "TJBCircuitTemplateGeneratorVC.h"

#import "CircuitDesignExerciseComponent.h"

@interface TJBCircuitTemplateGeneratorVC ()

@property (nonatomic, strong) NSMutableDictionary *constraintMapping;

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@property (nonatomic, strong) UINavigationItem *navItem;

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
    CGFloat componentHeight = rowHeight * ([self.numberOfRounds intValue] + 2) + componentStyleSpacing;
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
                                                                                                 chainIndex: [NSNumber numberWithInt: i + 1]
                                                                                               exerciseName: @"placeholder exercise"];
        
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


@end

















