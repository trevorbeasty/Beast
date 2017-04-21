//
//  TJBCircuitReferenceVC.h
//  Beast
//
//  Created by Trevor Beasty on 1/11/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    TJBRealizedsetGroupingEditingData,
    TJBRealizedChainEditingData
} TJBEditingDataType;

// core data

#import "CoreDataController.h"

@class TJBCircuitReferenceContainerVC; // master controller

@interface TJBCircuitReferenceVC : UIViewController

- (instancetype)initWithRealizedChain:(TJBRealizedChain *)rc realizedSetGrouping:(TJBRealizedSetGrouping)rsg editingDataType:(TJBEditingDataType)editingDataType masterController:(TJBCircuitReferenceContainerVC *)masterController;


@end
