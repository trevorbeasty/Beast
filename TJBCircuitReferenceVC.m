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

#import "TJBCircuitReferenceContainerVC.h" // master controller

// aesthetics

#import "TJBAestheticsController.h"

@interface TJBCircuitReferenceVC ()

{

    TJBEditingDataType _editingDataType;
    
}

// core

@property (nonatomic, strong) TJBRealizedChain *realizedChain;
@property (strong) TJBRealizedSetGrouping rsg;
@property (weak) TJBCircuitReferenceContainerVC *masterController;

// content

@property (strong) UIView *scrollViewContentContainer;

@end



#pragma mark - Constants

static CGFloat const titleBarHeight = 50;
static CGFloat const contentRowHeight = 44;
static CGFloat const componentToComponentSpacing = 24;
static CGFloat const componentStyleSpacing = 9;
static CGFloat const topSpacing;

static CGFloat const breatherRoom = 40;





@implementation TJBCircuitReferenceVC

#pragma mark - Instantiation

- (instancetype)initWithRealizedChain:(TJBRealizedChain *)rc realizedSetGrouping:(TJBRealizedSetGrouping)rsg editingDataType:(TJBEditingDataType)editingDataType masterController:(TJBCircuitReferenceContainerVC *)masterController{
    
    self = [super init];
    
    self.realizedChain = rc;
    self.rsg = rsg;
    _editingDataType = editingDataType;
    self.masterController = masterController;
    
    return self;
    
}

#pragma mark - Init Helper Methods



#pragma mark - View Life Cycle

- (void)loadView{
    
    UIView *view = [[UIView alloc] init];
    self.view = view;
    
    CGFloat contentWidth = [self contentWidth];
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
    
    [self configureViewAesthetics];
    
    [self createChildViewControllersAndLayoutViews];
    
}


#pragma mark - View Helper Methods

- (void)configureViewAesthetics{
    
    self.view.backgroundColor = [[TJBAestheticsController singleton] yellowNotebookColor];
    
}

- (void)createChildViewControllersAndLayoutViews{
    
    // the extra height allows the user to drag the bottom-most exercise further up on the screen
    
//    CGFloat extraHeight = [UIScreen mainScreen].bounds.size.height / 4.0;
//    CGFloat metaViewWidth = self.view.frame.size.width;
//    CGFloat totalContentHeight = [self totalContentHeight];
    
//    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame: self.view.bounds];
//    scrollView.contentSize = CGSizeMake(metaViewWidth, totalContentHeight + extraHeight);
//    [self.view addSubview: scrollView];
//    
//    CGRect scrollViewSubviewFrame = CGRectMake(0, 0, metaViewWidth, totalContentHeight);
//    UIView *scrollViewSubview = [[UIView alloc] initWithFrame: scrollViewSubviewFrame];
//    [scrollView addSubview: scrollViewSubview];
    
    // child views
    
    NSMutableDictionary *constraintMapping = [[NSMutableDictionary alloc] init];
    NSString *topViewName;
    
    if (_editingDataType == TJBRealizedsetGroupingEditingData){
        
        TJBCircuitReferenceExerciseComp *exComp = [self createAndConfigureExerciseComponentForExerciseIndex: 0];
        NSString *dynamicExCompName = [self dynamicExCompNameForExerciseIndex: 0];
        
        [constraintMapping setObject: exComp.view
                              forKey: dynamicExCompName];
        
        [self.scrollViewContentContainer addSubview: exComp.view];
        
        [self.scrollViewContentContainer addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: [self horizontalVFLStringForViewName: dynamicExCompName]
                                                                                   options: 0
                                                                                   metrics: nil
                                                                                     views: constraintMapping]];
        
        NSString *vertVFL = [self verticalVFLStringForViewName: dynamicExCompName
                                            currentTopViewName: nil];
        
        [self.scrollViewContentContainer addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: vertVFL
                                                                                   options: 0
                                                                                   metrics: nil
                                                                                     views: constraintMapping]];
        
    } else if (_editingDataType == TJBRealizedChainEditingData){
        
        for (int i = 0; i < self.realizedChain.chainTemplate.numberOfExercises; i++){
            
            
            TJBCircuitReferenceExerciseComp *exComp = [self createAndConfigureExerciseComponentForExerciseIndex: i];
            NSString *dynamicExCompName = [self dynamicExCompNameForExerciseIndex: i];
            
            [constraintMapping setObject: exComp.view
                                  forKey: dynamicExCompName];
            
            [self.scrollViewContentContainer addSubview: exComp.view];
            
            [self.scrollViewContentContainer addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: [self horizontalVFLStringForViewName: dynamicExCompName]
                                                                                       options: 0
                                                                                       metrics: nil
                                                                                         views: constraintMapping]];
            
            NSString *vertVFL = [self verticalVFLStringForViewName: dynamicExCompName
                                                currentTopViewName: topViewName];
            
            [self.scrollViewContentContainer addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: vertVFL
                                                                                       options: 0
                                                                                       metrics: nil
                                                                                         views: constraintMapping]];
            
            topViewName = dynamicExCompName;

        }
        
    }
    

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
        
        float numberOfExercises = (float)self.realizedChain.chainTemplate.numberOfExercises;
        
        return  [self componentHeight] * numberOfExercises + componentToComponentSpacing * (numberOfExercises - 1.0);
        
    } else{
        
        return 0;
        
    }
    
}

- (CGFloat)scrollViewContentHeight{
    
    CGFloat exactContentHeight = [self totalContentHeight];
    
    return exactContentHeight + breatherRoom + [self.masterController returnButtonBufferHeight];
    
}


- (CGFloat)contentWidth{
    
    return [UIScreen mainScreen].bounds.size.width;
    
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
    
    return [NSString stringWithFormat: @"H:|-0-[%@]-0-|", viewName];
    
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










































