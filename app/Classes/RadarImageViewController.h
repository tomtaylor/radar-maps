#import <UIKit/UIKit.h>
#import <Three20/Three20.h>

@interface RadarImageViewController : UIViewController <TTURLRequestDelegate> {
  IBOutlet UIImageView *radarImageView;
  IBOutlet UIProgressView *myProgressView;
  IBOutlet TTSearchlightLabel *loadingLabel;
  IBOutlet UIBarButtonItem *forwardButton;
  IBOutlet UIBarButtonItem *rewindButton;
  IBOutlet UIBarButtonItem *playPauseButton;
  NSCalendar *calendar;
  NSDate *startDate;
  int selectedPage;
  BOOL firstImageDisplayed;
  BOOL playing;
  NSMutableDictionary *radarImages;
  NSData *labelData;
  NSTimer *playTimer;
  NSString *shortLabel;
}

@property (nonatomic, retain) IBOutlet UIImageView *radarImageView;
@property (nonatomic, retain) NSString *shortLabel;

- (id)initWithShortLabel:(NSString *)shortLabel;

- (IBAction)moveToNextPage;
- (IBAction)moveToPreviousPage;
- (IBAction)togglePlayPause;
- (void)buildMapLabels;
- (void)displayPage:(int)page;
- (void)enableDisableButtons;

- (void)fetchAllPages;
- (void)queueLabelsForFetch;
- (void)queuePageForFetch:(int)page;

@end
