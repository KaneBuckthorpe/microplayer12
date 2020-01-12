#import <SpringBoard/SBRootFolderView.h>
#import <SpringBoard/SBRootFolderController.h>
#import <SpringBoard/SBIconController.h>

#import <FrontBoard/FBSceneHostWrapperView.h>
#import <SpringBoard/SBApplicationController.h>
#import <FrontBoard/FBSceneHostManager.h>

@interface FBSceneLayerHostContainerView:UIView 
@end

@interface FBSceneHostWrapperView()
@property (nonatomic,retain) FBSceneLayerHostContainerView * hostContainerView;   
@end

@interface SBIconScrollView:UIScrollView
@end
