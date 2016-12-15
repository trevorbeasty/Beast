//
//  CircuitDesignExerciseComponent.m
//  Beast
//
//  Created by Trevor Beasty on 12/13/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import "CircuitDesignExerciseComponent.h"

#import "CircuitDesignRowComponent.h"

@interface CircuitDesignExerciseComponent ()

@property (nonatomic, strong) NSMutableDictionary *constraintMapping;

@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet UILabel *roundColumnLabel;
@property (weak, nonatomic) IBOutlet UILabel *weightColumnLabel;
@property (weak, nonatomic) IBOutlet UILabel *repsColumnLabel;
@property (weak, nonatomic) IBOutlet UILabel *restColumnLabel;


@end

@implementation CircuitDesignExerciseComponent

#pragma mark - Instantiation

- (instancetype)initWithNumberOfRounds:(NSNumber *)numberOfRounds targetingWeight:(NSNumber *)targetingWeight targetingReps:(NSNumber *)targetingReps targetingRest:(NSNumber *)targetingRest targetsVaryByRound:(NSNumber *)targetsVaryByRound chainIndex:(NSNumber *)chainIndex exerciseName:(NSString *)exerciseName
{
    self = [super init];
    
    self.numberOfRounds = numberOfRounds;
    self.targetingWeight = targetingWeight;
    self.targetingReps = targetingReps;
    self.targetingRest = targetingRest;
    self.targetsVaryByRound = targetsVaryByRound;
    self.chainIndex = chainIndex;
    self.exerciseName = exerciseName;
    
    return self;
}



#pragma mark - Views

- (void)viewWillAppear:(BOOL)animated
{
    NSLog(@"viewWillAppear");
}

- (void)viewDidAppear:(BOOL)animated
{

}

- (void)viewDidLoad
{
    NSLog(@"viewDidLoad");
    // labels
    
    self.titleLabel.text = [NSString stringWithFormat: @"Chain Element %d: %@",
                            [self.chainIndex intValue],
                            self.exerciseName];
    
    
//    CircuitDesignRowComponent *vc = [[CircuitDesignRowComponent alloc] init];

    
    self.constraintMapping = [[NSMutableDictionary alloc] init];
    
    UILabel *redLabel = [[UILabel alloc] init];
    redLabel.backgroundColor = [UIColor redColor];
    redLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.constraintMapping setObject: redLabel
                               forKey: @"A"];
    [self.view addSubview: redLabel];
    
    [self.constraintMapping setObject: self.roundColumnLabel
                               forKey: @"roundColumnLabel"];
    
    NSArray *horizontalConstraints1 = [NSLayoutConstraint constraintsWithVisualFormat: @"H:|-8-[A]-8-|"
                                                                              options: 0
                                                                              metrics: nil
                                                                                views: self.constraintMapping];
    
    NSArray *verticalConstraints1 = [NSLayoutConstraint constraintsWithVisualFormat: @"V:[roundColumnLabel]-8-[A]-8-|"
                                                                            options: 0
                                                                            metrics: nil
                                                                              views: self.constraintMapping];
    
    [self.view addConstraints: horizontalConstraints1];
    [self.view addConstraints: verticalConstraints1];
    
    
    
    
    
    
    
    
    
    
    
    // add one row
    
    

//
//    UILabel *redLabel = [[UILabel alloc] init];
//    redLabel.backgroundColor = [UIColor redColor];
//    redLabel.translatesAutoresizingMaskIntoConstraints = NO;
//    [self.constraintMapping setObject: redLabel
//                               forKey: @"A"];
//    [self.view addSubview: redLabel];
    
    
//    UIView *vcView = vc.view;
    
//    [self presentViewController: vc
//                       animated: YES
//                     completion: nil];
    
//    vcView.translatesAutoresizingMaskIntoConstraints = NO;
    
//    [self.view addSubview: vcView];
//    
//    [self.constraintMapping setObject: vcView
//                               forKey: @"firstRow"];
//    [self.constraintMapping setObject: self.roundColumnLabel
//                               forKey: @"roundColumnLabel"];
//    
//    NSArray *horizontalConstraints1 = [NSLayoutConstraint constraintsWithVisualFormat: @"H:|-8-[A]-8-|"
//                                                                             options: 0
//                                                                             metrics: nil
//                                                                               views: self.constraintMapping];
//    
//    NSArray *verticalConstraints1 = [NSLayoutConstraint constraintsWithVisualFormat: @"V:[roundColumnLabel]-8-[A]-8-|"
//                                                                           options: 0
//                                                                           metrics: nil
//                                                                             views: self.constraintMapping];
//    
//    [self.view addConstraints: horizontalConstraints1];
//    [self.view addConstraints: verticalConstraints1];
    
}



@end

//- (void)loadView
//{
//    self.constraintMapping = [[NSMutableDictionary alloc] init];
//    
//    UIView *containerView = [[UIView alloc] init];
//    
//    containerView.backgroundColor = [UIColor whiteColor];
//    
//    // create top two rows: (1) component # and exercise button (2) round, weight, reps, rest
//
//    // title bar
//        
//    UILabel *titleLabel = [[UILabel alloc] init];
//        
//    NSString *titleString = [NSString stringWithFormat: @"Element %d: %@",
//                                 [self.chainIndex intValue],
//                                 self.exerciseName];
//        
//    titleLabel.text = titleString;
//    titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
//    titleLabel.backgroundColor = [UIColor redColor];
//    
//    [containerView addSubview: titleLabel];
//    [self.constraintMapping setObject: titleLabel
//                               forKey: @"titleLabel"];
//    
//    // column labels
//        
//    UILabel *roundColumnLabel = [[UILabel alloc] init];
//    roundColumnLabel.text = @"Round #";
//    [containerView addSubview: roundColumnLabel];
//    roundColumnLabel.translatesAutoresizingMaskIntoConstraints = NO;
//    [self.constraintMapping setObject: roundColumnLabel
//                                   forKey: @"roundColumnLabel"];
//    roundColumnLabel.backgroundColor = [UIColor greenColor];
//    
//    UILabel *weightColumnLabel = [[UILabel alloc] init];
//    weightColumnLabel.text = @"Weight (lbs)";
//    [containerView addSubview: weightColumnLabel];
//    weightColumnLabel.translatesAutoresizingMaskIntoConstraints = NO;
//    [self.constraintMapping setObject: weightColumnLabel
//                                   forKey: @"weightColumnLabel"];
//    weightColumnLabel.backgroundColor = [UIColor yellowColor];
//
//    UILabel *repsColumnLabel = [[UILabel alloc] init];
//    repsColumnLabel.text = @"Reps";
//    [containerView addSubview: repsColumnLabel];
//    repsColumnLabel.translatesAutoresizingMaskIntoConstraints = NO;
//    [self.constraintMapping setObject: repsColumnLabel
//                                   forKey: @"repsColumnLabel"];
//    repsColumnLabel.backgroundColor = [UIColor purpleColor];
//        
//    UILabel *restColumnLabel = [[UILabel alloc] init];
//    restColumnLabel.text = @"Rest (seconds)";
//    [containerView addSubview: restColumnLabel];
//    restColumnLabel.translatesAutoresizingMaskIntoConstraints = NO;
//    [self.constraintMapping setObject: restColumnLabel
//                                   forKey: @"restColumnLabel"];
//    restColumnLabel.backgroundColor = [UIColor grayColor];
//    
//    // add a button
//        
//    UIButton *testButton = [[UIButton alloc] init];
//    
//    [testButton setTitle: @"push me ya fuck"
//                forState: UIControlStateNormal];
//    [testButton addTarget: self
//                   action: @selector(testPress)
//         forControlEvents: UIControlEventTouchUpInside];
//    testButton.backgroundColor = [UIColor brownColor];
//    [self.constraintMapping setObject: testButton
//                               forKey: @"testButton"];
//    [containerView addSubview: testButton];
//    testButton.translatesAutoresizingMaskIntoConstraints = NO;
//        
//    NSArray *horizontalConstraint1 = [NSLayoutConstraint constraintsWithVisualFormat: @"H:|-8-[titleLabel]-8-|"
//                                                                                 options: 0
//                                                                                 metrics: nil
//                                                                                   views: self.constraintMapping];
//    NSArray *horizontalConstraint2 = [NSLayoutConstraint constraintsWithVisualFormat: @"H:|-8-[roundColumnLabel]-8-[weightColumnLabel(==roundColumnLabel)]-8-[repsColumnLabel(==weightColumnLabel)]-8-[restColumnLabel(==repsColumnLabel)]-8-|"
//                                                                                options: 0
//                                                                                metrics: nil
//                                                                                  views: self.constraintMapping];
//    NSArray *horizontalConstraint3 = [NSLayoutConstraint constraintsWithVisualFormat: @"H:|-8-[testButton]-8-|"
//                                                                             options: 0
//                                                                             metrics: nil
//                                                                               views: self.constraintMapping];
//    NSArray *verticalConstraint1 = [NSLayoutConstraint constraintsWithVisualFormat: @"V:|-8-[titleLabel]-8-[restColumnLabel(==200)]-8-[testButton(==100)]-8-|"
//                                                                               options: 0
//                                                                               metrics: nil
//                                                                                 views: self.constraintMapping];
//    NSArray *verticalConstraint2 = [NSLayoutConstraint constraintsWithVisualFormat: @"V:|-8-[titleLabel]-8-[roundColumnLabel(==200)]-8-[testButton(==100)]-8-|"
//                                                                           options: 0
//                                                                           metrics: nil
//                                                                             views: self.constraintMapping];
//    NSArray *verticalConstraint3 = [NSLayoutConstraint constraintsWithVisualFormat: @"V:|-8-[titleLabel]-8-[weightColumnLabel(==200)]-8-[testButton(==100)]-8-|"
//                                                                           options: 0
//                                                                           metrics: nil
//                                                                             views: self.constraintMapping];
//    NSArray *verticalConstraint4 = [NSLayoutConstraint constraintsWithVisualFormat: @"V:|-8-[titleLabel]-8-[repsColumnLabel(==200)]-8-[testButton(==100)]-8-|"
//                                                                           options: 0
//                                                                           metrics: nil
//                                                                             views: self.constraintMapping];
//    
//    [containerView addConstraints: horizontalConstraint1];
//    [containerView addConstraints: horizontalConstraint2];
//    [containerView addConstraints: horizontalConstraint3];
//    [containerView addConstraints: verticalConstraint1];
//    [containerView addConstraints: verticalConstraint2];
//    [containerView addConstraints: verticalConstraint3];
//    [containerView addConstraints: verticalConstraint4];
//    
//    
//    self.view = containerView;
//}

//- (void)testPress
//{
//    NSLog(@"succceeeeesssss!!");
//}



















