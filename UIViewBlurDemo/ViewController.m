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
@property (strong, nonatomic) IBOutlet UIImageView *imageView;

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
    [UIView animateWithDuration:2.0f animations:^{
        self.imageView.blur = 0;
    }];
}

- (IBAction)animateToBlurOne:(id)sender {
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:2.0f];
    self.imageView.blur = 1;
    [UIView commitAnimations];
}

@end
