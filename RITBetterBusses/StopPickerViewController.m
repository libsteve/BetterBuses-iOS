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
@property (strong, nonatomic) NSArray *schedulesForStops;
@property (strong, nonatomic) NSString *weekday;
@property (readonly, nonatomic) NSString *time;
@end

@implementation StopPickerViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    CGFloat heightInet = self.navigationController.navigationBar.bounds.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
    self.scheduleTableView.contentInset = UIEdgeInsetsMake(heightInet, 0, 0, 0);
    self.scheduleTableView.scrollIndicatorInsets = UIEdgeInsetsMake(heightInet, 0, 0, 0);
    
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"EEEE"];
    self.weekday = [df stringFromDate:[NSDate date]];
    
    [NSTimer scheduledTimerWithTimeInterval:60.0 target:self.scheduleTableView selector:@selector(reloadData) userInfo:nil repeats:YES];
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

- (NSString *)time {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"hh:mma"];
    NSString *result = [df stringFromDate:[NSDate date]];
    return [result substringToIndex:[result length] - 1];
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
    if (pickerView == self.stopPicker) {
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
                self.schedulesForStops = [[BBRouteData routeData] timeSortedSchedulesFromStop:self.sourceStop toStop:self.destStop onDay:self.weekday atOrAfterTime:self.time];
                [self.scheduleTableView reloadData];
            } break;
        }
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    if (tableView == self.scheduleTableView) {
        return 1;
    }
    return 0;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.scheduleTableView) {
        return [self.schedulesForStops count];
    }
    return 0;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (tableView == self.scheduleTableView) {
        if (section == 0) {
            return [NSString stringWithFormat:@"%@ to %@", self.sourceStop, self.destStop];
        }
    }
    return nil;
}

static NSInteger timeLeft(NSString *current, NSString *future) {
    NSInteger curr = [[BBRouteData routeData] timevalue:current];
    NSInteger fut = [[BBRouteData routeData] timevalue:future];
    NSInteger minutes = (fut - (fut / 100)) - (curr - (curr / 100));
    NSInteger hours = (fut / 100) - (curr / 100);
    return minutes + (hours * 60);
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray *schedule = self.schedulesForStops[indexPath.row];
    
    if (tableView == self.scheduleTableView) {
        ScheduleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ScheduleCell"];
        
        NSDictionary *source = [schedule firstObject];
        NSDictionary *dest = [schedule lastObject];
        
        cell.time.text = [NSString stringWithFormat:@"%@ to %@", source[@"departs"][@"time"], dest[@"arrives"][@"time"]];
        cell.timeLeft.text = [NSString stringWithFormat:@"Departs in %d minutes", timeLeft(self.time, source[@"departs"][@"time"])];
        cell.route.text = source[@"route"];
        
        return cell;
    }
    return nil;
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.scheduleTableView) {
        return 88;
    }
    return 0;
    
}

@end
