//
//  ScheduleCell.h
//  RITBetterBusses
//
//  Created by Steve on 9/17/13.
//  Copyright (c) 2013 Altece. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScheduleCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *source;
@property (weak, nonatomic) IBOutlet UILabel *destination;
@property (weak, nonatomic) IBOutlet UILabel *departureTime;
@property (weak, nonatomic) IBOutlet UILabel *arrivalTime;
@property (weak, nonatomic) IBOutlet UILabel *sourceArrivalTime;

@end
