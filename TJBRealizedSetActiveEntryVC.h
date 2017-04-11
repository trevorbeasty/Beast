//
//  TJBRealizedSetActiveEntryVC.h
//  Beast
//
//  Created by Trevor Beasty on 12/8/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

// protocols

#import "TJBStopwatchObserver.h"

// sibling personal records VC

#import "TJBPersonalRecordsVCProtocol.h"
@class TJBPersonalRecordVC;

@interface TJBRealizedSetActiveEntryVC : UIViewController <TJBStopwatchObserver>

#pragma mark - Sibling VC's

- (void)configureSiblingPersonalRecordsVC:(TJBPersonalRecordVC <TJBPersonalRecordsVCProtocol> *)personalRecordsVC;

@end
