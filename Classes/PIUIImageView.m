#import "PIUIImageView.h"

@implementation PIUIImageView
- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];

    return self;
}

-(BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
            return YES;
}
@end
