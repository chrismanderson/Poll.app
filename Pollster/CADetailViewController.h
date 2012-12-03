//
//  CADetailViewController.h
//  Pollster
//
//  Created by Chris Anderson on 11/28/12.
//  Copyright (c) 2012 Polutropos. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>

@interface CADetailViewController : UIViewController <RKObjectLoaderDelegate, UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate>

@property (strong, nonatomic) id detailItem;

@property (strong, nonatomic) IBOutlet UITableView *estimateTable;
@property (strong, nonatomic) IBOutlet UITableView *historyTable;
@property (strong, nonatomic) IBOutlet UILabel *estimate;
@property (weak, nonatomic) IBOutlet UILabel *detailDescriptionLabel;
@property (strong, nonatomic) IBOutlet UITableViewCell *estimateCell;
@property (strong, nonatomic) IBOutlet UILabel *lastUpdatedLabel;
@end
