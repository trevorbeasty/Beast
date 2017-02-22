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
    
    

}

- (IBAction)didPressRepsButton:(id)sender{
    
    
    
}

- (IBAction)didPressRestButton:(id)sender{
    

    
}





@end












































