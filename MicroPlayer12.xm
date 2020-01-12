#import "MicroPlayer12.h"

%hook SBIconController
MPViewController*microPlayerViewController;
-(void)_performInitialLayoutWithOrientation:(long long)arg1{
	%orig;
	microPlayerViewController=[[MPViewController alloc] initWithHomeScreenView:self._rootFolderController.contentView.scrollView];
}
%end

%hook SBIconScrollView
-(void)layoutSubviews{
%orig;
	if ( UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad ){
		[microPlayerViewController viewWillLayoutSubviews];
	}
}
%end

%hook SpringBoard
-(void) applicationDidFinishLaunching:(id) application {
    %orig;
    int iOSVersion;
    if(kCFCoreFoundationVersionNumber>=1443.00){
        iOSVersion=11;
    } else{
        iOSVersion=10;
    }

    if (iOSVersion==10){
SBIconScrollView*homeView=[[objc_getClass("SBIconController") sharedInstance] _rootFolderController].contentView.scrollView;
        microPlayerViewController=[[MPViewController alloc] initWithHomeScreenView:homeView];
    }
}
- (void)frontDisplayDidChange:(id)newDisplay {
	%orig;
	if(microPlayerViewController.mode==MPSystemWide){
		if(newDisplay == nil&&[[self valueForKey:@"_atHomescreen"]boolValue]&&microPlayerViewController.wantsHomeScreen){
			[microPlayerViewController removeFromSystemWide];
        }else{
			[microPlayerViewController viewWillLayoutSubviews];
        }
    }
    
}
%end

///handle activator events

@implementation MPLAListener
	
static NSString *showMicroPlayerName = @"com.microplayer12.show";

static NSString *hideMicroPlayerName = @"com.microplayer12.hide";

static NSString *toggleMicroPlayerName = @"com.microplayer12.toggleshowing";

static NSString *showMicroPlayerGrabberName = @"com.microplayer12.show-grabber";

static NSString *groupName = @"MicroPlayer12";

static 	NSBundle *tweakPrefBundle = [NSBundle bundleWithPath:@"/Library/PreferenceBundles/MicroPlayer12Prefs.bundle"];

- (void)activator:(LAActivator *)activator receiveEvent:(LAEvent *)event forListenerName:(NSString *)listenerName{
	if ([listenerName isEqualToString:showMicroPlayerName]){
		NSLog(@"1"); 
		[microPlayerViewController addToSystemWideAsGrabber:NO];
	} else if ([listenerName isEqualToString:hideMicroPlayerName]){
		NSLog(@"2"); 
		[microPlayerViewController removeFromSystemWide];
	} else if ([listenerName isEqualToString:toggleMicroPlayerName]){
		NSLog(@"3");
		[microPlayerViewController toggleMicroPlayer];
	} else if ([listenerName isEqualToString:showMicroPlayerGrabberName]){
		NSLog(@"4");
		[microPlayerViewController addToSystemWideAsGrabber:YES];
	}
	[event setHandled:YES];
}

+(void)load {

	    LAActivator *activator= [%c(LAActivator) sharedInstance]; 

	[activator registerListener:[self new] forName:showMicroPlayerName];

	[activator registerListener:[self new] forName:showMicroPlayerGrabberName];

	[activator registerListener:[self new] forName:hideMicroPlayerName];

	[activator registerListener:[self new] forName:toggleMicroPlayerName];

}

- (NSArray *)exclusiveAssignmentGroupsForListenerName:(NSString *)listenerName{
		NSArray *groups = @[groupName];
	return groups;
}

- (NSString *)activator:(LAActivator *)activator requiresLocalizedGroupForListenerName:(NSString *)listenerName{
	return groupName;
}

- (NSString *)activator:(LAActivator *)activator requiresLocalizedTitleForListenerName:(NSString *)listenerName{
	if ([listenerName isEqualToString:showMicroPlayerName]){
		return @"Show MicroPlayer";
	}else if ([listenerName isEqualToString:hideMicroPlayerName]){
		return @"Hide MicroPlayer";
	} else if ([listenerName isEqualToString:toggleMicroPlayerName]){
		return @"Toggle MicroPlayer";
	} else if ([listenerName isEqualToString:showMicroPlayerGrabberName]){
		return @"Show MicroPlayer grabber";
	}else{
	return @"MicroPlayer12 Error";
	}
}

- (NSString *)activator:(LAActivator *)activator requiresLocalizedDescriptionForListenerName:(NSString *)listenerName{
    
	if ([listenerName isEqualToString:showMicroPlayerName]){
		return @"Displays MicroPlayer as full player";
	}else if ([listenerName isEqualToString:hideMicroPlayerName]){
		return @"Hides MicroPlayer";
	} else if ([listenerName isEqualToString:toggleMicroPlayerName]){
		return @"Toggles MicroPlayer";
	} else if ([listenerName isEqualToString:showMicroPlayerGrabberName]){
		return @"Displays MicroPlayer as the grabber";
	} else {
	return @"MicroPlayer12 Error";
	}
}

- (NSArray *)activator:(LAActivator *)activator requiresCompatibleEventModesForListenerWithName:(NSString *)listenerName{
	return @[@"springboard", @"application", @"lockscreen"];
}

- (UIImage *)activator:(LAActivator *)activator requiresIconForListenerName:(NSString *)listenerName scale:(CGFloat)scale{	
	return [UIImage imageNamed:@"icon" inBundle:tweakPrefBundle compatibleWithTraitCollection:nil];
}

- (UIImage *)activator:(LAActivator *)activator requiresSmallIconForListenerName:(NSString *)listenerName scale:(CGFloat)scale{
	return [UIImage imageNamed:@"icon" inBundle:tweakPrefBundle compatibleWithTraitCollection:nil];	
	
}
@end
