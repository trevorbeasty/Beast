//
//  TJBCircuitTemplateContainerVC.m
//  Beast
//
//  Created by Trevor Beasty on 1/10/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBCircuitTemplateContainerVC.h"

#import "TJBCircuitTemplateVC.h"

@interface TJBCircuitTemplateContainerVC ()

// IBOutlet

@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIButton *launchCircuitButton;
@property (weak, nonatomic) IBOutlet UINavigationBar *navigationBar;

// IBAction

- (IBAction)didPressLaunchCircuit:(id)sender;

// core

@property (nonatomic, strong) NSNumber *targetingWeight;
@property (nonatomic, strong) NSNumber *targetingReps;
@property (nonatomic, strong) NSNumber *targetingRest;
@property (nonatomic, strong) NSNumber *targetsVaryByRound;
@property (nonatomic, strong) NSNumber *numberOfExercises;
@property (nonatomic, strong) NSNumber *numberOfRounds;
@property (nonatomic, strong) NSString *name;


@end

@implementation TJBCircuitTemplateContainerVC

#pragma mark - Instantiation

- (instancetype)initWithTargetingWeight:(NSNumber *)targetingWeight targetingReps:(NSNumber *)targetingReps targetingRest:(NSNumber *)targetingRest targetsVaryByRound:(NSNumber *)targetsVaryByRound numberOfExercises:(NSNumber *)numberOfExercises numberOfRounds:(NSNumber *)numberOfRounds name:(NSString *)name{
    
    self = [super init];
    
    // core
    
    self.targetingWeight = targetingWeight;
    self.targetingReps = targetingReps;
    self.targetingRest = targetingRest;
    self.targetsVaryByRound = targetsVaryByRound;
    self.numberOfExercises = numberOfExercises;
    self.numberOfRounds = numberOfRounds;
    self.name = name;

    return self;
    
}

#pragma mark - View Life Cycle

- (void)viewDidLoad{
    
    [self configureContainerView];
    
    [self configureNavigationBar];

}

- (void)configureContainerView{
    
    // create a TJBCircuitTemplateVC with the dimensions of the containerView
    
//    float viewHeightAsFloat = self.containerView.bounds.size.height;
//    float viewWidthAsFloat = self.containerView.bounds.size.width;
//    
//    NSNumber *viewHeight = [NSNumber numberWithFloat: viewHeightAsFloat];
//    NSNumber *viewWidth = [NSNumber numberWithFloat: viewWidthAsFloat];
    
    CGSize mainscreenSize = [UIScreen mainScreen].bounds.size;
    
    // due to scroll view's issues with auto layout and the fact that accessing containerView's bounds literally takes the dimensions in the xib, no matter what size the xib view is, I have to do this little bit of math
    // to properly do this, I will have to create IBOutlets for the auto layout constraints set in the xib file
    
    NSNumber *viewHeight = [NSNumber numberWithFloat: mainscreenSize.height - 124];
    NSNumber *viewWidth = [NSNumber numberWithFloat: mainscreenSize.width - 16];
    
    TJBCircuitTemplateVC *vc = [[TJBCircuitTemplateVC alloc] initWithTargetingWeight: self.targetingWeight
                                                                       targetingReps: self.targetingReps
                                                                       targetingRest: self.targetingRest
                                                                  targetsVaryByRound: self.targetsVaryByRound
                                                                   numberOfExercises: self.numberOfExercises
                                                                      numberOfRounds: self.numberOfRounds
                                                                                name: self.name
                                                                          viewHeight: viewHeight
                                                                           viewWidth: viewWidth];
    
    [self addChildViewController: vc];
    
    [self.containerView addSubview: vc.view];
    
    [vc didMoveToParentViewController: self];
}

- (void)configureNavigationBar{
    
    // create the navigation item
    
    UINavigationItem *navItem = [[UINavigationItem alloc] init];
    
    // must evaluate IV's to determine appropriate title for navItem
    
    NSString *word;
    int number = [self.numberOfRounds intValue];
    
    if (number == 1){
        
        word = @"round";
        
    } else{
        
        word = @"rounds";
        
    }
    
    NSString *title = [NSString stringWithFormat: @"%@ (%d %@)",
                       self.name,
                       number,
                       word];
    
    [navItem setTitle: title];
    
    // add a navigation bar button as well
    
        
    UIBarButtonItem *xBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemStop
                                                                                target: self
                                                                                action: @selector(didPressX)];
    [navItem setLeftBarButtonItem: xBarButton];
    
    UIBarButtonItem *goBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem: UIBarButtonSystemItemAdd
                                                                                 target: self
                                                                                 action: @selector(didPressAdd)];
    [navItem setRightBarButtonItem: goBarButton];
    
    // set the items of the navigation bar
    
    [self.navigationBar setItems: @[navItem]];
}

#pragma mark - Button Actions

- (IBAction)didPressLaunchCircuit:(id)sender {
    NSLog(@"didPressLaunchCircuit");
}

- (void)didPressX{
    
    [self dismissViewControllerAnimated: NO
                             completion: nil];
    
}

- (void)didPressAdd{
    NSLog(@"didPressAdd");
}

@end



























































