//
//  UIView+Blur.m
//  UIViewBlurDemo
//
//  Created by Francesco Mattia on 11/03/2014.
//  Copyright (c) 2014 Francesco Mattia. All rights reserved.
//

#import "UIView+Blur.h"
#import <objc/runtime.h>
#import "UIImage+ImageEffects.h"
#define maxBlurRadius 20.0f
#define steps 10

static char BLUR_SNAPSHOT;

@interface CABlurLayer : CALayer

@end

@implementation CABlurLayer

+ (BOOL)needsDisplayForKey:(NSString *) key {
    NSLog(@"key: %@",key);
    if ([key isEqualToString:@"blur"]) {
        return YES;
    }
    return [super needsDisplayForKey:key];
}

@end

@implementation UIView (Blur)

@dynamic blur;

+ (void)load {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Class class = [self class];
        
        // When swizzling a class method, use the following:
        // Class class = object_getClass((id)self);
        
        SEL originalSelector = @selector(drawRect:);
        SEL swizzledSelector = @selector(otherDrawRect:);
        
        Method originalMethod = class_getInstanceMethod(class, originalSelector);
        Method swizzledMethod = class_getInstanceMethod(class, swizzledSelector);
        
        BOOL didAddMethod =
        class_addMethod(class,
                        originalSelector,
                        method_getImplementation(swizzledMethod),
                        method_getTypeEncoding(swizzledMethod));
        if (didAddMethod) {
            class_replaceMethod(class,
                                swizzledSelector,
                                method_getImplementation(originalMethod),
                                method_getTypeEncoding(originalMethod));
        } else {
            method_exchangeImplementations(originalMethod, swizzledMethod);
        }
    });
}

- (void)otherDrawRect:(CGRect)rect
{
    [self otherDrawRect:rect];
    [self updateSnaphots];
}

- (NSArray*)blurredSnapshots
{
    return (NSArray *)objc_getAssociatedObject(self, &BLUR_SNAPSHOT);;
}

- (void)setBlurredSnapshots:(NSArray*)array
{
    objc_setAssociatedObject(self, &BLUR_SNAPSHOT, array, OBJC_ASSOCIATION_RETAIN);
}

- (UIImage*)snapshot
{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0);
    [self drawViewHierarchyInRect:self.bounds afterScreenUpdates:NO];
    return UIGraphicsGetImageFromCurrentImageContext();
}

- (void)updateSnaphots
{
    UIImage *snapshot = [self snapshot];
    NSMutableArray *array = [NSMutableArray new];
    for (int i = 0; i <= steps; i++)
    {
        UIImage *blurImage = [snapshot applyBlurWithRadius:5*(i*1/(float)steps) tintColor:[UIColor clearColor] saturationDeltaFactor:1 maskImage:nil];
        CABlurLayer *aLayer = [CABlurLayer layer];
        aLayer.bounds = self.bounds;
        aLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        aLayer.contents = (id)blurImage.CGImage;
        aLayer.opacity = 0;
        [self.layer addSublayer:aLayer];
        [array addObject:aLayer];
    }
    [self setBlurredSnapshots:array];
}

- (void)setBlur:(float)blur
{
    float value = blur * steps;
    int floor = floorf(value);
    if (![self blurredSnapshots]) [self updateSnaphots];
    [CATransaction begin];
    [CATransaction setValue: (id) kCFBooleanTrue forKey: kCATransactionDisableActions];
    for (int i = 0; i <= steps; i++)
    {
        CABlurLayer *layer = (CABlurLayer*)[self blurredSnapshots][i];
        if (floor == i) {
            [layer setValue:@(0) forKey:@"blur"];
            layer.opacity = 1;
        }
        else {
            layer.opacity = 0;
        }
    }
    [CATransaction commit];
}

@end
