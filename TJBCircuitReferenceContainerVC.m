//
//  TJBCircuitReferenceContainerVC.m
//  Beast
//
//  Created by Trevor Beasty on 1/11/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBCircuitReferenceContainerVC.h"

// core data

#import "CoreDataController.h"

// child VC

#import "TJBCircuitReferenceVC.h"

// aesthetics

#import "TJBAestheticsController.h"

@interface TJBCircuitReferenceContainerVC ()

{
    
    TJBEditingDataType _editingDataType;
    
}

// IBOutlet

@property (weak, nonatomic) IBOutlet UIView *circuitReferenceView;
@property (weak, nonatomic) IBOutlet UIView *titleContainerView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel1;

// core

@property (nonatomic, strong) TJBRealizedChain *realizedChain;
@property (strong) TJBRealizedSetGrouping rsg;
@property (nonatomic, strong) TJBCircuitReferenceVC *childRoutineVC;

@end

@implementation TJBCircuitReferenceContainerVC

#pragma mark - Instantiation

- (instancetype)initWithDataObject:(id)dataObject{
    
    self = [super init];
    
    [self determineDataTypeAndStoreAccordinglyForDataObject: dataObject];
    
    return self;
}



#pragma mark - Init Helper Methods

- (void)determineDataTypeAndStoreAccordinglyForDataObject:(id)dataObject{
    
    if ([dataObject isKindOfClass: [TJBRealizedChain class]]){
        
        TJBRealizedChain *rc = dataObject;
        self.realizedChain = rc;
        
        _editingDataType = TJBRealizedChainEditingData;
        
    } else if ([dataObject isKindOfClass: [TJBRealizedSet class]]){
        
        TJBRealizedSet *rs = dataObject;
        TJBRealizedSetGrouping rsg = @[rs];
        self.rsg = rsg;
        
        _editingDataType = TJBRealizedsetGroupingEditingData;
        
    } else if ([dataObject isKindOfClass: [NSArray class]]){
        
        TJBRealizedSetGrouping rsg = dataObject;
        self.rsg = rsg;
        
        _editingDataType = TJBRealizedsetGroupingEditingData;
        
    }
    
}



#pragma  mark - View Life Cycle

- (void)viewDidLoad{
    
    [self configureViewAesthetics];
    
}


- (void)configureViewAesthetics{
    
    // meta view
    
    self.view.backgroundColor = [[TJBAestheticsController singleton] yellowNotebookColor];
    
    // title label

    self.titleLabel1.backgroundColor = [UIColor darkGrayColor];
    self.titleLabel1.textColor = [UIColor whiteColor];
    self.titleLabel1.font = [UIFont boldSystemFontOfSize: 20];

    // title bar container
    
    self.titleContainerView.backgroundColor = [UIColor blackColor];
    
}

- (void)layoutContent{
    
    [self.view layoutSubviews];
    
    TJBCircuitReferenceVC *vc = [[TJBCircuitReferenceVC alloc] initWithRealizedChain: self.realizedChain
                                                                 realizedSetGrouping: self.rsg
                                                                     editingDataType: _editingDataType];
    self.childRoutineVC = vc;
    
    vc.view.frame = self.circuitReferenceView.bounds;
    
    [self addChildViewController: vc];
    
    [self.circuitReferenceView addSubview: vc.view];
    
    [vc didMoveToParentViewController: self];
    
}

@end




































































