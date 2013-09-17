//
//  BBRouteData.m
//  RITBetterBusses
//
//  Created by Steve on 9/11/13.
//  Copyright (c) 2013 Altece. All rights reserved.
//

#import "BBRouteData.h"
@import JavaScriptCore;

@interface BBRouteData ()
@property (retain, readwrite, nonatomic) NSDictionary *data;
@property (retain) JSContext *javascriptContext;
@property (retain, readwrite, nonatomic) NSArray *stops;
@property (retain, readwrite, nonatomic) NSArray *routes;
@end

@implementation BBRouteData

+ (instancetype)routeData {
    static BBRouteData *routeData;
    if (routeData == nil) {
        routeData = [[self class] new];
    }
    return routeData;
}

- (id)init {
    if (self = [super init]) {
        NSError *error = nil;
        
        // read in JSON data
        NSURL *JSONURL = [[NSBundle mainBundle] URLForResource:@"schedule" withExtension:@"json"];
        NSData *rawJSONData = [NSData dataWithContentsOfURL:JSONURL];
        self.data = [NSJSONSerialization JSONObjectWithData:rawJSONData options:0 error:&error];
        if (error != nil) {
            NSLog(@"Error reading JSON data. %@", error);
            self = nil;
            return self;
        }
        
        // read in JavaScript algorithms
        _javascriptContext = [[JSContext alloc] init];
        [_javascriptContext evaluateScript:[NSString stringWithContentsOfURL:[[NSBundle mainBundle] URLForResource:@"algorithm" withExtension:@"js"] encoding:NSStringEncodingConversionAllowLossy error:&error]];
        if (error != nil) {
            NSLog(@"Error loading algorithm script from bundle. %@", error);
            self = nil;
            return self;
        }
        
        // load in the JSON data into the JavaScript context
        [_javascriptContext evaluateScript:[NSString stringWithContentsOfURL:JSONURL encoding:NSStringEncodingConversionAllowLossy error:&error]];
        if (error != nil) {
            NSLog(@"Error reading JSON text. %@", error);
            self = nil;
            return self;
        }
    }
    return self;
}

#pragma mark - Algorithm Methods

- (NSArray *)stops {
    if (_stops == nil) {
        NSMutableArray *result = [NSMutableArray array];
        for (NSDictionary *routeData in [self.data objectEnumerator]) {
            for (NSString *stopKey in [routeData keyEnumerator]) {
                if (![result containsObject:stopKey]) {
                    [result addObject:stopKey];
                }
            }
        }
        self.stops = [result sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    }
    return _stops;
}

- (NSArray *)routes {
    if (_routes == nil) {
        NSMutableArray *result = [NSMutableArray array];
        for (NSString *routeKey in [self.data keyEnumerator]) {
            if (![result containsObject:routeKey]) {
                [result addObject:routeKey];
            }
        }
        self.routes = result;
        self.stops = [result sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
    }
    return _routes;
}

- (NSArray *)stopsForRoute:(NSString *)route {
    NSMutableArray *result = [NSMutableArray array];
    for (NSString *stop in [self.data[route] keyEnumerator]) {
        [result addObject:stop];
    }
    return [result sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

- (NSArray *)routesForStop:(NSString *)stop {
    NSMutableArray *result = [NSMutableArray array];
    for (NSString *routeKey in [self.data keyEnumerator]) {
        if (self.data[routeKey][stop] != nil) {
            [result addObject:routeKey];
        }
    }
    return [result sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

- (NSArray *)stopsReachableFromStop:(NSString *)stop {
    NSArray *routesForStop = [self routesForStop:stop];
    NSMutableArray *result = [NSMutableArray array];
    for (NSString *route in routesForStop) {
        for (NSString *routeStop in [self stopsForRoute:route]) {
            if (![result containsObject:routeStop] && ![routeStop isEqualToString:stop]) {
                [result addObject:routeStop];
            }
        }
    }
    return [result sortedArrayUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
}

- (NSArray *)scheduleForRoute:(NSString *)route fromStop:(NSString *)source toStop:(NSString *)destination {
    id result = [self schedulesForRoutes:@[route] fromStop:source toStop:destination][route];
    if ([route isKindOfClass:[JSValue class]]) {
        if ([(JSValue *)route isNull]) {
            return nil;
        }
        return [result toArray];
    } else {
        return result;
    }
}

- (NSDictionary *)schedulesForRoutes:(NSArray *)routes fromStop:(NSString *)source toStop:(NSString *)destination {
    JSValue *value = [self.javascriptContext evaluateScript:[NSString stringWithFormat:@"findScheduleFromRoutes(%@, %@, %@);", routes, source, destination]];
    if ([value isNull]) {
        return nil;
    }
    return [value toDictionary];
}

- (NSDictionary *)routeSchedulesFromStop:(NSString *)source toStop:(NSString *)destination {
    return [self schedulesForRoutes:[self routesForStop:source] fromStop:source toStop:destination];
}

@end
