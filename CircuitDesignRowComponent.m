//
//  CircuitDesignRowComponent.m
//  Beast
//
//  Created by Trevor Beasty on 12/15/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import "CircuitDesignRowComponent.h"

@interface CircuitDesignRowComponent ()

@property (weak, nonatomic) IBOutlet UILabel *roundLabel;
@property (weak, nonatomic) IBOutlet UIButton *weightButton;
@property (weak, nonatomic) IBOutlet UIButton *repsButton;
@property (weak, nonatomic) IBOutlet UIButton *restButton;

- (IBAction)didPressWeightButton:(id)sender;
- (IBAction)didPressRepsButton:(id)sender;
- (IBAction)didPressRestButton:(id)sender;



@end

@implementation CircuitDesignRowComponent

#pragma mark - Button Actions


- (IBAction)didPressWeightButton:(id)sender
{
    NSLog(@"weight button pressed");
}

- (IBAction)didPressRepsButton:(id)sender
{
    
}

- (IBAction)didPressRestButton:(id)sender
{
    
}
@end
