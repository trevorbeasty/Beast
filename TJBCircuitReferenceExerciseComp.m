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
@property (weak, nonatomic) IBOutlet UIStackView *rowCompStackView;



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
    
    [self configureStackViewContent];
    
    
}




#pragma mark - View Helper Methods

- (void)configureViewAesthetics{
    
    // meta view
    
    self.view.backgroundColor = [UIColor clearColor];
    
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

#pragma mark - Child Row Component Controllers

- (void)configureStackViewContent{
    
    self.rowCompStackView.distribution = UIStackViewDistributionFillEqually;
    
    int limit = _editingDataType == TJBRealizedsetGroupingEditingData ? (int)self.rsg.count : self.realizedChain.chainTemplate.numberOfRounds;
    
    for (int i = 0; i < limit; i++){
        
        [self createAndConfigureRowComponentForRoundIndex: i];
        
    }
    
}

- (TJBCircuitReferenceRowComp *)createAndConfigureRowComponentForRoundIndex:(int)roundIndex{
    
    TJBCircuitReferenceRowComp *vc = [[TJBCircuitReferenceRowComp alloc] initWithRealizedChain: self.realizedChain
                                                                                   realizedSet: self.rsg[roundIndex]
                                                                               editingDataType: _editingDataType
                                                                                 exerciseIndex: [self.exerciseIndex intValue]
                                                                                    roundIndex: roundIndex];
    vc.view.translatesAutoresizingMaskIntoConstraints = NO;
    
    [self addChildViewController: vc];
    
    [self.rowCompStackView addArrangedSubview: vc.view];
    
    [vc didMoveToParentViewController: self];
    
    return vc;
    
}












@end
