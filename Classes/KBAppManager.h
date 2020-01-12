#import <objc/runtime.h>
#import <FrontBoardServices/FBSMutableSceneSettings.h>
#import <FrontBoard/FBSceneHostManager.h>
#import <FrontBoard/FBSceneManager.h>
#import <FrontBoard/FBSceneHostManager.h>
#import <FrontBoard/FBProcessState.h>
#import <FrontBoardServices/FBSSystemService.h>
#import <FrontBoard/FBSceneClientProvider.h>
#import <FrontBoard/FBScene.h>
#import <SpringBoard/SBApplication.h>
#import <SpringBoard/SBApplicationController.h>
#import <SpringBoard/SpringBoard.h> 

@interface KBAppManager :NSObject
+ (id)sharedInstance;

-(SBApplication *)appWithBundleID:(NSString *)bundleID;
- (void)setApp:(SBApplication*)application backgrounded:(BOOL)backgrounded;
-(void)openApp:(SBApplication*)application suspended:(BOOL)suspended;
-(SBApplication *)currentApp;
@end

@interface LSApplicationWorkspace : NSObject
 +(id)defaultWorkspace;
- (BOOL)openApplicationWithBundleID:(NSString *)bundleID;
@end

@interface FBScene()
@property (nonatomic,retain,readonly) FBSceneHostManager * hostManager;   
-(long long)currentInterfaceOrientation;
@end

@interface FBSSceneSettingsDiff : NSObject
+(id)diffFromSettings:(id)arg1 toSettings:(id)arg2 ;
@end

@interface SBApplication()
-(FBProcessState *)processState;
@end



