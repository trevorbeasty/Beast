//
//  TJBWeightRepsSelectionVC.m
//  Beast
//
//  Created by Trevor Beasty on 2/4/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBWeightRepsSelectionVC.h"

@interface TJBWeightRepsSelectionVC () <UICollectionViewDelegate, UICollectionViewDataSource>

// IBOutlet

@property (weak, nonatomic) IBOutlet UICollectionView *weightCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *repsCollectionView;
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UISegmentedControl *weightSegmentedControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *repsSegmentedControl;

// state

@property (nonatomic, strong) NSNumber *weightSelectedCellIndex;
@property (nonatomic, strong) NSNumber *repsSelectedCellIndex;

// callback


@end

@implementation TJBWeightRepsSelectionVC

#pragma mark - View Life Cycle

- (void)viewDidLoad{
    
    [super viewDidLoad];
    
    [self configureCollectionViews];
    
}

- (void)configureCollectionViews{
    
    // weight
    
    UINib *cell = [UINib nibWithNibName: @"TJBWeightRepsSelectionCell"
                                 bundle: nil];
    
    [self.weightCollectionView registerNib: cell
                forCellWithReuseIdentifier: @"TJBWeightRepsSelectionCell"];
    
    // reps
    
    [self.repsCollectionView registerNib: cell
              forCellWithReuseIdentifier: @"TJBWeightRepsSelectionCell"];
    
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    
    return 1;
    
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    
    return 1000;
    
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    TJBBasicCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: reuseIdentifier
                                                                                 forIndexPath: indexPath];
    
    NSNumber *cellNumber = [NSNumber numberWithFloat: indexPath.item * [self.numberMultiple floatValue]];
    
    if (_numberTypeIdentifier == RestType)
    {
        cell.label.text = [[TJBStopwatch singleton] minutesAndSecondsStringFromNumberOfSeconds: [cellNumber intValue]];
    }
    else
    {
        cell.label.text = [cellNumber stringValue];
    }
    
    cell.label.layer.masksToBounds = YES;
    cell.label.layer.cornerRadius = 8.0;
    cell.backgroundColor = [UIColor clearColor];
    
    TJBAestheticsController *aesthetics = [TJBAestheticsController singleton];
    cell.label.backgroundColor = [aesthetics buttonBackgroundColor];
    [cell.label setTextColor: [aesthetics buttonTextColor]];
    
    cell.layer.opacity = .75;
    
    cell.label.font = [UIFont systemFontOfSize: 20.0];
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    // if there is a previously selected cell, change its attributes accordingly
    if (self.lastSelectedCell){
        self.lastSelectedCell.layer.opacity = .75;
        self.lastSelectedCell.label.backgroundColor = [[TJBAestheticsController singleton] buttonBackgroundColor];
    }
    
    // for state restoration of currently highlighted cell
    self.highlightedCellPath = indexPath;
    
    // change the attributes of the newly selected cell
    TJBBasicCollectionViewCell *selectedCell = (TJBBasicCollectionViewCell *)[self.collectionView cellForItemAtIndexPath: indexPath];
    [self configureCellForSelectedState: selectedCell];
    
    // update the lastSelectedCell property to point to the newly selected cell
    self.lastSelectedCell = selectedCell;
    
}

- (void)configureCellForSelectedState:(TJBBasicCollectionViewCell *)cell{
    
    cell.layer.opacity = 1;
    cell.label.backgroundColor = [UIColor redColor];
    
}



@end
