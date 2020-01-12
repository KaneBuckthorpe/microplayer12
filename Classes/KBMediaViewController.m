#import "KBMediaViewController.h"

@implementation KBMediaViewController {
    NSTimer *_timer;
}
- (id)init {
	self = [super init];
	if (self) {
		[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(songChanged) name:(__bridge NSString*)kMRMediaRemoteNowPlayingInfoDidChangeNotification object:nil];
		[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(isPlayingChanged) name:(__bridge NSString*) kMRMediaRemoteNowPlayingApplicationIsPlayingDidChangeNotification object:nil];
self.defaultApp=@"com.apple.Music";
		[self reload];
	}
	return self;
}
-(void)reload{
[self songChanged];
[self calulateElapsedTime];
}

- (void)loadView {
	MPBaseView *baseView = [MPBaseView new];
	self.view = baseView;
}

-(NSString*)defaultSongName{
	return @"- - - -";
}

-(NSString*)defaultAlbumName{
	return @"- - - -";
}

-(UIImage*)defaultAlbumImage{
	return nil;
}

- (void)songChanged{
	MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef result) {
		NSDictionary *nowPlayingInfo=(__bridge NSDictionary *)result;

		NSString *songName = [nowPlayingInfo objectForKey:(__bridge NSString *) kMRMediaRemoteNowPlayingInfoTitle];
		songName = songName ? songName : self.defaultSongName;

		NSString *artistNameHolder = [nowPlayingInfo objectForKey:(__bridge NSString *) kMRMediaRemoteNowPlayingInfoArtist];
		artistNameHolder = artistNameHolder ? artistNameHolder : self.defaultAlbumName;
		
		UIImage *nowPlayingImage =[UIImage imageWithData: [nowPlayingInfo objectForKey:(NSData *)(__bridge NSString *) kMRMediaRemoteNowPlayingInfoArtworkData]];
		nowPlayingImage = nowPlayingImage ? nowPlayingImage : self.defaultAlbumImage;

		self.nowPlayingApp = [[objc_getClass("SBMediaController") sharedInstance] nowPlayingApplication];

		if (!self.nowPlayingApp) {
			self.nowPlayingApp = [[KBAppManager sharedInstance] appWithBundleID:self.defaultApp];
		}
		
		NSArray* colorScheme = [self mainColoursInImage:nowPlayingImage];
		
		[self songUpdateWithName:songName artist:artistNameHolder artwork:nowPlayingImage colorScheme:colorScheme];
	});
}

- (void)isPlayingChanged {
	MRMediaRemoteGetNowPlayingApplicationIsPlaying(dispatch_get_main_queue(), ^(Boolean isPlaying) {
		if (_timer) {
			[_timer invalidate];
			_timer = nil;
		}
		if (isPlaying) {
			_timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(calulateElapsedTime) userInfo:nil repeats:YES];
		}
	});
}

- (void)calulateElapsedTime {
	MRMediaRemoteGetNowPlayingInfo(dispatch_get_main_queue(), ^(CFDictionaryRef result) {
	NSTimeInterval duration = (NSTimeInterval)[[(__bridge NSDictionary *)result objectForKey:(__bridge NSString*)kMRMediaRemoteNowPlayingInfoDuration] floatValue];
	NSString*songLength=[NSString stringFromTime:duration];

	CFAbsoluteTime musicStartRef = CFDateGetAbsoluteTime((CFDateRef)[(__bridge NSDictionary *)result objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoTimestamp]);


	NSTimeInterval elapsedTimeRef = (NSTimeInterval)[[(__bridge NSDictionary *)result objectForKey:(__bridge NSString *)kMRMediaRemoteNowPlayingInfoElapsedTime] doubleValue];

	NSTimeInterval nowSec = (CFAbsoluteTimeGetCurrent() - musicStartRef) + (elapsedTimeRef>1?elapsedTimeRef:0);

	NSTimeInterval currentPlayback = duration?(nowSec/duration):0;
	NSTimeInterval realCurrentPlayback = currentPlayback*duration;


NSString* elapsedTime=[NSString stringFromTime:realCurrentPlayback];

double elapsedPercentage = realCurrentPlayback/duration;
	[self updateSongLength:songLength elapsedTime:elapsedTime elapsedPercentage:elapsedPercentage];
});
}

/// override in subclass
- (void)songUpdateWithName:(NSString*)songName artist:(NSString*)artistName artwork:(UIImage*)artworkImage colorScheme:(NSArray*)colorScheme{
}

-(void)updateSongLength:(NSString*)songLength elapsedTime:(NSString*)elapsedTime elapsedPercentage:(double)elapsedPercentage{	

}

/////Controls
- (void)next {
    MRMediaRemoteSendCommand(MRMediaRemoteCommandNextTrack, 0);
}
- (void)previous {
    MRMediaRemoteSendCommand(MRMediaRemoteCommandPreviousTrack, 0);
}
- (void)playOrPause {
    MRMediaRemoteSendCommand(MRMediaRemoteCommandTogglePlayPause, 0);
}


- (NSArray *)mainColoursInImage:(UIImage*)image{
	// Original code by Johnny Rockex http://stackoverflow.com/a/29266983/825644

	// Higher the dimension, the more pixels are checked against.
	const float pixelDimension = 32;
	// Higher the range, more similar colors are removed.
	const float filterRange = 150;

	const float kBytesPerPixel = 4;
	NSUInteger bytesPerRow = kBytesPerPixel * pixelDimension;
	NSUInteger kBitsInAByte = 8;

	unsigned char *rawData = (unsigned char*) calloc(pixelDimension * pixelDimension * kBytesPerPixel, sizeof(unsigned char));

	CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
	CGContextRef context = CGBitmapContextCreate(rawData, pixelDimension, pixelDimension, kBitsInAByte, bytesPerRow, colorSpace, kCGImageAlphaPremultipliedLast | kCGBitmapByteOrder32Big);
	CGColorSpaceRelease(colorSpace);
	CGContextDrawImage(context, CGRectMake(0, 0, pixelDimension, pixelDimension), [image CGImage]);
	CGContextRelease(context);

	NSMutableArray * colors = [[NSMutableArray alloc] init];
	float x = 0;
	float y = 0;
	const int pixelMatrixSize = pixelDimension * pixelDimension;
	for (int i = 0; i < pixelMatrixSize; i++){
		int index = (bytesPerRow * y) + x * kBytesPerPixel;
		int red   = rawData[index];
		int green = rawData[index + 1];
		int blue  = rawData[index + 2];
		int alpha = rawData[index + 3];
		UIColor * color = [UIColor colorWithRed:(red / 255.0f) green:(green / 255.0f) blue:(blue / 255.0f) alpha:alpha];
		[colors addObject:color];
		
		y++;
		if (y == pixelDimension){
			y = 0;
			x++;
		}
	}
	free(rawData);

	NSMutableDictionary * colorCounter = [[NSMutableDictionary alloc] init];
	NSCountedSet *countedSet = [[NSCountedSet alloc] initWithArray:colors];
	for (NSString *item in countedSet) {
		NSUInteger count = [countedSet countForObject:item];
		[colorCounter setValue:[NSNumber numberWithInteger:count] forKey:item];
	}

	NSArray *orderedColors = [colorCounter keysSortedByValueUsingComparator:^NSComparisonResult(id obj1, id obj2){
		return [obj2 compare:obj1];
	}];
	
	NSMutableArray *filteredColors = [NSMutableArray new];
	for (UIColor *color in orderedColors){
		bool filtered = false;
		for (UIColor *rangedColor in filteredColors){
			if (abs([self redRGBComponentFromColor:color]-[self redRGBComponentFromColor:rangedColor]) <= filterRange && 
			abs([self greenRGBComponentFromColor:color]-[self greenRGBComponentFromColor:rangedColor]) <= filterRange && 
			abs([self blueRGBComponentFromColor:color] - [self blueRGBComponentFromColor:rangedColor]) <= filterRange) {
				filtered = true;
				break;
			}
		}
		if (!filtered) {
			[filteredColors addObject:color];
		}
	}
	if (filteredColors.count<2){
		UIColor *dominantColor=[filteredColors firstObject];
		const CGFloat *componentColors = CGColorGetComponents(dominantColor.CGColor);
		CGFloat colorBrightness = ((componentColors[0] * 299) + (componentColors[1] * 587) + (componentColors[2] * 114)) / 1000;
		if (colorBrightness < 0.5){
			[filteredColors addObject:UIColor.whiteColor];
			///my color is dark    
		}else{
			[filteredColors addObject:UIColor.blackColor];
			////my color is light
		}
	}
	return [filteredColors copy];
}

-(uint8_t)redRGBComponentFromColor:(UIColor*)color{
	const CGFloat * colorComponents = CGColorGetComponents(color.CGColor);
	NSNumber*value=[NSNumber numberWithFloat: colorComponents[0] * 255];
	return (uint8_t)[value unsignedCharValue];
}
-(uint8_t)greenRGBComponentFromColor:(UIColor*)color{
	const CGFloat * colorComponents = CGColorGetComponents(color.CGColor);
	NSNumber*value=[NSNumber numberWithFloat: colorComponents[1] * 255];
	return (uint8_t)[value unsignedCharValue];
}
-(uint8_t)blueRGBComponentFromColor:(UIColor*)color{
	const CGFloat * colorComponents = CGColorGetComponents(color.CGColor);
	NSNumber*value=[NSNumber numberWithFloat:colorComponents[2] * 255];
	return (uint8_t)[value unsignedCharValue];		
}
@end