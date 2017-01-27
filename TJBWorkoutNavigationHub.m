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

{
    // state
    
    int _activeSelectionIndex;
}

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
    
    [self configureGestureRecognizers];
    
}

- (void)configureGestureRecognizers{
    
    // left swipe GR
    
    UISwipeGestureRecognizer *leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget: self
                                                                                    action: @selector(didSwipeLeft)];
    
    leftSwipe.direction = UISwipeGestureRecognizerDirectionLeft;
    leftSwipe.numberOfTouchesRequired = 1;
    
    [self.view addGestureRecognizer: leftSwipe];
    
    // right swipe GR
    
    UISwipeGestureRecognizer *rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget: self
                                                                                    action: @selector(didSwipeRight)];
    
    rightSwipe.direction = UISwipeGestureRecognizerDirectionRight;
    rightSwipe.numberOfTouchesRequired = 1;
    
    [self.view addGestureRecognizer: rightSwipe];
    
}

- (void)configureCircleDates{
    
    // active selection index
    
    _activeSelectionIndex = 6;
    
    self.circleDateChildren = [[NSMutableArray alloc] init];
    
    CGFloat screenWidth = [UIScreen mainScreen].bounds.size.width;
    
    int numberOfDateButtons = 7;
    float dateButtonSpacing = 8.0;
    CGFloat buttonWidth = (screenWidth - (numberOfDateButtons - 1) * dateButtonSpacing) / (float)numberOfDateButtons;
    
    CGFloat buttonHeight = 40;
    float buttonCenterY = buttonHeight / 2.0;
    
    CGPoint center = CGPointMake(buttonWidth / 2.0, buttonCenterY);
    
    // calendar
    
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier: NSCalendarIdentifierGregorian];
    NSDateComponents *dateComps = [[NSDateComponents alloc] init];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    
    int dayOffset;
    NSDate *iterativeDate;
    
    BOOL selected;
    
    for (int i = 0; i < numberOfDateButtons; i++){
        
        // using the activeDate as the fourth button, configure all buttons with the appropriate date
        
        dayOffset = -6 + i;
        dateComps.day = dayOffset;
        
        iterativeDate = [calendar dateByAddingComponents: dateComps
                                                  toDate: self.activeDate
                                                 options: 0];
        
        dateFormatter.dateFormat = @"E";
        NSString *day = [dateFormatter stringFromDate: iterativeDate];
        
        dateFormatter.dateFormat = @"d";
        NSString *buttonTitle = [dateFormatter stringFromDate: iterativeDate];
        
        if (i == 6){
            
            selected = YES;
            
        } else{
            
            selected = NO;
            
        }
        
        // create the child vc
        
        TJBCircleDateVC *circleDateVC = [[TJBCircleDateVC alloc] initWithMainButtonTitle: buttonTitle
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

#pragma mark - Gesture Recognizer Actions

- (void)didSwipeLeft{
    
    [self incrementActiveDateByNumberOfDaysAndRefreshCircleDates: -1];
    
}

- (void)didSwipeRight{
    
    [self incrementActiveDateByNumberOfDaysAndRefreshCircleDates: 1];
    
}

- (void)incrementActiveDateByNumberOfDaysAndRefreshCircleDates:(int)numberOfDays{
    
    // active date
    
    NSCalendar *calendar = [NSCalendar calendarWithIdentifier: NSCalendarIdentifierGregorian];
    
    BOOL atMaxDate = [calendar isDateInToday: self.activeDate];
    
    if (!atMaxDate){
        
        NSDateComponents *dateComps = [[NSDateComponents alloc] init];
        dateComps.day = numberOfDays;
        
        NSDate *newDate = [calendar dateByAddingComponents: dateComps
                                                    toDate: self.activeDate
                                                   options: 0];
        
        self.activeDate = newDate;
        
    }
    

    
    // active index and date button appearance
    
    BOOL atRightExtreme = _activeSelectionIndex == 6 && numberOfDays == 1;
    BOOL atLeftExtreme = _activeSelectionIndex == 0 && numberOfDays == -1;
    
    
    if (!atRightExtreme && !atLeftExtreme){
        
        TJBCircleDateVC *circleDateVC =  self.circleDateChildren[_activeSelectionIndex];
        [circleDateVC configureButtonAsNotSelected];
        
        _activeSelectionIndex += numberOfDays;
        
        circleDateVC =  self.circleDateChildren[_activeSelectionIndex];
        [circleDateVC configureButtonAsSelected];
        
    } else if (atLeftExtreme){
        
        // give the date buttons new titles
        
        // change the selected date button
        
    } else if (atRightExtreme && !atMaxDate){
        
        
        
    }
    

    
}


@end





























