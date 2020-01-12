#import "NSString+TimeToString.h"

@implementation NSString (MusicTime)
+ (NSString *)stringFromTime:(NSTimeInterval)seconds {
    NSString *timeString = nil;
    const int secsPerMin = 60;
	const int minsPerHour = 60;
	const char *timeSep = ":";
	seconds = floor(seconds);

	if (seconds < 60.0) {
		timeString = [NSString stringWithFormat:@"0:%02.0f", seconds];
	} else {
        int mins = seconds/secsPerMin;
        int secs = seconds - mins*secsPerMin;

        if (mins < 60.0) {
            timeString = [NSString stringWithFormat:@"%d%s%02d", mins, timeSep, secs];
        } else {
            int hours = mins/minsPerHour;
            mins -= hours * minsPerHour;
            timeString = [NSString stringWithFormat:@"%d%s%02d%s%02d", hours, timeSep, mins, timeSep, secs];
        }
    }

    return timeString;
}
@end
