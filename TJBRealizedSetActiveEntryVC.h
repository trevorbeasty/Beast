//
//  TJBRealizedSetActiveEntryVC.h
//  Beast
//
//  Created by Trevor Beasty on 12/8/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TJBRealizedSetActiveEntryVC : UIViewController

{
    int _timeElapsedInSeconds;
}

@property (weak, nonatomic) IBOutlet UILabel *timerLabel;

@end
