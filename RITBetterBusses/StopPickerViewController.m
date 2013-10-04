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
#import "RouteListViewController.h"
#import "SettingsViewController.h"

static NSString *NoneStopPlaceholder = @"---";

@interface StopPickerViewController ()
@property (readonly, nonatomic) NSString *sourceStop;
@property (readonly, nonatomic) NSString *destStop;
@property (strong) NSString *previousSourceStop;
@property (strong) NSString *previousDestStop;
@property (weak, readonly, nonatomic) NSArray *stops;
@property (strong, nonatomic) NSArray *stopsForCurrentStop;
@property (strong, nonatomic) NSArray *schedulesForStops;

@property (strong, atomic) dispatch_queue_t searchQueue;
@property (assign, atomic) NSInteger currentSearchID;
@property (assign, atomic) BOOL isLoading;
@end

@implementation StopPickerViewController
@synthesize weekday = _weekday;
@synthesize time = _time;
@synthesize isToday = _isToday;
@synthesize isCurrentTime = _isCurrentTime;

- (void)viewDidLoad
{
    [super viewDidLoad];
    CGFloat heightInet = self.navigationController.navigationBar.bounds.size.height + [UIApplication sharedApplication].statusBarFrame.size.height;
    self.scheduleTableView.contentInset = UIEdgeInsetsMake(heightInet, 0, 0, 0);
    self.scheduleTableView.scrollIndicatorInsets = UIEdgeInsetsMake(heightInet, 0, 0, 0);
    
    self.currentSearchID = 0;
    _searchQueue = dispatch_queue_create("StopPickerSearchQueue", DISPATCH_QUEUE_PRIORITY_DEFAULT);
    
    self.isCurrentTime = YES;
    self.isToday = YES;
    
    [NSTimer scheduledTimerWithTimeInterval:60.0 target:self.scheduleTableView selector:@selector(reloadData) userInfo:nil repeats:YES];
    
    [self.view removeConstraints:self.view.constraints];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"V:|[table]-(-8)-[picker(160)]-(-8)-|" options:0 metrics:nil views:@{@"table" : self.scheduleTableView, @"picker" : self.stopPicker}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[table]|" options:0 metrics:nil views:@{@"table" : self.scheduleTableView}]];
    [self.view addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:@"H:|[picker]|" options:0 metrics:nil views:@{@"picker" : self.stopPicker}]];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSIndexPath *selected = [self.scheduleTableView indexPathForSelectedRow];
    if (selected) {
        [self.scheduleTableView deselectRowAtIndexPath:selected animated:YES];
    }
    [self reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    self.searchQueue = nil;
    self.stopsForCurrentStop = nil;
    self.schedulesForStops = nil;
    self.weekday = nil;
    self.previousSourceStop = nil;
    self.previousDestStop = nil;
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

- (void)setWeekday:(NSString *)weekday {
    if (weekday) {
        _isToday = NO;
    } else {
        _isToday = YES;
    }
    _weekday = weekday;
}

- (NSString *)weekday {
    if (_weekday) {
        return _weekday;
    }
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"EEEE"];
    return [df stringFromDate:[NSDate date]];
}

- (NSString *)sourceStop {
    return [BBRouteData routeData].stops[[self.stopPicker selectedRowInComponent:0]];
}

- (NSString *)destStop {
    return self.stopsForCurrentStop[[self.stopPicker selectedRowInComponent:1]];
}

- (void)setTime:(NSDate *)time {
    if (time && [time isKindOfClass:[NSDate class]]) {
        _isCurrentTime = NO;
        _time = time;
    } else {
        _isCurrentTime = YES;
        _time = nil;
    }
}

- (NSString *)time {
    NSDateFormatter *df = [[NSDateFormatter alloc] init];
    [df setDateFormat:@"hh:mma"];
    NSDate *date = (_time && [_time isKindOfClass:[NSDate class]]) ? _time : [NSDate date];
    NSString *result = [df stringFromDate:date];
    return [result substringToIndex:[result length] - 1];
}

- (NSDate *)timeDate {
    if (_time) {
        return _time;
    } else {
        return [NSDate date];
    }
}

- (NSArray *)stops {
    return [[BBRouteData routeData] stops];
}

- (BOOL)isToday {
    return _weekday == nil;
}

- (void)setIsToday:(BOOL)isToday {
    if (isToday) {
        self.weekday = nil;
    }
    _isToday = isToday;
}

- (BOOL)isCurrentTime {
    return _time == nil;
}

- (void)setIsCurrentTime:(BOOL)isCurrentTime {
    if (isCurrentTime) {
        self.time = nil;
    }
    _isCurrentTime = isCurrentTime;
}

- (void)reloadData {
    NSString *source = self.sourceStop;
    NSString *dest = self.destStop;
    if ([source isEqualToString:self.previousSourceStop] && [dest isEqualToString:self.previousDestStop] && self.shouldResetData == NO) {
        [self.scheduleTableView reloadData];
    } else {
        self.previousSourceStop = source;
        self.previousDestStop = dest;
        NSInteger currentID = (self.currentSearchID += 1);
        self.isLoading = YES;
        [self.scheduleTableView reloadData];
        dispatch_async(self.searchQueue, ^{
            NSArray *schedules = [[BBRouteData routeData] timeSortedSchedulesFromStop:source toStop:dest onDay:self.weekday atOrAfterTime:self.time];
            if (self.currentSearchID == currentID) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.isLoading = NO;
                    self.schedulesForStops = schedules;
                    [self.scheduleTableView reloadData];
                });
            }
        });
        self.shouldResetData = NO;
    }
}

- (IBAction)reverseSelectedStops:(id)sender {
    NSString *nextSource = self.destStop;
    NSString *nextDest = self.sourceStop;
    NSUInteger indexForNextSource = [self.stops indexOfObject:nextSource];
    NSUInteger indexForNextDest = [[[BBRouteData routeData] stopsReachableFromStop:nextSource] indexOfObject:nextDest];
    if (indexForNextDest != NSNotFound) {
        [self.stopPicker selectRow:indexForNextSource inComponent:0 animated:YES];
        self.stopsForCurrentStop = [[BBRouteData routeData] stopsReachableFromStop:self.stops[indexForNextSource]];
        [self.stopPicker reloadAllComponents];
        [self.stopPicker selectRow:indexForNextDest inComponent:1 animated:YES];
        [self reloadData];
    }
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

- (NSString *)titleForPickerViewForRow:(NSInteger)row forComponent:(NSInteger)component {
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
    return NoneStopPlaceholder;
}

//- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
//    if (pickerView == self.stopPicker) {
//        return [self titleForPickerViewForRow:row forComponent:component];
//    }
//    return NoneStopPlaceholder;
//}

- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    if (pickerView == self.stopPicker) {
        UILabel *label = nil;
        if ([view isKindOfClass:[UILabel class]]) {
            label = (UILabel *)view;
        } else {
            label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, pickerView.bounds.size.width / 2, 30)];
        }
//        label.text = [self titleForPickerViewForRow:row forComponent:component];
        label.textColor = [UIColor blackColor];
        label.backgroundColor = [UIColor clearColor];
        label.textAlignment = NSTextAlignmentCenter;
        label.attributedText = [[NSMutableAttributedString alloc] initWithString:[self titleForPickerViewForRow:row forComponent:component] attributes:@{NSFontAttributeName : [UIFont systemFontOfSize:[UIFont systemFontSize]+4]}];
        return label;
    }
    return view;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    if (pickerView == self.stopPicker) {
        switch (component) {
            case 0: {
                NSString *selectedStop = nil;
                if (self.stopsForCurrentStop != nil) {
                    NSInteger row = [self.stopPicker selectedRowInComponent:1];
                    selectedStop = [self titleForPickerViewForRow:row forComponent:1];
                }
                self.stopsForCurrentStop = [[BBRouteData routeData] stopsReachableFromStop:self.stops[row]];
                [self.stopPicker reloadComponent:1];
                if ([self.stopsForCurrentStop containsObject:selectedStop]) {
                    [self.stopPicker selectRow:[self.stopsForCurrentStop indexOfObject:selectedStop] inComponent:1 animated:YES];
                    [self pickerView:pickerView didSelectRow:[self.stopsForCurrentStop indexOfObject:selectedStop] inComponent:1];
                } else {
                    [self pickerView:pickerView didSelectRow:[self.stopPicker selectedRowInComponent:1] inComponent:1];
                }
            } break;
            case 1: {
                [self reloadData];
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
        if (self.isLoading) {
            return 1;
        } else {
            return [self.schedulesForStops count] != 0 ? [self.schedulesForStops count] : 1;
        }
    }
    return 0;
}

//- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
//    if (tableView == self.scheduleTableView) {
//        if (section == 0) {
//            return [NSString stringWithFormat:@"%@ to %@", self.sourceStop, self.destStop];
//        }
//    }
//    return nil;
//}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (tableView == self.scheduleTableView) {
        if (section == 0) {
            UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, self.scheduleTableView.frame.size.width, 30)];
            label.text = [NSString stringWithFormat:@"  %@ to %@", self.sourceStop, self.destStop];
            label.textColor = [UIColor whiteColor];
            label.backgroundColor = [UIColor brownColor];
            return label;
        }
    }
    return nil;
}

static NSInteger timeLeft(NSString *current, NSString *future) {
    NSInteger curr = [[BBRouteData routeData] timevalue:current];
    NSInteger fut = [[BBRouteData routeData] timevalue:future];
    NSInteger currmin = curr - (curr / 100 * 100);
    NSInteger futmin = fut - (fut / 100 * 100);
    NSInteger currhour = curr / 100;
    NSInteger futhour = fut / 100;
    if (currmin > futmin) {
        futmin += 60;
        futhour -= 1;
    }
    return (futmin - currmin) + ((futhour - currhour) * 60);
}

static NSString *countdown(NSInteger tminus) {
    NSInteger tminushours = tminus / 60;
    NSInteger tminusminutes = tminus - (tminushours * 60);
    NSString *countdownString = nil;
    if (tminushours == 0) {
        if (tminusminutes == 0) {
            countdownString = @"Now departing.";
        } else {
            countdownString = [NSString stringWithFormat:@"Departs in %d minute%s.", tminusminutes, tminusminutes == 1 ? "" : "s"];
        }
    } else {
        if (tminusminutes == 0) {
            countdownString = [NSString stringWithFormat:@"Departs in %d hour%s.", tminushours, tminushours == 1 ? "" : "s"];
        } else {
            countdownString = [NSString stringWithFormat:@"Departs in %d hour%s and %d minute%s.", tminushours, tminushours == 1 ? "" : "s", tminusminutes, tminusminutes == 1 ? "" : "s"];
        }
    }
    return countdownString;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (tableView == self.scheduleTableView) {
        if (self.isLoading) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"LoadingCell" forIndexPath:indexPath];
            UIActivityIndicatorView *spinner = (UIActivityIndicatorView *)cell.contentView.subviews[0];
            [spinner startAnimating];
            return cell;
        } else {
            if ([self.schedulesForStops count] == 0) {
                return [tableView dequeueReusableCellWithIdentifier:@"NoRoutesCell" forIndexPath:indexPath];
            } else {
                NSArray *schedule = self.schedulesForStops[indexPath.row];
                ScheduleCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ScheduleCell" forIndexPath:indexPath];
                
                NSDictionary *source = [schedule firstObject];
                NSDictionary *dest = [schedule lastObject];
                
                NSInteger tminus = timeLeft(self.time, source[@"departs"][@"time"]);
                if (tminus < 0) {
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.schedulesForStops = [self.schedulesForStops subarrayWithRange:NSMakeRange(1, self.schedulesForStops.count - 1)];
                        [self.scheduleTableView reloadData];
                    });
                }
                
                cell.time.text = [NSString stringWithFormat:@"%@ to %@", source[@"departs"][@"time"], dest[@"arrives"][@"time"]];
                cell.timeLeft.text = countdown(tminus);
                cell.route.text = source[@"route"];
                
                UIView *selected = [[UIView alloc] initWithFrame:[cell frame]];
                selected.backgroundColor = [UIColor colorWithRed:1 green:0.64313725490196 blue:0 alpha:1];
                [cell setSelectedBackgroundView:selected];
                
                return cell;
            }
        }
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

#pragma mark - Segue

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.identifier isEqualToString:@"RouteSegue"]) {
        RouteListViewController *vc = segue.destinationViewController;
        NSInteger row = [self.scheduleTableView indexPathForSelectedRow].row;
        vc.route = self.schedulesForStops[row];
    } else if ([segue.identifier isEqualToString:@"SettingsSegue"]) {
        SettingsViewController *vc = [((UINavigationController *)segue.destinationViewController) viewControllers][0];
        vc.mainViewController = self;
    }
}

@end
