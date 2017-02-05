//
//  TJBWeightRepsSelectionVC.m
//  Beast
//
//  Created by Trevor Beasty on 2/4/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBWeightRepsSelectionVC.h"

// cells

#import "TJBWeightRepsSelectionCell.h"

// aesthetics

#import "TJBAestheticsController.h"

@interface TJBWeightRepsSelectionVC () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

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
    
    [self configureViewAesthetics];
    
}

- (void)configureViewAesthetics{
    
    // segmented controls
    
    self.weightSegmentedControl.tintColor = [[TJBAestheticsController singleton] blueButtonColor];
    
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
    
    if ([collectionView isEqual: self.weightCollectionView]){
        
        TJBWeightRepsSelectionCell *weightCell = [self.weightCollectionView dequeueReusableCellWithReuseIdentifier: @"TJBWeightRepsSelectionCell"
                                                                                                      forIndexPath: indexPath];
        NSNumber *weightNumber = [NSNumber numberWithFloat: indexPath.row * 2.5];
        
        weightCell.numberLabel.text = [weightNumber stringValue];
        weightCell.backgroundColor = [UIColor whiteColor];
        
        return weightCell;
        
    } else{
        
        TJBWeightRepsSelectionCell *repsCell = [self.repsCollectionView dequeueReusableCellWithReuseIdentifier: @"TJBWeightRepsSelectionCell"
                                                                                                      forIndexPath: indexPath];
        NSNumber *repNumber = [NSNumber numberWithFloat: indexPath.row];
        
        repsCell.numberLabel.text = [repNumber stringValue];
        repsCell.backgroundColor = [UIColor whiteColor];
        
        return repsCell;
        
    }
}

#pragma mark <UICollectionViewDelegate>


#pragma mark - <UICollectionViewDelegateFlowLayout>

static CGFloat const spacing = 8.0;
static float const numberOfCellsPerRow = 2;

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    
    return spacing;
    
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    return UIEdgeInsetsMake(spacing, 0, 0, 0);
    
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    
    return spacing;
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    [self.view layoutIfNeeded];
    
    if ([collectionView isEqual: self.weightCollectionView]){
        
        CGFloat weightCollectionWidth = self.weightCollectionView.frame.size.width;
        
        CGFloat cellWidth = (weightCollectionWidth - (numberOfCellsPerRow -1) * spacing) / numberOfCellsPerRow;
        
        return CGSizeMake(cellWidth, cellWidth);
        
    } else{
        
        CGFloat repsCollectionWidth = self.repsCollectionView.frame.size.width;
        
        CGFloat cellWidth = (repsCollectionWidth - (numberOfCellsPerRow -1) * spacing) / numberOfCellsPerRow;
        
        return CGSizeMake(cellWidth, cellWidth);
        
    }
    
}


@end























