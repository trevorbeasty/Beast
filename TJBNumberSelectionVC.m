//
//  TJBNumberSelectionVC.m
//  Beast
//
//  Created by Trevor Beasty on 12/7/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import "TJBNumberSelectionVC.h"

#import "TJBNumberSelectionCell.h"

@interface TJBNumberSelectionVC ()

// for cell color control in response to selection

@property (nonatomic, weak) TJBNumberSelectionCell *lastSelectedCell;

// for aiding the pinch GR

@property CGPoint lastPinchTouchOne;
@property CGPoint lastPinchTouchTwo;

@end

@implementation TJBNumberSelectionVC

static NSString * const reuseIdentifier = @"numberCell";

#pragma mark - Initialization

- (void)viewDidLoad
{
    // configure the navigation item
    
    self.navigationItem.title = self.titleString;
    
    // set the collection view's background color
    
    self.collectionView.backgroundColor = [UIColor whiteColor];
    
    // add cancel bar button item
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCancel
                                                                                  target: self
                                                                                  action: @selector(cancel)];
    [self.navigationItem setLeftBarButtonItem: cancelButton];
    
    // add gesture recognizers to collection view
    
    // tap GR
    
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget: self
                                                                            action: @selector(doubleTap:)];
    tapGR.numberOfTapsRequired = 2;
    tapGR.cancelsTouchesInView = NO;
    tapGR.delaysTouchesBegan = NO;
    tapGR.delaysTouchesEnded = NO;
    
    [self.collectionView addGestureRecognizer: tapGR];
    
    // pinch GR
    
    UIPinchGestureRecognizer *pinchGR = [[UIPinchGestureRecognizer alloc] initWithTarget: self
                                                                                  action: @selector(pinch:)];
    pinchGR.cancelsTouchesInView = YES;
    pinchGR.delaysTouchesBegan = NO;
    pinchGR.delaysTouchesEnded = NO;
    
    [self.collectionView addGestureRecognizer: pinchGR];
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return 500;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    TJBNumberSelectionCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier: @"basicCell"
                                                                             forIndexPath: indexPath];
    
    // configure the cell
    
    NSNumber *cellNumber = [NSNumber numberWithFloat: indexPath.item * [self.numberMultiple floatValue]];
    NSString *cellNumberAsString = [cellNumber stringValue];
    
    cell.numberLabel.text = cellNumberAsString;
    cell.numberLabel.backgroundColor = [UIColor lightGrayColor];
    cell.numberLabel.layer.cornerRadius = 4;
    cell.numberLabel.layer.masksToBounds = YES;
    cell.numberLabel.layer.opacity = 0.2;
    
    return cell;
}

#pragma mark <UICollectionViewDelegate>

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    // if there is a previously selected cell, change its color back to light gray
    if (self.lastSelectedCell)
        self.lastSelectedCell.numberLabel.backgroundColor = [UIColor whiteColor];
    
    // change the color of the newly selected cell
    TJBNumberSelectionCell *selectedCell = (TJBNumberSelectionCell *)[self.collectionView cellForItemAtIndexPath: indexPath];
    selectedCell.numberLabel.backgroundColor = [UIColor redColor];
    
    // update the lastSelectedCell property to point to the newly selected cell
    self.lastSelectedCell = selectedCell;
}

#pragma mark - Gesture Recognizer Actions

- (void)doubleTap:(UIGestureRecognizer *)gr
{
    // find the index path of the selected item
    CGPoint touchPoint = [gr locationInView: self.collectionView];
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint: touchPoint];
    
    // apply the numberMultiple to establish the correct selected number
    NSNumber *selectedNumber = [NSNumber numberWithFloat: indexPath.item * [self.numberMultiple floatValue]];
    
    // pass relevant data to the presenting VC
    [self.associatedVC didSelectNumber: selectedNumber];
}

- (void)pinch:(UIGestureRecognizer *)gr
{
    // get the GR's state and act accordingly
    UIGestureRecognizerState state = gr.state;
    
    if (state == UIGestureRecognizerStateBegan)
    {
        if (gr.numberOfTouches != 2)
            NSLog(@"\nnumber of touches not equal to 2\n");
        
        // if touches just began, simply record the two initial touches
        self.lastPinchTouchOne = [gr locationOfTouch: 0
                                              inView: self.collectionView];
        self.lastPinchTouchTwo = [gr locationOfTouch: 1
                                              inView: self.collectionView];
    }
    else if (state == UIGestureRecognizerStateChanged)
    {
        // if the state changes, update the cell's label size proportionally to the change in the distance between the fingers
        // grab the location of the current touches in the collection view's bounds
        CGPoint pinchTouchOne = [gr locationOfTouch: 0
                                             inView: self.collectionView];
        CGPoint pinchTouchTwo = [gr locationOfTouch: 1
                                             inView: self.collectionView];
        
        // grab the current flow layout object and relevant properties
        UICollectionViewFlowLayout *flowLayout = (UICollectionViewFlowLayout *)[self.collectionView collectionViewLayout];
        CGSize cellSize = flowLayout.itemSize;
        
        // calculate the old and current distances separating the fingers and compute their ratio
        CGFloat lastXDist = self.lastPinchTouchOne.x - self.lastPinchTouchTwo.x;
        CGFloat lastYDist = self.lastPinchTouchOne.y - self.lastPinchTouchTwo.y;
        
        CGFloat XDist = pinchTouchOne.x - pinchTouchTwo.x;
        CGFloat YDist = pinchTouchOne.y - pinchTouchTwo.y;
        
        CGFloat lastAggregateDist = sqrtf((lastXDist * lastXDist) + (lastYDist * lastYDist));
        CGFloat aggregateDist = sqrtf((XDist * XDist) + (YDist * YDist));
        
        CGFloat aggDistRatio = lastAggregateDist / aggregateDist;
        
        // adjust the cell size accordingly and assign it to the flow layout object
        cellSize.height *= aggDistRatio;
        cellSize.width *= aggDistRatio;
        [flowLayout setItemSize: cellSize];
        
        // assign the current touches to the old touches property in anticipation of more pinching
        self.lastPinchTouchOne = pinchTouchOne;
        self.lastPinchTouchTwo = pinchTouchTwo;
        
    } else if (state == UIGestureRecognizerStateEnded)
    {
        // deallocate the touches defined in the class extension to free memory
        // this is not necessary for functionality - the 'last touches' will be replaced when a new pinch gesture occurs
    }
}

#pragma mark - Bar Button Item Actions

- (void)cancel
{
    [self dismissViewControllerAnimated: YES
                             completion: nil];
}

@end





















