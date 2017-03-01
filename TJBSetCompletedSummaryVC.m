//
//  TJBSetCompletedSummaryVC.m
//  Beast
//
//  Created by Trevor Beasty on 2/28/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBSetCompletedSummaryVC.h"

// aesthetics

#import "TJBAestheticsController.h"

@interface TJBSetCompletedSummaryVC ()

// IBOutlet

@property (weak, nonatomic) IBOutlet UIView *contentContainerView;
@property (weak, nonatomic) IBOutlet UILabel *exerciseLabel;
@property (weak, nonatomic) IBOutlet UILabel *weightLabel;
@property (weak, nonatomic) IBOutlet UILabel *repsLabel;
@property (weak, nonatomic) IBOutlet UILabel *pressAnywhereLabel;
@property (weak, nonatomic) IBOutlet UILabel *setCompletedLabel;

// core

@property (strong) NSString *exerciseName;
@property (strong) NSNumber *weight;
@property (strong) NSNumber *reps;
@property (strong) TJBCompletedSetCallback callbackBlock;


@end

@implementation TJBSetCompletedSummaryVC

#pragma mark - Instantiation

- (instancetype)initWithExerciseName:(NSString *)exerciseName weight:(NSNumber *)weight reps:(NSNumber *)reps callbackBlock:(TJBCompletedSetCallback)callbackBlock{
    
    self = [super init];
    
    self.exerciseName = exerciseName;
    self.weight = weight;
    self.reps = reps;
    self.callbackBlock = callbackBlock;
    
    return self;
    
}

#pragma mark - View Life Cycle

- (void)viewDidLoad{
    
    [self configureViewAesthetics];
    
    [self configureGestureRecognizer];
    
    [self configureDisplay];
    
}

- (void)viewWillAppear:(BOOL)animated{
    
    [self configureVisualEffectView];
    
}

- (void)configureVisualEffectView{
    
    UIBlurEffect *blur = [UIBlurEffect effectWithStyle: UIBlurEffectStyleDark];
    UIVisualEffectView *visualEffectView = [[UIVisualEffectView alloc] initWithEffect: blur];
    
    visualEffectView.frame = self.view.bounds;
    
    [self.view addSubview: visualEffectView];
    
    [visualEffectView.contentView addSubview: self.contentContainerView];
    
}

- (void)configureDisplay{
    
    self.exerciseLabel.text = self.exerciseName;
    
    NSString *weightText = [NSString stringWithFormat: @"%@ lbs", [self.weight stringValue]];
    NSString *repsText = [NSString stringWithFormat: @"%@ reps", [self.reps stringValue]];
    
    self.weightLabel.text = weightText;
    self.repsLabel.text = repsText;
    
}

- (void)configureViewAesthetics{
    
    // content container
    
    self.contentContainerView.layer.masksToBounds = YES;
    self.contentContainerView.layer.cornerRadius = 4.0;
    
    self.contentContainerView.backgroundColor = [UIColor lightGrayColor];
    
    // title labels
    
    NSArray *titleLabels = @[self.setCompletedLabel, self.pressAnywhereLabel];
    for (UILabel *lab in titleLabels){
        
        lab.backgroundColor = [UIColor clearColor];
        lab.textColor = [UIColor whiteColor];
        
    }
    
    self.exerciseLabel.font = [UIFont boldSystemFontOfSize: 20];
    self.pressAnywhereLabel.font = [UIFont boldSystemFontOfSize: 15];
    
    // detail labels
    
    NSArray *detailLabels = @[self.exerciseLabel, self.weightLabel, self.repsLabel];
    for (UILabel *lab in detailLabels){
        
        lab.backgroundColor = [[TJBAestheticsController singleton] yellowNotebookColor];
        lab.textColor = [UIColor blackColor];
        lab.font = [UIFont boldSystemFontOfSize: 20];
        
    }
    
}

- (void)configureGestureRecognizer{
    
    UITapGestureRecognizer *tapGR = [[UITapGestureRecognizer alloc] initWithTarget: self
                                                                            action: @selector(didTap)];
    
    tapGR.numberOfTouchesRequired = 1;
    tapGR.numberOfTapsRequired = 1;
    
    
    [self.view addGestureRecognizer: tapGR];

}

#pragma mark - Tap GR

- (void)didTap{
    
    self.callbackBlock();
    
}

@end






















