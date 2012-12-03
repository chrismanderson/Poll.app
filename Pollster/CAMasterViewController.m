//
//  CAMasterViewController.m
//  Pollster
//
//  Created by Chris Anderson on 11/28/12.
//  Copyright (c) 2012 Polutropos. All rights reserved.
//

#import "CAMasterViewController.h"
#import "CADetailViewController.h"

#import <RestKit/RestKit.h>
#import "Charts.h"
#import "Estimate.h"

@interface CAMasterViewController ()
@property (strong, nonatomic) NSArray *data;
@property (strong, nonatomic) NSMutableArray *filteredTableData;

@property (nonatomic, assign) bool isFiltered;
@end

@implementation CAMasterViewController

- (void)awakeFromNib
{
    [super awakeFromNib];
}

- (void)viewDidLoad
{
    // tints the navbar
    
    [super viewDidLoad];
    
    
    // Set up initial load.
    RKURL *baseURL = [RKURL URLWithBaseURLString:@"http://elections.huffingtonpost.com/pollster/api"];
    RKObjectManager *objectManager = [RKObjectManager objectManagerWithBaseURL:baseURL];
    objectManager.client.baseURL = baseURL;
    
    RKObjectMapping *estimateMapping = [RKObjectMapping mappingForClass:[Estimate class]];
    [estimateMapping mapAttributes:@"value", @"choice", nil];
    
    RKObjectMapping *dateEstimateMapping = [RKObjectMapping mappingForClass:[DateEstimates class]];
    [dateEstimateMapping mapAttributes:@"date", nil];
    
    RKObjectMapping *chartMapping = [RKObjectMapping mappingForClass:[Charts class]];
    [chartMapping mapKeyPathsToAttributes:@"title", @"title", nil];
    [chartMapping mapKeyPathsToAttributes:@"slug", @"slug", nil];
    [chartMapping mapKeyPathsToAttributes:@"last_updated", @"lastUpdated", nil];
    
    [objectManager.mappingProvider setMapping:chartMapping forKeyPath:@""];
    [chartMapping mapKeyPath:@"estimates" toRelationship:@"estimates" withMapping:estimateMapping];
    
    [dateEstimateMapping mapKeyPath:@"estimates" toRelationship:@"estimates" withMapping:estimateMapping];
    [chartMapping mapKeyPath:@"estimates_by_date" toRelationship:@"estimatesByDate" withMapping:dateEstimateMapping];

    
    // Grab the reference to the router from the manager
    RKObjectRouter *router = [RKObjectManager sharedManager].router;
    
    // Define a default resource path for all unspecified HTTP verbs
    [router routeClass:[Charts class] toResourcePath:@"/charts/:slug"];
    
//    [self sendRequest];
    [self sendRequest];
//    [self sendSecondRequest];

    
    [self.refreshControl addTarget:self action:@selector(refreshControl:) forControlEvents:UIControlEventValueChanged];
    
    self.searchBar.delegate = (id)self;
    
    CGRect newBounds = self.tableView.bounds;
    newBounds.origin.y = newBounds.origin.y + self.searchBar.bounds.size.height;
    self.tableView.bounds = newBounds;
}


- (void)refreshControl:(UIRefreshControl *)sender{
    [self sendRequest];
    [sender endRefreshing];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    int rowCount;
    if (self.isFiltered)
        rowCount = self.filteredTableData.count;
    else
        rowCount = self.data.count;
    
    return rowCount;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellText = [self.data[indexPath.row] title];
    UIFont *cellFont = [UIFont fontWithName:@"ProximaNova-Bold" size:20.0];
    CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
    CGSize labelSize = [cellText sizeWithFont:cellFont constrainedToSize:constraintSize lineBreakMode:NSLineBreakByWordWrapping];
    
    return labelSize.height + 20;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];

        cell.textLabel.lineBreakMode = NSLineBreakByWordWrapping;
        cell.textLabel.numberOfLines = 0;
        cell.textLabel.font = [UIFont fontWithName:@"ProximaNova-Bold" size:20.0];
    
    
    Charts *chart;
    if(self.isFiltered)
        chart = self.filteredTableData[indexPath.row];
    else
        chart = self.data[indexPath.row];

    cell.textLabel.text = [chart title];
    return cell;
}

- (void)searchBarSearchButtonClicked:(UISearchBar *)searchBar1;
{
    [self.searchBar resignFirstResponder];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}


/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Charts *object = self.data[indexPath.row];
        
        if (object.estimatesByDate == nil) {
            NSLog(@"Chart Slug: %@", [object slug]);
            [ [RKObjectManager sharedManager] getObject:object delegate:[segue destinationViewController]];
        }
        
        
        [[segue destinationViewController] setDetailItem:object];
    }
}
//
//- (void)getChartSlug:(NSString *)slug
//{
//    RKObjectManager *objectManager = [RKObjectManager sharedManager];
//    RKURL *URL = [RKURL URLWithBaseURL:[objectManager baseURL] resourcePath:@"/charts" queryParameters:nil];
//    [objectManager getO:[NSString stringWithFormat:@"%@/%@", [URL resourcePath], slug] delegate:self];
//}

- (void)sendSecondRequest
{
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    
    RKURL *URL = [RKURL URLWithBaseURL:[objectManager baseURL] resourcePath:@"/charts/" queryParameters:nil];
    [objectManager loadObjectsAtResourcePath:[NSString stringWithFormat:@"%@?%@", [URL resourcePath], [URL query]] delegate:self];
}

- (void)sendRequest
{
    NSDictionary *queryParams = @{ @"topic" : @"obama-job-approval" };
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    
    RKURL *URL = [RKURL URLWithBaseURL:[objectManager baseURL] resourcePath:@"/charts" queryParameters:queryParams];
    [objectManager loadObjectsAtResourcePath:[NSString stringWithFormat:@"%@?%@", [URL resourcePath], [URL query]] delegate:self];
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@", [error localizedDescription]);
}

- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {
    NSLog(@"response code: %d", [response statusCode]);
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObject:(id)object
{
    NSLog(@"Object:%@", [object slug]);
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects
{
    NSLog(@"objects[%d]", [objects count]);
    if (objects.count > 1) {
        self.data = objects;
        
        [self.tableView reloadData];
    }
    
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self.searchBar resignFirstResponder];
}

-(void)searchBar:(UISearchBar*)searchBar textDidChange:(NSString*)text
{
    if(text.length == 0)
    {
        self.isFiltered = FALSE;
    }
    else
    {
        self.isFiltered = true;
        self.filteredTableData = [[NSMutableArray alloc] init];
        
        for (Charts* chart in self.data)
        {
            NSRange nameRange = [chart.title rangeOfString:text options:NSCaseInsensitiveSearch];
            NSRange descriptionRange = [chart.title rangeOfString:text options:NSCaseInsensitiveSearch];
            if(nameRange.location != NSNotFound || descriptionRange.location != NSNotFound)
            {
                [self.filteredTableData addObject:chart];
            }
        }
    }
    
    [self.tableView reloadData];
}

@end
