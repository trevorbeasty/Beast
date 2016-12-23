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

@property (copy) void(^didPressSetCompletedBlock)(void);

@end



@implementation TJBInSetVC

#pragma mark - Instantiation

- (id)initWithDidPressSetCompletedBlock:(void (^)(void))block
{
    self = [super init];
    
    self.didPressSetCompletedBlock = block;
    
    return self;
}

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
    self.didPressSetCompletedBlock();
}


@end
