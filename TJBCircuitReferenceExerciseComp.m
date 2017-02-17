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

// IBOutlets

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *roundColumnLabel;
@property (weak, nonatomic) IBOutlet UILabel *weightColumnLabel;
@property (weak, nonatomic) IBOutlet UILabel *repsColumnLabel;
@property (weak, nonatomic) IBOutlet UILabel *restColumnLabel;
@property (weak, nonatomic) IBOutlet UILabel *thinLineLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectedExerciseButton;

// for programmatic auto layout constraints

@property (nonatomic, strong) NSMutableDictionary *constraintMapping;


@end

@implementation TJBCircuitReferenceExerciseComp

- (instancetype)initWithRealizedChain:(TJBRealizedChain *)realizedChain exerciseIndex:(int)exerciseIndex{
    
    self = [super init];
    
    self.realizedChain = realizedChain;
    self.exerciseIndex = [NSNumber numberWithInt: exerciseIndex];
    
    return self;
    
}



#pragma mark - View Life Cycle

- (void)configureViewAesthetics{
    
    // meta view
    
    self.view.backgroundColor = [[TJBAestheticsController singleton] yellowNotebookColor];
    
    CALayer *viewLayer = self.view.layer;
    viewLayer.masksToBounds = YES;
    viewLayer.cornerRadius = 8.0;
    viewLayer.opacity = 1;

    
    //  labels
    
    NSArray *labels = @[self.roundColumnLabel,
                        self.weightColumnLabel,
                        self.repsColumnLabel,
                        self.restColumnLabel,
                        self.titleLabel];
    
    for (UILabel *label in labels){
        
        label.backgroundColor = [UIColor lightGrayColor];
        label.textColor = [UIColor whiteColor];
        label.layer.opacity = 1;
        label.font = [UIFont boldSystemFontOfSize: 20.0];
        
    }
    
    // selected exercise button
    
    UIButton *button = self.selectedExerciseButton;
    
    button.backgroundColor = [[TJBAestheticsController singleton] blueButtonColor];
    [button setTitleColor: [UIColor whiteColor]
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
    
    [self.selectedExerciseButton setTitle: self.realizedChain.exercises[[self.exerciseIndex intValue]].name
                                 forState: UIControlStateNormal];
    
    self.selectedExerciseButton.enabled = NO;
    
    // title label
    
    NSString *exerciseNumberText = [NSString stringWithFormat: @"Exercise %d", [self.exerciseIndex intValue] + 1];
    self.titleLabel.text = exerciseNumberText;
    
}


- (void)viewDidLoad{
    
    [self configureViewAesthetics];
    
    [self configureViewDataAndFunctionality];
    
    //// major functionality includeing row child VC's and layout constraints
    
    self.constraintMapping = [[NSMutableDictionary alloc] init];
    
    // row components
    
    NSString *weightColumnLabel = @"weightColumnLabel";
    [self.constraintMapping setObject: self.weightColumnLabel
                               forKey: weightColumnLabel];
    
    NSString *roundColumnLabel = @"roundColumnLabel";
    [self.constraintMapping setObject:self.roundColumnLabel
                               forKey: roundColumnLabel];
    
    
    
    NSMutableString *verticalLayoutConstraintsString = [NSMutableString stringWithCapacity: 1000];
    [verticalLayoutConstraintsString setString: [NSString stringWithFormat: @"V:[%@]-0-", weightColumnLabel]];
    
    for (int i = 0 ; i < self.realizedChain.numberOfRounds; i ++){
        
        // create the child VC's and add their programattic constraints
        
        TJBCircuitReferenceRowComp *rowVC = [[TJBCircuitReferenceRowComp alloc] initWithRealizedChain: self.realizedChain
                                                                                        exerciseIndex: [self.exerciseIndex intValue]
                                                                                           roundIndex: i];
        
        rowVC.view.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addChildViewController: rowVC];
        
        [self.view addSubview: rowVC.view];
        
        NSString *dynamicRowName = [NSString stringWithFormat: @"rowComponent%d",
                                    i];
        
        [self.constraintMapping setObject: rowVC.view
                                   forKey: dynamicRowName];
        
        // vertical constraints
        
        NSString *verticalAppendString;
        
        if (i == self.realizedChain.numberOfRounds - 1)
        {
            verticalAppendString = [NSString stringWithFormat: @"[%@(==%@)]-0-|",
                                    dynamicRowName,
                                    roundColumnLabel];
        }
        else
        {
            verticalAppendString = [NSString stringWithFormat: @"[%@(==%@)]-0-",
                                    dynamicRowName,
                                    roundColumnLabel];
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








@end
