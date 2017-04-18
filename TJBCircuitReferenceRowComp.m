//
//  TJBCircuitReferenceRowComp.m
//  Beast
//
//  Created by Trevor Beasty on 1/11/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBCircuitReferenceRowComp.h"

// aesthetics

#import "TJBAestheticsController.h"

// stopwatch

#import "TJBStopwatch.h"

// core data

#import "CoreDataController.h"

// utilities

#import "TJBAssortedUtilities.h"

// number selection

#import "TJBNumberSelectionVC.h"

@interface TJBCircuitReferenceRowComp ()

{
    
    TJBEditingDataType _editingDataType;
    
}

// core

@property (nonatomic, strong) NSNumber *exerciseIndex;
@property (nonatomic, strong) NSNumber *roundIndex;

@property (nonatomic, strong) TJBRealizedChain *realizedChain;
@property (nonatomic, strong) TJBRealizedSet *rs;

// IBOutlet

@property (weak, nonatomic) IBOutlet UIButton *weightButton;
@property (weak, nonatomic) IBOutlet UIButton *repsButton;
@property (weak, nonatomic) IBOutlet UIButton *restButton;
@property (weak, nonatomic) IBOutlet UILabel *roundLabel;

// IBAction

- (IBAction)didPressWeightButton:(id)sender;
- (IBAction)didPressRepsButton:(id)sender;

@end

@implementation TJBCircuitReferenceRowComp

#pragma mark - Instantiation

- (instancetype)initWithRealizedChain:(TJBRealizedChain *)realizedChain realizedSet:(TJBRealizedSet *)rs editingDataType:(TJBEditingDataType)editingDataType exerciseIndex:(int)exerciseIndex roundIndex:(int)roundIndex{
    
    self = [super init];
    
    
    self.realizedChain = realizedChain;
    self.rs = rs;
    self.exerciseIndex = @(exerciseIndex);
    self.roundIndex = @(roundIndex);
    _editingDataType = editingDataType;
    
    

    return self;
    
}


#pragma mark - Init Helper Methods



#pragma mark - View Life Cycle

- (void)viewDidLoad{
    
    [self configureViewAesthetics];
    
    [self configureInitialViewData];
    
    [self configureButtonAestheticsAndFunctionality];
    
}


#pragma mark - View Helper Methods

- (void)configureViewAesthetics{
    
    // meta view
    
    self.view.backgroundColor = [UIColor clearColor];
    
    // round label
    
    self.roundLabel.backgroundColor = [UIColor clearColor];
    self.roundLabel.textColor = [UIColor blackColor];
    self.roundLabel.font = [UIFont boldSystemFontOfSize: 15];
    self.roundLabel.layer.opacity = 1.0;
    
    
}


- (void)configureInitialViewData{
    
    // weight and reps
    
    TJBRealizedSet *rs = [self realizedSetForController];
    
    if (rs.holdsNullValues == NO){
        
        NSNumber *weight = @(rs.submittedWeight);
        NSNumber *reps = @(rs.submittedReps);
        
        [self.weightButton setTitle: [weight stringValue]
                           forState: UIControlStateNormal];
        [self.repsButton setTitle: [reps stringValue]
                         forState: UIControlStateNormal];
        
        if (_editingDataType == TJBRealizedsetGroupingEditingData){
            
            NSDateFormatter *df = [[NSDateFormatter alloc] init];
            df.dateFormat = @"h:mm a";
            NSString *formattedTime = [df stringFromDate: rs.submissionTime];
            
            [self.restButton setTitle: formattedTime
                             forState: UIControlStateNormal];
            
        } else if (_editingDataType == TJBRealizedChainEditingData){
            
            TJBTargetUnit *tu = [self targetUnitForController];
            
            if (tu.isTargetingTrailingRest){
                
                float targetRest = tu.trailingRestTarget;
                NSString *formattedRest = [[TJBStopwatch singleton] minutesAndSecondsStringFromNumberOfSeconds: (int)targetRest];
                
                [self.restButton setTitle: formattedRest
                                 forState: UIControlStateNormal];
                
            } else{
                
                [self.restButton setTitle: @"X"
                                 forState: UIControlStateNormal];
                
            }
            
            
            
        }
        
         
    } else{
        
        NSString *blank = @"-";
        
        [self.weightButton setTitle: blank
                           forState: UIControlStateNormal];
        [self.repsButton setTitle: blank
                         forState: UIControlStateNormal];
        
        [self.restButton setTitle: @""
                         forState: UIControlStateNormal];
        
        
    }
    
    
    // round
    
    NSNumber *roundNumber = @([self.roundIndex intValue] + 1);
    NSString *roundText;
    
    if (_editingDataType == TJBRealizedChainEditingData){
        
        
        roundText = [NSString stringWithFormat: @"Round %@", [roundNumber stringValue]];
        
        
    } else if (_editingDataType == TJBRealizedsetGroupingEditingData){
        
        
        roundText = [NSString stringWithFormat: @"Set %@", [roundNumber stringValue]];
        
        
    }
    
    self.roundLabel.text = roundText;
    
    
}

- (void)configureButtonAestheticsAndFunctionality{
    
    TJBRealizedSet *rs = [self realizedSetForController];
    
    if (rs.holdsNullValues == NO){
        
        [self giveButtonActiveAppearanceAndFunctionality: self.weightButton];
        [self giveButtonActiveAppearanceAndFunctionality: self.repsButton];
        
        
    } else{
        
        
        [self giveButtonInactiveAppearanceAndFunctionality: self.weightButton];
        [self giveButtonInactiveAppearanceAndFunctionality: self.repsButton];
        
        
    }
    
    [self giveButtonInactiveAppearanceAndFunctionality: self.restButton];
    
}

#pragma mark - Button Appearances and States

- (void)giveButtonActiveAppearanceAndFunctionality:(UIButton *)butt{
    
    butt.enabled = YES;
    
    butt.backgroundColor = [[TJBAestheticsController singleton] paleLightBlueColor];
    [butt setTitleColor: [UIColor darkGrayColor]
               forState: UIControlStateNormal];
    butt.titleLabel.font = [UIFont systemFontOfSize: 15];
    
    CALayer *buttLayer = butt.layer;
    buttLayer.masksToBounds = YES;
    buttLayer.cornerRadius = 8;
    buttLayer.borderWidth = 1;
    buttLayer.borderColor = [UIColor darkGrayColor].CGColor;
    
    
}



- (void)giveButtonInactiveAppearanceAndFunctionality:(UIButton *)butt{
    
    butt.enabled = NO;
    
    butt.backgroundColor = [UIColor clearColor];
    [butt setTitleColor: [UIColor blackColor]
               forState: UIControlStateNormal];
    butt.titleLabel.font = [UIFont systemFontOfSize: 15];
    
    CALayer *buttLayer = butt.layer;
    buttLayer.borderWidth = 0;

    
}

#pragma mark - Core Data

- (TJBRealizedSet *)realizedSetForController{
    
    if (_editingDataType == TJBRealizedChainEditingData){
        
        return self.realizedChain.realizedSetCollections[[self.exerciseIndex intValue]].realizedSets[[self.roundIndex intValue]];

    } else if (_editingDataType == TJBRealizedsetGroupingEditingData){
        
        return self.rs;

    } else{
        
        return nil;
        
    }
    
}

- (TJBTargetUnit *)targetUnitForController{
    
    if (_editingDataType == TJBRealizedChainEditingData){
        
        return  self.realizedChain.chainTemplate.targetUnitCollections[[self.exerciseIndex intValue]].targetUnits[[self.roundIndex intValue]];
        
    }
    
    return nil;
    
}




#pragma mark - Target Action



- (IBAction)didPressWeightButton:(id)sender{
    
    // present the single number selection scene.  If a number is chosen, update core data and refresh the view
    
    CancelBlock cancelBlock = ^{
        
      [self dismissViewControllerAnimated: NO
                               completion: nil];
        
    };
    
    NumberSelectedBlockSingle numberSelectedBlock = ^(NSNumber *selectedNumber){
        
        // update the realized chain and save core data changes
        
        [self realizedSetForController].submittedWeight = [selectedNumber floatValue];
        
        [[CoreDataController singleton] saveContext];
        
        // button
        
        [self.weightButton setTitle: [selectedNumber stringValue]
                           forState: UIControlStateNormal];
        
        // presented VC
        
        [self dismissViewControllerAnimated: NO
                                 completion: nil];
        
    };
    
    TJBNumberSelectionVC *vc = [[TJBNumberSelectionVC alloc] initWithNumberTypeIdentifier: WeightType
                                                                                    title: @"Select Weight"
                                                                              cancelBlock: cancelBlock
                                                                      numberSelectedBlock: numberSelectedBlock];
    
    [self presentViewController: vc
                       animated: YES
                     completion: nil];
    
}

- (IBAction)didPressRepsButton:(id)sender{
    
    // present the single number selection scene.  If a number is chosen, update core data and refresh the view
    
    // present the single number selection scene.  If a number is chosen, update core data and refresh the view
    
    CancelBlock cancelBlock = ^{
        
        [self dismissViewControllerAnimated: NO
                                 completion: nil];
        
    };
    
    NumberSelectedBlockSingle numberSelectedBlock = ^(NSNumber *selectedNumber){
        
        // update the realized chain and save core data changes
        
        [self realizedSetForController].submittedReps = [selectedNumber floatValue];
        
        [[CoreDataController singleton] saveContext];
        
        // button
        
        [self.repsButton setTitle: [selectedNumber stringValue]
                         forState: UIControlStateNormal];
        
        // presented VC
        
        [self dismissViewControllerAnimated: NO
                                 completion: nil];
        
    };
    
    TJBNumberSelectionVC *vc = [[TJBNumberSelectionVC alloc] initWithNumberTypeIdentifier: RepsType
                                                                                    title: @"Select Reps"
                                                                              cancelBlock: cancelBlock
                                                                      numberSelectedBlock: numberSelectedBlock];
    
    [self presentViewController: vc
                       animated: YES
                     completion: nil];
    
}









@end






























































