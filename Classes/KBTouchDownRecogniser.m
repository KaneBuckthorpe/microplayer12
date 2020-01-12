#import "KBTouchDownRecogniser.h"
#import <UIKit/UIGestureRecognizerSubclass.h>

@implementation KBTouchDownRecogniser
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
 [super touchesBegan:touches withEvent:event]; 
self.strokePrecision = 10.0;
      
    if (touches.count > 1) {
      self.state = UIGestureRecognizerStateFailed; 
}else{
   
   self.firstTap = [touches.anyObject locationInView:  self.view.superview]; //C
self.state = UIGestureRecognizerStateBegan;
}
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
   [super touchesMoved:touches withEvent:event];   

   if (self.state ==UIGestureRecognizerStateBegan) {    //B 
  
CGRect bounds= self.view.bounds;
bounds.origin.x-=10;
bounds.size.width+=20;
if (CGRectContainsPoint(bounds, [touches.anyObject locationInView:self.view])){
self.state = UIGestureRecognizerStateChanged;  
}else{
self.state = UIGestureRecognizerStateEnded;
}
}
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
 [super touchesEnded:touches withEvent:event]; 
//if (self.state == UIGestureRecognizerStateChanged|| self.state == UIGestureRecognizerStateBegan){
self.state =UIGestureRecognizerStateEnded;
//}
}
-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
 [super touchesCancelled:touches withEvent:event]; 
self.state =UIGestureRecognizerStateCancelled;
}
-(void)reset{
[super reset];
}

@end