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

@property (weak, nonatomic) IBOutlet UIButton *selectedExerciseButton;
@property (weak, nonatomic) IBOutlet UILabel *horizontalThinLabel;
@property (weak, nonatomic) IBOutlet UILabel *exerciseNumberLabel;
@property (weak, nonatomic) IBOutlet UIStackView *rowCompStackView;

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

#pragma mark - Init Helper Methods



#pragma mark - View Life Cycle



- (void)viewDidLoad{
    
    [self viewAesthetics];
    
    [self configureStackView];
    
    self.exerciseNumberLabel.text = [NSString stringWithFormat: @"%d", [self.exerciseIndex intValue] + 1];
    
    int numberRounds = [[self.masterController numberOfRounds] intValue];
    
    for (int i = 0 ; i < numberRounds ; i ++){
        
        [self appendNewRoundComponentToExistingStructureWithRoundIndex: i];
        
    }

}










#pragma mark - View Helper Methods

- (void)configureStackView{
    
    self.rowCompStackView.distribution = UIStackViewDistributionFillEqually;
    
}


- (void)viewAesthetics{
    
    self.view.backgroundColor = [UIColor clearColor];
    
    // selected exercise button
    
    UIButton *button = self.selectedExerciseButton;
    
    button.backgroundColor = [[TJBAestheticsController singleton] blueButtonColor];
    UIColor *color = [[TJBAestheticsController singleton] buttonTextColor];
    [button setTitleColor: color
                 forState: UIControlStateNormal];
    
    button.titleLabel.numberOfLines = 0;
    button.titleLabel.font = [UIFont boldSystemFontOfSize: 20];
    
    // number label
    
    self.exerciseNumberLabel.font = [UIFont boldSystemFontOfSize: 35];
    self.exerciseNumberLabel.textColor = [[TJBAestheticsController singleton] yellowNotebookColor];
    self.exerciseNumberLabel.backgroundColor = [UIColor clearColor];
    
    
    // selected exercise button layer
    
    CALayer *layer = button.layer;
    layer.masksToBounds = YES;
    layer.cornerRadius = 8;
    
}



    
    
    
#pragma mark - Content Generation
    
- (void)appendNewRoundComponentToExistingStructureWithRoundIndex:(int)roundIndex{
    
    TJBCircuitTemplateRowComponent *rowVC = [[TJBCircuitTemplateRowComponent alloc] initWithChainTemplate: self.chainTemplate
                                                                                         masterController: self.masterController
                                                                                            exerciseIndex: [self.exerciseIndex intValue]
                                                                                               roundIndex: roundIndex];
    
    // add the newly created row component to the master controller's child collection
    
    [self.masterController addChildRowController: rowVC
                    correspondingToExerciseIndex: [self.exerciseIndex intValue]];
    
    [self addChildViewController: rowVC];
    
    [self.rowCompStackView addArrangedSubview: rowVC.view];

    [rowVC didMoveToParentViewController: self];
    
}

#pragma  mark - API

- (void)addRoundRowForExerciseIndex:(int)exerciseIndex{
    
    [self appendNewRoundComponentToExistingStructureWithRoundIndex: exerciseIndex];
    
}

- (void)deleteRowCorrespondingToRowComponent:(TJBCircuitTemplateRowComponent *)rowComponent{
    
    [rowComponent willMoveToParentViewController: nil];
    
//    [self.rowCompStackView removeArrangedSubview: rowComponent.view];
    [rowComponent.view removeFromSuperview];
    
    [rowComponent removeFromParentViewController];
    
}


#pragma mark - Old





#pragma mark - Button Actions

- (IBAction)didPressSelectExercise:(id)sender{
    
    __weak TJBCircuitTemplateExerciseComp *weakSelf = self;
    
    void (^callback)(TJBExercise *) = ^(TJBExercise *selectedExercise){
        
        // notify the master controller of the selection.  Because chain templates store the exercises as an ordered set (not mutable), the master controller must maintain a mutable ordered set (which initially contains placeholder exercises) and assign that set to the chain templates property every time an exercise is selected
        
        [self.masterController didSelectExercise: selectedExercise
                                forExerciseIndex: [self.exerciseIndex intValue]];
        
        TJBTargetUnitCollection *tuc = self.chainTemplate.targetUnitCollections[[self.exerciseIndex intValue]];
        
        for (int i = 0; i < self.chainTemplate.numberOfRounds; i++){
            
            TJBTargetUnit *tu = tuc.targetUnits[i];
            tu.exercise = selectedExercise;
            
        }
        
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





















































