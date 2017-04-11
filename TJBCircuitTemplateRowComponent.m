//
//  TJBCircuitTemplateRowComponent.m
//  Beast
//
//  Created by Trevor Beasty on 1/10/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBCircuitTemplateRowComponent.h"

// master VC

#import "TJBCircuitTemplateVC.h"

// aesthetics

#import "TJBAestheticsController.h"

// stopwatch

#import "TJBStopwatch.h"

// core data

#import "CoreDataController.h"

// number selection

@interface TJBCircuitTemplateRowComponent ()

{
    
    // state - for copying
    
    BOOL _copyingActive;
    BOOL _isReferenceForCopying;
    float _valueToCopy;
    TJBCopyInputType _copyInputType;
    
    BOOL _isTargetingWeight;
    BOOL _isTargetingReps;
    BOOL _isTargetingTrailingRest;
    
}

// core

@property (nonatomic, strong) NSNumber *roundIndex;
@property (nonatomic, strong) NSNumber *exerciseIndex;
@property (nonatomic, strong) TJBChainTemplate *chainTemplate;
@property (nonatomic, weak) TJBCircuitTemplateVC <TJBCircuitTemplateVCProtocol> *masterController;

// IBAction

- (IBAction)didPressWeightButton:(id)sender;
- (IBAction)didPressRepsButton:(id)sender;
- (IBAction)didPressRestButton:(id)sender;

// IBOutlet



@property (weak, nonatomic) IBOutlet UILabel *roundLabel;



@end

@implementation TJBCircuitTemplateRowComponent

#pragma mark - Instantiation

- (instancetype)initWithChainTemplate:(TJBChainTemplate *)chainTemplate masterController:(TJBCircuitTemplateVC<TJBCircuitTemplateVCProtocol> *)masterController exerciseIndex:(int)exerciseIndex roundIndex:(int)roundIndex{
    
    self = [super init];
    
    self.chainTemplate = chainTemplate;
    self.roundIndex = [NSNumber numberWithInt: roundIndex];
    self.exerciseIndex = [NSNumber numberWithInt: exerciseIndex];
    self.masterController = masterController;
    
    _isTargetingWeight = YES;
    _isTargetingReps = YES;
    _isTargetingTrailingRest = YES;
    
    return self;
    
}

#pragma mark - View Life Cycle

- (void)viewDidLoad{
    
    [self viewAesthetics];
    
    [self configureGestureRecognizers];
    
}

- (void)configureGestureRecognizers{
    
    // a long press GR is used to kick off the copying process.  One must be used for every of the 3 buttons
    
    // weight
    
    UILongPressGestureRecognizer *longPressGRWeight = [[UILongPressGestureRecognizer alloc] initWithTarget: self
                                                                                              action: @selector(didLongPressWeightButton:)];
    
    longPressGRWeight.minimumPressDuration = .2;
    longPressGRWeight.numberOfTouchesRequired = 1;
    
    longPressGRWeight.cancelsTouchesInView = YES;
    longPressGRWeight.delaysTouchesBegan = NO;
    longPressGRWeight.delaysTouchesEnded = NO;
    
    [self.weightButton addGestureRecognizer: longPressGRWeight];
    
    // reps
    
    UILongPressGestureRecognizer *longPressGRReps = [[UILongPressGestureRecognizer alloc] initWithTarget: self
                                                                                                  action: @selector(didLongPressRepsButton:)];
    
    longPressGRWeight.minimumPressDuration = .2;
    longPressGRWeight.numberOfTouchesRequired = 1;
    
    longPressGRWeight.cancelsTouchesInView = YES;
    longPressGRWeight.delaysTouchesBegan = NO;
    longPressGRWeight.delaysTouchesEnded = NO;
    
    [self.repsButton addGestureRecognizer: longPressGRReps];
    
    // rest
    
    UILongPressGestureRecognizer *longPressGRRest = [[UILongPressGestureRecognizer alloc] initWithTarget: self
                                                                                                  action: @selector(didLongPressRestButton:)];
    
    longPressGRWeight.minimumPressDuration = .2;
    longPressGRWeight.numberOfTouchesRequired = 1;
    
    longPressGRWeight.cancelsTouchesInView = YES;
    longPressGRWeight.delaysTouchesBegan = NO;
    longPressGRWeight.delaysTouchesEnded = NO;
    
    [self.restButton addGestureRecognizer: longPressGRRest];
    
}

- (void)viewAesthetics{
    
    // background
    
    self.view.backgroundColor = [UIColor clearColor];
    
    // round label
    
    self.roundLabel.text = [NSString stringWithFormat: @"Round %d", [self.roundIndex intValue] + 1];
        
    self.roundLabel.backgroundColor = [UIColor clearColor];
    self.roundLabel.textColor = [UIColor whiteColor];
    self.roundLabel.font = [UIFont boldSystemFontOfSize: 15];
    
    int eInd = [self.exerciseIndex intValue];
    int rInd = [self.roundIndex intValue];
    
    TJBTargetUnit *tu = self.chainTemplate.targetUnitCollections[eInd].targetUnits[rInd];
        
    if (tu.isTargetingWeight == YES){
            
        [self giveButtonActiveConfig: self.weightButton];
        
    } else{
            
        [self giveButtonInactiveConfig: self.weightButton];
    }
        
    if (tu.isTargetingReps == YES){
            
        [self giveButtonActiveConfig: self.repsButton];
        
    } else{
            
        [self giveButtonInactiveConfig: self.repsButton];
    }
        
    if (tu.isTargetingTrailingRest == YES){
            
        [self giveButtonActiveConfig: self.restButton];
        
    } else{
            
        [self giveButtonInactiveConfig: self.restButton];
    }
        
    
}

- (void)giveButtonActiveConfig:(UIButton *)button{
    
    button.backgroundColor = [[TJBAestheticsController singleton] yellowNotebookColor];
//    button.backgroundColor = [UIColor clearColor];
    [button setTitleColor: [UIColor blackColor]
                 forState: UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize: 15.0];
    
    CALayer *layer = button.layer;
    layer.masksToBounds = YES;
    layer.cornerRadius = 8.0;
//    layer.borderColor = [[TJBAestheticsController singleton] paleLightBlueColor].CGColor;
//    layer.borderWidth = 1.0;
    
}

- (void)giveButtonInactiveConfig:(UIButton *)button{
    
    button.backgroundColor = [UIColor clearColor];
    [button setTitle: @""
            forState: UIControlStateNormal];
    button.enabled = NO;
    
}


#pragma mark - Button Actions

- (IBAction)didPressWeightButton:(id)sender{
    
    // present the single number selection scene.  If a number is chosen, update core data and refresh the view
    
    CancelBlock cancelBlock = ^{
        
        [self dismissViewControllerAnimated: NO
                                 completion: nil];
        
    };
    
    NumberSelectedBlockSingle numberSelectedBlock = ^(NSNumber *selectedNumber){
        
        // update the realized chain and save core data changes
        
        int exerciseInd = [self.exerciseIndex intValue];
        int roundInd = [self.roundIndex intValue];
        
        // update core data.  The 'isDefaultObject' property indicates if a selection has been made for this particular target since the skeleton chain was created.  It is useful for app restoration (indicates whether or not to show the button as blue or yellow)
        
        TJBTargetUnit *tu = self.chainTemplate.targetUnitCollections[exerciseInd].targetUnits[roundInd];
        tu.weightTarget = [selectedNumber floatValue];
        tu.weightIsNull = NO;
        
        [[CoreDataController singleton] saveContext];
        
        // configure the button
        
        self.weightButton.backgroundColor = [UIColor clearColor];
        [self.weightButton setTitleColor: [[TJBAestheticsController singleton] paleLightBlueColor]
                                forState: UIControlStateNormal];
        
        NSString *weightText = [NSString stringWithFormat: @"%@ lbs", [selectedNumber stringValue]];
        [self.weightButton setTitle: weightText
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
    
    CancelBlock cancelBlock = ^{
        
        [self dismissViewControllerAnimated: NO
                                 completion: nil];
        
    };
    
    NumberSelectedBlockSingle numberSelectedBlock = ^(NSNumber *selectedNumber){
        
        // update the realized chain and save core data changes
        
        int exerciseInd = [self.exerciseIndex intValue];
        int roundInd = [self.roundIndex intValue];
        
        // update core data.  The 'isDefaultObject' property indicates if a selection has been made for this particular target since the skeleton chain was created.  It is useful for app restoration (indicates whether or not to show the button as blue or yellow)
        
        TJBTargetUnit *tu = self.chainTemplate.targetUnitCollections[exerciseInd].targetUnits[roundInd];
        tu.repsTarget = [selectedNumber floatValue];
        tu.repsIsNull = NO;
        
        [[CoreDataController singleton] saveContext];
        
        // configure the button
        
        self.repsButton.backgroundColor = [UIColor clearColor];
        [self.repsButton setTitleColor: [[TJBAestheticsController singleton] paleLightBlueColor]
                                forState: UIControlStateNormal];
        
        NSString *repsText = [NSString stringWithFormat: @"%@ reps", [selectedNumber stringValue]];
        [self.repsButton setTitle: repsText
                         forState: UIControlStateNormal];
        
        // presented VC
        
        [self dismissViewControllerAnimated: NO
                                 completion: nil];
        
    };
    
    TJBNumberSelectionVC *vc = [[TJBNumberSelectionVC alloc] initWithNumberTypeIdentifier: RepsType
                                                                                    title: @"Select Weight"
                                                                              cancelBlock: cancelBlock
                                                                      numberSelectedBlock: numberSelectedBlock];
    
    [self presentViewController: vc
                       animated: YES
                     completion: nil];
    
}

- (IBAction)didPressRestButton:(id)sender{
    
    // present the single number selection scene.  If a number is chosen, update core data and refresh the view
    
    CancelBlock cancelBlock = ^{
        
        [self dismissViewControllerAnimated: NO
                                 completion: nil];
        
    };
    
    NumberSelectedBlockSingle numberSelectedBlock = ^(NSNumber *selectedNumber){
        
        // update the realized chain and save core data changes
        
        int exerciseInd = [self.exerciseIndex intValue];
        int roundInd = [self.roundIndex intValue];
        
        // update core data.  The 'isDefaultObject' property indicates if a selection has been made for this particular target since the skeleton chain was created.  It is useful for app restoration (indicates whether or not to show the button as blue or yellow)
        
        TJBTargetUnit *tu = self.chainTemplate.targetUnitCollections[exerciseInd].targetUnits[roundInd];
        tu.trailingRestTarget = [selectedNumber floatValue];
        tu.trailingRestIsNull = NO;
        
//        self.chainTemplate.targetRestTimeArrays[exerciseInd].numbers[roundInd].value = [selectedNumber floatValue];
//        self.chainTemplate.targetRestTimeArrays[exerciseInd].numbers[roundInd].isDefaultObject = NO;
        
        [[CoreDataController singleton] saveContext];
        
        // configure the button
        
        self.restButton.backgroundColor = [UIColor clearColor];
        [self.restButton setTitleColor: [[TJBAestheticsController singleton] paleLightBlueColor]
                              forState: UIControlStateNormal];
        
        NSString *formattedTime = [[TJBStopwatch singleton] minutesAndSecondsStringFromNumberOfSeconds: [selectedNumber intValue]];
        NSString *restText = [NSString stringWithFormat: @"%@ rest", formattedTime];
        [self.restButton setTitle: restText
                         forState: UIControlStateNormal];
        
        // presented VC
        
        [self dismissViewControllerAnimated: NO
                                 completion: nil];
        
    };
    
    TJBNumberSelectionVC *vc = [[TJBNumberSelectionVC alloc] initWithNumberTypeIdentifier: TargetRestType
                                                                                    title: @"Select Weight"
                                                                              cancelBlock: cancelBlock
                                                                      numberSelectedBlock: numberSelectedBlock];
    
    [self presentViewController: vc
                       animated: YES
                     completion: nil];
    

    
}

#pragma mark - Gesture Recognizers

- (void)didLongPressWeightButton:(UIGestureRecognizer *)gr{
    
    if (gr.state == UIGestureRecognizerStateBegan){
        
        NSLog(@"began");
        
        BOOL valueNotSelected = [self targetUnitCorrespondingToVC].weightIsNull;
        
        // only initiate the copying process if a value has been selected and the copying process is not already active
        // make sure to change state variables accordingly
        
        if (!valueNotSelected && _copyingActive == NO){
            
            _isReferenceForCopying = YES;
            
            float number = [self targetUnitCorrespondingToVC].weightTarget;
            
            // change the appearance of the copying reference cell
            
            [self giveButtonCopyingAppearance: self.weightButton];
            
            [self.masterController activateCopyingStateForNumber: number
                                                   copyInputType: CopyWeightType];
            
        }
        
    } else if (gr.state == UIGestureRecognizerStateChanged && _copyingActive == YES){
        
        CGPoint touchPointInMasterView = [gr locationInView: self.masterController.view];
        
        [self.masterController didDragAcrossPointInView: touchPointInMasterView
                                          copyInputType: _copyInputType];
        
        
    } else if (gr.state == UIGestureRecognizerStateRecognized){
        
        NSLog(@"recognized");
        
        [self.masterController deactivateCopyingState];
        
    }
    
}

- (void)didLongPressRepsButton:(UIGestureRecognizer *)gr{
    
    if (gr.state == UIGestureRecognizerStateBegan){
        
        NSLog(@"began");
        
        BOOL valueNotSelected = [self targetUnitCorrespondingToVC].repsIsNull;
    
        // only initiate the copying process if a value has been selected and the copying process is not already active
        // make sure to change state variables accordingly
        
        if (!valueNotSelected && _copyingActive == NO){
            
            _isReferenceForCopying = YES;
            
            float number = [self targetUnitCorrespondingToVC].repsTarget;
            
            // change the appearance of the copying reference cell
            
            [self giveButtonCopyingAppearance: self.repsButton];
            
            [self.masterController activateCopyingStateForNumber: number
                                                   copyInputType: CopyRepsType];
            
        }
        
    } else if (gr.state == UIGestureRecognizerStateChanged && _copyingActive == YES){
        
        CGPoint touchPointInMasterView = [gr locationInView: self.masterController.view];
        
        [self.masterController didDragAcrossPointInView: touchPointInMasterView
                                          copyInputType: _copyInputType];
        
        
    } else if (gr.state == UIGestureRecognizerStateRecognized){
        
        NSLog(@"recognized");
        
        [self.masterController deactivateCopyingState];
        
    }
    
}

- (void)didLongPressRestButton:(UIGestureRecognizer *)gr{
    
    if (gr.state == UIGestureRecognizerStateBegan){
        
        NSLog(@"began");
        
        BOOL valueNotSelected = [self targetUnitCorrespondingToVC].trailingRestIsNull;
        
        // only initiate the copying process if a value has been selected and the copying process is not already active
        // make sure to change state variables accordingly
        
        if (!valueNotSelected && _copyingActive == NO){
            
            _isReferenceForCopying = YES;
            
            float number = [self targetUnitCorrespondingToVC].trailingRestTarget;
            
            // change the appearance of the copying reference cell
            
            [self giveButtonCopyingAppearance: self.restButton];
            
            [self.masterController activateCopyingStateForNumber: number
                                                   copyInputType: CopyRestType];
            
        }
        
    } else if (gr.state == UIGestureRecognizerStateChanged && _copyingActive == YES){
        
        CGPoint touchPointInMasterView = [gr locationInView: self.masterController.view];
        
        [self.masterController didDragAcrossPointInView: touchPointInMasterView
                                          copyInputType: _copyInputType];
        
        
    } else if (gr.state == UIGestureRecognizerStateRecognized){
        
        NSLog(@"recognized");
        
        [self.masterController deactivateCopyingState];
        
    }
    
}

- (void)giveButtonCopyingAppearance:(UIButton *)button{
    
    button.backgroundColor = [[TJBAestheticsController singleton] paleLightBlueColor];
    [button setTitleColor: [UIColor blackColor]
                 forState: UIControlStateNormal];
    
}

#pragma mark - Protocol

- (void)copyValueForWeightButton{
    
    // if it is not the reference button and copying is active, then copy the value
    
    if (!_isReferenceForCopying && _copyingActive){
        
        // button appearance
        
        NSNumber *copyNumber = [NSNumber numberWithFloat: _valueToCopy];
        NSString *weightText = [NSString stringWithFormat: @"%@ lbs", [copyNumber stringValue]];
        [self.weightButton setTitle: weightText
                           forState: UIControlStateNormal];
        
        [self giveButtonCopyingAppearance: self.weightButton];
        
        self.weightButton.layer.opacity = 1.0;
        
        // core data
        
        TJBTargetUnit *tu = [self targetUnitCorrespondingToVC];
        tu.weightTarget = _valueToCopy;
        tu.weightIsNull = NO;
        
//        self.chainTemplate.weightArrays[[self.exerciseIndex intValue]].numbers[[self.roundIndex intValue]].value = _valueToCopy;
//        self.chainTemplate.weightArrays[[self.exerciseIndex intValue]].numbers[[self.roundIndex intValue]].isDefaultObject = NO;
        
        [[CoreDataController singleton] saveContext];
        
    }
    
}

- (void)copyValueForRepsButton{
    
    // if it is not the reference button and copying is active, then copy the value
    
    if (!_isReferenceForCopying && _copyingActive){
        
        // button appearance
        
        NSNumber *copyNumber = [NSNumber numberWithFloat: _valueToCopy];
        NSString *repsText = [NSString stringWithFormat: @"%@ reps", [copyNumber stringValue]];
        [self.repsButton setTitle: repsText
                           forState: UIControlStateNormal];
        
        [self giveButtonCopyingAppearance: self.repsButton];
        
        self.repsButton.layer.opacity = 1.0;
        
        // core data
        
        TJBTargetUnit *tu = [self targetUnitCorrespondingToVC];
        tu.repsTarget = _valueToCopy;
        tu.repsIsNull = NO;

        [[CoreDataController singleton] saveContext];
        
    }
    
}

- (void)copyValueForRestButton{
    
    // if it is not the reference button and copying is active, then copy the value
    
    if (!_isReferenceForCopying && _copyingActive){
        
        // button appearance
        
        NSString *formattedTime = [[TJBStopwatch singleton] minutesAndSecondsStringFromNumberOfSeconds: (int)_valueToCopy];
        NSString *restText = [NSString stringWithFormat: @"%@ rest", formattedTime];
        [self.restButton setTitle: restText
                         forState: UIControlStateNormal];
        
        [self giveButtonCopyingAppearance: self.restButton];
        
        self.restButton.layer.opacity = 1.0;
        
        // core data
        
        TJBTargetUnit *tu = [self targetUnitCorrespondingToVC];
        tu.trailingRestTarget = _valueToCopy;
        tu.trailingRestIsNull = NO;
        
        [[CoreDataController singleton] saveContext];
        
    }
    
}

- (void)activeCopyingStateForNumber:(float)number copyInputType:(TJBCopyInputType)copyInputType{
    
    // change the state variables accordingly
    
    _copyingActive = YES;
    _valueToCopy = number;
    _copyInputType = copyInputType;
    
    // change the button appearance.  Simply give the button a lesser opacity if it is not the reference button
    
    UIButton *button;
    
    switch (copyInputType) {
        case CopyWeightType:
            button = self.weightButton;
            break;
            
        case CopyRepsType:
            button = self.repsButton;
            break;
            
        case CopyRestType:
            button = self.restButton;
            break;
            
        default:
            break;
    }
    
    if (!_isReferenceForCopying){
        
        button.layer.opacity = .25;
        
    }
    
}

- (void)deactivateCopyingState{
    
    // button appearance is determined by whether or not the button corresponds to a default value
    
    BOOL valueNotYetSelected;
    UIButton *button;
    TJBTargetUnit *tu = [self targetUnitCorrespondingToVC];
    
    switch (_copyInputType) {
        case CopyWeightType:
            valueNotYetSelected = tu.weightIsNull;
            button = self.weightButton;
            break;
            
        case CopyRepsType:
            valueNotYetSelected = tu.repsIsNull;
            button = self.repsButton;
            break;
            
        case CopyRestType:
            valueNotYetSelected = tu.trailingRestIsNull;
            button = self.restButton;
            break;
            
        default:
            break;
    }
    
    if (valueNotYetSelected){
        
        button.backgroundColor = [[TJBAestheticsController singleton] yellowNotebookColor];
        [button setTitleColor: [UIColor whiteColor]
                            forState: UIControlStateNormal];
        
    } else{
        
        button.backgroundColor = [UIColor clearColor];
        [button setTitleColor: [[TJBAestheticsController singleton] paleLightBlueColor]
                     forState: UIControlStateNormal];
        
    }
    
    button.layer.opacity = 1.0;
    
    // change state variables accordingly
    
    _copyingActive = NO;
    _valueToCopy = -1;
    _isReferenceForCopying = NO;
    
}

#pragma mark - Convenience

- (TJBTargetUnit *)targetUnitCorrespondingToVC{
    
    return  self.chainTemplate.targetUnitCollections[[self.exerciseIndex intValue]].targetUnits[[self.roundIndex intValue]];
    
}

#pragma mark - Targeting State

- (void)toggleWeightTargetingStateToActive:(BOOL)targetingStateActive{
    
    if (targetingStateActive == YES){
        
        self.weightButton.hidden = NO;
        
    } else{
        
        self.weightButton.hidden = YES;
        
    }
    
    [self updateChainTemplateForSwitchType: WeightSwitch
                               isTargeting: targetingStateActive];
    
}

- (void)toggleRepsTargetingStateToActive:(BOOL)targetingStateActive{
    
    if (targetingStateActive == YES){
        
        self.repsButton.hidden = NO;
        
    } else{
        
        self.repsButton.hidden = YES;
        
    }
    
    [self updateChainTemplateForSwitchType: RepsSwitch
                               isTargeting: targetingStateActive];
    
}

- (void)toggleTrailingRestTargetingStateToActive:(BOOL)targetingStateActive{
    
    if (targetingStateActive == YES){
        
        self.restButton.hidden = NO;
        
    } else{
        
        self.restButton.hidden = YES;
        
    }
    
    [self updateChainTemplateForSwitchType: TrailingRestSwitch
                               isTargeting: targetingStateActive];
    
}

- (void)updateChainTemplateForSwitchType:(TJBSwitchType)switchType isTargeting:(BOOL)isTargeting{
    
    TJBTargetUnit *relevantTU = self.chainTemplate.targetUnitCollections[[self.exerciseIndex intValue]].targetUnits[[self.roundIndex intValue]];
    
    switch (switchType) {
        case WeightSwitch:
            relevantTU.isTargetingWeight = isTargeting;
            break;
            
        case RepsSwitch:
            relevantTU.isTargetingReps = isTargeting;
            
        case TrailingRestSwitch:
            relevantTU.isTargetingTrailingRest = isTargeting;
            
        default:
            break;
    }
    
    [[CoreDataController singleton] saveContext];
    
}

@end












































