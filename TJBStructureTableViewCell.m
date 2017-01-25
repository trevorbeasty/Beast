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

@interface TJBStructureTableViewCell ()


@property (weak, nonatomic) IBOutlet UIStackView *stackView;


@end

@implementation TJBStructureTableViewCell

- (void)configureWithChainTemplate:(TJBChainTemplate *)chainTemplate{
    
    //// this cell will be dynamically sized, showing the chain name in the main label and stacking another label for every exercise in the chain
    
    // configure the chain name label
    
    self.chainNameLabel.text = chainTemplate.name;
    
    //// configure the stack view.  For every exercise, create a UILabel and configure it before adding it to the stack view
    
    int numExercises = chainTemplate.numberOfExercises;
    
    for (int i = 0; i < numExercises; i++){
        
        UILabel *dynamicLabel = [[UILabel alloc] init];
        
        NSString *labelText = [NSString stringWithFormat: @"%d. %@",
                               i,
                               chainTemplate.exercises[i].name];
        
        dynamicLabel.text = labelText;
        
        [self.stackView addArrangedSubview: dynamicLabel];
        
    }
    
    return;
    
    
    
}


@end
