//
//  ScheduleCell.h
//  RITBetterBusses
//
//  Created by Steve on 9/17/13.
//  Copyright (c) 2013 Altece. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ScheduleCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *route;
@property (weak, nonatomic) IBOutlet UILabel *time;
@property (weak, nonatomic) IBOutlet UILabel *timeLeft;


@end
