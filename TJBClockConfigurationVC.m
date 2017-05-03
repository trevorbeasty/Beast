//
//  TJBClockConfigurationVC.m
//  Beast
//
//  Created by Trevor Beasty on 4/1/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBClockConfigurationVC.h"

// aesthetics

#import "TJBAestheticsController.h"

// stopwatch

#import "TJBStopwatch.h"

// number selection

#import "TJBNumberSelectionVC.h"

@interface TJBClockConfigurationVC () <TJBStopwatchObserver>

{
    
    BOOL _restTargetIsStatic;
    
}

// IBOutlet

@property (weak, nonatomic) IBOutlet UILabel *myTimerLabel;
@property (weak, nonatomic) IBOutlet UILabel *timerValueLabel;

@property (weak, nonatomic) IBOutlet UILabel *targetRestTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *targetRestValueLabel;
@property (weak, nonatomic) IBOutlet UILabel *alertTimingTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *alertTiimingValueLabel;

@property (weak, nonatomic) IBOutlet UIButton *editButtonTargetRest;
@property (weak, nonatomic) IBOutlet UIButton *editButtonAlertTiming;

@property (weak, nonatomic) IBOutlet UIView *topTitleBar;
@property (weak, nonatomic) IBOutlet UIView *bottomTitleBar;
@property (weak, nonatomic) IBOutlet UIView *titleBarContainer;

@property (weak, nonatomic) IBOutlet UILabel *thinDividerLabel;

@property (weak, nonatomic) IBOutlet UIButton *restartButton;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (weak, nonatomic) IBOutlet UIButton *pauseButton;
//@property (weak, nonatomic) IBOutlet UIView *timerControlsContainer;
//@property (weak, nonatomic) IBOutlet UILabel *timerControlsTitleLabel;
@property (weak, nonatomic) IBOutlet UIButton *clearButton;

@property (weak, nonatomic) IBOutlet UIButton *returnButton;

@property (weak, nonatomic) IBOutlet UILabel *scheduledAlertLabel;


// IBAction

//- (IBAction)didPressSound:(id)sender;
- (IBAction)didPressExit:(id)sender;

- (IBAction)didPressEditTargetRest:(id)sender;
- (IBAction)didPressEditAlertTiming:(id)sender;

- (IBAction)didPressRestart:(id)sender;
- (IBAction)didPressPause:(id)sender;
- (IBAction)didPressPlay:(id)sender;

- (IBAction)didPressReturn:(id)sender;
- (IBAction)didPressClearButton:(id)sender;


// callback

@property (copy) VoidBlock cancelBlock;
@property (copy) AlertParametersBlock applyAlertParamBlock;

// core

@property (strong) NSNumber *selectedTargetRest;
@property (strong) NSNumber *selectedAlertTiming;



@end

@implementation TJBClockConfigurationVC

#pragma mark - Instantiation


- (instancetype)initWithApplyAlertParametersCallback:(AlertParametersBlock)applyAlertParamBlock cancelCallback:(VoidBlock)cancelBlock{
    
    self = [super init];
    
    self.cancelBlock = cancelBlock;
    self.applyAlertParamBlock = applyAlertParamBlock;
    
    _restTargetIsStatic = NO;
    
    return self;
    
}

- (instancetype)initWithApplyAlertParametersCallback:(AlertParametersBlock)applyAlertParamBlock cancelCallback:(VoidBlock)cancelBlock restTargetIsStatic:(BOOL)restTargetIsStatic{
    
    self = [super init];
    
    self.cancelBlock = cancelBlock;
    self.applyAlertParamBlock = applyAlertParamBlock;
    
    _restTargetIsStatic = restTargetIsStatic;
    
    return self;
    
}

#pragma mark - Instantiation Helper Methods


#pragma mark - View Life Cycle

- (void)viewDidLoad{
    
    [super viewDidLoad];
    
    [self configureViewAesthetics];
    
    [self configureScheduledAlertLabelText];
    
    [self copyStopwatchTargetsIfExist];
    
    if (_restTargetIsStatic == YES){
        
        [self configureForStaticRestTarget];
        
    }
    
    [self registerTimerValueLabelWithStopwatch];
    [[TJBStopwatch singleton]  updatePrimaryTimerLabels];
    
    
}



#pragma mark - View Helper Methods

- (void)configureForStaticRestTarget{
    
    self.editButtonTargetRest.hidden = YES;
    self.selectedTargetRest = [TJBStopwatch singleton].targetRest;
    
}

- (void)configureScheduledAlertLabelText{
    
    TJBStopwatch *stopwatch = [TJBStopwatch singleton];
    
    if (stopwatch.targetRest && stopwatch.alertTiming){
        
        int alertValue = [stopwatch.targetRest intValue] - [stopwatch.alertTiming intValue];
        NSString *formattedValue = [stopwatch minutesAndSecondsStringFromNumberOfSeconds: alertValue];
        NSString *scheduledAlertText = [NSString stringWithFormat: @"Alert at %@", formattedValue];
        self.scheduledAlertLabel.text = scheduledAlertText;
        
    }
    
}

- (void)copyStopwatchTargetsIfExist{
    
    // have this controller start with the targets in the stopwatch, if they exist
    
    TJBStopwatch *stopwatch = [TJBStopwatch singleton];
    NSNumber *stopwatchRestTarget = stopwatch.targetRest;
    NSNumber *stopwatchAlertTiming = stopwatch.alertTiming;
    
    if (stopwatchRestTarget){
        
        self.selectedTargetRest = stopwatchRestTarget;
        
        NSString *formattedRest = [stopwatch minutesAndSecondsStringFromNumberOfSeconds: [stopwatchRestTarget intValue]];
        self.targetRestValueLabel.text = formattedRest;
        
    }
    
    if (stopwatchAlertTiming){
        
        self.selectedAlertTiming = stopwatchAlertTiming;
        
        NSString *formattedAlert = [stopwatch minutesAndSecondsStringFromNumberOfSeconds: [stopwatchAlertTiming intValue]];
        self.alertTiimingValueLabel.text = formattedAlert;
        
    }
    
    
        
}


- (void)configureViewAesthetics{
    
    [self.view layoutIfNeeded];
    
    // scheduled alert label
    
    self.scheduledAlertLabel.font = [UIFont boldSystemFontOfSize: 15];
    self.scheduledAlertLabel.backgroundColor = [UIColor grayColor];
    self.scheduledAlertLabel.textColor = [UIColor whiteColor];
    
    // title bars and container
    
    self.topTitleBar.backgroundColor = [UIColor darkGrayColor];
    self.bottomTitleBar.backgroundColor = [UIColor darkGrayColor];
    self.titleBarContainer.backgroundColor = [UIColor blackColor];
    
    // meta view
    
    self.view.backgroundColor = [[TJBAestheticsController singleton] yellowNotebookColor];
    
    // divider label
    
    self.thinDividerLabel.backgroundColor = [UIColor blackColor];
    
    // time labels
    
    self.timerValueLabel.backgroundColor = [UIColor clearColor];
    self.timerValueLabel.font = [UIFont systemFontOfSize: 35];
    self.timerValueLabel.textColor = [UIColor whiteColor];
    
    NSArray *restTitleLabels = @[self.targetRestTitleLabel, self.alertTimingTitleLabel];
    for (UILabel *lab in restTitleLabels){
        
        lab.backgroundColor = [UIColor clearColor];
        lab.font = [UIFont systemFontOfSize: 15];
        lab.textColor = [UIColor blackColor];
        
    }
    
    NSArray *restValueLabels = @[self.targetRestValueLabel, self.alertTiimingValueLabel];
    for (UILabel *lab in restValueLabels){
        
        lab.backgroundColor = [UIColor clearColor];
        lab.font = [UIFont systemFontOfSize: 35];
        lab.textColor = [UIColor blackColor];
        
    }
    
    // buttons
    
    NSArray *iconButtons = @[self.restartButton, self.pauseButton, self.playButton];
    for (UIButton *butt in iconButtons){
        
        butt.backgroundColor = [UIColor clearColor];
        
    }
    
    NSArray *editButtons = @[self.editButtonTargetRest, self.editButtonAlertTiming];
    for (UIButton *butt in editButtons){
        
        butt.backgroundColor = [UIColor grayColor];
        [butt setTitleColor: [[TJBAestheticsController singleton] paleLightBlueColor] forState: UIControlStateNormal];
        butt.titleLabel.font = [UIFont boldSystemFontOfSize: 20];
        
        CALayer *buttLayer = butt.layer;
        buttLayer.masksToBounds = YES;
        buttLayer.cornerRadius = butt.frame.size.height / 2.0;
        buttLayer.borderWidth = 1.0;
        buttLayer.borderColor = [[TJBAestheticsController singleton] paleLightBlueColor].CGColor;
        
    }
    
    // clear button
    
    self.clearButton.backgroundColor = [UIColor redColor];
    [self.clearButton setTitleColor: [UIColor whiteColor]
                           forState: UIControlStateNormal];
    self.clearButton.titleLabel.font = [UIFont boldSystemFontOfSize: 20];
    CALayer *clearButtLayer = self.clearButton.layer;
    clearButtLayer.masksToBounds = YES;
    clearButtLayer.cornerRadius = self.clearButton.frame.size.height / 2.0;
    clearButtLayer.borderWidth = 1.0;
    clearButtLayer.borderColor = [UIColor whiteColor].CGColor;
    
    self.returnButton.backgroundColor = [UIColor grayColor];
    [self.returnButton setTitleColor: [[TJBAestheticsController singleton] paleLightBlueColor]
                            forState: UIControlStateNormal];
    self.returnButton.titleLabel.font = [UIFont boldSystemFontOfSize: 20];
    CALayer *rbLayer = self.returnButton.layer;
    rbLayer.borderColor = [[TJBAestheticsController singleton] paleLightBlueColor].CGColor;
    rbLayer.borderWidth = 1.0;
    rbLayer.masksToBounds = YES;
    rbLayer.cornerRadius = self.returnButton.frame.size.height / 2.0;
    

    
    
}




#pragma mark - IBAction

- (IBAction)didPressEditTargetRest:(id)sender{
    
    NSString *nsTitle = @"Target Rest";
    
    __weak TJBClockConfigurationVC *weakSelf = self;
    
    CancelBlock cancelBlock = ^{
        
        [weakSelf dismissViewControllerAnimated: YES
                                 completion: nil];
        
    };
    
    NumberSelectedBlockSingle nsBlock = ^(NSNumber *selectedNumber){
        
        NSString *formattedNumber = [[TJBStopwatch singleton] minutesAndSecondsStringFromNumberOfSeconds: [selectedNumber intValue]];
        weakSelf.targetRestValueLabel.text = formattedNumber;
        weakSelf.selectedTargetRest = selectedNumber;
        
        [TJBStopwatch singleton].targetRest = selectedNumber;
        
        // also need to notify the stopwatch of changes
        
        [weakSelf dismissViewControllerAnimated: YES
                                     completion: nil];
        
    };
    
    TJBNumberSelectionVC *nsVC = [[TJBNumberSelectionVC alloc] initWithNumberTypeIdentifier: TargetRestType
                                                                                      title: nsTitle
                                                                                cancelBlock: cancelBlock
                                                                        numberSelectedBlock: nsBlock];
    
    [self presentViewController: nsVC
                       animated: YES
                     completion: nil];
    
}

- (IBAction)didPressEditAlertTiming:(id)sender{
    
    NSString *nsTitle = @"Alert Timing";
    
    __weak TJBClockConfigurationVC *weakSelf = self;
    
    CancelBlock cancelBlock = ^{
        
        [weakSelf dismissViewControllerAnimated: YES
                                 completion: nil];
        
    };
    
    NumberSelectedBlockSingle nsBlock = ^(NSNumber *selectedNumber){
        
        NSString *formattedNumber = [[TJBStopwatch singleton] minutesAndSecondsStringFromNumberOfSeconds: [selectedNumber intValue]];
        weakSelf.alertTiimingValueLabel.text = formattedNumber;
        weakSelf.selectedAlertTiming = selectedNumber;
        
        [TJBStopwatch singleton].alertTiming = selectedNumber;
        
        // also need to notify the stopwatch of changes
        
        [weakSelf dismissViewControllerAnimated: YES
                                 completion: nil];
        
    };
    
    TJBNumberSelectionVC *nsVC = [[TJBNumberSelectionVC alloc] initWithNumberTypeIdentifier: TimeIntervalSelection
                                                                                      title: nsTitle
                                                                                cancelBlock: cancelBlock
                                                                        numberSelectedBlock: nsBlock];
    
    [self presentViewController: nsVC
                       animated: YES
                     completion: nil];

    
}

- (IBAction)didPressRestart:(id)sender{
    
    [[TJBStopwatch singleton] resetPrimaryTimer];
    
}

- (IBAction)didPressPause:(id)sender{
    
    [[TJBStopwatch singleton] pausePrimaryTimer];
    
}

- (IBAction)didPressPlay:(id)sender{
    
    [[TJBStopwatch singleton] playPrimaryTimer];
    
}


- (IBAction)didPressExit:(id)sender{
    
    self.cancelBlock();
    
}

- (IBAction)didPressClearButton:(id)sender{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"Clear Alert?"
                                                                   message: nil
                                                            preferredStyle: UIAlertControllerStyleAlert];
    
    UIAlertAction *cancelAction = [UIAlertAction actionWithTitle: @"Cancel"
                                                           style: UIAlertActionStyleCancel
                                                         handler: nil];
    [alert addAction: cancelAction];
    
    UIAlertAction *clearAction = [UIAlertAction actionWithTitle: @"Clear"
                                                          style: UIAlertActionStyleDestructive
                                                        handler: ^(UIAlertAction *action){
                                                            
                                                            // label text
                                                            
                                                            NSString *blank = @"---";
                                                            self.targetRestValueLabel.text = blank;
                                                            self.alertTiimingValueLabel.text = blank;
                                                            
                                                            // stopwatch
                                                            
                                                            TJBStopwatch *stopwatch = [TJBStopwatch singleton];
                                                            
                                                            [stopwatch deleteActiveLocalAlert];
                                                            [stopwatch clearTargetRestAndAlertTiming];
                                                            
                                                        }];
    [alert addAction: clearAction];
    
    [self presentViewController: alert
                       animated: YES
                     completion: nil];
    

    
}

#pragma mark - Apply & Return

- (IBAction)didPressReturn:(id)sender{
    
    if (self.selectedTargetRest && self.selectedAlertTiming){
        
        float restLessAlert = [self.selectedTargetRest floatValue] - [self.selectedAlertTiming floatValue];
        
        if (restLessAlert > 0.0){
            
            // make sure the timer is running
            
            [[TJBStopwatch singleton] playPrimaryTimer];
            
            if ([[TJBStopwatch singleton] alertIsFullyDefined]){
                
                [self deregisterTimerValueLabelWithStopwatch];
                
                // update the stopwatch
                TJBStopwatch *stopwatch = [TJBStopwatch singleton];
                [stopwatch scheduleAlertBasedOnUserPermissions];
                
                self.applyAlertParamBlock(self.selectedTargetRest, self.selectedAlertTiming);
                
            } else{
                
                [self alertNotFullyDefineAlertSequence];
                
            }

            
        } else{
            
            UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"Invalid Selections"
                                                                           message: @"Alert timing must be less than target rest"
                                                                    preferredStyle: UIAlertControllerStyleAlert];
            
            UIAlertAction *action = [UIAlertAction actionWithTitle: @"Continue"
                                                             style: UIAlertActionStyleDefault
                                                           handler: nil];
            
            [alert addAction: action];
            
            [self presentViewController: alert
                               animated: YES
                             completion: nil];
            
        }
    } else{
        
        [self alertNotFullyDefineAlertSequence];
        
    }
}



- (void)alertNotFullyDefineAlertSequence{
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle: @"Undefined Alert"
                                                                   message: @"A target rest and alert timing must be selected"
                                                            preferredStyle: UIAlertControllerStyleAlert];
    
    UIAlertAction *continueAction = [UIAlertAction actionWithTitle: @"Continue"
                                                             style: UIAlertActionStyleDefault
                                                           handler: nil];
    [alert addAction: continueAction];
    
    [self presentViewController: alert
                       animated: YES
                     completion: nil];
    
}



#pragma mark - Stopwatch Interaction

- (void)registerTimerValueLabelWithStopwatch{
    
    [[TJBStopwatch singleton] addPrimaryStopwatchObserver: self
                                           withTimerLabel: self.timerValueLabel];
    
}

- (void)deregisterTimerValueLabelWithStopwatch{
 
    [[TJBStopwatch singleton] removePrimaryStopwatchObserver: self.timerValueLabel];
    
}

#pragma mark - TJBStopwatchObserver

- (void)primaryTimerDidUpdateWithUpdateDate:(NSDate *)date timerValue:(float)timerValue{
    
    
    
}

- (void)secondaryTimerDidUpdateWithUpdateDate:(NSDate *)date{
    
    
    
}




@end
































