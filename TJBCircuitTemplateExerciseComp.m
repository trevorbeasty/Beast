//
//  TJBCircuitTemplateExerciseComp.m
//  Beast
//
//  Created by Trevor Beasty on 1/10/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBCircuitTemplateExerciseComp.h"

// child and parent VC's

#import "TJBCircuitTemplateVC.h"
#import "TJBCircuitTemplateRowComponent.h"

// core data

#import "CoreDataController.h"

// aesthetics

#import "TJBAestheticsController.h"

// exercise selection

#import "TJBExerciseSelectionScene.h"

@interface TJBCircuitTemplateExerciseComp ()

// core
@property (nonatomic, strong) NSNumber *exerciseIndex;
@property (nonatomic, weak) TJBCircuitTemplateVC <TJBCircuitTemplateVCProtocol> *masterController;
@property (nonatomic, strong) TJBChainTemplate *chainTemplate;

// IBOutlets

//@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
//@property (weak, nonatomic) IBOutlet UILabel *roundColumnLabel;
//@property (weak, nonatomic) IBOutlet UILabel *weightColumnLabel;
//@property (weak, nonatomic) IBOutlet UILabel *repsColumnLabel;
//@property (weak, nonatomic) IBOutlet UILabel *restColumnLabel;
//@property (weak, nonatomic) IBOutlet UILabel *thinLineLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectedExerciseButton;
@property (weak, nonatomic) IBOutlet UILabel *horizontalThinLabel;
@property (weak, nonatomic) IBOutlet UILabel *exerciseNumberLabel;

// auto layout

@property (nonatomic, strong) NSMutableDictionary *constraintMapping;
@property (strong) NSString *firstRowKey; // used to specify that all row comps have height equal to the first row comp

@end

@implementation TJBCircuitTemplateExerciseComp

#pragma mark - Instantiation

- (instancetype)initWithChainTemplate:(TJBChainTemplate *)chainTemplate exerciseIndex:(int)exerciseIndex masterController:(TJBCircuitTemplateVC<TJBCircuitTemplateVCProtocol> *)masterController{
    
    self = [super init];
    
    self.chainTemplate = chainTemplate;
    self.masterController = masterController;
    self.exerciseIndex = [NSNumber numberWithInt: exerciseIndex];
    
    return self;
    
}

#pragma mark - View Life Cycle

- (void)viewAesthetics{
    
    self.view.backgroundColor = [UIColor clearColor];
    
    // column label views
    
//    NSArray *labels = @[self.roundColumnLabel,
//                            self.weightColumnLabel,
//                            self.repsColumnLabel,
//                            self.restColumnLabel];
//    
//    for (UILabel *l in labels){
//        
//        l.backgroundColor = [UIColor lightGrayColor];
//        l.textColor = [UIColor whiteColor];
//        l.font = [UIFont boldSystemFontOfSize: 20.0];
//        
//    }
    
    // title label view
    
//    self.titleLabel.backgroundColor = [UIColor clearColor];
//    [self.titleLabel setTextColor: [UIColor whiteColor]];
//    self.titleLabel.font = [UIFont boldSystemFontOfSize: 15];
    
    // selected exercise button
    
    UIButton *button = self.selectedExerciseButton;
        
    button.backgroundColor = [[TJBAestheticsController singleton] blueButtonColor];
    UIColor *color = [[TJBAestheticsController singleton] buttonTextColor];
    [button setTitleColor: color
                 forState: UIControlStateNormal];
    
    button.titleLabel.numberOfLines = 0;
    button.titleLabel.font = [UIFont boldSystemFontOfSize: 20];
    
    // number label
    
    self.exerciseNumberLabel.font = [UIFont boldSystemFontOfSize: 30];
    self.exerciseNumberLabel.textColor = [[TJBAestheticsController singleton] yellowNotebookColor];
    self.exerciseNumberLabel.backgroundColor = [UIColor clearColor];
    
    
    // selected exercise button layer
    
    CALayer *layer = button.layer;
    layer.masksToBounds = YES;
    layer.cornerRadius = 8;
}

- (void)viewDidLoad
{
    [self viewAesthetics];
    
    //// major functionality includeing row child VC's and layout constraints
    
    self.constraintMapping = [[NSMutableDictionary alloc] init];
    
    // labels
    
//    self.titleLabel.text = [NSString stringWithFormat: @"Exercise %d",
//                            [self.exerciseIndex intValue] + 1];
    
    // row components
    
//    NSString *thinLineLabel = @"thinLineLabel";
//    [self.constraintMapping setObject: self.thinLineLabel
//                               forKey: thinLineLabel];
    
    // number label text
    
    self.exerciseNumberLabel.text = [NSString stringWithFormat: @"%d", [self.exerciseIndex intValue] + 1];
    
    NSString *exerciseButton = @"exerciseButton";
    [self.constraintMapping setObject: self.selectedExerciseButton
                               forKey: exerciseButton];
    
    NSString *horizontalThinLabel = @"horzThin";
    [self.constraintMapping setObject: self.horizontalThinLabel
                               forKey: horizontalThinLabel];
    
    NSMutableString *verticalLayoutConstraintsString = [NSMutableString stringWithCapacity: 1000];
    [verticalLayoutConstraintsString setString: [NSString stringWithFormat: @"V:[%@]-2-", horizontalThinLabel]];
    
    NSInteger iterationLimit; // establish the iteration limit. It is equal to the number of rounds unless targets do not vary by round, in which case it is 1
    
    if (self.chainTemplate.targetsVaryByRound == NO){
        iterationLimit = 1;
    } else{
        iterationLimit = self.chainTemplate.numberOfRounds;
    }
    
    for (int i = 0 ; i < iterationLimit ; i ++){
        
        TJBCircuitTemplateRowComponent *rowVC = [[TJBCircuitTemplateRowComponent alloc] initWithChainTemplate: self.chainTemplate
                                                                                             masterController: self.masterController
                                                                                                exerciseIndex: [self.exerciseIndex intValue]
                                                                                                   roundIndex: i];
        
        // add the newly created row component to the master controller's child collection
        
        [self.masterController addChildRowController: rowVC];
        
        rowVC.view.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addChildViewController: rowVC];
        
        [self.view addSubview: rowVC.view];
        
        NSString *dynamicRowName = [NSString stringWithFormat: @"rowComponent%d",
                                    i];
        
        [self.constraintMapping setObject: rowVC.view
                                   forKey: dynamicRowName];
        
        // vertical constraints
        
        NSString *verticalAppendString;
        
        if (i == 0){ // the row components have the same height. I specify that all row components have height equal to the first row component. This is not specified for the first row component
            
            self.firstRowKey = dynamicRowName;
            
        }
        
        if (self.chainTemplate.targetsVaryByRound == NO || self.chainTemplate.numberOfRounds == 1){
            
            verticalAppendString = [NSString stringWithFormat: @"[%@]-0-|",
                                    dynamicRowName];
            
        } else if (i == 0){
            
            verticalAppendString = [NSString stringWithFormat: @"[%@]-0-",
                                    dynamicRowName];
            
            
        } else if (i == iterationLimit - 1){
            
            verticalAppendString = [NSString stringWithFormat: @"[%@(==%@)]-0-|",
                                    dynamicRowName,
                                    self.firstRowKey];
            
        } else{
            
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
    
    for (TJBCircuitTemplateRowComponent *child in self.childViewControllers)
    {
        [child didMoveToParentViewController: self];
    }
}

#pragma mark - Button Actions

- (IBAction)didPressSelectExercise:(id)sender{
    
    __weak TJBCircuitTemplateExerciseComp *weakSelf = self;
    
    void (^callback)(TJBExercise *) = ^(TJBExercise *selectedExercise){
        
        // notify the master controller of the selection.  Because chain templates store the exercises as an ordered set (not mutable), the master controller must maintain a mutable ordered set (which initially contains placeholder exercises) and assign that set to the chain templates property every time an exercise is selected
        
        [self.masterController didSelectExercise: selectedExercise
                                forExerciseIndex: [self.exerciseIndex intValue]];
        
        // update the view
        
        self.selectedExerciseButton.backgroundColor = [UIColor clearColor];
        [self.selectedExerciseButton setTitleColor: [[TJBAestheticsController singleton] blueButtonColor]
                                          forState: UIControlStateNormal];
        
        [self.selectedExerciseButton setTitle: selectedExercise.name
                                     forState: UIControlStateNormal];
        
        //
        
        [weakSelf dismissViewControllerAnimated: NO
                                     completion: nil];
        
    };
    
    TJBExerciseSelectionScene *vc = [[TJBExerciseSelectionScene alloc] initWithCallbackBlock: callback];
    
    [self presentViewController: vc
                       animated: YES
                     completion: nil];
    
}



@end





















































