//
//  TJBInSetVC.h
//  Beast
//
//  Created by Trevor Beasty on 12/22/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TJBInSetVC : UIViewController

- initWithTimeDelay:(int)timeDelay DidPressSetCompletedBlock:(void(^)(int))block;

@end
