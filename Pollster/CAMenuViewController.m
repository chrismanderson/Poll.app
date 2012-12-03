//
//  CAMenuViewController.m
//  Pollster
//
//  Created by Chris Anderson on 12/2/12.
//  Copyright (c) 2012 Polutropos. All rights reserved.
//

#import "CAMenuViewController.h"
#import "UIViewController+JASidePanel.h"

@interface CAMenuViewController ()
@property (nonatomic, strong) UIViewController *pollPanel;
@end

@implementation CAMenuViewController

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
    self.pollPanel = self.sidePanelController.centerPanel;

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
	
    if ([segue.identifier isEqualToString:@"AddPlayer"])
	{
//		UINavigationController *navigationController =
//        segue.destinationViewController;
//		PlayerDetailsViewController
//        *playerDetailsViewController =
//        [[navigationController viewControllers]
//         objectAtIndex:0];
//		playerDetailsViewController.delegate = self;
	}
}



#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (indexPath.row == 0) {
        UIViewController *newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"AboutView"];
        self.sidePanelController.centerPanel = newTopViewController;
    } else {
        
        self.sidePanelController.centerPanel = self.pollPanel;
    }
    
    
//    NSString *identifier = [NSString stringWithFormat:@"%@Top", [self.menuItems objectAtIndex:indexPath.row]];
//    
//    UIViewController *newTopViewController = [self.storyboard instantiateViewControllerWithIdentifier:identifier];
//    
//    [self.slidingViewController anchorTopViewOffScreenTo:ECRight animations:nil onComplete:^{
//        CGRect frame = self.slidingViewController.topViewController.view.frame;
//        self.slidingViewController.topViewController = newTopViewController;
//        self.slidingViewController.topViewController.view.frame = frame;
//        [self.slidingViewController resetTopView];
//    }];
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

@end
