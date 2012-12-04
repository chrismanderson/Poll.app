//
//  CAMenuViewController.m
//  Pollster
//
//  Created by Chris Anderson on 12/2/12.
//  Copyright (c) 2012 Polutropos. All rights reserved.
//

#import "CAMenuViewController.h"
#import "CASideViewController.h"
#import "CAMasterViewController.h"
#import "UIViewController+JASidePanel.h"

@interface CAMenuViewController ()
@property (nonatomic, strong) UINavigationController *pollPanel;
@end

@implementation CAMenuViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.pollPanel = (UINavigationController *) self.sidePanelController.centerPanel;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    CAMasterViewController *masterView = self.pollPanel.viewControllers[0];
    if (indexPath.row == 0) {
        UIViewController *newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AboutView"];
        self.sidePanelController.centerPanel = newTopViewController;
    } else if (indexPath.row == 1) {
        [masterView toggleAllPolls:YES];
        self.sidePanelController.centerPanel = self.pollPanel;
    } else {
        [masterView toggleAllPolls:NO];
        self.sidePanelController.centerPanel = self.pollPanel;
    }
}

@end
