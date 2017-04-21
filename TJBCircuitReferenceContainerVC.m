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

#import "TJBAssortedUtilities.h" // utilities

@interface TJBCircuitReferenceContainerVC ()

{
    
    TJBEditingDataType _editingDataType;
    
}

// IBOutlet

@property (weak, nonatomic) IBOutlet UIView *circuitReferenceView;
@property (weak, nonatomic) IBOutlet UIView *titleContainerView;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel1;
@property (weak, nonatomic) IBOutlet UIButton *returnButton;
@property (weak, nonatomic) IBOutlet UIView *columnHeadersContainer;
@property (weak, nonatomic) IBOutlet UILabel *restOrTimeColumnLabel;
@property (weak, nonatomic) IBOutlet UILabel *repsColumnLabel;
@property (weak, nonatomic) IBOutlet UILabel *weightColumnLabel;

// IBAction

- (IBAction)didPressReturnButton:(id)sender;


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
    
    [self configureColumnLabelsText];
    
    [self layoutContent];
    
}

#pragma mark - View Helper Methods


- (void)configureViewAesthetics{
    
    // meta view
    
    self.circuitReferenceView.backgroundColor = [[TJBAestheticsController singleton] yellowNotebookColor];
    self.view.backgroundColor = [UIColor blackColor];
    
    // title label

    self.titleLabel1.backgroundColor = [UIColor darkGrayColor];
    self.titleLabel1.textColor = [UIColor whiteColor];
    self.titleLabel1.font = [UIFont boldSystemFontOfSize: 20];

    // title bar container
    
    self.titleContainerView.backgroundColor = [UIColor blackColor];
    
    // button
    
    self.returnButton.backgroundColor = [UIColor grayColor];
    [self.returnButton setTitleColor: [[TJBAestheticsController singleton] paleLightBlueColor]
                            forState: UIControlStateNormal];
    self.returnButton.titleLabel.font = [UIFont boldSystemFontOfSize: 20];
    
    CALayer *rbLayer = self.returnButton.layer;
    rbLayer.masksToBounds = YES;
    rbLayer.cornerRadius = 22;
    rbLayer.borderWidth = 1;
    rbLayer.borderColor = [[TJBAestheticsController singleton] paleLightBlueColor].CGColor;
    
    // column label area
    
    self.columnHeadersContainer.backgroundColor = [[TJBAestheticsController singleton] yellowNotebookColor];
    NSArray *columnLabels = @[self.weightColumnLabel, self.repsColumnLabel, self.restOrTimeColumnLabel];
    for (UILabel *label in columnLabels){
        
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize: 12];
        label.textColor = [UIColor blackColor];
        label.numberOfLines = 0;
        label.lineBreakMode = NSLineBreakByWordWrapping;
        label.textAlignment = NSTextAlignmentCenter;
        
    }
    
    // detailed lines
    
    [self drawDetailedLines];
    
}

- (void)configureColumnLabelsText{
    
    
    if (_editingDataType == TJBRealizedsetGroupingEditingData){
        
        self.restOrTimeColumnLabel.text = @"submission \ntime";
        
    } else{
        
        self.restOrTimeColumnLabel.text = @"rest";
        
    }
    
}

- (void)drawDetailedLines{
    
    [self.view layoutSubviews];
    [self.columnHeadersContainer layoutSubviews];
    
    NSArray *detailedLineLabels = @[self.weightColumnLabel, self.repsColumnLabel];
    for (UILabel *label in detailedLineLabels){
        
        [TJBAssortedUtilities drawVerticalDividerToRightOfLabel: label
                                               horizontalOffset: 0
                                                      thickness: .5
                                                 verticalOffset: label.frame.size.height / 4.0
                                                       metaView: self.columnHeadersContainer];
        
    }
    
}

- (void)layoutContent{
    
    [self.view layoutSubviews];
    
    TJBCircuitReferenceVC *vc = [[TJBCircuitReferenceVC alloc] initWithRealizedChain: self.realizedChain
                                                                 realizedSetGrouping: self.rsg
                                                                     editingDataType: _editingDataType
                                                                    masterController: self];
    self.childRoutineVC = vc;
    
    vc.view.frame = self.circuitReferenceView.bounds;
    
    [self addChildViewController: vc];
    
    [self.circuitReferenceView insertSubview: vc.view
                                     atIndex: 0];
    
    [vc didMoveToParentViewController: self];
    
}

#pragma mark - Button Actions



- (IBAction)didPressReturnButton:(id)sender{
    
    [self dismissViewControllerAnimated: YES
                             completion: nil];
    
}

#pragma mark - View Math

- (CGFloat)returnButtonBufferHeight{
    
    [self.view layoutSubviews];
    
    return self.circuitReferenceView.frame.size.height - self.returnButton.frame.origin.y;
    
}



@end




































































