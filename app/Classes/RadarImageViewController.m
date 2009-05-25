#import "RadarImageViewController.h"

#import "GDataXMLNode.h"

#define MAX_PAGES 18;

@interface RadarImageViewController(Private)

- (void)handleSuccessfulLabelsRequest:(TTURLRequest *)request;
- (void)handleSuccessfulPageRequest:(TTURLRequest *)request;

@end


@implementation RadarImageViewController

@synthesize radarImageView;
@synthesize shortLabel;

- (id) initWithShortLabel:(NSString *)_shortLabel {
  self = [super init];
  if (self != nil) {
    self.shortLabel = _shortLabel;
    calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSCalendarUnit unitFlags = NSYearCalendarUnit | NSMonthCalendarUnit | NSDayCalendarUnit | NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit;
    NSDate *dateToday = [NSDate date];
    NSDateComponents *dateComponents = [calendar components:unitFlags fromDate:dateToday];
    
    // snap hour to previous divisible by 3
    int hour = [dateComponents hour];
    while (hour % 3 != 0) {
      hour -= 1;
    }
    [dateComponents setHour:hour];
    
    startDate = [[calendar dateFromComponents:dateComponents] retain];
    
    radarImages = [[NSMutableDictionary alloc] init];
  }
  return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
  theSlider = [[UISlider alloc] initWithFrame:CGRectMake(20, 372, 280, 44)];
  [theSlider setEnabled:NO];
  [theSlider setValue:0.0f];
  [theSlider setMinimumValue:0.0f];
  [theSlider setMaximumValue:17.0f];
  [theSlider setContinuous:YES];
  [theSlider addTarget:self action:@selector(sliderMoved:) forControlEvents:UIControlEventValueChanged];
  [self.view addSubview:theSlider];
  [self fetchAllPages];
  [super viewDidLoad];
}

- (void)fetchAllPages {  
  int max = MAX_PAGES;
  
  [self queueLabelsForFetch];
  for (int i = 0; i < max; i++) {
    [self queuePageForFetch:i];
  }
}

- (void)queueLabelsForFetch {
  NSString *urlString = [NSString stringWithFormat:@"http://news.bbc.co.uk/weather/map_presenter/%@/MapAreaNode.xml", self.shortLabel];
  TTURLRequest *request = [TTURLRequest requestWithURL:urlString delegate:self];
  request.httpMethod = @"GET";
  request.response = [[[TTURLDataResponse alloc] init] autorelease];
  request.userInfo = [TTUserInfo topic:@"labels" strong:nil weak:self];
  [request send];
}

- (void)queuePageForFetch:(int)page {
  NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
  [offsetComponents setHour:(3 * page)];
  NSDate *selectedDate = [calendar dateByAddingComponents:offsetComponents toDate:startDate options:0];
  [offsetComponents release];
  
  NSCalendarUnit unitFlags = NSDayCalendarUnit | NSHourCalendarUnit;
  NSDateComponents *selectedDateComponents = [calendar components:unitFlags fromDate:selectedDate];
  NSString *urlString = [NSString stringWithFormat:@"http://newsimg.bbc.co.uk/weather/map_presenter/%02d/%02d/forecast/%@.jpg", [selectedDateComponents day], [selectedDateComponents hour], self.shortLabel];
  NSURL *url = [NSURL URLWithString:urlString];
  
  NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
  [outputFormatter setAMSymbol:@""];
  [outputFormatter setPMSymbol:@""];
  [outputFormatter setDateFormat:@"EEEE HH':00'"];
  NSString *title = [outputFormatter stringFromDate:selectedDate];
  [outputFormatter release];
  
  NSDictionary *requestInfo = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:page], @"page", title, @"title", nil];
  TTURLRequest *request = [TTURLRequest requestWithURL:[url absoluteString] delegate:self];
  request.httpMethod = @"GET";
  request.response = [[[TTURLImageResponse alloc] init] autorelease];
  request.userInfo = [TTUserInfo topic:@"page" strong:requestInfo weak:self];
  [request send];
}

- (void)requestDidFinishLoad:(TTURLRequest*)request {
  TTUserInfo *userInfo = request.userInfo;
  
  if ([userInfo.topic isEqualToString:@"page"]) {
    [self handleSuccessfulPageRequest:request];
  } else {
    [self handleSuccessfulLabelsRequest:request];
  }
}

- (void)handleSuccessfulLabelsRequest:(TTURLRequest *)request {
  TTURLDataResponse *response = request.response;
  labelData = [response.data copy];
}

- (void)handleSuccessfulPageRequest:(TTURLRequest *)request {
  TTURLImageResponse *response = request.response;
  TTUserInfo *userInfo = request.userInfo;
  
  NSDictionary *imageAndTitle = [[NSDictionary alloc] initWithObjectsAndKeys:
                                 response.image, @"image",
                                 [userInfo.strong objectForKey:@"title"], @"title",
                                 nil
                                 ];
  
  NSNumber *pageNumber = [userInfo.strong objectForKey:@"page"];
  [radarImages setObject:imageAndTitle forKey:pageNumber];
  [imageAndTitle release];
  
  if ([pageNumber integerValue] == 0) {
    [self displayPage:0];
    [theSlider setEnabled:YES];
  }
}


- (void)displayPage:(int)page {
  [self.radarImageView setImage:[[radarImages objectForKey:[NSNumber numberWithInt:page]] objectForKey:@"image"]];
  self.title =  [[radarImages objectForKey:[NSNumber numberWithInt:page]] objectForKey:@"title"];
  
  if (!firstImageDisplayed) {
    [self buildMapLabels];
    firstImageDisplayed = YES;
  }
}

- (void)buildMapLabels {
  NSError *error;
  GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithData:labelData options:XML_PARSE_NOCDATA error:&error];
  GDataXMLElement *rootNode = [document rootElement];
  NSArray *placenameNodes = [rootNode nodesForXPath:@"//placename" error:&error];
  
  CGSize imageSize = self.radarImageView.image.size;
  
  float scale;
  CGPoint offset;
  if (imageSize.height > imageSize.width) {
    // we're scaling by height
    scale = self.radarImageView.frame.size.height / imageSize.height;
    offset.x = -((imageSize.width*scale) - self.radarImageView.frame.size.width) / 2;
    
  } else {
    // we're scaling by width
    NSLog(@"Scaling by width");
    scale = self.radarImageView.frame.size.width / imageSize.width;
    offset.y = -((imageSize.height*scale) - self.radarImageView.frame.size.height) / 2;
  }
  
  for (GDataXMLElement *node in placenameNodes) {
    NSString *name = [[node attributeForName:@"name"] stringValue];
    NSString *align = [[node attributeForName:@"align"] stringValue];
    float originalX = [[[node attributeForName:@"x"] stringValue] floatValue];
    float originalY = [[[node attributeForName:@"y"] stringValue] floatValue];
    float newX = originalX * scale + offset.x;
    float newY = originalY * scale + offset.y;
    
    UIImageView *dotImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"dot.png"]];
    dotImageView.contentMode = UIViewContentModeCenter;
    dotImageView.center = CGPointMake(newX, newY);
    [self.view addSubview:dotImageView];
    [dotImageView release];
        
    UILabel *textLabel = [[UILabel alloc] init];
    textLabel.font = [UIFont boldSystemFontOfSize:12];
    textLabel.backgroundColor = [UIColor clearColor];
    textLabel.textColor = [UIColor whiteColor];
    textLabel.text = name;
    
    if ([align isEqualToString:@"left"]) {
      //NSLog(@"Align is right");
      textLabel.frame = CGRectMake(dotImageView.frame.origin.x - 203, dotImageView.frame.origin.y, 200, 12);
      textLabel.textAlignment = UITextAlignmentRight;
    } else {
      //NSLog(@"Align is left");
      textLabel.frame = CGRectMake(dotImageView.frame.origin.x + dotImageView.frame.size.width + 3, dotImageView.frame.origin.y, 200, 12);
      textLabel.textAlignment = UITextAlignmentLeft;

    }
    [self.view addSubview:textLabel];
    [textLabel release];
  }
}

- (void)sliderMoved:(UISlider *)sender {
  NSInteger page = floor(sender.value);
  [self displayPage:page];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
  // Release anything that's not essential, such as cached data
}

- (void)dealloc {
  [theSlider release];
  [labelData release];
  [radarImages release];
  [[TTURLRequestQueue mainQueue] cancelRequestsWithDelegate:self];
  [startDate release];
  [calendar release];
  [super dealloc];
}

@end
