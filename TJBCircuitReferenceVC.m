//
//  TJBCircuitReferenceVC.m
//  Beast
//
//  Created by Trevor Beasty on 1/11/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBCircuitReferenceVC.h"

// core data

#import "TJBChainTemplate+CoreDataProperties.h"
#import "TJBWeightArray+CoreDataProperties.h"
#import "TJBRepsArray+CoreDataProperties.h"
#import "TJBTargetRestTimeArray+CoreDataProperties.h"

// child VC's

#import "TJBCircuitReferenceExerciseComp.h"

@interface TJBCircuitReferenceVC ()

// core

@property (nonatomic, strong) TJBChainTemplate *chainTemplate;
@property (nonatomic, strong) NSNumber *viewHeight;
@property (nonatomic, strong) NSNumber *viewWidth;

// IV's derived from chainTemplate

@property (nonatomic, strong) NSNumber *numberOfExercises;
@property (nonatomic, strong) NSNumber *numberOfRounds;

@property (nonatomic, strong) NSNumber *targetingWeight;
@property (nonatomic, strong) NSNumber *targetingReps;
@property (nonatomic, strong) NSNumber *targetingRest;
@property (nonatomic, strong) NSNumber *targetsVaryByRound;

@property (nonatomic, strong) NSString *name;

// for programmatic layout constraints

@property (nonatomic, strong) NSMutableDictionary *constraintMapping;

@end

@implementation TJBCircuitReferenceVC

#pragma mark - Instantiation

- (instancetype)initWithChainTemplate:(TJBChainTemplate *)chainTemplate viewHeight:(NSNumber *)viewHeight viewWidth:(NSNumber *)viewWidth{
    
    self = [super init];
    
    // core
    
    self.chainTemplate = chainTemplate;
    self.viewHeight = viewHeight;
    self.viewWidth = viewWidth;
    
    // set IV's derived from chain template
    
    self.numberOfRounds = [NSNumber numberWithInt: chainTemplate.numberOfRounds];
    self.numberOfExercises = [NSNumber numberWithInt: chainTemplate.numberOfExercises];
    
    self.targetingWeight = [NSNumber numberWithBool: chainTemplate.targetingWeight];
    self.targetingReps = [NSNumber numberWithBool: chainTemplate.targetingReps];
    self.targetingRest = [NSNumber numberWithBool: chainTemplate.targetingRestTime];
    self.targetsVaryByRound = [NSNumber numberWithBool: chainTemplate.targetsVaryByRound];
    
    self.name = chainTemplate.name;
    
    return self;
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
    
    //    [self addBackgroundView];
    
    [self createChildViewControllersAndLayoutViews];
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
    // there is something wrong with my math in calculating contentSize.height
    // I have included an error term for now
    CGFloat error = 16;
    
    componentHeight = rowHeight * ([self.numberOfRounds intValue] + 2) + componentStyleSpacing;
    
    int numberOfComponents = [self.numberOfExercises intValue];
    CGFloat scrollContentHeight = componentHeight * numberOfComponents + componentToComponentSpacing * (numberOfComponents - 1) + error;
    
    scrollView.contentSize = CGSizeMake([self.viewWidth floatValue], scrollContentHeight);
    [self.view addSubview: scrollView];
    
    CGRect scrollViewSubviewFrame = CGRectMake(0, 0, [self.viewWidth floatValue], scrollContentHeight);
    UIView *scrollViewSubview = [[UIView alloc] initWithFrame: scrollViewSubviewFrame];
    [scrollView addSubview: scrollViewSubview];
    
    
    
    // row components
    
    NSMutableString *verticalLayoutConstraintsString = [NSMutableString stringWithCapacity: 1000];
    [verticalLayoutConstraintsString setString: @"V:|-"];
    
    for (int i = 0 ; i < [self.numberOfExercises intValue] ; i ++){
        
        // only attempt to pass data if the value is being targeted, otherwise pass nil
        
        NSOrderedSet <TJBNumberTypeArrayComp *> *weight;
        NSOrderedSet <TJBNumberTypeArrayComp *> *reps;
        NSOrderedSet <TJBNumberTypeArrayComp *> *rest;
        
        if ([self.targetingWeight boolValue] == YES){
            weight = self.chainTemplate.weightArrays[i].numbers;
        } else{
            weight = nil;
        }
        
        if ([self.targetingReps boolValue] == YES){
            reps = self.chainTemplate.repsArrays[i].numbers;
        } else{
            reps = nil;
        }
        
        if ([self.targetingRest boolValue] == YES){
            rest = self.chainTemplate.targetRestTimeArrays[i].numbers;
        } else{
            rest = nil;
        }
        
        TJBCircuitReferenceExerciseComp *vc = [[TJBCircuitReferenceExerciseComp alloc] initWithNumberOfRounds: self.numberOfRounds
                                                                                              targetingWeight: self.targetingWeight
                                                                                                targetingReps: self.targetingReps
                                                                                                targetingRest: self.targetingRest
                                                                                           targetsVaryByRound: self.targetsVaryByRound
                                                                                                  chainNumber: [NSNumber numberWithInt: i + 1]
                                                                                                     exercise: self.chainTemplate.exercises[i]
                                                                                                   weightData: weight
                                                                                                     repsData: reps
                                                                                                     restData: rest];
        
        
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
    
    for (TJBCircuitReferenceExerciseComp *child in self.childViewControllers){
        
        [child didMoveToParentViewController: self];
    }
}




@end










































