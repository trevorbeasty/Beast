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

// core

@property (nonatomic, strong) TJBRealizedChain *realizedChain;
@property (nonatomic, strong) NSNumber *exerciseIndex;
@property (nonatomic, strong) NSMutableArray *childRowCompControllers;

// IBOutlets

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectedExerciseButton;
@property (weak, nonatomic) IBOutlet UILabel *horzThinLabel;

// for programmatic auto layout constraints

@property (nonatomic, strong) NSMutableDictionary *constraintMapping;
@property (strong) NSString *firstRowKey; // used to specify that all row comps have height equal to the first row comp


@end

@implementation TJBCircuitReferenceExerciseComp

- (instancetype)initWithRealizedChain:(TJBRealizedChain *)realizedChain realizedSetGrouping:(TJBRealizedSetGrouping)rsg editingDataType:(TJBEditingDataType)editingDataType exerciseIndex:(int)exerciseIndex{
    
    self = [super init];
    
    self.realizedChain = realizedChain;
    self.exerciseIndex = [NSNumber numberWithInt: exerciseIndex];
    
    // prep
    
    self.childRowCompControllers = [[NSMutableArray alloc] init];
    
    return self;
    
}

#pragma mark - View Life Cycle

- (void)configureViewAesthetics{
    
    // meta view
    
    self.view.backgroundColor = [UIColor clearColor];
    
    CALayer *viewLayer = self.view.layer;
    viewLayer.masksToBounds = YES;
    viewLayer.cornerRadius = 8.0;
    viewLayer.opacity = 1;

    
    //  labels
    
    NSArray *labels = @[self.titleLabel];
    
    for (UILabel *label in labels){
        
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor blackColor];
        label.layer.opacity = 1;
        label.font = [UIFont boldSystemFontOfSize: 35];
        
    }
    
    // selected exercise button
    
    UIButton *button = self.selectedExerciseButton;
    
    button.backgroundColor = [UIColor clearColor];
    [button setTitleColor: [UIColor blackColor]
                 forState: UIControlStateNormal];
    button.titleLabel.font = [UIFont boldSystemFontOfSize: 15.0];
    button.layer.masksToBounds = YES;
    button.layer.cornerRadius = 8.0;
    
    // selected exercise button layer
    
    CALayer *layer = button.layer;
    layer.masksToBounds = YES;
    layer.cornerRadius = 8;
    layer.opacity = 1.0;
    
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


- (void)viewDidLoad{
    
    [self configureViewAesthetics];
    
    [self configureViewDataAndFunctionality];
    
    //// major functionality includeing row child VC's and layout constraints
    
    self.constraintMapping = [[NSMutableDictionary alloc] init];
    
    // number label text
    
    self.titleLabel.text = [NSString stringWithFormat: @"%d", [self.exerciseIndex intValue] + 1];
    
    NSString *exerciseButton = @"exerciseButton";
    [self.constraintMapping setObject: self.selectedExerciseButton
                               forKey: exerciseButton];
    
    NSString *horizontalThinLabel = @"horzThin";
    [self.constraintMapping setObject: self.horzThinLabel
                               forKey: horizontalThinLabel];
    
    NSMutableString *verticalLayoutConstraintsString = [NSMutableString stringWithCapacity: 1000];
    [verticalLayoutConstraintsString setString: [NSString stringWithFormat: @"V:[%@]-2-", horizontalThinLabel]];
    
    for (int i = 0 ; i < self.realizedChain.chainTemplate.numberOfRounds; i ++){
        
        // create the child VC's and add their programattic constraints
        
        TJBCircuitReferenceRowComp *rowVC = [[TJBCircuitReferenceRowComp alloc] initWithRealizedChain: self.realizedChain
                                                                                        exerciseIndex: [self.exerciseIndex intValue]
                                                                                           roundIndex: i];
        
        // add the rowVC to the child controllers property
        
        [self.childRowCompControllers addObject: rowVC];
        
        rowVC.view.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addChildViewController: rowVC];
        
        [self.view addSubview: rowVC.view];
        
        NSString *dynamicRowName = [NSString stringWithFormat: @"rowComponent%d",
                                    i];
        
        [self.constraintMapping setObject: rowVC.view
                                   forKey: dynamicRowName];
        
        if (i == 0){ // the row components have the same height. I specify that all row components have height equal to the first row component. This is not specified for the first row component
            
            self.firstRowKey = dynamicRowName;
            
        }
        
        // vertical constraints
        
        NSString *verticalAppendString;
        
        
        
        if (i == self.realizedChain.chainTemplate.numberOfRounds - 1)
        {
            verticalAppendString = [NSString stringWithFormat: @"[%@(==%@)]-0-|",
                                    dynamicRowName,
                                    self.firstRowKey];
        }
        else
        {
            verticalAppendString = [NSString stringWithFormat: @"[%@(==%@)]-0-",
                                    dynamicRowName,
                                    self.firstRowKey];
        }
        
        [verticalLayoutConstraintsString appendString: verticalAppendString];
        
        // horizontal constraints
        
        NSString *horizontalLayoutConstraintsString = [NSString stringWithFormat: @"H:|-0-[%@]-0-|",
                                                       dynamicRowName];
        
        NSArray *horizontalLayoutConstraints = [NSLayoutConstraint constraintsWithVisualFormat: horizontalLayoutConstraintsString
                                                                                       options: 0
                                                                                       metrics: nil
                                                                                         views: self.constraintMapping];
        
        [self.view addConstraints: horizontalLayoutConstraints];
    }
    
    NSArray *verticalLayoutConstraints = [NSLayoutConstraint constraintsWithVisualFormat: verticalLayoutConstraintsString
                                                                                 options: 0
                                                                                 metrics: nil
                                                                                   views: self.constraintMapping];
    
    [self.view addConstraints: verticalLayoutConstraints];
    
    for (TJBCircuitReferenceRowComp *child in self.childViewControllers)
    {
        [child didMoveToParentViewController: self];
    }
    
}

#pragma mark - Class API
//
//- (void)activateMode:(TJBRoutineReferenceMode)mode{
//    
//    for (TJBCircuitReferenceRowComp *rowComp in self.childRowCompControllers){
//        
//        switch (mode) {
//            case EditingMode:
//                [rowComp activateMode: EditingMode];
//                break;
//                
//            case ProgressMode:
//                [rowComp activateMode: ProgressMode];
//                break;
//                
//            case TargetsMode:
//                [rowComp activateMode: TargetsMode];
//                break;
//                
//            default:
//                break;
//        }
//        
//    }
//    
//}






@end
