#import "MPViewController.h"

@implementation MPViewController{
float _lastScale;
float _grabberScale;
}
NSUserDefaults *preferences;
MPBaseView * containerView;
CGPoint microPlayerCenterRef;
CGPoint grabberCenterRef;
float microPlayerScale;
UIProgressView *progressView;
BOOL darkDefaultImage=YES;
float backgroundOpacity = 1;
int selectedHomePage=1;
BOOL forceTouchEnabled=YES;


-(id)initWithHomeScreenView:(SBIconScrollView*)homeScreenView{
	self=[super init];
	if (self){
		int regToken;
		notify_register_dispatch("com.kaneb.microplayer12/prefchanged", &regToken, dispatch_get_main_queue(), ^(int token) {
			[self reloadMicroPlayerViews];
		});
		self.homeScreenView=homeScreenView;
		[self loadPreferences];
		[self loadWindow];
		[self loadPlayerViews];
	}
	return self;
}

-(void)loadPreferences {
	preferences = [[NSUserDefaults alloc] initWithSuiteName:@"com.kaneb.microplayer12"];   
	
	///HomeScreen
	selectedHomePage=[preferences objectForKey:@"selectedHomeScreenPage"]?[preferences integerForKey:@"selectedHomeScreenPage"]:1;       
	self.wantsHomeScreen=[preferences objectForKey:@"addToHomescreen"]?[preferences boolForKey:@"addToHomescreen"]:NO;
	self.mode=MPHidden;       
	
	//Size and positioning
	CGPoint defaultCenterRef=CGPointMake(0.5,0.5);
	
	microPlayerCenterRef =[preferences objectForKey:@"microPlayerCenterRef"] ? CGPointFromString([preferences objectForKey:@"microPlayerCenterRef"]):defaultCenterRef;
	if(microPlayerCenterRef.x<0||microPlayerCenterRef.y<0){ microPlayerCenterRef = defaultCenterRef;}
	
	grabberCenterRef = [preferences objectForKey:@"grabberCenterRef"]? CGPointFromString([preferences objectForKey:@"grabberCenterRef"]):microPlayerCenterRef;
	if(grabberCenterRef.x<0||grabberCenterRef.y<0){ grabberCenterRef = microPlayerCenterRef; }
	
	microPlayerScale = [preferences objectForKey:@"microPlayerScale"]?[preferences floatForKey:@"microPlayerScale"]:1;
    _grabberScale =[preferences objectForKey:@"grabberSize"]?[preferences floatForKey:@"grabberSize"]/100.00:0.3;
    self.playerWantsOpening=NO;
	
	///Styling
	self.backgroundColor = UIColor.clearColor;
	backgroundOpacity=[preferences objectForKey:@"backgroundOpacity"]?[preferences floatForKey:@"backgroundOpacity"]/100.00:1;
	darkDefaultImage=[preferences objectForKey:@"darkDefaultImage"]?[preferences boolForKey:@"darkDefaultImage"]:YES;
	
	///Other
	NSArray*musicApps = [preferences objectForKey:@"defaultApp"]?[preferences objectForKey:@"defaultApp"]:nil;
	self.defaultApp=(musicApps.count>=1)?[[musicApps firstObject]valueForKey:@"bundleID"]:@"com.apple.Music";
	forceTouchEnabled=[preferences objectForKey:@"forceTouchEnabled"]?[preferences boolForKey:@"forceTouchEnabled"]:YES;
}

-(UIImage*)defaultAlbumImage{
	NSString *bundlePath = @"/Library/Application Support/MicroPlayer";
	NSBundle *bundle = [NSBundle bundleWithPath:bundlePath];
	
	NSString* imageName=darkDefaultImage?@"defaultArtworkDark":@"defaultArtworkLight";
	return [UIImage imageNamed:imageName inBundle:bundle compatibleWithTraitCollection:nil];
	
}

- (void)loadWindow {
	self.window = [[PIWindow alloc]initWithFrame:UIScreen.mainScreen.bounds];
	self.window.hidden=NO;
}

-(void)layoutWindow{
	SpringBoard *springBoard = (SpringBoard*)[NSClassFromString(@"SpringBoard") sharedApplication];
	int orientation;
	SBApplication* frontApp=springBoard._accessibilityFrontMostApplication;	
	if (frontApp){
		orientation=frontApp.mainScene.currentInterfaceOrientation;
	} else {
		orientation=springBoard.activeInterfaceOrientation;
	}
	[self.window _rotateWindowToOrientation:orientation updateStatusBar:NO duration:0.3 skipCallbacks:NO];
}

-(void)loadView{
	[super loadView];
	[self.homeScreenView addSubview:self.view]; ///got homescreenView added
}

-(void)layoutContainerView{	
	if(containerView.superview){
		containerView.frame=containerView.superview.bounds;
	}
	containerView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
	containerView.translatesAutoresizingMaskIntoConstraints = YES;

}

-(void)addMicroplayerToHomeScreenAsGrabber:(BOOL)grabber{
	if((self.mode!=MPHomeScreen)||(self.isGrabber!=grabber)){
		if(containerView){
			[UIView animateWithDuration:0.6f animations:^{
			//self.microPlayerView.alpha = 0.0f;
			[self.view addSubview:containerView];	
			[self showGrabber:grabber];
			[self viewWillLayoutSubviews];
			}];
			self.mode=MPHomeScreen;	
			if(self.isDisplayingApp&!grabber){
				[self hideApp];
			}
			[UIView animateWithDuration:0.6f animations:^{
			///	self.microPlayerView.alpha = 1.0f;
			}];
		}
	}
}

-(void)addToSystemWideAsGrabber:(BOOL)grabber{
	if((self.mode!=MPSystemWide)||(self.isGrabber!=grabber)){
		//self.microPlayerView.alpha = 0.0f;
		[UIView animateWithDuration:0.6f animations:^{
		[self.window addSubview:containerView];
		[self showGrabber:grabber];
		[self viewWillLayoutSubviews];
		}];
		if (self.isDisplayingApp&!grabber) {
			[self hideApp];
		}
        /*
		[UIView animateWithDuration:0.6f animations:^{
			self.microPlayerView.alpha = 1.0f;
		}];
         */
		self.mode=MPSystemWide;
	}
}

- (void)loadPlayerViews {
	if(!containerView){
		containerView= [MPBaseView new];
	}
	
	self.microPlayerView = [[UIView alloc] initWithFrame:CGRectMake(150, 350, 175, 175)];
	self.microPlayerView.layer.cornerRadius = 16;
	self.microPlayerView.layer.borderWidth = 1.5f;
	[containerView addSubview:self.microPlayerView];
	
	self.backgroundView = [[UIView alloc] initWithFrame:self.microPlayerView.bounds];
	self.backgroundView.backgroundColor = self.backgroundColor;
	self.backgroundView.userInteractionEnabled = NO;
	self.backgroundView.layer.cornerRadius = 16;
	self.backgroundView.layer.borderWidth = 3.0f;
	self.backgroundView.alpha=backgroundOpacity;
	[self.microPlayerView addSubview:self.backgroundView];
	
	self.volumeSlider = [[KBVolumeSlider alloc] initWithFrame:CGRectMake(14, 128.5, 147, 35)];
	self.volumeSlider.layer.zPosition=1;
	self.volumeSlider.minimumValue = 0.0;
	self.volumeSlider.maximumValue = 1.0;
	self.volumeSlider.continuous = YES;
	self.volumeSlider.sliderRecognizer.delegate = self;
	
	[self.microPlayerView addSubview:self.volumeSlider];
	
	self.currentPlaybackLabel = [[UILabel alloc] initWithFrame:CGRectMake(61.25, 17.5, 30, 26.25)];
	self.currentPlaybackLabel.backgroundColor = UIColor.clearColor;
	self.currentPlaybackLabel.textAlignment=NSTextAlignmentLeft;
	[self.currentPlaybackLabel setFont:[UIFont fontWithName:@".SFUIText-Medium" size:12]];
	[self.microPlayerView addSubview:self.currentPlaybackLabel];
	
	self.durationLabel = [[UILabel alloc] initWithFrame:CGRectMake(128.625, 18.375, 35, 26.25)];
	self.durationLabel.backgroundColor = UIColor.clearColor;
	self.durationLabel.textAlignment=NSTextAlignmentRight;
	[self.durationLabel setFont:[UIFont fontWithName:@".SFUIText-Medium" size:12]];
	[self.microPlayerView addSubview:self.durationLabel];
	
	progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(62.5, 44.625, 101.25, 8.75)];
	progressView.trackTintColor = UIColor.blackColor;
	progressView.progress = 0.75f;
	[self.microPlayerView addSubview:progressView];
	
	self.songTitle = [[ScrollyLabel alloc] initWithFrame:CGRectMake(8.75, 61.25, 157.5, 26.25)];
	self.songTitle.backgroundColor = UIColor.clearColor;
	self.songTitle.textAlignment=NSTextAlignmentCenter;
	self.songTitle.font = [UIFont fontWithName:@".SFUIText-Semibold" size:18];
	self.songTitle.labelSpacing = 50;
	self.songTitle.pauseInterval = 0;
	self.songTitle.scrollSpeed = 18;
	self.songTitle.fadeLength = 2.0f;
	self.songTitle.scrollDirection = ScrollyLabelDirectionLeft;
	[self.microPlayerView addSubview:self.songTitle];
	
	self.artistName = [[ScrollyLabel alloc] initWithFrame:CGRectMake(8.75, 96.25, 157.5, 26.25)];
	self.artistName.backgroundColor = UIColor.clearColor;
	self.artistName.textAlignment=NSTextAlignmentCenter;
	self.artistName.font=[UIFont fontWithName:@".SFUIText" size:16];
	self.artistName.labelSpacing = 50;
	self.artistName.pauseInterval = 0;
	self.artistName.scrollSpeed = 18;
	self.artistName.fadeLength = 2.0f;
	self.artistName.scrollDirection = ScrollyLabelDirectionLeft;
	[self.microPlayerView addSubview:self.artistName];
	
	self.musicCoverView =[[PIUIImageView alloc] initWithFrame:CGRectMake(2.5, 2.5, 170, 170)];
	self.musicCoverView.backgroundColor = UIColor.blackColor;
	self.musicCoverView.layer.cornerRadius = 14;
	self.musicCoverView.layer.borderColor = UIColor.blackColor.CGColor;
	self.musicCoverView.layer.borderWidth = 1.0f;
	self.musicCoverView.clipsToBounds = YES;
	self.musicCoverView.userInteractionEnabled = NO;
	self.musicCoverView.contentMode=UIViewContentModeScaleAspectFit;
	[self.microPlayerView addSubview:self.musicCoverView];
	
	/// Adding Gestures
	KBForceTouchGestureRecognizer*forceTouchGesture=[[KBForceTouchGestureRecognizer alloc] initWithTarget:self action:@selector(showOrHideApp:)];
	forceTouchGesture.enabled=forceTouchEnabled;
	[self.microPlayerView addGestureRecognizer:forceTouchGesture];
	
	UITapGestureRecognizer*doubleTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self  action:@selector(toggleGrabber)];
	doubleTapGesture.numberOfTapsRequired = 2;
	doubleTapGesture.delegate = self;
	[self.microPlayerView addGestureRecognizer:doubleTapGesture];
	
	UITapGestureRecognizer*tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(playOrPause)];
	tapGesture.numberOfTapsRequired = 1;
	tapGesture.delegate = self;
	[self.microPlayerView addGestureRecognizer:tapGesture];
	
	UIPanGestureRecognizer *movePan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(moveMicroPlayer:)];
	movePan.minimumNumberOfTouches=1;
	movePan.maximumNumberOfTouches=2;
	movePan.delegate = self;
	[self.microPlayerView addGestureRecognizer:movePan];
	
	self.upSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipe:)];
	self.upSwipe.direction=UISwipeGestureRecognizerDirectionUp;
	self.upSwipe.delegate = self;
	self.upSwipe.numberOfTouchesRequired = 1;
	[self.microPlayerView addGestureRecognizer:self.upSwipe];
	
	self.rightSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipe:)];
	self.rightSwipe.direction=UISwipeGestureRecognizerDirectionRight;
	self.rightSwipe.delegate = self;
	self.rightSwipe.numberOfTouchesRequired = 1;
	[self.microPlayerView addGestureRecognizer:self.rightSwipe];
	
	self.leftSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipe:)];
	self.leftSwipe.direction=UISwipeGestureRecognizerDirectionLeft;
	self.leftSwipe.numberOfTouchesRequired = 1;
	self.leftSwipe.delegate = self;
	[self.microPlayerView addGestureRecognizer:self.leftSwipe];
	
	self.downSwipe = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipe:)];
	self.downSwipe.direction=UISwipeGestureRecognizerDirectionDown;
	self.downSwipe.delegate = self;
	self.downSwipe.numberOfTouchesRequired = 1;
	[self.microPlayerView addGestureRecognizer:self.downSwipe];
	
	self.twoFingerPinch = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(scalePlayer:)];
	self.twoFingerPinch.delegate = self;
	[self.microPlayerView addGestureRecognizer:self.twoFingerPinch];
	
	UILongPressGestureRecognizer* longHoldGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(showOrHideApp:)];
	longHoldGesture.delegate = self;
	longHoldGesture.numberOfTouchesRequired = 1;
	longHoldGesture.minimumPressDuration = 0.5;
	[self.microPlayerView addGestureRecognizer:longHoldGesture];
	
	/// Setting Gesture Priority
	
	/// pan
	[movePan requireGestureRecognizerToFail:forceTouchGesture];
	[movePan requireGestureRecognizerToFail:self.rightSwipe];
	[movePan requireGestureRecognizerToFail:self.leftSwipe];
	[movePan requireGestureRecognizerToFail:self.upSwipe];
	[movePan requireGestureRecognizerToFail:self.downSwipe];
	
	/// pinch
	[self.rightSwipe requireGestureRecognizerToFail:self.twoFingerPinch];
	[self.leftSwipe requireGestureRecognizerToFail:self.twoFingerPinch];
	[self.downSwipe requireGestureRecognizerToFail:self.twoFingerPinch];
	[self.upSwipe requireGestureRecognizerToFail:self.twoFingerPinch];
	
	/// longHold
	[tapGesture requireGestureRecognizerToFail:longHoldGesture];
	[longHoldGesture requireGestureRecognizerToFail:movePan];
	[self.upSwipe requireGestureRecognizerToFail:self.volumeSlider.sliderRecognizer];
	[self.downSwipe requireGestureRecognizerToFail:self.volumeSlider.sliderRecognizer];
	
	/// double Tap
	[tapGesture requireGestureRecognizerToFail:doubleTapGesture];
	
	if (self.wantsHomeScreen) {
		[self addMicroplayerToHomeScreenAsGrabber:self.isGrabber];
	}
	[self layoutContainerView];
}
-(void)viewWillLayoutSubviews{
	[self layoutHomeScreenBaseView];
	if (self.mode==MPSystemWide){
		[self layoutWindow];
	}
	[self layoutContainerView];
	[self layoutMicroPlayer];
	if (self.isDisplayingApp){
		[self layoutAppView];
	}
	NSLog(@"1234");
}

-(void)layoutHomeScreenBaseView{
	CGFloat statusBarHeight = UIApplication.sharedApplication.statusBarFrame.size.height;
	CGSize homeScreenSize=self.homeScreenView.frame.size;
	self.view.frame= CGRectMake(homeScreenSize.width*selectedHomePage,-statusBarHeight,homeScreenSize.width,homeScreenSize.height+ statusBarHeight);
	[self.view bringSubviewToFront:containerView];
}

-(void)layoutMicroPlayer{
	
		self.microPlayerView.transform =CGAffineTransformMakeScale(self.scale, self.scale);
	CGFloat totalMovableWidth=floor(self.microPlayerView.superview.bounds.size.width-self.microPlayerView.frame.size.width);
	CGFloat centerXForCalculation= self.centerRef.x*totalMovableWidth;
	
	CGFloat totalMovableHeight=floor(self.microPlayerView.superview.bounds.size.height-self.microPlayerView.frame.size.height);
	CGFloat centerYForCalculation=self.centerRef.y*totalMovableHeight;
	
	CGFloat centerX=centerXForCalculation+ceil(self.microPlayerView.frame.size.width/2.0f);
	CGFloat centerY=centerYForCalculation+ceil(self.microPlayerView.frame.size.height/2.0f);
	self.microPlayerView.center=CGPointMake(centerX,centerY);	

}

-(CGPoint)centerRef{
	return self.isGrabber ? grabberCenterRef:microPlayerCenterRef;
}

-(float)scale{
	return self.isGrabber ? _grabberScale :microPlayerScale;
}

-(void)reloadMicroPlayerViews{
	[super reload];
	for (UIView __strong *view in containerView.subviews) {
		[view removeFromSuperview], view=nil;
	}	
	[containerView removeFromSuperview], containerView=nil;
	[self loadPreferences];
	[self loadPlayerViews];
	[self layoutHomeScreenBaseView];
	[self layoutMicroPlayer];
	if(self.isDisplayingApp){
		[self showApp];
	}
}

/////song animations
- (void)danceForSong:(NSString *)songTitle {
	if ([songTitle isEqualToString:@"Harlem Shake"]) {
		CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
		[animation setDuration:0.05];
		[animation setRepeatCount:16];
		[animation setAutoreverses:YES];
		[animation setFromValue:[NSValue valueWithCGPoint:CGPointMake(self.microPlayerView.center.x-30.0f, self.microPlayerView.center.y-30)]];
		[animation setToValue:[NSValue valueWithCGPoint:CGPointMake(self.microPlayerView.center.x+30.0f, self.microPlayerView.center.y+30)]];
		[self.microPlayerView.layer addAnimation:animation forKey:@"position"];
	}
}

////Gesture Methods

- (void)moveMicroPlayer:(UIPanGestureRecognizer *)pan {
	CGPoint translation = [pan translationInView:pan.view.superview];
	CGRect recognizerFrame = pan.view.frame;
	recognizerFrame.origin.x += translation.x;
	recognizerFrame.origin.y += translation.y;
	
	// Check if UIView is completely inside its superView
	if (CGRectContainsRect(pan.view.superview.bounds, recognizerFrame)) {
		pan.view.frame = recognizerFrame;
	} else {
		// Check vertically outside of superView
		if (recognizerFrame.origin.y < pan.view.superview.bounds.origin.y) {
			recognizerFrame.origin.y = 0;
		} else if (recognizerFrame.origin.y + recognizerFrame.size.height > pan.view.superview.bounds.size.height) {
			recognizerFrame.origin.y =pan.view.superview.bounds.size.height - recognizerFrame.size.height;
		}
		// Check horizantally outside of superView
		if (recognizerFrame.origin.x < pan.view.superview.bounds.origin.x) {
			recognizerFrame.origin.x = 0;
		} else if (recognizerFrame.origin.x + recognizerFrame.size.width > pan.view.superview.bounds.size.width) {
			recognizerFrame.origin.x = pan.view.superview.bounds.size.width - recognizerFrame.size.width;
		}
	}

	CGFloat centerXForCalculation=ceil(pan.view.center.x-(recognizerFrame.size.width/2.0f));
	CGFloat totalMovableWidth=floor(pan.view.superview.bounds.size.width-recognizerFrame.size.width);
	CGFloat centerXRef=centerXForCalculation/totalMovableWidth;
    
    CGFloat centerYForCalculation=ceil(pan.view.center.y-(recognizerFrame.size.height/2.0f));
    CGFloat totalMovableHeight=floor(pan.view.superview.bounds.size.height-recognizerFrame.size.height);
    CGFloat centerYRef=centerYForCalculation/totalMovableHeight;
	
	CGPoint centerRef=CGPointMake(centerXRef,centerYRef);
 
	if (self.isGrabber) {
		grabberCenterRef = centerRef;
		[preferences setObject:NSStringFromCGPoint(grabberCenterRef) forKey:@"grabberCenterRef"];
	} else {
		microPlayerCenterRef = centerRef;
		[preferences setObject:NSStringFromCGPoint(microPlayerCenterRef) forKey:@"microPlayerCenterRef"];
	}
	/// Reset translation so that on next pan recognition we get correct translation value
	[pan setTranslation:CGPointMake(0, 0) inView:pan.view.superview];
	
	if (pan.state == UIGestureRecognizerStateEnded) {
		[preferences synchronize];
	}
}

- (void)scalePlayer:(UIPinchGestureRecognizer *)gestureRecognizer {
	if (gestureRecognizer.state == UIGestureRecognizerStateBegan) {
		// Reset the last scale, necessary if there are multiple objects with different scales.
		_lastScale = gestureRecognizer.scale;
	}
	
	if (gestureRecognizer.state == UIGestureRecognizerStateBegan || gestureRecognizer.state == UIGestureRecognizerStateChanged) {
		CGFloat currentScale = [[gestureRecognizer.view.layer valueForKeyPath:@"transform.scale"] floatValue];
		
		// Constants to adjust the max/min values of zoom
		const CGFloat kMaxScale = 1.25;
		const CGFloat kMinScale = 0.75;
		
		CGFloat newScale =1 - (_lastScale - gestureRecognizer.scale); // new scale is in the range (0-1)
		newScale = MIN(newScale, kMaxScale / currentScale);
		newScale = MAX(newScale, kMinScale / currentScale);
		
		dispatch_async(dispatch_get_main_queue(), ^{ 
			CGAffineTransform transform = CGAffineTransformScale(gestureRecognizer.view.transform, newScale, newScale);
			gestureRecognizer.view.transform = transform;
		});
		CGRect gestureViewFrame = gestureRecognizer.view.frame;
		CGRect gestureSuperViewBounds = gestureRecognizer.view.superview.bounds;
		
		if (gestureViewFrame.origin.y < gestureSuperViewBounds.origin.y) {
			gestureViewFrame.origin.y = 0;
		} else if (gestureViewFrame.origin.y + gestureViewFrame.size.height > gestureSuperViewBounds.size.height) {
			gestureViewFrame.origin.y = gestureSuperViewBounds.size.height - gestureViewFrame.size.height;
		}
		
		// Check horizantally
		if (gestureViewFrame.origin.x < gestureSuperViewBounds.origin.x) {
			gestureViewFrame.origin.x = 0;
		} else if (gestureViewFrame.origin.x + gestureViewFrame.size.width > gestureSuperViewBounds.size.width) {
			gestureViewFrame.origin.x = gestureSuperViewBounds.size.width - gestureViewFrame.size.width;
		}
		gestureRecognizer.view.frame = gestureViewFrame;
		_lastScale = gestureRecognizer.scale;
		
		CGFloat xScale = gestureRecognizer.view.transform.a;
		microPlayerScale = xScale;
		[preferences setFloat:xScale forKey:@"microPlayerScale"];
	}
	if (gestureRecognizer.state == UIGestureRecognizerStateEnded) {
		[preferences synchronize];
	}
}

- (void)didSwipe:(UISwipeGestureRecognizer *)recognizer {
	if (recognizer.direction == UISwipeGestureRecognizerDirectionRight) {
		[self previous];
	} else if (recognizer.direction == UISwipeGestureRecognizerDirectionLeft) {
		[self next];
	} else if (recognizer.direction == UISwipeGestureRecognizerDirectionUp) {
		[self setPlayerOpen:YES];
		self.playerWantsOpening=YES;
	} else if (recognizer.direction == UISwipeGestureRecognizerDirectionDown) {
		[self setPlayerOpen:NO];
		self.playerWantsOpening=NO;
	}
}

- (void)toggleGrabber {
	if (self.isGrabber) {
		self.wantsGrabber = NO;
		if (self.isDisplayingApp) {
			[self hideApp];
		}
		[self showGrabber:NO];
	} else {
		self.wantsGrabber = YES;
		[self showGrabber:YES];
	}
}

- (void)showGrabber:(BOOL)show {
	if (show) {
		///// Display as grabber
		self.isGrabber = YES;
		self.upSwipe.enabled = NO;
		self.downSwipe.enabled = NO;
		self.leftSwipe.enabled = NO;
		self.rightSwipe.enabled = NO;
		self.twoFingerPinch.enabled = NO;
		self.volumeSlider.sliderRecognizer.enabled = NO;
		[self setPlayerOpen:NO];
		
		[UIView animateWithDuration:0.30 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
			[self layoutMicroPlayer];
		} completion:nil];
	} else {

		///// Display as music player
		self.isGrabber = NO;
		self.upSwipe.enabled = YES;
		self.downSwipe.enabled = YES;
		self.leftSwipe.enabled = YES;
		self.rightSwipe.enabled = YES;
		self.twoFingerPinch.enabled = YES;
		self.volumeSlider.sliderRecognizer.enabled = YES;
		
		[UIView animateWithDuration:0.30 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
			[self layoutMicroPlayer];
			
			if(self.playerWantsOpening){
			[self setPlayerOpen:YES];
			}
			}completion:nil];
	}
}


- (void)setPlayerOpen:(BOOL)open {
	if (open) {
		dispatch_async(dispatch_get_main_queue(), ^{
			[UIView animateWithDuration:0.20 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
				CGAffineTransform scaleTrans = CGAffineTransformMakeScale(0.25, 0.25);
				CGAffineTransform smallCover = CGAffineTransformMakeTranslation(-(self.backgroundView.frame.size.width/2-33.25),-(self.backgroundView.frame.size.height/2-33.25));
				self.musicCoverView.transform = CGAffineTransformConcat(scaleTrans, smallCover);
			} completion:nil];
		});
    } else {
		dispatch_async(dispatch_get_main_queue(), ^{
			[UIView animateWithDuration:0.20 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
				self.musicCoverView.transform = CGAffineTransformIdentity;
			} completion:nil];
		});
	}
}

-(void)removeFromSystemWide{
	if (self.wantsHomeScreen){
		[self addMicroplayerToHomeScreenAsGrabber:self.wantsGrabber];
	}else{
		[containerView removeFromSuperview];
		self.mode=MPHidden;
	}
}

-(void)toggleMicroPlayer{
	if (self.mode==MPHomeScreen||self.mode==MPHidden){
		[self addToSystemWideAsGrabber:NO];
	} else{
		[self removeFromSystemWide];
	}
}
///Subclass Overides

- (void)songUpdateWithName:(NSString*)songName artist:(NSString*)artistName artwork:(UIImage*)artworkImage colorScheme:(NSArray*)colorScheme{
	[super songUpdateWithName:songName artist:artistName artwork:artworkImage colorScheme:colorScheme];
	[self danceForSong:songName];
	UIColor* dominantColor1=[colorScheme firstObject];
	UIColor* dominantColor2=[colorScheme objectAtIndex:1];

    dispatch_async(dispatch_get_main_queue(), ^{
		[UIView transitionWithView:self.musicCoverView duration:0.4 options:UIViewAnimationOptionTransitionCrossDissolve animations:^{
			self.songTitle.text=songName;
			self.artistName.text=artistName;
			self.musicCoverView.image = artworkImage;
	
			/// update colours based on albums artwork
			progressView.progressTintColor = dominantColor2;
			self.microPlayerView.layer.borderColor = dominantColor1.CGColor;
			self.songTitle.textColor=dominantColor2;
			self.artistName.textColor=dominantColor2;
			self.backgroundView.layer.borderColor = dominantColor2.CGColor;
			self.backgroundView.backgroundColor = dominantColor1;
			self.musicCoverView.layer.borderColor = dominantColor1.CGColor;
			self.currentPlaybackLabel.textColor=dominantColor2;
			self.durationLabel.textColor=dominantColor2;
			[self.volumeSlider updateThumbColor:dominantColor2];
		} completion:nil];
    });
}

-(void)updateSongLength:(NSString*)songLength elapsedTime:(NSString*)elapsedTime elapsedPercentage:(double)elapsedPercentage{
	[super updateSongLength:songLength elapsedTime:elapsedTime elapsedPercentage:elapsedPercentage];
	self.currentPlaybackLabel.text=elapsedTime;
	self.durationLabel.text=songLength;
	progressView.progress =elapsedPercentage;
}

///App Stuff
- (void)showOrHideApp:(UIGestureRecognizer *)sender {
	if (sender.state == UIGestureRecognizerStateBegan) {
		if (!self.nowPlayingApp.processState.isRunning) {
			[[KBAppManager sharedInstance] openApp:self.nowPlayingApp suspended:FALSE];
		} else {
			[self toggleApp];
		}
	}
}

- (void)toggleApp {
	if (!self.isDisplayingApp) {
		[self showGrabber:YES];
		[self showApp];
	} else {
		/// App needs hiding
		[self showGrabber:self.wantsGrabber];
		[self hideApp];
	}
}

-(void)layoutAppView{
	float scale=(containerView.bounds.size.height/self.hostView.bounds.size.height)*0.9;
	self.hostView.transform = CGAffineTransformMakeScale(scale, scale);
	self.hostView.center = CGPointMake(containerView.frame.size.width / 2, containerView.frame.size.height / 2);	
	
}

-(void)showApp{
	/// allow app background use
	[[KBAppManager sharedInstance] setApp:self.nowPlayingApp backgrounded:FALSE];
	
	/// Setup/open App Display
	self.sceneHostManager = [[self.nowPlayingApp mainScene] hostManager];
	self.hostView = [self.sceneHostManager hostViewForRequester:@"com.kaneb.microplayer" enableAndOrderFront:true];
	self.hostView.layer.cornerRadius = 18.0f;
	self.hostView.clipsToBounds = YES;
	self.hostView.backgroundColor = UIColor.clearColor;
	self.hostView.userInteractionEnabled = NO;
	self.hostView.center = self.microPlayerView.center;
	self.hostView.transform = CGAffineTransformMakeScale(0.1, 0.1);
	[self layoutAppView];
	[UIView animateWithDuration:0.60 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
		[containerView addSubview:self.hostView];
		[containerView bringSubviewToFront:self.microPlayerView];
		self.hostView.hostContainerView.transform = CGAffineTransformMakeScale(1, 1);
	} completion:nil];
	
	self.isDisplayingApp = YES;
	
	
}

- (void)hideApp {
	[UIView animateWithDuration:0.60 delay:0 options:UIViewAnimationOptionCurveLinear animations:^{
		self.hostView.transform = CGAffineTransformMakeScale(1, 1);
		self.hostView.layer.cornerRadius = 0;
		self.hostView.clipsToBounds = NO;
		self.hostView.center = self.hostView.superview.center;
	} completion:nil];
	
	[self.sceneHostManager disableHostingForRequester:@"com.kaneb.microplayer"];
	
	if ([[KBAppManager sharedInstance] currentApp] == self.nowPlayingApp) {
		[[KBAppManager sharedInstance] setApp:self.nowPlayingApp backgrounded:FALSE];
	} else {
		[[KBAppManager sharedInstance] setApp:self.nowPlayingApp backgrounded:TRUE];
	}
	self.isDisplayingApp = NO;
}

/// Gesture Delegate

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
	if ([gestureRecognizer isKindOfClass:[KBForceTouchGestureRecognizer class]]||[otherGestureRecognizer isKindOfClass:[KBForceTouchGestureRecognizer class]]){
		return NO;
	}
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
	return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
	if ((([gestureRecognizer.view isDescendantOfView:gestureRecognizer.view.superview]) && ![otherGestureRecognizer.view isDescendantOfView:gestureRecognizer.view])) {
		return YES;
	} else {
		return NO;
	}
}
@end
