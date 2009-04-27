#import "RootViewController.h"
#import "RadarAppDelegate.h"
#import "RadarImageViewController.h"
#import "RadarArea.h"

@implementation RootViewController

- (void)viewDidLoad {
  [super viewDidLoad];
  self.title = @"Weather";
  UIBarButtonItem *backButton = [[UIBarButtonItem alloc] init];
  backButton.title = @"Back";
  self.navigationItem.backBarButtonItem = backButton;
  [backButton release];
  
  radarAreasArray = [[NSArray alloc] initWithObjects:
                     [RadarArea radarAreaWithName:@"British Isles" code:@"uk"], 
                     [RadarArea radarAreaWithName:@"London" code:@"londonhertfordshire"],                     
                     nil];
}

/*
- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}
*/
/*
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}
*/
/*
- (void)viewWillDisappear:(BOOL)animated {
	[super viewWillDisappear:animated];
}
*/
/*
- (void)viewDidDisappear:(BOOL)animated {
	[super viewDidDisappear:animated];
}
*/

/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
    // Release anything that's not essential, such as cached data
}

#pragma mark Table view methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
  return 1;
}


// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  return [radarAreasArray count];
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
    }
    
    // Set up the cell...
  RadarArea *radarArea = [radarAreasArray objectAtIndex:indexPath.row];
  cell.text = radarArea.name;
  return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  RadarArea *radarArea = [radarAreasArray objectAtIndex:indexPath.row];
    RadarImageViewController *radarImageViewController = [[RadarImageViewController alloc] initWithShortLabel:radarArea.code];
  [self.navigationController pushViewController:radarImageViewController animated:YES];
  [radarImageViewController release];
}

- (void)dealloc {
    [super dealloc];
}


@end

