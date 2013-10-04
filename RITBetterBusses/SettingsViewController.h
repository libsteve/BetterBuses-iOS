//
//  SettingsViewController.h
//  RITBetterBusses
//
//  Created by Steve on 10/3/13.
//  Copyright (c) 2013 Altece. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StopPickerViewController.h"

@interface SettingsViewController : UITableViewController <UIPickerViewDataSource, UIPickerViewDelegate>
@property (weak, nonatomic) StopPickerViewController *mainViewController;
@property (weak, nonatomic) IBOutlet UISwitch *todayToggle;
@property (weak, nonatomic) IBOutlet UISwitch *currentTimeToggle;
@property (weak, nonatomic) IBOutlet UISwitch *holidayToggle;
@property (weak, nonatomic) IBOutlet UIDatePicker *timePicker;
@property (weak, nonatomic) IBOutlet UIPickerView *dayPicker;
- (IBAction)cancel:(id)sender;
- (IBAction)save:(id)sender;
- (IBAction)toggleToday:(id)sender;
- (IBAction)toggleCurrentTime:(id)sender;
- (IBAction)toggleHoliday:(id)sender;
@end
