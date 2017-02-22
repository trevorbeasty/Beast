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

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *roundColumnLabel;
@property (weak, nonatomic) IBOutlet UILabel *weightColumnLabel;
@property (weak, nonatomic) IBOutlet UILabel *repsColumnLabel;
@property (weak, nonatomic) IBOutlet UILabel *restColumnLabel;
@property (weak, nonatomic) IBOutlet UILabel *thinLineLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectedExerciseButton;


@property (nonatomic, strong) NSMutableDictionary *constraintMapping;

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
    
    // container view
    
    CALayer *viewLayer = self.view.layer;
    viewLayer.masksToBounds = YES;
    viewLayer.cornerRadius = 8.0;
    
    self.view.backgroundColor = [[TJBAestheticsController singleton] yellowNotebookColor];
    
    // column label views
    
    NSArray *labels = @[self.roundColumnLabel,
                            self.weightColumnLabel,
                            self.repsColumnLabel,
                            self.restColumnLabel];
    
    for (UILabel *l in labels){
        
        l.backgroundColor = [UIColor lightGrayColor];
        l.textColor = [UIColor whiteColor];
        l.font = [UIFont boldSystemFontOfSize: 20.0];
        
    }
    
    // title label view
    
    self.titleLabel.backgroundColor = [UIColor lightGrayColor];
    [self.titleLabel setTextColor: [UIColor whiteColor]];
    
    // selected exercise button
    
    UIButton *button = self.selectedExerciseButton;
        
    button.backgroundColor = [[TJBAestheticsController singleton] blueButtonColor];
    UIColor *color = [[TJBAestheticsController singleton] buttonTextColor];
    [button setTitleColor: color
                 forState: UIControlStateNormal];
    
    
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
    
    self.titleLabel.text = [NSString stringWithFormat: @"Exercise %d",
                            [self.exerciseIndex intValue] + 1];
    
    // row components
    
    NSString *thinLineLabel = @"thinLineLabel";
    [self.constraintMapping setObject: self.thinLineLabel
                               forKey: thinLineLabel];
    
    NSString *roundColumnLabel = @"roundColumnLabel";
    [self.constraintMapping setObject:self.roundColumnLabel
                               forKey: roundColumnLabel];
    
    
    
    NSMutableString *verticalLayoutConstraintsString = [NSMutableString stringWithCapacity: 1000];
    [verticalLayoutConstraintsString setString: [NSString stringWithFormat: @"V:[%@]-0-", thinLineLabel]];
    
    for (int i = 0 ; i < self.chainTemplate.numberOfRounds ; i ++){
        
        TJBCircuitTemplateRowComponent *rowVC = [[TJBCircuitTemplateRowComponent alloc] initWithChainTemplate: self.chainTemplate
                                                                                             masterController: self.masterController
                                                                                                exerciseIndex: [self.exerciseIndex intValue]
                                                                                                   roundIndex: i];
        
        // add the newly created row component to the master controller's child collection
        
        [self.masterController addChildRowController: rowVC
                                    forExerciseIndex: [self.exerciseIndex intValue]];
        
        rowVC.view.translatesAutoresizingMaskIntoConstraints = NO;
        
        [self addChildViewController: rowVC];
        
        [self.view addSubview: rowVC.view];
        
        NSString *dynamicRowName = [NSString stringWithFormat: @"rowComponent%d",
                                    i];
        
        [self.constraintMapping setObject: rowVC.view
                                   forKey: dynamicRowName];
        
        // vertical constraints
        
        NSString *verticalAppendString;
        
        if (self.chainTemplate.targetsVaryByRound == NO)
        {
            i = self.chainTemplate.numberOfRounds - 1;
        }
        
        if (i == self.chainTemplate.numberOfRounds - 1)
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
        [self.selectedExerciseButton setTitleColor: [UIColor blackColor]
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





















































