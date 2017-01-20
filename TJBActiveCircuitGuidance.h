//
//  TJBActiveCircuitGuidance.h
//  Beast
//
//  Created by Trevor Beasty on 12/24/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

// protocol

#import "TJBStopwatchObserver.h"

@class TJBChainTemplate;
@class TJBRealizedChain;

// associated VC

#import "TJBCircuitActiveUpdatingVCProtocol.h"
#import "SelectedExerciseObserver.h"

@class TJBCircuitActiveUpdatingVC;
@class RealizedSetPersonalRecordVC;



@interface TJBActiveCircuitGuidance : UIViewController <TJBStopwatchObserver>

// associated VC's
// they are in the header because they must be accessed by the TJBCircuitModeTBC during restoration

@property (nonatomic, weak) TJBCircuitActiveUpdatingVC <TJBCircuitActiveUpdatingVCProtocol> *circuitActiveUpdatingVC;
@property (nonatomic, weak) RealizedSetPersonalRecordVC <SelectedExerciseObserver> *personalRecordsVC;

- (instancetype)initWithChainTemplate:(TJBChainTemplate *)chainTemplate realizedChainCorrespondingToChainTemplate:(TJBRealizedChain *)realizedChain circuitActiveUpdatingVC:(TJBCircuitActiveUpdatingVC<TJBCircuitActiveUpdatingVCProtocol> *)circuitActiveUpdatingVC wasRestored:(BOOL)wasRestored personalRecordsVC:(RealizedSetPersonalRecordVC<SelectedExerciseObserver> *)personalRecordsVC;



@end
