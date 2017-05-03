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

// jump bars

#import "TJBNumberJumpVC.h"

@interface TJBWeightRepsSelectionVC () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

// view objects

@property (weak, nonatomic) IBOutlet UICollectionView *weightCollectionView;
@property (weak, nonatomic) IBOutlet UICollectionView *repsCollectionView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *weightSegmentedControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *repsSegmentedControl;
@property (weak, nonatomic) IBOutlet UILabel *weightSelectedValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *repsSelectedValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *topTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *submitButton;
@property (weak, nonatomic) IBOutlet UIButton *cancelButton;
@property (weak, nonatomic) IBOutlet UIView *titleBarContainer;
@property (weak, nonatomic) IBOutlet UIView *topTitleBar;
@property (weak, nonatomic) IBOutlet UILabel *weightRepEntryLabel;
@property (weak, nonatomic) IBOutlet UIView *topTopTitleBar;


@property (weak, nonatomic) IBOutlet UIView *leftJumpBarContainer;
@property (weak, nonatomic) IBOutlet UIView *rightJumpBarContainer;
@property (weak, nonatomic) IBOutlet UILabel *thinDividerLabel;

// IBAction

- (IBAction)didPressSubmitButton:(id)sender;
- (IBAction)didPressCancel:(id)sender;

// state

@property (nonatomic, strong) NSIndexPath *weightSelectedCellIndexPath;
@property (nonatomic, strong) NSIndexPath *repsSelectedCellIndexPath;

// callback

@property (nonatomic, copy) CancelBlock cancelBlock;
@property (nonatomic, copy) NumberSelectedBlockDouble numberSelectedBlock;

// core

@property (nonatomic, strong) NSString *navBarTitle;

@end



#pragma mark - Constants and Typedefs





// type

typedef enum {
    WeightType,
    RepsType,
} TJBJumpBarType;










@implementation TJBWeightRepsSelectionVC

#pragma mark - Instantiation

- (instancetype)initWithTitle:(NSString *)title cancelBlock:(CancelBlock)cancelBlock numberSelectedBlock:(NumberSelectedBlockDouble)numberSelectedBlock{
    
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
    
    [self.view layoutIfNeeded];
    
    [self configureViewAesthetics];
    
    [self configureSegmentedControl];
    
    [self configureViewData];
    
    [self configureJumpBars];
    
}


#pragma mark - View Helper Methods

- (void)configureJumpBars{
    
    [self.view layoutIfNeeded];
    
    __weak TJBWeightRepsSelectionVC *weakSelf = self;
    
    // weight jump bar
    
    void (^jumpBarWeightCallback)(NSNumber *) = ^(NSNumber *touchNumber){
        
        [weakSelf jumpBarTouchedWithNumberEquivalent: touchNumber
                                         jumpBarType: WeightType];
        
    };
    
    TJBNumberJumpVC *weightJumpBar = [[TJBNumberJumpVC alloc] initWithLowerLimit: @(0)
                                                            numberOfLabels: @(11)
                                                              intervalSize: @(50)
                                                          delegateCallback: jumpBarWeightCallback];
    
    [self addChildViewController: weightJumpBar];
    
    weightJumpBar.view.frame = self.leftJumpBarContainer.bounds;
    [self.leftJumpBarContainer addSubview: weightJumpBar.view];
    
    [weightJumpBar didMoveToParentViewController: self];
    
    // reps jump bar
    
    void (^jumpBarRepsCallback)(NSNumber *) = ^(NSNumber *touchNumber){
        
        [weakSelf jumpBarTouchedWithNumberEquivalent: touchNumber
                                         jumpBarType: RepsType];
        
    };
    
    TJBNumberJumpVC *repsJumpBar = [[TJBNumberJumpVC alloc] initWithLowerLimit: @(0)
                                                            numberOfLabels: @(11)
                                                              intervalSize: @(5)
                                                          delegateCallback: jumpBarRepsCallback];
    
    [self addChildViewController: repsJumpBar];
    
    repsJumpBar.view.frame = self.leftJumpBarContainer.bounds;
    [self.rightJumpBarContainer addSubview: repsJumpBar.view];
    
    [repsJumpBar didMoveToParentViewController: self];
    
}

- (void)configureViewData{
    
    self.topTitleLabel.text = self.navBarTitle;
    
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
    
    [self.weightCollectionView reloadData];
    [self.repsCollectionView reloadData];
    
}


- (void)configureViewAesthetics{
    
    [self.view layoutIfNeeded];
    
    // thin divider label
    
    self.thinDividerLabel.backgroundColor = [UIColor clearColor];
    self.thinDividerLabel.text = @"";
    
    // meta view
    
    self.view.backgroundColor = [[TJBAestheticsController singleton] yellowNotebookColor];
    self.titleBarContainer.backgroundColor = [UIColor blackColor];
    self.topTitleBar.backgroundColor = [UIColor darkGrayColor];
    
    // segmented controls
    
    NSArray *segmentedControls = @[self.weightSegmentedControl, self.repsSegmentedControl];
    for (UISegmentedControl *sc in segmentedControls){
        
        sc.tintColor = [[TJBAestheticsController singleton] paleLightBlueColor];
        sc.backgroundColor = [UIColor grayColor];
        
        CALayer *scLayer = sc.layer;
        scLayer.masksToBounds = YES;
        scLayer.cornerRadius = sc.frame.size.height / 2.0;
        scLayer.borderWidth = 1.0;
        scLayer.borderColor = [[TJBAestheticsController singleton] paleLightBlueColor].CGColor;
        
    }
    
    // top labels
    
    NSArray *titleLabels = @[self.topTitleLabel];
    for (UILabel *label in titleLabels){
        
        label.backgroundColor = [UIColor clearColor];
        label.textColor = [UIColor whiteColor];
        label.font = [UIFont boldSystemFontOfSize: 20.0];
        
    }
    
    // selected value labels
    
    NSArray *selectedValueLabels = @[self.weightSelectedValueLabel, self.repsSelectedValueLabel];
    for (UILabel *lab in selectedValueLabels){
        
        lab.backgroundColor = [UIColor grayColor];
        lab.textColor = [UIColor whiteColor];
        lab.font = [UIFont boldSystemFontOfSize: 20];
        
    }
    
    // buttons
    
    self.submitButton.backgroundColor = [UIColor grayColor];
    [self.submitButton setTitleColor: [[TJBAestheticsController singleton] paleLightBlueColor]
                            forState: UIControlStateNormal];
    self.submitButton.titleLabel.font = [UIFont boldSystemFontOfSize:20.0];
    CALayer *sbLayer = self.submitButton.layer;
    sbLayer.masksToBounds = YES;
    sbLayer.cornerRadius = self.submitButton.frame.size.height / 2.0;
    sbLayer.borderColor = [[TJBAestheticsController singleton] paleLightBlueColor].CGColor;
    sbLayer.borderWidth = 1;
    
    self.cancelButton.backgroundColor = [UIColor clearColor];
    
    // jump bars
    
    NSArray *jumpBarContainers = @[self.leftJumpBarContainer, self.rightJumpBarContainer];
    for (UIView *view in jumpBarContainers){
        
        view.backgroundColor = [[TJBAestheticsController singleton] paleLightBlueColor];
        
        CALayer *layer = view.layer;
        layer.masksToBounds = YES;
        layer.cornerRadius = view.frame.size.width / 2.0;
        layer.borderWidth = 1.0;
        layer.borderColor = [UIColor darkGrayColor].CGColor;
        
    }
    
    // top top title bar and label
    
    self.topTopTitleBar.backgroundColor = [UIColor darkGrayColor];
    
    self.weightRepEntryLabel.font = [UIFont boldSystemFontOfSize: 20];
    self.weightRepEntryLabel.textColor = [UIColor whiteColor];
    
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
        weightCell.typeLabel.text = @"";

        
        [self configureUnselectedCellAesthetics: weightCell];
        
        
        // the following is done so that a cell remains highlighted if it is selected, scrolled off-screen, and then scrolled back on-screen
        
        
        if (self.weightSelectedCellIndexPath){
            
            if (self.weightSelectedCellIndexPath.row == indexPath.row){
                
                [self configureSelectedCellAesthetics: weightCell];
                
            }
            
        }
        
        return weightCell;
        
    } else{
        
        TJBWeightRepsSelectionCell *repsCell = [self.repsCollectionView dequeueReusableCellWithReuseIdentifier: @"TJBWeightRepsSelectionCell"
                                                                                                      forIndexPath: indexPath];
        
        NSNumber *repsNumber = [NSNumber numberWithFloat: indexPath.row * [self repsMultiplier]];
        
        repsCell.numberLabel.text = [repsNumber stringValue];
        repsCell.typeLabel.text = @"";
        
        [self configureUnselectedCellAesthetics: repsCell];
        
        if (self.repsSelectedCellIndexPath){
            
            if (self.repsSelectedCellIndexPath.row == indexPath.row){
                
                [self configureSelectedCellAesthetics: repsCell];
                
            }
            
        }
        
        return repsCell;
        
    }
}

#pragma mark - Cell Aesthetics



- (void)configureUnselectedCellAesthetics:(TJBWeightRepsSelectionCell *)cell{
    
    cell.backgroundColor = [UIColor clearColor];
    cell.numberLabel.font = [UIFont boldSystemFontOfSize: 15];
    cell.numberLabel.textColor = [UIColor blackColor];
    
    CALayer *cellLayer = cell.layer;
    cellLayer.masksToBounds = YES;
    cellLayer.cornerRadius = 4.0;
    cellLayer.borderColor = [UIColor blackColor].CGColor;
    cellLayer.borderWidth = 1.0;
    
}

- (void)configureSelectedCellAesthetics:(TJBWeightRepsSelectionCell *)cell{
    
    cell.backgroundColor = [UIColor darkGrayColor];
    cell.numberLabel.font = [UIFont boldSystemFontOfSize: 15];
    cell.numberLabel.textColor = [[TJBAestheticsController singleton] yellowNotebookColor];
    
    CALayer *cellLayer = cell.layer;
    cellLayer.masksToBounds = YES;
    cellLayer.cornerRadius = 4.0;
    cellLayer.borderColor = [[TJBAestheticsController singleton] paleLightBlueColor].CGColor;
    cellLayer.borderWidth = 0.0;
    
}



#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath{
    
    if ([collectionView isEqual: self.weightCollectionView]){
        
        if (self.weightSelectedCellIndexPath){
            
            TJBWeightRepsSelectionCell *previousCell = (TJBWeightRepsSelectionCell *)[self.weightCollectionView cellForItemAtIndexPath: self.weightSelectedCellIndexPath];
            
            [self configureUnselectedCellAesthetics: previousCell];
            
        }
        
        self.weightSelectedCellIndexPath = indexPath;
        
        TJBWeightRepsSelectionCell *currentCell = (TJBWeightRepsSelectionCell *)[self.weightCollectionView cellForItemAtIndexPath: indexPath];
        
        [self configureSelectedCellAesthetics: currentCell];
        
        NSNumber *weight = [NSNumber numberWithFloat: indexPath.row * [self weightMultiplier]];
        self.weightSelectedValueLabel.text = [NSString stringWithFormat: @"%@ lbs", [weight stringValue]];
        
    } else{
        
        if (self.repsSelectedCellIndexPath){
            
            TJBWeightRepsSelectionCell *previousCell = (TJBWeightRepsSelectionCell *)[self.repsCollectionView cellForItemAtIndexPath: self.repsSelectedCellIndexPath];
            
            [self configureUnselectedCellAesthetics: previousCell];
            
        }
        
        self.repsSelectedCellIndexPath = indexPath;
        
        TJBWeightRepsSelectionCell *currentCell = (TJBWeightRepsSelectionCell *)[self.repsCollectionView cellForItemAtIndexPath: indexPath];
        
        [self configureSelectedCellAesthetics: currentCell];
        
        NSNumber *reps = [NSNumber numberWithFloat: indexPath.row * [self repsMultiplier]];
        self.repsSelectedValueLabel.text = [NSString stringWithFormat: @"%@ reps", [reps stringValue]];
        
    }
    
    if (self.weightSelectedCellIndexPath && self.repsSelectedCellIndexPath){
        
        self.submitButton.enabled = YES;
        
    }
    
}


#pragma mark - <UICollectionViewDelegateFlowLayout>

static CGFloat const spacing = 1.0;
static float const numberOfCellsPerRow = 2;

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

#pragma mark - Segmented Control

- (void)weightSCValueChanged{
    
    [self.weightCollectionView reloadData];
    
    self.weightSelectedCellIndexPath = nil;
    self.weightSelectedValueLabel.text = @"--- lbs";
    
    self.submitButton.enabled = NO;
    
}

- (void)repsSCValueChanged{
    
    [self.repsCollectionView reloadData];
    
    self.repsSelectedCellIndexPath = nil;
    self.repsSelectedValueLabel.text = @"--- reps";
    
    self.submitButton.enabled = NO;
    
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



#pragma mark - Submit Button Actions

- (IBAction)didPressSubmitButton:(id)sender{
    
    if ([self requisiteUserInputCollected]){
        
        NSNumber *weight = [NSNumber numberWithFloat: self.weightSelectedCellIndexPath.row * [self weightMultiplier]];
        NSNumber *reps = [NSNumber numberWithFloat: self.repsSelectedCellIndexPath.row * [self repsMultiplier]];
        
        self.numberSelectedBlock(weight, reps);
        
    } else{
        
        UIAlertController *alertContr = [UIAlertController alertControllerWithTitle: @"Incomplete Selections"
                                                                            message: @"Please select both a weight and number of reps before submitting"
                                                                     preferredStyle: UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle: @"Continue"
                                                         style: UIAlertActionStyleDefault
                                                       handler: ^(UIAlertAction *action){
                                                           
                                                           return;
                                                           
                                                       }];
        [alertContr addAction: action];
        
        [self presentViewController: alertContr
                           animated: YES
                         completion: nil];
        
    }
}


- (BOOL)requisiteUserInputCollected{
    
    return self.weightSelectedCellIndexPath && self.repsSelectedCellIndexPath;
    
}


#pragma mark - Cancel Button Actions

- (IBAction)didPressCancel:(id)sender{
    
    self.cancelBlock();
    
}



#pragma mark - Jump Bars

- (void)jumpBarTouchedWithNumberEquivalent:(NSNumber *)touchNumber jumpBarType:(TJBJumpBarType)type{
    
    NSIndexPath *pathToSelect = [self pathForJumpBarTouchNumber: touchNumber
                                                    jumpBarType: type];
    
    if (type == WeightType){
        
        [self.weightCollectionView selectItemAtIndexPath: pathToSelect
                                                animated: YES
                                          scrollPosition: UICollectionViewScrollPositionCenteredVertically];
        
    } else{
        
        [self.repsCollectionView selectItemAtIndexPath: pathToSelect
                                              animated: YES
                                        scrollPosition: UICollectionViewScrollPositionCenteredVertically];
        
    }
    

    
}

- (NSIndexPath *)pathForJumpBarTouchNumber:(NSNumber *)touchNumber jumpBarType:(TJBJumpBarType)type{
    
    // get the value of the multiplier, designated by the segmented control
    // round the touchNumber to the lower encapsulating multiple
    // divide by the touch touch to get the row of the index path
    
    if (type == WeightType){
        
        float multValue = [self weightMultiplier];
        NSInteger touchNum = [touchNumber intValue];
        NSInteger lowerBoundMultiple = touchNum / multValue;
        
        NSIndexPath *returnPath = [NSIndexPath indexPathForRow: lowerBoundMultiple
                                                     inSection: 0];
        
        return returnPath;
        
    } else{
        
        float multValue = [self repsMultiplier];
        NSInteger touchNum = [touchNumber intValue];
        NSInteger lowerBoundMultiple = touchNum / multValue;
        
        NSIndexPath *returnPath = [NSIndexPath indexPathForRow: lowerBoundMultiple
                                                     inSection: 0];
        
        return returnPath;
        
    }
    

    
}





@end























