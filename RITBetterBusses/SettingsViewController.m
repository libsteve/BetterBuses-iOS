//
//  SettingsViewController.m
//  RITBetterBusses
//
//  Created by Steve on 10/3/13.
//  Copyright (c) 2013 Altece. All rights reserved.
//

#import "SettingsViewController.h"

@interface SettingsViewController ()
@property (strong, nonatomic) NSArray *weekdays;
@end

@implementation SettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.weekdays = @[@"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Friday", @"Saturday", @"Sunday", @"Holiday"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.todayToggle setOn:self.mainViewController.isToday animated:NO];
    [self.currentTimeToggle setOn:self.mainViewController.isCurrentTime animated:NO];
    [self.holidayToggle setOn:[self.mainViewController.weekday isEqualToString:@"Holiday"] animated:NO];
    [self.dayPicker selectRow:[self.weekdays indexOfObject:self.mainViewController.weekday] inComponent:0 animated:NO];
    [self.timePicker setDate:self.mainViewController.timeDate animated:NO];
    [self toggleToday:nil];
    [self toggleCurrentTime:nil];
    [self toggleHoliday:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    self.weekdays = nil;
}

- (IBAction)cancel:(id)sender {
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (IBAction)save:(id)sender {
    // manage the current day
    if (self.todayToggle.isOn != self.mainViewController.isToday) {
        if (!self.todayToggle.isOn) {
            self.mainViewController.weekday = self.weekdays[[self.dayPicker selectedRowInComponent:0]];
        }
        self.mainViewController.isToday = self.todayToggle.isOn;
        self.mainViewController.shouldResetData = YES;
    }
    // manage the current time
    if (self.currentTimeToggle.isOn != self.mainViewController.isCurrentTime) {
        if (!self.currentTimeToggle.isOn) {
            self.mainViewController.time = [self.timePicker date];
        }
        self.mainViewController.isCurrentTime = self.currentTimeToggle.isOn;
        self.mainViewController.shouldResetData = YES;
    }
    [self dismissViewControllerAnimated:YES completion:^{
        [self.mainViewController reloadData];
    }];
}

static NSString *today() {
    NSDateFormatter *df = [NSDateFormatter new];
    [df setDateFormat:@"EEEE"];
    return [df stringFromDate:[NSDate date]];
}

- (IBAction)toggleToday:(id)sender {
    if (self.todayToggle.isOn) {
        [self.dayPicker selectRow:[self.weekdays indexOfObject:today()] inComponent:0 animated:YES];
        if (self.holidayToggle.isOn) {
            [self.holidayToggle setOn:NO animated:YES];
        }
    } else {
    }
}

- (IBAction)toggleCurrentTime:(id)sender {
    if (self.currentTimeToggle.isOn) {
        [self.timePicker setDate:[NSDate date] animated:YES];
    } else {
    }
}

- (IBAction)toggleHoliday:(id)sender {
    if (self.holidayToggle.isOn) {
        [self.todayToggle setOn:NO animated:YES];
        [self.dayPicker selectRow:[self.weekdays indexOfObject:@"Holiday"] inComponent:0 animated:YES];
    } else {
        [self.todayToggle setOn:YES animated:YES];
        [self toggleToday:nil];
    }
}

#pragma mark - UIPickerView stuff

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return self.weekdays[row];
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return self.weekdays.count;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    NSString *selected = self.weekdays[row];
    if ([selected isEqualToString:today()]) {
        [self.todayToggle setOn:YES animated:YES];
        [self toggleToday:nil];
    } else {
        if (self.todayToggle.isOn) {
            [self.todayToggle setOn:NO animated:YES];
            [self toggleToday:nil];
        }
        if ([selected isEqualToString:@"Holiday"]) {
            [self.holidayToggle setOn:YES animated:YES];
            [self toggleHoliday:nil];
        } else {
            if (self.holidayToggle.isOn) {
                [self.holidayToggle setOn:NO animated:YES];
                [self toggleHoliday:nil];
            }
        }
    }
}

@end
