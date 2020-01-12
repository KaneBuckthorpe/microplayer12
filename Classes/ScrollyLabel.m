#import "ScrollyLabel.h"
#import <QuartzCore/QuartzCore.h>


#define kLabelCount 2
#define kDefaultFadeLength 7.0f
#define kDefaultLabelBufferSpace 20
#define kDefaultPixelsPerSecond 30
#define kDefaultPauseTime 1.5f

static void each_object(NSArray *objects, void(^block)(id object)) {
    for (id obj in objects) {
        block(obj);
    }
}

#define EACH_LABEL(ATTR, VALUE) each_object(self.labels, ^(UILabel *label) { label.ATTR = VALUE; });

@interface ScrollyLabel ()
@property (nonatomic, strong) NSArray *labels;
@property (nonatomic, strong, readonly) UILabel *mainLabel;
@property (nonatomic, strong) UIScrollView *scrollView;
@end

@implementation ScrollyLabel
-(id)initWithCoder:(NSCoder *)aDecoder {
  if((self = [super initWithCoder:aDecoder])) {
        [self commonInit];
    }
    return self;
}

-(id)initWithFrame:(CGRect)frame {
  if((self = [super initWithFrame:frame])) {
        [self commonInit];
    }
    return self;
}

-(void)commonInit {
  NSMutableSet *labelSet = [[NSMutableSet alloc] initWithCapacity:kLabelCount];

for(int index = 0; index < kLabelCount; ++index) {
   UILabel *label = [[UILabel alloc] init];
   label.backgroundColor=UIColor.clearColor;
   label.autoresizingMask=self.autoresizingMask;

   [self.scrollView addSubview:label];
   [labelSet addObject:label];
}
    self.labels = [labelSet.allObjects copy];

    _scrollDirection = ScrollyLabelDirectionLeft;
    _scrollSpeed = kDefaultPixelsPerSecond;
    self.pauseInterval = kDefaultPauseTime;
    self.labelSpacing = kDefaultLabelBufferSpace;
    self.textAlignment = NSTextAlignmentLeft;
    self.animationOptions = UIViewAnimationOptionCurveLinear;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.scrollEnabled = NO;
    self.userInteractionEnabled = NO;
    self.backgroundColor = [UIColor clearColor];
    self.clipsToBounds = YES;
    self.fadeLength = kDefaultFadeLength;
}


-(void)setFrame:(CGRect)frame {
     [super setFrame:frame];
     [self didChangeFrame];
}

-(void)setBounds:(CGRect)bounds {
     [super setBounds:bounds];
     [self didChangeFrame];
}

- (void)didMoveToWindow {
      [super didMoveToWindow];

 if(self.window) {
      [self scrollLabelIfNeeded];
  }
}


#pragma mark - Properties
- (UIScrollView *)scrollView {
    if (_scrollView == nil) {
        _scrollView = [[UIScrollView alloc] initWithFrame:self.bounds];
        _scrollView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        _scrollView.backgroundColor = [UIColor clearColor];

        [self addSubview:_scrollView];
    }
    return _scrollView;
}

- (void)setFadeLength:(CGFloat)fadeLength {
    if (_fadeLength != fadeLength) {
        _fadeLength = fadeLength;

        [self refreshLabels];
        [self applyGradientMaskForFadeLength:fadeLength enableFade:NO];
    }
}

- (UILabel *)mainLabel {
    return self.labels[0];
}

- (void)setText:(NSString *)theText {
    [self setText:theText refreshLabels:YES];
}

- (void)setText:(NSString *)theText refreshLabels:(BOOL)refresh {
    if ([theText isEqualToString:self.text])
        return;

    EACH_LABEL(text, theText)

    if (refresh)
        [self refreshLabels];
}

- (NSString *)text {
    return self.mainLabel.text;
}

- (void)setAttributedText:(NSAttributedString *)theText {
    [self setAttributedText:theText refreshLabels:YES];
}

- (void)setAttributedText:(NSAttributedString *)theText refreshLabels:(BOOL)refresh {
    if ([theText.string isEqualToString:self.attributedText.string])
        return;

    EACH_LABEL(attributedText, theText)

    if (refresh)
        [self refreshLabels];
}

- (NSAttributedString *)attributedText {
    return self.mainLabel.attributedText;
}

- (void)setTextColor:(UIColor *)color {
    EACH_LABEL(textColor, color)
}

- (UIColor *)textColor {
    return self.mainLabel.textColor;
}

- (void)setFont:(UIFont *)font {
    if (self.mainLabel.font == font)
        return;

    EACH_LABEL(font, font)

    [self refreshLabels];
    [self invalidateIntrinsicContentSize];
}

- (UIFont *)font {
    return self.mainLabel.font;
}

- (void)setScrollSpeed:(float)speed {
    _scrollSpeed = speed;

    [self scrollLabelIfNeeded];
}

- (void)setScrollDirection:(ScrollyLabelDirection)direction {
    _scrollDirection = direction;

    [self scrollLabelIfNeeded];
}

- (void)setShadowColor:(UIColor *)color {
    EACH_LABEL(shadowColor, color)
}

- (UIColor *)shadowColor {
    return self.mainLabel.shadowColor;
}

- (void)setShadowOffset:(CGSize)offset {
    EACH_LABEL(shadowOffset, offset)
}

- (CGSize)shadowOffset {
    return self.mainLabel.shadowOffset;
}

#pragma mark - Autolayout

- (CGSize)intrinsicContentSize {
    return CGSizeMake(0, [self.mainLabel intrinsicContentSize].height);
}

#pragma mark - Misc

- (void)observeApplicationNotifications {
    [[NSNotificationCenter defaultCenter] removeObserver:self];

    // restart scrolling when the app has been activated
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(scrollLabelIfNeeded)
                                                 name:UIApplicationWillEnterForegroundNotification
                                               object:nil];

    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(scrollLabelIfNeeded)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];

#ifndef TARGET_OS_TV
    // refresh labels when interface orientation is changed
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(onUIApplicationDidChangeStatusBarOrientationNotification:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
#endif

}

- (void)enableShadow {
    _scrolling = YES;
    [self applyGradientMaskForFadeLength:self.fadeLength enableFade:YES];
}

- (void)scrollLabelIfNeeded {
    if (!self.text.length)
        return;

    CGFloat labelWidth = CGRectGetWidth(self.mainLabel.bounds);
    if (labelWidth <= CGRectGetWidth(self.bounds))
        return;

    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(scrollLabelIfNeeded) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(enableShadow) object:nil];

    [self.scrollView.layer removeAllAnimations];

    BOOL doScrollLeft = (self.scrollDirection == ScrollyLabelDirectionLeft);
    self.scrollView.contentOffset = (doScrollLeft ? CGPointZero : CGPointMake(labelWidth + self.labelSpacing, 0));

    [self performSelector:@selector(enableShadow) withObject:nil afterDelay:self.pauseInterval];

    NSTimeInterval duration = labelWidth / self.scrollSpeed;
    [UIView animateWithDuration:duration delay:self.pauseInterval options:self.animationOptions | UIViewAnimationOptionAllowUserInteraction animations:^{
         self.scrollView.contentOffset = (doScrollLeft ? CGPointMake(labelWidth + self.labelSpacing, 0) : CGPointZero);
     } completion:^(BOOL finished) {
         _scrolling = NO;

         [self applyGradientMaskForFadeLength:self.fadeLength enableFade:NO];

         if (finished) {
             [self performSelector:@selector(scrollLabelIfNeeded) withObject:nil];
         }
     }];
}

- (void)refreshLabels {
    __block float offset = 0;

    each_object(self.labels, ^(UILabel *label) {
        [label sizeToFit];

        CGRect frame = label.frame;
        frame.origin = CGPointMake(offset, 0);
        frame.size.height = CGRectGetHeight(self.bounds);
        label.frame = frame;

        label.center = CGPointMake(label.center.x, roundf(self.center.y - CGRectGetMinY(self.frame)));

        offset += CGRectGetWidth(label.bounds) + self.labelSpacing;
    });

    self.scrollView.contentOffset = CGPointZero;
    [self.scrollView.layer removeAllAnimations];

    if (CGRectGetWidth(self.mainLabel.bounds) > CGRectGetWidth(self.bounds)) {
        CGSize size;
        size.width = CGRectGetWidth(self.mainLabel.bounds) + CGRectGetWidth(self.bounds) + self.labelSpacing;
        size.height = CGRectGetHeight(self.bounds);
        self.scrollView.contentSize = size;

        EACH_LABEL(hidden, NO)

        [self applyGradientMaskForFadeLength:self.fadeLength enableFade:self.scrolling];

        [self scrollLabelIfNeeded];
    } else {
        EACH_LABEL(hidden, (self.mainLabel != label))

        self.scrollView.contentSize = self.bounds.size;
        self.mainLabel.frame = self.bounds;
        self.mainLabel.hidden = NO;
        self.mainLabel.textAlignment = self.textAlignment;

        [self.scrollView.layer removeAllAnimations];

        [self applyGradientMaskForFadeLength:0 enableFade:NO];
    }
}

- (void)didChangeFrame {
    [self refreshLabels];
    [self applyGradientMaskForFadeLength:self.fadeLength enableFade:self.scrolling];
}

#pragma mark - Gradient
- (void)applyGradientMaskForFadeLength:(CGFloat)fadeLength enableFade:(BOOL)fade {
    CGFloat labelWidth = CGRectGetWidth(self.mainLabel.bounds);

    if (labelWidth <= CGRectGetWidth(self.bounds))
        fadeLength = 0;

    if (fadeLength) {
        CAGradientLayer *gradientMask = [CAGradientLayer layer];

        gradientMask.bounds = self.layer.bounds;
        gradientMask.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));

        gradientMask.shouldRasterize = YES;
        gradientMask.rasterizationScale = [UIScreen mainScreen].scale;

        gradientMask.startPoint = CGPointMake(0, CGRectGetMidY(self.frame));
        gradientMask.endPoint = CGPointMake(1, CGRectGetMidY(self.frame));

        id transparent = (id)[UIColor clearColor].CGColor;
        id opaque = (id)[UIColor blackColor].CGColor;
        gradientMask.colors = @[transparent, opaque, opaque, transparent];

        CGFloat fadePoint = fadeLength / CGRectGetWidth(self.bounds);
        NSNumber *leftFadePoint = @(fadePoint);
        NSNumber *rightFadePoint = @(1 - fadePoint);
        if (!fade) switch (self.scrollDirection) {
                case ScrollyLabelDirectionLeft:
                    leftFadePoint = @0;
                    break;

                case ScrollyLabelDirectionRight:
                    leftFadePoint = @0;
                    rightFadePoint = @1;
                    break;
            }

        gradientMask.locations = @[@0, leftFadePoint, rightFadePoint, @1];

        [CATransaction begin];
        [CATransaction setDisableActions:YES];
        self.layer.mask = gradientMask;
        [CATransaction commit];
    } else {
        self.layer.mask = nil;
    }
}

#pragma mark - Notifications
- (void)onUIApplicationDidChangeStatusBarOrientationNotification:(NSNotification *)notification {
    [self performSelector:@selector(refreshLabels) withObject:nil afterDelay:.1f];
    [self performSelector:@selector(scrollLabelIfNeeded) withObject:nil afterDelay:.1f];
}

@end
