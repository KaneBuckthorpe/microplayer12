#import "KBAppManager.h"

///////////////Open Source Reference Material
////https://github.com/eswick/appcenter/blob/master/Tweak.xm

@implementation KBAppManager
+ (id)sharedInstance{
    static KBAppManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[KBAppManager alloc] init];

    });
    return sharedInstance;
}
-(SBApplication *)appWithBundleID:(NSString *)bundleID{

SBApplication *application = [[objc_getClass("SBApplicationController") sharedInstance] applicationWithBundleIdentifier:bundleID];

 return application;
}

- (void)setApp:(SBApplication*)application backgrounded:(BOOL)backgrounded{

  FBSceneManager *sceneManager = [FBSceneManager sharedInstance];
  FBScene *scene = [sceneManager sceneWithIdentifier: application.bundleIdentifier];
scene.mutableSettings.backgrounded=backgrounded;

  id <FBSceneClientProvider> clientProvider = [scene clientProvider];
  id <FBSceneClient> client = [scene client];

  FBSSceneSettings *settings = [scene settings];
  FBSMutableSceneSettings *mutableSettings = [settings mutableCopy];

  mutableSettings.backgrounded=backgrounded;

  FBSSceneSettingsDiff *settingsDiff = [FBSSceneSettingsDiff diffFromSettings:settings toSettings:mutableSettings];

  [clientProvider beginTransaction];
  [client host:scene didUpdateSettings:mutableSettings withDiff:settingsDiff transitionContext:nil completion:nil];
  [clientProvider endTransaction];

}
-(void)openApp:(SBApplication*)application suspended:(BOOL)suspended{

if (suspended){

   [[FBSSystemService sharedService] openApplication:application.bundleIdentifier options:@{ FBSOpenApplicationOptionKeyActivateSuspended:@true } withResult:^{
}];

}else{

dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^(void){
[[objc_getClass ("LSApplicationWorkspace") defaultWorkspace] openApplicationWithBundleID:application.bundleIdentifier];
});

}
}
-(SBApplication *)currentApp{
SBApplication*currentApp = [(SpringBoard *)[objc_getClass("SpringBoard") sharedApplication] _accessibilityTopDisplay];
 return currentApp;
}
@end