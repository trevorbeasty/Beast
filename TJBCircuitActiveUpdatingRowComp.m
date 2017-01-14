//
//  TJBCircuitActiveUpdatingRowComp.m
//  Beast
//
//  Created by Trevor Beasty on 1/11/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBCircuitActiveUpdatingRowComp.h"

@interface TJBCircuitActiveUpdatingRowComp ()


// core

@property (nonatomic, strong) NSNumber *chainNumber;
@property (nonatomic, strong) NSNumber *roundNumber;
@property (nonatomic, strong) NSNumber *weightData;
@property (nonatomic, strong) NSNumber *repsData;
@property (nonatomic, strong) NSNumber *restData;
@property (nonatomic, strong) NSNumber *setLengthData;
@property (nonatomic, strong) NSNumber *setHasBeenRealized;

// IBOutlet

@property (weak, nonatomic) IBOutlet UIButton *weightButton;
@property (weak, nonatomic) IBOutlet UIButton *repsButton;
@property (weak, nonatomic) IBOutlet UIButton *restButton;
@property (weak, nonatomic) IBOutlet UILabel *roundLabel;
@property (weak, nonatomic) IBOutlet UIButton *setLengthButton;

@end

@implementation TJBCircuitActiveUpdatingRowComp

#pragma mark - Instantiation

- (instancetype)initWithRoundNumber:(NSNumber *)roundNumber chainNumber:(NSNumber *)chainNumber weightData:(NSNumber *)weightData repsData:(NSNumber *)repsData restData:(NSNumber *)restData setLengthData:(NSNumber *)setLengthData setHasBeenRealized:(NSNumber *)setHasBeenRealized{
    
    self = [super init];
    
    self.chainNumber = chainNumber;
    self.roundNumber = roundNumber;
    self.weightData = weightData;
    self.repsData = repsData;
    self.restData = restData;
    self.setLengthData = setLengthData;
    self.setHasBeenRealized = setHasBeenRealized;
    
    return self;
}



#pragma mark - View Life Cycle

- (void)viewDidLoad{
    
    [self configureViewAestheticsAndFunctionality];
    
    [self configureViewData];
}

- (void)configureViewData{
    
    void (^deleteTitle)(UIButton *) = ^(UIButton *button){
        [button setTitle: @""
                forState: UIControlStateNormal];
    };
    
    [self.weightButton setTitle: [self.weightData stringValue]
                       forState: UIControlStateNormal];
    
    [self.repsButton setTitle: [self.repsData stringValue]
                     forState: UIControlStateNormal];
    
    deleteTitle(self.restButton);
    
    [self.setLengthButton setTitle: [self.setLengthData stringValue]
                          forState: UIControlStateNormal];
    
}

- (void)configureViewAestheticsAndFunctionality{
    
    // round label
    

    self.roundLabel.text = [NSString stringWithFormat: @"Round %d", [self.roundNumber intValue]];
    
    // button appearance
    
    NSArray *buttons = @[self.weightButton,
                         self.repsButton,
                         self.restButton,
                         self.setLengthButton];
    
    for (UIButton *button in buttons){
        
        button.backgroundColor = [UIColor whiteColor];
        [button setTitleColor: [UIColor blackColor]
                     forState: UIControlStateNormal];
        button.enabled = NO;
        
    }
}


@end















