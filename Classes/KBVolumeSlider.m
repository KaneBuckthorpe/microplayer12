#import "KBVolumeSlider.h"

@implementation KBVolumeSlider

- (id)initWithFrame:(CGRect)frame{
	self = [super initWithFrame:frame];
	
	[NSNotificationCenter.defaultCenter addObserver:self selector:@selector(updateValueAnimated) name:@"AVSystemController_SystemVolumeDidChangeNotification" object:nil];
	
	float sliderHeight=self.frame.size.height;
	self.thumbImageView= [UIImageView.alloc initWithFrame: CGRectMake(0,0, sliderHeight, sliderHeight)];
	[self addSubview: self.thumbImageView];
	[self setThumbImage:UIImage.alloc.init forState:UIControlStateHighlighted];
	[self setMaximumTrackImage:UIImage.alloc.init forState:UIControlStateNormal];
	
	///My custom Slider Gesture
	self.sliderRecognizer = [KBTouchDownRecogniser.alloc initWithTarget:self  action:@selector(tapAndSlide:)];
	[self addGestureRecognizer: self.sliderRecognizer];
	[self updateValueAnimated];
	return self;
}

- (VolumeControl *)volumeController {
    return (VolumeControl *)[objc_getClass("VolumeControl")
        sharedVolumeControl];
}

// Volume controllers
- (AVSystemController *)audioController {

    return [objc_getClass("AVSystemController") sharedAVSystemController];
}

- (float)volume {
    float volume = 0.06;
    [self.audioController getVolume:&volume forCategory:@"Audio/Video"];
    return volume;
}

-(void)setVolume:(float) volume {
    [self.volumeController addAlwaysHiddenCategory:@"Audio/Video"];
        if (![self.audioController setVolumeTo:self.value
                                   forCategory:@"Audio/Video"]) {
            NSLog(@"setVolumeForRinger failed.");
        }
    [self.volumeController removeAlwaysHiddenCategory:@"Audio/Video"];
}

-(void)updateThumbColor:(UIColor*)color{
self.thumbColor=color;
[self slideImage];
}

- (CGRect)thumbRect {
	CGRect trackRect = [self trackRectForBounds:self.bounds];
    return [self thumbRectForBounds:self.bounds trackRect:trackRect value: [self volume]];
}

-(void)updateValueAnimated{
	[UIView animateWithDuration:0.25 delay:0. options:UIViewAnimationOptionCurveEaseInOut animations:^{
		[self setValue:[self volume]];
		[self slideImage];
	} completion:nil];
}

- (void)tapAndSlide:(KBTouchDownRecogniser*)gesture{
	CGPoint pt = [gesture locationInView: self];
	CGFloat thumbWidth = [self thumbRect].size.width;
	CGFloat value;
	
	if(pt.x <= [self thumbRect].size.width/2.0){
		value = self.minimumValue;
	}else if(pt.x >= self.bounds.size.width - thumbWidth/2.0){
		value = self.maximumValue;
	}else {
		CGFloat percentage = (pt.x - thumbWidth/2.0)/(self.bounds.size.width - thumbWidth);
		CGFloat delta = percentage * (self.maximumValue - self.minimumValue);
		value = self.minimumValue + delta;
	}
	
	if ((gesture.state == UIGestureRecognizerStateBegan) || (gesture.state == UIGestureRecognizerStateChanged)){
        [self setVolume:value];
		self.isChangingVolume=YES;
    }
}

-(void)slideImage{
	[self bringSubviewToFront: self.thumbImageView];
	float thumbWidth=self.thumbImageView.bounds.size.width;
	float newPosition = self.value* (self.bounds.size.width-thumbWidth)+thumbWidth/2;
	self.thumbImageView.center= CGPointMake(newPosition, self.frame.size.height/2);
	self.thumbImageView.image=[KBVolumeAnimation imageOfVolumeSliderWithValue:self.value color:self.thumbColor];
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent*)event {
	CGRect bounds = self.bounds;
	bounds = CGRectInset(bounds, -20, 5);
	return CGRectContainsPoint(bounds, point);
}
@end
