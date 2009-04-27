#import <Foundation/Foundation.h>

@interface RadarArea : NSObject {
  NSString *name;
  NSString *code;
}

@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *code;

+ (RadarArea *)radarAreaWithName:(NSString *)_name code:(NSString *)_code;

@end
