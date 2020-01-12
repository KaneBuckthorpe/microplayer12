#import "MPBaseView.h"

@implementation MPBaseView
- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    self.clipsToBounds = NO;
    self.backgroundColor = UIColor.clearColor;

    return self;
}

- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event {
    for (UIView *subview in self.subviews) {
        if ([subview hitTest:[self convertPoint:point toView:subview] withEvent:event] != nil) {
            return YES;
        }
    }
    return NO;
}
@end