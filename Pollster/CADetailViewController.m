//
//  CADetailViewController.m
//  Pollster
//
//  Created by Chris Anderson on 11/28/12.
//  Copyright (c) 2012 Polutropos. All rights reserved.
//

#import "CADetailViewController.h"
#import "CAEstimateCell.h"
#import "Charts.h"
#import "Estimate.h"
#import "DateEstimates.h"

@interface CADetailViewController ()
@property (strong, nonatomic) NSArray *data;
@property (strong, nonatomic) NSArray *history;
- (void)configureView;
@end

@implementation CADetailViewController

#pragma mark - Managing the detail item

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@", [error localizedDescription]);    
}

- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response
{
    [[self historyTable] reloadData];
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObject:(id)object
{
    self.history = [object estimatesByDate];
    [[self historyTable] reloadData];
}


- (void)setDetailItem:(Charts *)newDetailItem
{
    if (_detailItem != newDetailItem) {
        _detailItem = newDetailItem;
        
        // Update the view.
        [self configureView];
    }
}


- (void)configureView
{
    // Update the user interface for the detail item.
    if (self.detailItem) {
        self.detailDescriptionLabel.text = [self.detailItem title];
        self.estimate.text = [[self.detailItem estimates] description];
    }
    
    NSSortDescriptor *valueDescriptor = [[NSSortDescriptor alloc] initWithKey:@"value" ascending:NO];
    NSArray *descriptors = [NSArray arrayWithObject:valueDescriptor];
    self.data = [[self.detailItem estimates] sortedArrayUsingDescriptors:descriptors];
    self.history = [self.detailItem estimatesByDate];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd-yyyy"];
    
    self.lastUpdatedLabel.font = [UIFont fontWithName:@"ProximaNova-Bold" size:20.0];
    self.lastUpdatedLabel.text = [dateFormatter stringFromDate:[self.detailItem lastUpdated]];
    
    [self.estimateTable setDelegate:self];
    [self.estimateTable setDataSource:self];
    
    [self.historyTable setDelegate:self];
    [self.historyTable setDataSource:self];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if ([tableView isEqual:self.historyTable]) {
        return [[[self detailItem] estimatesByDate] count];
    } else {
        return 1;
    }
}

- (NSString *)tableView:(UITableView *)tableView
titleForHeaderInSection:(NSInteger)section
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd-yyyy"];
    
    if ([tableView isEqual:self.historyTable]) {
        return [dateFormatter stringFromDate:
                [[[self.detailItem estimatesByDate] objectAtIndex:section] date]];
    } else {
        return nil;
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([tableView isEqual:self.historyTable]) {
        return [[[[self.detailItem estimatesByDate] objectAtIndex:section] estimates]count];
    } else {
        return [[self.detailItem estimates] count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterPercentStyle];
    [formatter setMinimumFractionDigits:1];

    if ([tableView isEqual:self.estimateTable]) {
        CAEstimateCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EstimateCell"];
        Estimate *item = self.data[indexPath.row];
        
        cell.percentageLabel.text = [NSString stringWithFormat:@"%3.1f%%", [item.value doubleValue]];
        cell.titleLabel.text = item.choice;
        
        return cell;
        
    } else if ([tableView isEqual:self.historyTable]) {
        UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue2 reuseIdentifier:@"HistoryCell"];
        
        // get the right DateEstimate
        DateEstimates *dateEstimate = self.history[indexPath.section];
        
        // get the right estimate
        Estimate *item = dateEstimate.estimates[indexPath.row];
        cell.textLabel.text = item.choice;
        cell.detailTextLabel.text = [NSString stringWithFormat:@"%3.1f%%", [item.value doubleValue]];;
        
        return cell;
    } else {
        NSLog(@"I have no idea what's going on...");
        return nil;
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.detailDescriptionLabel.font = [UIFont fontWithName:@"ProximaNova-Bold" size:24.0];
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
