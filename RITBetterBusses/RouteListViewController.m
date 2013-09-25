//
//  RouteListViewController.m
//  RITBetterBusses
//
//  Created by Steve on 9/24/13.
//  Copyright (c) 2013 Altece. All rights reserved.
//

#import "RouteListViewController.h"
#import "RouteJumpCell.h"

@interface RouteListViewController ()

@end

@implementation RouteListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.navigationItem.title = [self.route firstObject][@"route"];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    self.route = nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.route.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RouteJumpCell *cell = [tableView dequeueReusableCellWithIdentifier:@"ScheduleStopCell" forIndexPath:indexPath];
    
    NSString *from = self.route[indexPath.row][@"arrives"][@"from"];
    NSString *to = self.route[indexPath.row][@"departs"][@"to"];
    
    NSString *arrival = self.route[indexPath.row][@"arrives"][@"time"];
    NSString *departure = self.route[indexPath.row][@"departs"][@"time"];
    
    cell.jumpTitle.text = [NSString stringWithFormat:@"%@ to %@", from, to];
    cell.jumpTimes.text = [NSString stringWithFormat:@"Departs at %@, arrives at %@.", departure, arrival];
    
    return cell;
}

@end
