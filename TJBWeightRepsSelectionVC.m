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
@property (weak, nonatomic) IBOutlet UIView *collectionViewContainer;
@property (weak, nonatomic) IBOutlet UILabel *weightSelectedValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *repsSelectedValueLabel;

// state

@property (nonatomic, strong) NSIndexPath *weightSelectedCellIndexPath;
@property (nonatomic, strong) NSIndexPath *repsSelectedCellIndexPath;

// callback

@property (nonatomic, copy) CancelBlock cancelBlock;
@property (nonatomic, copy) NumberSelectedBlock numberSelectedBlock;

// core

@property (nonatomic, strong) NSString *navBarTitle;

@end

@implementation TJBWeightRepsSelectionVC

#pragma mark - Instantiation

- (instancetype)initWithTitle:(NSString *)title cancelBlock:(CancelBlock)cancelBlock numberSelectedBlock:(NumberSelectedBlock)numberSelectedBlock{
    
    self = [super init];
    
    self.navBarTitle = title;
    self.cancelBlock = cancelBlock;
    self.numberSelectedBlock = numberSelectedBlock;
    
    return self;
    
}

#pragma mark - View Life Cycle

- (void)viewDidLoad{
    
    [super viewDidLoad];
    
    [self configureCollectionViews];
    
    [self configureViewAesthetics];
    
    [self configureSegmentedControl];
    
    [self configureNavigationBar];
    
}

- (void)configureNavigationBar{
    
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle: self.navBarTitle];
    
    UIBarButtonItem *rightButton = [[UIBarButtonItem alloc] initWithTitle: @"Done"
                                                                    style: UIBarButtonItemStyleDone
                                                                   target: self
                                                                   action: @selector(didPressDone)];
    
    [navItem setRightBarButtonItem: rightButton];
    
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithTitle: @"Cancel"
                                                                   style: UIBarButtonItemStyleDone
                                                                  target: self
                                                                  action: @selector(didPressCancel)];
    
    [navItem setLeftBarButtonItem: leftButton];
    
    [self.navBar setItems: @[navItem]];
    
}

- (void)configureSegmentedControl{
    
    [self.weightSegmentedControl addTarget: self
                                    action: @selector(weightSCValueChanged)
                          forControlEvents: UIControlEventValueChanged];
    
    [self.repsSegmentedControl addTarget: self
                                  action: @selector(repsSCValueChanged)
                        forControlEvents: UIControlEventValueChanged];
    
    self.weightSegmentedControl.selectedSegmentIndex = 1;
    
    self.repsSegmentedControl.selectedSegmentIndex = 1;
    
}


- (void)configureViewAesthetics{
    
    // segmented controls
    
    self.weightSegmentedControl.tintColor = [UIColor whiteColor];
    
    self.repsSegmentedControl.tintColor = [UIColor whiteColor];
    
    // collection view container
    
    self.collectionViewContainer.backgroundColor = [UIColor whiteColor];
    
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
        
        NSNumber *weightNumber = [NSNumber numberWithFloat: indexPath.row * [self weightMultiplier]];
        
        weightCell.numberLabel.text = [weightNumber stringValue];
        weightCell.numberLabel.textColor = [UIColor whiteColor];
        weightCell.numberLabel.font = [UIFont boldSystemFontOfSize: 15.0];
        weightCell.typeLabel.text = @"";
        weightCell.typeLabel.font = [UIFont systemFontOfSize: 15.0];
        
        // the following is done so that a cell remains highlighted if it is selected, scrolled off-screen, and then scrolled back on-screen
        
        weightCell.backgroundColor = [[TJBAestheticsController singleton] blueButtonColor];
        
        if (self.weightSelectedCellIndexPath){
            
            if (self.weightSelectedCellIndexPath.row == indexPath.row){
                
                weightCell.backgroundColor = [UIColor redColor];
                
            }
            
        } 
        
        weightCell.layer.masksToBounds = YES;
        weightCell.layer.cornerRadius = 4.0;
        
        return weightCell;
        
    } else{
        
        TJBWeightRepsSelectionCell *repsCell = [self.repsCollectionView dequeueReusableCellWithReuseIdentifier: @"TJBWeightRepsSelectionCell"
                                                                                                      forIndexPath: indexPath];
        
        NSNumber *repsNumber = [NSNumber numberWithFloat: indexPath.row * [self repsMultiplier]];
        
        repsCell.numberLabel.text = [repsNumber stringValue];
        repsCell.numberLabel.textColor = [UIColor whiteColor];
        repsCell.numberLabel.font = [UIFont boldSystemFontOfSize: 15.0];
        repsCell.typeLabel.text = @"";
        repsCell.typeLabel.font = [UIFont systemFontOfSize: 15.0];
        
        repsCell.backgroundColor = [[TJBAestheticsController singleton] blueButtonColor];
        
        if (self.repsSelectedCellIndexPath){
            
            if (self.repsSelectedCellIndexPath.row == indexPath.row){
                
                repsCell.backgroundColor = [UIColor redColor];
                
            }
            
        }
        
        repsCell.layer.masksToBounds = YES;
        repsCell.layer.cornerRadius = 4.0;
        
        return repsCell;
        
    }
}

- (float)weightMultiplier{
    
    NSInteger weightSCIndex = self.weightSegmentedControl.selectedSegmentIndex;
    
    float returnValue;
    
    switch (weightSCIndex) {
            
        case 0:
            returnValue = 1.0;
            break;
            
        case 1:
            returnValue = 2.5;
            break;
            
        case 2:
            returnValue = 5.0;
            break;
            
        default:
            break;
            
    }
    
    return returnValue;
    
}

- (float)repsMultiplier{
    
    NSInteger repsSCIndex = self.repsSegmentedControl.selectedSegmentIndex;
    
    float returnValue;
    
    switch (repsSCIndex) {
            
        case 0:
            returnValue = 0.5;
            break;
            
        case 1:
            returnValue = 1.0;
            break;
            
        default:
            break;
            
    }
    
    return returnValue;
    
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([collectionView isEqual: self.weightCollectionView]){
        
        if (self.weightSelectedCellIndexPath){
            
            TJBWeightRepsSelectionCell *previousCell = (TJBWeightRepsSelectionCell *)[self.weightCollectionView cellForItemAtIndexPath: self.weightSelectedCellIndexPath];
            
            previousCell.backgroundColor = [[TJBAestheticsController singleton] blueButtonColor];
            
        }
        
        self.weightSelectedCellIndexPath = indexPath;
        
        TJBWeightRepsSelectionCell *currentCell = (TJBWeightRepsSelectionCell *)[self.weightCollectionView cellForItemAtIndexPath: indexPath];
        
        currentCell.backgroundColor = [UIColor redColor];
        
        NSNumber *weight = [NSNumber numberWithFloat: indexPath.row * [self weightMultiplier]];
        self.weightSelectedValueLabel.text = [NSString stringWithFormat: @"%@ lbs", [weight stringValue]];
        
    } else{
        
        if (self.repsSelectedCellIndexPath){
            
            TJBWeightRepsSelectionCell *previousCell = (TJBWeightRepsSelectionCell *)[self.repsCollectionView cellForItemAtIndexPath: self.repsSelectedCellIndexPath];
            
            previousCell.backgroundColor = [[TJBAestheticsController singleton] blueButtonColor];
            
        }
        
        self.repsSelectedCellIndexPath = indexPath;
        
        TJBWeightRepsSelectionCell *currentCell = (TJBWeightRepsSelectionCell *)[self.repsCollectionView cellForItemAtIndexPath: indexPath];
        
        currentCell.backgroundColor = [UIColor redColor];
        
        NSNumber *reps = [NSNumber numberWithFloat: indexPath.row * [self repsMultiplier]];
        self.repsSelectedValueLabel.text = [NSString stringWithFormat: @"%@ reps", [reps stringValue]];
        
    }
    
}


#pragma mark - <UICollectionViewDelegateFlowLayout>

static CGFloat const spacing = 8.0;
static float const numberOfCellsPerRow = 2;

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    
    return spacing;
    
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    return UIEdgeInsetsMake(spacing, spacing, 0, spacing);
    
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    
    return spacing;
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    [self.view layoutIfNeeded];
    
    if ([collectionView isEqual: self.weightCollectionView]){
        
        CGFloat weightCollectionWidth = self.weightCollectionView.frame.size.width;
        
        CGFloat cellWidth = (weightCollectionWidth - (numberOfCellsPerRow -1) * spacing - 2 * spacing) / numberOfCellsPerRow;
        
        return CGSizeMake(cellWidth, cellWidth);
        
    } else{
        
        CGFloat repsCollectionWidth = self.repsCollectionView.frame.size.width;
        
        CGFloat cellWidth = (repsCollectionWidth - (numberOfCellsPerRow -1) * spacing - 2 * spacing) / numberOfCellsPerRow;
        
        return CGSizeMake(cellWidth, cellWidth);
        
    }
    
}

#pragma mark - Segmented Control

- (void)weightSCValueChanged{
    
    [self.weightCollectionView reloadData];
    
    self.weightSelectedCellIndexPath = nil;
    self.weightSelectedValueLabel.text = @"select";
    
}

- (void)repsSCValueChanged{
    
    [self.repsCollectionView reloadData];
    
    self.repsSelectedCellIndexPath = nil;
    self.repsSelectedValueLabel.text = @"select";
    
}

#pragma mark - Button Actions

- (void)didPressCancel{
    
    [self cancelBlock];
    
}

- (void)didPressDone{
    
    
    
}


@end























