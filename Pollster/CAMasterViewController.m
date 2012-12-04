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

#define defaultSlug @"obama-job-approval, obama-favorable-rating, us-economy-better-or-worse, obama-job-approval-economy, congress-job-approval, us-satisfaction, us-right-direction-wrong-track, party-identification"

@interface CAMasterViewController ()
@property (strong, nonatomic) NSArray *data;
@property (strong, nonatomic) NSMutableArray *filteredTableData;
@property (strong, nonatomic) NSArray *defaultPolls;

@property (nonatomic, assign) bool isFiltered;

@end

@implementation CAMasterViewController

- (void)toggleAllPolls:(bool)isAllPolls
{
    self.isAllPolls = isAllPolls;
    [self sendRequest];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}
- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.isAllPolls = NO;
    self.defaultPolls = [defaultSlug componentsSeparatedByString:@", "];
}

- (void)loadAllTheThings
{
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
    
    [self sendRequest];
    
    [self.refreshControl addTarget:self action:@selector(refreshControl:) forControlEvents:UIControlEventValueChanged];
    
    self.searchBar.delegate = (id)self;
    
    CGRect newBounds = self.tableView.bounds;
    newBounds.origin.y = newBounds.origin.y + self.searchBar.bounds.size.height;
    self.tableView.bounds = newBounds;
}

- (void)viewDidLoad
{    
    [super viewDidLoad];
    [self loadAllTheThings];
}


- (void)refreshControl:(UIRefreshControl *)sender{
    [self sendRequest];
    [sender endRefreshing];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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
    NSString *cellText    = [self.data[indexPath.row] title];
    UIFont *cellFont      = [UIFont fontWithName:@"ProximaNova-Bold" size:20.0];
    CGSize constraintSize = CGSizeMake(280.0f, MAXFLOAT);
    CGSize labelSize      = [cellText sizeWithFont:cellFont
                                 constrainedToSize:constraintSize
                                     lineBreakMode:NSLineBreakByWordWrapping];
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


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"showDetail"]) {
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        Charts *object = self.data[indexPath.row];
        if (object.estimatesByDate == nil) {
            [ [RKObjectManager sharedManager] getObject:object delegate:[segue destinationViewController]];
        }
        [[segue destinationViewController] setDetailItem:object];
    }
}

- (void)sendRequest
{
    RKObjectManager *objectManager = [RKObjectManager sharedManager];
    RKURL *URL = [RKURL URLWithBaseURL:[objectManager baseURL] resourcePath:@"/charts/" queryParameters:nil];
    [objectManager loadObjectsAtResourcePath:[NSString stringWithFormat:@"%@?%@", [URL resourcePath], [URL query]] delegate:self];
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didFailWithError:(NSError *)error
{
    NSLog(@"Error: %@", [error localizedDescription]);
}

- (void)request:(RKRequest*)request didLoadResponse:(RKResponse*)response {
    NSLog(@"response code: %d", [response statusCode]);
}

- (void)objectLoader:(RKObjectLoader *)objectLoader didLoadObjects:(NSArray *)objects
{
    NSPredicate *sPredicate = [NSPredicate predicateWithFormat:@"slug in %@", self.defaultPolls];
    if (objects.count > 1 && !self.isAllPolls) {
        self.data = [objects filteredArrayUsingPredicate:sPredicate];
        self.navigationBar.title = @"Top Polls";
    } else {
        self.data = objects;
        self.navigationBar.title = @"All Polls";
    }
    NSSortDescriptor *valueDescriptor = [[NSSortDescriptor alloc] initWithKey:@"title" ascending:YES];
    NSArray *descriptors = [NSArray arrayWithObject:valueDescriptor];
    self.data = [self.data sortedArrayUsingDescriptors:descriptors];
    [self.tableView reloadData];
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
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
