//
//  TJBCircuitReferenceVC.m
//  Beast
//
//  Created by Trevor Beasty on 1/11/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBCircuitReferenceVC.h"

// core data

#import "CoreDataController.h"

// child VC's

#import "TJBCircuitReferenceExerciseComp.h"
#import "TJBCircuitReferenceRowComp.h"

// aesthetics

#import "TJBAestheticsController.h"

@interface TJBCircuitReferenceVC ()

{
    
    // core
    
    CGSize _prescribedSize;
    
}

// core

@property (nonatomic, strong) TJBRealizedChain *realizedChain;
@property (nonatomic, strong) NSMutableArray *childExerciseCompControllers;

// for programmatic layout constraints

@property (nonatomic, strong) NSMutableDictionary *constraintMapping;



@end

@implementation TJBCircuitReferenceVC

#pragma mark - Instantiation

- (instancetype)initWithRealizedChain:(TJBRealizedChain *)realizedChain viewSize:(CGSize)size{
    
    self = [super init];
    
    self.realizedChain = realizedChain;
    _prescribedSize = size;
    
    // prep
    
    self.childExerciseCompControllers = [[NSMutableArray alloc] init];
    
    return self;
    
}

#pragma mark - View Life Cycle

- (void)loadView{
    
    // this must be called when creating the view programatically
        
    CGRect frame = CGRectMake(0, 0, _prescribedSize.width, _prescribedSize.height);
    UIView *view = [[UIView alloc] initWithFrame: frame];
    view.backgroundColor = [UIColor clearColor];
    self.view = view;
    
}


- (void)viewDidLoad{
    
    // meta view background color
    
    self.view.backgroundColor = [[TJBAestheticsController singleton] offWhiteColor];
    
    [self createChildViewControllersAndLayoutViews];
    
}

- (void)createChildViewControllersAndLayoutViews{
    
    // for constraint mapping
    
    self.constraintMapping = [[NSMutableDictionary alloc] init];
    
    // scroll view
    
    CGRect scrollViewFrame = CGRectMake(0, 0, _prescribedSize.width, _prescribedSize.height);
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame: scrollViewFrame];
    
    // determine height of scroll view content size
    
    CGFloat rowHeight = 50;
    CGFloat componentToComponentSpacing = 16;
    CGFloat componentStyleSpacing = 8;
    CGFloat componentHeight;
    CGFloat initialTopSpacing = 16.0;

    // the extra height allows the user to drag the bottom-most exercise further up on the screen
    
    CGFloat extraHeight = [UIScreen mainScreen].bounds.size.height / 4.0;
    
    componentHeight = rowHeight * (self.realizedChain.numberOfRounds + 2) + componentStyleSpacing;
    
    int numberOfComponents = self.realizedChain.numberOfExercises;
    CGFloat scrollContentHeight = componentHeight * numberOfComponents + componentToComponentSpacing * (numberOfComponents - 1) + extraHeight;
    
    scrollView.contentSize = CGSizeMake(_prescribedSize.width, scrollContentHeight + initialTopSpacing);
    [self.view addSubview: scrollView];
    
    CGRect scrollViewSubviewFrame = CGRectMake(0, 0, _prescribedSize.width, scrollContentHeight + initialTopSpacing);
    UIView *scrollViewSubview = [[UIView alloc] initWithFrame: scrollViewSubviewFrame];
    [scrollView addSubview: scrollViewSubview];
    
    
    
    // exercise components
    
    NSMutableString *verticalLayoutConstraintsString = [NSMutableString stringWithCapacity: 1000];
    NSString *string = [NSString stringWithFormat: @"V:|-%f-", initialTopSpacing];
    [verticalLayoutConstraintsString setString: string];
    
    for (int i = 0 ; i < self.realizedChain.numberOfExercises ; i ++){
        
        TJBCircuitReferenceExerciseComp *vc = [[TJBCircuitReferenceExerciseComp alloc] initWithRealizedChain: self.realizedChain
                                                                                               exerciseIndex: i];
        
        // add the vc to the child controllers array
        
        [self.childExerciseCompControllers addObject: vc];
        
        vc.view.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addChildViewController: vc];
        
        [scrollViewSubview addSubview: vc.view];
        
        NSString *dynamicComponentName = [NSString stringWithFormat: @"exerciseComponent%d",
                                          i];
        
        [self.constraintMapping setObject: vc.view
                                   forKey: dynamicComponentName];
        
        // vertical constraints
        
        NSString *verticalAppendString;
        
        if (i == self.realizedChain.numberOfExercises - 1){
            
            verticalAppendString = [NSString stringWithFormat: @"[%@(==%f)]",
                                    dynamicComponentName,
                                    componentHeight];
        } else{
            
            verticalAppendString = [NSString stringWithFormat: @"[%@(==%f)]-%d-",
                                    dynamicComponentName,
                                    componentHeight,
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
    
    NSLog(@"%@", verticalLayoutConstraintsString);
    
    NSArray *verticalLayoutConstraints = [NSLayoutConstraint constraintsWithVisualFormat: verticalLayoutConstraintsString
                                                                                 options: 0
                                                                                 metrics: nil
                                                                                   views: self.constraintMapping];
    
    [scrollViewSubview addConstraints: verticalLayoutConstraints];
    
    for (TJBCircuitReferenceExerciseComp *child in self.childViewControllers){
        
        [child didMoveToParentViewController: self];
    }
}

#pragma mark - Class Interface

- (void)activateMode:(TJBRoutineReferenceMode)mode{
    
    for (TJBCircuitReferenceExerciseComp *exerciseComp in self.childExerciseCompControllers){
        
        switch (mode) {
            case EditingMode:
                [exerciseComp activateMode: EditingMode];
                break;
                
            case AbsoluteComparisonMode:
                [exerciseComp activateMode: AbsoluteComparisonMode];
                break;
                
            case RelativeComparisonMode:
                [exerciseComp activateMode: RelativeComparisonMode];
                break;
                
            case TargetsMode:
                [exerciseComp activateMode: TargetsMode];
                
            default:
                break;
        }
        
    }
    
}


@end










































