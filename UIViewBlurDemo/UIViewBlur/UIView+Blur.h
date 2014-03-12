//
//  UIView+Blur.h
//  UIViewBlurDemo
//
//  Created by Francesco Mattia on 11/03/2014.
//  Copyright (c) 2014 Francesco Mattia. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (Blur)

@property (nonatomic, assign) float blur;

- (UIImage*)snapshot;
- (void)updateSnaphots;

@end
