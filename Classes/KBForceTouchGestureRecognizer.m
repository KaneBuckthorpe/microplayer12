//
//  PSForceTouchGestureRecognizer.h
//  Copyright © 2015 Paraset LLC. All rights reserved.
//

#import "KBForceTouchGestureRecognizer.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@interface KBForceTouchGestureRecognizer ()

@property (nonatomic, readwrite) CGFloat currentForce;
@end

@implementation KBForceTouchGestureRecognizer{
_UILinearForceLevelClassifier *_forceSpecs;
CGFloat _minimumForce;
}

- (id)initWithTarget:(id)target action:(SEL)action {
	if (self = [super initWithTarget:target action:action]) {
		self.numberOfTouchesRequired = 1.0;
		_forceSpecs= [_UILinearForceLevelClassifier new];
	}
	return self;
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
	[super touchesBegan:touches withEvent:event];
	[self handleForceWithTouches:touches];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
	[super touchesMoved:touches withEvent:event];
	[self handleForceWithTouches:touches];
}

- (void)touchesEnded:(NSSet*)touches withEvent:(UIEvent *)event {
	[super touchesEnded:touches withEvent:event];
	[super setState:UIGestureRecognizerStateEnded];
	[self handleForceWithTouches:touches];
}

-(void)handleForceWithTouches:(NSSet<UITouch *> *)touches{
	if(touches.count!=self.numberOfTouchesRequired){
	    [super setState:UIGestureRecognizerStateFailed];
	}
	_minimumForce = _forceSpecs.standardThreshold;
	UITouch *t=touches.anyObject;
	CGFloat force = t.force;
	self.currentForce=force;
	if(self.currentForce >= _minimumForce) {
		if (super.state==UIGestureRecognizerStateBegan){
			[super setState:UIGestureRecognizerStateChanged];
		} 
		if (super.state!=UIGestureRecognizerStateChanged){
			[super setState:UIGestureRecognizerStateBegan];
		}
	}
}
@end
