//
//  StopPickerViewController.h
//  RITBetterBusses
//
//  Created by Steve on 9/13/13.
//  Copyright (c) 2013 Altece. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StopPickerViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource, UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UIPickerView *stopPicker;
@property (weak, nonatomic) IBOutlet UITableView *scheduleTableView;

@property (assign, nonatomic) BOOL isToday;
@property (assign, nonatomic) BOOL isCurrentTime;
@property (strong, nonatomic) NSString *weekday;
@property (strong, nonatomic) id /* NSDate */ time;
- (NSString *)time;
- (NSDate *)timeDate;

@property (assign, nonatomic) BOOL shouldResetData;
- (void)reloadData;

- (IBAction)reverseSelectedStops:(id)sender;

@end
