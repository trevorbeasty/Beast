//
//  TJBStructureTableViewCell.m
//  Beast
//
//  Created by Trevor Beasty on 1/25/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBStructureTableViewCell.h"

// core data

#import "CoreDataController.h"

// aesthetics

#import "TJBAestheticsController.h"

@interface TJBStructureTableViewCell ()

// IBOutlet

@property (weak, nonatomic) IBOutlet UILabel *chainNameLabel;
@property (weak, nonatomic) IBOutlet UIStackView *stackView;
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;



@end

@implementation TJBStructureTableViewCell

- (void)setOverallColor:(UIColor *)color{
    
    self.containerView.backgroundColor = color;
    
}

- (void)clearExistingEntries{
    
    ////  clear the stack view entries
    
    NSArray *views = self.stackView.arrangedSubviews;
    
    for (UIView *view in views){
        
        [self.stackView removeArrangedSubview: view];
        [view removeFromSuperview];
        
    }
    
    
}

- (void)configureWithChainTemplate:(TJBChainTemplate *)chainTemplate date:(NSDate *)date{
    
    //// this cell will be dynamically sized, showing the chain name in the main label and stacking another label for every exercise in the chain
    
    [self configureViewAesthetics];
    
    // configure the chain name label
    
    self.chainNameLabel.text = chainTemplate.name;

    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateFormat = @"MMM d";
    self.dateLabel.text = [df stringFromDate: date];
    
    NSArray *labels = @[self.chainNameLabel, self.dateLabel];
    for (UILabel *label in labels){
        
        [label setTextColor: [UIColor whiteColor]];
        [label setFont: [UIFont boldSystemFontOfSize: 20.0]];
        
    }
    
    //// configure the stack view.  For every exercise, create a UILabel and configure it before adding it to the stack view
    
    int numExercises = chainTemplate.numberOfExercises;
    
    for (int i = 0; i < numExercises; i++){
        
        UIView *iterativeView = [self exerciseNameSubviewWithNumber: [NSNumber numberWithInt: i + 1]
                                                               name: chainTemplate.exercises[i].name];
        
        [self.stackView addArrangedSubview: iterativeView];
        
    }
    
    return;
    
    
    
}

- (void)configureViewAesthetics{
    
    //// configure view aesthetics
    
    // colors
    
    self.containerView.backgroundColor = [[TJBAestheticsController singleton] color1];
    self.contentView.backgroundColor = [UIColor clearColor];
    
    // shapes
    
    CALayer *containerViewLayer = self.containerView.layer;
    containerViewLayer.masksToBounds = YES;
    containerViewLayer.cornerRadius = 4;
    
}

- (UIView *)exerciseNameSubviewWithNumber:(NSNumber *)number name:(NSString *)name{
    
    //// create the exercise name subview, which will have two labels - one for a number and one for a name
    
    UIView *view = [[UIView alloc] init];
    
    UILabel *numberLabel = [[UILabel alloc] init];
    UILabel *nameLabel = [[UILabel alloc] init];
    
    numberLabel.translatesAutoresizingMaskIntoConstraints = NO;
    nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    numberLabel.text = [number stringValue];
    nameLabel.text = name;
    
    [view addSubview: numberLabel];
    [view addSubview: nameLabel];
    
    NSArray *labels = @[numberLabel, nameLabel];
    for (UILabel *label in labels){
        
        [label setTextColor: [UIColor whiteColor]];
        [label setFont: [UIFont systemFontOfSize: 20.0]];
        
    }
    
    NSDictionary *constraintMapping = [NSDictionary dictionaryWithObjects: @[numberLabel, nameLabel]
                                                                  forKeys: @[@"numberLabel", @"nameLabel"]];
    
    NSString *horizontal1 = @"H:|-0-[numberLabel(==20)]-4-[nameLabel]-0-|";
    
    NSArray *horizontalConstraints1 = [NSLayoutConstraint constraintsWithVisualFormat: horizontal1
                                                                              options: 0
                                                                              metrics: nil
                                                                                views: constraintMapping];
    
    NSString *vertical1 = @"V:|-0-[numberLabel]-0-|";
    NSString *vertical2 = @"V:|-0-[nameLabel]-0-|";
    
    NSArray *verticalConstraints1 = [NSLayoutConstraint constraintsWithVisualFormat: vertical1
                                                                            options: 0
                                                                            metrics: nil
                                                                              views: constraintMapping];
    
    NSArray *verticalConstraints2 = [NSLayoutConstraint constraintsWithVisualFormat: vertical2
                                                                            options: 0
                                                                            metrics: nil
                                                                              views: constraintMapping];
    
    [view addConstraints: horizontalConstraints1];
    [view addConstraints: verticalConstraints1];
    [view addConstraints: verticalConstraints2];
    
    return view;
}


@end

























