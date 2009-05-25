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
  
  countryAreas = [[NSArray alloc] initWithObjects:[RadarArea radarAreaWithName:@"British Isles" code:@"uk"],
                  [RadarArea radarAreaWithName:@"Northern Ireland" code:@"northernireland"], 
                  nil];
  
  englandAreas = [[NSArray alloc] initWithObjects:
                  [RadarArea radarAreaWithName:@"Bedfordshire" code:@"northamptonbedfordshire"], 
                  [RadarArea radarAreaWithName:@"Berkshire" code:@"berkshire"], 
                  [RadarArea radarAreaWithName:@"Birmingham" code:@"birminghamwarwickshire"], 
                  [RadarArea radarAreaWithName:@"Black Country" code:@"staffordshireblackcountry"], 
                  [RadarArea radarAreaWithName:@"Bradford" code:@"leedsbradford"], 
                  [RadarArea radarAreaWithName:@"Bristol" code:@"bristol"], 
                  [RadarArea radarAreaWithName:@"Buckinghamshire" code:@"oxfordbucks"], 
                  [RadarArea radarAreaWithName:@"Cambridgeshire" code:@"cambridgeshire"], 
                  [RadarArea radarAreaWithName:@"Cheshire" code:@"liverpoolcheshire"], 
                  [RadarArea radarAreaWithName:@"Cornwall" code:@"cornwall"], 
                  [RadarArea radarAreaWithName:@"Cumbria" code:@"cumbria"], 
                  [RadarArea radarAreaWithName:@"Derby" code:@"derby"], 
                  [RadarArea radarAreaWithName:@"Devon" code:@"devon"], 
                  [RadarArea radarAreaWithName:@"Dorset" code:@"dorset"], 
                  [RadarArea radarAreaWithName:@"Essex" code:@"essex"], 
                  [RadarArea radarAreaWithName:@"Gloucestershire" code:@"gloucestershire"], 
                  [RadarArea radarAreaWithName:@"Guernsey" code:@"jerseyguernsey"], 
                  [RadarArea radarAreaWithName:@"Hampshire" code:@"hampshire"], 
                  [RadarArea radarAreaWithName:@"Hereford" code:@"herefordworcester"], 
                  [RadarArea radarAreaWithName:@"Hertfordshire" code:@"londonhertfordshire"], 
                  [RadarArea radarAreaWithName:@"Humber" code:@"humberside"], 
                  [RadarArea radarAreaWithName:@"Jersey" code:@"jerseyguernsey"], 
                  [RadarArea radarAreaWithName:@"Kent" code:@"kent"], 
                  [RadarArea radarAreaWithName:@"Lancashire" code:@"lancashire"], 
                  [RadarArea radarAreaWithName:@"Leeds" code:@"leedsbradford"], 
                  [RadarArea radarAreaWithName:@"Leicestershire" code:@"leicester"], 
                  [RadarArea radarAreaWithName:@"Lincolnshire" code:@"lincolnshire"], 
                  [RadarArea radarAreaWithName:@"Liverpool / Merseyside" code:@"liverpoolcheshire"], 
                  [RadarArea radarAreaWithName:@"London" code:@"londonhertfordshire"], 
                  [RadarArea radarAreaWithName:@"Manchester" code:@"manchester"], 
                  [RadarArea radarAreaWithName:@"Newcastle / Tyne" code:@"tynewear"], 
                  [RadarArea radarAreaWithName:@"Norfolk" code:@"norfolk"], 
                  [RadarArea radarAreaWithName:@"North Yorkshire" code:@"northyorkshire"], 
                  [RadarArea radarAreaWithName:@"Northampton" code:@"northamptonbedfordshire"], 
                  [RadarArea radarAreaWithName:@"Nottinghamshire" code:@"nottingham"], 
                  [RadarArea radarAreaWithName:@"Oxfordshire" code:@"oxfordbucks"], 
                  [RadarArea radarAreaWithName:@"Shropshire" code:@"shropshire"], 
                  [RadarArea radarAreaWithName:@"Somerset" code:@"somerset"], 
                  [RadarArea radarAreaWithName:@"South Yorkshire" code:@"southyorkshire"], 
                  [RadarArea radarAreaWithName:@"Staffordshire" code:@"staffordshireblackcountry"], 
                  [RadarArea radarAreaWithName:@"Suffolk" code:@"suffolk"], 
                  [RadarArea radarAreaWithName:@"Surrey" code:@"surreysussex"], 
                  [RadarArea radarAreaWithName:@"Sussex" code:@"surreysussex"], 
                  [RadarArea radarAreaWithName:@"Tees" code:@"tees"], 
                  [RadarArea radarAreaWithName:@"Warwickshire" code:@"birminghamwarwickshire"], 
                  [RadarArea radarAreaWithName:@"Wear" code:@"tynewear"], 
                  [RadarArea radarAreaWithName:@"West Yorkshire" code:@"leedsbradford"], 
                  [RadarArea radarAreaWithName:@"Wiltshire" code:@"wiltshire"], 
                  [RadarArea radarAreaWithName:@"Worcester" code:@"herefordworcester"],
                  nil];
  
  scotlandAreas = [[NSArray alloc] initWithObjects:[RadarArea radarAreaWithName:@"Central" code:@"taysidecentralscotland"], 
                   [RadarArea radarAreaWithName:@"East" code:@"edinburgheastscotland"], 
                   [RadarArea radarAreaWithName:@"Edinburgh" code:@"edinburgheastscotland"], 
                   [RadarArea radarAreaWithName:@"Glasgow" code:@"glasgowandwest"], 
                   [RadarArea radarAreaWithName:@"Highlands and Islands" code:@"highlandsandislands"], 
                   [RadarArea radarAreaWithName:@"North East" code:@"northeastscotland"], 
                   [RadarArea radarAreaWithName:@"Northern Isles" code:@"northeastscotland"], 
                   [RadarArea radarAreaWithName:@"Orkney and Shetland" code:@"orkneyshetland"], 
                   [RadarArea radarAreaWithName:@"South" code:@"southscotland"], 
                   [RadarArea radarAreaWithName:@"Tayside" code:@"taysidecentralscotland"], 
                   [RadarArea radarAreaWithName:@"West" code:@"glasgowandwest"],
                   nil];
  
  walesAreas = [[NSArray alloc] initWithObjects:[RadarArea radarAreaWithName:@"Mid" code:@"midwales"], 
                [RadarArea radarAreaWithName:@"North East" code:@"newales"], 
                [RadarArea radarAreaWithName:@"North West" code:@"nwwales"], 
                [RadarArea radarAreaWithName:@"South East" code:@"sewales"], 
                [RadarArea radarAreaWithName:@"South West" code:@"swwales"], 
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
  return 4;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
  switch (section) {
    case 0:
      return nil;
      break;
    case 1:
      return @"England";
      break;
    case 2:
      return @"Scotland";
      break;
    case 3:
      return @"Wales";
    default:
      return nil;
      break;
  }
}

// Customize the number of rows in the table view.
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
  switch (section) {
    case 0:
      return [countryAreas count];
      break;
    case 1:
      return [englandAreas count];
      break;
    case 2:
      return [scotlandAreas count];
      break;
    case 3:
      return [walesAreas count];
      break;
    default:
      return 0;
      break;
  }
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
  static NSString *CellIdentifier = @"Cell";
  
  UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
  if (cell == nil) {
      cell = [[[UITableViewCell alloc] initWithFrame:CGRectZero reuseIdentifier:CellIdentifier] autorelease];
  }
  
  RadarArea *radarArea;
  
  switch (indexPath.section) {
    case 0:
      radarArea = [countryAreas objectAtIndex:indexPath.row];
      break;
    case 1:
      radarArea = [englandAreas objectAtIndex:indexPath.row];
      break;
    case 2:
      radarArea = [scotlandAreas objectAtIndex:indexPath.row];
      break;
    case 3:
      radarArea = [walesAreas objectAtIndex:indexPath.row];
      break;
    default:
      break;
  }
  
  cell.text = radarArea.name;
  return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
  RadarArea *radarArea;
  
  switch (indexPath.section) {
    case 0:
      radarArea = [countryAreas objectAtIndex:indexPath.row];
      break;
    case 1:
      radarArea = [englandAreas objectAtIndex:indexPath.row];
      break;
    case 2:
      radarArea = [scotlandAreas objectAtIndex:indexPath.row];
      break;
    case 3:
      radarArea = [walesAreas objectAtIndex:indexPath.row];
      break;
    default:
      break;
  }
  
    RadarImageViewController *radarImageViewController = [[RadarImageViewController alloc] initWithShortLabel:radarArea.code];
  [self.navigationController pushViewController:radarImageViewController animated:YES];
  [radarImageViewController release];
}

- (void)dealloc {
  [englandAreas release];
  [super dealloc];
}


@end

