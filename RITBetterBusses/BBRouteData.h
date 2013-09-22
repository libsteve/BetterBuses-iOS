//
//  BBRouteData.h
//  RITBetterBusses
//
//  Created by Steve on 9/11/13.
//  Copyright (c) 2013 Altece. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface BBRouteData : NSObject

@property (retain, readonly, nonatomic) NSDictionary *data;

@property (retain, readonly, nonatomic) NSArray *stops;
@property (retain, readonly, nonatomic) NSArray *routes;

+ (instancetype)routeData;


- (NSInteger)timevalue:(NSString *)timeString;

- (NSArray *)stopsForRoute:(NSString *)route;
- (NSArray *)routesForStop:(NSString *)stop;

- (NSArray *)stopsReachableFromStop:(NSString *)stop;

- (NSArray *)scheduleForRoute:(NSString *)route fromStop:(NSString *)source toStop:(NSString *)destination onDay:(NSString *)day;
- (NSDictionary *)schedulesForRoutes:(NSArray *)routes fromStop:(NSString *)source toStop:(NSString *)destination onDay:(NSString *)day;

- (NSDictionary *)routeSchedulesFromStop:(NSString *)source toStop:(NSString *)destination onDay:(NSString *)day;

- (NSArray *)timeSortedSchedulesFromStop:(NSString *)source toStop:(NSString *)destination onDay:(NSString *)day;

- (NSArray *)timeSortedSchedulesFromStop:(NSString *)source toStop:(NSString *)destination onDay:(NSString *)day atOrAfterTime:(NSString *)time;

@end
