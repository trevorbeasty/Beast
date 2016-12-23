//
//  TJBInSetVC.m
//  Beast
//
//  Created by Trevor Beasty on 12/22/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import "TJBInSetVC.h"

#import "TJBStopwatch.h"

@interface TJBInSetVC ()

@property (weak, nonatomic) IBOutlet UILabel *timerLabel;

- (IBAction)didPressSetCompleted:(id)sender;

@end



@implementation TJBInSetVC

#pragma mark - Instantiation

-(void)viewDidLoad
{
    // stopwatch
    
    TJBStopwatch *stopwatch = [TJBStopwatch singleton];
    [stopwatch resetSecondaryStopwatch];
    [stopwatch addSecondaryStopwatchObserver: self.timerLabel];
}

#pragma mark - Button Actions

- (IBAction)didPressSetCompleted:(id)sender
{
    
}


@end
