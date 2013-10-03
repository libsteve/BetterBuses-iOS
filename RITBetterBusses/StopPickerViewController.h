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

@property (strong, nonatomic) NSString *weekday;
@property (strong, nonatomic) id /* NSDate */ time;
- (NSString *)time;

- (IBAction)reverseSelectedStops:(id)sender;

@end
