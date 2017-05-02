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

// jump bar

#import "TJBNumberJumpVC.h"

@interface TJBNumberSelectionVC () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

{
    // state
    
    NumberType _numberTypeIdentifier;
    
}

@property (copy) void (^cancelBlock)(void);
@property (copy) void (^numberSelectedBlock)(NSNumber *);
@property (nonatomic, strong) NSString *selectionTitle;

// IBOutlet

@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UILabel *topLabel1;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *multiplierSegmentedControl;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UIView *titleBarContainer;
@property (weak, nonatomic) IBOutlet UIView *jumpBarContainer;
@property (weak, nonatomic) IBOutlet UILabel *selectedValueLabel;
@property (weak, nonatomic) IBOutlet UIView *titleAreaContainer;

// IBAction

- (IBAction)didPressCancel:(id)sender;
- (IBAction)didPressSubmit:(id)sender;


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
    
    [self configureSegmentedControl];
    
    [self.view layoutIfNeeded];
    
    [self configureViewAesthetics];
    
    [self configureDisplay];
    
    [self configureJumpBar];
    
}

#pragma mark - View Helper Methods

- (void)configureJumpBar{
    
    [self.view layoutIfNeeded];
    
    __weak TJBNumberSelectionVC *weakSelf = self;
    
    // weight jump bar
    
    void (^jumpBarWeightCallback)(NSNumber *) = ^(NSNumber *touchNumber){
        
        [weakSelf jumpBarTouchedWithNumberEquivalent: touchNumber];
        
    };
    
    NSNumber *intervalSize;
    BOOL isTimeType;
    
    switch (_numberTypeIdentifier) {
        case WeightType:
            intervalSize = @(50);
            isTimeType = NO;
            break;
            
        case RepsType:
            intervalSize = @(5);
            isTimeType = NO;
            break;
            
        case TargetRestType:
            intervalSize = @(30);
            isTimeType = YES;
            break;
            
        case TimeIntervalSelection:
            intervalSize = @(30);
            isTimeType = YES;
            break;
            
        default:
            break;
    }
    
    TJBNumberJumpVC *jumpBar = [[TJBNumberJumpVC alloc] initWithLowerLimit: @(0)
                                                            numberOfLabels: @(11)
                                                              intervalSize: intervalSize
                                                          delegateCallback: jumpBarWeightCallback
                                                                isTimeType: isTimeType];
    
    [self addChildViewController: jumpBar];
    
    jumpBar.view.frame = self.jumpBarContainer.bounds;
    [self.jumpBarContainer addSubview: jumpBar.view];
    
    [jumpBar didMoveToParentViewController: self];
    
}

- (void)configureDisplay{
    
    switch (_numberTypeIdentifier) {
        case WeightType:
            self.selectedValueLabel.text = @"--- lbs";
            self.topLabel1.text = @"Select Weight";
            break;
            
        case TargetRestType:
            self.selectedValueLabel.text = @"--- rest";
            self.topLabel1.text = @"Select Rest";
            break;
            
        case TimeIntervalSelection:
            self.selectedValueLabel.text = @"---";
            self.topLabel1.text = @"Select Time";
            break;
            
        case RepsType:
            self.selectedValueLabel.text = @"--- reps";
            self.topLabel1.text = @"Select Reps";
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
    
    [self.view layoutIfNeeded];
    
    // meta views
    
    self.view.backgroundColor = [[TJBAestheticsController singleton] yellowNotebookColor];
    self.titleAreaContainer.backgroundColor = [UIColor blackColor];
    self.titleBarContainer.backgroundColor = [UIColor darkGrayColor];
    
    // segmented control
    
    self.multiplierSegmentedControl.tintColor = [UIColor grayColor];
    self.multiplierSegmentedControl.backgroundColor = [UIColor clearColor];
    CALayer *scLayer = self.multiplierSegmentedControl.layer;
    scLayer.masksToBounds = YES;
    scLayer.cornerRadius = self.multiplierSegmentedControl.frame.size.height / 2.0;
    scLayer.borderColor = [UIColor grayColor].CGColor;
    scLayer.borderWidth = 1.0;
    
    // title label
    
    self.topLabel1.backgroundColor = [UIColor clearColor];
    self.topLabel1.textColor = [UIColor whiteColor];
    self.topLabel1.font = [UIFont boldSystemFontOfSize: 20];
    
    // buttons
    
    self.cancelButton.backgroundColor = [UIColor clearColor];
    
    self.submitButton.backgroundColor = [[TJBAestheticsController singleton] paleLightBlueColor];
    self.submitButton.titleLabel.font = [UIFont boldSystemFontOfSize: 20];
    [self.submitButton setTitleColor: [UIColor darkGrayColor]
                            forState: UIControlStateNormal];
    CALayer *sbLayer = self.submitButton.layer;
    sbLayer.masksToBounds = YES;
    sbLayer.cornerRadius = 4;
    sbLayer.borderWidth = 1;
    sbLayer.borderColor = [UIColor darkGrayColor].CGColor;
    
    // selected value label
    
    self.selectedValueLabel.font = [UIFont boldSystemFontOfSize: 20];
    self.selectedValueLabel.textColor = [UIColor blackColor];
    self.selectedValueLabel.backgroundColor = [UIColor clearColor];
    
    // jump bar container
    
    self.jumpBarContainer.backgroundColor = [UIColor clearColor];
    CALayer *jbLayer = self.jumpBarContainer.layer;
    jbLayer.masksToBounds = YES;
    jbLayer.cornerRadius = self.jumpBarContainer.frame.size.width / 2.0;
    jbLayer.borderWidth = 1.0;
    jbLayer.borderColor = [UIColor grayColor].CGColor;
    
}

- (void)configureCollectionView{
    
    UINib *nib = [UINib nibWithNibName: @"TJBWeightRepsSelectionCell"
                                bundle: nil];
    
    [self.collectionView registerNib: nib
          forCellWithReuseIdentifier: reuseIdentifier];
    
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
    
    NSNumber *cellNumber;
    if (_numberTypeIdentifier == TargetRestType){
        
        cellNumber = [NSNumber numberWithFloat: (indexPath.row - 1) * [self multiplierValue] + 30.0];
        
    } else{
        
        cellNumber = [NSNumber numberWithFloat: indexPath.row * [self multiplierValue]];
        
    }
    
    [self configureUnselectedCellAppearance: cell];
    
    if (self.selectedCellIndexPath){
        
        if (self.selectedCellIndexPath.row == indexPath.row){
            
            [self configureSelectedCellAppearanceForCell: cell];
            
        }
        
    }
    
    if (_numberTypeIdentifier == TargetRestType){
        
        // if it is the first cell, give it the string 'no rest' representation
        
        if (indexPath.row == 0){
            
            cell.numberLabel.text = @"Go Immediately Into Next Set";
            
        } else{
            
            cell.numberLabel.text = [[TJBStopwatch singleton] minutesAndSecondsStringFromNumberOfSeconds: [cellNumber floatValue]];
            
        }

    } else if (_numberTypeIdentifier == TimeIntervalSelection){
        
        cell.numberLabel.text = [[TJBStopwatch singleton] minutesAndSecondsStringFromNumberOfSeconds: [cellNumber floatValue]];
        
    } else{
        
        cell.numberLabel.text = [cellNumber stringValue];
        
    }
    
    cell.typeLabel.text = @"";
    
    return cell;
    
}

#pragma mark - Cell Aesthetics

- (void)configureSelectedCellAppearanceForCell:(TJBWeightRepsSelectionCell *)cell{
    
    cell.backgroundColor = [UIColor clearColor];
    cell.numberLabel.textColor = [UIColor blackColor];
    cell.numberLabel.font = [UIFont boldSystemFontOfSize: 15];
    
    CALayer *cellLayer = cell.layer;
    cellLayer.masksToBounds = YES;
    cellLayer.cornerRadius = 4.0;
    cellLayer.borderColor = [UIColor blackColor].CGColor;
    cellLayer.borderWidth = 4.0;
    
}

- (void)configureUnselectedCellAppearance:(TJBWeightRepsSelectionCell *)cell{
    
    cell.backgroundColor = [UIColor grayColor];
    cell.numberLabel.font = [UIFont boldSystemFontOfSize: 15];
    cell.numberLabel.textColor = [UIColor whiteColor];
    
    CALayer *cellLayer = cell.layer;
    cellLayer.masksToBounds = YES;
    cellLayer.cornerRadius = 4.0;
    cellLayer.borderColor = [UIColor darkGrayColor].CGColor;
    cellLayer.borderWidth = 1.0;
    
}



#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    self.submitButton.enabled = YES;
        
    if (self.selectedCellIndexPath){
            
        TJBWeightRepsSelectionCell *previousCell = (TJBWeightRepsSelectionCell *)[self.collectionView cellForItemAtIndexPath: self.selectedCellIndexPath];
            
        [self configureUnselectedCellAppearance: previousCell];
            
    }
        
    self.selectedCellIndexPath = indexPath;
        
    TJBWeightRepsSelectionCell *currentCell = (TJBWeightRepsSelectionCell *)[self.collectionView cellForItemAtIndexPath: indexPath];
        
    [self configureSelectedCellAppearanceForCell: currentCell];
    
    NSNumber *number;
    if (_numberTypeIdentifier == TargetRestType){
        
        number = [NSNumber numberWithFloat: (indexPath.row - 1) * [self multiplierValue] + 30.0];
        
    } else{
        
        number = [NSNumber numberWithFloat: indexPath.row * [self multiplierValue]];
        
    }
    
    if (_numberTypeIdentifier == WeightType){
        
        self.selectedValueLabel.text = [NSString stringWithFormat: @"%@ lbs", [number stringValue]];
        
    } else if (_numberTypeIdentifier == TimeIntervalSelection){
        
        self.selectedValueLabel.text = [[TJBStopwatch singleton] minutesAndSecondsStringFromNumberOfSeconds: [number intValue]];
        
    } else if (_numberTypeIdentifier == TargetRestType){
        
        if (indexPath.row == 0){
            
            self.selectedValueLabel.text = @"Go Immediately Into Next Set";
            
        } else{
            
            self.selectedValueLabel.text = [[TJBStopwatch singleton] minutesAndSecondsStringFromNumberOfSeconds: [number intValue]];
            
        }
        
    } else{
        
        self.selectedValueLabel.text = [NSString stringWithFormat: @"%@ reps", [number stringValue]];
        
    }
    
}


#pragma mark - Button Actions


- (IBAction)didPressCancel:(id)sender{
    
    self.cancelBlock();
    
}

- (IBAction)didPressSubmit:(id)sender{
    
    if (self.selectedCellIndexPath){
        
        NSNumber *selectedNumber;
        
        if (_numberTypeIdentifier == TargetRestType){
            
            if (self.selectedCellIndexPath.row == 0){
                
                selectedNumber = [NSNumber numberWithInt: 0];
                
            } else{
                
                selectedNumber = [NSNumber numberWithFloat: (self.selectedCellIndexPath.row - 1) * [self multiplierValue] + 30.0];
                
            }
            
        } else{
            
            selectedNumber = [NSNumber numberWithFloat: self.selectedCellIndexPath.row * [self multiplierValue]];
            
        }
        
        self.numberSelectedBlock(selectedNumber);
        
    }
    
}

#pragma mark - Segmented Control



- (void)scValueDidChange{
    
    self.submitButton.enabled = NO;
    
    self.selectedCellIndexPath = nil;
    
    [self.collectionView reloadData];
    
    [self configureDisplay]; // called so that the selectedValueLabel resets to the correct 'no selection made' text
    
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

#pragma mark - <UICollectionViewDelegateFlowLayout>

static CGFloat const spacing = 1.0;
static float const numberOfCellsPerRow = 4;

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section{
    
    return spacing;
    
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section{
    
    return UIEdgeInsetsMake(0, 0, 8, 0);
    
    
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section{
    
    return spacing;
    
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    [self.view layoutIfNeeded];
    
    // the rest options will have a 'no rest' option and will otherwise begin with a minimum value of 30 seconds.  This is done because the app experience is poor if the user does not have enough time to enter their realized set info
    
    CGFloat collectionViewWidth = self.collectionView.frame.size.width;
    
    CGFloat cellWidth = (collectionViewWidth - (numberOfCellsPerRow -1) * spacing) / numberOfCellsPerRow;
    
    if (_numberTypeIdentifier == TargetRestType && indexPath.row == 0){
        
        return CGSizeMake(collectionViewWidth, cellWidth);
        
    } else{
        
        return CGSizeMake(cellWidth, cellWidth);
        
    }
    
    
}

#pragma mark - Jump Bar

- (void)jumpBarTouchedWithNumberEquivalent:(NSNumber *)number{
    
    NSIndexPath *path = [self pathForJumpBarTouchNumber: number];
    
    [self.collectionView selectItemAtIndexPath: path
                                      animated: YES
                                scrollPosition: UICollectionViewScrollPositionCenteredVertically];
    
}

- (NSIndexPath *)pathForJumpBarTouchNumber:(NSNumber *)touchNumber{
    
    float multValue = [self multiplierValue];
    NSInteger touchNum = [touchNumber intValue];
    NSInteger lowerBoundMultiple = touchNum / multValue;
    
    NSIndexPath *returnPath = [NSIndexPath indexPathForRow: lowerBoundMultiple
                                                 inSection: 0];
    
    return returnPath;
    
}



@end





















