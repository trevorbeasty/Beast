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

@property (weak, nonatomic) IBOutlet UIButton *weightButton;
@property (weak, nonatomic) IBOutlet UIButton *repsButton;
@property (weak, nonatomic) IBOutlet UIButton *restButton;
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
    
    return self;
    
}

#pragma mark - View Life Cycle

- (void)viewDidLoad{
    
    [self viewAesthetics];
    
}

- (void)viewAesthetics{
    
    TJBAestheticsController *aesthetics = [TJBAestheticsController singleton];
    
    // background
    
    self.view.backgroundColor = [UIColor clearColor];
    
    // round label
    
    if (self.chainTemplate.targetsVaryByRound == NO){
        
        self.roundLabel.text = @"All";
        
    } else{
        
        self.roundLabel.text = [NSString stringWithFormat: @"%d", [self.roundIndex intValue] + 1];
        
    }
    
    self.roundLabel.backgroundColor = [UIColor lightGrayColor];
    
    // button appearance
    
    void (^eraseButton)(UIButton *) = ^(UIButton *button){
        button.backgroundColor = [UIColor clearColor];
        [button setTitle: @""
                forState: UIControlStateNormal];
        button.enabled = NO;
    };
    
        
    void (^activeButtonConfiguration)(UIButton *) = ^(UIButton *button){
        
        button.backgroundColor = [aesthetics blueButtonColor];
        [button setTitleColor: [UIColor whiteColor]
                     forState: UIControlStateNormal];
        button.titleLabel.font = [UIFont systemFontOfSize: 15.0];
        
        CALayer *layer = button.layer;
        layer.masksToBounds = YES;
        layer.cornerRadius = 8.0;
        
    };
        
    if (self.chainTemplate.targetingWeight == YES){
            
        activeButtonConfiguration(self.weightButton);
        
    } else{
            
        eraseButton(self.weightButton);
    }
        
    if (self.chainTemplate.targetingReps == YES){
            
        activeButtonConfiguration(self.repsButton);
        
    } else{
            
        eraseButton(self.repsButton);
    }
        
    if (self.chainTemplate.targetingRestTime == YES){
            
        activeButtonConfiguration(self.restButton);
        
    } else{
            
        eraseButton(self.restButton);
    }
        
    
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
        
        self.chainTemplate.weightArrays[exerciseInd].numbers[roundInd].value = [selectedNumber floatValue];
        self.chainTemplate.weightArrays[exerciseInd].numbers[roundInd].isDefaultObject = NO;
        
        [[CoreDataController singleton] saveContext];
        
        // configure the button
        
        self.weightButton.backgroundColor = [UIColor clearColor];
        [self.weightButton setTitleColor: [UIColor blackColor]
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
        
        self.chainTemplate.repsArrays[exerciseInd].numbers[roundInd].value = [selectedNumber floatValue];
        self.chainTemplate.repsArrays[exerciseInd].numbers[roundInd].isDefaultObject = NO;
        
        [[CoreDataController singleton] saveContext];
        
        // configure the button
        
        self.repsButton.backgroundColor = [UIColor clearColor];
        [self.repsButton setTitleColor: [UIColor blackColor]
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
        
        self.chainTemplate.targetRestTimeArrays[exerciseInd].numbers[roundInd].value = [selectedNumber floatValue];
        self.chainTemplate.targetRestTimeArrays[exerciseInd].numbers[roundInd].isDefaultObject = NO;
        
        [[CoreDataController singleton] saveContext];
        
        // configure the button
        
        self.restButton.backgroundColor = [UIColor clearColor];
        [self.restButton setTitleColor: [UIColor blackColor]
                              forState: UIControlStateNormal];
        
        NSString *restText = [[TJBStopwatch singleton] minutesAndSecondsStringFromNumberOfSeconds: [selectedNumber intValue]];
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





@end












































