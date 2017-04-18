//
//  TJBCircuitReferenceVC.m
//  Beast
//
//  Created by Trevor Beasty on 1/11/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBCircuitReferenceVC.h"



// child VC's

#import "TJBCircuitReferenceExerciseComp.h"
#import "TJBCircuitReferenceRowComp.h"

// aesthetics

#import "TJBAestheticsController.h"

@interface TJBCircuitReferenceVC ()

{

    TJBEditingDataType _editingDataType;
    
}

// core

@property (nonatomic, strong) TJBRealizedChain *realizedChain;
@property (strong) TJBRealizedSetGrouping rsg;
//@property (nonatomic, strong) NSMutableArray *childExerciseCompControllers;

// for programmatic layout constraints

//@property (nonatomic, strong) NSMutableDictionary *constraintMapping;



@end



#pragma mark - Constants

static CGFloat const titleBarHeight = 50;
static CGFloat const contentRowHeight = 44;
static CGFloat const componentToComponentSpacing = 24;
static CGFloat const componentStyleSpacing = 9;
static CGFloat const topSpacing;





@implementation TJBCircuitReferenceVC

#pragma mark - Instantiation

- (instancetype)initWithRealizedChain:(TJBRealizedChain *)rc realizedSetGrouping:(TJBRealizedSetGrouping)rsg editingDataType:(TJBEditingDataType)editingDataType{
    
    self = [super init];
    
    self.realizedChain = rc;
    self.rsg = rsg;
    _editingDataType = editingDataType;
    
    return self;
    
}

#pragma mark - Init Helper Methods



#pragma mark - View Life Cycle

- (void)loadView{
    
    UIView *view = [[UIView alloc] init];
    self.view = view;
    
}


- (void)viewDidLoad{
    
    [self configureViewAesthetics];
    
    [self createChildViewControllersAndLayoutViews];
    
}


#pragma mark - View Helper Methods

- (void)configureViewAesthetics{
    
    self.view.backgroundColor = [[TJBAestheticsController singleton] yellowNotebookColor];
    
}

- (void)createChildViewControllersAndLayoutViews{
    
    // the extra height allows the user to drag the bottom-most exercise further up on the screen
    
    CGFloat extraHeight = [UIScreen mainScreen].bounds.size.height / 4.0;
    CGFloat metaViewWidth = self.view.frame.size.width;
    CGFloat totalContentHeight = [self totalContentHeight];
    
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame: self.view.bounds];
    scrollView.contentSize = CGSizeMake(metaViewWidth, totalContentHeight + extraHeight);
    [self.view addSubview: scrollView];
    
    CGRect scrollViewSubviewFrame = CGRectMake(0, 0, metaViewWidth, totalContentHeight);
    UIView *scrollViewSubview = [[UIView alloc] initWithFrame: scrollViewSubviewFrame];
    [scrollView addSubview: scrollViewSubview];
    
    // child views
    
    NSMutableDictionary *constraintMapping = [[NSMutableDictionary alloc] init];
    NSString *topViewName;
    
    if (_editingDataType == TJBRealizedsetGroupingEditingData){
        
        TJBCircuitReferenceExerciseComp *exComp = [self createAndConfigureExerciseComponentForExerciseIndex: 0];
        NSString *dynamicExCompName = [self dynamicExCompNameForExerciseIndex: 0];
        
        [constraintMapping setObject: exComp.view
                              forKey: dynamicExCompName];
        
        [scrollViewSubview addSubview: exComp.view];
        
        [scrollViewSubview addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: [self horizontalVFLStringForViewName: dynamicExCompName]
                                                                                   options: 0
                                                                                   metrics: nil
                                                                                     views: constraintMapping]];
        
        NSString *vertVFL = [self verticalVFLStringForViewName: dynamicExCompName
                                            currentTopViewName: nil];
        
        [scrollViewSubview addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: vertVFL
                                                                                   options: 0
                                                                                   metrics: nil
                                                                                     views: constraintMapping]];
        
    } else if (_editingDataType == TJBRealizedChainEditingData){
        
        for (int i = 0; i < self.realizedChain.chainTemplate.numberOfExercises; i++){
            
            
            TJBCircuitReferenceExerciseComp *exComp = [self createAndConfigureExerciseComponentForExerciseIndex: i];
            NSString *dynamicExCompName = [self dynamicExCompNameForExerciseIndex: i];
            
            [constraintMapping setObject: exComp.view
                                  forKey: dynamicExCompName];
            
            [scrollViewSubview addSubview: exComp.view];
            
            [scrollViewSubview addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: [self horizontalVFLStringForViewName: dynamicExCompName]
                                                                                       options: 0
                                                                                       metrics: nil
                                                                                         views: constraintMapping]];
            
            NSString *vertVFL = [self verticalVFLStringForViewName: dynamicExCompName
                                                currentTopViewName: topViewName];
            
            [scrollViewSubview addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: vertVFL
                                                                                       options: 0
                                                                                       metrics: nil
                                                                                         views: constraintMapping]];
            
            topViewName = dynamicExCompName;

        }
        
    }
    
    
//    
//    // exercise components
//    
//    NSMutableString *verticalLayoutConstraintsString = [NSMutableString stringWithCapacity: 1000];
//    [verticalLayoutConstraintsString setString: @"V:|-2-"];
//    
//    for (int i = 0 ; i < self.realizedChain.chainTemplate.numberOfExercises ; i ++){
//        
//        TJBCircuitReferenceExerciseComp *vc = [[TJBCircuitReferenceExerciseComp alloc] initWithRealizedChain: self.realizedChain
//                                                                                               exerciseIndex: i];
//        
//        // add the vc to the child controllers array
//        
//        [self.childExerciseCompControllers addObject: vc];
//        
//        vc.view.translatesAutoresizingMaskIntoConstraints = NO;
//        
//        [self addChildViewController: vc];
//        
//        [scrollViewSubview addSubview: vc.view];
//        
//        NSString *dynamicComponentName = [NSString stringWithFormat: @"exerciseComponent%d",
//                                          i];
//        
//        [self.constraintMapping setObject: vc.view
//                                   forKey: dynamicComponentName];
//        
//        // vertical constraints
//        
//        NSString *verticalAppendString;
//        
//        if (i == self.realizedChain.chainTemplate.numberOfExercises - 1){
//            
//            verticalAppendString = [NSString stringWithFormat: @"[%@(==%f)]",
//                                    dynamicComponentName,
//                                    componentHeight];
//        } else{
//            
//            verticalAppendString = [NSString stringWithFormat: @"[%@(==%f)]-%d-",
//                                    dynamicComponentName,
//                                    componentHeight,
//                                    (int)componentToComponentSpacing];
//        }
//        
//        [verticalLayoutConstraintsString appendString: verticalAppendString];
//        
//        // horizontal constraints
//        
//        NSString *horizontalLayoutConstraintsString = [NSString stringWithFormat: @"H:|-0-[%@]-0-|",
//                                                       dynamicComponentName];
//        
//        NSArray *horizontalLayoutConstraints = [NSLayoutConstraint constraintsWithVisualFormat: horizontalLayoutConstraintsString
//                                                                                       options: 0
//                                                                                       metrics: nil
//                                                                                         views: self.constraintMapping];
//        
//        [scrollViewSubview addConstraints: horizontalLayoutConstraints];
//    }
//    
//    NSArray *verticalLayoutConstraints = [NSLayoutConstraint constraintsWithVisualFormat: verticalLayoutConstraintsString
//                                                                                 options: 0
//                                                                                 metrics: nil
//                                                                                   views: self.constraintMapping];
//    
//    [scrollViewSubview addConstraints: verticalLayoutConstraints];
//    
//    for (TJBCircuitReferenceExerciseComp *child in self.childViewControllers){
//        
//        [child didMoveToParentViewController: self];
//    }
}



#pragma mark - View Math

- (float)numberOfRounds{
    
    return _editingDataType == TJBRealizedsetGroupingEditingData ? self.rsg.count : self.realizedChain.chainTemplate.numberOfRounds;
    
}


- (CGFloat)componentHeight{
    
    return titleBarHeight + contentRowHeight * [self numberOfRounds] + componentStyleSpacing;
    
}

- (CGFloat)totalContentHeight{
    
    if (_editingDataType == TJBRealizedsetGroupingEditingData){
        
        return [self componentHeight];
        
    } else if (_editingDataType == TJBRealizedChainEditingData){
        
        float numberOfRounds = [self numberOfRounds];
        
        return  [self componentHeight] * numberOfRounds + componentToComponentSpacing * (numberOfRounds - 1.0);
        
    } else{
        
        return 0;
        
    }
    
}

#pragma mark - Child Exercise Component Controllers

- (TJBCircuitReferenceExerciseComp *)createAndConfigureExerciseComponentForExerciseIndex:(int)exerciseIndex{
    
    TJBCircuitReferenceExerciseComp *vc = [[TJBCircuitReferenceExerciseComp alloc] initWithRealizedChain: self.realizedChain
                                                                                     realizedSetGrouping: self.rsg
                                                                                         editingDataType: _editingDataType
                                                                                           exerciseIndex: exerciseIndex];
    vc.view.translatesAutoresizingMaskIntoConstraints = NO;

    [self addChildViewController: vc];
    
    [vc didMoveToParentViewController: self];
    
    return vc;
    
}




#pragma mark - Visual Format Language Strings

- (NSString *)dynamicExCompNameForExerciseIndex:(int)exerciseIndex{
    
    return [NSString stringWithFormat: @"exComp%d", exerciseIndex];
    
}

- (NSString *)horizontalVFLStringForViewName:(NSString *)viewName{
    
    return [NSString stringWithFormat: @"|-0-[%@]-0-|", viewName];
    
}

- (NSString *)verticalVFLStringForViewName:(NSString *)viewName currentTopViewName:(NSString *)currentTopViewName{
    
    NSString *vertVFL;
    
    if (!currentTopViewName){
        
        vertVFL = [NSString stringWithFormat: @"V:|-%f-[%@(==%f)]",
                   topSpacing,
                   viewName,
                   [self componentHeight]];
        
    } else{
        
        vertVFL = [NSString stringWithFormat: @"V:[%@]-%f-[%@(==%f)]",
                   currentTopViewName,
                   componentToComponentSpacing,
                   viewName,
                   [self componentHeight]];
        
    }
    
    return vertVFL;
    
}




@end










































