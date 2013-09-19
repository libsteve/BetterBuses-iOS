//
//  StopPickerViewController.m
//  RITBetterBusses
//
//  Created by Steve on 9/13/13.
//  Copyright (c) 2013 Altece. All rights reserved.
//

#import "StopPickerViewController.h"
#import "BBRouteData.h"
#import "ScheduleCell.h"

static NSString *NoneStopPlaceholder = @"---";

@interface StopPickerViewController ()
@property (readonly, nonatomic) NSString *sourceStop;
@property (readonly, nonatomic) NSString *destStop;
@property (strong, nonatomic) NSArray *stopsForCurrentStop;
@property (strong, nonatomic) NSDictionary *routeSchedulesForStops;
@end

@implementation StopPickerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    CGFloat heightInet = self.navigationController.navigationBar.bounds.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
    self.scheduleTableView.contentInset = UIEdgeInsetsMake(heightInet, 0, 0, 0);
}

//- (void)viewDidAppear:(BOOL)animated {
//    [super viewDidAppear:animated];
//    [self.scheduleTableView reloadData];
//}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSArray *)stopsForCurrentStop {
    if (_stopsForCurrentStop == nil) {
        NSInteger selectedSourceStopIndex = [self.stopPicker selectedRowInComponent:0];
        if (selectedSourceStopIndex != -1) {
            self.stopsForCurrentStop = [[BBRouteData routeData] stopsReachableFromStop:[[BBRouteData routeData] stops][selectedSourceStopIndex]];
        }
    }
    return _stopsForCurrentStop;
}

- (NSString *)sourceStop {
    return [BBRouteData routeData].stops[[self.stopPicker selectedRowInComponent:0]];
}

- (NSString *)destStop {
    return self.stopsForCurrentStop[[self.stopPicker selectedRowInComponent:1]];
}

#pragma mark - UIPickerDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    if (pickerView == self.stopPicker) {
        return 2;
    }
    return 0;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    if (pickerView == self.stopPicker) {
        switch (component) {
            case 0: {
                return [[[BBRouteData routeData] stops] count];
            } break;
            case 1: {
                if (self.stopsForCurrentStop != nil) {
                    return self.stopsForCurrentStop.count;
                }
                return 0;
            } break;
        }
    }
    return 0;
}

#pragma mark - UIPickerDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    if (pickerView == self.stopPicker) {
        switch (component) {
            case 0: {
                return [[BBRouteData routeData] stops][row];
            } break;
            case 1: {
                if (self.stopsForCurrentStop != nil) {
                    return self.stopsForCurrentStop[row];
                }
                return NoneStopPlaceholder;
            } break;
        }
    }
    return NoneStopPlaceholder;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (pickerView == self.stopPicker) {NSLog(@"here! %d, %d", row, component);
        switch (component) {
            case 0: {
                NSString *selectedStop = nil;
                if (self.stopsForCurrentStop != nil) {
                    NSInteger row = [self.stopPicker selectedRowInComponent:1];
                    selectedStop = [self pickerView:self.stopPicker titleForRow:row forComponent:1];
                }
                self.stopsForCurrentStop = [[BBRouteData routeData] stopsReachableFromStop:[[BBRouteData routeData] stops][row]];
                [self.stopPicker reloadComponent:1];
                if ([self.stopsForCurrentStop containsObject:selectedStop]) {
                    [self.stopPicker selectRow:[self.stopsForCurrentStop indexOfObject:selectedStop] inComponent:1 animated:YES];
                    [self pickerView:pickerView didSelectRow:[self.stopsForCurrentStop indexOfObject:selectedStop] inComponent:1];
                }
            } break;
            case 1: {
                self.routeSchedulesForStops = [[BBRouteData routeData] routeSchedulesFromStop:self.sourceStop toStop:self.destStop onDay:@""];
                [self.scheduleTableView reloadData];
            } break;
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.scheduleTableView) {
        NSLog(@"sections! %@", self.routeSchedulesForStops);
        return [self.routeSchedulesForStops count];
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.scheduleTableView) {
        NSString *key = [self.routeSchedulesForStops allKeys][section];
        return [(NSArray *)self.routeSchedulesForStops[key] count];
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView == self.scheduleTableView) {
        return [self.routeSchedulesForStops allKeys][section];
    }
    return nil;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *schedule = ^{
        NSArray *schedules = self.routeSchedulesForStops[[self tableView:tableView titleForHeaderInSection:indexPath.section]];
        return schedules[indexPath.row];
    }();
    
    if (tableView == self.scheduleTableView) {
        ScheduleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ScheduleCell"];
        
        cell.source.text = self.sourceStop;
        cell.destination.text = self.destStop;
        
        NSDictionary *source = [schedule firstObject];
        NSDictionary *dest = [schedule lastObject];
        
        cell.sourceArrivalTime.text = source[@"arrives"][@"time"];
        cell.departureTime.text = source[@"depatrs"][@"time"];
        
        cell.arrivalTime.text = dest[@"arrives"][@"time"];
        
        return cell;
    }
    return nil;
}

@end
