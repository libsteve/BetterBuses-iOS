//
//  NSArray+Functional.h
//  RITBetterBusses
//
//  Created by Steve on 9/17/13.
//  Copyright (c) 2013 Altece. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (Functional)

- (instancetype)map:(id(^)(id))fn;
- (instancetype)reduceWithDefault:(id)d function:(id(^)(id r, id v))fn;

@end
