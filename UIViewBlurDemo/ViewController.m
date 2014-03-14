//
//  ViewController.m
//  UIViewBlurDemo
//
//  Created by Francesco Mattia on 11/03/2014.
//  Copyright (c) 2014 Francesco Mattia. All rights reserved.
//

#import "ViewController.h"
#import "UIView+Blur.h"
#import "UIImage+ImageEffects.h"

@interface ViewController ()
@property (strong, nonatomic) IBOutlet UIBlurImageView *imageView;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)blurValueChanged:(UISlider*)sender {
    self.imageView.blur = sender.value;
}

- (IBAction)animateToBlurZero:(id)sender {
    NSLog(@"Animating implictly to .blur = 0");
    [UIView animateWithDuration:2.0f animations:^{
        self.imageView.blur = 0;
    }];
}

- (IBAction)animateToBlurOneNew:(id)sender {
    NSLog(@"Animating implictly to .blur = 1");
    [UIView animateWithDuration:2.0f animations:^{
        self.imageView.blur = 1;
    }];
}

- (IBAction)animateToBlurOne:(id)sender {
    NSLog(@"Animating explictly to .blur = 1");
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"blur"];
    
    // Set the initial and the final values
    [animation setToValue:@(1.0)];
    
    // Set duration
    [animation setDuration:3.0f];
    
    // Set animation to be consistent on completion
    //[animation setRemovedOnCompletion:NO];
    //[animation setFillMode:kCAFillModeForwards];
    
    // Add animation to the view's layer
    [self.imageView.blurredLayer addAnimation:animation forKey:@"blur"];
    self.imageView.blurredLayer.blur = 1;
}

- (IBAction)blurZero:(id)sender {
    NSLog(@"NOT animating to .blur = 0");
    self.imageView.blur = 0;
}
- (IBAction)blurOne:(id)sender {
    NSLog(@"NOT animating to .blur = 1");
    self.imageView.blur = 1;
}
@end
