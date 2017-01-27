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
@property (weak, nonatomic) IBOutlet UIStackView *dateStackView;



// IBAction

- (IBAction)didPressFreeformButton:(id)sender;
- (IBAction)didPressDesignedButton:(id)sender;

// circle dates

@property (nonatomic, strong) NSMutableArray <TJBCircleDateVC *> *circleDateChildren;

// state variables

@property (nonatomic, strong) NSDate *activeDate;

@end

@implementation TJBWorkoutNavigationHub

#pragma mark - Instantiation

- (instancetype)init{
    
    self = [super init];
    
    // for restoration
    
    self.restorationClass = [TJBWorkoutNavigationHub class];
    self.restorationIdentifier = @"TJBWorkoutNavigationHub";
    
    // state
    
    self.activeDate = [NSDate date];
    
    return self;
}

#pragma mark - View Life Cycle

- (void)viewDidLoad{
    
    [self configureViewAesthetics];
    
    [self configureCircleDates];
    
    
}

- (void)configureCircleDates{
    
    self.circleDateChildren = [[NSMutableArray alloc] init];
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    int numberOfDateButtons = 7;
    float dateButtonSpacing = 8.0;
    CGFloat buttonWidth = (screenWidth - (numberOfDateButtons - 1) * dateButtonSpacing) / (float)numberOfDateButtons;
    
    CGFloat buttonHeight = 40;
//    CGFloat dayLabelHeight = 20;
    float buttonCenterY = buttonHeight / 2.0;
    
    CGPoint center = CGPointMake(buttonWidth / 2.0, buttonCenterY);
    
    // calendar
    
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier: NSCalendarIdentifierGregorian];
    NSDateComponents *dateComps = [[NSDateComponents alloc] init];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateFormat = @"E";
    
    int dayOffset;
    NSDate *iterativeDate;
    
    BOOL selected;
    
    for (int i = 0; i < numberOfDateButtons; i++){
        
        // using the activeDate as the fourth button, configure all buttons with the appropriate date
        
        dayOffset = -3 + i;
        dateComps.day = dayOffset;
        
        iterativeDate = [calendar dateByAddingComponents: dateComps
                                                  toDate: self.activeDate
                                                 options: 0];
        
        NSString *day = [dateFormatter stringFromDate: iterativeDate];
        
        if (i == 3){
            
            selected = YES;
            
        } else{
            
            selected = NO;
            
        }
        
        // create the child vc
        
        NSString *title = [NSString stringWithFormat: @"%d", i + 1];
        
        TJBCircleDateVC *circleDateVC = [[TJBCircleDateVC alloc] initWithMainButtonTitle: title
                                                                                dayTitle: day
                                                                                  radius: buttonWidth / 2.0
                                                                                  center: center
                                                                      selectedAppearance: selected];
        
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





























