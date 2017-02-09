//
//  TJBNumberSelectionVC.m
//  Beast
//
//  Created by Trevor Beasty on 12/7/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import "TJBNumberSelectionVC.h"

// cell

#import "TJBWeightRepsSelectionCell.h"

// stopwatch

#import "TJBStopwatch.h"

// aesthetics

#import "TJBAestheticsController.h"

@interface TJBNumberSelectionVC () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

{
    // state
    
    NumberType _numberTypeIdentifier;
    
}

@property (copy) void (^cancelBlock)(void);
@property (copy) void (^numberSelectedBlock)(NSNumber *);
@property (nonatomic, strong) NSString *selectionTitle;

// view objects

@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *selectedValueLabel;
@property (weak, nonatomic) IBOutlet UISegmentedControl *multiplierSegmentedControl;

@property (nonatomic, weak) UIBarButtonItem *submitButton;

// state

@property (nonatomic, strong) NSIndexPath *selectedCellIndexPath;


@end

static NSString * const reuseIdentifier = @"cell";

@implementation TJBNumberSelectionVC

#pragma mark - Instantiation

- (instancetype)initWithNumberTypeIdentifier:(NumberType)numberType title:(NSString *)title cancelBlock:(CancelBlock)cancelBlock numberSelectedBlock:(NumberSelectedBlockSingle)numberSelectedBlock{

    self = [super init];
    
    _numberTypeIdentifier = numberType;
    self.selectionTitle = title;
    self.cancelBlock = cancelBlock;
    self.numberSelectedBlock = numberSelectedBlock;
    
    return self;
    
}

#pragma mark - View Life Cycle

- (void)viewDidLoad{
    
    [self configureCollectionView];
    
    [self configureViewAesthetics];
    
    [self configureSegmentedControl];
    
    [self configureDisplay];
    
    [self configureNavigationBar];
    
}

- (void)configureDisplay{
    
    switch (_numberTypeIdentifier) {
        case WeightType:
            self.typeLabel.text = @"Weight";
            break;
            
        case RestType:
            self.typeLabel.text = @"Time";
            break;
            
        case RepsType:
            self.typeLabel.text = @"Reps";
            break;
            
        default:
            break;
    }
    
}

- (void)configureSegmentedControl{
    
    if (_numberTypeIdentifier == WeightType){
        
        [self.multiplierSegmentedControl removeAllSegments];
        
        NSArray *segmentNumbers = @[[NSNumber numberWithDouble: 1.0],
                                    [NSNumber numberWithDouble: 2.5],
                                    [NSNumber numberWithDouble: 5.0]];
        
        for (NSNumber *number in segmentNumbers){
            
            [self.multiplierSegmentedControl insertSegmentWithTitle: [number stringValue]
                                                            atIndex: [segmentNumbers indexOfObject: number]
                                                           animated: NO];
        }
        
        self.multiplierSegmentedControl.selectedSegmentIndex = 1;
        
    } else if (_numberTypeIdentifier == RepsType){
        
        [self.multiplierSegmentedControl removeAllSegments];
        
        NSArray *segmentNumbers = @[[NSNumber numberWithDouble: 0.5],
                                    [NSNumber numberWithDouble: 1.0]];
        
        for (NSNumber *number in segmentNumbers){
            
            [self.multiplierSegmentedControl insertSegmentWithTitle: [number stringValue]
                                                            atIndex: [segmentNumbers indexOfObject: number]
                                                           animated: NO];
        }
        
        self.multiplierSegmentedControl.selectedSegmentIndex = 1;
        
    } else{
        
        [self.multiplierSegmentedControl removeAllSegments];
        
        NSArray *segmentNumbers = @[[NSNumber numberWithDouble: 1.0],
                                    [NSNumber numberWithDouble: 5.0],
                                    [NSNumber numberWithDouble: 10.0]];
        
        for (NSNumber *number in segmentNumbers){
            
            [self.multiplierSegmentedControl insertSegmentWithTitle: [number stringValue]
                                                            atIndex: [segmentNumbers indexOfObject: number]
                                                           animated: NO];
        }
        
        self.multiplierSegmentedControl.selectedSegmentIndex = 1;
        
    }
    
    [self.multiplierSegmentedControl addTarget: self
                                        action: @selector(scValueDidChange)
                              forControlEvents: UIControlEventValueChanged];
    
}

- (void)configureViewAesthetics{
    
    self.multiplierSegmentedControl.tintColor = [UIColor darkGrayColor];
    
    // type label
    
    self.typeLabel.layer.masksToBounds = YES;
    self.typeLabel.layer.cornerRadius = 4.0;
    
}

- (void)configureCollectionView{
    
    UINib *nib = [UINib nibWithNibName: @"TJBWeightRepsSelectionCell"
                                bundle: nil];
    
    [self.collectionView registerNib: nib
          forCellWithReuseIdentifier: reuseIdentifier];
    
}

- (void)configureNavigationBar{
    
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle: self.selectionTitle];
    
    UIBarButtonItem *submitButton = [[UIBarButtonItem alloc] initWithTitle: @"OK"
                                                                     style: UIBarButtonItemStyleDone
                                                                    target: self
                                                                    action: @selector(didPressSubmit)];
    
    self.submitButton = submitButton;
    submitButton.enabled = NO;
    
    [navItem setRightBarButtonItem: submitButton];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCancel
                                                                                  target: self
                                                                                  action: @selector(cancel)];
    
    [navItem setLeftBarButtonItem: cancelButton];
    
    [self.navBar setItems: @[navItem]];
    
    // nav bar text appearance
    
    [self.navBar setTitleTextAttributes: @{NSFontAttributeName: [UIFont boldSystemFontOfSize: 20.0]}];
    
}



#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 1000;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    TJBWeightRepsSelectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: reuseIdentifier
                                                                                 forIndexPath: indexPath];
    
    NSNumber *cellNumber = [NSNumber numberWithFloat: indexPath.row * [self multiplierValue]];
    
    cell.backgroundColor = [[TJBAestheticsController singleton] blueButtonColor];
    
    if (self.selectedCellIndexPath){
        
        if (self.selectedCellIndexPath.row == indexPath.row){
            
            cell.backgroundColor = [UIColor redColor];
            
        }
        
    }
    
    if (_numberTypeIdentifier == RestType){
        
        cell.numberLabel.text = [[TJBStopwatch singleton] minutesAndSecondsStringFromNumberOfSeconds: [cellNumber floatValue]];
        
    } else{
        
        cell.numberLabel.text = [cellNumber stringValue];
        
    }
    
    cell.numberLabel.textColor = [UIColor whiteColor];
    cell.numberLabel.font = [UIFont boldSystemFontOfSize: 15.0];
    cell.typeLabel.text = @"";
    cell.typeLabel.font = [UIFont systemFontOfSize: 15.0];
    
    cell.layer.masksToBounds = YES;
    cell.layer.cornerRadius = 4.0;
    
    return cell;
    
}

- (float)multiplierValue{
    
    float returnValue;
    NSInteger index = self.multiplierSegmentedControl.selectedSegmentIndex;
    
    if (_numberTypeIdentifier == WeightType){
        
        switch (index) {
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
        
    } else if (_numberTypeIdentifier == RepsType){
        
        switch (index) {
            case 0:
                returnValue = 0.5;
                break;
                
            case 1:
                returnValue = 1.0;
                break;
                
            default:
                break;
        }
        
    } else{
        
        switch (index) {
            case 0:
                returnValue = 1.0;
                break;
                
            case 1:
                returnValue = 5.0;
                break;
                
            case 2:
                returnValue = 10.0;
                break;
                
            default:
                break;
        }
        
    }
    
    return returnValue;
    
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    self.submitButton.enabled = YES;
        
    if (self.selectedCellIndexPath){
            
        TJBWeightRepsSelectionCell *previousCell = (TJBWeightRepsSelectionCell *)[self.collectionView cellForItemAtIndexPath: self.selectedCellIndexPath];
            
        previousCell.backgroundColor = [[TJBAestheticsController singleton] blueButtonColor];
            
    }
        
    self.selectedCellIndexPath = indexPath;
        
    TJBWeightRepsSelectionCell *currentCell = (TJBWeightRepsSelectionCell *)[self.collectionView cellForItemAtIndexPath: indexPath];
        
    currentCell.backgroundColor = [UIColor redColor];
        
    NSNumber *number = [NSNumber numberWithFloat: indexPath.row * [self multiplierValue]];
    
    if (_numberTypeIdentifier == WeightType){
        
        self.selectedValueLabel.text = [NSString stringWithFormat: @"%@ lbs", [number stringValue]];
        
    } else if (_numberTypeIdentifier == RestType){
        
        self.selectedValueLabel.text = [[TJBStopwatch singleton] minutesAndSecondsStringFromNumberOfSeconds: [number intValue]];
        
    } else{
        
        self.selectedValueLabel.text = [NSString stringWithFormat: @"%@ reps", [number stringValue]];
        
    }
    
}


#pragma mark - Actions

- (void)cancel{
    
    self.cancelBlock();
    
}

- (void)didPressSubmit{
    
    if (self.selectedCellIndexPath){
        
        NSNumber *selectedNumber = [NSNumber numberWithFloat: self.selectedCellIndexPath.row * [self multiplierValue]];
        
        self.numberSelectedBlock(selectedNumber);
        
    }
}

- (void)scValueDidChange{
    
    self.submitButton.enabled = NO;
    
    self.selectedCellIndexPath = nil;
    
    [self.collectionView reloadData];
    
    self.selectedValueLabel.text = @"select";
    
}

#pragma mark - <UICollectionViewDelegateFlowLayout>

static CGFloat const spacing = 8.0;
static float const numberOfCellsPerRow = 4;

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    
    return spacing;
    
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    return UIEdgeInsetsMake(8, 0, 8, 0);
    
    
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    
    return spacing;
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    [self.view layoutIfNeeded];
        
    CGFloat collectionViewWidth = self.collectionView.frame.size.width;
        
    CGFloat cellWidth = (collectionViewWidth - (numberOfCellsPerRow -1) * spacing) / numberOfCellsPerRow;
        
    return CGSizeMake(cellWidth, cellWidth);
    
}



@end





















