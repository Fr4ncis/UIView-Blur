//
//  UIView+Blur.m
//  UIViewBlurDemo
//
//  Created by Francesco Mattia on 11/03/2014.
//  Copyright (c) 2014 Francesco Mattia. All rights reserved.
//

#import "UIView+Blur.h"
#import <objc/runtime.h>
#import <QuartzCore/QuartzCore.h>
#import "UIImage+ImageEffects.h"
#define maxBlurRadius 20.0f
#define steps 10

//@interface MyCAAction : CABasicAnimation
//
//@end
//
//@implementation MyCAAction
//
//+ (instancetype)sharedInstance {
//    static MyCAAction *_sharedInstance = nil;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        _sharedInstance = [MyCAAction new];
//    });
//    
//    return _sharedInstance;
//}
//
//- (void)runActionForKey:(NSString *)event object:(id)anObject arguments:(NSDictionary *)dict
//{
//    CABlurLayer *layer = (CABlurLayer*)anObject;
//    [anObject addAnimation:self forKey:@"blur"];
//    NSLog(@"runActionForkey: %@ <%@> (an: %.1f) d: %@", event, anObject, layer.blur, dict);
//}
//
//@end

@interface CABlurLayer () {
    NSArray *blurredSnapshots;
}

@end

@implementation CABlurLayer
@dynamic blur;

- (void)updateSnapshots
{
    [self setOpacity:0];
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);
    [[self superlayer] renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    [self setOpacity:1];
    NSMutableArray *array = [NSMutableArray new];
    for (int i = 0; i <= steps; i++)
    {
        UIImage *blurImage = [snapshot applyBlurWithRadius:5*(i*1/(float)steps) tintColor:[UIColor clearColor] saturationDeltaFactor:1 maskImage:nil];
        [array addObject:blurImage];
    }
    blurredSnapshots = array;
}

//- (void)setBlur:(float)aBlur
//{
//    blur = aBlur;
//    [self setNeedsDisplay];
//}

- (id)initWithLayer:(id)layer {
	if ((self = [super initWithLayer:layer])) {
		self.blur = 0;
	}
	return self;
}

+ (BOOL)needsDisplayForKey:(NSString *) key {
    if ([key isEqualToString:@"blur"])
    {
        return YES;
    }
    return [super needsDisplayForKey:key];
}

- (void)drawInContext:(CGContextRef)ctx
{
    [super drawInContext:ctx];
    NSLog(@"drawInContext blur: %.1f", self.blur);
    if (!blurredSnapshots) [self updateSnapshots];
    int index = floorf(self.blur*steps);
    UIImage *blurImage = blurredSnapshots[index];
    UIGraphicsPushContext(ctx);
    //CGContextDrawImage(ctx, self.bounds, blurImage.CGImage);
    [blurImage drawAtPoint:CGPointZero];
    UIGraphicsPopContext();

}

- (id<CAAction>)actionForKey:(NSString *)event
{
    if ([event isEqualToString:@"blur"])
    {
        NSLog(@"actionForKey: %@", event);
        CABasicAnimation *anim = [CABasicAnimation animation];
        //[anim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
        //[anim setFillMode:kCAFillModeForwards];
        //[anim setFromValue:[NSValue valueWithCGPoint:CGPointMake(0, 0)]];
        [anim setRemovedOnCompletion:NO];
        [anim setKeyPath:@"blur"];
        return anim;
    }
    return [super actionForKey:event];
}

//- (id<CAAction>)actionForLayer:(CALayer *)layer forKey:(NSString *)event
//{
//    NSLog(@"actionForLayer: %@ key: %@", layer, event);
//    if ([event isEqualToString:@"blur"])
//    {
//        return [super actionForKey:@"position"];
//    }
//    return nil;
//}

@end

@implementation UIBlurImageView
@synthesize blurredLayer;
@dynamic blur;

//- (CALayer*)blurredLayer
//{
//    return (CALayer *)objc_getAssociatedObject(self, &BLUR_LAYER);;
//}
//
//- (void)setBlurredLayer:(CALayer*)layer
//{
//    objc_setAssociatedObject(self, &BLUR_LAYER, layer, OBJC_ASSOCIATION_RETAIN);
//}

- (void)updateSnapshots
{
    [self.blurredLayer updateSnapshots];
}

- (void)setBlur:(float)blur
{
    NSLog(@"setBlur blur: %.1f", blur);
    
    if (!self.blurredLayer)
    {
        self.blurredLayer = [[CABlurLayer alloc] initWithLayer:nil];
        self.blurredLayer.bounds = self.bounds;
        self.blurredLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        [self.layer addSublayer:self.blurredLayer];
    }
    self.blurredLayer.blur = blur;
    
    
    // DISABLE Animation
    //[CATransaction begin];
    //[CATransaction setValue: (id) kCFBooleanTrue forKey: kCATransactionDisableActions];
    //[CATransaction commit];

}

@end
