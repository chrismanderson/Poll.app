//
//  CAMasterViewController.h
//  Pollster
//
//  Created by Chris Anderson on 11/28/12.
//  Copyright (c) 2012 Polutropos. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RestKit/RestKit.h>

@interface CAMasterViewController : UITableViewController <RKObjectLoaderDelegate, UISearchBarDelegate, UISearchDisplayDelegate>

@property (nonatomic, assign) bool isAllPolls;

@property (weak, nonatomic) IBOutlet UINavigationItem *navigationBar;
@property (weak, nonatomic) IBOutlet UISearchBar *searchBar;

- (void)toggleAllPolls:(bool)isAllPolls;

@end
