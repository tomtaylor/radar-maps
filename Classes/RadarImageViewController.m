#import "RadarImageViewController.h"
#import "ASIHTTPRequest.h"
#import "GDataXMLNode.h"

#define MAX_PAGES 20;

@implementation RadarImageViewController

@synthesize radarImageView;
@synthesize labelRequest;
@synthesize shortLabel;

- (id) initWithShortLabel:(NSString *)shortLabel {
  self = [super init];
  if (self != nil) {
    self.shortLabel = shortLabel;
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
    
    networkQueue = [[ASINetworkQueue alloc] init];
    [networkQueue setMaxConcurrentOperationCount:4];
    radarImages = [[NSMutableDictionary alloc] init];
  }
  return self;
}

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
  
  forwardButton.enabled = NO;
  rewindButton.enabled = NO;
  playPauseButton.enabled = NO;
  
  [super viewDidLoad];
  [myProgressView setProgress:0];
  [self fetchAllPages];
}

- (void)fetchAllPages {
  [networkQueue setDelegate:self];
  [networkQueue setRequestDidFinishSelector:@selector(requestReturned:)];
  [networkQueue setRequestDidFailSelector:@selector(requestFailedToFetchImage:)];
  [networkQueue setQueueDidFinishSelector:@selector(queueDidFinish:)];
  [networkQueue setDownloadProgressDelegate:myProgressView];
  
  int max = MAX_PAGES;
  
  [self queueLabelsForFetch];
  for (int i = 0; i < max; i++) {
    [self queuePageForFetch:i];
  }
  
  [networkQueue go];
}

- (void)queueLabelsForFetch {
  NSString *urlString = [NSString stringWithFormat:@"http://news.bbc.co.uk/weather/map_presenter/%@/MapAreaNode.xml", self.shortLabel];
  NSURL *url = [NSURL URLWithString:urlString];
  ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
  [request setUserInfo:[NSDictionary dictionaryWithObject:[NSNumber numberWithBool:YES] forKey:@"labelRequest"]];
  [networkQueue addOperation:request];
}

- (void)queuePageForFetch:(int)page {
  NSDateComponents *offsetComponents = [[NSDateComponents alloc] init];
  [offsetComponents setHour:(3 * page)];
  NSDate *selectedDate = [calendar dateByAddingComponents:offsetComponents toDate:startDate options:0];
  
  NSCalendarUnit unitFlags = NSDayCalendarUnit | NSHourCalendarUnit;
  NSDateComponents *selectedDateComponents = [calendar components:unitFlags fromDate:selectedDate];
  NSString *urlString = [NSString stringWithFormat:@"http://newsimg.bbc.co.uk/weather/map_presenter/%02d/%02d/forecast/%@.jpg", [selectedDateComponents day], [selectedDateComponents hour], self.shortLabel];
  NSURL *url = [NSURL URLWithString:urlString];
  
  ASIHTTPRequest *request = [[[ASIHTTPRequest alloc] initWithURL:url] autorelease];
  
  NSDateFormatter *outputFormatter = [[NSDateFormatter alloc] init];
  [outputFormatter setAMSymbol:@""];
  [outputFormatter setPMSymbol:@""];
  [outputFormatter setDateFormat:@"EEEE haa"];
  NSString *title = [outputFormatter stringFromDate:selectedDate];
  [outputFormatter release];
  [request setUserInfo:[NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithInt:page], @"page", title, @"title", nil]];
  [networkQueue addOperation:request];
}

- (void)requestReturned:(ASIHTTPRequest *)request {
  NSLog(@"Request returned.");
  
  if ([[request userInfo] objectForKey:@"labelRequest"] == [NSNumber numberWithBool:YES]) {
    self.labelRequest = [request retain];
    NSLog(@"Label request");
  } else {  
    NSLog(@"Not a label request");
    NSData *data = [request responseData];
    UIImage *image = [[UIImage alloc] initWithData:data];
    
    NSDictionary *imageAndTitle = [[NSDictionary alloc] initWithObjectsAndKeys:
                                   image, @"image",
                                   [[request userInfo] objectForKey:@"title"], @"title",
                                   nil
                                   ];
    [image release];
    [radarImages setObject:imageAndTitle forKey:[[request userInfo] objectForKey:@"page"]];
    [imageAndTitle release];
  }
}

- (void)queueDidFinish:(ASINetworkQueue *)queue {
  NSLog(@"Queue finished.");
  [myProgressView removeFromSuperview];
  [loadingLabel removeFromSuperview];
  [self displayPage:selectedPage];
  [self enableDisableButtons];
  playPauseButton.enabled = YES;
}

- (void)requestFailedToFetchImage:(ASIHTTPRequest *)request {
  NSLog(@"Failed to fetch image.");
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
  NSData *xmlData = [labelRequest responseData];
  NSError *error;
  GDataXMLDocument *document = [[GDataXMLDocument alloc] initWithData:xmlData options:XML_PARSE_NOCDATA error:&error];
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
  }
}

- (IBAction)moveToNextPage {
  selectedPage += 1;
  [self displayPage:selectedPage];
  [self enableDisableButtons];
  
  int max = MAX_PAGES;
  max -= 1;
  if ([playTimer isValid] && selectedPage == max) {
    [playTimer invalidate];
    playTimer = nil;
  }
}

- (IBAction)moveToPreviousPage {
  selectedPage -= 1;
  [self displayPage:selectedPage];
  [self enableDisableButtons];
}

- (void)enableDisableButtons {
  if (playing) {
    rewindButton.enabled = NO;
    forwardButton.enabled = NO;
  } else {
    if (selectedPage > 0) {
      rewindButton.enabled = YES;
    } else {
      rewindButton.enabled = NO;
    }
    
    int max = MAX_PAGES;
    max -= 1;
    if (selectedPage < max) {
      forwardButton.enabled = YES;
    } else {
      forwardButton.enabled = NO;
    }
  }

}

- (IBAction)togglePlayPause {
  //playPauseButton.
  if (playing) {
    playing = NO;
    [playTimer invalidate];
  } else {
    playing = YES;
    playTimer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(moveToNextPage) userInfo:nil repeats:YES];
  }
  [self enableDisableButtons];
}

- (void)didReceiveMemoryWarning {
  [super didReceiveMemoryWarning]; // Releases the view if it doesn't have a superview
  // Release anything that's not essential, such as cached data
}

- (void)dealloc {
  if (labelRequest)
    [labelRequest release];
  [radarImages release];
  [networkQueue cancelAllOperations];
  [networkQueue release];
  [startDate release];
  [calendar release];
  [super dealloc];
}

@end
