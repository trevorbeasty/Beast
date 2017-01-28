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

//- (UIView *)exerciseSubviewWithName:(NSString *)name{
//    
//    //// create the exercise name subview, which will have two labels - one for a number and one for a name
//    
//    UIView *view = [[UIView alloc] init];
//    
//    UILabel *numberLabel = [[UILabel alloc] init];
//    UILabel *nameLabel = [[UILabel alloc] init];
//    
//    numberLabel.translatesAutoresizingMaskIntoConstraints = NO;
//    nameLabel.translatesAutoresizingMaskIntoConstraints = NO;
//    
//    numberLabel.text = [number stringValue];
//    nameLabel.text = name;
//    
//    [view addSubview: numberLabel];
//    [view addSubview: nameLabel];
//    
//    NSArray *labels = @[numberLabel, nameLabel];
//    for (UILabel *label in labels){
//        
//        [label setTextColor: [UIColor blackColor]];
//        [label setFont: [UIFont systemFontOfSize: 15.0]];
//        
//    }
//    
//    NSDictionary *constraintMapping = [NSDictionary dictionaryWithObjects: @[numberLabel, nameLabel]
//                                                                  forKeys: @[@"numberLabel", @"nameLabel"]];
//    
//    NSString *horizontal1 = @"H:|-0-[numberLabel(==20)]-4-[nameLabel]-0-|";
//    
//    NSArray *horizontalConstraints1 = [NSLayoutConstraint constraintsWithVisualFormat: horizontal1
//                                                                              options: 0
//                                                                              metrics: nil
//                                                                                views: constraintMapping];
//    
//    NSString *vertical1 = @"V:|-0-[numberLabel]-0-|";
//    NSString *vertical2 = @"V:|-0-[nameLabel]-0-|";
//    
//    NSArray *verticalConstraints1 = [NSLayoutConstraint constraintsWithVisualFormat: vertical1
//                                                                            options: 0
//                                                                            metrics: nil
//                                                                              views: constraintMapping];
//    
//    NSArray *verticalConstraints2 = [NSLayoutConstraint constraintsWithVisualFormat: vertical2
//                                                                            options: 0
//                                                                            metrics: nil
//                                                                              views: constraintMapping];
//    
//    [view addConstraints: horizontalConstraints1];
//    [view addConstraints: verticalConstraints1];
//    [view addConstraints: verticalConstraints2];
//    
//    return view;
//}


@end


























