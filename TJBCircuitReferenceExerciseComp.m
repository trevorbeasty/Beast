//
//  TJBCircuitReferenceExerciseComp.m
//  Beast
//
//  Created by Trevor Beasty on 1/11/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBCircuitReferenceExerciseComp.h"

// core data

#import "CoreDataController.h"

// aesthetics

#import "TJBAestheticsController.h"

// child VC

#import "TJBCircuitReferenceRowComp.h"



@interface TJBCircuitReferenceExerciseComp ()

{
    
    TJBEditingDataType _editingDataType;
    
}

// core

@property (nonatomic, strong) TJBRealizedChain *realizedChain;
@property (strong) TJBRealizedSetGrouping rsg;
@property (nonatomic, strong) NSNumber *exerciseIndex;

// IBOutlets

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectedExerciseButton;
@property (weak, nonatomic) IBOutlet UILabel *horzThinLabel;



@end


#pragma mark - Constants

static CGFloat const topSpacing = 2;
static CGFloat const componentToComponentSpacing = 0;






@implementation TJBCircuitReferenceExerciseComp

#pragma mark - Instantiation

- (instancetype)initWithRealizedChain:(TJBRealizedChain *)realizedChain realizedSetGrouping:(TJBRealizedSetGrouping)rsg editingDataType:(TJBEditingDataType)editingDataType exerciseIndex:(int)exerciseIndex{
    
    self = [super init];
    
    _editingDataType = editingDataType;
    self.realizedChain = realizedChain;
    self.rsg = rsg;
    self.exerciseIndex = [NSNumber numberWithInt: exerciseIndex];
    
    return self;
    
}

#pragma mark - View Life Cycle


- (void)viewDidLoad{
    
    [self configureViewAesthetics];
    
//    [self configureViewDataAndFunctionality];
    
    NSMutableDictionary *constraintMapping = [[NSMutableDictionary alloc] init];
    NSString *horizontalThinLabelName = @"horizontalThinLabel";
    [constraintMapping setObject: self.horzThinLabel
                          forKey: horizontalThinLabelName];
    NSString *topViewName = horizontalThinLabelName;
    
    int limit = _editingDataType == TJBRealizedsetGroupingEditingData ? (int)self.rsg.count : self.realizedChain.chainTemplate.numberOfRounds;
    
    for (int i = 0; i < limit; i++){
        
        TJBCircuitReferenceRowComp *rowComp = [self createAndConfigureRowComponentForRoundIndex: i];
        NSString *dynamicExCompName = [self dynamicRowCompNameForRoundIndex: i];
        
        [constraintMapping setObject: rowComp.view
                              forKey: dynamicExCompName];
        
        [self.view addSubview: rowComp.view];
        
        
        [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: [self horizontalVFLStringForViewName: dynamicExCompName]
                                                                                                            options: 0
                                                                                                 metrics: nil
                                                                                                   views: constraintMapping]];
        
        NSString *vertVFL = [self verticalVFLStringForViewName: dynamicExCompName
                                            currentTopViewName: topViewName];
        
        [self.view addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: vertVFL
                                                                                                 options: 0
                                                                                                 metrics: nil
                                                                                                   views: constraintMapping]];
        
        topViewName = dynamicExCompName;
        
    }
    
//    if (_editingDataType == TJBRealizedsetGroupingEditingData){
//        
//        TJBCircuitReferenceExerciseComp *exComp = [self createAndConfigureExerciseComponentForExerciseIndex: 0];
//        NSString *dynamicExCompName = [self dynamicExCompNameForExerciseIndex: 0];
//        
//        [constraintMapping setObject: exComp.view
//                              forKey: dynamicExCompName];
//        
//        [self.scrollViewContentContainer addSubview: exComp.view];
//        
//        [self.scrollViewContentContainer addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: [self horizontalVFLStringForViewName: dynamicExCompName]
//                                                                                                 options: 0
//                                                                                                 metrics: nil
//                                                                                                   views: constraintMapping]];
//        
//        NSString *vertVFL = [self verticalVFLStringForViewName: dynamicExCompName
//                                            currentTopViewName: nil];
//        
//        [self.scrollViewContentContainer addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: vertVFL
//                                                                                                 options: 0
//                                                                                                 metrics: nil
//                                                                                                   views: constraintMapping]];
//        
//    } else if (_editingDataType == TJBRealizedChainEditingData){
//        
//        for (int i = 0; i < self.realizedChain.chainTemplate.numberOfExercises; i++){
//            
//            
//            TJBCircuitReferenceExerciseComp *exComp = [self createAndConfigureExerciseComponentForExerciseIndex: i];
//            NSString *dynamicExCompName = [self dynamicExCompNameForExerciseIndex: i];
//            
//            [constraintMapping setObject: exComp.view
//                                  forKey: dynamicExCompName];
//            
//            [self.scrollViewContentContainer addSubview: exComp.view];
//            
//            [self.scrollViewContentContainer addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: [self horizontalVFLStringForViewName: dynamicExCompName]
//                                                                                                     options: 0
//                                                                                                     metrics: nil
//                                                                                                       views: constraintMapping]];
//            
//            NSString *vertVFL = [self verticalVFLStringForViewName: dynamicExCompName
//                                                currentTopViewName: topViewName];
//            
//            [self.scrollViewContentContainer addConstraints: [NSLayoutConstraint constraintsWithVisualFormat: vertVFL
//                                                                                                     options: 0
//                                                                                                     metrics: nil
//                                                                                                       views: constraintMapping]];
//            
//            topViewName = dynamicExCompName;
//            
//        }
//        
//    }
    
    // number label text
    
//    self.titleLabel.text = [NSString stringWithFormat: @"%d", [self.exerciseIndex intValue] + 1];
//    
//    NSString *exerciseButton = @"exerciseButton";
//    [self.constraintMapping setObject: self.selectedExerciseButton
//                               forKey: exerciseButton];
//    
//    NSString *horizontalThinLabel = @"horzThin";
//    [self.constraintMapping setObject: self.horzThinLabel
//                               forKey: horizontalThinLabel];
//    
//    NSMutableString *verticalLayoutConstraintsString = [NSMutableString stringWithCapacity: 1000];
//    [verticalLayoutConstraintsString setString: [NSString stringWithFormat: @"V:[%@]-2-", horizontalThinLabel]];
//    
//    for (int i = 0 ; i < self.realizedChain.chainTemplate.numberOfRounds; i ++){
//        
//        // create the child VC's and add their programattic constraints
//        
//        TJBCircuitReferenceRowComp *rowVC = [[TJBCircuitReferenceRowComp alloc] initWithRealizedChain: self.realizedChain
//                                                                                        exerciseIndex: [self.exerciseIndex intValue]
//                                                                                           roundIndex: i];
//        
//        // add the rowVC to the child controllers property
//        
//        [self.childRowCompControllers addObject: rowVC];
//        
//        rowVC.view.translatesAutoresizingMaskIntoConstraints = NO;
//        
//        [self addChildViewController: rowVC];
//        
//        [self.view addSubview: rowVC.view];
//        
//        NSString *dynamicRowName = [NSString stringWithFormat: @"rowComponent%d",
//                                    i];
//        
//        [self.constraintMapping setObject: rowVC.view
//                                   forKey: dynamicRowName];
//        
//        if (i == 0){ // the row components have the same height. I specify that all row components have height equal to the first row component. This is not specified for the first row component
//            
//            self.firstRowKey = dynamicRowName;
//            
//        }
//        
//        // vertical constraints
//        
//        NSString *verticalAppendString;
//        
//        
//        
//        if (i == self.realizedChain.chainTemplate.numberOfRounds - 1)
//        {
//            verticalAppendString = [NSString stringWithFormat: @"[%@(==%@)]-0-|",
//                                    dynamicRowName,
//                                    self.firstRowKey];
//        }
//        else
//        {
//            verticalAppendString = [NSString stringWithFormat: @"[%@(==%@)]-0-",
//                                    dynamicRowName,
//                                    self.firstRowKey];
//        }
//        
//        [verticalLayoutConstraintsString appendString: verticalAppendString];
//        
//        // horizontal constraints
//        
//        NSString *horizontalLayoutConstraintsString = [NSString stringWithFormat: @"H:|-0-[%@]-0-|",
//                                                       dynamicRowName];
//        
//        NSArray *horizontalLayoutConstraints = [NSLayoutConstraint constraintsWithVisualFormat: horizontalLayoutConstraintsString
//                                                                                       options: 0
//                                                                                       metrics: nil
//                                                                                         views: self.constraintMapping];
//        
//        [self.view addConstraints: horizontalLayoutConstraints];
//    }
//    
//    NSArray *verticalLayoutConstraints = [NSLayoutConstraint constraintsWithVisualFormat: verticalLayoutConstraintsString
//                                                                                 options: 0
//                                                                                 metrics: nil
//                                                                                   views: self.constraintMapping];
//    
//    [self.view addConstraints: verticalLayoutConstraints];
//    
//    for (TJBCircuitReferenceRowComp *child in self.childViewControllers)
//    {
//        [child didMoveToParentViewController: self];
//    }
    
}




#pragma mark - View Helper Methods

- (void)configureViewAesthetics{
    
    // meta view
    
    self.view.backgroundColor = [UIColor redColor];
    
    CALayer *viewLayer = self.view.layer;
    viewLayer.masksToBounds = YES;
    viewLayer.cornerRadius = 8.0;
    viewLayer.opacity = 1;

    //  labels

    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.layer.opacity = 1;
    self.titleLabel.font = [UIFont boldSystemFontOfSize: 35];
    
    // selected exercise button
    
    UIButton *button = self.selectedExerciseButton;
    
    button.backgroundColor = [UIColor clearColor];
    [button setTitleColor: [UIColor blackColor]
                 forState: UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize: 15.0];
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = 8.0;
    button.layer.opacity = 1.0;
    
}

- (void)configureViewDataAndFunctionality{
    
    // exercise
    
    [self.selectedExerciseButton setTitle: self.realizedChain.chainTemplate.exercises[[self.exerciseIndex intValue]].name
                                 forState: UIControlStateNormal];
    
    self.selectedExerciseButton.enabled = NO;
    
    // title label
    
    NSString *exerciseNumberText = [NSString stringWithFormat: @"Exercise %d", [self.exerciseIndex intValue] + 1];
    self.titleLabel.text = exerciseNumberText;
    
    // disable button
    
    self.selectedExerciseButton.enabled = NO;
    
}

#pragma mark - Child Exercise Component Controllers

- (TJBCircuitReferenceRowComp *)createAndConfigureRowComponentForRoundIndex:(int)roundIndex{
    
    TJBCircuitReferenceRowComp *vc = [[TJBCircuitReferenceRowComp alloc] initWithRealizedChain: self.realizedChain
                                                                                   realizedSet: self.rsg[roundIndex]
                                                                               editingDataType: _editingDataType
                                                                                 exerciseIndex: [self.exerciseIndex intValue]
                                                                                    roundIndex: roundIndex];
    vc.view.translatesAutoresizingMaskIntoConstraints = NO;
    vc.view.backgroundColor = [UIColor orangeColor];
    
    [self addChildViewController: vc];
    
    [vc didMoveToParentViewController: self];
    
    return vc;
    
}





#pragma mark - Visual Format Language Strings

- (NSString *)dynamicRowCompNameForRoundIndex:(int)roundIndex{
    
    return [NSString stringWithFormat: @"rowComp%d", roundIndex];
    
}

- (NSString *)horizontalVFLStringForViewName:(NSString *)viewName{
    
    return [NSString stringWithFormat: @"|-0-[%@]-0-|", viewName];
    
}

- (NSString *)verticalVFLStringForViewName:(NSString *)viewName currentTopViewName:(NSString *)currentTopViewName{
    
    NSString *vertVFL;
    
    if (!currentTopViewName){
        
        vertVFL = [NSString stringWithFormat: @"V:|-%f-[%@]",
                   topSpacing,
                   viewName];
        
    } else{
        
        vertVFL = [NSString stringWithFormat: @"V:[%@]-%f-[%@(==%@)]",
                   currentTopViewName,
                   componentToComponentSpacing,
                   viewName,
                   currentTopViewName];
        
    }
    
    return vertVFL;
    
}









@end
