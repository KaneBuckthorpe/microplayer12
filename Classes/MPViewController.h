#import "MPInterfaces.h"
#import "KBMediaViewController.h"
#include "PIWindow.h"
#import "PIUIImageView.h"
#import "ScrollyLabel.h"
#import "KBTouchDownRecogniser.h"
#import "KBForceTouchGestureRecognizer.h"
#import <notify.h>
#import <SpringBoard/SpringBoard.h> 

typedef NS_ENUM(NSInteger, MPMode) {
	MPHidden,
	MPHomeScreen,
	MPSystemWide,
};



@interface MPViewController :KBMediaViewController<UIGestureRecognizerDelegate>
@property (nonatomic, retain) UISwipeGestureRecognizer*upSwipe;
@property (nonatomic, retain) UISwipeGestureRecognizer*downSwipe;
@property (nonatomic, retain) UISwipeGestureRecognizer*leftSwipe;
@property (nonatomic, retain) UISwipeGestureRecognizer*rightSwipe;
@property (nonatomic, retain) UIPinchGestureRecognizer*twoFingerPinch;

@property (nonatomic, assign) BOOL playerWantsOpening;
@property (nonatomic, assign) MPMode mode;
@property (nonatomic, assign) BOOL isDisplayingApp;
@property (nonatomic, assign) BOOL isGrabber;
@property (nonatomic, assign) BOOL wantsGrabber;
@property (nonatomic, assign) BOOL wantsHomeScreen;

@property (strong, retain) UIView* microPlayerView;
@property (nonatomic, retain) UIView *backgroundView;
@property (nonatomic, retain) ScrollyLabel*artistName;
@property (nonatomic, retain) ScrollyLabel*songTitle;
@property (nonatomic, retain) PIUIImageView*musicCoverView;

@property (nonatomic, retain) UILabel *currentPlaybackLabel;
@property (nonatomic, retain) UILabel *durationLabel;
@property (nonatomic, retain) PIWindow*window;
@property (nonatomic, retain) SBIconScrollView*homeScreenView;
@property (nonatomic, retain) UIColor*backgroundColor;
@property (nonatomic, retain) FBSceneHostManager *sceneHostManager;
@property (nonatomic, retain) FBSceneHostWrapperView *hostView;
-(id)initWithHomeScreenView:(SBIconScrollView*)homeScreenView;
-(void)addToSystemWideAsGrabber:(BOOL)grabber;
-(void)toggleMicroPlayer;
-(void)toggleApp;
-(void)hideApp;
-(void)removeFromSystemWide;
-(void)layoutWindow;
@end