#import "PIWindow.h"

@implementation PIWindow
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
        self.clipsToBounds = YES;
        self.backgroundColor = UIColor.clearColor;
self.layer.masksToBounds=YES;
self.windowLevel = 1070;
self.alpha= 1;
self.opaque=NO;
    return self;
}
- (bool)_shouldCreateContextAsSecure{
        return YES;
}
-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
    for (UIView* subview in self.subviews ) {
        if ( [subview hitTest:[self convertPoint:point toView:subview] withEvent:event] != nil ) {
            return YES;
        }
    }
    return NO;
}
@end
