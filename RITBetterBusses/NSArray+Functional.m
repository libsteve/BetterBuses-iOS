//
//  NSArray+Functional.m
//  RITBetterBusses
//
//  Created by Steve on 9/17/13.
//  Copyright (c) 2013 Altece. All rights reserved.
//

#import "NSArray+Functional.h"

@implementation NSArray (Functional)

- (instancetype)map:(id(^)(id v))fn {
    NSMutableArray *result = [[self class] new];
    for (id v in self) {
        [result addObject:fn(v)];
    }
    return result;
}

- (instancetype)reduceWithDefault:(id)d function:(id(^)(id r, id v))fn {
    id result = d;
    for (id v in self) {
        result = fn(result, v);
    }
    return result;
}

- (instancetype)filter:(BOOL(^)(id v))fn {
    return [self reduceWithDefault:[[self class] new] function:^id(id r, id v) {
        if (fn(v)) {
            r = [r arrayByAddingObject:v];
        }
        return r;
    }];
}

@end
