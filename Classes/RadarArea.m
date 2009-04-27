#import "RadarArea.h"

@implementation RadarArea

@synthesize name;
@synthesize code;

+ (RadarArea *)radarAreaWithName:(NSString *)_name code:(NSString *)_code {
  RadarArea *radarArea = [[RadarArea alloc] init];
  radarArea.name = _name;
  radarArea.code = _code;
  [radarArea autorelease];
  return radarArea;
}

@end
