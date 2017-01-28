//
//  TJBRealizedChainCell.m
//  Beast
//
//  Created by Trevor Beasty on 1/27/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBRealizedChainCell.h"

// core data

#import "CoreDataController.h"

// aesthetics

#import "TJBAestheticsController.h"

@interface TJBRealizedChainCell ()

// IBOutlet

@property (weak, nonatomic) IBOutlet UILabel *chainNameLabel;
@property (weak, nonatomic) IBOutlet UIStackView *stackView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *numberLabel;



@end

@implementation TJBRealizedChainCell

- (void)clearExistingEntries{
    
    ////  clear the stack view arranged subviews
    
    NSArray *views = self.stackView.arrangedSubviews;
    
    for (UIView *view in views){
        
        [self.stackView removeArrangedSubview: view];
        [view removeFromSuperview];
        
    }
    
    
}

- (void)configureWithRealizedChain:(TJBRealizedChain *)realizedChain number:(NSNumber *)number{
    
    //// this cell will be dynamically sized, showing the chain name in the main label and stacking another label for every exercise in the chain
    
    TJBChainTemplate *chainTemplate = realizedChain.chainTemplate;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self configureViewAesthetics];
    
    // configure the chain name label
    
    self.numberLabel.text = [number stringValue];
    
    NSString *title = [NSString stringWithFormat: @"%@",
                       chainTemplate.name];
    
    self.chainNameLabel.text = title;
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateStyle = NSDateFormatterNoStyle;
    df.timeStyle = NSDateFormatterShortStyle;
    self.dateLabel.text = [df stringFromDate: realizedChain.dateCreated];
    
    //// configure the stack view.  For every exercise, create a UILabel and configure it before adding it to the stack view
    
    int numExercises = chainTemplate.numberOfExercises;
    
    for (int i = 0; i < numExercises; i++){
        
        UILabel *iterativeView = [[UILabel alloc] init];
        iterativeView.text = chainTemplate.exercises[i].name;
        iterativeView.font = [UIFont systemFontOfSize: 15.0];
        iterativeView.textAlignment = NSTextAlignmentLeft;
        
        [self.stackView addArrangedSubview: iterativeView];
        
    }
    
    return;
    
    
    
}

- (void)configureViewAesthetics{
    
    self.contentView.backgroundColor = [UIColor clearColor];
    
}

- (UIView *)exerciseSubviewWithName:(NSString *)name{
    
    //// create the exercise name subview, which will have two labels - one for a number and one for a name
    
    UIView *view = [[UIView alloc] init];
    
    UILabel *weightLabel = [[UILabel alloc] init];
    UILabel *repsLabel = [[UILabel alloc] init];
    UILabel *nameLabel = [[UILabel alloc] init];
    
    weightLabel.translatesAutoresizingMaskIntoConstraints = NO;
    nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
    repsLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    weightLabel.text = @"135 - 175 lbs";
    repsLabel.text = @"8 - 12 reps";
    nameLabel.text = name;
    
    [view addSubview: weightLabel];
    [view addSubview: repsLabel];
    [view addSubview: nameLabel];
    
    NSArray *labels = @[weightLabel,
                        repsLabel];
    
    for (UILabel *label in labels){
        
        [label setTextColor: [UIColor blackColor]];
        [label setFont: [UIFont systemFontOfSize: 10.0]];
        label.textAlignment = NSTextAlignmentLeft;
        
    }
    
    [weightLabel setTextColor: [UIColor blackColor]];
    [weightLabel setFont: [UIFont systemFontOfSize: 15.0]];
    weightLabel.textAlignment = NSTextAlignmentLeft;
    
    NSDictionary *constraintMapping = [NSDictionary dictionaryWithObjects: @[weightLabel, repsLabel, nameLabel]
                                                                  forKeys: @[@"weightLabel", @"repsLabel", @"nameLabel"]];
    
    NSString *horizontal1 = @"H:|-0-[nameLabel]-4-[weightLabel(==nameLabel)]-4[repsLabel(==nameLabel)-|";
    
    NSArray *horizontalConstraints1 = [NSLayoutConstraint constraintsWithVisualFormat: horizontal1
                                                                              options: 0
                                                                              metrics: nil
                                                                                views: constraintMapping];
    
    NSString *vertical1 = @"V:|-0-[nameLabel]-0-|";
    NSString *vertical2 = @"V:|-0-[weightLabel]-0-|";
    NSString *vertical3 = @"V:|-0-[repsLabel]-0-|";
    
    
    NSArray *verticalConstraints1 = [NSLayoutConstraint constraintsWithVisualFormat: vertical1
                                                                            options: 0
                                                                            metrics: nil
                                                                              views: constraintMapping];
    
    NSArray *verticalConstraints2 = [NSLayoutConstraint constraintsWithVisualFormat: vertical2
                                                                            options: 0
                                                                            metrics: nil
                                                                              views: constraintMapping];
    
    NSArray *verticalConstraints3 = [NSLayoutConstraint constraintsWithVisualFormat: vertical3
                                                                            options: 0
                                                                            metrics: nil
                                                                              views: constraintMapping];
    
    [view addConstraints: horizontalConstraints1];
    [view addConstraints: verticalConstraints1];
    [view addConstraints: verticalConstraints2];
    [view addConstraints: verticalConstraints3];
    
    return view;
}

+ (float)suggestedCellHeightForRealizedChain:(TJBRealizedChain *)realizedChain{
    
    //// must manually configure the inputs as the xib is altered
    
    float numberOfExercises = (float)realizedChain.numberOfExercises;
    float titleHeight = 20.0;
    float spacing = 8.0;
    float error = 16.0;
    
    return (numberOfExercises + 1.0) * titleHeight + spacing + error;
 
}

@end


























