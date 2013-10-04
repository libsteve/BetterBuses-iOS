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
    self.weekdays = @[@"Monday", @"Tuesday", @"Wednesday", @"Thursday", @"Firday", @"Saturday", @"Sunday", @"Holiday"];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.todayToggle setOn:self.mainViewController.isToday animated:NO];
    [self.currentTimeToggle setOn:self.mainViewController.isCurrentTime animated:NO];
    [self.dayPicker selectRow:[self.weekdays indexOfObject:self.mainViewController.weekday] inComponent:0 animated:NO];
    [self.timePicker setDate:self.mainViewController.timeDate animated:NO];
    [self toggleToday:nil];
    [self toggleCurrentTime:nil];
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

- (IBAction)toggleToday:(id)sender {
    if (self.todayToggle.isOn) {
        [self.dayPicker setUserInteractionEnabled:NO];
        NSDateFormatter *df = [NSDateFormatter new];
        [df setDateFormat:@"EEEE"];
        NSString *currentDay = [df stringFromDate:[NSDate date]];
        [self.dayPicker selectRow:[self.weekdays indexOfObject:currentDay] inComponent:0 animated:YES];
    } else {
        [self.dayPicker setUserInteractionEnabled:YES];
    }
}

- (IBAction)toggleCurrentTime:(id)sender {
    if (self.currentTimeToggle.isOn) {
        [self.timePicker setUserInteractionEnabled:NO];
        [self.timePicker setDate:[NSDate date] animated:YES];
    } else {
        [self.timePicker setUserInteractionEnabled:YES];
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

@end
