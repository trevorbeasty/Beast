//
//  TJBWorkoutNavigationHub.m
//  Beast
//
//  Created by Trevor Beasty on 12/12/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import "TJBWorkoutNavigationHub.h"


#import "TJBCircuitDesignVC.h"

#import "TJBAestheticsController.h"

#import "NewOrExistinigCircuitVC.h"

#import "TJBRealizedSetActiveEntryTBC.h"

#import "TJBNumberSelectionVC.h"

#import "TJBCircuitReferenceVC.h"

// history

#import "TJBCompleteHistoryVC.h"

// circle dates

#import "TJBCircleDateVC.h"




@interface TJBWorkoutNavigationHub ()

// IBOutlet

@property (weak, nonatomic) IBOutlet UIButton *freeformButton;
@property (weak, nonatomic) IBOutlet UIButton *designedButton;
@property (weak, nonatomic) IBOutlet UIScrollView *dateScrollView;
@property (weak, nonatomic) IBOutlet UIStackView *dateStackView;



// IBAction

- (IBAction)didPressFreeformButton:(id)sender;
- (IBAction)didPressDesignedButton:(id)sender;

// circle dates

@property (nonatomic, strong) NSMutableArray <TJBCircleDateVC *> *circleDateChildren;

@end

@implementation TJBWorkoutNavigationHub

#pragma mark - Instantiation

- (instancetype)init{
    self = [super init];
    
    // for restoration
    self.restorationClass = [TJBWorkoutNavigationHub class];
    self.restorationIdentifier = @"TJBWorkoutNavigationHub";
    
    return self;
}

#pragma mark - View Life Cycle

- (void)viewDidLoad{
    
    [self configureViewAesthetics];
    
    [self configureCircleDates];
    
    
}

//- (void)viewWillAppear:(BOOL)animated{
//    
//    for (TJBCircleDateVC *vc in self.circleDateChildren){
//        
//        CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
//        
//        float numberOfDateButtons = 5;
//        float dateButtonSpacing = 8;
//        CGFloat buttonWidth = (screenWidth - (numberOfDateButtons - 1) * dateButtonSpacing) / numberOfDateButtons;
//        
//        CGFloat buttonHeight = 100;
//        
//        CGSize buttonSize = CGSizeMake(buttonWidth , buttonHeight);
//        
//        [vc configureButtonMaskWithButtonSize: buttonSize];
//        
//    }
//    
//    
//}

- (void)configureCircleDates{
    
    int limit = 5;
    
    self.circleDateChildren = [[NSMutableArray alloc] init];
    
            CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    
            float numberOfDateButtons = 5.0;
            float dateButtonSpacing = 8.0;
            CGFloat buttonWidth = (screenWidth - (numberOfDateButtons - 1) * dateButtonSpacing) / numberOfDateButtons;
    
            CGFloat buttonHeight = 100;
    
            CGSize buttonSize = CGSizeMake(buttonWidth , buttonHeight);
    
    for (int i = 0; i < limit; i++){
        
        NSString *title = [NSString stringWithFormat: @"%d", i];
        
        TJBCircleDateVC *circleDateVC = [[TJBCircleDateVC alloc] initWithMainButtonTitle: title
                                                                                    size: buttonSize];
        
        [self.circleDateChildren addObject: circleDateVC];
        
        [self addChildViewController: circleDateVC];
        
        [self.dateStackView addArrangedSubview: circleDateVC.view];
        
        [circleDateVC didMoveToParentViewController: self];
        
    }
    
}

- (void)configureViewAesthetics{
    
    NSArray *buttons = @[self.freeformButton,
                         self.designedButton];
    
    for (UIButton *button in buttons){
        
        button.backgroundColor = [[TJBAestheticsController singleton] color2];
        [button setTitleColor: [UIColor whiteColor]
                     forState: UIControlStateNormal];
        
    }
    
}


#pragma mark - Button Actions


- (IBAction)didPressFreeformButton:(id)sender {
    
    TJBRealizedSetActiveEntryTBC *tbc = [[TJBRealizedSetActiveEntryTBC alloc] initWithChildViewControllers];
    
    [self presentViewController: tbc
                       animated: YES
                     completion: nil];
    
}




- (void)didPressDesignedButton:(id)sender{
    
    NewOrExistinigCircuitVC *vc = [[NewOrExistinigCircuitVC alloc] init];
    
    [self presentViewController: vc
                       animated: YES
                     completion: nil];
    
}


@end





























