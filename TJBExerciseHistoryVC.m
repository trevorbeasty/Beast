//
//  TJBExerciseHistoryVC.m
//  Beast
//
//  Created by Trevor Beasty on 4/10/17.
//  Copyright © 2017 Trevor Beasty. All rights reserved.
//

#import "TJBExerciseHistoryVC.h"

// core data

#import "CoreDataController.h"

@interface TJBExerciseHistoryVC ()




// core

@property (strong) TJBExercise *exercise;

// optimization

@property (strong) NSCalendar *calendar;

@end



typedef NSArray<TJBRealizedSet *> *TJBRealizedSetGrouping;





@implementation TJBExerciseHistoryVC



#pragma mark - View Life Cycle






#pragma mark - View Helper Methods



#pragma mark - Content Derivation

- (void)deriveContentForActiveExercise{
    
    NSMutableArray *collector = [[NSMutableArray alloc] init];
    
    // collect all relevant TJBRealizedSets and TJBRealizedChains
    
    for (TJBRealizedSet *set in self.exercise.realizedSets){
        
        [collector addObject: set];
        
    }
    
    for (TJBChainTemplate *ct in self.exercise.chainTemplates){
        
        for (TJBRealizedChain *rc in ct.realizedChains){
            
            [collector addObject: rc];
            
        }
        
    }
    
    // sort all collected items by date in descending order
    
    [collector sortUsingComparator: ^(id obj1, id obj2){
        
        NSDate *date1 = [self dateForObject: obj1];
        NSDate *date2 = [self dateForObject: obj2];
        
        NSTimeInterval diff = [date1 timeIntervalSinceDate: date2];
        
        if (diff > 0){
            
            return NSOrderedAscending;
            
        } else{
            
            return NSOrderedDescending;
            
        }
        
    }];
    
    // group adjacent realized sets from the same day together
    
    NSMutableArray *collector2 = [[NSMutableArray alloc] init];
    
    NSInteger groupSize = 1;
    
    NSInteger limit = collector.count;
    for (NSInteger i = 0; i < limit - 1; i++){
        
        id obj1 = collector[i];
        id obj2 = collector[i + 1];
        
        BOOL objectsAreRealizedSetsOfSameDay = [self objectsAreRealizedSetsOfSameDay_obj1: obj1
                                                                                     obj2: obj2];
        
        if (objectsAreRealizedSetsOfSameDay){
            
            groupSize += 1;
            continue;
            
        } else{
            
            id object = [self objectForSourceArray: collector
                                 iterationPosition: i
                                         groupSize: groupSize];
            
            [collector2 addObject: object];
            
            groupSize = 1;
            
            continue;
            
        }
        
    }
    
}

- (id)objectForSourceArray:(NSArray *)array iterationPosition:(NSInteger)iterationPosition groupSize:(NSInteger)groupSize{
    
    if (groupSize > 1){
        
        NSMutableArray *collector = [[NSMutableArray alloc] init];
        
        for (NSInteger i = 0; i < groupSize; i++){
            
            [collector addObject: array[iterationPosition + i]];
            
        }
        
        TJBRealizedSetGrouping rsg = [NSArray arrayWithArray: collector];
        return rsg;
        
    } else{
        
        return array[iterationPosition];
        
    }
    
}

- (NSDate *)dateForObject:(id)object{
    
    if ([object isKindOfClass: [TJBRealizedSet class]]){
        
        TJBRealizedSet *rs = object;
        return rs.submissionTime;
        
    } else if ([object isKindOfClass: [TJBRealizedChain class]]){
        
        TJBRealizedChain *rc = object;
        return  rc.dateCreated;
        
    } else{
        
        return nil;
        
    }
    
}

- (BOOL)objectsAreRealizedSetsOfSameDay_obj1:(id)obj1 obj2:(id)obj2{
    
    BOOL obj1IsRealizedSet = [self objectIsRealizedSet: obj1];
    BOOL obj2IsRealizedSet = [self objectIsRealizedSet: obj2];
    
    if (obj1IsRealizedSet && obj2IsRealizedSet){
        
        if (!self.calendar){
            
            self.calendar = [[NSCalendar alloc] initWithCalendarIdentifier: NSCalendarIdentifierGregorian];
            
        }
        
        TJBRealizedSet *rs1 = obj1;
        TJBRealizedSet *rs2 = obj2;
        
        return [self.calendar isDate: rs1.submissionTime
                     inSameDayAsDate: rs2.submissionTime];
        
    } else{
        
        return NO;
        
    }
    
}

- (BOOL)objectIsRealizedSet:(id)obj{
    
    return [obj isKindOfClass: [TJBRealizedSet class]];
    
}



#pragma mark - TJBExerciseHistoryProtocol

- (void)activeExerciseDidUpdate:(TJBExercise *)exercise{
    
    
    
}

@end
