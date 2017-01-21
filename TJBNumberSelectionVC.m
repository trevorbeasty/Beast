//
//  TJBNumberSelectionVC.m
//  Beast
//
//  Created by Trevor Beasty on 12/7/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import "TJBNumberSelectionVC.h"

//#import "TJBNumberSelectionCell.h"
#import "TJBBasicCollectionViewCell.h"

#import "TJBStopwatch.h"

#import "TJBAestheticsController.h"

@interface TJBNumberSelectionVC () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>
// core variables set in init methods
{
    NumberType _numberTypeIdentifier;
}

// core variables set in init methods
@property (nonatomic, strong) NSNumber *numberMultiple;
@property (nonatomic, strong) NSNumber *numberLimit;
@property (copy) void (^cancelBlock)(void);
@property (copy) void (^numberSelectedBlock)(NSNumber *);
@property (nonatomic, strong) NSString *selectionTitle;

// for cell color control in response to selection
// should this be a strong or weak property?
@property (nonatomic, weak) TJBBasicCollectionViewCell *lastSelectedCell;
// for state restoration
@property (nonatomic, strong) NSIndexPath *highlightedCellPath;

// for aiding the pinch GR
@property CGPoint lastPinchTouchOne;
@property CGPoint lastPinchTouchTwo;

// IBOutlets
@property (weak, nonatomic) IBOutlet UINavigationBar *navBar;
@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@end

static NSString * const reuseIdentifier = @"basicCell";

@implementation TJBNumberSelectionVC

#pragma mark - Instantiation

- (instancetype)initWithNumberTypeIdentifier:(NumberType)numberType numberMultiple:(NSNumber *)numberMultiple numberLimit:(NSNumber *)numberLimit title:(NSString *)title cancelBlock:(void (^)(void))cancelBlock numberSelectedBlock:(void (^)(NSNumber *))numberSelectedBlock{

    self = [super init];
    
    _numberTypeIdentifier = numberType;
    self.numberMultiple = numberMultiple;
    self.numberLimit = numberLimit;
    self.selectionTitle = title;
    self.cancelBlock = cancelBlock;
    self.numberSelectedBlock = numberSelectedBlock;
    
    return self;
    
}

#pragma mark - View Life Cycle

- (void)viewDidLoad{
    
    // collection view
    
    UINib *nib = [UINib nibWithNibName: @"TJBBasicCollectionViewCell"
                                bundle: nil];
    [self.collectionView registerNib: nib
          forCellWithReuseIdentifier: reuseIdentifier];

    //// add gesture recognizers to collection view
    
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
    
    // other methods
    
    [self addBackgroundView];
    
    [self configureNavigationBar];
    
}

- (void)configureNavigationBar{
    
    UINavigationItem *navItem = [[UINavigationItem alloc] initWithTitle: self.selectionTitle];
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemCancel
                                                                                  target: self
                                                                                  action: @selector(cancel)];
    
    [navItem setLeftBarButtonItem: cancelButton];
    
    [self.navBar setItems: @[navItem]];
    
    // nav bar text appearance
    
    [self.navBar setTitleTextAttributes: @{NSFontAttributeName: [UIFont boldSystemFontOfSize: 20.0]}];
    
}

- (void)addBackgroundView{
    UIImage *image = [UIImage imageNamed: @"pileOfPlates"];
    UIImageView *imageView = [[UIImageView alloc] initWithImage: image];
    imageView.layer.opacity = .9;
    self.collectionView.backgroundView = imageView;
}

#pragma mark <UICollectionViewDataSource>

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView{
    return 1;
}


- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    return 500;
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

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
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

#pragma mark - Gesture Recognizer Actions

- (void)doubleTap:(UIGestureRecognizer *)gr
{
    // find the index path of the selected item
    
    CGPoint touchPoint = [gr locationInView: self.collectionView];
    
    NSIndexPath *indexPath = [self.collectionView indexPathForItemAtPoint: touchPoint];
    
    // apply the numberMultiple to establish the correct selected number
    
    NSNumber *selectedNumber = [NSNumber numberWithFloat: indexPath.item * [self.numberMultiple floatValue]];
    
    // pass relevant data to the presenting VC
    
    self.numberSelectedBlock(selectedNumber);
    
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
        
    } 
}

#pragma mark - Bar Button Item Actions

- (void)cancel{
    
    self.cancelBlock();
    
}


@end





















