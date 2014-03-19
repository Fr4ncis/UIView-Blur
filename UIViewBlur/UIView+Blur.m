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
#define steps 20
#define asyncBlur YES
#define implicitAnimationsDisabled NO

static NSString* BLUR_LAYER;

@interface CABlurLayer () {
    int currentImageIndex;
}

@end

@implementation CABlurLayer
@dynamic blur;

- (void)updateSnapshots
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);
    [[self superlayer] renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *snapshot = UIGraphicsGetImageFromCurrentImageContext();
    NSMutableArray *array;
    if (self.blurredSnapshots)
    {
        array = [self.blurredSnapshots mutableCopy];
    } else
    {
        array = [[NSMutableArray alloc] initWithCapacity:steps];
        for (int i = 0; i <= steps; i++)
        {
            [array addObject:snapshot];
        }
    }
    void (^blurBlock)() = ^void() {
        for (int i = 0; i <= steps; i++)
        {
            UIImage *blurImage = [snapshot applyBlurWithRadius:maxBlurRadius*(i*1/(float)steps) tintColor:[UIColor clearColor] saturationDeltaFactor:1 maskImage:nil];
            [array removeObjectAtIndex:i];
            [array insertObject:blurImage atIndex:i];
        }
    };
    self.blurredSnapshots = array;
    if (asyncBlur)
    {
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_LOW, 0), blurBlock);
    }
    else
    {
        blurBlock();
    }
}


- (id)initWithLayer:(id)layer {
	if ((self = [super initWithLayer:layer])) {
        //NSLog(@"initWithLayer (self: %@ copying: %@)", self, layer);
        if ([layer class] == [CABlurLayer class])
        {
            CABlurLayer *blurLayer = (CABlurLayer*)layer;
            self.blur = [blurLayer blur];
            currentImageIndex = [blurLayer getCurrentIndex];
            self.blurredSnapshots = [blurLayer blurredSnapshots];
        }
        self.drawsAsynchronously = YES;
	}
	return self;
}

+ (BOOL)needsDisplayForKey:(NSString *) key {
    if ([key isEqualToString:@"blur"]) return YES;
    return [super needsDisplayForKey:key];
}

- (int)getCurrentIndex
{
    return floorf(self.blur*steps);
}

- (void)drawInContext:(CGContextRef)ctx
{
    //NSLog(@"drawInContext: (p: %.1f) %.1f (%@) (m: %@) (p: %@)", [self.presentationLayer blur], self.blur, self, self.modelLayer, self.presentationLayer);
    int index = [self getCurrentIndex];
    if (index != currentImageIndex)
    {
        UIImage *blurImage = self.blurredSnapshots[index];
        UIGraphicsPushContext(ctx);
        //CGContextDrawImage(ctx, self.bounds, blurImage.CGImage);
        [blurImage drawAtPoint:CGPointZero];
        UIGraphicsPopContext();
    }
}



- (id<CAAction>)actionForKey:(NSString *)event
{
    if ([event isEqualToString:@"blur"])
    {
        if (implicitAnimationsDisabled) return nil;
        CABasicAnimation *anim = [CABasicAnimation animationWithKeyPath:@"blur"];
        [anim setFromValue:@([self.presentationLayer blur])];
        [anim setDuration:1.5f];
        [anim setTimingFunction:[CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionDefault]];
        [anim setKeyPath:@"blur"];
        return anim;
    }
    return [super actionForKey:event];
}

@end

@implementation UIView (Blur)

- (CALayer*)blurredLayer
{
    return (CALayer *)objc_getAssociatedObject(self, &BLUR_LAYER);;
}

- (void)setBlurredLayer:(CALayer*)layer
{
    objc_setAssociatedObject(self, &BLUR_LAYER, layer, OBJC_ASSOCIATION_RETAIN);
}

- (void)updateSnapshots
{
    self.blurredLayer.opacity = 0;
    [self.blurredLayer updateSnapshots];
    self.blurredLayer.opacity = 1;
}

- (float)blur
{
    return [self.blurredLayer blur];
}

- (void)setBlur:(float)blur
{    
    if (!self.blurredLayer)
    {
        self.blurredLayer = [[CABlurLayer alloc] initWithLayer:nil];
        self.blurredLayer.bounds = self.bounds;
        self.blurredLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        [self.layer addSublayer:self.blurredLayer];
        if (![self.blurredLayer blurredSnapshots]) [self.blurredLayer updateSnapshots];
    }
    self.blurredLayer.blur = blur;
}

@end
