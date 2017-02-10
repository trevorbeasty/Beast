//
//  TJBActiveRoutineGuidanceVC.m
//  Beast
//
//  Created by Trevor Beasty on 2/9/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBActiveRoutineGuidanceVC.h"

// core data

#import "CoreDataController.h"

// child VC's

#import "TJBActiveRoutineExerciseItemVC.h"

@interface TJBActiveRoutineGuidanceVC ()

// IBOutlet

@property (weak, nonatomic) IBOutlet UILabel *roundTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *timerTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *alertTimingButton;
@property (weak, nonatomic) IBOutlet UIScrollView *contentScrollView;



// IBAction

// core

@property (nonatomic, strong) TJBChainTemplate *chainTemplate;

@property (nonatomic, strong) UIView *scrollContentView;
@property (nonatomic, strong) UILabel *nextUpLabel;
@property (nonatomic, strong) UIStackView *guidanceStackView;
@property (nonatomic, strong) NSMutableArray<TJBActiveRoutineExerciseItemVC *> *exerciseItemChildVCs;

// scroll content view

@property (nonatomic, strong) NSMutableDictionary *constraintMapping;

@end

@implementation TJBActiveRoutineGuidanceVC

#pragma mark - Instantiation

- (instancetype)initFreshRoutineWithChainTemplate:(TJBChainTemplate *)chainTemplate{
    
    self = [super init];
    
    self.chainTemplate = chainTemplate;
    
    return self;
    
}

#pragma mark - View Life Cycle

- (void)viewDidLoad{
    
    // get the scrollContentView and make it a subview of the scroll view
    
    [self.contentScrollView addSubview: [self scrollContentView]];
    
    
}

#pragma mark - Scroll View Content

static NSString const *nextUpLabelKey = @"nextUpLabel";
static NSString const *guidanceStackViewKey = @"guidanceStackView";

- (UIView *)scrollContentView{
    
    // prep
    
    [self.view layoutIfNeeded];
    
    self.constraintMapping = [[NSMutableDictionary alloc] init];
    self.exerciseItemChildVCs = [[NSMutableArray alloc] init];
    
    //// create the master view and give it the appropriate frame. Set the scroll view's content area according to the masterFrame's size
    
    CGFloat width = self.view.frame.size.width;
    CGFloat height = 800.0;
    CGRect masterFrame = CGRectMake(0, 0, width, height);
    
    [self.contentScrollView setContentSize: CGSizeMake(width, height)];
    
    UIView *masterView = [[UIView alloc] initWithFrame: masterFrame];
    masterView.backgroundColor = [UIColor redColor];
    
    self.scrollContentView = masterView;
    
    //// create the 'next up' label and pin it to the top of the master view
    
    // label creation and text configuration
    
    UILabel *nextUpLabel = [[UILabel alloc] init];
    nextUpLabel.text = @"Next Up";
    nextUpLabel.backgroundColor = [UIColor darkGrayColor];
    nextUpLabel.textColor = [UIColor whiteColor];
    nextUpLabel.font = [UIFont boldSystemFontOfSize: 30.0];
    nextUpLabel.textAlignment = NSTextAlignmentCenter;
    nextUpLabel.translatesAutoresizingMaskIntoConstraints = NO;
    
    self.nextUpLabel = nextUpLabel;
    
    // constraints
    
    [self.constraintMapping setObject: nextUpLabel
                               forKey: nextUpLabelKey];
    [masterView addSubview: nextUpLabel];
    
    NSArray *nextUpLabelHorC = [NSLayoutConstraint constraintsWithVisualFormat: @"H:|-0-[nextUpLabel]-0-|"
                                                                       options: 0
                                                                       metrics: nil
                                                                         views: self.constraintMapping];
    NSArray *nextUpLabelVerC = [NSLayoutConstraint constraintsWithVisualFormat: @"V:|-0-[nextUpLabel(==50)]"
                                                                       options: 0
                                                                       metrics: nil
                                                                         views: self.constraintMapping];
    
    [masterView addConstraints: nextUpLabelHorC];
    [masterView addConstraints: nextUpLabelVerC];
    
    //// create and add on a stack view.  This stack view will fill the rest of the scrollable content and its individual views will be the immediate targets along with previous marks
    
    UIStackView *guidanceStackView = [[UIStackView alloc] init];
    guidanceStackView.axis = UILayoutConstraintAxisVertical;
    guidanceStackView.distribution = UIStackViewDistributionFillEqually;
    guidanceStackView.alignment = UIStackViewDistributionFillEqually;
    guidanceStackView.spacing = 0;
    
    guidanceStackView.translatesAutoresizingMaskIntoConstraints = NO;
    
    // layout constraints
    
    [self.constraintMapping setObject: guidanceStackView
                               forKey: guidanceStackViewKey];
    [masterView addSubview: guidanceStackView];
    
    NSArray *guidanceStackViewHorC = [NSLayoutConstraint constraintsWithVisualFormat: @"H:|-0-[guidanceStackView]-0-|"
                                                                             options: 0
                                                                             metrics: nil
                                                                               views: self.constraintMapping];
    NSArray *guidanceStackViewVerC = [NSLayoutConstraint constraintsWithVisualFormat: @"V:|-0-[guidanceStackView]-0-|"
                                                                             options: 0
                                                                             metrics: nil
                                                                               views: self.constraintMapping];
    
    [masterView addConstraints: guidanceStackViewHorC];
    [masterView addConstraints: guidanceStackViewVerC];
    
    // add views to the guidance stack view
    
    for (int i = 0; i < 3; i++){
        
        TJBActiveRoutineExerciseItemVC *exerciseItemVC = [[TJBActiveRoutineExerciseItemVC alloc] initWithTitleNumber: [NSNumber numberWithInt: 1]
                                                                                                  targetExerciseName: @"Bench Press"
                                                                                                        targetWeight: [NSNumber numberWithInt: 205]
                                                                                                          targetReps: [NSNumber numberWithInt: 8]
                                                                                                     previousEntries: nil];
        [self.exerciseItemChildVCs addObject: exerciseItemVC];
        [self addChildViewController: exerciseItemVC];
        
        [guidanceStackView addArrangedSubview: exerciseItemVC.view];
        
        [exerciseItemVC didMoveToParentViewController: self];
        
    }
    
    //
    
    return masterView;
    
}






@end



























