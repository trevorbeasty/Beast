//
//  TJBRealizedSetCollectionCell.m
//  Beast
//
//  Created by Trevor Beasty on 2/23/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBRealizedSetCollectionCell.h"

// core data

#import "CoreDataController.h"

// stopwatch

#import "TJBStopwatch.h"

@interface TJBRealizedSetCollectionCell ()

// IBOutlet

@property (weak, nonatomic) IBOutlet UILabel *numberLabel;
@property (weak, nonatomic) IBOutlet UIStackView *contentStackView;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;

// core

@property (strong) NSArray<TJBRealizedSet *> *realizedSetCollection;
@property (strong) NSNumber *finalRest;

@end

@implementation TJBRealizedSetCollectionCell

- (void)clearExistingEntries{
    
    ////  clear the stack view arranged subviews
    
    NSArray *views = self.contentStackView.arrangedSubviews;
    
    for (UIView *view in views){
        
        [self.contentStackView removeArrangedSubview: view];
        [view removeFromSuperview];
        
    }
    
    
}

- (void)configureWithRealizedSetCollection:(NSArray<TJBRealizedSet *> *)realizedSetColleection number:(NSNumber *)number finalRest:(NSNumber *)finalRest referenceIndexPath:(NSIndexPath *)path{
    
    self.referenceIndexPath = path;
    
    //// this cell will be dynamically sized, showing the chain name in the main label and stacking another label for every exercise in the chain
    
    self.realizedSetCollection = realizedSetColleection;
    self.finalRest = finalRest;
    
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    [self configureViewAesthetics];
    
    // configure label display info
    
    NSString *numberText = [NSString stringWithFormat: @"%@. %@",
                            [number stringValue],
                            self.realizedSetCollection[0].exercise.name];
    self.numberLabel.text = numberText;
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    df.dateStyle = NSDateFormatterNoStyle;;
    df.timeStyle = NSDateFormatterShortStyle;;
    self.dateLabel.text = [df stringFromDate: realizedSetColleection[0].endDate];
    
    //// configure the stack view.  For every exercise, create a UILabel and configure it before adding it to the stack view
    
    NSInteger numSets = self.realizedSetCollection.count;
    
    for (int i = 0; i < numSets; i++){
        
        UIView *iterativeView = [self viewForIndex: i];
        
        [self.contentStackView addArrangedSubview: iterativeView];
        
    }
    
    return;
    
    
    
}

- (void)configureViewAesthetics{
    
    self.contentView.backgroundColor = [UIColor clearColor];
    
    // main label
    
    NSArray *labels = @[self.numberLabel, self.dateLabel];
    for (UILabel *label in labels){
        
        label.textColor = [UIColor blackColor];
        label.backgroundColor = [UIColor clearColor];
        label.font = [UIFont boldSystemFontOfSize: 15.0];
        
    }
    
    self.dateLabel.font = [UIFont systemFontOfSize: 10.0];
    
}


- (UIView *)viewForIndex:(int)index{
    
    TJBRealizedSet *realizedSet = self.realizedSetCollection[index];
    
    //// create the exercise name subview, which will have two labels - one for a number and one for a name
    
    UIView *view = [[UIView alloc] init];
    
    UILabel *weightLabel = [[UILabel alloc] init];
    UILabel *repsLabel = [[UILabel alloc] init];
    UILabel *restLabel = [[UILabel alloc] init];
    
    float weight = realizedSet.weight;
    int reps = realizedSet.reps;
    
    NSString *weightString = [NSString stringWithFormat: @"%.01f lbs", weight];
    NSString *repsString = [NSString stringWithFormat: @"%d reps", reps];
    
    
    weightLabel.text = weightString;
    repsLabel.text = repsString;
    
    // rest string
    
    NSString *restText;
    
    // first, see if this is the last set of the collection.  If so, the 'finalRest' property must be used
    
    if (index < self.realizedSetCollection.count - 1){
        
        NSDate *currentSetEndDate;
        NSDate *nextSetBeginDate;
        
        if (realizedSet.recordedEndDate){
            currentSetEndDate = realizedSet.endDate;
        } else{
            currentSetEndDate = nil;
        }
        
        if (self.realizedSetCollection[index + 1].recordedBeginDate){
            nextSetBeginDate = self.realizedSetCollection[index+1].beginDate;
        } else{
            nextSetBeginDate = nil;
        }
        
        // if both date are not nil, then calculate the rest
        
        if (currentSetEndDate && nextSetBeginDate){
            
            float timeDiff = [nextSetBeginDate timeIntervalSinceDate: currentSetEndDate];
            restText = [NSString stringWithFormat: @"%@ rest", [[TJBStopwatch singleton] minutesAndSecondsStringFromNumberOfSeconds: (int)timeDiff]];
            restLabel.text = restText;
            
        } else{
            
            restLabel.text = @"X rest";
            
        }
        
    } else{
        
        // use the final rest property if there is one
        
        if (self.finalRest){
            
            restText = [NSString stringWithFormat: @"%@ rest", [[TJBStopwatch singleton] minutesAndSecondsStringFromNumberOfSeconds: [self.finalRest intValue]]];
            restLabel.text = restText;
            
        } else{
            
            restLabel.text = @"";
            
        }
        
    }
    
    // aesthetics and layout constraints
    
    NSArray *labels = @[weightLabel,
                        repsLabel,
                        restLabel];
    
    for (UILabel *label in labels){
        
        label.translatesAutoresizingMaskIntoConstraints = NO;
        label.backgroundColor = [UIColor clearColor];
        
        [view addSubview: label];
        
        [label setTextColor: [UIColor blackColor]];
        [label setFont: [UIFont systemFontOfSize: 15.0]];
        label.textAlignment = NSTextAlignmentLeft;
        
    }
    
    NSDictionary *constraintMapping = [NSDictionary dictionaryWithObjects: @[weightLabel, repsLabel, restLabel]
                                                                  forKeys: @[@"weightLabel", @"repsLabel", @"restLabel"]];
    
    NSString *horizontal1 = @"H:|-32-[weightLabel]-0-[repsLabel(==weightLabel)]-0-[restLabel(==weightLabel)]-0-|";
    
    NSArray *horizontalConstraints1 = [NSLayoutConstraint constraintsWithVisualFormat: horizontal1
                                                                              options: 0
                                                                              metrics: nil
                                                                                views: constraintMapping];
    
    NSString *vertical1 = @"V:|-0-[restLabel]-0-|";
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

+ (float)suggestedCellHeightForRealizedSetCollection:(NSArray<TJBRealizedSet *> *)realizedSetCollection{
    
    //// must manually configure the inputs as the xib is altered
    
    float numberOfRows = (float)realizedSetCollection.count;
    float titleHeight = 20.0;
    float spacing = 8.0;
    float error = 8.0;
    
    return (numberOfRows + 1.0) * titleHeight + spacing + error;
    
}



@end

























