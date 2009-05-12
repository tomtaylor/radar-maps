#import <UIKit/UIKit.h>
#import "ASINetworkQueue.h"
#import "ASIHTTPRequest.h"

@interface RadarImageViewController : UIViewController {
  IBOutlet UIImageView *radarImageView;
  IBOutlet UIProgressView *myProgressView;
  IBOutlet UILabel *loadingLabel;
  IBOutlet UIBarButtonItem *forwardButton;
  IBOutlet UIBarButtonItem *rewindButton;
  IBOutlet UIBarButtonItem *playPauseButton;
  NSCalendar *calendar;
  NSDate *startDate;
  int selectedPage;
  BOOL firstImageDisplayed;
  BOOL playing;
  ASINetworkQueue *networkQueue;
  NSMutableDictionary *radarImages;
  ASIHTTPRequest *labelRequest;
  NSTimer *playTimer;
  NSString *shortLabel;
}

@property (nonatomic, retain) IBOutlet UIImageView *radarImageView;
@property (nonatomic, retain) ASIHTTPRequest *labelRequest;
@property (nonatomic, retain) NSString *shortLabel;

- (IBAction)moveToNextPage;
- (IBAction)moveToPreviousPage;
- (IBAction)togglePlayPause;
- (void)buildMapLabels;
- (void)displayPage:(int)page;
- (void)enableDisableButtons;

@end
