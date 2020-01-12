#import "MPBaseView.h"
#import "KBVolumeSlider.h"
#import <MediaPlayer/MediaPlayer.h>
#import <SpringBoard/SBMediaController.h>
#import <MediaRemote/MediaRemote.h>
#import "NSString+TimeToString.h"
#import "KBAppManager.h"

@interface KBMediaViewController:UIViewController
@property  (nonatomic, retain)KBVolumeSlider* volumeSlider;
@property (nonatomic, retain) SBApplication *nowPlayingApp;
@property (nonatomic, retain) NSString *defaultApp;

-(NSString*)defaultSongName;
-(NSString*)defaultAlbumName;
-(UIImage*)defaultAlbumImage;
-(void)songUpdateWithName:(NSString*)songName artist:(NSString*)artistName artwork:(UIImage*)artworkImage colorScheme:(NSArray*)colorScheme;
-(void)updateSongLength:(NSString*)songLength elapsedTime:(NSString*)elapsedTime elapsedPercentage:(double)elapsedPercentage;
-(void)next;
-(void)previous;
-(void)playOrPause;
-(void)reload;
@end






