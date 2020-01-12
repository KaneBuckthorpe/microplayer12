#import <objc/runtime.h>
#import <SpringBoard/SBHUDController.h>
#import "KBTouchDownRecogniser.h"
#import "KBVolumeAnimation.h"

@interface KBVolumeSlider:UISlider
@property (nonatomic, retain) KBTouchDownRecogniser *sliderRecognizer;
@property (nonatomic, retain) UIColor * thumbColor;
@property (nonatomic, retain) UIImageView * thumbImageView;
@property (nonatomic, assign) BOOL isChangingVolume;
-(void)slideImage;
-(void)updateValueAnimated;
-(void)updateThumbColor:(UIColor*)color;
@end


@interface AVSystemController : NSObject
-(BOOL)getVolume:(float*)arg1 forCategory:(id)arg2 ;
-(BOOL)setVolumeTo:(float)arg1 forCategory:(id)arg2;
+(id)sharedAVSystemController;
@end

@interface VolumeControl : NSObject
+ (id)sharedVolumeControl;
- (void)addAlwaysHiddenCategory:(id)arg1;
- (void)removeAlwaysHiddenCategory:(id)arg1;
@end





