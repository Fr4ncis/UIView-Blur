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

static NSString* SNAPSHOT;

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
    
}

@end

@implementation CABlurLayer
@dynamic blur;

- (void)updateSnapshots
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);
    [[self superlayer] renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    NSMutableArray *array = [NSMutableArray new];
    for (int i = 0; i <= steps; i++)
    {
        UIImage *blurImage = [snapshot applyBlurWithRadius:5*(i*1/(float)steps) tintColor:[UIColor clearColor] saturationDeltaFactor:1 maskImage:nil];
        [array addObject:blurImage];
    }
    self.blurredSnapshots = array;
}

- (id)initWithLayer:(id)layer {
	if ((self = [super initWithLayer:layer])) {
        NSLog(@"initWithLayer (self: %@ copying: %@)", self, layer);
        if ([layer class] == [CABlurLayer class])
        {
            CABlurLayer *blurLayer = (CABlurLayer*)layer;
            self.blur = [blurLayer blur];
            self.blurredSnapshots = [blurLayer blurredSnapshots];
        }
        //self.drawsAsynchronously = YES;
	}
	return self;
}

+ (BOOL)needsDisplayForKey:(NSString *) key {
    if ([key isEqualToString:@"blur"]) return YES;
    return [super needsDisplayForKey:key];
}

- (void)drawLayer:(CALayer *)layer inContext:(CGContextRef)ctx
{
    NSLog(@"drawLayer:inContext:");
}

- (void)drawInContext:(CGContextRef)ctx
{
    NSLog(@"drawInContext: (p: %.1f) %.1f (%@) (m: %@) (p: %@)", [self.presentationLayer blur], self.blur, self, self.modelLayer, self.presentationLayer);
    int index = floorf([self.presentationLayer blur]*steps);
    UIImage *blurImage = self.blurredSnapshots[index];
    UIGraphicsPushContext(ctx);
    CGContextDrawImage(ctx, self.bounds, blurImage.CGImage);
    [blurImage drawAtPoint:CGPointZero];
    //CGContextSetLineWidth(ctx, 10);
    //CGContextSetStrokeColorWithColor(ctx, [UIColor yellowColor].CGColor);
    //CGContextMoveToPoint(ctx, 0, 0);
    //CGContextAddEllipseInRect(ctx, (CGRect){0,0,self.bounds.size.width*[self.presentationLayer blur], self.bounds.size.height*[self.presentationLayer blur]});
    //CGContextFillPath(ctx);
    UIGraphicsPopContext();
}

- (void)updateLayer
{
    int index = floorf(blur*steps);
    UIImage *blurImage = self.blurredSnapshots[index];
    self.contents = (id)blurImage.CGImage;
}

//- (id<CAAction>)actionForKey:(NSString *)event
//{
//    if ([event isEqualToString:@"blur"])
//    {
//        NSLog(@"an: %@", self.actions);
//        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"blur"];
//        [anim setFromValue:@([self.presentationLayer blur])];
//        [anim setDuration:1.0f];
//        [anim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
//        [anim setKeyPath:@"blur"];
//        return anim;
//    }
//    return [super actionForKey:event];
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

- (NSArray*)blurredSnapshots
{
    return (NSArray *)objc_getAssociatedObject(self, &SNAPSHOT);
}

- (void)setBlurredSnapshots:(NSArray*)array
{
    objc_setAssociatedObject(self, &SNAPSHOT, array, OBJC_ASSOCIATION_RETAIN);
}


- (void)updateSnapshots
{
    self.blurredLayer.opacity = 0;
    [self.blurredLayer updateSnapshots];
    self.blurredLayer.opacity = 1;
}

- (void)setBlur:(float)blur
{
    //NSLog(@"setBlur blur: %.1f", blur);
    
    if (!self.blurredLayer)
    {
        self.blurredLayer = [[CABlurLayer alloc] initWithLayer:nil];
        self.blurredLayer.bounds = self.bounds;
        self.blurredLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        [self.layer addSublayer:self.blurredLayer];
        if (![self blurredSnapshots]) [self updateSnapshots];
    }
    self.blurredLayer.blur = blur;
    
    
    // DISABLE Animation
    //[CATransaction begin];
    //[CATransaction setValue: (id) kCFBooleanTrue forKey: kCATransactionDisableActions];
    //[CATransaction commit];

}

@end
