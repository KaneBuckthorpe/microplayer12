#import <UIKit/UIKit.h>

@interface KBTouchDownRecogniser : UIGestureRecognizer
   @property (nonatomic) NSUInteger strokePrecision;
   @property (nonatomic) CGPoint firstTap;
@end