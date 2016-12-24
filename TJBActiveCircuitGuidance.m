//
//  TJBActiveCircuitGuidance.m
//  Beast
//
//  Created by Trevor Beasty on 12/24/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import "TJBActiveCircuitGuidance.h"

#import "CoreDataController.h"

#import "TJBRepsArray+CoreDataProperties.h"
#import "TJBNumberArray+CoreDataProperties.h"

@interface TJBActiveCircuitGuidance ()

- (IBAction)beginNextSet:(id)sender;

// UI

@property (weak, nonatomic) IBOutlet UIView *containerSubview;


@property (weak, nonatomic) IBOutlet UILabel *nextUpExerciseLabel;
@property (weak, nonatomic) IBOutlet UILabel *weightLabel;
@property (weak, nonatomic) IBOutlet UILabel *repsLabel;
@property (weak, nonatomic) IBOutlet UILabel *remainingRestLabel;

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;

// data

@property (nonatomic, strong) TJBChainTemplate *chainTemplate;

// derived IV's

@property (nonatomic, strong) NSNumber *numberOfExercises;
@property (nonatomic, strong) NSNumber *numberOfRounds;




@end

@implementation TJBActiveCircuitGuidance

#pragma mark - Instantiation

- (instancetype)initWithChainTemplate:(TJBChainTemplate *)chainTemplate{
    self = [super init];
    
    // IV's
    
    self.chainTemplate = chainTemplate;
    
    // derived IV's
    
    NSNumber *numberOfExercises = [NSNumber numberWithUnsignedLong: [chainTemplate.exercises count]];
    self.numberOfExercises = numberOfExercises;
    
    TJBRepsArray *repsArray = chainTemplate.repsArrays[0];
    NSNumber *numberOfRounds = [NSNumber numberWithUnsignedLong: [repsArray.numbers count]];
    self.numberOfRounds = numberOfRounds;
    
    return self;
}

#pragma mark - Button Actions

- (IBAction)beginNextSet:(id)sender
{
    
}
@end
