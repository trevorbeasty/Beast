//
//  CoreDataController.h
//  Beast
//
//  Created by Trevor Beasty on 12/9/16.
//  Copyright © 2016 Trevor Beasty. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreData/CoreData.h>

@interface CoreDataController : NSObject

@property (readonly, strong) NSPersistentContainer *persistentContainer;

+ (instancetype)singleton;

- (void)saveContext;



@end
