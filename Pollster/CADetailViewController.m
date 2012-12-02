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

@interface CADetailViewController ()
@property (strong, nonatomic) NSArray *data;
- (void)configureView;
@end

@implementation CADetailViewController

#pragma mark - Managing the detail item

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
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM-dd-yyyy"];
    
    self.lastUpdatedLabel.font = [UIFont fontWithName:@"ProximaNova-Bold" size:20.0];
    self.lastUpdatedLabel.text = [dateFormatter stringFromDate:[self.detailItem lastUpdated]];
    
    [self.estimateTable setDelegate:self];
    [self.estimateTable setDataSource:self];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return self.data.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CAEstimateCell *cell = [tableView dequeueReusableCellWithIdentifier:@"EstimateCell"];
    
    
    /*
     *   Now that we have a cell we can configure it to display the data corresponding to
     *   this row/section
     */
    NSLog(@"%@", [self.detailItem lastUpdated]);
    Estimate *item = self.data[indexPath.row];
    NSLog(@"%@", item);
    

    
    NSNumberFormatter *formatter = [[NSNumberFormatter alloc] init];
    [formatter setNumberStyle:NSNumberFormatterPercentStyle];
    [formatter setMinimumFractionDigits:1];
    
    
    cell.percentageLabel.text = [NSString stringWithFormat:@"%3.1f%%", [item.value doubleValue]];;
    cell.titleLabel.text = item.choice;
//    NSString *path = [[NSBundle mainBundle] pathForResource:[item objectForKey:@"imageKey"] ofType:@"png"];
//    UIImage *theImage = [UIImage imageWithContentsOfFile:path];
//    cell.imageView.image = theImage;
    
    /* Now that the cell is configured we return it to the table view so that it can display it */
    
    return cell;
}



- (void)viewDidLoad
{
    [super viewDidLoad];
    self.detailDescriptionLabel.font = [UIFont fontWithName:@"ProximaNova-Bold" size:24.0];
    NSLog(@"%@", self.detailDescriptionLabel.font);
    
    NSLog(@"Proxima Nova: %@",
          [UIFont fontNamesForFamilyName:@"Proxima Nova"]
          );
	// Do any additional setup after loading the view, typically from a nib.
    [self configureView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
