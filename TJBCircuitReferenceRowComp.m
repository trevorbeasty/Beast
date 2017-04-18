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
    
    // state
    
//    TJBRoutineReferenceMode _activeMode;
    
}

// core

@property (nonatomic, strong) NSNumber *exerciseIndex;
@property (nonatomic, strong) NSNumber *roundIndex;

@property (nonatomic, strong) TJBRealizedChain *realizedChain;

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

- (instancetype)initWithRealizedChain:(TJBRealizedChain *)realizedChain exerciseIndex:(int)exerciseIndex roundIndex:(int)roundIndex{
    
    self = [super init];
    
    self.exerciseIndex = [NSNumber numberWithInt: exerciseIndex];
    self.roundIndex = [NSNumber numberWithInt: roundIndex];
    self.realizedChain = realizedChain;
    
    // staying current with user input
    
    [self registerForCoreDataNotification];
    
    // state
    
//    _activeMode = EditingMode;
    
    return self;
    
}

- (void)registerForCoreDataNotification{
    
    // this class will take it upon itself to refresh it display data when core data is updated
    // can refine later for improved performence (iterative updates / updates only for specific situations)
    
    [[NSNotificationCenter defaultCenter] addObserver: self
                                             selector: @selector(coreDataDidSave)
                                                 name: NSManagedObjectContextDidSaveNotification
                                               object: [[CoreDataController singleton] moc]];
    
}

#pragma mark - View Life Cycle

- (void)viewDidLoad{
    
    [self configureViewAesthetics];
    
    [self configureViewForProgressMode];
    
    // round label text
    
    NSNumber *roundNumber = @([self.roundIndex intValue] + 1);
    
    self.roundLabel.text = [NSString stringWithFormat: @"Round %@", [roundNumber stringValue]];
    
}

- (void)configureViewAesthetics{
    
    // meta view
    
    self.view.backgroundColor = [UIColor clearColor];
    
    // round label
    
    self.roundLabel.backgroundColor = [UIColor clearColor];
    self.roundLabel.textColor = [UIColor blackColor];
    self.roundLabel.font = [UIFont boldSystemFontOfSize: 15];
    self.roundLabel.layer.opacity = 1.0;
    
    // buttons
    
    NSArray *buttons = @[self.weightButton,
                         self.repsButton,
                         self.restButton];
    for (UIButton *button in buttons){
        
        button.backgroundColor = [UIColor clearColor];
        [button setTitleColor: [UIColor blackColor]
                     forState: UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize: 15.0];
        
        button.layer.masksToBounds = YES;
        button.layer.cornerRadius = 8.0;
        
    }
    
    
    
}


#pragma mark - Notifications

- (void)coreDataDidSave{
    
    // have the controller refresh its view data every time core data saves
    
//    [self activateMode: _activeMode];
    
}

#pragma mark - Modes

- (void)configureViewForProgressMode{
    
    // state
    
//    _activeMode = ProgressMode;
    
    // buttons
    
    NSArray *buttons = @[self.weightButton,
                         self.repsButton,
                         self.restButton];
    
    // aesthetis and functionality
    
    for (UIButton *b in buttons){
        
        b.enabled = NO;
        
        b.backgroundColor = [UIColor clearColor];
        [b setTitleColor: [UIColor blackColor]
                forState: UIControlStateNormal];
        
        [self getRidOfActiveButtonEffects: b];
        
    }
    
    // must first gather all of the appropriate data and then format it appropriately
    
    TJBChainTemplate *chainTemplate = self.realizedChain.chainTemplate;
    
    int exerciseInd = [self.exerciseIndex intValue];
    int roundInd = [self.roundIndex intValue];
    
    BOOL instanceHasOccurred = [TJBAssortedUtilities indiceWithExerciseIndex: exerciseInd
                                                                  roundIndex: roundInd
                                             isPriorToReferenceExerciseIndex: self.realizedChain.firstIncompleteExerciseIndex
                                                         referenceRoundIndex: self.realizedChain.firstIncompleteRoundIndex];
    
    NSNumber *nextRoundIndex;
    NSNumber *nextExerciseIndex;
    BOOL nextSetIsWithinIndiceRange = [TJBAssortedUtilities nextIndiceValuesForCurrentExerciseIndex: exerciseInd
                                                                                  currentRoundIndex: roundInd
                                                                                   maxExerciseIndex: chainTemplate.numberOfExercises - 1
                                                                                      maxRoundIndex: chainTemplate.numberOfRounds - 1
                                                                             exerciseIndexReference: &nextExerciseIndex
                                                                                roundIndexReference: &nextRoundIndex];
    BOOL nextSetHasOccurred = [TJBAssortedUtilities indiceWithExerciseIndex: [nextExerciseIndex intValue]
                                                                 roundIndex: [nextRoundIndex intValue]
                                            isPriorToReferenceExerciseIndex: self.realizedChain.firstIncompleteExerciseIndex
                                                        referenceRoundIndex: self.realizedChain.firstIncompleteRoundIndex];

    // weight and reps
    
    if (instanceHasOccurred){

        [self.weightButton setTitle: [self realizedWeightString]
                           forState: UIControlStateNormal];
        
        [self.repsButton setTitle: [self realizedRepsString]
                         forState: UIControlStateNormal];
        
    } else{
        
        [self.weightButton setTitle: @""
                           forState: UIControlStateNormal];
        
        [self.repsButton setTitle: @""
                         forState: UIControlStateNormal];
        
    }

    // rest target - will show the target rest time if the next set has been completed
    
    if (nextSetHasOccurred && nextSetIsWithinIndiceRange){
        
        [self.restButton setTitle: [self targetRestString]
                         forState: UIControlStateNormal];
        
    } else{
        
        [self.restButton setTitle: @""
                         forState: UIControlStateNormal];
        
    }
    
}

//- (void)configureViewForTargetsMode{
//    
//    // state
//    
//    _activeMode = TargetsMode;
//    
//    // buttons
//    
//    NSArray *buttons = @[self.weightButton,
//                         self.repsButton,
//                         self.restButton];
//    for (UIButton *button in buttons){
//        
//        button.enabled = NO;
//        
//    }
//    
//    // aesthetis and functionality
//    
//    for (UIButton *b in buttons){
//        
//        b.enabled = NO;
//        
//        b.backgroundColor = [UIColor clearColor];
//        [b setTitleColor: [UIColor blackColor]
//                forState: UIControlStateNormal];
//        
//        [self getRidOfActiveButtonEffects: b];
//        
//    }
//    
//    // must first gather all of the appropriate data and then format it appropriately
//    
//    int exerciseInd = [self.exerciseIndex intValue];
//    int roundInd = [self.roundIndex intValue];
//    
//    // targets
//    
//    TJBChainTemplate *chainTemplate = self.realizedChain.chainTemplate;
//    
//    // only grab targets if the type is being targeted, otherwise leave them as nil
//    
//    NSNumber *weightTarget;
//    NSNumber *repsTarget;
//    
//    TJBTargetUnit *tu = chainTemplate.targetUnitCollections[exerciseInd].targetUnits[roundInd];
//    
//    if (tu.isTargetingWeight){
//        weightTarget = [NSNumber numberWithFloat: tu.weightTarget];
//    }
//    
//    if (tu.isTargetingReps){
//        repsTarget = [NSNumber numberWithFloat: tu.repsTarget];
//    }
//    
//    // weight
//    
//    if (tu.isTargetingWeight){
//        
//        NSString *weightString = [NSString stringWithFormat: @"%@ lbs", [weightTarget stringValue]];
//        
//        [self.weightButton setTitle: weightString
//                           forState: UIControlStateNormal];
//        
//    } else{
//        
//        [self.weightButton setTitle: @"X"
//                           forState: UIControlStateNormal];
//        
//    }
//    
//    // reps
//    
//    if (tu.isTargetingReps){
//        
//        NSString *repsString = [NSString stringWithFormat: @"%@ reps", [repsTarget stringValue]];
//        
//        [self.repsButton setTitle: repsString
//                         forState: UIControlStateNormal];
//        
//    } else{
//        
//        [self.repsButton setTitle: @"X"
//                         forState: UIControlStateNormal];
//        
//    }
//    
//    // rest
//    
//    [self.restButton setTitle: [self targetRestString]
//                     forState: UIControlStateNormal];
//    
//    
//}

- (void)getRidOfActiveButtonEffects:(UIButton *)button{
    
    CALayer *buttLayer = button.layer;
    buttLayer.masksToBounds = NO;
    buttLayer.borderWidth = 0.0;
    
}


//
//- (void)configureViewForEditingMode{
//    
//    // state
//    
//    _activeMode = EditingMode;
//    
//    // aesthetics and functionality
//    
//    int exerciseInd = [self.exerciseIndex intValue];
//    int roundInd = [self.roundIndex intValue];
//    
//    BOOL setHasOccurred = [TJBAssortedUtilities indiceWithExerciseIndex: exerciseInd
//                                                             roundIndex: roundInd
//                                        isPriorToReferenceExerciseIndex: self.realizedChain.firstIncompleteExerciseIndex
//                                                    referenceRoundIndex: self.realizedChain.firstIncompleteRoundIndex];
//    
//    NSArray *buttons = @[self.weightButton,
//                         self.repsButton];
//    
//    // if the set has actually occurred, then give it an active button appearance and enable it.  If not, simply give it a blank text string
//    
//    if (setHasOccurred){
//        
//        for (UIButton *button in buttons){
//            
//            button.backgroundColor = [UIColor clearColor];
//            [button setTitleColor: [UIColor blackColor]
//                         forState: UIControlStateNormal];
//            button.enabled = YES;
//            
//            CALayer *buttLayer = button.layer;
//            buttLayer.masksToBounds = YES;
//            buttLayer.cornerRadius = 22;
//            buttLayer.borderWidth = 1.0;
//            buttLayer.borderColor = [UIColor blackColor].CGColor;
//            
//        }
//        
//    } else{
//        
//        for (UIButton *button in buttons){
//            
//            button.enabled = NO;
//            [button setTitle: @""
//                    forState: UIControlStateNormal];\
//            
//        }
//        
//    }
//    
//    // display data
//    // if the set has occurred, then fill in the appropriate data
//    
//    if (setHasOccurred){
//        
//        [self.weightButton setTitle: [self realizedWeightString]
//                           forState: UIControlStateNormal];
//        
//        [self.repsButton setTitle: [self realizedRepsString]
//                         forState: UIControlStateNormal];
//        
//    } else{
//        
//        for (UIButton *button in buttons){
//            
//            [button setTitle: @""
//                    forState: UIControlStateNormal];
//            
//        }
//        
//    }
//    
//    // the user cannot edit rest times.  Simply show a blank string as the rest button title
//    
//    [self.restButton setTitle: @""
//                     forState: UIControlStateNormal];
//    
//}

#pragma mark - Convenience

- (NSString *)displayStringForRealizedNumber:(NSNumber *)realizedNumber targetNumber:(NSNumber *)targetNumber realizedNumberExists:(BOOL)realizedNumberExists targetNumberExists:(BOOL)targetNumberExists isTimeType:(BOOL)isTimeType{
    
    if (isTimeType){
        
        NSString *realizedTime = [[TJBStopwatch singleton] minutesAndSecondsStringFromNumberOfSeconds: [realizedNumber intValue]];
        NSString *targetTime = [[TJBStopwatch singleton] minutesAndSecondsStringFromNumberOfSeconds: [targetNumber intValue]];
        
        if (realizedNumberExists && targetNumberExists){
            
            return [NSString stringWithFormat: @"%@ / %@", realizedTime, targetTime];
            
        } else if (!realizedNumberExists && targetNumberExists){
            
            return [NSString stringWithFormat: @"X / %@", targetTime];
            
        } else if (realizedNumberExists & !targetNumberExists){
            
            return [NSString stringWithFormat: @"%@ / X", realizedTime];
            
        } else{
            
            return [NSString stringWithFormat: @"X / X"];
            
        }
        
    } else{
        
        if (realizedNumberExists && targetNumberExists){
            
            return [NSString stringWithFormat: @"%@ / %@", [realizedNumber stringValue], [targetNumber stringValue]];
            
        } else if (!realizedNumberExists && targetNumberExists){
            
            return [NSString stringWithFormat: @"X / %@", [targetNumber stringValue]];
            
        } else if (realizedNumberExists & !targetNumberExists){
            
            return [NSString stringWithFormat: @"%@ / X", [realizedNumber stringValue]];
            
        } else{
            
            return [NSString stringWithFormat: @"X / X"];
            
        }
        
    }
    
}

- (TJBTargetUnit *)targetUnitForController{
    
    return self.realizedChain.chainTemplate.targetUnitCollections[[self.exerciseIndex intValue]].targetUnits[[self.roundIndex intValue]];
    
}

- (NSString *)realizedWeightString{
    
    NSNumber *weight = [NSNumber numberWithFloat: [self realizedSetForController].submittedWeight];
    
    return [NSString stringWithFormat: @"%@ lbs", [weight stringValue]];
    
}

- (NSString *)realizedRepsString{
    
    NSNumber *reps = [NSNumber numberWithFloat: [self realizedSetForController].submittedReps];
    
    return [NSString stringWithFormat: @"%@ reps", [reps stringValue]];
    
}

- (NSString *)targetRestString{
    
    float rest;
    TJBTargetUnit *tu = [self targetUnitForController];
    
    if (tu.isTargetingTrailingRest){
        
        rest = tu.trailingRestTarget;
        
        NSString *formattedRest = [[TJBStopwatch singleton] minutesAndSecondsStringFromNumberOfSeconds: (int)rest];
        
        return [NSString stringWithFormat: @"%@ rest", formattedRest];
        
    } else{
        
        return @"";
        
    }
    

    
}

#pragma mark - Class API

//- (void)activateMode:(TJBRoutineReferenceMode)mode{
//    
//    switch (mode) {
//        case EditingMode:
//            [self configureViewForEditingMode];
//            break;
//            
//        case ProgressMode:
//            [self configureViewForProgressMode];
//            break;
//            
//        case TargetsMode:
//            [self configureViewForTargetsMode];
//            break;
//            
//        default:
//            break;
//    
//    }
//    
//}

#pragma mark - Target Action

- (TJBRealizedSet *)realizedSetForController{
    
    return self.realizedChain.realizedSetCollections[[self.exerciseIndex intValue]].realizedSets[[self.roundIndex intValue]];
    
}

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
        
        // reload view data
        
//        [self activateMode: _activeMode];
        
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
        
        // reload view data
        
//        [self activateMode: _activeMode];
//        [self.view setNeedsDisplay];
        
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






























































