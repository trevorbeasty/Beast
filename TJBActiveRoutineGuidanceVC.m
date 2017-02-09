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

- (UIView *)scrollContentView{
    
    // prep
    
    [self.view layoutIfNeeded];
    
    self.constraintMapping = [[NSMutableDictionary alloc] init];
    
    //// create the master view and give it the appropriate frame. Set the scroll view's content area according to the masterFrame's size
    
    CGFloat width = self.view.frame.size.width;
    CGFloat height = 2000.0;
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
    nextUpLabel.font = [UIFont boldSystemFontOfSize: 20.0];
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
    NSArray *nextUpLabelVerC = [NSLayoutConstraint constraintsWithVisualFormat: @"V:|-0-[nextUpLabel(==40)]"
                                                                       options: 0
                                                                       metrics: nil
                                                                         views: self.constraintMapping];
    
    [masterView addConstraints: nextUpLabelHorC];
    [masterView addConstraints: nextUpLabelVerC];
    
    return masterView;
    
}






@end



























