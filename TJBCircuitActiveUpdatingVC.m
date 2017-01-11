//
//  TJBCircuitActiveUpdatingVC.m
//  Beast
//
//  Created by Trevor Beasty on 1/11/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBCircuitActiveUpdatingVC.h"

// child VC

#import "TJBCircuitActiveUpdatingExerciseComp.h"

// core data

#import "CoreDataController.h"

#import "TJBRealizedChain+CoreDataProperties.h"
#import "TJBChainTemplate+CoreDataProperties.h"
#import "TJBWeightArray+CoreDataProperties.h"
#import "TJBRepsArray+CoreDataProperties.h"
#import "TJBTargetRestTimeArray+CoreDataProperties.h"
#import "SetBeginDateArray+CoreDataProperties.h"
#import "SetEndDateArray+CoreDataProperties.h"

@interface TJBCircuitActiveUpdatingVC ()

// core

@property (nonatomic, strong) TJBRealizedChain *realizedChain;
@property (nonatomic, strong) NSNumber *viewHeight;
@property (nonatomic, strong) NSNumber *viewWidth;

// IV's derived from realizedChain

@property (nonatomic, strong) NSNumber *numberOfExercises;
@property (nonatomic, strong) NSNumber *numberOfRounds;
@property (nonatomic, strong) NSNumber *targetsVaryByRound;
@property (nonatomic, strong) NSString *realizedChainUniqueID;

// for programmatic layout constraints

@property (nonatomic, strong) NSMutableDictionary *constraintMapping;

@end

@implementation TJBCircuitActiveUpdatingVC

#pragma mark - Instantiation

- (instancetype)initWithRealizedChain:(TJBRealizedChain *)realizedChain viewHeight:(NSNumber *)viewHeight viewWidth:(NSNumber *)viewWidth{
    
    self = [super init];
    
    // core
    
    self.realizedChain = realizedChain;
    self.viewHeight = viewHeight;
    self.viewWidth = viewWidth;
    
    // set derived instance variables
    
    [self setDerivedInstanceVariables];
    
    // for notifications
    
    [self registerForRelevantNotifications];
    
    return self;
}

- (void)setDerivedInstanceVariables{
    
    // set IV's derived from chain template
    
    TJBChainTemplate *chainTemplate = self.realizedChain.chainTemplate;
    
    self.numberOfRounds = [NSNumber numberWithInt: chainTemplate.numberOfRounds];
    self.numberOfExercises = [NSNumber numberWithInt: chainTemplate.numberOfExercises];
    self.targetsVaryByRound = [NSNumber numberWithBool: chainTemplate.targetsVaryByRound];
    
    self.realizedChainUniqueID = self.realizedChain.uniqueID;
    
}

- (void)registerForRelevantNotifications{
    
    // this notification relies on the TJBActiveCircuitGuidance using the same TJBRealizedChain as is stored in this VC
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(realizedChainDidChange)
                                                 name: NSManagedObjectContextDidSaveNotification
                                               object: self.realizedChain];
    
}

#pragma mark - Notification Actions

- (void)realizedChainDidChange{
    
    // must re-fetch the realized chain and reload the view in response
    
    [[[CoreDataController singleton] moc] refreshObject: self.realizedChain
                                           mergeChanges: YES];
    
    [self setDerivedInstanceVariables];
    
    [self.view setNeedsDisplay];
    
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
    
    BOOL targetsVaryByRound = [self.targetsVaryByRound boolValue] == YES;
    
    if (targetsVaryByRound){
        
        componentHeight = rowHeight * ([self.numberOfRounds intValue] + 2) + componentStyleSpacing;
        
    } else{
        
        componentHeight = rowHeight * 3 + componentStyleSpacing;
    }
    
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
    
        
        TJBCircuitActiveUpdatingExerciseComp *vc = [[TJBCircuitActiveUpdatingExerciseComp alloc] initWithNumberOfRounds: self.numberOfRounds
                                                                                                     targetsVaryByRound: self.targetsVaryByRound
                                                                                                            chainNumber: [NSNumber numberWithInt: i + 1]
                                                                                                               exercise: self.realizedChain.chainTemplate.exercises[i]
                                                                                                             weightData: self.realizedChain.weightArrays[i].numbers
                                                                                                               repsData: self.realizedChain.repsArrays[i].numbers
                                                                                                          setBeginDates: self.realizedChain.setBegindateArrays[i].dates
                                                                                                            setEndDates: self.realizedChain.setEndDateArrays[i].dates
                                                                                                 maxExerciseIndexToFill: [NSNumber numberWithInt: self.realizedChain.firstIncompleteExerciseIndex - 1]
                                                                                                    maxRoundIndexToFill: [NSNumber numberWithInt: self.realizedChain.firstIncompleteRoundIndex - 1]
                                                                                                      numberOfExercises: self.numberOfExercises];
        
        
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
    
    for (TJBCircuitActiveUpdatingExerciseComp *child in self.childViewControllers){
        
        [child didMoveToParentViewController: self];
    }
}

@end





























