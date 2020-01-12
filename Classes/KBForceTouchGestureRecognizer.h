#import <UIKit/UIKit.h>

@interface KBForceTouchGestureRecognizer : UIGestureRecognizer
@property (nonatomic) NSUInteger  numberOfTouchesRequired;    // Default is 1. The number of fingers required to match
@property (nonatomic, readonly) CGFloat currentForce;

@end

@interface _UILinearForceLevelClassifier :NSObject
-(double)standardThreshold;
@end